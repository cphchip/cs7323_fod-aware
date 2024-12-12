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
    
    @IBOutlet weak var combinedImageView: UIImageView!
    
    var objectImage: UIImage? // Variable to hold the passed object image
    
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
        
        // Ensure the object image is available
        guard let objectImage = objectImage else {
            print("No object image provided")
            return
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createQRCode(_ sender: UIButton) {
        // Example: Using a UUID (Universally Unique Identifier):
        let qrCodeText = UUID().uuidString
        //qrCodeImageView.image = generateQRCode(from: qrCodeText)
        
        if let qrCodeImage = generateQRCode(from: qrCodeText) {
            // Combine the object image and QR code
            let qrCodeSize = CGSize(width: 100, height:100) // Adjust size as needed
            let qrCodePosition = CGPoint(x: (objectImage?.size.width ?? 200) - 110, y: (objectImage?.size.height ?? 200) - 110) // Bottom-right corner
            //if let combinedImage = combineImages(objectImage: objectImage ?? defaultObjectImage, qrCodeImage: qrCodeImage, qrCodeSize: qrCodeSize, qrCodePosition: qrCodePosition) {
                // Display the combined image
              //  combinedImageView.image = combinedImage
            //}
            combinedImageView.image = qrCodeImage
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
    
//    // Combine the object image with the QR code
//    func combineImages(objectImage: UIImage, qrCodeImage: UIImage, qrCodeSize: CGSize, qrCodePosition: CGPoint) -> UIImage? {
//        let canvasSize = objectImage.size
//        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
//        defer { UIGraphicsEndImageContext() }
//
//        // Draw the object image
//        objectImage.draw(in: CGRect(origin: .zero, size: canvasSize))
//
//        // Draw the QR code
//        let qrCodeRect = CGRect(origin: qrCodePosition, size: qrCodeSize)
//        qrCodeImage.draw(in: qrCodeRect)
//
//        // Get the combined image
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
    
//    @IBAction func createNewBaseline(_ sender: UIButton) {
//        //let newImage = UIImage(named: "sample.png") // Replace this with your actual image
//        let newImage = combinedImageView.image ?? defaultObjectImage
//        SharedDataModel.sharedData.trayImages.append(newImage) // Add the image to the shared data model
//        print("Image added to trayImages: \(SharedDataModel.sharedData.trayImages.count)")
//    }
    
    //Print QR Code
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
