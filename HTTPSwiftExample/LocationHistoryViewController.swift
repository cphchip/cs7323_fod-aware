//
//  TableViewController.swift
//  flipped_module_1_smith_davis_hendersonExample
//
//  Created by Eric Larson on 9/3/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//
// Revisions:
// Smith,Davis,Henderson: updated for Flipped Assignment 1

import UIKit

class LocationHistoryViewController: UITableViewController {
    
    var current_row: Int?
    var locationImages: [UIImage] = []  //location images to pass to TrayDetail View Controller
    
    var currentlocation: StorageLocation?
    var current_id: String?
    
    var locHistory: [InventoryCheck]?
    
    // interacting with server
    let client = APIClient()  // how we will interact with the server
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // use delegation for interacting with client
        client.historyDelegate = self
   
    }
    
    override func viewWillAppear(_ animated:Bool)  {
        super.viewWillAppear(animated)
        if let id = current_id {
            print("locHist:  fetch id = \(id)")
            client.fetchHistory(forStorageLocation: id)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //return self.imageModel.numberOfImages()
            //For TESTING ONLY
            //return Shared_VCdata.sharedData.trayImages.count
            print("locHist:  count = \(locHistory?.count ?? 1)")
            return locHistory?.count ?? 1
        }
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InvHistoryCell", for: indexPath)
            
            let date: Date = locHistory?[indexPath.row].created ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let date_str = dateFormatter.string(from: date)
            var inv_status: String = ""
            if locHistory?[indexPath.row].matches_baseline == true {
                inv_status = "Inventory Success"
            }
            else {
                inv_status = "Missing Items"
            }
            cell.textLabel?.text = "\(date_str) - \(inv_status)"
           return cell
        }
        else {
               // Provide a default cell for other sections
               let defaultCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
               defaultCell.textLabel?.text = "Default"
               return defaultCell
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? TrayDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
           //vc.objectImage = Shared_VCdata.sharedData.trayImages[indexPath.row]  // Pass the correct image
            let imageName = locHistory?[indexPath.row].image_name ?? "placeholder"// Pass the correct image
            
            // Fetch Inv Check image from client
            client.fetchImage(imageName) { result in
                print(result)
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        vc.imageView.image = image  // Pass the correct image
                    }
                case .failure(let error):
                    print("Failed to fetch image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        vc.imageView.image = UIImage(named: "placeholder")  // Placeholder
                    }
                }
            }
        }
        
    }
}
extension LocationHistoryViewController: HistoryDelegate {
    func didFetchHistory(storageLocation: StorageLocation, history: [InventoryCheck]) {
        print("Successfully Fetched History for StorageLocation: \(storageLocation.id)")
        print("LocationHistoryVC: Location Histories Fetched! \(history.count)")
        locHistory = history
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    func didFailFetchingHistory(error: APIError) {
        print(" Failed to Fetch History: \(error.localizedDescription) ")
    }
}
