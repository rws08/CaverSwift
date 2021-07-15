//
//  FeeDelegatedAccountUpdateWithRatioTest.swift
//  CaverSwiftTests
//
//  Created by won on 2021/07/15.
//

import XCTest
@testable import CaverSwift

class FeeDelegatedAccountUpdateWithRatioTest: XCTestCase {
    static let caver = Caver(Caver.DEFAULT_URL)
    
    static let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    static let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
    static let from = "0x5c525570f2b8e7e25f3a6b5e17f2cc63b872ece7"
    static let account = Account.createWithAccountKeyLegacy(from)
    static let to = "0x7b65b75d204abed71587c9e519a89277766ee1d0"
    static let gas = "0x493e0"
    static let gasPrice = "0x5d21dba00"
    static let nonce = "0x0"
    static let chainID = "0x7e3"
    static let value = "0xa"
    static let input = "0x68656c6c6f"
    static let humanReadable = false
    static let codeFormat = CodeFormat.EVM.hexa
    static let feeRatio = BigInt(30)

    static let senderSignature = SignatureData(
        "0x0fea",
        "0x8d45728ca7a288d27f70c6b7153624b6c3dabd8f345e63049048b2b1787aae1e",
        "0x370d2c5cf3cd99dc0a6ecaca75e30cc5e030ea71bf72fada047ace020c7410f0"
    )
    static let feePayer = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"
    static let feePayerSignatureData = SignatureData(
        "0x0fe9",
        "0x550440015be09e0020f3cf6173c862420e2982c77f6a0a43d607b153bb7abd6c",
        "0x67ca2a849a5e14992d3e9dff3562b1ac9856ff89f383c34645925fec12b3fdf9"
    )

    static let expectedRLPEncoding = "0x22f8cb808505d21dba00830493e0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece78201c01ef847f845820feaa08d45728ca7a288d27f70c6b7153624b6c3dabd8f345e63049048b2b1787aae1ea0370d2c5cf3cd99dc0a6ecaca75e30cc5e030ea71bf72fada047ace020c7410f094294f5bc8fadbd1079b191d9c47e1f217d6c987b4f847f845820fe9a0550440015be09e0020f3cf6173c862420e2982c77f6a0a43d607b153bb7abd6ca067ca2a849a5e14992d3e9dff3562b1ac9856ff89f383c34645925fec12b3fdf9"
    static let expectedTransactionHash = "0xbfc73185429a9b5310dd159d16e44e6d63f2e278bf1aaa12be48827f2dee9d43"
    static let expectedRLPSenderTransactionHash = "0x64e837cb9b7bdc3bffc8c37731ba60de47570da931b817139cf11b4fb1cc3a5e"
    static let expectedRLPEncodingForFeePayerSigning = "0xf841a6e522808505d21dba00830493e0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece78201c01e94294f5bc8fadbd1079b191d9c47e1f217d6c987b48207e38080"
    
    public static func getAccountUpdateList() throws -> [FeeDelegatedAccountUpdateWithRatio] {
        let accountUpdateList = [
            try setLegacyData().builder.build(),
            try setAccountPublic().builder.build(),
            try setAccountKeyFail().builder.build(),
            try setAccountKeyWeightedMultiSig().builder.build(),
            try setAccountKeyRoleBased().builder.build()
        ]
        return accountUpdateList
    }
    
    public static func getExpectedDataList() throws -> [ExpectedData] {
        let expectedDataList = [
            setLegacyData(),
            setAccountPublic(),
            setAccountKeyFail(),
            try setAccountKeyWeightedMultiSig(),
            try setAccountKeyRoleBased()
        ]
        return expectedDataList
    }
    
    static func setLegacyData() -> ExpectedData {
            let from = "0x5c525570f2b8e7e25f3a6b5e17f2cc63b872ece7"
            let account = Account.createWithAccountKeyLegacy(from)

            let gas = "0x493e0"
            let nonce = "0x0"
            let gasPrice = "0x5d21dba00"
            let feeRatio = BigInt(30)

            let senderSignatureData = SignatureData(
                    "0x0fea",
                    "0x8d45728ca7a288d27f70c6b7153624b6c3dabd8f345e63049048b2b1787aae1e",
                    "0x370d2c5cf3cd99dc0a6ecaca75e30cc5e030ea71bf72fada047ace020c7410f0"
            )

            let feePayer = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"

            let feePayerSignatureData = SignatureData(
                    "0x0fe9",
                    "0x550440015be09e0020f3cf6173c862420e2982c77f6a0a43d607b153bb7abd6c",
                    "0x67ca2a849a5e14992d3e9dff3562b1ac9856ff89f383c34645925fec12b3fdf9"
            )
            let chainID = "0x7e3"

            let builder = FeeDelegatedAccountUpdateWithRatio.Builder()
                    .setFrom(from)
                    .setAccount(account)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setNonce(nonce)
                    .setAccount(account)
                    .setSignatures(senderSignatureData)
                    .setFeeRatio(feeRatio)
                    .setFeePayer(feePayer)
                    .setFeePayerSignatures(feePayerSignatureData)
                    .setChainId(chainID)

            let expectedRLPEncoding = "0x22f8cb808505d21dba00830493e0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece78201c01ef847f845820feaa08d45728ca7a288d27f70c6b7153624b6c3dabd8f345e63049048b2b1787aae1ea0370d2c5cf3cd99dc0a6ecaca75e30cc5e030ea71bf72fada047ace020c7410f094294f5bc8fadbd1079b191d9c47e1f217d6c987b4f847f845820fe9a0550440015be09e0020f3cf6173c862420e2982c77f6a0a43d607b153bb7abd6ca067ca2a849a5e14992d3e9dff3562b1ac9856ff89f383c34645925fec12b3fdf9"
            let expectedRLPTransactionHash = "0xbfc73185429a9b5310dd159d16e44e6d63f2e278bf1aaa12be48827f2dee9d43"
            let expectedRLPSenderTransactionHash = "0x64e837cb9b7bdc3bffc8c37731ba60de47570da931b817139cf11b4fb1cc3a5e"
            let expectedRLPEncodingForFeePayerSigning = "0xf841a6e522808505d21dba00830493e0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece78201c01e94294f5bc8fadbd1079b191d9c47e1f217d6c987b48207e38080"

            let expectedData = ExpectedData(builder, expectedRLPEncoding, expectedRLPTransactionHash, expectedRLPSenderTransactionHash, expectedRLPEncodingForFeePayerSigning)

            return expectedData
        }

        static func setAccountPublic() -> ExpectedData {
            let from = "0x5c525570f2b8e7e25f3a6b5e17f2cc63b872ece7"
            let publicKey = "0xa1d2af887950891813bf7d851bce55f47246a5269a5d4be1fc0ab78d78ae0f5a5cce7537f5a3776df303d240c0f730301df6be668907a1106adb0dbbef0beb3c"
            let account = Account.createWithAccountKeyPublic(from, publicKey)

            let gas = "0x493e0"
            let nonce = "0x1"
            let gasPrice = "0x5d21dba00"
            let feeRatio = BigInt(30)
            let senderSignatureData = SignatureData(
                    "0x0fea",
                    "0x8553a692cd8f86af4d335785468a5b4527ee1a2d0c5e18517fe39375e4e82d85",
                    "0x698db3a07cc81427eb8ea877bb8af33d66abfb29526f58db6997eb99010be4fd"
            )

            let feePayer = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"
            let feePayerSignatureData = SignatureData(
                    "0x0fea",
                    "0xa44cbc6e30f9df61633ed1714014924b8b614b315288cdfd795c5ba18d36d5d8",
                    "0x011611104f18e3bb3d32508317a0ce6d31f0a71d55e2363b02a47aabbc7bf9d4"
            )

            let chainID = "0x7e3"

            let builder = FeeDelegatedAccountUpdateWithRatio.Builder()
                    .setFrom(from)
                    .setAccount(account)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setNonce(nonce)
                    .setAccount(account)
                    .setSignatures(senderSignatureData)
                    .setFeeRatio(feeRatio)
                    .setFeePayer(feePayer)
                    .setFeePayerSignatures(feePayerSignatureData)
                    .setChainId(chainID)

            let expectedRLPEncoding = "0x22f8ec018505d21dba00830493e0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece7a302a102a1d2af887950891813bf7d851bce55f47246a5269a5d4be1fc0ab78d78ae0f5a1ef847f845820feaa08553a692cd8f86af4d335785468a5b4527ee1a2d0c5e18517fe39375e4e82d85a0698db3a07cc81427eb8ea877bb8af33d66abfb29526f58db6997eb99010be4fd94294f5bc8fadbd1079b191d9c47e1f217d6c987b4f847f845820feaa0a44cbc6e30f9df61633ed1714014924b8b614b315288cdfd795c5ba18d36d5d8a0011611104f18e3bb3d32508317a0ce6d31f0a71d55e2363b02a47aabbc7bf9d4"
            let expectedRLPTransactionHash = "0x265ad666c91db8355a620831698b26e6504a5770a5d0d1d7f5a6706ee2387616"
            let expectedRLPSenderTransactionHash = "0xa9b2afdc79d7a647b1b8d38d552141f785ae8d37448aef1487a4dbd262165da0"
            let expectedRLPEncodingForFeePayerSigning = "0xf864b848f84622018505d21dba00830493e0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece7a302a102a1d2af887950891813bf7d851bce55f47246a5269a5d4be1fc0ab78d78ae0f5a1e94294f5bc8fadbd1079b191d9c47e1f217d6c987b48207e38080"

            let expectedData = ExpectedData(builder, expectedRLPEncoding, expectedRLPTransactionHash, expectedRLPSenderTransactionHash, expectedRLPEncodingForFeePayerSigning)

            return expectedData
        }

        static func setAccountKeyFail() -> ExpectedData {
            let from = "0x5c525570f2b8e7e25f3a6b5e17f2cc63b872ece7"
            let account = Account.createWithAccountKeyFail(from)

            let gas = "0x186a0"
            let nonce = "0x4"
            let gasPrice = "0x5d21dba00"
            let feeRatio = BigInt(30)
            let senderSignatureData = [
                    SignatureData(
                            "0x0fe9",
                            "0xfe43c4044a682a0f14489a4dabc94efdbf2838cff255911b059baf53511050e6",
                            "0x2fde2475ca919e313a6bb5cafe8ed3b61651c8cc6ff939f88c36c11b805d6530"
                    ),
                    SignatureData(
                            "0x0fea",
                            "0x0b17cb389f0dbc9f65d22255b82a0c440f6033f2cc5ec0deff11da3e2e515d14",
                            "0x1ba420aa515ac311812724a441e3f772b19536735ced7a0d989c50063d73aa58"
                    ),
                    SignatureData(
                            "0x0fe9",
                            "0xdc7fac293ee42ef4f113414bc391b8f976c95e10ff364a74a4564b8c9bd6af7a",
                            "0x4e0513eb4ee7359d631be46f8b7f44c0049b9f4752565b1978fcd2260fc8103d"
                    ),
            ]

            let feePayer = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"
            let feePayerSignatureData = SignatureData(
                    "0x0fea",
                    "0x409bdfe4239de15901ca37e54ab632a95cbced6a17ff85203d5c15ae140405f9",
                    "0x464cd266e2a207589508d9d6241e93fe637476e8562e755c4d133875d7afe0dc"
            )

            let chainID = "0x7e3"

            let builder = FeeDelegatedAccountUpdateWithRatio.Builder()
                    .setFrom(from)
                    .setAccount(account)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setNonce(nonce)
                    .setAccount(account)
                    .setSignatures(senderSignatureData)
                    .setFeeRatio(feeRatio)
                    .setFeePayer(feePayer)
                    .setFeePayerSignatures(feePayerSignatureData)
                    .setChainId(chainID)

            let expectedRLPEncoding = "0x22f90159048505d21dba00830186a0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece78203c01ef8d5f845820fe9a0fe43c4044a682a0f14489a4dabc94efdbf2838cff255911b059baf53511050e6a02fde2475ca919e313a6bb5cafe8ed3b61651c8cc6ff939f88c36c11b805d6530f845820feaa00b17cb389f0dbc9f65d22255b82a0c440f6033f2cc5ec0deff11da3e2e515d14a01ba420aa515ac311812724a441e3f772b19536735ced7a0d989c50063d73aa58f845820fe9a0dc7fac293ee42ef4f113414bc391b8f976c95e10ff364a74a4564b8c9bd6af7aa04e0513eb4ee7359d631be46f8b7f44c0049b9f4752565b1978fcd2260fc8103d94294f5bc8fadbd1079b191d9c47e1f217d6c987b4f847f845820feaa0409bdfe4239de15901ca37e54ab632a95cbced6a17ff85203d5c15ae140405f9a0464cd266e2a207589508d9d6241e93fe637476e8562e755c4d133875d7afe0dc"
            let expectedRLPTransactionHash = "0xe36dbee2c9c52a1d108794b69deb56efd40c250ef686b895ee9410b815d7eee4"
            let expectedRLPSenderTransactionHash = "0xfff1eba87cac6c60316441b05af9cf920612a3471fa188686bc6b8ee7ef120be"
            let expectedRLPEncodingForFeePayerSigning = "0xf841a6e522048505d21dba00830186a0945c525570f2b8e7e25f3a6b5e17f2cc63b872ece78203c01e94294f5bc8fadbd1079b191d9c47e1f217d6c987b48207e38080"

            let expectedData = ExpectedData(builder, expectedRLPEncoding, expectedRLPTransactionHash, expectedRLPSenderTransactionHash, expectedRLPEncodingForFeePayerSigning)

            return expectedData
        }

        static func setAccountKeyWeightedMultiSig() throws -> ExpectedData {
            let from = "0x5c525570f2b8e7e25f3a6b5e17f2cc63b872ece7"

            let publicKeyArr = [                    "0xabbd10c55f629098d594b5c2b2967198bc5eccdf20a35e4e9c2896b0db6c7a8d1255629bc54d3e52ddfd16202e1820034630c8a2c2a0d4a1561aa1a9a1a9cb2b",
                    "0x1f1d4186a795070bc519c7e297eed00d466106718a8e68abe43d37e65da0254f5968d5f789284099e11fd65b300c97ff6df543ba9b212f18a71e17adf8fbcdeb",
                    "0x1ec395b3de087980e4a6ae2cb6e9d1acb469c0e54577267f2c4a5b4809f9d9118b691c79b8b5a1d07ececa6cfe5c8be0ebd622f240558bd776e4e73fbc57932d",
            ]

            let options = try WeightedMultiSigOptions(BigInt(2), [BigInt(1), BigInt(2), BigInt(3)])
            let account = try Account.createWithAccountKeyWeightedMultiSig(from, publicKeyArr, options)

            let gas = "0x55730"
            let nonce = "0x2"
            let gasPrice = "0x5d21dba00"
            let feeRatio = BigInt(30)

            let senderSignatureData = SignatureData(
                    "0x0fe9",
                    "0xc1d45ae52a2de256d3da5086ab7769bccc3611243fdf3b1d0186617e3c782df7",
                    "0x26fcae8a34404ecc1e21a1a1a749c40cf667add4dc99986064d6097a95a59031"
            )

            let feePayer = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"

            let feePayerSignatureData = SignatureData(
                    "0x0fea",
                    "0x1b14fdbc76f6870943ebef563092324ef8743bf8ee5a7c76fe3faa2d60f74624",
                    "0x707502cd4225aa08f4990c5a564152ec55724d8ce4ea497ac1885c6791432899"
            )

            let chainID = "0x7e3"

            let builder = FeeDelegatedAccountUpdateWithRatio.Builder()
                    .setFrom(from)
                    .setAccount(account)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setNonce(nonce)
                    .setAccount(account)
                    .setSignatures(senderSignatureData)
                    .setFeeRatio(feeRatio)
                    .setFeePayer(feePayer)
                    .setFeePayerSignatures(feePayerSignatureData)
                    .setChainId(chainID)

            let expectedRLPEncoding = "0x22f9013c028505d21dba0083055730945c525570f2b8e7e25f3a6b5e17f2cc63b872ece7b87204f86f02f86ce301a103abbd10c55f629098d594b5c2b2967198bc5eccdf20a35e4e9c2896b0db6c7a8de302a1031f1d4186a795070bc519c7e297eed00d466106718a8e68abe43d37e65da0254fe303a1031ec395b3de087980e4a6ae2cb6e9d1acb469c0e54577267f2c4a5b4809f9d9111ef847f845820fe9a0c1d45ae52a2de256d3da5086ab7769bccc3611243fdf3b1d0186617e3c782df7a026fcae8a34404ecc1e21a1a1a749c40cf667add4dc99986064d6097a95a5903194294f5bc8fadbd1079b191d9c47e1f217d6c987b4f847f845820feaa01b14fdbc76f6870943ebef563092324ef8743bf8ee5a7c76fe3faa2d60f74624a0707502cd4225aa08f4990c5a564152ec55724d8ce4ea497ac1885c6791432899"
            let expectedRLPTransactionHash = "0x797a418893c6f3ac0cad2284707b716ef826e5fd09c5c1a5efddff897acefb1d"
            let expectedRLPSenderTransactionHash = "0x083d4a460b19988a34dfc1e3e458df84e2c97c8693389a13931a4c740746b746"
            let expectedRLPEncodingForFeePayerSigning = "0xf8b4b898f89622028505d21dba0083055730945c525570f2b8e7e25f3a6b5e17f2cc63b872ece7b87204f86f02f86ce301a103abbd10c55f629098d594b5c2b2967198bc5eccdf20a35e4e9c2896b0db6c7a8de302a1031f1d4186a795070bc519c7e297eed00d466106718a8e68abe43d37e65da0254fe303a1031ec395b3de087980e4a6ae2cb6e9d1acb469c0e54577267f2c4a5b4809f9d9111e94294f5bc8fadbd1079b191d9c47e1f217d6c987b48207e38080"

            let expectedData = ExpectedData(builder, expectedRLPEncoding, expectedRLPTransactionHash, expectedRLPSenderTransactionHash, expectedRLPEncodingForFeePayerSigning)

            return expectedData
        }

        static func setAccountKeyRoleBased() throws -> ExpectedData {
            let from = "0x5c525570f2b8e7e25f3a6b5e17f2cc63b872ece7"

            let publicKeyArr = [
                    [
                            "0x82d11080d64faed9b9cc0e50664175012d43491d430ed1c0c6d1e610c71155a9ec310c868f6873c539507602fd5df5a80e09c9a0b541d408fbdbc89553329c4b",
                            "0xc4a93d90ae50bb1234230b419ea3dcbb196d4619c36cacb1d6494d10832441b9902d8e67b22dd07fc561c07178edde33fe2554661d8c75af20058a2689b82d30",
                            "0xe7deb2e2b19c1fdb21163d7a3d4e861cdd59fa3df0e0e04420b8173b2545e546e979e26799a016d3f19e86601954e1609226297dd19b735a9e567ff76a4f3499",
                    ],
                    [
                            "0xfc08c1f60bd819090a710397d008f7fe9484d434d61d156074591ab1f8bce6b779432d7e744314e7204a68b6d2827e43ad8cbb7f819c0681d0581217e15ba654",
                            "0x281f3ae3b67ff556052338e27d9f9ce1d0175cce78b45b98338123a4baa0d2bd5815a4691b39ed893b943f8b2ed3104e3c5d09873df7ef9859070cc1c43b27e1",
                            "0xd347eec75998b6b5ac6cc9bb77a771a292c533fb043464462f9c37e9f3a84760de8d916eae476155bb09e51a63d557f46a259f6c4b0874acf58e362a1f59979a",
                    ],
                    [
                            "0x748d779bc3b06f83eb28636e6ab98838cb4b2ceb0c066ec6b5f3161a8f242e82374d599dd1f5296bf42404018fc2c4095cd2046aa7cfd8c11de1376ab1b26e6b",
                            "0x9e9c3e95386e71835a839c504e19b3ed36d1aff87892b6414b513525f6bd6a422685708d591fe8dc3b410459b90bf74cfbb5fffff26eebc4733aeca45a101536",
                            "0x1d965ec526e1d588d40b9c99fefa4763f2cebde74103a300778cb7c212474b49f88760495cb258441b19a8fd130aafc4ddc9d0786ab2922272c5f6b0501805a6",
                    ]
            ]

            let account = try Account.createWithAccountKeyRoleBased(from, publicKeyArr)

            let gas = "0x61a80"
            let nonce = "0x3"
            let gasPrice = "0x5d21dba00"
            let feeRatio = BigInt(30)
            let senderSignatureData = [
                    SignatureData(
                            "0x0fea",
                            "0xa2a8fe5dc3e5c6d01cde5b11ddd6a9fd8c419c4aa96100162f50e307660979b6",
                            "0x0e22cdfc93744a70403299e497618b8102f03a34773987ad80ae454fc8f97287"
                    ),
                    SignatureData(
                            "0x0fea",
                            "0x48d6e5567961fd86fd8cdbd46a81eec5336c76772d6644cb944eb995959af521",
                            "0x306064709347bc74177595e6f48fbe8665fe6772cdaff4885f640dbb4a820161"
                    ),
                    SignatureData(
                            "0x0fe9",
                            "0x0e335413896be3f75f9accbfee2a99b825a33d2513893d6ade0b18105d110245",
                            "0x085cfd94bd82c916ddcac4ca41b51d691b48073fa840752c166e470a9db9f7e9"
                    ),
            ]

            let feePayer = "0x294f5bc8fadbd1079b191d9c47e1f217d6c987b4"
            let feePayerSignatureData = SignatureData(
                    "0x0fea",
                    "0x7a8af8836035be491b86719c270375ddc1cefc2bcf19f2dfcd00e54173096e86",
                    "0x79d079ba796d28d24168a5eb10556620cc2a222f35691d19ed6ed85c245ffb8f"
            )

            let chainID = "0x7e3"

            let builder = FeeDelegatedAccountUpdateWithRatio.Builder()
                    .setFrom(from)
                    .setAccount(account)
                    .setGas(gas)
                    .setGasPrice(gasPrice)
                    .setNonce(nonce)
                    .setAccount(account)
                    .setSignatures(senderSignatureData)
                    .setFeeRatio(feeRatio)
                    .setFeePayer(feePayer)
                    .setFeePayerSignatures(feePayerSignatureData)
                    .setChainId(chainID)

            let expectedRLPEncoding = "0x22f902b9038505d21dba0083061a80945c525570f2b8e7e25f3a6b5e17f2cc63b872ece7b9016005f9015cb87204f86f01f86ce301a10382d11080d64faed9b9cc0e50664175012d43491d430ed1c0c6d1e610c71155a9e301a102c4a93d90ae50bb1234230b419ea3dcbb196d4619c36cacb1d6494d10832441b9e301a103e7deb2e2b19c1fdb21163d7a3d4e861cdd59fa3df0e0e04420b8173b2545e546b87204f86f01f86ce301a102fc08c1f60bd819090a710397d008f7fe9484d434d61d156074591ab1f8bce6b7e301a103281f3ae3b67ff556052338e27d9f9ce1d0175cce78b45b98338123a4baa0d2bde301a102d347eec75998b6b5ac6cc9bb77a771a292c533fb043464462f9c37e9f3a84760b87204f86f01f86ce301a103748d779bc3b06f83eb28636e6ab98838cb4b2ceb0c066ec6b5f3161a8f242e82e301a1029e9c3e95386e71835a839c504e19b3ed36d1aff87892b6414b513525f6bd6a42e301a1021d965ec526e1d588d40b9c99fefa4763f2cebde74103a300778cb7c212474b491ef8d5f845820feaa0a2a8fe5dc3e5c6d01cde5b11ddd6a9fd8c419c4aa96100162f50e307660979b6a00e22cdfc93744a70403299e497618b8102f03a34773987ad80ae454fc8f97287f845820feaa048d6e5567961fd86fd8cdbd46a81eec5336c76772d6644cb944eb995959af521a0306064709347bc74177595e6f48fbe8665fe6772cdaff4885f640dbb4a820161f845820fe9a00e335413896be3f75f9accbfee2a99b825a33d2513893d6ade0b18105d110245a0085cfd94bd82c916ddcac4ca41b51d691b48073fa840752c166e470a9db9f7e994294f5bc8fadbd1079b191d9c47e1f217d6c987b4f847f845820feaa07a8af8836035be491b86719c270375ddc1cefc2bcf19f2dfcd00e54173096e86a079d079ba796d28d24168a5eb10556620cc2a222f35691d19ed6ed85c245ffb8f"
            let expectedRLPTransactionHash = "0xd6f78a65f3de0dc2e4974a739bec097e54543c68beb5106bb1fc24d4290ec318"
            let expectedRLPSenderTransactionHash = "0x14e68510db84f82075fa367bbd4dada2b1024cb985fce70b4ae72ee9cc421b2a"
            let expectedRLPEncodingForFeePayerSigning = "0xf901a5b90188f9018522038505d21dba0083061a80945c525570f2b8e7e25f3a6b5e17f2cc63b872ece7b9016005f9015cb87204f86f01f86ce301a10382d11080d64faed9b9cc0e50664175012d43491d430ed1c0c6d1e610c71155a9e301a102c4a93d90ae50bb1234230b419ea3dcbb196d4619c36cacb1d6494d10832441b9e301a103e7deb2e2b19c1fdb21163d7a3d4e861cdd59fa3df0e0e04420b8173b2545e546b87204f86f01f86ce301a102fc08c1f60bd819090a710397d008f7fe9484d434d61d156074591ab1f8bce6b7e301a103281f3ae3b67ff556052338e27d9f9ce1d0175cce78b45b98338123a4baa0d2bde301a102d347eec75998b6b5ac6cc9bb77a771a292c533fb043464462f9c37e9f3a84760b87204f86f01f86ce301a103748d779bc3b06f83eb28636e6ab98838cb4b2ceb0c066ec6b5f3161a8f242e82e301a1029e9c3e95386e71835a839c504e19b3ed36d1aff87892b6414b513525f6bd6a42e301a1021d965ec526e1d588d40b9c99fefa4763f2cebde74103a300778cb7c212474b491e94294f5bc8fadbd1079b191d9c47e1f217d6c987b48207e38080"

            let expectedData = ExpectedData(builder, expectedRLPEncoding, expectedRLPTransactionHash, expectedRLPSenderTransactionHash, expectedRLPEncodingForFeePayerSigning)

            return expectedData
        }
    
    public class ExpectedData {
        var builder: FeeDelegatedAccountUpdateWithRatio.Builder
        var expectedRLPEncoding: String
        var expectedTransactionHash: String
        var expectedSenderTransactionHash: String
        var expectedRLPEncodingForFeePayerSigning: String

        public init(_ builder: FeeDelegatedAccountUpdateWithRatio.Builder, _ expectedRLPEncoding: String, _ expectedTransactionHash: String, _ expectedSenderTransactionHash: String, _ expectedRLPEncodingForFeePayerSigning: String) {
            self.builder = builder
            self.expectedRLPEncoding = expectedRLPEncoding
            self.expectedTransactionHash = expectedTransactionHash
            self.expectedSenderTransactionHash = expectedSenderTransactionHash
            self.expectedRLPEncodingForFeePayerSigning = expectedRLPEncodingForFeePayerSigning
        }

        public func getBuilder() -> FeeDelegatedAccountUpdateWithRatio.Builder{
            return builder
        }

        public func setBuilder(_ builder: FeeDelegatedAccountUpdateWithRatio.Builder) {
            self.builder = builder
        }

        public func getExpectedRLPEncoding() -> String {
            return expectedRLPEncoding
        }

        public func setExpectedRLPEncoding(_ expectedRLPEncoding: String) {
            self.expectedRLPEncoding = expectedRLPEncoding
        }

        public func getExpectedTransactionHash() -> String {
            return expectedTransactionHash
        }

        public func setExpectedTransactionHash(_ expectedTransactionHash: String) {
            self.expectedTransactionHash = expectedTransactionHash
        }

        public func getExpectedSenderTransactionHash() -> String {
            return expectedSenderTransactionHash
        }

        public func setExpectedSenderTransactionHash(_ expectedSenderTransactionHash: String) {
            self.expectedSenderTransactionHash = expectedSenderTransactionHash
        }

        public func getExpectedRLPEncodingForFeePayerSigning() -> String {
            return expectedRLPEncodingForFeePayerSigning
        }

        public func setExpectedRLPEncodingForFeePayerSigning(_ expectedRLPEncodingForFeePayerSigning: String) {
            self.expectedRLPEncodingForFeePayerSigning = expectedRLPEncodingForFeePayerSigning
        }
    }
    
    public static func generateRoleBaseKeyring(_ numArr: [Int], _ address: String) throws -> AbstractKeyring {
        let keyArr = KeyringFactory.generateRoleBasedKeys(numArr, "entropy")
        return try KeyringFactory.createWithRoleBasedKey(address, keyArr)
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_createInstanceBuilder: XCTestCase {
    let from = FeeDelegatedAccountUpdateWithRatioTest.from
    let account = FeeDelegatedAccountUpdateWithRatioTest.account
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = FeeDelegatedAccountUpdateWithRatioTest.gas
    let nonce = FeeDelegatedAccountUpdateWithRatioTest.nonce
    let gasPrice = FeeDelegatedAccountUpdateWithRatioTest.gasPrice
    let chainID = FeeDelegatedAccountUpdateWithRatioTest.chainID
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = FeeDelegatedAccountUpdateWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedAccountUpdateWithRatioTest.feeRatio
        
    public func test_BuilderTest() throws {
        let txObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeeRatio(feeRatio)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .build()
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_BuilderWithRPCTest() throws {
        let txObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setKlaytnCall(FeeDelegatedAccountUpdateWithRatioTest.caver.rpc.klay)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice("")
            .setNonce("")
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeeRatio(feeRatio)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId("")
            .build()
        
        try txObj.fillTransaction()
        
        XCTAssertFalse(txObj.nonce.isEmpty)
        XCTAssertFalse(txObj.gasPrice.isEmpty)
        XCTAssertFalse(txObj.chainId.isEmpty)
    }
    
    public func test_BuilderTestWithBigInteger() throws {
        let txObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(BigInt(hex: nonce)!)
            .setGas(BigInt(hex: gas)!)
            .setGasPrice(BigInt(hex: gasPrice)!)
            .setChainId(BigInt(hex: chainID)!)
            .setFrom(from)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeeRatio(feeRatio)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .build()
        
        XCTAssertNotNil(txObj)
        
        XCTAssertEqual(gas, txObj.gas)
        XCTAssertEqual(gasPrice, txObj.gasPrice)
        XCTAssertEqual(chainID, txObj.chainId)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
        
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_setFeePayerSignatures_missingFeePayer() throws {
        let feePayer = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feePayer is missing: feePayer must be defined with feePayerSignatures."))
        }
    }
    
    public func test_throwException_missingAccount() throws {
        let account: Account? = nil
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("account is missing."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101)
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio.Builder()
                                .setFrom(from)
                                .setGas(gas)
                                .setGasPrice(gasPrice)
                                .setNonce(nonce)
                                .setAccount(account)
                                .setSignatures(senderSignature)
                                .setFeeRatio(feeRatio)
                                .setFeePayer(feePayer)
                                .setFeePayerSignatures(feePayerSignatureData)
                                .setChainId(chainID)
                                .build()) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_createInstance: XCTestCase {
    let from = "0xfb675bea5c3fa279fd21572161b6b6b2dbd84233"
    let account = Account.createWithAccountKeyLegacy("0xfb675bea5c3fa279fd21572161b6b6b2dbd84233")
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = "0x30d40"
    let nonce = "0x0"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = "0x23bf3d4eb274621e56ce65f6fa05da9e24785bb8"
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let feeRatio = "0x1e"
    
    public func test_createInstance() throws {
        let txObj = try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )
        
        XCTAssertNotNil(txObj)
    }
    
    public func test_throwException_invalidFrom() throws {
        let from = "invalid Address"
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid address. : \(from)"))
        }
    }
    
    public func test_throwException_missingFrom() throws {
        let from = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("from is missing."))
        }
    }
    
    public func test_throwException_invalidGas() throws {
        let gas = "invalid gas"
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid gas. : \(gas)"))
        }
    }
    
    public func test_throwException_missingGas() throws {
        let gas = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("gas is missing."))
        }
    }
    
    public func test_throwException_missingAccount() throws {
        let account: Account? = nil
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("account is missing."))
        }
    }
    
    public func test_throwException_FeeRatio_invalid() throws {
        let feeRatio = "invalid fee ratio"
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid type of feeRatio: feeRatio should be number type or hex number string"))
        }
    }
    
    public func test_throwException_FeeRatio_outOfRange() throws {
        let feeRatio = BigInt(101).hexa
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid feeRatio: feeRatio is out of range. [1,99]"))
        }
    }
    
    public func test_throwException_missingFeeRatio() throws {
        let feeRatio = ""
        XCTAssertThrowsError(try FeeDelegatedAccountUpdateWithRatio(
            nil,
            from,
            nonce,
            gas,
            gasPrice,
            chainID,
            nil,
            feePayer,
            nil,
            feeRatio,
            account
        )) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("feeRatio is missing."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_getRLPEncodingTest: XCTestCase {
    let from = FeeDelegatedAccountUpdateWithRatioTest.from
    let account = FeeDelegatedAccountUpdateWithRatioTest.account
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = FeeDelegatedAccountUpdateWithRatioTest.gas
    let nonce = FeeDelegatedAccountUpdateWithRatioTest.nonce
    let gasPrice = FeeDelegatedAccountUpdateWithRatioTest.gasPrice
    let chainID = FeeDelegatedAccountUpdateWithRatioTest.chainID
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = FeeDelegatedAccountUpdateWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let feeRatio = FeeDelegatedAccountUpdateWithRatioTest.feeRatio
    
    let expectedRLPEncoding = FeeDelegatedAccountUpdateWithRatioTest.expectedRLPEncoding
        
    public func test_getRLPEncoding() throws {
        let expectedDataList = try FeeDelegatedAccountUpdateWithRatioTest.getExpectedDataList()
        try expectedDataList.forEach {
            let txObj = try $0.builder.build()
            XCTAssertEqual($0.expectedRLPEncoding, try txObj.getRLPEncoding())
        }
    }
    
    public func test_throwException_NoNonce() throws {
        let txObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeeRatio(feeRatio)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NoGasPrice() throws {
        let txObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setGas(gas)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeeRatio(feeRatio)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .build()
        
        XCTAssertThrowsError(try txObj.getRLPEncoding()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_signAsFeePayer_OneKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var keyring: AbstractKeyring?
    
    let privateKey = "0x45a915e4d060149eb4365960e6a7a45f334393093061116b197e3240065ff2d8"
    let feePayerPrivateKey = "0xb9d5558443585bca6f225b935950e3f6e69f9da8a5809a83f51c3365dff53936"
        
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    var account: Account?
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = "0xf4240"
    let nonce = "0x4d2"
    let gasPrice = "0x19"
    let chainID = "0x1"
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = BigInt(30)
    let senderSignature = SignatureData(
        "0x26",
        "0xe5929f96dec2b41343a9e6f0150eef08741fe7dcece88cc5936c49ed19051dc",
        "0x5a07b07017190e0baba32bdf6352f5a358a2798ed3c56e704a63819b87cf8e3f"
    )
    let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    let feePayerSignatureData = SignatureData(
        "0x26",
        "0xf295cd69b4144d9dbc906ba144933d2cc535d9d559f7a92b4672cc5485bf3a60",
        "0x784b8060234ffd64739b5fc2f2503939340ab4248feaa6efcf62cb874345fe40"
    )
    
    let expectedRLPEncoding = "0x22f8e58204d219830f424094a94f5374fce5edbc8e2a8697c15331677e6ebf0ba302a1033a514176466fa815ed481ffad09110a2d344f6c9b78c1d14afc351c3a51be33d1ef845f84326a00e5929f96dec2b41343a9e6f0150eef08741fe7dcece88cc5936c49ed19051dca05a07b07017190e0baba32bdf6352f5a358a2798ed3c56e704a63819b87cf8e3f945a0043070275d9f6054307ee7348bd660849d90ff845f84326a0cf8d102de7c6b0a41d3f02aefb7e419522341734c98af233408298d0c424c04ba00286f89cab4668f728d7c269997116a49b80cec8776fc64e60588a9268571e35"
        
    override func setUpWithError() throws {
        let sender = try PrivateKey(privateKey)
        account = Account.createWithAccountKeyPublic(sender.getDerivedAddress(), try sender.getPublicKey())
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
        
        keyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        klaytnWalletKey = try keyring?.getKlaytnWalletKey()
    }
    
    public func test_signAsFeePayer_KlaytnWalletKey() throws {
        _ = try mTxObj!.signAsFeePayer(klaytnWalletKey!)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signAsFeePayer_Keyring() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0, TransactionHasher.getHashForFeePayerSignature(_:))
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signAsFeePayer_Keyring_NoSigner() throws {
        _ = try mTxObj!.signAsFeePayer(keyring!, 0)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signAsFeePayer_multipleKey() throws {
        let keyArr = [
            PrivateKey.generate().privateKey,
            feePayerPrivateKey,
            PrivateKey.generate().privateKey
        ]
        let keyring = try KeyringFactory.createWithMultipleKey(feePayer, keyArr)
        _ = try mTxObj!.signAsFeePayer(keyring, 1)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_signAsFeePayer_roleBasedKey() throws {
        let keyArr = [
            [
                PrivateKey.generate().privateKey,
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey
            ],
            [
                PrivateKey.generate().privateKey,
                feePayerPrivateKey
            ]
        ]
        let roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(feePayer, keyArr)
        _ = try mTxObj!.signAsFeePayer(roleBasedKeyring, 1)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(expectedRLPEncoding, try mTxObj?.getRawTransaction())
    }
    
    public func test_throwException_NotMatchAddress() throws {
        XCTAssertThrowsError(try mTxObj!.sign(keyring!)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The from address of the transaction is different with the address of the keyring to use"))
        }
    }
    
    public func test_throwException_InvalidIndex() throws {
        let role = try AccountUpdateTest.generateRoleBaseKeyring([3,3,3], from)
        
        XCTAssertThrowsError(try mTxObj!.sign(role, 4)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("Invalid index : index must be less than the length of the key."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_signAsFeePayer_AllKeyTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var singleKeyring, multipleKeyring, roleBasedKeyring: AbstractKeyring?
        
    let privateKey = FeeDelegatedAccountUpdateWithRatioTest.privateKey
    let feePayerPrivateKey = FeeDelegatedAccountUpdateWithRatioTest.feePayerPrivateKey
        
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    var account: Account?
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = "0xf4240"
    let nonce = "0x4d2"
    let gasPrice = "0x19"
    let chainID = "0x1"
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = "0x14"
    let senderSignature = SignatureData(
        "0x26",
        "0xab69d9adca15d9763c4ce6f98b35256717c6e932007658f19c5a255de9e70dda",
        "0x26aa676a3a1a6e96aff4a3df2335788d614d54fb4db1c3c48551ce1fa7ac5e52"
    )
    let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
        
    override func setUpWithError() throws {
        account = Account.createWithAccountKeyFail(from)
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
        
        singleKeyring = try KeyringFactory.createWithSingleKey(feePayer, feePayerPrivateKey)
        multipleKeyring = try KeyringFactory.createWithMultipleKey(feePayer, KeyringFactory.generateMultipleKeys(8))
        roleBasedKeyring = try KeyringFactory.createWithRoleBasedKey(feePayer, KeyringFactory.generateRoleBasedKeys([3,4,5]))
    }

    public func test_signWithKeys_singleKeyring() throws {
        _ = try mTxObj!.signAsFeePayer(singleKeyring!, TransactionHasher.getHashForFeePayerSignature(_:))
        XCTAssertEqual(1, mTxObj?.signatures.count)
    }

    public func test_signWithKeys_singleKeyring_NoSigner() throws {
        _ = try mTxObj!.signAsFeePayer(singleKeyring!)
        XCTAssertEqual(1, mTxObj?.feePayerSignatures.count)
    }

    public func test_signWithKeys_multipleKeyring() throws {
        _ = try mTxObj!.signAsFeePayer(multipleKeyring!)
        XCTAssertEqual(8, mTxObj?.feePayerSignatures.count)
    }

    public func test_signWithKeys_roleBasedKeyring() throws {
        _ = try mTxObj!.signAsFeePayer(roleBasedKeyring!)
        XCTAssertEqual(5, mTxObj?.feePayerSignatures.count)
    }

    public func test_throwException_NotMatchAddress() throws {
        let keyring = try KeyringFactory.createFromPrivateKey(PrivateKey.generate().privateKey)
        XCTAssertThrowsError(try mTxObj!.signAsFeePayer(keyring)) {
            XCTAssertEqual($0 as? CaverError, CaverError.IllegalArgumentException("The feePayer address of the transaction is different with the address of the keyring to use."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_appendFeePayerSignaturesTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedAccountUpdateWithRatioTest.privateKey
    let feePayerPrivateKey = FeeDelegatedAccountUpdateWithRatioTest.feePayerPrivateKey
        
    let from = "0xa94f5374Fce5edBC8E2a8697C15331677e6EbF0B"
    var account: Account?
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = "0xf4240"
    let nonce = "0x4d2"
    let gasPrice = "0x19"
    let chainID = "0x1"
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = "0x1e"
    let senderSignature = SignatureData(
        "0x26",
        "0xab69d9adca15d9763c4ce6f98b35256717c6e932007658f19c5a255de9e70dda",
        "0x26aa676a3a1a6e96aff4a3df2335788d614d54fb4db1c3c48551ce1fa7ac5e52"
    )
    let feePayer = "0x5A0043070275d9f6054307Ee7348bD660849D90f"
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    
    override func setUpWithError() throws {
        account = Account.createWithAccountKeyFail(from)
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
        
        coupledKeyring = try KeyringFactory.createFromPrivateKey(privateKey)
        deCoupledKeyring = try KeyringFactory.createWithSingleKey(PrivateKey.generate().getDerivedAddress(), privateKey)
        klaytnWalletKey = try coupledKeyring?.getKlaytnWalletKey()
    }
    
    public func test_appendFeePayerSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendFeePayerSignatures(signatureData)
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_appendFeePayerSignatureList() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendFeePayerSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_appendFeePayerSignatureList_EmptySig() throws {
        let emptySignature = SignatureData.getEmptySignature()
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setAccount(account)
            .setFeePayerSignatures(emptySignature)
            .setFeeRatio(feeRatio)
            .build()
        
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        try mTxObj!.appendFeePayerSignatures([signatureData])
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_appendFeePayerSignature_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setAccount(account)
            .setFeePayerSignatures(signatureData)
            .setFeeRatio(feeRatio)
            .build()
        
        let signatureData1 = SignatureData(
            "0x0fea",
            "0x7a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0x23ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        try mTxObj!.appendFeePayerSignatures([signatureData1])
        XCTAssertEqual(2, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.feePayerSignatures[1])
    }
    
    public func test_appendSignatureList_ExistedSignature() throws {
        let signatureData = SignatureData(
            "0x0fea",
            "0xade9480f584fe481bf070ab758ecc010afa15debc33e1bd75af637d834073a6e",
            "0x38160105d78cef4529d765941ad6637d8dcf6bd99310e165fee1c39fff2aa27e"
        )
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setFrom(from)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setAccount(account)
            .setFeePayerSignatures(signatureData)
            .setFeeRatio(feeRatio)
            .build()
        
        let signatureData1 = SignatureData(
            "0x0fea",
            "0x7a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0x23ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        let signatureData2 = SignatureData(
            "0x0fea",
            "0x9a5011b41cfcb6270af1b5f8aeac8aeabb1edb436f028261b5add564de694700",
            "0xa3ac51660b8b421bf732ef8148d0d4f19d5e29cb97be6bccb5ae505ebe89eb4a"
        )
        
        try mTxObj!.appendFeePayerSignatures([signatureData1, signatureData2])
        XCTAssertEqual(3, mTxObj?.feePayerSignatures.count)
        XCTAssertEqual(signatureData, mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(signatureData1, mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(signatureData2, mTxObj?.feePayerSignatures[2])
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_combineSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedAccountUpdateWithRatioTest.privateKey
    let from = "0x610a4bf32905c1dc6e5e61c37165b9aa3a718908"
    var account: Account?
    let to = "0x8723590d5D60e35f7cE0Db5C09D3938b26fF80Ae"
    let gas = "0x186a0"
    let nonce = "0x1"
    let gasPrice = "0x5d21dba00"
    let chainID = "0x7e3"
    let value = BigInt(1)
    let input = "0x68656c6c6f"
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = BigInt(30)
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = FeeDelegatedAccountUpdateWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedAccountUpdateWithRatioTest.expectedRLPEncoding
    
    override func setUpWithError() throws {
        account = Account.createWithAccountKeyLegacy(from)
                
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
    }
    
    public func test_combineSignature() throws {
        let expectedRLPEncoded = "0x22f887018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef847f845820feaa03f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188a03e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = SignatureData(
            "0x0fea",
            "0x3f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188",
            "0x3e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e"
        )
        
        let rlpEncoded = "0x22f887018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef847f845820feaa03f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188a03e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e940000000000000000000000000000000000000000c4c3018080"
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.signatures[0])
    }
    
    public func test_combine_multipleSignature() throws {
        let expectedRLPEncoded = "0x22f90115018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef8d5f845820feaa03f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188a03e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781ef845820fe9a08094b2512daf27c211292cf2bdecca13733065070d5f61433a5d6702b864ee4aa02e86ee64c66859f8bc0b9c750c8b5ea0cc79a03cdbf9b78ca5db9c4ab6926b25f845820feaa034cda207b780c1defd54138f1d071f5d0e82160decf46c8d182f5f7aac341c32a003e174ed4357afebaa26c5c6c61c660c9bb130027d53f8cafb3a27f54273c3fd940000000000000000000000000000000000000000c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                "0x0fea",
                "0x3f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188",
                "0x3e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e"
            ),
            SignatureData(
                "0x0fe9",
                "0x8094b2512daf27c211292cf2bdecca13733065070d5f61433a5d6702b864ee4a",
                "0x2e86ee64c66859f8bc0b9c750c8b5ea0cc79a03cdbf9b78ca5db9c4ab6926b25"
            ),
            SignatureData(
                "0x0fea",
                "0x34cda207b780c1defd54138f1d071f5d0e82160decf46c8d182f5f7aac341c32",
                "0x03e174ed4357afebaa26c5c6c61c660c9bb130027d53f8cafb3a27f54273c3fd"
            )
        ]
        
        let rlpEncodedString = [
            "0x22f873018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef847f845820fe9a08094b2512daf27c211292cf2bdecca13733065070d5f61433a5d6702b864ee4aa02e86ee64c66859f8bc0b9c750c8b5ea0cc79a03cdbf9b78ca5db9c4ab6926b2580c4c3018080",
            "0x22f873018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef847f845820feaa034cda207b780c1defd54138f1d071f5d0e82160decf46c8d182f5f7aac341c32a003e174ed4357afebaa26c5c6c61c660c9bb130027d53f8cafb3a27f54273c3fd80c4c3018080"
        ]
        
        let senderSignature = SignatureData(
            "0x0fea",
            "0x3f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188",
            "0x3e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e"
        )
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
    }
    
    public func test_combineSignature_feePayerSignature() throws {
        let expectedRLPEncoded = "0x22f887018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ec4c301808094a317526534d82b902e86c960e037ede7b83af824f847f845820fe9a071487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9a04d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2"
        
        let expectedSignature = SignatureData(
            "0x0fe9",
            "0x71487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9",
            "0x4d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2"
        )
        
        let rlpEncoded = "0x22f887018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ec4c301808094a317526534d82b902e86c960e037ede7b83af824f847f845820fe9a071487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9a04d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2"
        
        let feePayer = "0xa317526534d82b902e86c960e037ede7b83af824"
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFeePayer(feePayer)
            .setChainId(chainID)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions([rlpEncoded])
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature, mTxObj?.feePayerSignatures[0])
    }
    
    public func test_combineSignature_multipleFeePayerSignature() throws {
        let expectedRLPEncoded = "0x22f90115018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ec4c301808094a317526534d82b902e86c960e037ede7b83af824f8d5f845820fe9a071487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9a04d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2f845820fe9a0d7e460da9cd48d780a71a8005b0bb5a6d6009786af55151f3388e42499b70e37a078643c2eca2711a2f776d9558fc2d8cf1a2f905647bbb0ffbab34b046ba9a141f845820fe9a03a8484bbfde6d139cc886e9a253648f50b5b435f1049725f1e52da8f2b3ca765a004149af877984cfd0f3756b7e46ea8dd6a5f47de504c852d607adbdb67fa17fa"
        
        let expectedSignature = [
            SignatureData(
                "0x0fe9",
                "0x71487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9",
                "0x4d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2"
            ),
            SignatureData(
                "0x0fe9",
                "0xd7e460da9cd48d780a71a8005b0bb5a6d6009786af55151f3388e42499b70e37",
                "0x78643c2eca2711a2f776d9558fc2d8cf1a2f905647bbb0ffbab34b046ba9a141"
            ),
            SignatureData(
                "0x0fe9",
                "0x3a8484bbfde6d139cc886e9a253648f50b5b435f1049725f1e52da8f2b3ca765",
                "0x04149af877984cfd0f3756b7e46ea8dd6a5f47de504c852d607adbdb67fa17fa"
            )
        ]
        
        let rlpEncodedString = [
            "0x22f887018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ec4c301808094a317526534d82b902e86c960e037ede7b83af824f847f845820fe9a0d7e460da9cd48d780a71a8005b0bb5a6d6009786af55151f3388e42499b70e37a078643c2eca2711a2f776d9558fc2d8cf1a2f905647bbb0ffbab34b046ba9a141",
            "0x22f887018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ec4c301808094a317526534d82b902e86c960e037ede7b83af824f847f845820fe9a03a8484bbfde6d139cc886e9a253648f50b5b435f1049725f1e52da8f2b3ca765a004149af877984cfd0f3756b7e46ea8dd6a5f47de504c852d607adbdb67fa17fa"
        ]
        
        let feePayer = "0xa317526534d82b902e86c960e037ede7b83af824"
        let feePayerSignatureData = SignatureData(
            "0x0fe9",
            "0x71487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9",
            "0x4d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2"
        )
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setFeePayer(feePayer)
            .setChainId(chainID)
            .setAccount(account)
            .setFeePayerSignatures(feePayerSignatureData)
            .setFeeRatio(feeRatio)
            .build()
        
        let combined = try mTxObj!.combineSignedRawTransactions(rlpEncodedString)
        XCTAssertEqual(expectedRLPEncoded, combined)
        XCTAssertEqual(expectedSignature[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_multipleSignature_senderSignature_feePayerSignature() throws {
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncodedString = "0x22f90101018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef8d5f845820feaa03f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188a03e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781ef845820fe9a08094b2512daf27c211292cf2bdecca13733065070d5f61433a5d6702b864ee4aa02e86ee64c66859f8bc0b9c750c8b5ea0cc79a03cdbf9b78ca5db9c4ab6926b25f845820feaa034cda207b780c1defd54138f1d071f5d0e82160decf46c8d182f5f7aac341c32a003e174ed4357afebaa26c5c6c61c660c9bb130027d53f8cafb3a27f54273c3fd80c4c3018080"
        
        let expectedSignature = [
            SignatureData(
                "0x0fea",
                "0x3f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188",
                "0x3e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e"
            ),
            SignatureData(
                "0x0fe9",
                "0x8094b2512daf27c211292cf2bdecca13733065070d5f61433a5d6702b864ee4a",
                "0x2e86ee64c66859f8bc0b9c750c8b5ea0cc79a03cdbf9b78ca5db9c4ab6926b25"
            ),
            SignatureData(
                "0x0fea",
                "0x34cda207b780c1defd54138f1d071f5d0e82160decf46c8d182f5f7aac341c32",
                "0x03e174ed4357afebaa26c5c6c61c660c9bb130027d53f8cafb3a27f54273c3fd"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedString])
        
        let rlpEncodedStringsWithFeePayerSignatures = "0x22f90115018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ec4c301808094a317526534d82b902e86c960e037ede7b83af824f8d5f845820fe9a071487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9a04d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2f845820fe9a0d7e460da9cd48d780a71a8005b0bb5a6d6009786af55151f3388e42499b70e37a078643c2eca2711a2f776d9558fc2d8cf1a2f905647bbb0ffbab34b046ba9a141f845820fe9a03a8484bbfde6d139cc886e9a253648f50b5b435f1049725f1e52da8f2b3ca765a004149af877984cfd0f3756b7e46ea8dd6a5f47de504c852d607adbdb67fa17fa"
        
        let expectedFeePayerSignatures = [
            SignatureData(
                "0x0fe9",
                "0x71487ff3f9d01d0bbec812339ff775a7129a0311b2039e8cbf113be48f2fa3d9",
                "0x4d4d0bcb2c9e4468de70645a5a818d9304ec2f8c75497fa092eb3cc8e7fe94d2"
            ),
            SignatureData(
                "0x0fe9",
                "0xd7e460da9cd48d780a71a8005b0bb5a6d6009786af55151f3388e42499b70e37",
                "0x78643c2eca2711a2f776d9558fc2d8cf1a2f905647bbb0ffbab34b046ba9a141"
            ),
            SignatureData(
                "0x0fe9",
                "0x3a8484bbfde6d139cc886e9a253648f50b5b435f1049725f1e52da8f2b3ca765",
                "0x04149af877984cfd0f3756b7e46ea8dd6a5f47de504c852d607adbdb67fa17fa"
            )
        ]
        
        _ = try mTxObj!.combineSignedRawTransactions([rlpEncodedStringsWithFeePayerSignatures])
        
        XCTAssertEqual(expectedSignature[0], mTxObj?.signatures[0])
        XCTAssertEqual(expectedSignature[1], mTxObj?.signatures[1])
        XCTAssertEqual(expectedSignature[2], mTxObj?.signatures[2])
        
        XCTAssertEqual(expectedFeePayerSignatures[0], mTxObj?.feePayerSignatures[0])
        XCTAssertEqual(expectedFeePayerSignatures[1], mTxObj?.feePayerSignatures[1])
        XCTAssertEqual(expectedFeePayerSignatures[2], mTxObj?.feePayerSignatures[2])
    }
    
    public func test_throwException_differentField() throws {
        let gas = "0x1000"
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setNonce(nonce)
            .setFrom(from)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setChainId(chainID)
            .setAccount(account)
            .setFeeRatio(feeRatio)
            .build()
        
        let rlpEncoded = "0x22f873018505d21dba00830186a094610a4bf32905c1dc6e5e61c37165b9aa3a7189088201c01ef847f845820feaa03f34007147ba1c9184d51b7dfacae768ae00c859b4726ef339502e98d44ec188a03e518e277769ba02d57c8c7fab291abab61e2525735500402e78a1493e48781e80c4c3018080"
        
        XCTAssertThrowsError(try mTxObj!.combineSignedRawTransactions([rlpEncoded])) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("Transactions containing different information cannot be combined."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_getRawTransactionTest: XCTestCase {
    public func test_getRawTransaction() throws {
        let expectedDataList = try FeeDelegatedAccountUpdateWithRatioTest.getExpectedDataList()
        try expectedDataList.forEach {
            let txObj = try $0.builder.build()
            XCTAssertEqual($0.expectedRLPEncoding, try txObj.getRawTransaction())
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_getTransactionHashTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedAccountUpdateWithRatioTest.privateKey
    let from = FeeDelegatedAccountUpdateWithRatioTest.from
    let account = FeeDelegatedAccountUpdateWithRatioTest.account
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = FeeDelegatedAccountUpdateWithRatioTest.gas
    let nonce = FeeDelegatedAccountUpdateWithRatioTest.nonce
    let gasPrice = FeeDelegatedAccountUpdateWithRatioTest.gasPrice
    let chainID = FeeDelegatedAccountUpdateWithRatioTest.chainID
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = FeeDelegatedAccountUpdateWithRatioTest.feeRatio
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = FeeDelegatedAccountUpdateWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedAccountUpdateWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedAccountUpdateWithRatioTest.expectedTransactionHash
            
    public func test_getTransactionHash() throws {
        let expectedDataList = try FeeDelegatedAccountUpdateWithRatioTest.getExpectedDataList()
        try expectedDataList.forEach {
            let txObj = try $0.builder.build()
            XCTAssertEqual($0.expectedTransactionHash, try txObj.getTransactionHash())
        }
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getTransactionHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_getSenderTxHashTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedAccountUpdateWithRatioTest.privateKey
    let from = FeeDelegatedAccountUpdateWithRatioTest.from
    let account = FeeDelegatedAccountUpdateWithRatioTest.account
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = FeeDelegatedAccountUpdateWithRatioTest.gas
    let nonce = FeeDelegatedAccountUpdateWithRatioTest.nonce
    let gasPrice = FeeDelegatedAccountUpdateWithRatioTest.gasPrice
    let chainID = FeeDelegatedAccountUpdateWithRatioTest.chainID
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = FeeDelegatedAccountUpdateWithRatioTest.feeRatio
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = FeeDelegatedAccountUpdateWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedAccountUpdateWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedAccountUpdateWithRatioTest.expectedTransactionHash
            
    public func test_getRLPEncodingForSignature() throws {
        let expectedDataList = try FeeDelegatedAccountUpdateWithRatioTest.getExpectedDataList()
        try expectedDataList.forEach {
            let txObj = try $0.builder.build()
            XCTAssertEqual($0.expectedSenderTransactionHash, try txObj.getSenderTxHash())
        }
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getSenderTxHash()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}

class FeeDelegatedAccountUpdateWithRatioTest_getRLPEncodingForFeePayerSignatureTest: XCTestCase {
    var mTxObj: FeeDelegatedAccountUpdateWithRatio?
    var klaytnWalletKey: String?
    var coupledKeyring: AbstractKeyring?
    var deCoupledKeyring: AbstractKeyring?
    
    let privateKey = FeeDelegatedAccountUpdateWithRatioTest.privateKey
    let from = FeeDelegatedAccountUpdateWithRatioTest.from
    let account = FeeDelegatedAccountUpdateWithRatioTest.account
    let to = FeeDelegatedAccountUpdateWithRatioTest.to
    let gas = FeeDelegatedAccountUpdateWithRatioTest.gas
    let nonce = FeeDelegatedAccountUpdateWithRatioTest.nonce
    let gasPrice = FeeDelegatedAccountUpdateWithRatioTest.gasPrice
    let chainID = FeeDelegatedAccountUpdateWithRatioTest.chainID
    let value = FeeDelegatedAccountUpdateWithRatioTest.value
    let input = FeeDelegatedAccountUpdateWithRatioTest.input
    let humanReadable = FeeDelegatedAccountUpdateWithRatioTest.humanReadable
    let codeFormat = FeeDelegatedAccountUpdateWithRatioTest.codeFormat
    let feeRatio = FeeDelegatedAccountUpdateWithRatioTest.feeRatio
    let senderSignature = FeeDelegatedAccountUpdateWithRatioTest.senderSignature
    let feePayer = FeeDelegatedAccountUpdateWithRatioTest.feePayer
    let feePayerSignatureData = FeeDelegatedAccountUpdateWithRatioTest.feePayerSignatureData
    let expectedRLPEncoding = FeeDelegatedAccountUpdateWithRatioTest.expectedRLPEncoding
    let expectedTransactionHash = FeeDelegatedAccountUpdateWithRatioTest.expectedTransactionHash
    let expectedRLPEncodingForFeePayerSigning = FeeDelegatedAccountUpdateWithRatioTest.expectedRLPEncodingForFeePayerSigning
            
    public func test_getRLPEncodingForSignature() throws {
        let expectedDataList = try FeeDelegatedAccountUpdateWithRatioTest.getExpectedDataList()
        try expectedDataList.forEach {
            let txObj = try $0.builder.build()
            XCTAssertEqual($0.expectedRLPEncodingForFeePayerSigning, try txObj.getRLPEncodingForFeePayerSignature())
        }
    }
    
    public func test_throwException_NotDefined_Nonce() throws {
        let nonce = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("nonce is undefined. Define nonce in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_gasPrice() throws {
        let gasPrice = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("gasPrice is undefined. Define gasPrice in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
    
    public func test_throwException_NotDefined_chainID() throws {
        let chainID = ""
        
        mTxObj = try FeeDelegatedAccountUpdateWithRatio.Builder()
            .setFrom(from)
            .setAccount(account)
            .setGas(gas)
            .setGasPrice(gasPrice)
            .setNonce(nonce)
            .setAccount(account)
            .setSignatures(senderSignature)
            .setFeePayer(feePayer)
            .setFeePayerSignatures(feePayerSignatureData)
            .setChainId(chainID)
            .setFeeRatio(feeRatio)
            .build()
                
        XCTAssertThrowsError(try mTxObj!.getRLPEncodingForSignature()) {
            XCTAssertEqual($0 as? CaverError, CaverError.RuntimeException("chainId is undefined. Define chainId in transaction or use 'transaction.fillTransaction' to fill values."))
        }
    }
}


