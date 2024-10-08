//
//  CandidSerialisationTestVectors.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 01.05.23.
//

import Foundation
@testable import Candid

enum CandidSerialisationTestVectors {
    static let singleValueTestVectors: [(CandidValue, [UInt8])] = [
        (.null, [0x00, 0x01, 0x7F]),
        (.bool(false), [0x00, 0x01, 0x7E, 0x00]),
        (.bool(true), [0x00, 0x01, 0x7E, 0x01]),
        (.natural(0), [0x00, 0x01, 0x7D, 0x00]),
        (.natural(1), [0x00, 0x01, 0x7D, 0x01]),
        (.natural(300), [0x00, 0x01, 0x7D, 0xAC, 0x02]),
        (.integer(-129), [0x00, 0x01, 0x7C, 0xFF, 0x7E]),
        (.natural8(5), [0x00, 0x01, 0x7B, 0x05]),
        (.natural16(5), [0x00, 0x01, 0x7A, 0x05, 0x00]),
        (.natural32(5), [0x00, 0x01, 0x79, 0x05, 0x00, 0x00, 0x00]),
        (.natural64(5), [0x00, 0x01, 0x78, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
        (.integer8(-5), [0x00, 0x01, 0x77, 0xfb]),
        (.integer16(-5), [0x00, 0x01, 0x76, 0xfB, 0xff]),
        (.integer32(-5), [0x00, 0x01, 0x75, 0xfB, 0xff, 0xff, 0xff]),
        (.integer64(-5), [0x00, 0x01, 0x74, 0xfB, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]),
        (.float32(-0.5), [0x00, 0x01, 0x73, 0x00, 0x00, 0x00, 0xbf]),
        (.float32(-0.768), [0x00, 0x01, 0x73, 0xa6, 0x9b, 0x44, 0xbf]),
        (.float64(-0.768), [0x00, 0x01, 0x72, 0xFA, 0x7E, 0x6A, 0xBC, 0x74, 0x93, 0xE8, 0xBF]),
        (.reserved, [0x00, 0x01, 0x70]),
        (.empty, [0x00, 0x01, 0x6F]),
        (.text("a"), [0x00, 0x01, 0x71, 0x01, 0x61]),
        (.text("%±§"), [0x00, 0x01, 0x71, 0x05, 0x25, 0xc2, 0xb1, 0xc2, 0xa7]),
        // 1 type in table, option, bool, 1 candidValue, value of type 0, null value
        (.option(.bool), [0x01, 0x6E, 0x7E, 0x01, 0x00, 0x00]),
        // 1 type in table, option, bool, 1 candidValue, value of type 0, non-null value, true
        (.option(.bool(true)), [0x01, 0x6E, 0x7E, 0x01, 0x00, 0x01, 0x01]),
        // 1 type in table, vector, bool, 1 candidValue, value of type 0, 0 elements
        (.vector(.bool), [0x01, 0x6D, 0x7E, 0x01, 0x00, 0x00]),
        // 1 type in table, vector, bool, 1 candidValue, value of type 0, 2 elements, true, false
        (try! .vector([.bool(true), .bool(false)]), [0x01, 0x6D, 0x7E, 0x01, 0x00, 0x02, 0x01, 0x00]),
        // 1 type in table, vector, nat8, 1 candidValue, value of type 0, 0 elements
        (.blob(Data()), [0x01, 0x6D, 0x7B, 0x01, 0x00, 0x00]),
        // 1 type in table, vector, nat8, 1 candidValue, value of type 0, 2 elements, 127, 128
        (.blob(Data([127, 128])), [0x01, 0x6D, 0x7B, 0x01, 0x00, 0x02, 0x7F, 0x80]),
        // 1 type in table, record, 0 rows, 1 candidValue, value of type 0,
        (.record([:]),[0x01, 0x6C, 0x00, 0x01, 0x00]),
        // 1 type in table, record, 1 row, leb(hash("a")), .empty, 1 candidValue, value of type 0,
        (.record(["a":.empty]),[0x01, 0x6C, 0x01, 97, 0x6F, 0x01, 0x00]),
        // 1 type in table, record, 2 rows, leb(hash("a")), .natural, leb(hash("b")), .natural8, 1 candidValue, value of type 0, 0x01, 0x02
        (.record(["a":.natural(1),"b":.natural8(2)]), [0x01, 0x6C, 0x02, 97, 0x7D, 98, 0x7B, 0x01, 0x00, 0x01, 0x02]),
        (.record([
            "a": .option(.bool(true)),
            "b": .option(.bool(false)),
        ]), [0x02, 0x6e, 0x7e, 0x6c, 0x02, 97, 0x00, 98, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00]),
        // 2 types in table, (0)vector, bool, (1)option, referencing type 0, 1 candidValue, value of type 1, option present, 2 values, true, false
        (.option(try! .vector([.bool(true), .bool(false)])), [0x02, 0x6D, 0x7E, 0x6E, 0x00, 0x01, 0x01, 0x01, 0x02, 0x01, 0x00]),
        // 3 types in table, (0)vector, nat8, (1) vector, ref 0, (2)option, ref 1, 1 candidValue, value of type 2, option present, 2 values, length 0, length 2, leb(127), leb(128)
        (.option(try! .vector([.blob(Data()), .blob(Data([127, 128]))])), [0x03, 0x6D, 0x7B, 0x6D, 0x00, 0x6E, 0x01, 0x01, 0x02, 0x01, 0x02, 0x00, 0x02, 0x7F, 0x80]),
        // 4 types in table, (0)vector, nat8, (1) vector, ref 0, (2) record, 2 keys, leb(hash("a")), ref 0, leb(hash("b")), ref 1, (3)option, ref 2, 1 candidValue, value of type 3, option present, length 1, 0x44, length 1, length 2, 0x45, 0x47
        (.option(.record([
            "a": .blob(Data([0x44])),
            "b": try! .vector([.blob(Data([0x45, 0x47]))] )
        ])), [4, 0x6D, 0x7B, 0x6D, 0, 0x6C, 2, 97, 0, 98, 1, 0x6E, 2, 0x01, 3, 1, 1, 0x44, 1, 2, 0x45, 0x47]),
        (.variant(try! CandidVariant(
            candidTypes: [
                ("a", .bool),
                ("b", .natural8),
                ("c", .vector(.natural8)),
            ],
            value: ("b", .natural8(15)))),
         // 2 types in table, (0) vector, nat8, (1) variant, 3 keys, leb(hash("a")), bool, leb(hash("b")), nat8, leb(hash("c")), type 0, 1 candidValue, type 1, row 1, 15
         [2, 0x6D, 0x7B, 0x6B, 3, 97, 0x7E, 98, 0x7B, 99, 0, 1, 1, 1, 0x0f]),
        
        (try! .principal("aaaaa-aa"), [0x00,0x01,0x68,0x01,0x00]),
        (try! .principal("w7x7r-cok77-xa"), [0x00,0x01,0x68,0x01,0x03, 0xca, 0xff, 0xee]),
        (try! .principal("2chl6-4hpzw-vqaaa-aaaaa-c"), [0x00,0x01,0x68,0x01,0x09, 0xef, 0xcd, 0xab, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]),
        
        (try! .function([], [], "w7x7r-cok77-xa", "a"), [0x01, 0x6a, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x01, 0x03, 0xca, 0xff, 0xee, 0x01, 0x61]),
        (try! .function([.principal], [.natural], "w7x7r-cok77-xa", "foo"), [0x01, 0x6a, 0x01, 0x68, 0x01, 0x7d, 0x00, 0x01, 0x00, 0x01, 0x01, 0x03, 0xca, 0xff, 0xee, 0x03] + foo),
        (try! .function([.text], [.natural], query: true, "w7x7r-cok77-xa", "foo"), [0x01, 0x6a, 0x01, 0x71, 0x01, 0x7d, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x03, 0xca, 0xff, 0xee, 0x03] + foo),
        (try! .function([.text], [.natural], compositeQuery: true, "w7x7r-cok77-xa", "foo"), [0x01, 0x6a, 0x01, 0x71, 0x01, 0x7d, 0x01, 0x03, 0x01, 0x00, 0x01, 0x01, 0x03, 0xca, 0xff, 0xee, 0x03] + foo),
        (try! .function([.integer, .natural],[.service()], query: true,"aaaaa-aa", "🐂"),[0x02, 0x69, 0x00, 0x6a, 0x02, 0x7c, 0x7d, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x04, 0xf0, 0x9f, 0x90, 0x82]),
        
        (try! .service([], "w7x7r-cok77-xa"), [0x01, 0x69, 0x00, 0x01, 0x00, 0x01, 0x03, 0xca, 0xff, 0xee]),
        (try! .service([.init("foo", [.text], [.natural])], "w7x7r-cok77-xa"), [0x02, 0x6a, 0x01, 0x71, 0x01, 0x7d, 0x00, 0x69, 0x01, 0x03] + foo + [0x00, 0x01, 0x01, 0x01, 0x03, 0xca, 0xff, 0xee]),
        (try! .service([.init("foo", [.text], [.natural]), .init("foo2", [.text], [.natural])], "w7x7r-cok77-xa"), [0x02, 0x6a, 0x01, 0x71, 0x01, 0x7d, 0x00, 0x69, 0x02, 0x03] + foo +  [0x00, 0x04] + foo + [0x32, 0x00, 0x01, 0x01, 0x01, 0x03, 0xca, 0xff, 0xee]),
    ]
    
    static let foo = Data("foo".utf8).bytes
    
    static let multipleValuesTestVectors: [([CandidValue], [UInt8])] = [
        ([], [0x00, 0x00]),
        ([.natural8(0), .natural8(1), .natural8(2)], [0x00, 0x03, 0x7B, 0x7B, 0x7B, 0, 1, 2]),
        ([.natural8(0), .natural16(258), .natural8(2)], [0x00, 0x03, 0x7B, 0x7A, 0x7B, 0, 2, 1, 2]),
        ([
            .option(.record([
                "a": .blob(Data([0x44])),
                "b": try! .vector([.blob(Data([0x45, 0x47]))] )
            ])),
            .record([
                "a": .blob(Data([0x43])),
                "b": try! .vector([.blob(Data([0x40, 0x41]))] )
            ]),
        // 4 types in table, (0)vector, nat8, (1) vector, ref 0, (2) record, 2 keys, leb(hash("a")), ref 0, leb(hash("b")), ref 1, (3)option, ref 2, 2 candidValues, value of type 3, value of type 2, option present, length 1, 0x44, length 1, length 2, 0x45, 0x47,  length 1, 0x43, length 1, length 2, 0x40, 0x41
         ], [4, 0x6D, 0x7B, 0x6D, 0, 0x6C, 2, 97, 0, 98, 1, 0x6E, 2, 0x02, 3, 2, 1, 1, 0x44, 1, 2, 0x45, 0x47, 1, 0x43, 1, 2, 0x40, 0x41]),
    ]
    
    static let recursiveExamples: [(CandidValue, String)] = [
        (.option(.named("0")), "016e00010000"),
        (.option(CandidValue.option(.named("0"))), "016e0001000100"),
        (.option(CandidValue.option(CandidValue.option(.named("0")))), "016e000100010100"),
        (.vector(.named("0")), "016d00010000"),
        (try! .vector([.vector(.named("0"))]), "016d0001000100"),
        (try! .vector([.vector([.vector(.named("0"))])]), "016d000100010100"),
        (.option(.named("1")), "026e016d00010000"),
        (.option(CandidValue.vector(.named("0"))), "026e016d0001000100"),
        (.option(try! CandidValue.vector([.option(.named("1"))])), "026e016d000100010100"),
        (.option(CandidType.vector(.bool)), "026e016d7e010000"),
        (.record([
            "a": .option(.named("1")),
        ]), "026c0161016e01010000"),
        (.record([
            "a": .option(CandidValue.option(.named("1"))),
        ]), "026c0161016e0101000100"),
        (.record([
            "a": .option(CandidValue.option(CandidValue.option(.named("1")))),
        ]), "026c0161016e010100010100"),
        (try! .variant([0: .named("0"), 1: .bool], .bool(false), 1), "016b020000017e01000100"),
        (try! .variant([0: .named("0"), 1: .bool], .variant([0: .named("0"),1: .bool], .bool(false), 1), 0), "016b020000017e0100000100"),
        (try! .variant([0: .named("0"), 1: .bool],
            .variant([0: .named("0"), 1: .bool],
                .variant([0: .named("0"),1: .bool], .bool(false), 1), 0), 0), "016b020000017e010000000100"),
    ]
    
    static let realWorldExamples: [String] = [
        // this example has a type table with forward references
        // eg. type 0 references type 1 which is defined later in the type table
        "4449444c076b02bc8a0178c5fed201016b05b79eb35d02a1c3ebfd0703c7c6b5f60a05cce5b6900f7feb9cdbd50f066c01a7a5f3cc0e786c01bf9bb7f00d046c01e0a9b302786c018bbdf29b01786c019cbab69c0204010001040000000000000000",
        // this example includes recursive definition
        "4449444c056d016c02007101026b06cf89df017cfc84eb0100c189ee017dfdd2c9df0204cdf1cbbe0371f9baf3c50b036d026d7b0100051169637263373a6465736372697074696f6e04034e2f410a69637263373a6e616d65041b78796f326f2d67796161612d616161616c2d71623535612d6361690c69637263373a73796d626f6c041b78796f326f2d67796161612d616161616c2d71623535612d6361691269637263373a746f74616c5f737570706c79023d0a69637263373a6c6f676f0400",
    ]
}
