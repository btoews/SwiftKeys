//
//  P256Tests.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/10/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
@testable import SwiftKeys

class P256Tests: SwiftKeysTestCase {
    var makeKey: P256? {
        return P256(protection: .Always)
    }
    
    func testGenerate() {
        guard let _ =  makeKey else {
            XCTFail("Error generating key")
            return
        }
    }
}
