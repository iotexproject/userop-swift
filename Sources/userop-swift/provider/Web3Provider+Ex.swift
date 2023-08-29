//
//  Web3Provider+Ex.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import Foundation
import Web3Core

extension Web3Provider {
    public func send<Result>(_ method: String, parameter: [Encodable]) async throws -> APIResponse<Result> {
        return try await APIRequest.send(method, parameter: parameter, with: self)
    }
}
