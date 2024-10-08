//
//  CandidInterfaceDefinitionProvider.swift
//  
//
//  Created by Konstantinos Gaitanis on 30.07.24.
//

import Foundation

/// Used by the `CandidParser` to process `import` statements.
public protocol CandidInterfaceDefinitionProvider {
    /// - Returns: The contents of the main `.did` file to parse
    func readMain() async throws -> String
    
    /// Returns the contents of a `.did` file
    /// - Parameter file: The filename.
    /// - Returns: The contents of the filename
    func read(contentsOf file: String) async throws -> String
}

public class FileCandidInterfaceDefinitionProvider: CandidInterfaceDefinitionProvider {
    public let mainFile: URL
    public let workingPath: String
    
    public init(workingPath: String, mainFile: String) {
        self.workingPath = workingPath
        self.mainFile = URL(filePath: workingPath).appending(path: mainFile)
    }
    
    public func readMain() async throws -> String {
        let contents = try String(contentsOf: mainFile)
        return contents
    }
    
    public func read(contentsOf file: String) async throws -> String {
        let path = mainFile.deletingLastPathComponent().appending(path: file)
        let contents = try String(contentsOf: path)
        return contents
    }
}
