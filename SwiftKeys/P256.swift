//
//  P256.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/10/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public class P256: KeyPair {
    public convenience init?(protection: SecAttrAccessible, isPermanent: Bool = true, keychain: Keychain = Keychain.shared) {
        self.init(size: 256, protection: protection, keychain: keychain)
    }
}
