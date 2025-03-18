//
//  KeychainError.swift
//  KeychainSwift
//
//  Created by Lennard Sprong on 20/02/2025.
//

import Foundation
import Security

public struct KeychainError : RawRepresentable, CustomStringConvertible {
    public init(rawValue: OSStatus) {
        self.rawValue = rawValue
    }
    
    public init(_ code: OSStatus) {
        rawValue = code
    }
    
    /// The result code for the operation.
    public let rawValue: OSStatus
    
    /// Retrieve the localized description for this error. This uses ``/Security/SecCopyErrorMessageString(_:_:)`` internally.
    public var localizedDescription: String {
        if let message = SecCopyErrorMessageString(rawValue, nil) {
            return message as String
        }
        return description
    }
    
    public var description: String {
        "KeychainError(\(rawValue))"
    }
}

extension KeychainError : CustomNSError {
    public static var errorDomain: String { NSOSStatusErrorDomain }
}

extension KeychainError : LocalizedError {
    public var errorDescription: String? { localizedDescription }
}
