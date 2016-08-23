//
//  Ev3Response.swift
//  EV3BTSpike
//
//  Created by Andre on 26.04.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

class Ev3Response {
    var replyType: ReplyType?
    var sequence: UInt16?
    
    var data: NSData?
    var systemCommand: SystemOpcode?
    var systemReplyStatus: SystemReplyStatus?
    
    var responseReceivedCallback: (() -> Void)?
    
    init(sequence: UInt16){
        self.sequence = sequence
    }
    
}