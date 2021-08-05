//
//  PublicKey.swift
//  SwiftECC
//
//  Created by Leif Ibsen on 18/02/2020.
//

import Foundation
import ASN1
import BigInt

///
/// An Elliptic Curve public key
///
public class ECPublicKey: CustomStringConvertible {

    // Cache multiples of w to speed up signature verification
    var wptsP: [Point]?
    var wpts2: [Point2]?

    // MARK: Initializers
    
    /// Creates a public key
    ///
    /// - Parameters:
    ///   - domain: The domain the key belongs to
    ///   - w: The public key value - a curve point
    /// - Throws: An exception if *w* is not on the curve
    public init(domain: Domain, w: Point) throws {
        if !domain.contains(w) {
            throw ECException.publicKeyParameter
        }
        self.domain = domain
        self.w = w
        
        // Compute and cache multiples of 'w' to speed-up encrytion and signature verification

        if self.domain.characteristic2 {
            self.wptsP = nil
            self.wpts2 = self.domain.domain2!.computeGWpts(self.w)
        } else {
            self.wptsP = self.domain.domainP!.computeGWpts(self.w)
            self.wpts2 = nil
        }
    }
    
    /// Creates a public key from its DER encoding
    ///
    /// - Parameters:
    ///   - der: The DER encoding of the key
    /// - Throws: An exception if the DER encoding is wrong
    public convenience init(der: [UInt8]) throws {
        let asn1 = try ASN1.build(der)
        guard let seq = asn1 as? ASN1Sequence else {
            throw ECException.asn1Structure
        }
        if seq.getValue().count < 2 {
            throw ECException.asn1Structure
        }
        guard let seq1 = seq.get(0) as? ASN1Sequence else {
            throw ECException.asn1Structure
        }
        guard let bits = seq.get(1) as? ASN1BitString else {
            throw ECException.asn1Structure
        }
        if seq1.getValue().count < 2 {
            throw ECException.asn1Structure
        }
        let domain = try Domain.domainFromASN1(seq1.get(1))
        let w = try domain.asn1DecodePoint(bits)
        try self.init(domain: domain, w: w)
    }

    /// Creates a public key from its PEM encoding
    ///
    /// - Parameters:
    ///   - pem: The PEM encoding of the key
    /// - Throws: An exception if the PEM encoding is wrong
    public convenience init(pem: String) throws {
        try self.init(der: Base64.pemDecode(pem, "PUBLIC KEY"))
    }

    
    // MARK: Stored Properties
    
    /// The domain the key belongs to
    public let domain: Domain
    /// The public value - a curve point
    public let w: Point
    
    
    // MARK: Computed Properties

    /// The ASN1 encoding of *self*
    public var asn1: ASN1 { get { do { return ASN1Sequence().add(ASN1Sequence().add(ASN1ObjectIdentifier("1.2.840.10045.2.1")!).add(self.domain.asn1)).add(try ASN1BitString(
        self.domain.encodePoint(self.w), 0)) } catch { return ASN1.NULL } } }
    /// The PEM encoding of *self*
    public var pem: String { get { return Base64.pemEncode(self.asn1.encode(), "PUBLIC KEY") } }
    /// A textual representation of the ASN1 encoding of *self*
    public var description: String { get { return self.asn1.description } }

    
    // MARK: Instance Methods
    
    /// Verifies a signature with ECDSA
    ///
    /// - Parameters:
    ///   - signature: The signature to verify
    ///   - msg: The message to verify *signature* for
    ///   - bw: Optional bitwidth used to select the proper message digest. By default the domain field size is used
    /// - Returns: *true* iff the signature is verified
    public func verify(signature: ECSignature, msg: [UInt8], bw: Int? = nil) -> Bool {
        let order = self.domain.order
        guard signature.r.count > 0 && signature.s.count > 0 else {
            return false
        }
        let r = BInt(magnitude: signature.r)
        guard r > BInt.ZERO && r < order else {
            return false
        }
        let s = BInt(magnitude: signature.s)
        guard s > BInt.ZERO && s < order else {
            return false
        }
        let md = bw == nil ? MessageDigest.instance(self.domain) : MessageDigest.instance(bw!)
        md.update(msg)
        let digest = md.digest()
        var e = BInt(magnitude: digest)
        let d = digest.count * 8 - order.bitWidth
        if d > 0 {
            e >>= d
        }
        let x = s.modInverse(order)
        let u1 = (e * x).mod(order)
        let u2 = (r * x).mod(order)
        var wu2: Point
        if self.domain.characteristic2 {
            wu2 = self.domain.domain2!.multiplyW(u2, &self.wpts2!)
        } else {
            wu2 = self.domain.domainP!.multiplyW(u2, &self.wptsP!)
        }
        do {
            let R = try self.domain.addPoints(self.domain.multiplyG(u1), wu2)
            return R.infinity ? false : R.x.mod(order) == r
        } catch {
            return false
        }
    }
    
    /// Verifies a signature with ECDSA
    ///
    /// - Parameters:
    ///   - signature: The signature to verify
    ///   - msg: The message to verify *signature* for
    ///   - bw: Optional bitwidth used to select the proper message digest. By default the domain field size is used
    /// - Returns: *true* iff the signature is verified
    public func verify(signature: ECSignature, msg: Data, bw: Int? = nil) -> Bool {
        return self.verify(signature: signature, msg: [UInt8](msg), bw: bw)
    }

    /// Encrypts a byte array with ECIES
    ///
    /// - Parameters:
    ///   - msg: The bytes to encrypt
    ///   - cipher: The AES cipher to use
    ///   - mode: The block mode to use - GCM is default
    /// - Returns: The encrypted message
    public func encrypt(msg: [UInt8], cipher: AESCipher, mode: BlockMode = .GCM) -> [UInt8] {
        let r = (self.domain.order - BInt.ONE).randomLessThan() + BInt.ONE
        do {
            let R = try self.domain.encodePoint(self.domain.multiplyG(r))
            var SP: Point
            if self.domain.characteristic2 {
                SP = self.domain.domain2!.multiplyW(r, &self.wpts2!)
            } else {
                SP = self.domain.domainP!.multiplyW(r, &self.wptsP!)
            }
            let S = self.domain.align(SP.x.asMagnitudeBytes())
            let cipher = Cipher.instance(cipher, mode, S, R)
            var result = msg
            let tag = cipher.encrypt(&result)
            return R + result + tag
        } catch {
            fatalError("'encrypt' inconsistency")
        }
    }

    /// Encrypts a Data structure with ECIES
    ///
    /// - Parameters:
    ///   - msg: The data to encrypt
    ///   - cipher: The AES cipher to use
    ///   - mode: The block mode to use - GCM is default
    /// - Returns: The encrypted message
    public func encrypt(msg: Data, cipher: AESCipher, mode: BlockMode = .GCM) -> Data {
        return Data(self.encrypt(msg: [UInt8](msg), cipher: cipher, mode: mode))
    }

}
