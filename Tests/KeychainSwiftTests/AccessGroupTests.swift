import XCTest
@testable import KeychainSwift

class AccessGroupTests: XCTestCase {
  
  var obj: TestableKeychainSwift!
  
  override func setUp() {
    super.setUp()
    
    obj = TestableKeychainSwift()
    try? obj.clear()
    obj.lastQueryParameters = nil
    obj.accessGroup = nil
  }
  
  // MARK: - Add access group
  
  func testAddAccessGroup() {
    var result: [String: Any] = [
      "one": "two"
    ]
    
    obj.accessGroup = "123.my.test.group"
    obj.addAccessGroupWhenPresent(&result)
    
    XCTAssertEqual(2, result.count)
    XCTAssertEqual("two", result["one"] as! String)
    XCTAssertEqual("123.my.test.group", result["agrp"] as! String)
  }
  
  func testAddAccessGroup_nil() {
    var result: [String: Any] = [
      "one": "two"
    ]
    
    obj.addAccessGroupWhenPresent(&result)
    
    XCTAssertEqual(1, result.count)
    XCTAssertEqual("two", result["one"] as! String)
  }
  
  func testSet() {
    obj.accessGroup = "123.my.test.group"
    try? obj.set("hello :)", forKey: "key 1")
    XCTAssertEqual("123.my.test.group", obj.lastQueryParameters?["agrp"] as! String)
  }
  
  func testGet() {
    obj.accessGroup = "123.my.test.group"
    _ = try? obj.get("key 1")
    XCTAssertEqual("123.my.test.group", obj.lastQueryParameters?["agrp"] as! String)
  }
  
  func testDelete() {
    obj.accessGroup = "123.my.test.group"
    _ = try? obj.delete("key 1")
    XCTAssertEqual("123.my.test.group", obj.lastQueryParameters?["agrp"] as! String)
  }
  
  func testClear() {
    obj.accessGroup = "123.my.test.group"
    try? obj.clear()
    XCTAssertEqual("123.my.test.group", obj.lastQueryParameters?["agrp"] as! String)
  }
}
