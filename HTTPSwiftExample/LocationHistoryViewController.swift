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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // interacting with server
    let client = APIClient()  // how we will interact with the server
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //return self.imageModel.numberOfImages()
            //For TESTING ONLY
            //return Shared_VCdata.sharedData.trayImages.count
        }
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InvHistoryCell", for: indexPath)
            
            // FOR TESTING ONLY
            //print("current_row: \(indexPath.row)")
            //locationImages[indexPath.row] = Shared_VCdata.sharedData.trayImages[indexPath.row]
            
            // Configure the cell...
            //if let name = self.imageModel.getImageName(for: indexPath.row) as? String{
            //    cell.textLabel!.text = name
            //}
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
           let name = cell.textLabel?.text,
           let indexPath = tableView.indexPath(for: cell) { // Get the indexPath of the tapped cell
            vc.objectImage = Shared_VCdata.sharedData.trayImages[indexPath.row]  // Pass the correct image
            
        }
        
    }
}
