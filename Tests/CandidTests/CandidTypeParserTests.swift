//
//  CandidParserTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import XCTest
@testable import Candid

final class CandidTypeParserTests: XCTestCase {
    let parser = CandidParser()
    
    func testParseSingleTypes() throws {
        for (input, candidType) in CandidTypeParserTestVectors.passingSingleTypes {
            XCTAssertEqual(try parser.parseSingleType(input), candidType, "Failed \(input)\nNot equal to \(candidType.syntax)")
        }
    }
    
    func testParseComments() throws {
        for (input) in CandidTypeParserTestVectors.comments {
            let stream = try CandidParserStream(string: input)
            var foundComments: [String] = []
            while stream.hasNext {
                let token = try stream.takeNext()
                if case .comment(let comment, _) = token {
                    foundComments.append(comment)
                }
            }
            XCTAssertTrue(foundComments.isEmpty)
        }
    }
    
    func testParseFunctionArgumentNames() throws {
        for (input, candidType, argNames, resNames) in CandidTypeParserTestVectors.functionArgumentNames {
            let parsed = try parser.parseSingleType(input)
            XCTAssertEqual(parsed, candidType, "\(input)\nNot equal to \(candidType.syntax)")
            guard case .function(let signature) = parsed else {
                XCTFail("not a function")
                return
            }
            XCTAssertEqual(signature.arguments.map { $0.name }, argNames)
            XCTAssertEqual(signature.results.map { $0.name }, resNames)
        }
    }
    
    func testParseFailingSingleType() throws {
        for input in CandidTypeParserTestVectors.failingSingleTypes {
            XCTAssertThrowsError(try parser.parseSingleType(input), "\(input)")
        }
    }
    
    func testDidFiles() async throws {
        for (did, namedTypes, service) in CandidTypeParserTestVectors.didFiles {
            let interface = try await parser.parseInterfaceDescription(did)
            XCTAssertEqual(interface.namedTypes, CandidInterfaceDefinition(namedTypes: namedTypes).namedTypes)
            XCTAssertEqual(interface.service, service)
            XCTAssertTrue(interface.isResolved())
        }
    }
    
    func testOriginalString() async throws {
        for (did, originalStrings) in CandidTypeParserTestVectors.originalStringDid {
            let interface = try await parser.parseInterfaceDescription(did)
            for namedType in interface.namedTypes {
                XCTAssertEqual(namedType.originalDefinition, originalStrings[namedType.name])
            }
        }
    }
    
    func testUnresolvedDidFiles() async throws {
        for did in CandidTypeParserTestVectors.unresolvedDidFiles {
            let interface = try await parser.parseInterfaceDescription(did)
            XCTAssertFalse(interface.isResolved(), did)
        }
    }
    
    func testFailingDidFiles() async throws {
        for did in CandidTypeParserTestVectors.failingDidFiles {
            do {
                _ = try await parser.parseInterfaceDescription(did)
                XCTFail()
            } catch {
                // pass
            }
        }
    }
    
    func testImports() async throws {
        for (main, files, types, service) in CandidTypeParserTestVectors.importedFiles {
            let provider = MockProvider(main, files)
            let interface = try await parser.parseInterfaceDescription(provider)
            XCTAssertEqual(interface.namedTypes, CandidInterfaceDefinition(namedTypes: types).namedTypes)
            XCTAssertEqual(interface.service, service)
            XCTAssertTrue(interface.isResolved())
        }
    }
    
    func testFailingImports() async throws {
        for (main, files) in CandidTypeParserTestVectors.failingImportedFiles {
            let provider = MockProvider(main, files)
            do {
                _ = try await parser.parseInterfaceDescription(provider)
                XCTFail()
            } catch {
                // pass
            }
        }
    }
    
    func testRealWorldExamples() async throws {
        for (source, nTypes, nMethods) in CandidTypeParserTestVectors.realWorldExamples {
            let service = try await parser.parseInterfaceDescription(source)
            XCTAssertEqual(service.namedTypes.count, nTypes)
            guard case .concrete(let serviceSig) = service.service?.signature else {
                XCTFail("no concrete service")
                return
            }
            XCTAssertEqual(serviceSig.methods.count, nMethods)
        }
    }
}

private class MockProvider: CandidInterfaceDefinitionProvider {
    let main: String
    let files: [String: String]
    init(_ main: String, _ files: [String : String]) {
        self.main = main
        self.files = files
    }
    
    func readMain() async throws -> String { main }
    
    func read(contentsOf file: String) async throws -> String {
        guard let contents = files[file] else { throw CandidParserError.unresolvedImport(file) }
        return contents
    }
}
