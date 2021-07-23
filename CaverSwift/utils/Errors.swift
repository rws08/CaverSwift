//
//  Errors.swift
//  CaverSwift
//
//  Created by won on 2021/05/10.
//

import Foundation

public enum CaverError: Error, Equatable {
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
    case RuntimeException(String)
    case IllegalArgumentException(String)
    case NullPointerException(String)
    case SignatureException(String)
    case CipherException(String)
    case TransactionException(String, String)
    case JSONRPCError(String)
}
