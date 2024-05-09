//
//  ImageLoader.swift
//  LoadPhoto
//
//  Created by Саша Восколович on 08.05.2024.
//

import SwiftUI

public protocol ImageDownloader {
    @available(iOS 13.0.0, *)
    func image(from url: URL) async throws -> UIImage
}

@available(iOS 13.0, *)
public actor Image: ImageDownloader {
    
    private enum CacheEntry {
        case inProgress(Task<UIImage, Error>)
        case ready(UIImage)
    }
    
    private var cache: [URL: CacheEntry] = [:]
    
    private let fetcher: Fetch
    
    public init(fetcher: Fetch) {
        self.fetcher = fetcher
    }
    
    
    public func image(from url: URL) async throws -> UIImage {
        
        if let cached = cache[url] {
            switch cached {
            case .inProgress(let task):
                return try await task.value
            case .ready(let image):
                return image
            }
        }
        
        let task = Task {
            try await downloadImage(from: url)
        }
        
        cache[url] = .inProgress(task)
        
        do {
            let image = try await task.value
            cache[url] = .ready(image)
            return image
        } catch {
            cache[url] = nil
            throw error
        }
    }
    
    
    private func downloadImage(from url: URL) async throws -> UIImage {
        guard let data = try? await fetcher.load(from: url), let image = UIImage(data: data) else {
            throw FetchError.failData
        }
        return image
    }
}

public enum FetchError: Error {
    case failData
}
