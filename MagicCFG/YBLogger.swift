//
//  YBLogger.swift
//  SimpleLogger
//
//  Created by Yogesh Bhople on 10/07/17.
//  Copyright © 2017 Yogesh Bhople. All rights reserved.
//

import Foundation

protocol YBLoggerConfiguration {
    func allowToPrint() -> Bool
    func allowToLogWrite() -> Bool
    func addTimeStamp() -> Bool
    func addFileName() -> Bool
    func addFunctionName() -> Bool
    func addLineNumber() -> Bool
}
extension YBLoggerConfiguration {
    func addTimeStamp() -> Bool {return false}
    func addFileName() -> Bool {return false}
    func addFunctionName() -> Bool {return true}
    func addLineNumber() -> Bool {return true}
}
public enum YBLogger : YBLoggerConfiguration {
    case DEBUG,INFO,ERROR,EXCEPTION,WARNING
    
fileprivate func symbolString() -> String {
        var messgeString = ""
        switch self {
        case .DEBUG:
            messgeString =  "\u{0001F539} "
        case .INFO:
            messgeString =  "\u{0001F538} "
        case .ERROR:
            messgeString =  "\u{0001F6AB} "
        case .EXCEPTION:
            messgeString =  "\u{2757}\u{FE0F} "
        case .WARNING:
            messgeString =  "\u{26A0}\u{FE0F} "
        }
        var logLevelString = "\(self)"
        
        for _ in 0 ..< (10 - logLevelString.count)  {
            logLevelString.append(" ")
        }
        messgeString = messgeString + logLevelString + "➯ "
        return messgeString
    }
    
}


public func print(_ message: Any...,logLevel:YBLogger,_ callingFunctionName: String = #function,_ lineNumber: UInt = #line,_ fileName:String = #file) {
    let messageString = message.map({"\($0)"}).joined(separator: " ")
    var fullMessageString = logLevel.symbolString()
    
    if logLevel.addTimeStamp() {
        fullMessageString = fullMessageString + Date().formattedISO8601 + " ⇨ "
    }
    if logLevel.addFileName() {
        let fileName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        fullMessageString = fullMessageString + fileName + " ⇨ "
    }
    if logLevel.addFunctionName() {
        fullMessageString = fullMessageString + callingFunctionName
        if logLevel.addLineNumber() {
            fullMessageString = fullMessageString + " : \(lineNumber)" + " ⇨ "
        } else {
            fullMessageString = fullMessageString + " ⇨ "
        }
    }
    
    fullMessageString = fullMessageString + messageString
    
    if logLevel.allowToPrint() {
        print(fullMessageString)
    }
    if logLevel.allowToLogWrite() {
        var a = YBFileLogger.default
        print(fullMessageString,to:&a)
    }
}


extension Foundation.Date {
    /* Reference : http://stackoverflow.com/questions/28016578/
     //swift-how-to-create-a-date-time-stamp-and-format-as-iso-8601-rfc-3339-utc-tim
     */
    struct Date {
        static let formatterISO8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()
        
        static let formatteryyyyMMdd: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyyMMdd"
            return formatter
        }()
    }
    var formattedISO8601: String { return Date.formatterISO8601.string(from: self) }
    var currentDate: String { return Date.formatteryyyyMMdd.string(from: self) }
}
