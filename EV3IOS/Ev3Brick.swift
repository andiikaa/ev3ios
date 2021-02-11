//
//  Ev3Brick.swift
//  EV3BTSpike
//
//  Created by Andre on 21.04.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

public protocol Ev3BrickChangedDelegate {
    func brickChanged()
}

public class Ev3Brick : Ev3ReportDelegate, Ev3ConnectionChangedDelegate {
    /// Interval for polling brick infos
    private let timeInterval: TimeInterval = 2.0
    
    /// The connection on which the app can read/write data
    private let connection: Ev3Connection
    
    private let alwaysSendEvents: Bool
    
    private var timer: Timer?
    
    /// Send "direct commands" to the EV3 brick.  These commands are executed instantly and are not batched.
    lazy public var directCommand: Ev3DirectCommand = Ev3DirectCommand(brick: self)
    
    /// Send a batch command of multiple direct commands at once.
    lazy public var command: Ev3Command = Ev3Command(brick: self)
    
    /// Send "system commands" to the EV3 brick.  These commands are executed instantly and are not batched.
    lazy var systemCommand: Ev3SystemCommand = Ev3SystemCommand(brick: self)
    
    /// Input and output ports on LEGO EV3 brick
    var ports: Dictionary<InputPort, Ev3Port>
    
    /// Buttons on the face of the LEGO EV3 brick
    var buttons: BrickButtons
    
    /// Add delegates to get informed, if the brick has changed
    var brickChangedDelegates = [Ev3BrickChangedDelegate]()
    
    let responseSize = 11

    public convenience init(connection: Ev3Connection){
        self.init(connection: connection, alwaysSendEvents: false)
    }
    
    /// Constructor
    /// - parameter comm: Object implementing the Ev3Connection interface for talking to the brick
    /// - parameter alwaysSendEvents: Send events when data changes, or at every poll
    public init(connection: Ev3Connection, alwaysSendEvents: Bool){
        self.connection = connection
        self.alwaysSendEvents = alwaysSendEvents
        buttons = BrickButtons()
        ports = [InputPort: Ev3Port]()
        
        connection.addEv3ReportDelegate(self)
        connection.connectionChangedDelegates.append(self)
        
        //TODO fix async pooling -> command too big for input stream?
        // schedule the background polling of the input stream
        /*timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(Ev3Brick.pollSensorsAsync), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)*/
        
        addAllPorts()
    }
    
    private func addAllPorts(){
        
        for (index, port) in InputPort.allValues.enumerated() {
            let p = Ev3Port(index: index, inputPort: port)
            
            //TODO set name
            
            ports.updateValue(p, forKey: port)
        }
  
    }
    
    public func ev3ConnectionChanged(connected: Bool){
        if !connected{
            timer?.invalidate()
        }
        else if (timer == nil || !(timer?.isValid ?? false)) {
            
            // schedule new timer
            /*timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(Ev3Brick.pollSensorsAsync), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)*/
        }
    }
    
    func reportReceived(report: [UInt8]){
        Ev3ResponseManager.handleResponse(report: report)
    }
    
    public func sendCommand(_ command: Ev3Command){
        connection.write(command: command)
    }
    
    public func closeConnection(){
        connection.close()
    }
    
    // TODO complete async polling
    @objc public func pollSensorsAsync() {
        var index = 0;
        
        let c = Ev3Command(commandType: CommandType.directReply, globalSize: UInt16((8 * responseSize) + 6), localSize: 0)
        
        for port in InputPort.allValues {
            guard let p = ports[port] else { continue }
            index = p.index * responseSize;
            
            c.getTypeMode(port: p.inputPort, typeIndex: index, modeIndex: index + 1)
            c.readySI(port: p.inputPort, mode: p.mode, index: index + 2)
            c.readyRaw(port: p.inputPort, mode: p.mode, index: index + 6)
            c.readyPercent(port: p.inputPort, mode: p.mode, index: index + 10)
        }        
    
        index += responseSize;
    
        c.isBrickButtonPressed(button: BrickButton.back,  index: index + 0);
        c.isBrickButtonPressed(button: BrickButton.left,  index: index + 1);
        c.isBrickButtonPressed(button: BrickButton.up,    index: index + 2);
        c.isBrickButtonPressed(button: BrickButton.right, index: index + 3);
        c.isBrickButtonPressed(button: BrickButton.down,  index: index + 4);
        c.isBrickButtonPressed(button: BrickButton.enter, index: index + 5);
        
        c.response?.responseReceivedCallback = {
            if let response = c.response {
                if response.data != nil {
                    self.backgroundDataReceived(response: response, index)
                }
            }
        }
    
        sendCommand(c);
    }
    
    private func backgroundDataReceived(response: Ev3Response, _ index: Int){
        var changed = false;
        
        for i in InputPort.allValues{
            guard let p = ports[i] else { continue }
            
            let type: UInt8 = convertToUInt8(data: response.data, position: (p.index * responseSize) + 0)
            
            //TODO is mode used?
            //let mode: UInt8 = convertToUInt8(c.response.data, position: (p.index * responseSize) + 1)
            
            let siValue: Float = convertToFloat(data: response.data, position: (p.index * responseSize) + 2)
            let rawValue: Int32 = convertToInt32(data: response.data, position: (p.index * responseSize) + 6)
            
            let percentValue: UInt8 = convertToUInt8(data: response.data, position: (p.index * responseSize) + 10)
            
            if p.type?.rawValue != type || abs(p.siValue ?? 0.0 - siValue) > 0.01 || p.rawValue != rawValue || p.percentValue != percentValue {
                changed = true
            }
            
            if let t = DeviceType(rawValue: type){
                p.type = t
            }
            else{
                p.type = DeviceType.unknown
            }
            
            p.siValue = siValue
            p.rawValue = rawValue
            p.percentValue = percentValue
        }

        
        if buttons.back != (convertToUInt8(data: response.data, position: index + 0) == 1) ||
            buttons.left != (convertToUInt8(data: response.data, position: index + 1) == 1) ||
            buttons.up != (convertToUInt8(data: response.data, position: index + 2) == 1) ||
            buttons.right != (convertToUInt8(data: response.data, position: index + 3) == 1) ||
            buttons.down != (convertToUInt8(data: response.data, position: index + 4) == 1) ||
            buttons.enter != (convertToUInt8(data: response.data, position: index + 5) == 1)
        {
            changed = true
        }
        
        buttons.back = (convertToUInt8(data: response.data, position: index + 0) == 1)
        buttons.left = (convertToUInt8(data: response.data, position: index + 1) == 1)
        buttons.up = (convertToUInt8(data: response.data, position: index + 2) == 1)
        buttons.right = (convertToUInt8(data: response.data, position: index + 3) == 1)
        buttons.down = (convertToUInt8(data: response.data, position: index + 4) == 1)
        buttons.enter = (convertToUInt8(data: response.data, position: index + 5) == 1)
        
        if changed || alwaysSendEvents {
            for del in brickChangedDelegates {
                del.brickChanged()
            }
        }
    }
    
    private func convertToFloat(data: NSData?, position: Int) -> Float{
        var out: Float = 0
        guard let data = data else { return 0.0 }
        data.getBytes(&out, range: NSMakeRange(position, 4))
        return out
    }
    
    private func convertToInt32(data: NSData?, position: Int) -> Int32 {
        var out: Int32 = 0
        guard let data = data else { return 0 }
        data.getBytes(&out, range: NSMakeRange(position, 4))
        return out
    }
    
    private func convertToUInt8(data: NSData?, position: Int) -> UInt8{
        var out: UInt8 = 0
        guard let data = data else { return 0 }
        data.getBytes(&out, range: NSMakeRange(position, 1))
        return out
    }
}
