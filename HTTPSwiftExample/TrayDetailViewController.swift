//
//  TrayViewController.swift
//  HTTPSwiftExample
//
//  Created by Chip Henderson on 12/7/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

class TrayDetailViewController: UIViewController {
    //Ref Cite:  ChatGPT
    // This section of code was generated with the assistance of ChatGPT, an AI language model by OpenAI.
    // Date: 12/9/24
    // Source: OpenAI's ChatGPT (https://openai.com/chatgpt)
    // Prompt: Showing details of an image from a CollectionView using Apple's iOS and Swift
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
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
        
        // Ensure the object image is available
        guard let objectImage = objectImage else {
            print("No object image provided")
            return
        }

        // Assign the object image to the image view
       imageView.image = objectImage
        
        // Do any additional setup after loading the view.
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
