//
//  Errors.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public enum CaverError: Error {
    case ArgumentException(String)
    case NumberFormatException(String)
    case IOException(String)
    case ClassNotFoundException(String)
    case NoSuchMethodException(String)
    case InstantiationException(String)
    case IllegalAccessException(String)
    case InvocationTargetException(String)
    case invalidSignature
    case unexpectedReturnValue
    case decodeIssue
    case UnsupportedOperationException(String)
    case invalidValue
    case invalidType
    case notCurrentlySupported
}
