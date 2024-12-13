//
//  model.swift
//  HTTPSwiftExample
//
//  Created by Ches Smith on 12/12/24.

import Foundation

/// Represents a storage location
struct StorageLocation: Decodable, Identifiable {
    // unique identifier for the storage location
    let id: UUID
    // name of the storage location
    let name: String
    // description of the storage location
    let description: String
    // image url for the baseline image
    let image_url: String?
    // date that the storage location was created
    let created: Date
}

/// Represents an image check
struct InventoryCheck: Decodable, Identifiable {
    // unique identifier for the image check
    let id: UUID
    // whether the image matches the baseline
    let matches_baseline: Bool
    // image url for the image being checked
    let image_url: String
    // date that the image check was performed
    let created: Date
}
