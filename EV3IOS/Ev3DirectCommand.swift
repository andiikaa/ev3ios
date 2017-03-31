//
//  Ev3DirectCommand.swift
//  EV3BTSpike
//
//  Created by Andre on 22.04.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

/// Send "direct commands" to the EV3 brick.  These commands are executed instantly and are not batched.
public class Ev3DirectCommand {
    
    let brick: Ev3Brick
    
    init(brick: Ev3Brick){
        self.brick = brick
    }
    
    /**
        Turn the motor connected to the specified port or ports at the specified power.
     
        - parameter ports: A specific port or Ports.All
     
        - parameter power: The power at which to turn the motor (-100 to 100)
     */
    public func turnMotorAtPower(onPorts ports: OutputPort, withPower power: Int16){
        let c = Ev3Command(commandType: .directNoReply)
        c.turnMotorAtPower(ports: ports, power: power)
        c.startMotor(ports: ports)
        brick.sendCommand(c)
    }
    
    /**
     
     Turn the specified motor(s) at the specified speed.
     
     - parameter ports: Port or ports to apply the command
     - parameter speed: The speed to applay to the specified motors (-100% to 100%)
     
     */
    public func turnMotorAtSpeed(onPorts ports: OutputPort, withSpeed speed: Int16){
        let c = Ev3Command(commandType: .directNoReply)
        c.turnMotorAtSpeed(ports: ports, speed: speed)
        c.startMotor(ports: ports)
        brick.sendCommand(c)
    }
    
    /**
     This function enables specifying a full motor power cycle in tacho counts. The system will automatically
     adjust the power level to the motor to keep the specified output speed.
     
     - parameter ports: one or more ports
     - parameter speed: the speed to go (-100 to 100)
     - parameter steps: specifyes the constant power period in tacho counts.
     - parameter brake: apply brake to motor(s) at the end of routine
     */
    public func stepMotorAtSpeed(ports: OutputPort, speed: Int16, steps: UInt32, brake: Bool){
        stepMotorAtSpeed(ports: ports, speed: speed, rampUpSteps: 0, constantSteps: steps,
                         rampDownSteps: 0, brake: brake)
    }
    
    /**
     This function enables specifying a full motor power cycle in tacho counts. The system will automatically
     adjust the power level to the motor to keep the specified output speed.
     
     - parameter ports: one or more ports
     - parameter speed: the speed to go (-100 to 100)
     - parameter rampUpSteps: specifyes the power ramp up periode in tacho count.
     - parameter constantSteps: specifyes the constant power period in tacho counts.
     - parameter rampDownSteps: specifyes the power down period in tacho counts.
     - parameter brake: apply brake to motor(s) at the end of routine
     */
    public func stepMotorAtSpeed(ports: OutputPort, speed: Int16, rampUpSteps: UInt32, constantSteps: UInt32, rampDownSteps: UInt32, brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.stepMotorAtSpeed(ports: ports, speed: speed, rampUpSteps: rampUpSteps, constantSteps: constantSteps,
                           rampDownSteps: rampUpSteps, brake: brake)
        brick.sendCommand(c)
    }
    
    
    /**
     
     Step the motor connected to specified port or ports at the specified power for the specified number of steps
     
     - parameter ports: A Specified port or all
     - parameter power: The power at which to turn the motor (-100 to 100)
     - parameter rampUpSteps:
     - parameter constantSteps:
     - parameter rampDownSteps:
     - parameter brake: Apply brake to motor at end of routine
     */
    public func stepMotorAtPower(ports: OutputPort, power: Int16, rampUpSteps: UInt32, constantSteps: UInt32, rampDownSteps: UInt32, brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.stepMotorAtPower(ports: ports, power: power, rampUpSteps: rampDownSteps, constantSteps: constantSteps, rampDownSteps: rampDownSteps, brake: brake)
        brick.sendCommand(c)
    }
    /**
     This function enables synchonizing two motors. Synchonization should be used when motors should run as
     synchrone as possible, for example to archieve a model driving straight. Duration is specified in
     tacho counts.
     
     #### Turn ratio:
     
     * 0 : Motor will run with same power
     * 100 : One motor will run with specified power while the other will be close to zero
     * 200: One motor will run with specified power forward while the other will run in the
     opposite direction at the same power level.
     
     - parameter ports: the specific ports
     - parameter speed: the speed at which to turn the motor (-100 to 100)
     - parameter turnRatio: the turn ration to apply (-200 to 200)
     - parameter step: the number of steps to turn the motor(s)
     - parameter brake: brake or coast at the end
     
     */
    public func stepMotorSync(ports: OutputPort, speed: Int16, turnRatio: Int16, step: UInt32, brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.stepMotorSync(ports: ports, speed: speed, turnRatio: turnRatio, step: step, brake: brake)
        brick.sendCommand(c)
    }
    
    /**
     This function enables synchonizing two motors. Synchonization should be used when motors should run as synchrone as possible, 
     for example to archieve a model driving straight. Duration is specified in time.
     
     #### Turn ratio:
     
     * 0 : Motor will run with same power
     * 100 : One motor will run with specified power while the other will be close to zero
     * 200: One motor will run with specified power forward while the other will run in the
     opposite direction at the same power level.
     
     - parameter ports: the specific ports
     - parameter speed: the speed at which to turn the motor (-100 to 100)
     - parameter turnRatio: the turn ration to apply (-200 to 200)
     - parameter time: the number of steps to turn the motor(s)
     - parameter brake: brake or coast at the end
     
     */
    public func timeMotorSync(ports: OutputPort, speed: Int16, turnRatio: Int16, time: UInt32, brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.timeMotorSync(ports: ports, speed: speed, turnRatio: turnRatio, time: time, brake: brake)
        brick.sendCommand(c)
    }
    
    
    /**
     Turn the motor connected to the specified port or ports at the specified speed for the specified times.
     - parameter ports: the specific ports
     - parameter speed: the power at which to turn the motor (-100 to 100)
     - parameter milliseconds: number of ms to run at constant speed
     - parameter brake: apply brake to motor at end of routine
     */
    public func turnMotorAtSpeedForTime(ports: OutputPort, speed: Int16, milliseconds: UInt32, brake: Bool){
        turnMotorAtSpeedForTime(ports: ports, speed: speed, msRampUp: 0, msConstant: milliseconds, msRampDown: 0, brake: brake)
    }
    
    /**
     Turn the motor connected to the specified port or ports at the specified speed for the specified times.
     - parameter ports: the specific ports
     - parameter speed: the power at which to turn the motor (-100 to 100)
     - parameter msRampUp: number of ms to get up to speed
     - parameter msConstant: number of ms to run at constant speed
     - parameter msRampDown: number of ms to slow down to a stop
     - parameter brake: apply brake to motor at end of routine
     */
    public func turnMotorAtSpeedForTime(ports: OutputPort, speed: Int16, msRampUp: UInt32, msConstant: UInt32, msRampDown: UInt32, brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.turnMotorAtSpeedForTime(ports: ports, speed: speed, msRampUp: msRampUp, msConstant: msConstant, msRampDown: msRampDown, brake: brake)
        brick.sendCommand(c)
    }
    
    /**
     
     Step the motor connected to specified port or ports at the specified power for the specified number of steps
     
     - parameter ports: A Specified port or all
     - parameter power: The power at which to turn the motor (-100 to 100)
     - parameter steps:
     - parameter brake: Apply brake to motor at end of routine
     */
    public func stepMotorAtPower(ports: OutputPort, power: Int16, steps: UInt32, brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.stepMotorAtPower(ports: ports, power: power, steps: steps, brake: brake)
        brick.sendCommand(c)
    }
    
    /**
        Stops motors on the specified ports.
     
        - parameter ports: The port or ports to which the stop command will be sent.
     
        - parameter brake: Apply brake to motor at end of routine.
     */
    public func stopMotor(onPorts ports: OutputPort, withBrake brake: Bool){
        let c = Ev3Command(commandType: .directNoReply)
        c.stopMotor(ports: ports, brake: brake)
        brick.sendCommand(c)
    }
    
    /**
     
     Set EV3 brick LED pattern
    
     - parameter ledPattern: Pattern to display on LED
     */
    public func setLedPattern(ledPattern: LedPattern) {
        let c = Ev3Command(commandType: .directNoReply)
        c.setLedPattern(ledPattern: ledPattern)
        brick.sendCommand(c)
    }
    
    /**
        Return the current version number of the firmware running on the EV3 brick.
     
     - parameter receivedFirmware: Callback for receiving the Firmware
     
     */
    public func getFirmwareVersion(receivedFirmware: @escaping (String?) -> Void){
        let c = Ev3Command(commandType: .directReply, globalSize: 0x10, localSize: 0)
        c.getFirwmareVersion(maxLength: 0x10, index: 0)
        c.response?.responseReceivedCallback = {
            if let data = c.response?.data, let str = String(data: data as Data, encoding: String.Encoding.utf8) {
                receivedFirmware(str)
            } else {
                receivedFirmware(nil)
            }
        }
        
        brick.sendCommand(c)
    }
    
    /**
    Get the name of the device attached to the specified port
 
     - parameter port: Port to query
     - parameter receivedDeviceName: Callback to receive the device name
     */
    public func getDeviceName(port: InputPort, receivedDeviceName: @escaping (String?) -> Void) {
        let c = Ev3Command(commandType: CommandType.directReply, globalSize: 0x7f, localSize: 0)
        c.getDeviceName(port: port, bufferSize: 0x7f, index: 0)
        c.response?.responseReceivedCallback = {
            if let data = c.response?.data, let str = String(data: data as Data, encoding: String.Encoding.utf8) {
                receivedDeviceName(str)
            } else {
                receivedDeviceName(nil)
            }
        }
        
        brick.sendCommand(c)
    }
    
    /**
     Gets the battery level in range from 0 to 100.
     */
    public func getBatteryLevel(receivedBatLevel: @escaping (UInt8?) -> Void){
        let c = Ev3Command(commandType: .directReply, globalSize: 8, localSize: 0)
        c.getBatteryLevel(index: 0)
        c.response?.responseReceivedCallback = {
            if c.response?.data == nil {
                receivedBatLevel(nil)
            }
            else {
                let level = ByteTools.convertToUInt8(data: c.response?.data, position: 0)
                receivedBatLevel(level)
            }        
        }
        brick.sendCommand(c)
    }
    
    /**
     Gets the information, if a button is pressed
     */
    public func isBrickButtonPressed(button: BrickButton, receivedButtonState: @escaping (Bool?) -> Void){
        let c = Ev3Command(commandType: .directReply, globalSize: 1, localSize: 0)
        c.isBrickButtonPressed(button: BrickButton.up, index: 0)
        c.response?.responseReceivedCallback = {
            if(c.response?.data == nil){
                receivedButtonState(nil)
            }
            else{
                let data = ByteTools.convertToUInt8(data: c.response?.data, position: 0)
                receivedButtonState(data == 1)
            }
        }
        brick.sendCommand(c)
    }
    
    /**
     plays a sound file
     
     - parameter volume: Volume to play the sound
     - parameter filename: Filename on the Brick of the sound to play
     */
    public func playSound(volume: UInt8, filename: String){
        let c = Ev3Command(commandType: .directNoReply)
        c.playSound(volume: volume, filename: filename)
        brick.sendCommand(c)
    }
    
    /**
     plays a tone
     
     - parameter volume: Volme to play the tone (0-100)
     - parameter frequency: Frequency of the tone in hertz (250 - 10000)
     - parameter duration: Duration of the tone in milliseconds
     */
    public func playTone(volume: UInt8, frequency: UInt16, duration: UInt16) {
        let c = Ev3Command(commandType: .directNoReply)
        c.playTone(volume: volume, frequency: frequency, duration: duration)
        brick.sendCommand(c)
    }
    
    // TODO complete
    /*
     
     CMD: READY_RAW = 0x1C Arguments
     (Data8) LAYER – Specify chain layer number [0-3]
     (Data8) NO – Port number
     (Data8) TYPE – Specify device type (0 = Don’t change type) (Data8) MODE – Device mode [0-7] (-1 = Don’t change mode) (Data8) VALUES – Number of return values
     Returns (Depending on number of data samples requested in (VALUES))
     (Data32) VALUE1 – First value received from sensor in the specified mode
     
     */
    public func readyRaw(port: InputPort, mode: UInt8, receivedRaw: @escaping (NSData?) -> Void){
        let c = Ev3Command(commandType: .directReply, globalSize: 4, localSize: 0)
        c.readyRaw(port: port, mode: mode, index: 0)
        c.response?.responseReceivedCallback = {
            if let data = c.response?.data {
                let bytes = NSData(bytes: data.bytes, length: data.length)
                receivedRaw(bytes)
            } else {
                receivedRaw(nil)
            }
        }
        brick.sendCommand(c)
    }
    
    /**
     Clears the tacho count used as sensor input
     */
    public func clearCount(ports: OutputPort){
        let c = Ev3Command(commandType: .directNoReply)
        c.clearCount(ports: ports)
        brick.sendCommand(c)
    }
    
    /**
     starts a user program
     */
    public func programStart(name: String, debug: Bool){
        let c = Ev3Command(commandType: .directNoReply, globalSize: 8, localSize: 0)
        c.programStart(programId: 0x01, filename: name, sizeIndex: 0, ipIndex: 4, debug: debug)
        brick.sendCommand(c)
    }
    
}
