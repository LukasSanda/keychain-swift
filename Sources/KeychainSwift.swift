import Security
import Foundation

/**

A collection of helper functions for saving text and data in the keychain.

*/
open class KeychainSwift: @unchecked Sendable {
  
  var lastQueryParameters: [String: Any]? // Used by the unit tests

  var keyPrefix = "" // Can be useful in test.
  
  /**

  Specify an access group that will be used to access keychain items. Access groups can be used to share keychain items between applications. When access group value is nil all application access groups are being accessed. Access group name is used by all functions: set, get, delete and clear.

  */
  open var accessGroup: String? { _accessGroup }
  private let _accessGroup: String?
  
  /**
   
  Specifies whether the items can be synchronized with other devices through iCloud. Setting this property to true will
   add the item to other devices with the `set` method and obtain synchronizable items with the `get` command. Deleting synchronizable items will remove them from all devices. In order for keychain synchronization to work the user must enable "Keychain" in iCloud settings.
   
  Does not work on macOS.
   
  */
  open var synchronizable: Bool { _synchronizable }
  private let _synchronizable: Bool

  private let lock = NSLock()

  /**
  
   Instantiate a KeychainSwift object
   
  - parameter keyPrefix: a prefix that is added before the key in get/set methods. Note that `clear` method still clears everything from the Keychain.
  - parameter accessGroup: Access groups can be used to share keychain items between applications. When access group value is nil all application access groups are being accessed. Access group name is used by all functions: set, get, delete and clear.
  - parameter synchronizable: Specifies whether the items can be synchronized with other devices through iCloud. Setting this property to true will add the item to other devices with the `set` method and obtain synchronizable items with the `get` command. Deleting synchronizable items will remove them from all devices. In order for keychain synchronization to work the user must enable "Keychain" in iCloud settings. Does not work on macOS.

  */
  public init(keyPrefix: String = "", accessGroup: String? = nil, synchronizable: Bool = false) {
    self.keyPrefix = keyPrefix
    _accessGroup = accessGroup
    _synchronizable = synchronizable
  }
  
  /**
  
  Stores the text value in the keychain item under the given key.
  
  - parameter key: Key under which the text value is stored in the keychain.
  - parameter value: Text string to be written to the keychain.
  - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.

  */
  open func set(_ value: String, forKey key: String,
                  withAccess access: KeychainSwiftAccessOptions? = nil) throws {
    
    if let value = value.data(using: String.Encoding.utf8) {
      try set(value, forKey: key, withAccess: access)
    } else {
      throw KeychainError(errSecInvalidEncoding)
    }
  }

  /**
  
  Stores the data in the keychain item under the given key.
  
  - parameter key: Key under which the data is stored in the keychain.
  - parameter value: Data to be written to the keychain.
  - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
  
  */
  open func set(_ value: Data, forKey key: String,
    withAccess access: KeychainSwiftAccessOptions? = nil) throws {
    
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    try deleteNoLock(key) // Delete any existing key before saving it

    let accessible = access?.value ?? KeychainSwiftAccessOptions.defaultOption.value
      
    let prefixedKey = keyWithPrefix(key)
      
    var query: [String : Any] = [
      KeychainSwiftConstants.klass       : kSecClassGenericPassword,
      KeychainSwiftConstants.attrAccount : prefixedKey,
      KeychainSwiftConstants.valueData   : value,
      KeychainSwiftConstants.accessible  : accessible
    ]
      
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: true)
    lastQueryParameters = query
    
    try throwIfFailed(SecItemAdd(query as CFDictionary, nil))
  }

  /**

  Stores the boolean value in the keychain item under the given key.

  - parameter key: Key under which the value is stored in the keychain.
  - parameter value: Boolean to be written to the keychain.
  - parameter withAccess: Value that indicates when your app needs access to the value in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.

  */
  open func set(_ value: Bool, forKey key: String,
    withAccess access: KeychainSwiftAccessOptions? = nil) throws {
  
    let bytes: [UInt8] = value ? [1] : [0]
    let data = Data(bytes)

    try set(data, forKey: key, withAccess: access)
  }

  /**
  
  Retrieves the text value from the keychain that corresponds to the given key.
  
  - parameter key: The key that is used to read the keychain item.
  - returns: The text value from the keychain. Returns nil if unable to read the item.
  
  */
  open func get(_ key: String) throws -> String? {
    if let data = try getData(key) {
      
      if let currentString = String(data: data, encoding: .utf8) {
        return currentString
      }
      
      throw KeychainError(errSecInvalidEncoding)
    }

    return nil
  }

  /**
  
  Retrieves the data from the keychain that corresponds to the given key.
  
  - parameter key: The key that is used to read the keychain item.
  - parameter asReference: If true, returns the data as reference (needed for things like NEVPNProtocol).
  - returns: The text value from the keychain. Returns nil if unable to read the item.
  
  */
  open func getData(_ key: String, asReference: Bool = false) throws -> Data? {
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
      KeychainSwiftConstants.klass       : kSecClassGenericPassword,
      KeychainSwiftConstants.attrAccount : prefixedKey,
      KeychainSwiftConstants.matchLimit  : kSecMatchLimitOne
    ]
    
    if asReference {
      query[KeychainSwiftConstants.returnReference] = kCFBooleanTrue
    } else {
      query[KeychainSwiftConstants.returnData] =  kCFBooleanTrue
    }
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    var result: AnyObject?
    
    let lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode != errSecItemNotFound {
      try throwIfFailed(lastResultCode)
    }
    
    return result as? Data
  }

  /**

  Retrieves the boolean value from the keychain that corresponds to the given key.

  - parameter key: The key that is used to read the keychain item.
  - returns: The boolean value from the keychain. Returns nil if unable to read the item.

  */
  open func getBool(_ key: String) throws -> Bool? {
    guard let data = try getData(key) else { return nil }
    guard let firstBit = data.first else { return nil }
    return firstBit == 1
  }

  /**

  Deletes the single keychain item specified by the key.
  
  - parameter key: The key that is used to delete the keychain item.
  - returns: True if the item was successfully deleted.
  
  */
  @discardableResult
  open func delete(_ key: String) throws -> Bool {
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    return try deleteNoLock(key)
  }
  
  /**
  Return all keys from keychain
   
  - returns: An string array with all keys from the keychain.
   
  */
  public var allKeys: [String] {
    var query: [String: Any] = [
      KeychainSwiftConstants.klass : kSecClassGenericPassword,
      KeychainSwiftConstants.returnData : true,
      KeychainSwiftConstants.returnAttributes: true,
      KeychainSwiftConstants.returnReference: true,
      KeychainSwiftConstants.matchLimit: KeychainSwiftConstants.secMatchLimitAll
    ]
  
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)

    var result: AnyObject?

    let lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return (result as? [[String: Any]])?.compactMap {
        $0[KeychainSwiftConstants.attrAccount] as? String } ?? []
    }
    
    return []
  }
    
  /**
   
  Same as `delete` but is only accessed internally, since it is not thread safe.
   
   - parameter key: The key that is used to delete the keychain item.
   - returns: True if the item was successfully deleted.
   
   */
   @discardableResult
   func deleteNoLock(_ key: String) throws -> Bool {
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
      KeychainSwiftConstants.klass       : kSecClassGenericPassword,
      KeychainSwiftConstants.attrAccount : prefixedKey
    ]
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    let lastResultCode = SecItemDelete(query as CFDictionary)
    
    guard lastResultCode != errSecItemNotFound else { return false }
      
    try throwIfFailed(lastResultCode)
    return true
  }

  /**
  
  Deletes all Keychain items used by the app. Note that this method deletes all items regardless of the prefix settings used for initializing the class.
  
  */
  open func clear() throws {
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    try throwIfFailed(SecItemDelete(query as CFDictionary))
  }
  
  /// Returns the key with currently set prefix.
  func keyWithPrefix(_ key: String) -> String {
    return "\(keyPrefix)\(key)"
  }
  
  func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
    guard let accessGroup = accessGroup else { return items }
    
    var result: [String: Any] = items
    result[KeychainSwiftConstants.accessGroup] = accessGroup
    return result
  }
  
  /**
 
  Adds kSecAttrSynchronizable: kSecAttrSynchronizableAny` item to the dictionary when the `synchronizable` property is true.
   
   - parameter items: The dictionary where the kSecAttrSynchronizable items will be added when requested.
   - parameter addingItems: Use `true` when the dictionary will be used with `SecItemAdd` method (adding a keychain item). For getting and deleting items, use `false`.
   
   - returns: the dictionary with kSecAttrSynchronizable item added if it was requested. Otherwise, it returns the original dictionary.
 
  */
  func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
    if !synchronizable { return items }
    var result: [String: Any] = items
    result[KeychainSwiftConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
    return result
  }
  
  @inlinable
  func throwIfFailed(_ status: OSStatus) throws {
    if status != noErr {
      throw KeychainError(status)
    }
  }
}
