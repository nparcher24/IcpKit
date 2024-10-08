//
//  CandidSerialisationTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 28.04.23.
//

import XCTest
@testable import Candid

final class CandidSerialisationTests: XCTestCase {
    let serialiser = CandidSerialiser()
    let deserialiser = CandidDeserialiser()
    
    func testSerialiseDeserialiseSingleValues() throws {
        let testVectors = CandidSerialisationTestVectors.singleValueTestVectors
        for (value, expected) in testVectors {
            let encoded = serialiser.encode(value)
            XCTAssertEqual(encoded, CandidSerialiser.magicBytes + Data(expected), "\(value) --expected \(Data(expected).hex) -- got -- \(encoded.hex)")
            let decoded = try deserialiser.decode(encoded)
            XCTAssertEqual(value, decoded.first)
        }
    }
    
    func testSerialiseDeserialiseMultipleValues() throws {
        let testVectors = CandidSerialisationTestVectors.multipleValuesTestVectors
        for (value, expected) in testVectors {
            let encoded = serialiser.encode(value)
            XCTAssertEqual(encoded, CandidSerialiser.magicBytes + Data(expected), "\(value) --expected \(Data(expected).hex) -- got -- \(encoded.hex)")
            let decoded = try deserialiser.decode(encoded)
            XCTAssertEqual(value, decoded)
        }
    }
    
    func testRealWorldExamples() throws {
        for input in CandidSerialisationTestVectors.realWorldExamples {
            let data = Data.fromHex(input)!
            do {
                let decoded = try self.deserialiser.decode(data)
                print(decoded)
            } catch (let error) {
                XCTFail("failed to deserialise with error \(error)")
            }
        }
    }
    
    func testRecursive() throws {
        for (expected, hex) in CandidSerialisationTestVectors.recursiveExamples {
            let data = CandidSerialiser.magicBytes + Data.fromHex(hex)!
            let deserialised = try deserialiser.decode(data).first!
            XCTAssertEqual(deserialised, expected)
        }
    }
    
    func testDictionaryKeyHash() {
        let testVectors: [(String, Int)] = [
            ("a", 97),
            ("b", 98),
            ("c", 99),
            ("ab", 21729),
            ("ba", 21951),
            ("ac", 21730),
            ("abcd %§±`~", 1687702841),
            (String(repeating: "abcd", count: 1000), 3277195728),
        ]
        for (string, expectedHash) in testVectors {
            let hashed = CandidKey.candidHash(string)
            XCTAssertEqual(hashed, expectedHash)
        }
    }
    
    func testFunctionReferenceRealWorld() throws {
        // this example contains several function references
        let candidData = Data.fromHex("4449444c196c0597928bda010186dda8bf0a03a4c7a8ce0c7891fb95920d7883f4f4c40f106e026d7b6d046c03dec389dc0405d6a9bbae0a0bc39c99ad0f016c04ba89e5c2047893a6c6900901a78882820a0682f3f3910c0b6e076b05adfaedfb0108ef80e5df020cc2f5d599030dcbd6fda00b0ed5fce8ea0e0f6c05c6fcb60209eaca8a9e0402b98792ea077cdea7f7da0d0acb96dcb40e026c01e0a9b302786e0b6c01d6f68e8001786c02eaca8a9e0402d8a38ca80d096c02fbca0102d8a38ca80d096c04fbca0102c6fcb60209eaca8a9e0402d8a38ca80d096c05fbca0102c6fcb60209eaca8a9e0402d8a38ca80d09cb96dcb40e026d116c03c5b39af80712e2e8ada00878e6a99ef809786a0113011401016c02e2e8ada00878e6a99ef809786b02bc8a0115c5fed201166c0186dda8bf0a036b02b0ad8cd40417b0ad8fcd0c186c02c1a482a6057880d5dbdd05786c0290c6c1960571c498b1b50d78010000010000000000000000000103207750c79b3d0ef35a5ffc3fc1b350d84575ae5f76d763271bb815fe6c6c2350c6102700000000000020cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c102700000000000000844208c55e5f17f9def690c55e5f170120fb34cfdac368b0d0853f8783dfb1776659c6ff3fdee5e9394db050523a5dd6efaa655d0000000000b9625d000000000000")!
        
        XCTAssertNoThrow(try deserialiser.decode(candidData))
    }
}
