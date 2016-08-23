//
//  ReportListener.swift
//  EV3BTSpike
//
//  Created by Andre on 09.05.16.
//  Copyright © 2016 Andre. All rights reserved.
//

import Foundation

protocol Ev3ReportDelegate {
    
    func reportReceived(report: [UInt8])
}
