import XCTest
@testable import KeychainSwift

class SynchronizableTests: XCTestCase {
  
  var obj: TestableKeychainSwift!
  
  override func setUp() {
    super.setUp()
    
    obj = TestableKeychainSwift()
    try? obj.clear()
    obj.lastQueryParameters = nil
    obj.synchronizable = false
  }
  
  // MARK: - addSynchronizableIfRequired
  
  func testAddSynchronizableGroup_addItemsFalse() {
    var result: [String: Any] = [
      "one": "two"
    ]
    
    obj.synchronizable = true
    obj.addSynchronizableIfRequired(&result, addingItems: false)
    
    XCTAssertEqual(2, result.count)
    XCTAssertEqual("two", result["one"] as? String)
    XCTAssertEqual(kSecAttrSynchronizableAny as String, result["sync"] as? String)
  }
  
  func testAddSynchronizableGroup_addItemsTrue() {
      var result: [String: Any] = [
      "one": "two"
    ]
    
    obj.synchronizable = true
    obj.addSynchronizableIfRequired(&result, addingItems: true)
    
    XCTAssertEqual(2, result.count)
    XCTAssertEqual("two", result["one"] as? String)
    XCTAssertEqual(true, result["sync"] as? Bool)
  }
  
  func testAddSynchronizableGroup_nil() {
    var result: [String: Any] = [
      "one": "two"
    ]
    
    obj.addSynchronizableIfRequired(&result, addingItems: false)
    
    XCTAssertEqual(1, result.count)
    XCTAssertEqual("two", result["one"] as? String)
  }
  
  // MARK: - Set
  
  func testSet() {
    obj.synchronizable = true
    try? obj.set("hello :)", forKey: "key 1")
    XCTAssertEqual(true, obj.lastQueryParameters?["sync"] as? Bool)
  }
  
  func testSet_doNotSetSynchronizable() {
    try? obj.set("hello :)", forKey: "key 1")
    XCTAssertNil(obj.lastQueryParameters?["sync"])
  }
  
  // MARK: - Get
  
  func testGet() {
    obj.synchronizable = true
    _ = try? obj.get("key 1")
    XCTAssertEqual(kSecAttrSynchronizableAny as String, obj.lastQueryParameters?["sync"] as? String)
  }
  
  func testGet_doNotSetSynchronizable() {
    _ = try? obj.get("key 1")
    XCTAssertNil(obj.lastQueryParameters?["sync"])
  }
  
  // MARK: - Delete

  func testDelete() {
    obj.synchronizable = true
    _ = try? obj.delete("key 1")
    XCTAssertEqual(kSecAttrSynchronizableAny as String, obj.lastQueryParameters?["sync"] as? String)
  }
  
  func testDelete_doNotSetSynchronizable() {
    _ = try? obj.delete("key 1")
    XCTAssertNil(obj.lastQueryParameters?["sync"])
  }
  
  // MARK: - Clear
  
  func testClear() {
    obj.synchronizable = true
    try? obj.clear()
    XCTAssertEqual(kSecAttrSynchronizableAny as String, obj.lastQueryParameters?["sync"] as? String)
  }
  
  func testClear_doNotSetSynchronizable() {
    try? obj.clear()
    XCTAssertNil(obj.lastQueryParameters?["sync"])
  }
}
