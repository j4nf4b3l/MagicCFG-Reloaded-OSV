//
//  YBFileLogger.swift
//  SimpleLogger
//
//  Created by Yogesh Bhople on 23/07/17.
//  Copyright © 2017 Yogesh Bhople. All rights reserved.
//

import Foundation

struct YBFileLogger: TextOutputStream {
    
    private static var documentDirectoryPath:String {
        get {
            return NSHomeDirectory() + "/Documents/"
        }
    }
    
    private static var logFileName:String{
        get{
            return Date().currentDate+"MagicCFG.log"
        }
    }
    
    private static var logFileFullPath:String{
        get{
            return documentDirectoryPath+logFileName
        }
    }
    
    static var `default`: YBFileLogger {
        struct Singleton {
            static let instance = YBFileLogger()
        }
        return Singleton.instance
    }
    
    private init() {
        
    }
    
    lazy var fileHandle: FileHandle? = {
        if !FileManager.default.fileExists(atPath: YBFileLogger.logFileFullPath) {
            FileManager.default.createFile(atPath: YBFileLogger.logFileFullPath, contents: nil, attributes: nil)
        }
        let fileHandle = FileHandle(forWritingAtPath: YBFileLogger.logFileFullPath)
        return fileHandle
    }()
    
    mutating func write(_ string: String) {
        fileHandle?.seekToEndOfFile()
//        print(YBFileLogger.logFileFullPath)
        if let dataToWrite = string.data(using: String.Encoding.utf8) {
            fileHandle?.write(dataToWrite)
        }
        
    }
}

