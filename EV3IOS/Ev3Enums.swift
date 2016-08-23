//
//  Ev3Enums.swift
//  EV3BTSpike
//
//  Created by Andre on 22.04.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation


enum ArgumentSize : UInt8
{
    case Byte = 0x81	// 1 byte
    case Short = 0x82	// 2 bytes
    case Int = 0x83		// 4 bytes
    case String = 0x84	// null-terminated string
}

public enum ReplyType : UInt8
{
    case DirectReply = 0x02
    case SystemReply = 0x03
    case DirectReplyError = 0x04
    case SystemReplyError = 0x05
}

enum Opcode : UInt16
{
    case ProgramStart = 0x03
    case ProgramStop = 0x02
    
    case UIRead_GetFirmware = 0x810a
    case UIRead_GetVBatt    = 0x8101
    case UIRead_GetLBatt    = 0x8112
    
    case UIWrite_LED = 0x821b
    
    case UIButton_Pressed = 0x8309
    
    case UIDraw_Update = 0x8400
    case UIDraw_Clean = 0x8401
    case UIDraw_Pixel = 0x8402
    case UIDraw_Line = 0x8403
    case UIDraw_Circle = 0x8404
    case UIDraw_Text = 0x8405
    case UIDraw_FillRect = 0x8409
    case UIDraw_Rect = 0x840a
    case UIDraw_InverseRect = 0x8410
    case UIDraw_SelectFont = 0x8411
    case UIDraw_Topline = 0x8412
    case UIDraw_FillWindow = 0x8413
    case UIDraw_DotLine = 0x8415
    case UIDraw_FillCircle = 0x8418
    case UIDraw_BmpFile = 0x841c
    
    case Sound_Break = 0x9400
    case Sound_Tone = 0x9401
    case Sound_Play = 0x9402
    case Sound_Repeat = 0x9403
    case Sound_Service = 0x9404
    case Sound_Ready = 0x96
    
    case InputDevice_GetTypeMode = 0x9905
    case InputDevice_GetDeviceName = 0x9915
    case InputDevice_GetModeName = 0x9916
    case InputDevice_ReadyPct = 0x991b
    case InputDevice_ReadyRaw = 0x991c
    case InputDevice_ReadySI = 0x991d
    case InputDevice_ClearAll = 0x990a
    case InputDevice_ClearChanges = 0x991a
    
    case InputRead = 0x9a
    case InputReadExt = 0x9e
    case InputReadSI = 0x9d
    
    case OutputSetType = 0xa1
    case OutputReset = 0xa2
    case OutputStop = 0xa3
    case OutputPower = 0xa4
    case OutputSpeed = 0xa5
    case OutputStart = 0xa6
    case OutputPolarity = 0xa7
    case OutputReady = 0xaa
    case OutputStepPower = 0xac
    case OutputTimePower = 0xad
    case OutputStepSpeed = 0xae
    case OutputTimeSpeed = 0xaf
    case OutputStepSync = 0xb0
    case OutputTimeSync = 0xb1
    case OutputClearCount = 0xb2
    case OutputGetCount = 0xb3
    
    case File_LoadImage = 0xC008
    
    case TimerWait = 0x85
    
    case Tst = 0xff
}

enum SystemOpcode : UInt8
{
    case BeginDownload = 0x92
    case ContinueDownload = 0x93
    case CloseFileHandle = 0x98
    case CreateDirectory = 0x9b
    case DeleteFile = 0x9c
}

enum SystemReplyStatus : UInt8
{
    case Success = 0x00
    case UnknownHandle
    case HandleNotReady
    case CorruptFile
    case NoHandlesAvailable
    case NoPermission
    case IllegalPath
    case FileExists
    case EndOfFile
    case SizeError
    case UnknownError
    case IllegalFilename
    case IllegalConnection
}

// The type of command being sent to the brick
public enum CommandType : UInt8
{
    // Direct command with a reply expected
    case DirectReply = 0x00

    // Direct command with no reply
    case DirectNoReply = 0x80
    
    // System command with a reply expected
    case SystemReply = 0x01
    
    // System command with no reply
    case SystemNoReply = 0x81
}

// Format for sensor data.
enum Format : UInt8
{
    // Percentage
    case Percent = 0x10
    
    // Raw
    case Raw = 0x11
    
    /// International System of Units
    case SI = 0x12
}

// Polarity/direction to turn the motor
enum Polarity : Int
{
    // Turn backward
    case Backward = -1

    // Turn in the opposite direction
    case Opposite = 0

    // Turn forward
    case Forward = 1
}

/// Ports which can receive input data
public enum InputPort : UInt8
{
    /// Port 1
    case One = 0x00

    /// Port 2
    case Two = 0x01

    /// Port 3
    case Three = 0x02

    /// Port 4
    case Four = 0x03
    
    /// Port A
    case A	= 0x10

    /// Port B
    case B	= 0x11

    /// Port C
    case C	= 0x12
    
    /// Port D
    case D	= 0x13
    
    /// makes it possible to loop over this enum as swift provides no functionality for this yet
    static let allValues = [One, Two, Three, Four, A, B, C, D]
}


// Ports which can send output
public struct OutputPort : OptionSetType {
    public let rawValue: UInt8
    
    public init(rawValue:UInt8){ self.rawValue = rawValue}
    
    /// Port A
    public static let A = OutputPort(rawValue: 0x01)

    /// Port B
    static let B = OutputPort(rawValue: 0x02)

 
    /// Port C
    static let C = OutputPort(rawValue: 0x04)


    /// Port D
    static let D = OutputPort(rawValue: 0x08)

    /// Ports A,B,C and D simultaneously
    static let All = OutputPort(rawValue: 0x0f)
}

/// List of devices which can be recognized as input or output devices
public enum DeviceType : UInt8
{
    // 2 motors

    /// Large motor
    case LMotor = 7
    
    /// Medium motor
    case MMotor = 8
    
    // Ev3 devices

    /// EV3 Touch sensor
    case Touch = 16
 
    /// EV3 Color sensor
    case Color = 29

    /// EV3 Ultrasonic sensor
    case Ultrasonic = 30

    /// EV3 Gyroscope sensor
    case Gyroscope = 32
    
    /// EV3 IR sensor
    case Infrared = 33
    
    // other

    /// Sensor is initializing
    case Initializing = 0x7d

    /// Port is empty
    case Empty = 0x7e

    /// Sensor is plugged into a motor port, or vice-versa
    case WrongPort = 0x7f
    
    /// Unknown sensor/status
    case Unknown = 0xff
}


/// Buttons on the face of the EV3 brick
public enum BrickButton: UInt8
{
    /// No button
    case None = 0

    /// Up button
    case Up = 1

    /// Enter button
    case Enter = 2

    /// Down button
    case Down = 3
    
    /// Right button
    case Right = 4

    /// Left button
    case Left = 5

    /// Back button
    case Back = 6

    /// Any button
    case Any = 7
}

/// Pattern to light up the EV3 brick's LED
public enum LedPattern : UInt8
{
    /// LED off
    case Black = 0
    
    /// Solid green
    case Green = 1

    /// Solid red
    case Red = 2

    /// Solid orange
    case Orange = 3
    
    /// Flashing green
    case GreenFlash = 4

    /// Flashing red
    case RedFlash = 5
    
    /// Flashing orange
    case OrangeFlash = 6

    /// Pulsing green
    case GreenPulse = 7

    /// Pulsing red
    case RedPulse = 8

    /// Pulsing orange
    case OrangePulse = 9
}

/// NXT and EV3 Touch Sensor mode
public enum TouchMode : UInt8
{
    /// On when pressed, off when released
    case Touch = 0

    /// Running counter of number of presses
    case Bumps = 1
}

/// NXT Light Sensor mode
public enum NxtLightMode : UInt8
{
    /// Amount of reflected light
    case Reflect = 0

    /// Amoutn of ambient light
    case Ambient = 1
}

/// NXT Sound Sensor mode
public enum NxtSoundMode : UInt8
{
    /// Decibels
    case Decibels = 0
    
    /// Adjusted Decibels
    case AdjustedDecibels = 1
}

/// NXT Ultrasonic Sensor mode
public enum NxtUltrasonicMode : UInt8
{
    /// Values in centimeter units
    case Centimeters = 0

    /// Values in inch units
    case Inches = 1
}

/// NXT Temperature Sensor mode
public enum NxtTemperatureMode : UInt8
{
    /// Values in Celsius units
    case Celsius = 0
    
    /// Values in Fahrenheit units
    case Fahrenheit = 1
}

/// Motor mode
public enum MotorMode : UInt8
{

    /// Values in degrees
    case Degrees = 0
    
    /// Values in rotations
    case Rotations = 1

    /// Values in percentage
    case Percent = 2
}


/// EV3 Color Sensor mode
public enum ColorMode : UInt8
{
    /// Reflected color
    case Reflective = 0

    /// Ambient color
    case Ambient = 1

    /// Specific color
    case Color = 2
    
    /// Reflected color raw value
    case ReflectiveRaw = 3

    /// Reflected color RGB value
    case ReflectiveRgb = 4

    /// Calibration
    case Calibration = 5 // TODO: ??
}


/// EV3 Ultrasonic Sensor mode
public enum UltrasonicMode : UInt8
{
    /// Values in centimeter units
    case Centimeters = 0

    /// Values in inch units
    case Inches = 1

    /// Listen mode
    case Listen = 2
    
    /// Unknown
    case SiCentimeters = 3

    /// Unknown
    case SiInches = 4
    
    /// Unknown
    case DcCentimeters = 5	// TODO: DC?

    /// Unknown
    case DcInches = 6		// TODO: DC?
}

/// EV3 Gyroscope Sensor mode
public enum GyroscopeMode : UInt8
{
    /// Angle
    case Angle = 0

    /// Rate of movement
    case Rate = 1

    /// Unknown
    case Fas = 2		// TOOD: ??

    /// Unknown
    case GandA = 3	// TODO: ??

    /// Calibrate
    case Calibrate = 4
}

/// EV3 Infrared Sensor mode
public enum InfraredMode : UInt8
{

    /// Proximity
    case Proximity = 0

    /// Seek
    case Seek = 1

    /// EV3 remote control
    case Remote = 2

    /// Unknown
    case RemoteA = 3	// TODO: ??

    /// Unknown
    case SAlt = 4		// TODO: ??

    ///  Calibrate
    case Calibrate = 5
}

/// Values returned by the color sensor
public enum ColorSensorColor
{
    /// Transparent
    case Transparent

    /// Black
    case Black
    
    /// Blue
    case Blue

    /// Green
    case Green

    /// Yellow
    case Yellow

    /// Red
    case Red
    
    /// White
    case White

    /// Brown
    case Brown
}


