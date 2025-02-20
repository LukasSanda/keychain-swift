//
//  KeychainError.swift
//  KeychainSwift
//
//  Created by Lennard Sprong on 20/02/2025.
//

import Foundation
import Security

public struct KeychainError : CustomNSError {
    public init(_ code: OSStatus) {
        errorCode = code
    }
    
    public static var errorDomain: String { NSOSStatusErrorDomain }
    
    /// The result code for the operation.
    public let errorCode: OSStatus
    
    /// Retrieve the localized description for this error. This uses ``/Security/SecCopyErrorMessageString(_:_:)`` internally.
    public var localizedDescription: String {
        if let message = SecCopyErrorMessageString(errorCode, nil) {
            return message as String
        }
        return "KeychainError \(errorCode)"
    }
}
