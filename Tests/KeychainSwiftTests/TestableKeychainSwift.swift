//
//  TestableKeychainSwift.swift
//  KeychainSwift
//
//  Created by Lennard Sprong on 21/02/2025.
//

@testable import KeychainSwift

class TestableKeychainSwift : KeychainSwift, @unchecked Sendable {
    var _accessGroup: String? = nil
    override var accessGroup: String? {
        get { _accessGroup }
        set { _accessGroup = newValue }
    }
    
    var _synchronizable: Bool = false
    override var synchronizable: Bool {
        get { _synchronizable }
        set { _synchronizable = newValue }
    }
    
    init(keyPrefix: String = "") {
        super.init(keyPrefix: keyPrefix)
    }
}
