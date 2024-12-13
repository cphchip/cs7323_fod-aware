//
//  ClientDelegates.swift
//  HTTPSwiftExample
//
//  Created by Ches Smith on 12/12/24.

/// used to notify the delegate when the image has been uploaded
protocol ImageDelegate: AnyObject {
    func didCreateBaseline(storageLocation: StorageLocation)
    func didCheckImage(imageCheck: ImageCheck)
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
    func didFetchHistory(storageLocation: StorageLocation, history: [ImageCheck])
    func didFailFetchingHistory(error: APIError)
}
