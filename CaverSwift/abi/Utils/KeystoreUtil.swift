//
//  KeystoreUtil.swift
//  web3swift
//
//  Created by Julien Niset on 16/02/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation

enum KeystoreUtilError: Error {
    case corruptedKeystore
    case decodeFailed
    case encodeFailed
    case unknown
}
