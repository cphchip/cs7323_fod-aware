//
//  TrayModalViewController.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/13/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit
// Protocol to send data back to main Tray View Controller
protocol MainModalViewControllerDelegate: AnyObject {
    func didSend_existing_date_created (_ date_created: Date)
}

class MainModalViewController: UIViewController {
   
    @IBOutlet weak var invChk_createDate: UIDatePicker!
    
    weak var delegate: MainModalViewControllerDelegate? // Delegate reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        
        // Delegate for Date Picker
        invChk_createDate.datePickerMode = .date
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        delegate?.didSend_existing_date_created(selectedDate)
    }
    
    @IBAction func dismissSelected(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
