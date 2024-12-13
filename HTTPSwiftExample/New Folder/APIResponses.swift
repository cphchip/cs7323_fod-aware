//
//  responses.swift
//  HTTPSwiftExample
//
//  Created by Ches Smith on 12/12/24.

import Foundation

// json decodable structs for API responses

struct NewBaselineResponse: Decodable {
    let status: String
    let sloc: StorageLocation
}
struct ImageCheckResponse: Decodable {
    let status: String
    let check: ImageCheck
    let sloc: StorageLocation
}

struct ErrorResponse: Decodable {
    let status: String
    let message: String
}

enum ImageUploadResponse {
    case imageChecked(ImageCheckResponse)
    case baselineAdded(NewBaselineResponse)
}

extension ImageUploadResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(String.self, forKey: .status)

        switch status {
        case "image_checked":
            self = .imageChecked(try ImageCheckResponse(from: decoder))
        case "baseline_added":
            self = .baselineAdded(try NewBaselineResponse(from: decoder))
        case "error":
            let errorResponse = try ErrorResponse(from: decoder)
            throw APIError.serverError(errorResponse.message)
        default:
            throw APIError.invalidResponse("Unknown status value: \(status)")
        }
    }
}

struct NewStorageLocationResponse: Decodable {
    let status: String
    let sloc: StorageLocation
}

enum CreateStorageLocationResponse {
    case success(NewStorageLocationResponse)
}

extension CreateStorageLocationResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(String.self, forKey: .status)

        switch status {
        case "success":
            self = .success(try NewStorageLocationResponse(from: decoder))
        case "error":
            let errorResponse = try ErrorResponse(from: decoder)
            throw APIError.serverError(errorResponse.message)
        default:
            throw APIError.invalidResponse("Unknown status value: \(status)")
        }
    }
}

struct HistoryResponse: Decodable {
    let status: String
    let sloc: StorageLocation
    let history: [ImageCheck]
}

enum FetchHistoryResponse {
    case success(HistoryResponse)
}

extension FetchHistoryResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(String.self, forKey: .status)

        switch status {
        case "success":
            self = .success(try HistoryResponse(from: decoder))
        case "error":
            let errorResponse = try ErrorResponse(from: decoder)
            throw APIError.serverError(errorResponse.message)
        default:
            throw APIError.invalidResponse("Unknown status value: \(status)")
        }
    }
}

struct StorageLocationsResponse: Decodable {
    let status: String
    let slocs: [StorageLocation]
}

enum FetchStorageLocationsResponse {
    case success(StorageLocationsResponse)
}

extension FetchStorageLocationsResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(String.self, forKey: .status)

        switch status {
        case "success":
            self = .success(try StorageLocationsResponse(from: decoder))
        case "error":
            let errorResponse = try ErrorResponse(from: decoder)
            throw APIError.serverError(errorResponse.message)
        default:
            throw APIError.invalidResponse("Unknown status value: \(status)")
        }
    }
}
