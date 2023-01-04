// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import Foundation
import Pulse

enum DurationFormatter {
    static func string(from timeInterval: TimeInterval) -> String {
        string(from: timeInterval, isPrecise: true)
    }

    static func string(from timeInterval: TimeInterval, isPrecise: Bool) -> String {
        if timeInterval < 0.95 {
            if isPrecise {
                return String(format: "%.1fms", timeInterval * 1000)
            } else {
                return String(format: "%.0fms", timeInterval * 1000)
            }
        }
        if timeInterval < 200 {
            return String(format: "%.\(isPrecise ? "3" : "1")fs", timeInterval)
        }
        let minutes = timeInterval / 60
        if minutes < 60 {
            return String(format: "%.1fmin", minutes)
        }
        let hours = timeInterval / (60 * 60)
        return String(format: "%.1fh", hours)
    }
}

enum StatusCodeFormatter {
    static func string(for statusCode: Int32) -> String {
        string(for: Int(statusCode))
    }

    static func string(for statusCode: Int) -> String {
        switch statusCode {
        case 200: return "200 OK"
        default: return "\(statusCode) \( HTTPURLResponse.localizedString(forStatusCode: statusCode).capitalized)"
        }
    }
}

enum ErrorFormatter {
    static func shortErrorDescription(for task: NetworkTaskEntity) -> String {
        if task.errorCode != 0 {
            if task.errorDomain == URLError.errorDomain {
                return "\(task.errorCode) \(descriptionForURLErrorCode(Int(task.errorCode)))"
            } else if task.errorDomain == NetworkLogger.DecodingError.domain {
                return "Decoding Failed"
            } else {
                return "Error"
            }
        } else {
            return StatusCodeFormatter.string(for: Int(task.statusCode))
        }
    }
}

extension ByteCountFormatter {
    static func string(fromByteCount count: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: count, countStyle: .file)
    }
}
