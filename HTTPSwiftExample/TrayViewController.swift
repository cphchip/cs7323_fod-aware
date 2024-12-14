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
    func didSend_sloc_UUID (_ sloc_UUID: UUID)
    func didSend_sloc_name (_ sloc_name: String)
    func didSend_sloc_description (_ sloc_description: String)
    func didSend_date_created (_ date_created: Date)
    func createStorageLoc()
}

class TrayViewController: UIViewController {
    //Ref Cite:  ChatGPT
    // This section of code was generated with the assistance of ChatGPT, an AI language model by OpenAI.
    // Date: 12/9/24
    // Source: OpenAI's ChatGPT (https://openai.com/chatgpt)
    // Prompt: generate a QR code in an app using Apple's iOS and Swift
    
    // name of the new storage location
    var new_sloc_name: String?
    
    // description of the storage location
    var new_sloc_description: String?
    
    // date that the storage location was created
    var new_date_created: Date?
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    weak var delegate: TrayViewControllerDelegate? // Delegate reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        qrCodeImageView.contentMode = .scaleAspectFit

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createQRCode(_ sender: UIButton) {
        // Example: Using a UUID (Universally Unique Identifier):
        let qrCode = UUID()
        let qrCodeText = qrCode.uuidString
        delegate?.didSend_sloc_UUID(qrCode)
        
        if let qrCodeImage = generateQRCode(from: qrCodeText) {
            // Display QRCode Image
            qrCodeImageView.image = qrCodeImage
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
                
                //Initiate creation of the new storage location
                self.delegate?.createStorageLoc()
                
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
//protocol TrayModalViewControllerDelegate: AnyObject {
//    func didSend_sloc_name (_ sloc_name: String)
//    func didSend_sloc_description (_ sloc_description: String)
//    func didSend_date_created (_ date_created: Date)
//}
// MARK: - TrayModalViewControllerDelegate
extension TrayViewController: TrayModalViewControllerDelegate {
    func didSend_sloc_name (_ sloc_name: String) {
        new_sloc_name = sloc_name
        print("trayVC: new_sloc_name = \(String(describing: new_sloc_name))")
        delegate?.didSend_sloc_name(new_sloc_name ?? "")
    }
    func didSend_sloc_description (_ sloc_description: String) {
        new_sloc_description = sloc_description
        print("trayVC: new_sloc_description = \(String(describing: new_sloc_description))")
        delegate?.didSend_sloc_description(new_sloc_description ?? "")
    }
    func didSend_date_created (_ date_created: Date) {
        new_date_created = date_created
        print("trayVC: new_date_created = \(String(describing: new_date_created)))")
        delegate?.didSend_date_created(new_date_created ?? Date())
    }
}
