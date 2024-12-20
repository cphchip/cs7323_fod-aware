//
//  TrayHistoryViewController.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/8/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CollectCell"

class TrayHistoryViewController: UICollectionViewController {
    
    var currentlocations: [StorageLocation]?
    
    var objectImages: [UIImage] = [] // Array to hold multiple images
    

    
    // interacting with server
    let client = APIClient()  // how we will interact with the server
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // use delegation for interacting with client
        client.storageLocationsDelegate = self
        
        
        // Ensure the object image is available
        //guard let objectImage = objectImage else {
        //    print("No object image provided")
        //    return
        // }
        // Ask the client to fetch the Storage Locations
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool)  {
        super.viewWillAppear(animated)
        client.fetchStorageLocations()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return objectImages.count // Number of items matches the number of images
        return currentlocations?.count ?? 0 // Number of items matches the number of images
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
            cell.imageView.image = UIImage(named: "placeholder")

            guard let locations = currentlocations else {
                return cell
            }
            // get the image name
            let slocName = locations[indexPath.item].name
            guard let imageName = locations[indexPath.item].image_name else {
                return cell
            }
            
            client.fetchImage(imageName) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                case .failure(let error):
                    print("Failed to fetch image: \(error.localizedDescription)")
                }
            }
            
            return cell
            
        }else{
            fatalError("Could not dequeue cell")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let selectedImage = objectImages[indexPath.item]
       // performSegue(withIdentifier: "showTrayDetailViewController", sender: selectedImage)
        // No need to performSegue here since the storyboard handles it
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocationHistoryViewController",
           let locVC = segue.destination as? LocationHistoryViewController,
           let indexPath = collectionView.indexPathsForSelectedItems?.first{
            //locVC.objectImage = objectImages[indexPath.item]
            locVC.currentlocation = currentlocations?[indexPath.item]
            locVC.current_id = currentlocations?[indexPath.item].id
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// Subscribe to APIClient NewStorageLocation Delegate
extension TrayHistoryViewController: StorageLocationsDelegate {
    func didFetchStorageLocations(locations: [StorageLocation]) {
        print("TrayHistoryVC: StorageLocations Fetched! \(locations.count)")
        currentlocations = locations
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    func didFailFetchingStorageLocations(error: APIError) {
        print(" TrayHistoryVC: Failed to Fetch StorageLocations: \(error.localizedDescription) ")
    }
}
