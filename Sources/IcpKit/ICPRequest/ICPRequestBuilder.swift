//
//  ICPRequestBuilder.swift
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation
import Candid

enum ICPRequestBuilder {
    static let defaultIngressExpirySeconds: TimeInterval = 4 * 60 // 4 minutes
    
    static func buildContent(_ request: ICPRequestType, sender: ICPPrincipal?) throws -> ICPRequestContent {
            print("ICPRequestBuilder: Building content for request type: \(String(describing: request))")
            let nonce = try ICPCryptography.secureRandom(32)
            let ingressExpiry = createIngressExpiry()
            let senderBytes = sender?.bytes ?? Data([4])
            
            switch request {
            case .readState(let paths):
                print("ICPRequestBuilder: Building ReadStateRequestContent")
                let encodedPaths = paths.map { $0.encodedComponents() }
                return ReadStateRequestContent(
                    request_type: .readState,
                    sender: senderBytes,
                    nonce: nonce,
                    ingress_expiry: ingressExpiry,
                    paths: encodedPaths
                )
                
            case .call(let method), .query(let method):
                print("ICPRequestBuilder: Building CallRequestContent for method: \(method.methodName)")
                let serialisedArgs = CandidSerialiser().encode(method.args)
                print("ICPRequestBuilder: Serialised args: \(serialisedArgs.hex)")
                print("ICPRequestBuilder: Serialised args length: \(serialisedArgs.count)")
                return CallRequestContent(
                    request_type: .from(request),
                    sender: senderBytes,
                    nonce: nonce,
                    ingress_expiry: ingressExpiry,
                    method_name: method.methodName,
                    canister_id: method.canister.bytes,
                    arg: serialisedArgs
                )
            }
        }
    
    static func buildEnvelope(_ content: ICPRequestContent, sender: ICPSigningPrincipal?) async throws -> ICPRequestEnvelope {
        guard let sender = sender else {
            return ICPRequestEnvelope(content: content)
        }
        let requestId = try content.calculateRequestId()
        let senderSignature = try await sender.sign(requestId, domain: "ic-request")
        let senderPublicKey = try Cryptography.der(uncompressedEcPublicKey: sender.rawPublicKey)
        return ICPRequestEnvelope(
            content: content,
            sender_pubkey: senderPublicKey,
            sender_sig: senderSignature
        )        
    }
    
    private static func createIngressExpiry(_ seconds: TimeInterval = defaultIngressExpirySeconds) -> Int {
        let expiryDate = Date.now.addingTimeInterval(defaultIngressExpirySeconds)
        let nanoSecondsSince1970 = expiryDate.timeIntervalSince1970 * 1_000_000_000
        return Int(nanoSecondsSince1970)
    }
}
