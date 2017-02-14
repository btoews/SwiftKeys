//
//  RSA.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/14/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public class RSA: KeyPair {
    override class var keyType: SecAttrKeyType { return SecAttrKeyType.RSA }
}
