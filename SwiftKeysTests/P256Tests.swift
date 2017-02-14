//
//  P256Tests.swift
//  SwiftKeysTests
//
//  Created by Benjamin P Toews on 2/14/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
import SwiftKeys

class P256Tests: SwiftKeysTestCase {
    func testGenerate() {
        guard let _ = SwiftKeys.P256(protection: .Always) else {
            XCTFail("Error generating key")
            return
        }
    }
    
    func testFind() {
        guard let k1 = SwiftKeys.P256(protection: .Always) else {
            XCTFail("Error generating key")
            return
        }
        
        guard let k2 = SwiftKeys.P256(applicationLabel: k1.applicationLabel) else {
            XCTFail("Error finding key")
            return
        }
        
        XCTAssertEqual(k1.applicationLabel, k2.applicationLabel)
        XCTAssertEqual(k1.publicKeyData, k2.publicKeyData)
    }
    
    func testCount() {
        XCTAssertEqual(SwiftKeys.P256.count() , 0)
        let _ = SwiftKeys.P256(protection: .Always)
        XCTAssertEqual(SwiftKeys.P256.count() , 2)
        let _ = SwiftKeys.P256(protection: .Always)
        XCTAssertEqual(SwiftKeys.P256.count() , 4)
        let _ = SwiftKeys.P256(protection: .Always)
        XCTAssertEqual(SwiftKeys.P256.count() , 6)
    }
    
    func testDeleteAll() {
        let _ = SwiftKeys.P256(protection: .Always)
        XCTAssertEqual(SwiftKeys.P256.count() , 2)
        let _ = SwiftKeys.P256.delete()
        XCTAssertEqual(SwiftKeys.P256.count() , 0)
    }
    
    func testDeleteOne() {
        let _ = SwiftKeys.P256(protection: .Always)
        let k = SwiftKeys.P256(protection: .Always)
        XCTAssertEqual(SwiftKeys.P256.count() , 4)
        let _ = k?.delete()
        XCTAssertEqual(SwiftKeys.P256.count() , 2)
    }
    
    func testPublicKeyData() {
        guard let k = SwiftKeys.P256(protection: .Always) else {
            XCTFail("Error generating key")
            return
        }
        
        guard let pk = k.publicKeyData else {
            XCTFail("Error getting public key data")
            return
        }
        
        XCTAssertEqual(pk.count, 65)
    }
    
    func testSignVerify() {
        let d = "hello, world!".data(using: .utf8)!
        let d2 = "hi, world!".data(using: .utf8)!

        guard let k = SwiftKeys.P256(protection: .Always) else {
            XCTFail("Error generating key")
            return
        }
        
        guard let sig = k.sign(d, algorithm: .ecdsaSignatureMessageX962SHA256) else {
            XCTFail("Error generating signature")
            return
        }
        
        XCTAssert(k.verify(data: d, signature: sig, algorithm: .ecdsaSignatureMessageX962SHA256))
        XCTAssert(!k.verify(data: d, signature: sig, algorithm: .ecdsaSignatureMessageX962SHA512))
        XCTAssert(!k.verify(data: d2, signature: sig, algorithm: .ecdsaSignatureMessageX962SHA256))
        XCTAssert(!k.verify(data: d, signature: d2, algorithm: .ecdsaSignatureMessageX962SHA256))
    }
}
