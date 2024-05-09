//
//  Fetch.swift
//  
//
//  Created by Саша Восколович on 08.05.2024.
//

import Foundation

@available(iOS 13.0.0, *)
public protocol Fetch {
    func load(from url: URL) async throws -> Data
}

@available(iOS 15.0, *)
public class Fetcher: Fetch {
    
    public init() {}
    
    public func load(from url: URL) async throws -> Data {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            throw FetchError.failData
        }
        return data
    }
}

