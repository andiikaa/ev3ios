//
//  Ev3Command.swift
//  EV3BTSpike
//
//  Created by Andre on 21.04.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

/// Send a batch command of multiple direct commands at once.
public class Ev3Command {
    var brick: Ev3Brick?
    
    var commandType: CommandType?
    var buffer: NSMutableData = NSMutableData()
    var response: Ev3Response?
    
    convenience init(brick: Ev3Brick) {
        self.init(commandType: CommandType.directNoReply)
        self.brick = brick
    }
    
    convenience init(commandType: CommandType){
        self.init(commandType: commandType, globalSize: 0, localSize: 0)
    }
    
    init(commandType: CommandType, globalSize: UInt16, localSize: Int){
        initialize(commandType: commandType, globalSize: globalSize, localSize: localSize)
    }
    
    /**
     
     Note: paramters not checked at the moment. This can lead to unexpected behavior. Be sure to be in range.
     
     - parameter globalSize: max value is 1024
     - parameter localSize: max value is 64
     
     */
    public func initialize(commandType: CommandType, globalSize: UInt16, localSize: Int){
        self.commandType = commandType
        
        let response = Ev3ResponseManager.createResponse()
        self.response = response
        
        // 2 bytes (this gets filled in later when the user calls toBytes()
        buffer.appendUInt16(value: 0xffff)
        
        print("created sequence: \(response.sequence)")
        
        // 2 bytes
        buffer.appendUInt16LE(value: response.sequence)
        
        // 1 byte
        buffer.appendUInt8(value: commandType.rawValue)
        
        if(commandType == CommandType.directReply || commandType == CommandType.directNoReply){
            // 2 bytes (llllllgg gggggggg)
            
            //lower bits of global size
            buffer.appendUInt8(value: UInt8(globalSize))
            
            // upper bits of globalSize + localSize
            buffer.appendUInt8(value: UInt8(localSize << 2 | Int((globalSize >> 8) & 0x03)))
        }
    }
    
    public func initialize(commandType: CommandType) {
        initialize(commandType: commandType, globalSize: 0, localSize: 0);
    }
    
    func addParameter(_ parameter: UInt8){
        buffer.appendUInt8(value: ArgumentSize.byte.rawValue)
        buffer.appendUInt8(value: parameter)
    }
    
    func addParameter(_ parameter: Int16) {
        buffer.appendUInt8(value: ArgumentSize.short.rawValue)
        buffer.appendInt16LE(value: parameter)
    }
    
    func addParameter(_ parameter: UInt16) {
        buffer.appendUInt8(value: ArgumentSize.short.rawValue)
        buffer.appendUInt16LE(value: parameter)
    }
    
    func addParameter(_ parameter: UInt32) {
        buffer.appendUInt8(value: ArgumentSize.int.rawValue)
        buffer.appendUInt32LE(value: parameter)
    }
    
    func addParameter(_ s: String){
        // 0x84 = long format, null terminated string
        buffer.appendUInt8(value: ArgumentSize.string.rawValue)
        let bytes: [UInt8] = [UInt8](s.utf8)
        buffer.append(bytes, length: bytes.count)
        buffer.appendUInt8(value: 0x00)
    }
    
    func addGlobalIndex(_ index: UInt8) {
        // 0xe1 = global index, long format, 1 byte
        buffer.appendUInt8(value: 0xe1);
        buffer.appendUInt8(value: index);
    }
    
    func addOpcode(_ opcode: Opcode) {
        // 1 or 2 bytes (opcode + subcmd, if applicable)
        // I combined opcode + sub into ushort where applicable, so we need to pull them back apart here
        
        if opcode.rawValue > Opcode.tst.rawValue {
            buffer.appendUInt8(value: UInt8(opcode.rawValue >> 8))
        }
        buffer.appendUInt8(value: UInt8(opcode.rawValue & 0x00ff))
    }
    
    func toBytes() -> NSData
    {
        // size of data, not including the 2 size bytes
        let size = UInt32(buffer.length - 2)
        
        let byteArray = ByteTools.uint32ToUint8Array(value: size)
    
        var msb = UInt8(byteArray[2])
        var lsb = UInt8(byteArray[3])
    
        // little-endian
        buffer.replaceBytes(in: NSRange(location: 0, length: 1), withBytes: &lsb)
        buffer.replaceBytes(in: NSRange(location: 1, length: 1), withBytes: &msb)

        //TODO is a copy needed if commands executed asyn?
        //return NSData(bytes: buffer!.bytes, length: buffer!.length)
        return buffer
    }
    
    /**
     
     Append the Set LED Pattern command to an existing Command object

     - parameter ledPattern: The LED pattern to display.
     */
    public func setLedPattern(ledPattern: LedPattern) {
        addOpcode(Opcode.uiWrite_LED)
        addParameter(ledPattern.rawValue)
    }
    
    
    /**
     
     Turns the specified motor at the specified power
     
     - parameter power: only values between -100 and 100
     */
    public func turnMotorAtPower(ports: OutputPort, power: Int16) {
        addOpcode(Opcode.outputPower)
        addParameter(UInt8(0x00))       // layer
        addParameter(ports.rawValue)	// ports
        let pwr = ByteTools.firstByteOfInt16(value: power)
        addParameter(pwr)      // power
    }
    
    /**
     
     Turn the specified motor(s) at the specified speed
     
     - parameter ports: Port or ports to apply the command
     - parameter speed: The speed to applay to the specified motors (-100% to 100%)
     */
    public func turnMotorAtSpeed(ports: OutputPort, speed: Int16){
        addOpcode(Opcode.outputSpeed)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        let sp = ByteTools.firstByteOfInt16(value: speed)
        addParameter(sp)
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
        addOpcode(Opcode.outputStepSpeed)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        let sp = ByteTools.firstByteOfInt16(value: speed)
        addParameter(sp)
        addParameter(rampUpSteps)
        addParameter(constantSteps)
        addParameter(rampDownSteps)
        addParameter(UInt8(brake ? 0x01 : 0x00))
    }
    
    /**
     Step the motor connected to specified port or ports at the specified power for the specified number of steps.
     - parameter ports: A Specified port or all
     - parameter power: The power at which to turn the motor (-100 to 100)
     - parameter steps: The number of steps to turn the motor
     - parameter brake: Apply brake to motor at end of routine
     */
    public func stepMotorAtPower(ports: OutputPort, power: Int16, steps: UInt32, brake: Bool){
        stepMotorAtPower(ports: ports, power: power, rampUpSteps: 0, constantSteps: steps, rampDownSteps: 10, brake: brake)        
    }
    
    /**
     Step the motor connected to specified port or ports at the specified power for the specified number of steps.
     - parameter ports: A Specified port or all
     - parameter power: The power at which to turn the motor (-100 to 100)
     - parameter rampUpSteps:
     - parameter constantSteps:
     - parameter rampDownSteps:
     - parameter brake: Apply brake to motor at end of routine
     */
    public func stepMotorAtPower(ports: OutputPort, power: Int16, rampUpSteps: UInt32, constantSteps: UInt32, rampDownSteps: UInt32, brake: Bool){
        addOpcode(Opcode.outputStepPower)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        let pwr = ByteTools.firstByteOfInt16(value: power)
        addParameter(pwr)
        addParameter(rampUpSteps)
        addParameter(constantSteps)
        addParameter(rampDownSteps)
        addParameter(UInt8(brake ? 0x01 : 0x00))
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
        addOpcode(Opcode.outputStepSync)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        let sp = ByteTools.firstByteOfInt16(value: speed)
        addParameter(sp)
        addParameter(turnRatio)
        addParameter(step)
        addParameter(UInt8(brake ? 0x01 : 0x00))
    }
    
    /**
     Turn the motor connected to the specified port or ports at the specified speed for the specified times.
     
     - parameter ports: the specific ports
     - parameter speed: the speed at which to turn the motor (-100 to 100)
     - parameter milliseconds: number of ms to run at constant speed
     - parameter brake: apply brake to motor at end of routine
     */
    public func turnMotorAtSpeedForTime(ports: OutputPort, speed: Int16, milliseconds: UInt32, brake: Bool){
        turnMotorAtSpeedForTime(ports: ports, speed: speed, msRampUp: 0, msConstant: milliseconds, msRampDown: 0, brake: brake)
    }
    
    /**
     Turn the motor connected to the specified port or ports at the specified speed for the specified times.
     
     - parameter ports: the specific ports
     - parameter speed: the speed at which to turn the motor (-100 to 100)
     - parameter msRampUp: number of ms to get up to speed
     - parameter msConstant: number of ms to run at constant speed
     - parameter msRampDown: number of ms to slow down to a stop
     - parameter brake: apply brake to motor at end of routine
     */
    public func turnMotorAtSpeedForTime(ports: OutputPort, speed: Int16, msRampUp: UInt32, msConstant: UInt32, msRampDown: UInt32, brake: Bool){
        addOpcode(Opcode.outputTimeSpeed)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        let sp = ByteTools.firstByteOfInt16(value: speed)
        addParameter(sp)
        addParameter(msRampUp)
        addParameter(msConstant)
        addParameter(msRampDown)
        addParameter(UInt8(brake ? 0x01 : 0x00))
    }
    
    /**
     This function enables synchonizing two motors. Synchonization should be used when motors should run
     as synchrone as possible, for example to archieve a model driving straight.
     Duration is specified in time.
     
     #### Turn ratio:
     
     * 0 : Motor will run with same power
     * 100 : One motor will run with specified power while the other will be close to zero
     * 200: One motor will run with specified power forward while the other will run in the
     opposite direction at the same power level.
     
     - parameter ports: the specific ports
     - parameter speed: the speed at which to turn the motor (-100 to 100)
     - parameter turnRatio: the turn ration to apply (-200 to 200)
     - parameter time: the time to turn the motor(s)
     - parameter brake: brake or coast at the end
     */
    public func timeMotorSync(ports: OutputPort, speed: Int16, turnRatio: Int16, time: UInt32, brake: Bool){
        addOpcode(Opcode.outputTimeSync)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        let sp = ByteTools.firstByteOfInt16(value: speed)
        addParameter(sp)
        addParameter(turnRatio)
        addParameter(time)
        addParameter(UInt8(brake ? 0x01 : 0x00))
    }
    
    /**
     Clears the tacho count used as sensor input.
     */
    public func clearCount(ports: OutputPort){
        addOpcode(Opcode.outputClearCount)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
    }
    
    /** 
     
     Start the motor(s) based on previous commands
     
    - parameter ports: Port or ports to apply the command to.

    */
    public func startMotor(ports: OutputPort) {
        addOpcode(Opcode.outputStart)
        addParameter(UInt8(0x00))             // layer
        addParameter(ports.rawValue)   // ports
    }
    
    /**
  
     Append the Stop Motor command to an existing Command object
     
     - parameter ports: Port or ports to stop
     - parameter brake: Apply the brake at the end of the command
     */
    public func stopMotor(ports: OutputPort, brake: Bool) {
        addOpcode(Opcode.outputStop)
        addParameter(UInt8(0x00))                 // layer
        addParameter(ports.rawValue)       // ports
        addParameter(UInt8(brake ? 0x01 : 0x00))	// brake (0 = coast, 1 = brake)
    }
    
    /**
     
     Append the Get Firmware Version command to an existing Command object
     
     - parameter maxLength: Maximum length of string to be returned
                            ATTENTION: maxLength should not be greater than 255 bytes
     - parameter index: Index at which the data should be returned inside of the global buffer
                        ATTENTION: index should not be greater than 1024
     
     */
    public func getFirwmareVersion(maxLength: UInt8, index: UInt32) {
        addOpcode(Opcode.uiRead_GetFirmware)
        addParameter(maxLength)		// global buffer size
        addGlobalIndex(UInt8(index))   // index where buffer begins
    }
    
    /*
    Add the Is Brick Pressed command to an existing Command object
    
    - parameter button:Button to check
    - parameter index: Index at which the data should be returned inside of the global buffer. 
                        ATTENTION: Index cannot be greater than 1024
     */
    public func isBrickButtonPressed(button: BrickButton, index: Int) {
        addOpcode(Opcode.uiButton_Pressed)
        addParameter(UInt8(button.rawValue))
        addGlobalIndex(UInt8(index))
    }
    
    /**
        Append the Get Type/Mode command to an existing Command object

     - parameter port: The port to query
     - parameter typeIndex: The index to hold the Type value in the global buffer. Index for Type cannot be greater than 1024
     - parameter modeIndex: The index to hold the Mode value in the global buffer. Index for Mode cannot be greater than 1024
    */
    public func getTypeMode(port: InputPort, typeIndex: Int, modeIndex: Int) {
        addOpcode(Opcode.inputDevice_GetTypeMode)
        addParameter(UInt8(0x00))                 // layer
        addParameter(port.rawValue)       // port
        addGlobalIndex(UInt8(typeIndex))	// index for type
        addGlobalIndex(UInt8(modeIndex))	// index for mode
    }
    
    /**
        Append the Ready SI command to an existing Command object
 
     - parameter port: The port to query.
     - parameter mode: The mode to read the data as.
     - parameter index: The index to hold the return value in the global buffer. Index cannot be greater than 1024
     */
    public func readySI(port: InputPort, mode: UInt8, index: Int) {
        addOpcode(Opcode.inputDevice_ReadySI)
        addParameter(UInt8(0x00))                  // layer
        addParameter(port.rawValue)         // port
        addParameter(UInt8(0x00))                  // type
        addParameter(mode)                  // mode
        addParameter(UInt8(0x01))                  // # values
        addGlobalIndex(UInt8(index))		// index for return data
    }
    
    /**
        Append the Ready Raw command to an existing Command object

     - parameter port: The port to query.
     - parameter mode: The mode to query the value as.
     - parameter index: The index in the global buffer to hold the return value. Index cannot be greater than 1024.
     */
    public func readyRaw(port: InputPort, mode: UInt8, index: Int){
        addOpcode(Opcode.inputDevice_ReadyRaw)
        addParameter(UInt8(0x00))				// layer
        addParameter(port.rawValue)		// port
        addParameter(UInt8(0x00))				// type
        addParameter(mode)              // mode
        addParameter(UInt8(0x01))				// # values
        addGlobalIndex(UInt8(index))	// index for return data
    }
    
    /**
        Append the Ready Percent command to an existing Command object
 
     - parameter port: The port to query
     - parameter mode: The mode to query the value as
     - parameter index: The index in the global buffer to hold the return value. Index cannot be greater than 1024.
     */
    public func readyPercent(port: InputPort, mode: UInt8, index: Int) {
        addOpcode(Opcode.inputDevice_ReadyPct)
        addParameter(UInt8(0x00))                 // layer
        addParameter(port.rawValue)		// port
        addParameter(UInt8(0x00))                 // type
        addParameter(mode)                 // mode
        addParameter(UInt8(0x01))                 // # values
        addGlobalIndex(UInt8(index))		// index for return data
    }
    
    
    /**
     Append the Play Tone command to an existing Command object
 
    - parameter volume: Volme to play the tone (0-100)
    - parameter frequency: Frequency of the tone in hertz (250 - 10000)
    - parameter duration: Duration of the tone in milliseconds
     */
    public func playTone(volume: UInt8, frequency: UInt16, duration: UInt16) {
        addOpcode(Opcode.sound_Tone)
        addParameter(volume)        // volume
        addParameter(frequency)     // frequency
        addParameter(duration)      // duration (ms)
    }
    
    /**
     Append the Play Sound command to an existing Command object
    
    - parameter volume: Volume to play the sound
    - parameter filename: Filename on the Brick of the sound to play
     */
    public func playSound(volume: UInt8, filename: String){
        addOpcode(Opcode.sound_Play)
        addParameter(volume)
        addParameter(filename)
    }
    
    /**
     Waits till sound is ready (waits for completion)
     */
    public func soundReady(){
        addOpcode(Opcode.sound_Ready)
    }
    
    /// sends the command to the brick
    public func sendCommand() -> NSData?{
        brick?.sendCommand(self)
        initialize(commandType: CommandType.directNoReply)
        return response?.data
    }
    
    /**
    Append the Get Device Name command to an existing Command object
    
    - parameter port: The port to query
    - parameter bufferSize: Size of the buffer to hold the returned data
    - parameter index: Index to the position of the returned data in the global buffer. Max. 1024
     */
    public func getDeviceName(port: InputPort, bufferSize: Int, index: Int) {
        addOpcode(Opcode.inputDevice_GetDeviceName)
        addParameter(UInt8(0x00))
        addParameter(port.rawValue)
        addParameter(UInt8(bufferSize))
        addGlobalIndex(UInt8(index))
    }
    
    /**
     Appends the get battery level command to an existing command object
     
     returns level 0-100 (8 bit)
    */
    public func getBatteryLevel(index: Int){
        addOpcode(Opcode.uiRead_GetLBatt)
        addGlobalIndex(UInt8(index))
    }
    
    /**
     Appends the get battery voltage command to an existing command object
     */
    public func getBatteryVoltage(index: Int){
        addOpcode(Opcode.uiRead_GetVBatt)
        addGlobalIndex(UInt8(index))
    }
    
    /**
     Appends the program_start command.
     */
    public func programStart(programId: UInt16, filename: String, sizeIndex: Int, ipIndex: Int, debug: Bool){
        loadImage(id: programId, name: filename, sizeIndex: sizeIndex, ipIndex: ipIndex)
        addOpcode(Opcode.programStart)
        addParameter(programId) // program id slot
        addGlobalIndex(UInt8(sizeIndex)) // size offset
        addGlobalIndex(UInt8(ipIndex))  // ip offset
        addParameter(UInt8(debug ? 0x01 : 0x00)) // debug mode
    }
    
    /**
     Enables loading a program from memory. Works only in compound with start program
     - parameter id: 
     0x00 : reserved for user interface program
     0x01 : used for user projects, apps, tools
     0x02 : used for direct commands from c_com
     0x03 : used for direct commands from c_ui
     0x04 : used for debug command from ui
     
     - parameter name: name of the program
     
     returns:
     - (Data32) Size - image size in bytes
     - (Data32) *IP - address of image
     */
    public func loadImage(id: UInt16, name: String, sizeIndex: Int, ipIndex: Int){
        addOpcode(Opcode.file_LoadImage)
        addParameter(id)
        addParameter(name)
        addGlobalIndex(UInt8(sizeIndex))
        addGlobalIndex(UInt8(ipIndex))
    }
    
    /**
     Enables program execution to wait for output ready. (Wait for completion)
     */
    public func outputReady(ports: OutputPort){
        addOpcode(Opcode.outputReady)
        addParameter(UInt8(ports.rawValue))
    }
    
    /**
     This function enables specifying the output device type. If u use this, it may be good also to 
     use outputReady() immediatly after this function.
     */
    public func outputSetType(ports: OutputPort, type: DeviceType){
        addOpcode(Opcode.outputSetType)
        addParameter(UInt8(0x00))
        addParameter(ports.rawValue)
        addParameter(type.rawValue)
    }

}
