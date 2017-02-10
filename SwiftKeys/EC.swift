//
//  EC.swift
//  SwiftKeys
//
//  Created by Benjamin P Toews on 2/9/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public protocol EC {}

extension EC {
    public static var keyType: SecAttrKeyType { return .EC }
}
