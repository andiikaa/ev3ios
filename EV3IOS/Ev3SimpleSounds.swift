//
//  Ev3SimpleSounds.swift
//  EV3BTSpike
//
//  Created by Andre on 17.05.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

public class Ev3SimpleSounds {


    public static func appendSimpleStartupSound(command: Ev3Command, volume: UInt8){
        command.playTone(volume: volume, frequency: 262, duration: 150)
        command.soundReady()
        command.playTone(volume: volume, frequency: 330, duration: 150)
        command.soundReady()
        command.playTone(volume: volume, frequency: 392, duration: 150)
        command.soundReady()
        command.playTone(volume: volume, frequency: 523, duration: 300)
    }
}
