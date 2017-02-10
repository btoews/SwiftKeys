//
//  Utils.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/9/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

typealias CFDictionaryMember = (CFString, CFTypeRef)

// Helper for making CFDictionary.
func makeCFDictionary(_ members: [CFDictionaryMember]) -> CFDictionary {
    var dict = [String: AnyObject]()
    
    members.forEach { elt in
        dict[elt.0 as String] = elt.1
    }
    
    return dict as CFDictionary
}

// Helper for making CFDictionary.
func makeCFDictionary(_ members: CFDictionaryMember...) -> CFDictionary {
    return makeCFDictionary(members)
}
