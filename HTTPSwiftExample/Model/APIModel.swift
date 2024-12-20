//
//  APIModel.swift
//
//  Created by Ches Smith on 12/12/24.
// Contains the data models for the API

import Foundation

/// Represents a storage location
struct StorageLocation: Decodable, Identifiable {
    // unique identifier for the storage location
    let id: String
    // name of the storage location
    let name: String
    // description of the storage location
    let description: String
    let baseline_added: Bool
    // image url for the baseline image
    let image_name: String?
    // date that the storage location was created
    let created: Date
}

/// Represents an image check
struct InventoryCheck: Decodable, Identifiable {
    // unique identifier for the image check
    let id: String
    let inventory_complete: Bool
    // whether the image matches the baseline
    let matches_baseline: Bool
    // image url for the image being checked
    let image_name: String
    // date that the image check was performed
    let created: Date
}
