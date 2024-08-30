
//
//  ICPRequest.swift
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import BigInt
import PotentCBOR
import Candid

// private let canisterBaseUrl: URL = "https://icp-api.io/api/v2/canister"

public struct ICPMethod {
    public let canister: ICPPrincipal
    public let methodName: String
    public let args: [CandidValue]?
    
    public init(canister: ICPPrincipal, methodName: String, args: [CandidValue]) {
        self.canister = canister
        self.methodName = methodName
        self.args = args
    }
    
    public init(canister: ICPPrincipal, methodName: String, arg: CandidValue? = nil) {
        self.canister = canister
        self.methodName = methodName
        self.args = arg.map { [$0] }
    }
}

public enum ICPRequestType {
    case call(ICPMethod)
    case query(ICPMethod)
    case readState(paths: [ICPStateTreePath])    
}

/// https://internetcomputer.org/docs/current/references/ic-interface-spec#http-interface
public struct ICPRequest {
    public let requestId: Data
    let httpRequest: HttpRequest
    
    public init(_ request: ICPRequestType, canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil, baseURL: URL? = nil) async throws {
        let content = try ICPRequestBuilder.buildContent(request, sender: sender?.principal)
        requestId = try content.calculateRequestId()
        let envelope = try await ICPRequestBuilder.buildEnvelope(content, sender: sender)
        let rawBody = try ICPCryptography.CBOR.serialise(envelope)
        
        httpRequest = HttpRequest {
            $0.method = .post
            $0.url = Self.buildUrl(request, canister, baseURL: baseURL)
            $0.body = .data(rawBody, contentType: "application/cbor")
            $0.timeout = 120
        }
    }
    
    private static func buildUrl(_ request: ICPRequestType, _ canister: ICPPrincipal, baseURL: URL?) -> URL {
        let baseUrl = baseURL ?? URL(string: "https://icp-api.io")!
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        
        components.path = "/api/v2/canister/\(canister.string)"
        
        switch request {
        case .query:
            components.path += "/query"
        case .call:
            components.path += "/call"
        case .readState:
            components.path += "/read_state"
        }
        
        return components.url!
    }
}
