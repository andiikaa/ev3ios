//
//  Ev3ResponseManager.swift
//  EV3BTSpike
//
//  Created by Andre on 26.04.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

class Ev3ResponseManager {
    private static var nextSequence: UInt16 = 0x0001
    private static var responses = [UInt16 : Ev3Response]()
    
    private static func getSequenceNumber() -> UInt16  {
        if nextSequence == UInt16.max{
            nextSequence = nextSequence &+ 1 //unsigned overflow
        }
        nextSequence += 1
        return nextSequence;
    }
    
    static func createResponse() -> Ev3Response {
        let sequence = getSequenceNumber();
        let r = Ev3Response(sequence: sequence);
        responses.updateValue(r, forKey: sequence)
        return r;
    }
    
    static func handleResponse(report: [UInt8]){
        if report.count < 3 {
            return
        }
        
        //let sequence: UInt16 = (ushort) (report[0] | (report[1] << 8));
        
        //TODO seems not that the seqence number is stored le
        let sequence: UInt16 = UInt16(report[1]) << 8 | UInt16(report[0])
        
        if sequence < 1 {
            return
        }
        
        print("received reply for sequence number \(sequence)")
        
        let replyType: UInt8 = report[2]
        let rt = responses[sequence]
        
        if rt == nil {
            print("no item for sequence number \(sequence)")
            return
        }
        
        let r = rt!       
        
        
        if let rt = ReplyType(rawValue: replyType){
            r.replyType = rt
        }
        
        if(r.replyType != nil && ( r.replyType == .DirectReply || r.replyType == .DirectReplyError)) {
            let tmp = NSData(bytes: report, length: report.count)
            r.data = tmp.subdataWithRange(NSRange(location: 3, length: report.count - 3))
        }
        else if (r.replyType != nil && (r.replyType == .SystemReply || r.replyType == .SystemReplyError )){
            if let oc = SystemOpcode(rawValue: report[3]){
                r.systemCommand = oc
            }
            
            if let rs = SystemReplyStatus(rawValue: report[4]){
                r.systemReplyStatus = rs
            }
            
            let tmp = NSData(bytes: report, length: report.count)
            r.data = tmp.subdataWithRange(NSRange(location: 5, length: report.count - 5))
    
        }
        
        // informes the callback that a response for the command was received
        r.responseReceivedCallback?()        
    }
}


