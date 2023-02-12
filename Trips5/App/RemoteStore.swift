//
//  RemoteStore.swift
//  Trips5
//
//  Created by Rob Goble on 8/28/22.
//

import Foundation

class RemoteStore<T> where T: Codable, T: URLPathProviding {
    
    private let dateFormatter: DateFormatter
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        jsonEncoder.outputFormatting = [.withoutEscapingSlashes]
    }
    
    func getAll() async throws -> [T] {
        guard let url = T.url(for: .getAll) else { return [] }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try jsonDecoder.decode([T].self, from: data)
    }
    
    func post(_ value: T) async throws -> (Data, HTTPURLResponse)? {
        guard let url = T.url(for: .post) else { return nil }
        
        let encodedValue = try jsonEncoder.encode(value)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: encodedValue)
        
        if let httpResp = response as? HTTPURLResponse {
            return (data, httpResp)
        }
        
        return nil
    }
}
