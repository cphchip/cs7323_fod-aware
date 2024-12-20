//
//  APIClient.swift
//
//  Created by Ches Smith on 12/12/24.
//
// API client for the FodAware app

import Foundation
import UIKit

/// API client for the FodAware app
class APIClient {
    // MARK: - Private Constants
    // API endpoint
    private let API_BASE_ENDPOINT = "http://45.33.24.52:8000"

    // secret API token
    private let API_TOKEN =
        Bundle.main.object(forInfoDictionaryKey: "API_TOKEN") as? String ?? ""

    // MARK: - Delegates
    /// Delegate for image-related operations
    public var inventoryDelegate: InventoryDelegate?

    /// Delegate for creating new storage locations
    public var newStorageLocationDelegate: NewStorageLocationDelegate?

    /// Delegate for fetching storage locations
    public var storageLocationsDelegate: StorageLocationsDelegate?

    /// Delegate for fetching history for a storage location
    public var historyDelegate: HistoryDelegate?

    // MARK: - Public Methods

    /// Fetch an image from the server with the given name
    /// - Parameters:
    ///  - imageName: The name of the image to fetch
    ///  - completion: The completion handler to call when the image is fetched
    func fetchImage(
        _ imageName: String,
        completion: @escaping (Result<UIImage, APIError>) -> Void
    ) {
        Task {
            // Validate the server URL
            guard
                let serverURL = URL(
                    string: "\(API_BASE_ENDPOINT)/images/\(imageName)")
            else {
                completion(.failure(.invalidURL))
                return
            }

            // Prepare the request
            var request = URLRequest(url: serverURL)
            request.httpMethod = "GET"
            request.addValue(API_TOKEN, forHTTPHeaderField: "x-api-token")

            // Send the request
            let data = try? await performRequest(request)

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // Decode the response
            guard let image = UIImage(data: data) else {
                completion(
                    .failure(.decodingError("Failed to decode the image data")))
                return
            }
            completion(.success(image))
            return
        }
    }

    /// Create a new storage location
    func createStorageLocation(
        withName name: String, andDescription description: String
    ) {
        Task {
            do {
                // Perform the request
                let response = try await performCreateStorageLocation(
                    name: name, description: description)
                // Notify the delegate that the storage location was created
                newStorageLocationDelegate?.didCreateStorageLocation(
                    storageLocation: response.sloc)
            } catch {
                // Notify the delegate of the error
                newStorageLocationDelegate?.didFailCreatingStorageLocation(
                    error: error.asAPIError())
            }
        }
    }

    /// Upload an image for the given storage location
    /// - Parameters:
    ///  - image: The image to upload
    ///  - sloc_id: The ID of the storage location
    func uploadImage(image: UIImage, forStorageLocation sloc_id: String) {
        Task {
            do {
                // Perform the request
                let response = try await performUploadImage(
                    sloc_id: sloc_id, image: image)
                switch response {
                // the storage location already has a baseline, so we check the image
                case .inventoryChecked(let inventoryCheckResponse):
                    // Notify the delegate of the image check
                    inventoryDelegate?.didCheckInventory(
                        inventoryCheck: inventoryCheckResponse.inventory)
                // the storage location did not have a baseline, so we create one
                case .baselineAdded(let newBaselineResponse):
                    // Notify the delegate of the new baseline
                    inventoryDelegate?.didCreateBaseline(
                        storageLocation: newBaselineResponse.sloc)
                }
            } catch {
                // Notify the delegate of the error
                inventoryDelegate?.didFailImageUpload(error: error.asAPIError())
            }
        }
    }

    /// Fetch the storage locations from the server
    func fetchStorageLocations() {
        Task {
            do {
                // Perform the request
                let response = try await performFetchStorageLocations()
                // Notify the delegate of the fetched storage locations
                storageLocationsDelegate?.didFetchStorageLocations(
                    locations: response.slocs)
            } catch {
                // Notify the delegate of the error
                storageLocationsDelegate?.didFailFetchingStorageLocations(
                    error: error.asAPIError())
            }
        }
    }

    /// Fetch the history for the given storage location
    /// - Parameters:
    /// - sloc_id: The ID of the storage location
    func fetchHistory(forStorageLocation sloc_id: String) {
        Task {
            do {
                // Perform the request
                let response = try await performFetchHistory(sloc_id: sloc_id)
                // Notify the delegate of the fetched history
                historyDelegate?.didFetchHistory(
                    storageLocation: response.sloc, history: response.history)
            } catch {
                // Notify the delegate of the error
                historyDelegate?.didFailFetchingHistory(
                    error: error.asAPIError())
            }
        }
    }

    // MARK: - Private Methods

    private func performCreateStorageLocation(name: String, description: String)
        async throws -> NewStorageLocationResponse
    {
        // Validate the server URL
        guard let serverURL = URL(string: "\(API_BASE_ENDPOINT)/create_sloc")
        else {
            throw APIError.invalidURL
        }

        // Prepare the request
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(API_TOKEN, forHTTPHeaderField: "x-api-token")

        // Prepare the request body
        let body = ["name": name, "description": description]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Send the request
        let data = try await performRequest(request)
        // convert data to string
        let dataString = String(data: data, encoding: .utf8)
        print("Data: \(dataString ?? "No data")")
        // Decode the response
        return try decodeResponse(data) as NewStorageLocationResponse
    }

    private func performUploadImage(sloc_id: String, image: UIImage)
        async throws
        -> ImageUploadResponse
    {
        // Validate the server URL
        guard let serverURL = URL(string: "\(API_BASE_ENDPOINT)/upload_image")
        else {
            throw APIError.invalidURL
        }

        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.encodingError("Unable to compress image")
        }

        // Prepare the multipart request
        var multipart = MultipartRequest()
        multipart.add(key: "sloc_id", value: sloc_id)  // Add ID
        multipart.add(
            key: "image",
            fileName: "image.jpg",
            fileMimeType: "image/jpeg",
            fileData: imageData
        )

        // Create the HTTP request
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue(
            multipart.httpContentTypeHeadeValue,
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = multipart.httpBody

        // add api token to the request
        request.addValue(API_TOKEN, forHTTPHeaderField: "x-api-token")

        // Send the request
        let data = try await performRequest(request)

        // Decode the response
        return try decodeResponse(data) as ImageUploadResponse
    }

    private func performFetchStorageLocations() async throws
        -> StorageLocationsResponse
    {
        // Validate the server URL
        guard let serverURL = URL(string: "\(API_BASE_ENDPOINT)/slocs")
        else {
            throw APIError.invalidURL
        }

        // Prepare the request
        var request = URLRequest(url: serverURL)
        request.httpMethod = "GET"
        request.addValue(API_TOKEN, forHTTPHeaderField: "x-api-token")

        // Send the request
        let data = try await performRequest(request)
        let dataString = String(data: data, encoding: .utf8)
        print("Data: \(dataString ?? "No data")")
        // Decode the response
        return try decodeResponse(data) as StorageLocationsResponse
    }

    private func performFetchHistory(sloc_id: String) async throws
        -> HistoryResponse
    {
        // Validate the server URL
        guard
            let serverURL = URL(
                string:
                    //"\(API_BASE_ENDPOINT)/history/\(sloc_id.uuidString)"
                    "\(API_BASE_ENDPOINT)/history/\(sloc_id)"
            )
        else {
            throw APIError.invalidURL
        }

        // Prepare the request
        var request = URLRequest(url: serverURL)
        request.httpMethod = "GET"
        request.addValue(API_TOKEN, forHTTPHeaderField: "x-api-token")

        // Send the request
        let data = try await performRequest(request)
        // convert data to string
        let dataString = String(data: data, encoding: .utf8)
        print("Data: \(dataString ?? "No data")")
        // Decode the response
        return try decodeResponse(data) as HistoryResponse
    }

}
