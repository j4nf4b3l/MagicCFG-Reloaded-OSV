//
//  YBLoggerConfiguration.swift
//  SimpleLogger
//
//  Created by Yogesh Bhople on 23/07/17.
//  Copyright © 2017 Yogesh Bhople. All rights reserved.
//

import Foundation

extension YBLoggerConfiguration {
    func allowToPrint() -> Bool {
        var allowed = false
        
        if let logLevel = self as? YBLogger {
            #if DEBUG
                allowed = true
            #elseif RELEASE
                switch logLevel {
                case .DEBUG:
                    allowed = false
                case .INFO:
                    allowed = false
                case .ERROR:
                    allowed = true
                case .EXCEPTION:
                    allowed = true
                case .WARNING:
                    allowed = false
                }
                
            #endif
        }
        return allowed
    }
    func allowToLogWrite() -> Bool {
        var allowed = true
        
        if let logLevel = self as? YBLogger {
            #if DEBUG
                allowed = true
            #elseif RELEASE
                switch logLevel {
                case .DEBUG:
                    allowed = true
                case .INFO:
                    allowed = true
                case .ERROR:
                    allowed = true
                case .EXCEPTION:
                    allowed = true
                case .WARNING:
                    allowed = true
                }
                
            #endif
        }
        return allowed
    }
    
}
