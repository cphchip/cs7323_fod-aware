//
//  ClientDelegates.swift
//  HTTPSwiftExample
//
//  Created by Ches Smith on 12/12/24.
//
// Contains the delegate protocols for the API client

/// used to notify the delegate when the image has been uploaded
protocol InventoryDelegate: AnyObject {
    func didCreateBaseline(storageLocation: StorageLocation)
    func didCheckInventory(inventoryCheck: InventoryCheck)
    func didFailImageUpload(error: APIError)
}

/// used to notify the delegate when a new storage location has been created
protocol NewStorageLocationDelegate: AnyObject {
    func didCreateStorageLocation(storageLocation: StorageLocation)
    func didFailCreatingStorageLocation(error: APIError)
}

/// used to notify the delegate when storage locations have been fetched
protocol StorageLocationsDelegate: AnyObject {
    func didFetchStorageLocations(locations: [StorageLocation])
    func didFailFetchingStorageLocations(error: APIError)
}

/// used to notify the delegate when history has been fetched
protocol HistoryDelegate: AnyObject {
    func didFetchHistory(storageLocation: StorageLocation, history: [InventoryCheck])
    func didFailFetchingHistory(error: APIError)
}
