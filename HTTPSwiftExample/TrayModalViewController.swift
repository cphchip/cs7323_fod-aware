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
    func willSend_NewSlocCreate()
}

class TrayModalViewController: UIViewController, UITextFieldDelegate {
    // name of the new storage location
    var new_sloc_name: String?
    
    // description of the storage location
    var new_sloc_description: String?
    
    @IBOutlet weak var slocName: UITextField!
    
    @IBOutlet weak var slocDescription: UITextField!

    
    weak var delegate: TrayModalViewControllerDelegate? // Delegate reference
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        
        // delegate for textFieds
        slocName.delegate = self
        slocDescription.delegate = self
        
        // Add a tap gesture to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        
        // Do any additional setup after loading the view.
    }
    
    // Dismiss the keyboard when tapping outside the text fields
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    
    @IBAction func dismissSelected(_ sender: UIButton) {
        delegate?.willSend_NewSlocCreate()
        self.dismiss(animated: true, completion: nil)
    }
    
    // Delegate method called when editing begins
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == slocName {
            //print("User started editing First TextField")
        } else if textField == slocDescription {
            //print("User started editing Second TextField")
        }
    }
    
    // Delegate method called when editing ends
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == slocName {
            //print("slocName TextField finished editing: \(textField.text ?? "")")
            print("ModalVC: slocName: \(String(describing: textField.text))")
            delegate?.didSend_sloc_name(textField.text ?? "")
            new_sloc_name = textField.text
        } else if textField == slocDescription {
            //print("slocDescription TextField finished editing: \(textField.text ?? "")")
            print("ModalVC: slocDescription: \(String(describing: textField.text))")
            delegate?.didSend_sloc_description(textField.text ?? "")
            new_sloc_description = textField.text
        }
    }
    
}


