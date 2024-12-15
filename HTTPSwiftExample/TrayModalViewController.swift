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
}

class TrayModalViewController: UIViewController, UITextFieldDelegate {
    // name of the new storage location
    var new_sloc_name: String?
    
    // description of the storage location
    var new_sloc_description: String?
    
    @IBOutlet weak var slocName: UITextField!
    
    @IBOutlet weak var slocDescription: UITextField!

    
    weak var delegate: TrayModalViewControllerDelegate? // Delegate reference
    
    // interacting with server
    let client = APIClient()  // how we will interact with the server
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        
        // delegate for textFieds
        slocName.delegate = self
        slocDescription.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func dismissSelected(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Switch focus between text fields
        if textField == slocName {
            print("ModalVC: slocName: \(String(describing: textField.text))")
            delegate?.didSend_sloc_name(textField.text ?? "")
            new_sloc_name = textField.text
            slocDescription.becomeFirstResponder()
        }
        else {
            print("ModalVC: slocDescription: \(String(describing: textField.text))")
            delegate?.didSend_sloc_description(textField.text ?? "")
            new_sloc_description = textField.text
            textField.resignFirstResponder() // Close the keyboard
        }
        
        // Request new storage location using APIClient
        print("TrayModalVC: Requesting a New Storage Location - name: \(String(describing: new_sloc_name))")
        client.createStorageLocation(withName: new_sloc_name ?? "", andDescription: new_sloc_description ?? "")
        return true
    }
}


