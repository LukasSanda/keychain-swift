import XCTest
@testable import KeychainSwift

class KeychainSwiftTests: XCTestCase {
  
  var obj: KeychainSwift!
  
  override func setUp() {
    super.setUp()
    
    obj = KeychainSwift()
    try? obj.clear()
    obj.lastQueryParameters = nil
  }

  // MARK: - Set text
  // -----------------------

  func testSet() throws {
    try obj.set("hello :)", forKey: "key 1")
    XCTAssertEqual("hello :)", try obj.get("key 1")!)
  }
  
  func testSet_usesAccessibleWhenUnlockedByDefault() throws {
    try obj.set("hello :)", forKey: "key 1")
    
    let accessValue = obj.lastQueryParameters?[KeychainSwiftConstants.accessible] as? String
    XCTAssertEqual(KeychainSwiftAccessOptions.accessibleWhenUnlocked.value, accessValue!)
  }
  
  func testSetWithAccessOption() throws {
    try obj.set("hello :)", forKey: "key 1", withAccess: .accessibleAfterFirstUnlock)
    let accessValue = obj.lastQueryParameters?[KeychainSwiftConstants.accessible] as? String
    XCTAssertEqual(KeychainSwiftAccessOptions.accessibleAfterFirstUnlock.value, accessValue!)
  }
  
  // MARK: - Set data
  // -----------------------
  
  func testSetData() throws {
    let data = "hello world".data(using: String.Encoding.utf8)!
    
    try obj.set(data, forKey: "key 123")
    
    let dataFromKeychain = try obj.getData("key 123")!
    let textFromKeychain = String(data: dataFromKeychain, encoding:String.Encoding.utf8)!
    XCTAssertEqual("hello world", textFromKeychain)
  }
  
  func testSetData_usesAccessibleWhenUnlockedByDefault() throws {
    let data = "hello world".data(using: String.Encoding.utf8)!
    
    try obj.set(data, forKey: "key 123")
    
    let accessValue = obj.lastQueryParameters?[KeychainSwiftConstants.accessible] as? String
    XCTAssertEqual(KeychainSwiftAccessOptions.accessibleWhenUnlocked.value, accessValue!)
  }

  // MARK: - Set bool
  // -----------------------

  func testSetBool() throws {
    try obj.set(true, forKey: "key bool")
    XCTAssertTrue(try obj.getBool("key bool")!)
    try obj.set(false, forKey: "key bool")
    XCTAssertFalse(try obj.getBool("key bool")!)
  }

  func testSetBool_usesAccessibleWhenUnlockedByDefault() throws {
    try obj.set(false, forKey: "key bool")
    let accessValue = obj.lastQueryParameters?[KeychainSwiftConstants.accessible] as? String
    XCTAssertEqual(KeychainSwiftAccessOptions.accessibleWhenUnlocked.value, accessValue!)
  }

  // MARK: - Get
  // -----------------------

  func testGet_returnNilWhenValueNotSet() throws {
    XCTAssert(try obj.get("key 1") == nil)
  }

  // MARK: - Get bool
  // -----------------------

  func testGetBool_returnNilWhenValueNotSet() throws {
    XCTAssert(try obj.getBool("some bool key") == nil)
  }

  // MARK: - Delete
  // -----------------------

  func testDelete() throws {
    try obj.set("hello :)", forKey: "key 1")
    try obj.delete("key 1")
    
    XCTAssert(try obj.get("key 1") == nil)
  }

  func testDelete_deleteOnSingleKey() throws {
    try obj.set("hello :)", forKey: "key 1")
    try obj.set("hello two", forKey: "key 2")

    try obj.delete("key 1")
    
    XCTAssertEqual("hello two", try obj.get("key 2")!)
  }
}
