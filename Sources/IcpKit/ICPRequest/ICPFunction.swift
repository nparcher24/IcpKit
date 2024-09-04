//
//  ICPFunction.swift
//
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation
import Candid
import os

public extension CandidFunctionProtocol {
    init(_ canister: ICPPrincipal, _ method: String) {
        self.init(CandidPrincipal(canister.bytes), method)
    }
    
    var icpPrincipal: ICPPrincipal { ICPPrincipal(canister) }
}

public class ICPFunction<Argument, Result, Query: StaticBool>: CandidFunctionProtocol {
    public let canister: CandidPrincipal
    public let methodName: String
    public var query: Bool { Query.value }
    
    
    public required init(_ canister: CandidPrincipal, _ method: String) {
        self.canister = canister
        self.methodName = method
    }
}

public typealias ICPFunctionNoArgsNoResult<Query: StaticBool> = ICPFunction<Void, Void, Query>
public typealias ICPFunctionNoArgs<Result, Query: StaticBool> = ICPFunction<Void, Result, Query>
public typealias ICPFunctionNoResult<Argument, Query: StaticBool> = ICPFunction<Argument, Void, Query>

public typealias ICPQueryNoArgsNoResult = ICPFunctionNoArgsNoResult<StaticTrue>
public typealias ICPQueryNoArgs<Result> = ICPFunctionNoArgs<Result, StaticTrue>
public typealias ICPQueryNoResult<Argument> = ICPFunctionNoResult<Argument, StaticTrue>
public typealias ICPQuery<Argument, Result> = ICPFunction<Argument, Result, StaticTrue>

public typealias ICPCallNoArgsNoResult = ICPFunctionNoArgsNoResult<StaticFalse>
public typealias ICPCallNoArgs<Result> = ICPFunctionNoArgs<Result, StaticFalse>
public typealias ICPCallNoResult<Argument> = ICPFunctionNoResult<Argument, StaticFalse>
public typealias ICPCall<Argument, Result> = ICPFunction<Argument, Result, StaticFalse>

public extension ICPFunction where Argument: Encodable, Result: Decodable {
    func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: methodName,
            args: try encodeArguments(argument)
        )
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public extension ICPFunctionNoResult where Argument: Encodable {
    func callMethod(_ argument: Argument, _ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(
            canister: icpPrincipal,
            methodName: methodName,
            args: try encodeArguments(argument)
        )
        let _ = try await callOrQuery(method, client, sender)
    }
}

public extension ICPFunctionNoArgs where Result: Decodable {
    func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws -> Result {
        let method = ICPMethod(canister: icpPrincipal, methodName: methodName)
        let response = try await callOrQuery(method, client, sender)
        let decoded: Result = try CandidDecoder().decode(response)
        return decoded
    }
}

public extension ICPFunctionNoArgsNoResult {
    func callMethod(_ client: ICPRequestClient, sender: ICPSigningPrincipal? = nil) async throws {
        let method = ICPMethod(canister: icpPrincipal, methodName: methodName)
        let _ = try await callOrQuery(method, client, sender)
    }
}

fileprivate extension CandidFunctionProtocol {
    func callOrQuery(_ method: ICPMethod, _ client: ICPRequestClient, _ sender: ICPSigningPrincipal?) async throws -> CandidValue {
        if query {
            return try await client.query(method, effectiveCanister: icpPrincipal, sender: sender)
        } else {
            return try await client.callAndPoll(method, effectiveCanister: icpPrincipal, sender: sender)
        }
    }
    
    func encodeArguments<T>(_ arg: T) throws -> [CandidValue] where T: Encodable {
        print("ICPFunction: Encoding arguments of type: \(type(of: arg))")
        if let tuple = arg as? CandidTuple2<String, String> {
            print("ICPFunction: Encoding as CandidTuple2<String, String>")
            return [
                try CandidEncoder().encode(tuple._0),
                try CandidEncoder().encode(tuple._1)
            ]
        } else if let tuple = arg as? CandidTuple2<Encodable, Encodable> {
            print("ICPFunction: Encoding as CandidTuple2<Encodable, Encodable>")
            return [
                try CandidEncoder().encode(tuple._0),
                try CandidEncoder().encode(tuple._1)
            ]
        } else if let tuple = arg as? CandidTuple3<Encodable, Encodable, Encodable> {
            print("ICPFunction: Encoding as CandidTuple3")
            return [
                try CandidEncoder().encode(tuple._0),
                try CandidEncoder().encode(tuple._1),
                try CandidEncoder().encode(tuple._2)
            ]
        } else if let tuple = arg as? CandidTuple4<Encodable, Encodable, Encodable, Encodable> {
            print("ICPFunction: Encoding as CandidTuple4")
            return [
                try CandidEncoder().encode(tuple._0),
                try CandidEncoder().encode(tuple._1),
                try CandidEncoder().encode(tuple._2),
                try CandidEncoder().encode(tuple._3)
            ]
        } else if let tuple = arg as? CandidTuple5<Encodable, Encodable, Encodable, Encodable, Encodable> {
            print("ICPFunction: Encoding as CandidTuple5")
            return [
                try CandidEncoder().encode(tuple._0),
                try CandidEncoder().encode(tuple._1),
                try CandidEncoder().encode(tuple._2),
                try CandidEncoder().encode(tuple._3),
                try CandidEncoder().encode(tuple._4)
            ]
        } else if let tuple = arg as? CandidTuple6<Encodable, Encodable, Encodable, Encodable, Encodable, Encodable> {
            print("ICPFunction: Encoding as CandidTuple6")
            return [
                try CandidEncoder().encode(tuple._0),
                try CandidEncoder().encode(tuple._1),
                try CandidEncoder().encode(tuple._2),
                try CandidEncoder().encode(tuple._3),
                try CandidEncoder().encode(tuple._4),
                try CandidEncoder().encode(tuple._5)
            ]
        } else {
            print("ICPFunction: Encoding as single argument")
            return [try CandidEncoder().encode(arg)]
        }
    }
}
