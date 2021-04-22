# EV3 iOS SDK

![build status](https://github.com/andiikaa/ev3ios/actions/workflows/swift.yml/badge.svg?branch=master)

The EV3 iOS SDK makes it possible to send commands from an iOS device to an Lego Ev3 robot. 
At the moment only bluetooth connections are supported, but it should be also possible to 
extend the SDK to a wifi connection feature. The SDK uses the offical lego connection protocol, so there is no need to flash a new firmare such as [leJOS](http://www.lejos.org/). We tested this implementation with the original firmware from 1.06h to 1.08h.

This SDK is a port of the more popular [BrianPeek/legoev3](https://github.com/BrianPeek/legoev3) to Apples swift language. 

## First Steps

- Make sure, iOS compatibility is enabled on the ev3

- Add this SDK as Swift Package to your Xcode project, as described [here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

- Add the Ev3 Protocol to the 'info.plist'
    - add row (if 'Supported external accessory protocols' not exists)
    - choose 'Supported external accessory protocols'
    - Set value for Item # to 'COM.LEGO.MINDSTORMS.EV3'

## Connect with EV3

The following example, shows how to connect, to a EV3 brick. 
The 'Ev3Brick' just needs a 'Ev3Connection', which needs a 'EAAccessory'.
To optain a 'EAAccessory' you can access the 'EAAccessoryManager' and loop over all connected devices. Attention: The device must be already connected to the iOS device via bluetooth, otherwise it is not listed in the 'EAAccessoryManager'. The only possible official solution supported by Apple, to force the iOS device to connect to the bluetooth device, is to show a dialog, within you can select bluetooth devices, which are in range.


Register to notifications if a bt device has connected or disconnected. Connect or disconnect is handled in 
'accessoryConnected' and 'accessoryDisconnected' (further down).
```swift
NotificationCenter.default.addObserver(self, selector: #selector(accessoryConnected), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(accessoryDisconnected), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
EAAccessoryManager.shared().registerForLocalNotifications()
```


Shows the connect dialog, to force the ios device to connect to a bt device, which is in range.
So the user does not have to go to the bluetooth settings.
```swift
EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil) { error in
    // handle error
}
```

In case a accessory has connected to the iOS device.
```swift
@objc private func accessoryConnected(notification: NSNotification) {
    print("EAController::accessoryConnected")

    let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory

    // check if the device is a ev3
    if !Ev3Connection.supportsEv3Protocol(accessory: connectedAccessory) {
        return
    }

    connect(accessory: connectedAccessory)
}
``` 

In case a accessory has disconnected from the iOS device.
```swift
@objc private func accessoryDisconnected(notification: NSNotification) {
    print("EAController::accessoryDisconnected")
    let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory

    // check if the device is a ev3
    if !Ev3Connection.supportsEv3Protocol(accessory: connectedAccessory) {
        return
    }

    disconnect()
}
``` 

In case, the EV3 is already connected to the iOS device just loop over the connected 'EAAccessory'
```swift
private func getEv3Accessory() -> EAAccessory? {
    let man = EAAccessoryManager.shared()
    let connected = man.connectedAccessories

    for tmpAccessory in connected{
        if Ev3Connection.supportsEv3Protocol(accessory: tmpAccessory){
            return tmpAccessory
        }
    }
    return nil
}
```

Once you have optained the EAAcessory for the EV3 you can create a EV3Connection and start communicating with the EV3 
```swift
private func connect(accessory: EAAccessory){
    connection = Ev3Connection(accessory: accessory)
    brick = Ev3Brick(connection: connection!)
    connection?.open()
}
``` 


## Direct, System, and Batch Commands

The commands can devide in three categories:

* DirectCommands
* BatchCommands
* SystemCommands

### DirectCommands

These commands are "one off" commands and are executed immediately. These are greate if you only 
need to do a single operation at a time, but can be very slow when calling a series of them in 
very quick succession. There are a lot of other existing direct commands. You can just look in the code. A few are describted further down.

#### Motors Examples

Following command will turn the motor on the ports A and B with the speed of 50 backwards.

```swift
ev3Brick.directCommand.turnMotorAtSpeed([.A, .B], -50)
```

This command will turn the motor A with the speed of 100 forwards for 1000 milliseconds. The parameter brake let 
you choose, if you want to apply the brake at the end of the movement.

```swift
ev3Brick.directCommand.turnMotorAtSpeedForTime(.A, speed: 100, milliseconds: 1000, brake: false)
```

#### Get Firmaware/ Battery Status

It is also possible to receive some informations from the Ev3 e.g. Sensor Data (not fully implemented), firmware version, or battery status. The data is returned within a Closure.

```swift
brick?.directCommand.getBatteryLevel({ (level: UInt8?) in
    let lev = level == nil ? "--" : String(level!)
    self.batEv3Text.text = lev + " %"
})
```

```swift
brick?.directCommand.getFirmwareVersion({ (fmw: String?) in
    if (fmw != nil) {
        self.infoEV3Text.text = "Firmware: \(fmw!)"
    }
})
```


## BatchCommands

These commands are queued up until the queue of a command is send to the brick.
You can imagine such a bacth command as a program, which is build with the SDK, 
then send to the brick and then executed.

#### Driving and Sound Example

Heres a example, how batch commands can be build and send to the brick (you can also have a look 
in the class EV3DirectCommand)

The following command will play the sound file "Connect", set the motor speed for ports A and B 
to -50 and starts them immediately.

```swift
let c = Ev3Command(commandType: .DirectNoReply)
c.playSound(100, filename: "../prjs/achten/Connect")
c.turnMotorAtPower([.A, .B], power: -50)
c.startMotor([.A, .B])
brick.sendCommand(c)
```

#### Receive Data from EV3 Example

The following example show a deeper look in the direct command 'getFirmwareVersion'. You see that you have to take care of the response size and the offset, where the data for the firmware begins. This is more important, if you have commands, which return more data (e.g. port values).

If data is read from the EASession.inputStream, it is stored in the Ev3ResponseManager. Since all commands have a sequence number, responses can be assigned to their original command, with the help of this sequence number. Each command has a response and you can assign a callback to each response, which will inform you about an incoming response. The response only holds the raw data. Converting this data to actual values (e.g. String) is up to you (except for already implemented direct commands, e.g. getBaterryLevel).

```swift
public func getFirmwareVersion(receivedFirmware: (String?) -> Void){
    let c = Ev3Command(commandType: .DirectReply, globalSize: 0x10, localSize: 0)

    // length and index in response
    c.getFirwmareVersion(0x10, index: 0)
    c.response?.responseReceivedCallback = {
    if(c.response?.data == nil){
        receivedFirmware(nil)
    }
    else if let str = String(data: c.response!.data!, encoding: NSUTF8StringEncoding) {
        receivedFirmware(str)
    } else {
        receivedFirmware(nil)
    }}

    brick.sendCommand(c)
}
```

## SystemCommands

System commands are also "one off" but cannot be batched. These commands are for uploading files and other 
system-level functions.

At the moment there are no system commands implemented yet.

## Problems

### Bluetooth Disconnections

We observed bluetooth disconnects, if a large direct command (e.g. polling for sensor values/button states), or many commands in a row, within a short period are send. Sometimes the Ev3 has to be restarted, in order to connect again via bluetooth. Since nobody seems to have this problem on android, we think this is an iOS specific error on the Ev3. The official Lego app also seems not to have this issue, unfortunately there is no source for this app. The main problem seems to be, that the statement

```swift
EASession.outputStream.hasSpaceAvailable
``` 
is always returning true. So we can send a lot of data, but the Ev3 is not ready to handle that. If you have any solution for this problem, please leave a note.

Our workaround at the moment is to buffer the commands, which are send to the brick. After one command was send to the EASession.outputStream we wait a given time (at the moment 125ms - messured empirical) till a follwing command can be send to the Ev3 brick. If there are a lot of commands within a short period of time, we throw away the oldest ones from the command buffer. Please note, that it is possible, that if you send a large command, the waiting time of 125ms is maybe not enough.

If you have any issues with the current settings or want to improve the connection for your needs you can play around with the following two values in the 'Ev3Connection'.
```swift
/// max command buffer size
let maxBufferSize = 2

/// sleeping time after each command was send to ev3
let connSleepTime = 0.125
```

## Additional links

[Android Project](https://github.com/BrianPeek/legoev3)

[Documentation of the Ev3 communication protocol](https://github.com/mindboards/ev3sources/blob/master/lms2012/c_com/source/c_com.h)

[Bytecodes for Ev3 (for building direct commands)](https://github.com/mindboards/ev3sources/blob/master/lms2012/lms2012/source/bytecodes.h)

[Lego Downloads e.g. Firmware Developer Guide (very useful)](http://www.lego.com/de-de/mindstorms/downloads)
