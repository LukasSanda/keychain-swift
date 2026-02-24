//
//  AllKeysTests.swift
//  KeychainSwiftTests
//
//  Created by Lucas Paim on 02/01/20.
//  Copyright © 2020 Evgenii Neumerzhitckii. All rights reserved.
//

import XCTest
@testable import KeychainSwift


class AllKeysTests: XCTestCase {
  
  var obj: TestableKeychainSwift!
  
  override func setUp() {
    super.setUp()
    
    obj = TestableKeychainSwift()
    try? obj.clear()
  }
  
  // MARK: - allKeys
  func testAddSynchronizableGroup_addItemsFalse() throws {
    let items: [String] = [
      "one", "two"
    ]

    for (index, key) in items.enumerated() {
      try obj.set("\(index)", forKey: key)
    }

    // On macOS the keychain is shared system-wide, so only verify our items are present
    XCTAssertTrue(obj.allKeys.contains("one"))
    XCTAssertTrue(obj.allKeys.contains("two"))

    // clear() cannot bulk-delete foreign app items on macOS; use delete() for specific keys
    try obj.delete("one")
    try obj.delete("two")

    XCTAssertFalse(obj.allKeys.contains("one"))
    XCTAssertFalse(obj.allKeys.contains("two"))
  }
}
