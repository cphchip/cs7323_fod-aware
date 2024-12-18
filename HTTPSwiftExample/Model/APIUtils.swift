//
//  Dataset.swift
//
//  Created by Ches Smith on 11/24/24.
//
// Utilities for the API client

import Foundation

/// error type for the api client
enum APIError: Error, LocalizedError {
    case invalidResponse(String?)
    case invalidURL
    case httpError(Int, String?)
    case serverError(String)
    case decodingError(String)
    case encodingError(String)
    case noData
    case networkError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let detail):
            if let detail = detail {
                return "The server response is invalid: \(detail)"
            }
            return "The server response is invalid."
        case .invalidURL:
            return "The URL is invalid."
        case .httpError(let statusCode, let detail):
            return
                "Server responded with an error. Status code: \(statusCode), detail: \(detail ?? "")"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let message):
            return "Failed to decode the server response: \(message)"
        case .encodingError(let message):
            return "Failed to encode the request: \(message)"
        case .noData:
            return "No data received from the server."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Error: \(error.localizedDescription)"
        }

    }
}

extension APIClient {
    // MARK: - HTTP Response Handling

    // Parse the error detail from the server
    private func parseErrorDetail(from data: Data?) -> String {
        guard let data = data else { return "No detail from server" }
        if let json = try? JSONSerialization.jsonObject(with: data, options: [])
            as? [String: Any],
            let detail = json["detail"] as? String
        {
            return detail
        }
        return "No detail from server"
    }

    // Perform the HTTP request
    func performRequest(_ request: URLRequest) async throws -> Data {
        // Send the request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check the HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(nil)
        }

        // make sure we have a valid status code
        guard (200...299).contains(httpResponse.statusCode) else {
            let detail = parseErrorDetail(from: data)
            throw APIError.httpError(httpResponse.statusCode, detail)
        }

        return data
    }

    // attempt to decode the response
    func decodeResponse<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error: \(error)")
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}

extension Error {
    /// Converts the error to an `APIError
    func asAPIError() -> APIError {
        if let apiError = self as? APIError {
            return apiError
        } else if (self as NSError).domain == NSURLErrorDomain {
            return .networkError(self)
        } else {
            return .unknown(self)
        }
    }
}
