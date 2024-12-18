//
//  responses.swift
//  HTTPSwiftExample
//
//  Created by Ches Smith on 12/12/24.

import Foundation

// json decodable structs for API responses

/// A new baseline response from the server
struct NewBaselineResponse: Decodable {
    let status: String
    let sloc: StorageLocation
}

/// An inventory check response from the server
struct InventoryCheckResponse: Decodable {
    let status: String
    let inventory: InventoryCheck
    let sloc: StorageLocation
}

/// An error response from the server
struct ErrorResponse: Decodable {
    let status: String
    let message: String
}

/// The ImageUploadResponse enum represents the possible response
/// types from the image upload API endpoint.
enum ImageUploadResponse {
    case inventoryChecked(InventoryCheckResponse)
    case baselineAdded(NewBaselineResponse)
}

/// handles decoding of the image upload response
extension ImageUploadResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }

    init(from decoder: Decoder) throws {
        // Decode the status field
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(String.self, forKey: .status)
        // based on the status, decode the appropriate response
        switch status {
        case "inventory_checked":
            // decode the inventory check response
            self = .inventoryChecked(try InventoryCheckResponse(from: decoder))
        case "baseline_added":
            // decode the new baseline response
            self = .baselineAdded(try NewBaselineResponse(from: decoder))
        case "error":
            // decode the error response
            let errorResponse = try ErrorResponse(from: decoder)
            throw APIError.serverError(errorResponse.message)
        default:
            // that was unexpected
            throw APIError.invalidResponse("Unknown status value: \(status)")
        }
    }
}

/// The NewStorageLocationResponse response from the server
struct NewStorageLocationResponse: Decodable {
    let status: String
    let sloc: StorageLocation
}

/// create storage location response
enum CreateStorageLocationResponse {
    case success(NewStorageLocationResponse)
}


extension CreateStorageLocationResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }
    // same as the upload image response, we decode the status
    // but this time we only have a success or error
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

/// history response from the server
struct HistoryResponse: Decodable {
    let status: String
    let sloc: StorageLocation
    let history: [InventoryCheck]
}

// fetch history response enum
enum FetchHistoryResponse {
    case success(HistoryResponse)
}

// decode the fetch history response
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

/// storage location response from the server
struct StorageLocationsResponse: Decodable {
    let status: String
    let slocs: [StorageLocation]
}

// fetch storage locations response enum
enum FetchStorageLocationsResponse {
    case success(StorageLocationsResponse)
}

// decode the fetch storage locations response
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
