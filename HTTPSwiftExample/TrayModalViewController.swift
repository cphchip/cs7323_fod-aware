//
//  TrayModalViewController.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/13/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit
// Protocol to send data back to main Tray View Controller
protocol TrayModalViewControllerDelegate: AnyObject {
    func didSend_sloc_name (_ sloc_name: String)
    func didSend_sloc_description (_ sloc_description: String)
    func didSend_date_created (_ date_created: Date)
}

class TrayModalViewController: UIViewController, UITextFieldDelegate {
   
    
    @IBOutlet weak var slocName: UITextField!
    
    @IBOutlet weak var slocDescription: UITextField!
    
    @IBOutlet weak var slocCreateDate: UIDatePicker!

    weak var delegate: TrayModalViewControllerDelegate? // Delegate reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        
        // delegate for textFieds
        slocName.delegate = self
        slocDescription.delegate = self
        
        slocCreateDate.datePickerMode = .date
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        delegate?.didSend_date_created(selectedDate)
    }
    
    
    @IBAction func dismissSelected(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Switch focus between text fields
        if textField == slocName {
            print("ModalVC: slocName: \(String(describing: textField.text))")
            delegate?.didSend_sloc_name(textField.text ?? "")
            slocDescription.becomeFirstResponder()
        } else {
            print("ModalVC: slocDescription: \(String(describing: textField.text))")
            delegate?.didSend_sloc_description(textField.text ?? "")
            textField.resignFirstResponder() // Close the keyboard
        }
        return true
    }
}
