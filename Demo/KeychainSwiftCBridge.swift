import Security
import Foundation
import KeychainSwift // You might need to remove this import in your project

/**

 This file can be used in your ObjC project if you want to use KeychainSwift Swift library.
 Extend this file to add other functionality for your app.

 How to use
 ----------

 1. Import swift code in your ObjC file:

 #import "YOUR_PRODUCT_MODULE_NAME-Swift.h"

 2. Use KeychainSwift in your ObjC code:

 - (void)viewDidLoad {
 [super viewDidLoad];

 KeychainSwiftCBridge *keychain = [[KeychainSwiftCBridge alloc] init];
 [keychain set:@"Hello World" forKey:@"my key"];
 NSString *value = [keychain get:@"my key"];

 3. You might need to remove `import KeychainSwift` import from this file in your project.

*/
@objcMembers public class KeychainSwiftCBridge: NSObject {
  private var _accessGroup: String?
  private var _synchronizable: Bool = false

  private var keychain: KeychainSwift {
    KeychainSwift(accessGroup: _accessGroup, synchronizable: _synchronizable)
  }

  open var accessGroup: String? {
    set { _accessGroup = newValue }
    get { return _accessGroup }
  }

  open var synchronizable: Bool {
    set { _synchronizable = newValue }
    get { return _synchronizable }
  }


  @discardableResult
  open func set(_ value: String, forKey key: String) -> Bool {
    return (try? keychain.set(value, forKey: key)) != nil
  }

  @discardableResult
  open func setData(_ value: Data, forKey key: String) -> Bool {
    return (try? keychain.set(value, forKey: key)) != nil
  }

  @discardableResult
  open func setBool(_ value: Bool, forKey key: String) -> Bool {
    return (try? keychain.set(value, forKey: key)) != nil
  }

  open func get(_ key: String) -> String? {
    return (try? keychain.get(key)) ?? nil
  }

  open func getData(_ key: String) -> Data? {
    return (try? keychain.getData(key)) ?? nil
  }

  open func getBool(_ key: String) -> Bool? {
    return (try? keychain.getBool(key)) ?? nil
  }

  @discardableResult
  open func delete(_ key: String) -> Bool {
    return (try? keychain.delete(key)) ?? false
  }

  @discardableResult
  open func clear() -> Bool {
    return (try? keychain.clear()) != nil
  }
}
