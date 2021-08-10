//
//  Signature.swift
//  SwiftECC
//
//  Created by Leif Ibsen on 18/02/2020.
//

import ASN1
import BigInt

///
/// ECSignature instances contain an ECDSA signature which consists of two byte arrays named *r* and *s*
///
public class ECSignature {

    // MARK: Initializers

    /// Creates a signature from its *r* and *s* components
    ///
    /// - Parameters:
    ///   - r: The r component
    ///   - s: The s component
    public init(r: [UInt8], s: [UInt8]) {
        self.r = r
        self.s = s
    }

    /// Creates a signature from its ASN1 representation
    ///
    /// - Parameters:
    ///   - asn1: The ASN1 representation of the signature
    ///   - domain: The domain of the signature
    /// - Throws: An exception if the ASN1 structure is wrong
    public convenience init(asn1: ASN1, domain: Domain) throws {
        guard let seq = asn1 as? ASN1Sequence else {
            throw ECException.asn1Structure
        }
        if seq.getValue().count < 2 {
            throw ECException.asn1Structure
        }
        guard let r0 = seq.get(0) as? ASN1Integer else {
            throw ECException.asn1Structure
        }
        guard let s1 = seq.get(1) as? ASN1Integer else {
            throw ECException.asn1Structure
        }
        self.init(r: domain.align(r0.value.asMagnitudeBytes()), s: domain.align(s1.value.asMagnitudeBytes()))
    }


    // MARK: Stored Properties
    
    /// The *r* component of the signature
    public let r: [UInt8]
    /// The *s* component of the signature
    public let s: [UInt8]
    
    
    // MARK: Computed Properties
    
    /// The ASN1 encoding of the signature
    public var asn1: ASN1 { get { return ASN1Sequence().add(ASN1Integer(BInt(magnitude: self.r))).add(ASN1Integer(BInt(magnitude: self.s))) } }
    /// Textual description of *self*
    public var description: String { get { return self.asn1.description } }

}
