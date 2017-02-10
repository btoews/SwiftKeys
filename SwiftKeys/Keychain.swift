//
//  Keychain.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/9/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import Security

public class Keychain {
    static var shared = Keychain(label: "SwiftKeys")

    public static var namespace: String {
        get {
            return shared.label
        }
        
        set {
            shared = Keychain(label: newValue)
        }
    }
    
    let label: String
    
    init(label: String) {
        self.label = label
    }
    
    // Count SecItems matching query.
    func count(query: CFDictionaryMember...) -> Int? {
        let queryDict = makeCFDictionary(query)
        var optionalOpaqueResult: CFTypeRef? = nil
        
        let err = SecItemCopyMatching(queryDict, &optionalOpaqueResult)
        
        if err == errSecItemNotFound {
            return 0
        }
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }
        
        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return nil
        }
        
        let result = opaqueResult as! CFArray as [AnyObject]
        
        return result.count
    }

    // Count all SecItems generated with this keychain.
    func count() -> Int? {
        return count(query:
            (kSecClass,       kSecClassKey),
            (kSecAttrLabel,   label as CFString),
            (kSecReturnRef,   kCFBooleanTrue),
            (kSecMatchLimit,  100 as CFNumber)
        )
    }
    
    // Count SecItems of keyType.
    func count(keyType: SecAttrKeyType) -> Int? {
        return count(query:
            (kSecClass,       kSecClassKey),
            (kSecAttrKeyType, keyType.rawValue as CFString),
            (kSecAttrLabel,   label as CFString),
            (kSecReturnRef,   kCFBooleanTrue),
            (kSecMatchLimit,  100 as CFNumber)
        )
    }
    
    // Delete all keychain items matching the given query.
    func delete(query: CFDictionaryMember...) -> Bool {
        let queryDict = makeCFDictionary(query)
        
        let err = SecItemDelete(queryDict)
        
        switch err {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            print("Error from keychain: \(err)")
            return false
        }
    }
    
    // Delete all keys generate with this Keychain.
    func delete() -> Bool {
        return delete(query:
            (kSecClass, kSecClassKey),
            (kSecAttrLabel, label as CFString)
        )
    }

    // Delete the key with the specified application label.
    func delete(keyType: SecAttrKeyType) -> Bool {
        return delete(query:
            (kSecClass, kSecClassKey),
            (kSecAttrLabel, label as CFString),
            (kSecAttrKeyType, keyType.rawValue as CFString)
        )
    }
    
    // Delete the key with the specified application label.
    func delete(attrAppLabel: Data) -> Bool {
        return delete(query: 
            (kSecClass, kSecClassKey),
            (kSecAttrLabel, label as CFString),
            (kSecAttrApplicationLabel, attrAppLabel as CFData)
        )
    }
    
    
    // Get the given attribute for the given SecKey.
    func getSecKeyAttr<T:Any>(key: SecKey, attr: SecAttr) -> T? {
        guard let attrs = SecKeyCopyAttributes(key) as? [String: AnyObject] else {
            return nil
        }
        
        guard let ret = attrs[attr.rawValue] as? T else {
            return nil
        }
        
        return ret
    }
    
    // Get the given attribute for the SecItem with the given kSecAttrApplicationLabel.
    func getSecItemAttr<T>(attrAppLabel: Data, keyType: SecAttrKeyType, keyClass: SecAttrKeyClass, attr: SecAttr) -> T? {
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, keyType.rawValue as CFString),
            (kSecAttrKeyClass, keyClass.rawValue as CFString),
            (kSecAttrApplicationLabel, attrAppLabel as CFData),
            (kSecReturnAttributes, kCFBooleanTrue)
        )
        
        var optionalOpaqueDict: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueDict)
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }
        
        guard let opaqueDict = optionalOpaqueDict else {
            print("Unexpected nil returned from keychain")
            return nil
        }
        
        guard let dict = opaqueDict as! CFDictionary as? [String: AnyObject] else {
            print("Error downcasting CFDictionary")
            return nil
        }
        
        guard let opaqueResult = dict[attr.rawValue] else {
            print("Missing key in dictionary")
            return nil
        }
        
        return opaqueResult as? T
    }
    
    // Get the given attribute for the SecItem with the given kSecAttrApplicationLabel.
    func setSecItemAttr<T:CFTypeRef>(attrAppLabel: Data, keyType: SecAttrKeyType, keyClass: SecAttrKeyClass, attr: SecAttr, value: T) {
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, keyType.rawValue as CFString),
            (kSecAttrKeyClass, keyClass.rawValue as CFString),
            (kSecAttrApplicationLabel, attrAppLabel as CFData)
        )
        
        let newAttrs = makeCFDictionary(
            (attr.rawValue as CFString, value)
        )
        
        let err = SecItemUpdate(query, newAttrs)
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
        }
    }
    
    // Get the raw data for the SecItem with the given kSecAttrApplicationLabel.
    func getSecItemData(attrAppLabel: Data, keyType: SecAttrKeyType, keyClass: SecAttrKeyClass) -> Data? {
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, keyType.rawValue as CFString),
            (kSecAttrKeyClass, keyClass.rawValue as CFString),
            (kSecAttrApplicationLabel, attrAppLabel as CFData),
            (kSecReturnData, kCFBooleanTrue)
        )
        
        var optionalOpaqueResult: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueResult)
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }
        
        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return nil
        }
        
        return opaqueResult as! CFData as Data
    }
    
    func getSecKey(attrAppLabel: Data, keyClass: SecAttrKeyClass) -> SecKey? {
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, kSecAttrKeyTypeEC),
            (kSecAttrKeyClass, keyClass.rawValue as CFString),
            (kSecAttrApplicationLabel, attrAppLabel as CFData),
            (kSecReturnRef, kCFBooleanTrue)
        )
        
        var optionalOpaqueResult: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueResult)
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }
        
        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return nil
        }
        
        let result = opaqueResult as! SecKey
        
        return result
    }
    
    // Generate access control policy for key generation.
    func generateACL(protection: SecAttrAccessible, rawFlags: UInt = 0) -> SecAccessControl? {
        var err: Unmanaged<CFError>? = nil
        let flags = SecAccessControlCreateFlags.init(rawValue: rawFlags)

        let ret = SecAccessControlCreateWithFlags(nil, protection.rawValue as CFString, flags, &err)
        
        if err != nil {
            print("Error generating ACL for key generation: \(err!.takeRetainedValue().localizedDescription)")
            err!.release()
            return nil
        }
        
        return ret
    }
    
    func generateKeyPair(keyType: SecAttrKeyType, keySize: Int, isPermanent: Bool, acl: SecAccessControl) -> (SecKey, SecKey)? {
        // Make parameters for generating keys.
        let params = makeCFDictionary(
            (kSecAttrKeyType, keyType.rawValue as CFString),
            (kSecAttrKeySizeInBits, keySize as CFNumber),
            (kSecAttrAccessControl, acl),
            (kSecAttrIsPermanent, isPermanent as CFBoolean),
            (kSecAttrLabel, label as CFString)
        )
        
        // Generate key pair.
        var pub: SecKey? = nil
        var priv: SecKey? = nil
        let status = SecKeyGeneratePair(params, &pub, &priv)
        
        if status != errSecSuccess {
            print("Error calling SecKeyGeneratePair: \(status)")
            return nil
        }
        
        if pub == nil || priv == nil {
            print("Keys not returned from SecKeyGeneratePair")
            return nil
        }
        
        return (pub!, priv!)
    }
    
    // Sign some data with the private key.
    func sign(key: SecKey, data: Data, algorithm: SecKeyAlgorithm) -> Data? {
        var err: Unmanaged<CFError>? = nil
        defer { err?.release() }
        
        let sig = SecKeyCreateSignature(key, algorithm, data as CFData, &err) as? Data
        
        if err != nil {
            print("Error creating signature: \(err!.takeUnretainedValue().localizedDescription)")
            return nil
        }
        
        return sig
    }
    
    // Verify some signature over some data with the public key.
    func verify(key: SecKey, data: Data, signature: Data, algorithm: SecKeyAlgorithm) -> Bool {
        var err: Unmanaged<CFError>? = nil
        defer { err?.release() }
        
        let ret = SecKeyVerifySignature(key, algorithm, data as CFData, signature as CFData, &err)
        
        if err != nil {
            print("Error verifying signature: \(err!.takeUnretainedValue().localizedDescription)")
            return false
        }
        
        return ret
    }
}
