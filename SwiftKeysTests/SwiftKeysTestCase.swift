//
//  SwiftKeysTestCase.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/14/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
import SwiftKeys

class SwiftKeysTestCase: XCTestCase {    
    override func setUp() {
        SwiftKeys.Keychain.namespace = "SwiftKeysTests"
        let _ = SwiftKeys.Keychain.delete()
    }
    
    override func tearDown() {
        let _ = SwiftKeys.Keychain.delete()
    }
}
