//
//  TrayViewController.swift
//  HTTPSwiftExample
//
//  Created by Chip Henderson on 12/7/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

class TrayViewController: UIViewController {
    //Ref Cite:  ChatGPT
    // This section of code was generated with the assistance of ChatGPT, an AI language model by OpenAI.
    // Date: 12/9/24
    // Source: OpenAI's ChatGPT (https://openai.com/chatgpt)
    // Prompt: generate a QR code in an app using Apple's iOS and Swift
    
    @IBOutlet weak var qrCodeImageView: UIImageView!

    let defaultObjectImage = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200)).image { context in
        UIColor.lightGray.setFill() // Default to white background
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        
        // Configure the text attributes
        let text = "No Image"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.darkGray
        ]
        
        // Calculate the text size and position
        let textSize = text.size(withAttributes: attributes)
        let textPosition = CGPoint(
            x: (200 - textSize.width) / 2, // Center horizontally
            y: (200 - textSize.height) / 2 // Center vertically
        )
        
        // Draw the text
        text.draw(at: textPosition, withAttributes: attributes)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up any initial configurations
        qrCodeImageView.contentMode = .scaleAspectFit

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createQRCode(_ sender: UIButton) {
        // Example: Using a UUID (Universally Unique Identifier):
        let qrCodeText = UUID().uuidString
        
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
        let printableImage = renderImageForPrinting(qrCodeImageView.image ?? defaultObjectImage)
        
        let padding: CGFloat = 250.0
        let printableImageWithPadding = addPadding(to: printableImage, padding: padding) ?? defaultObjectImage
        
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
