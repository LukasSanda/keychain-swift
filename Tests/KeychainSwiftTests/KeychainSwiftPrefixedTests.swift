import XCTest
@testable import KeychainSwift

class KeychainWithPrefixTests: XCTestCase {
  
  var prefixed: KeychainSwift!
  var nonPrefixed: KeychainSwift!

  
  override func setUp() {
    super.setUp()
    
    prefixed = KeychainSwift(keyPrefix: "test_prefix_")
    nonPrefixed = KeychainSwift()
    
    try? prefixed.clear()
    try? nonPrefixed.clear()
    
    prefixed.lastQueryParameters = nil
  }
  
  func testKeyWithPrefix() throws {
    XCTAssertEqual("test_prefix_key", prefixed.keyWithPrefix("key"))
    XCTAssertEqual("key", nonPrefixed.keyWithPrefix("key"))
  }
  
  // MARK: - Set text
  // -----------------------
  
  func testSet() throws {
    let key = "key 1"
    try prefixed.set("prefixed", forKey: key)
    try nonPrefixed.set("non prefixed", forKey: key)
    
    XCTAssertEqual("prefixed", try prefixed.get(key)!)
    XCTAssertEqual("non prefixed", try nonPrefixed.get(key)!)
  }
  
  
  // MARK: - Set data
  // -----------------------
  
  func testSetData() throws {
    let key = "key 123"
    
    let dataPrefixed = "prefixed".data(using: String.Encoding.utf8)!
    let dataNonPrefixed = "non prefixed".data(using: String.Encoding.utf8)!
    
    try prefixed.set(dataPrefixed, forKey: key)
    try nonPrefixed.set(dataNonPrefixed, forKey: key)

    
    let dataFromKeychainPrefixed = try prefixed.getData(key)!
    let textFromKeychainPrefixed = String(data: dataFromKeychainPrefixed, encoding: .utf8)!
    XCTAssertEqual("prefixed", textFromKeychainPrefixed)
    
    let dataFromKeychainNonPrefixed = try nonPrefixed.getData(key)!
    let textFromKeychainNonPrefixed = String(data: dataFromKeychainNonPrefixed, encoding: .utf8)!
    XCTAssertEqual("non prefixed", textFromKeychainNonPrefixed)
  }
  
  // MARK: - Delete
  // -----------------------
  
  func testDelete() throws {
    let key = "key 1"
    try prefixed.set("prefixed", forKey: key)
    try nonPrefixed.set("non prefixed", forKey: key)
    
    try prefixed.delete(key)
    
    XCTAssert(try prefixed.get(key) == nil)
    XCTAssertFalse(try nonPrefixed.get(key) == nil) // non-prefixed still exists
  }
  
}
