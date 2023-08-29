//
//  Web3Provider+Ex.swift
//  
//
//  Created by liugang zhang on 2023/8/25.
//

import Foundation
import Web3Core

extension Web3Provider {
    public func send<Result>(_ call: APIRequest) async throws -> APIResponse<Result> {
        try await APIRequest.sendRequest(with: self, for: call)
    }
}
