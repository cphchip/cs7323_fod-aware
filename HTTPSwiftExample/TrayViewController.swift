//
//  TrayViewController.swift
//  HTTPSwiftExample
//
//  Created by Chip Henderson on 12/7/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

// Protocol to send data back to main View Controller
protocol TrayViewControllerDelegate: AnyObject {
    func didSend_sloc_name (_ sloc_name: String)
    func didSend_sloc_description (_ sloc_description: String)
}

class TrayViewController: UIViewController {
    //Ref Cite:  ChatGPT
    // This section of code was generated with the assistance of ChatGPT, an AI language model by OpenAI.
    // Date: 12/9/24
    // Source: OpenAI's ChatGPT (https://openai.com/chatgpt)
    // Prompt: generate a QR code in an app using Apple's iOS and Swift
    
    // interacting with server
    let client = APIClient()  // how we will interact with the server
    
    // name of the new storage location
    var new_sloc_name: String?
    
    // description of the storage location
    var new_sloc_description: String?
    
    // date that the storage location was created
    var new_date_created: Date?
    
    // new qr code received from server for new storage location
    var new_qr_code: String?
    
    // new qr code.text used to generate QR code
    var new_qr_code_text: String?
 
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var slocName: UILabel!
    
 
    @IBOutlet weak var slocDescription: UILabel!
    
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    weak var tray_VC_delegate: TrayViewControllerDelegate? // TrayViewControllerDelegate reference
    
    var newQRcode_received: Bool = false  //check if new QR Code received from APIClient
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        qrCodeImageView.contentMode = .scaleAspectFit

        newQRcode_received = false
        
        
        // Do any additional setup after loading the view.
        client.newStorageLocationDelegate = self

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTrayModal", // Match the identifier of your segue
           let modalVC = segue.destination as? TrayModalViewController {
            modalVC.delegate = self // Set the delegate
        }
    }
    
    func Send_CreateNewSloc() {
        // Request new storage location using APIClient
        print("TrayModalVC: Requesting a New Storage Location - name: \(String(describing: new_sloc_name))")
        feedbackLabel.text = "Requesting a New Storage Location!"
        client.createStorageLocation(withName: new_sloc_name ?? "", andDescription: new_sloc_description ?? "")
    }
    
    @IBAction func createQRCode(_ sender: UIButton) {
         //  Get QR Code text
         //let qrCode = UUID()
        if newQRcode_received { // received new storageLocation QR code?
            new_qr_code_text = new_qr_code
            
            if let qrCodeImage = generateQRCode(from: new_qr_code_text ?? "") {
                // Display QRCode Image
                qrCodeImageView.image = qrCodeImage
            }
            newQRcode_received = false
        }
        else {
            feedbackLabel.text = "Waiting for Server Response-New StorageLocation Requested:\(String(describing: new_sloc_name))"
        }
        

    }
    
    // QR Code generation method
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        
        // Create the QR Code filter
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction level
            
            // Get the CIImage from the filter
            if let qrCodeImage = filter.outputImage {
                // Scale the image
                let transform = CGAffineTransform(scaleX: 10, y: 10) // Adjust scale as needed
                let scaledQRCode = qrCodeImage.transformed(by: transform)
                
                // Convert to UIImage
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledQRCode, from: scaledQRCode.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
    
    //Print QR Code
    @IBAction func printQRCode(_ sender: UIButton) {
        // Render the QR code for printing
        let printableImage = renderImageForPrinting(qrCodeImageView.image ?? Shared_VCdata.sharedData.defaultObjectImage)
        
        let padding: CGFloat = 250.0
        let printableImageWithPadding = addPadding(to: printableImage, padding: padding) ?? Shared_VCdata.sharedData.defaultObjectImage
        
        // Resize the QR code to make it smaller
        let targetSize = CGSize(width: 150, height: 150) // Adjust the size as needed
        guard let resizedImage = resizeImage(printableImageWithPadding, targetSize: targetSize) else {
            print("Failed to resize QR code")
            return
        }

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Print QR Code"
        printInfo.outputType = .photo
        printController.printInfo = printInfo

        // Use the resized image as the printing item
        printController.printingItem = resizedImage

        // Present the print controller
        printController.present(animated: true) { (controller, completed, error) in
            if completed {
                print("Printing successful!")
                //TODO: Add check if name, description is nil,
                //If name, description nil, then display a message that
                // name and description must be filled in
                // before a new storage location can be created
                // Also, add message to print QR Code before location
                // can be created
                
            } else if let error = error {
                print("Error printing: \(error.localizedDescription)")
            }
        }
    }
    
    //helper function to generate a printable Image
    func renderImageForPrinting(_ image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
    
    //helper function to scale the QR code image
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func addPadding(to image: UIImage, padding: CGFloat) -> UIImage? {
        let newSize = CGSize(width: image.size.width + 2 * padding, height: image.size.height + 2 * padding)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: newSize))
            image.draw(in: CGRect(x: padding, y: padding, width: image.size.width, height: image.size.height))
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

// MARK: - TrayModalViewControllerDelegate
extension TrayViewController: TrayModalViewControllerDelegate {
    func didSend_sloc_name (_ sloc_name: String) {
        new_sloc_name = sloc_name
        print("trayVC: new_sloc_name = \(String(describing: new_sloc_name))")
        
        // Populate sloc_name UILabel
        slocName.text = new_sloc_name
        
        tray_VC_delegate?.didSend_sloc_name(new_sloc_name ?? "")
    }
    
    func didSend_sloc_description (_ sloc_description: String) {
        new_sloc_description = sloc_description
        print("trayVC: new_sloc_description = \(String(describing: new_sloc_description))")
        
        // Populate sloc_description UILabel
        slocDescription.text = new_sloc_description
        
        tray_VC_delegate?.didSend_sloc_description(new_sloc_description ?? "")
    }
    func willSend_NewSlocCreate() {
        // Check if both text fields have valid non-empty values
        if let name = new_sloc_name, !name.isEmpty,
           let description = new_sloc_description, !description.isEmpty {
            // Both fields are valid, proceed further
            print("trayVC-Name: \(name)")
            print("trayVC-Description: \(description)")
            
            // Request new storage location using APIClient
            Send_CreateNewSloc()
        }
        else {
            print(" Must Enter Both Name and Description!")
        }
    }
}

// Subscribe to APIClient NewStorageLocation Delegate
extension TrayViewController: NewStorageLocationDelegate {
    func didCreateStorageLocation(storageLocation: StorageLocation){
        print("New Storage Location Created \(storageLocation.id)")
        DispatchQueue.main.async{
            self.feedbackLabel.text = "Created Storage Location-Create and Print QR Code"
        }
        new_qr_code = storageLocation.id
        newQRcode_received = true
    }
    func didFailCreatingStorageLocation(error: APIError){
        print(" Failed to Create New Storage Location: \(error.localizedDescription) ")
        DispatchQueue.main.async{
            self.feedbackLabel.text = "Failed to Create New Storage Location: \(error.localizedDescription) "
        }
    }
    
}
