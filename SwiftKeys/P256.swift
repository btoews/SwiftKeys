//
//  P256.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/10/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public class P256: EC, KeyPair {
    public static let keySize = 256
    
    public let keychain: Keychain
    public let applicationLabel: Data
    public let privateKey: SecKey
    public let publicKey: SecKey
    
    required public init(applicationLabel: Data, privateKey: SecKey, publicKey: SecKey, keychain: Keychain) {
        self.applicationLabel = applicationLabel
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.keychain = keychain
    }
}
