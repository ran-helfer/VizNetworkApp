//
//  Logger.swift
//  NetworkApp
//
//  Created by Ran Helfer on 18/07/2021.
//  Copyright © 2021 . All rights reserved.
//

import Foundation

/**********************/
/* Public Log Level   */
/**********************/

public enum LogLevel: String {
    case mute = "MUTE"
    case verbose = "VERBOSE"
    case info = "INFO"
    case warn = "WARNING"
    case error = "ERROR"
}

/**********************/
/*    Public API      */
/**********************/

func logVerbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(.verbose, message, function: function, file: file, line: line)
}

func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(.info, message, function: function, file: file, line: line)
}

func logWarn(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(.warn, message, function: function, file: file, line: line)
}

func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.log(.error, message, function: function, file: file, line: line)
}

/*************************************************/
/*              Hidden interface                 */
/*************************************************/

class Logger {
    fileprivate static let shared = Logger()
    
    var logLevel: LogLevel = .mute
    let levels: [LogLevel] = [.verbose, .info, .warn, .error]
    
    static func setLogLevel(_ level: LogLevel) {
        Logger.shared.logLevel = level
    }
    
    fileprivate func log(_ level: LogLevel,
                         _ message: String? = nil,
                         function: String? = nil ,
                         file: String? = nil,
                         line: Int? = nil) {
        
        var printOut = "\(level.rawValue) "
        
        if let file = file {
            let fileString = URL(string: file)?.deletingPathExtension().lastPathComponent
            printOut = printOut + "(\(fileString ?? "unknown file") "
        }
        
        if let function = function {
            printOut = printOut + function + " "
        }
        
        if let line = line {
            printOut = printOut + " \(line): "
        }
        
        if let message = message {
            printOut = printOut + message
        }
        print(printOut)
    }
}
