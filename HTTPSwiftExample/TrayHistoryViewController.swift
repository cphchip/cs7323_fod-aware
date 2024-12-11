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
    
    var objectImages: [UIImage] = [] // Array to hold multiple images
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the object image is available
        //guard let objectImage = objectImage else {
        //    print("No object image provided")
        //    return
       // }
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectImages.count // Number of items matches the number of images
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell {
            
            cell.imageView.image = objectImages[indexPath.item] // Set the image for the corresponding item
            return cell
            
        }else{
            fatalError("Could not dequeue cell")
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
