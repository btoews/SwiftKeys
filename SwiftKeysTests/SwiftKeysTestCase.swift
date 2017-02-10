//
//  SwiftKeysTestCase.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/10/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
@testable import SwiftKeys

class SwiftKeysTestCase: XCTestCase {
    static var keychainWas: Keychain?
    
    override static func setUp() {
        super.setUp()
        
        keychainWas = Keychain.shared
        Keychain.namespace = "SwiftKeysTest"
    }
    
    override static func tearDown() {
        if let kcw = keychainWas {
            Keychain.shared = kcw
        }

        super.tearDown()
    }
}
