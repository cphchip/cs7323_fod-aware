//
//  SharedDataModel.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/10/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

class Shared_VCdata {
    static let sharedData = Shared_VCdata()
    var trayImages: [UIImage] = []
    
    
    let defaultObjectImage = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200)).image { context in
            UIColor.lightGray.setFill() // Default to white background
            context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
    
            // Configure the text attributes
            let text = "No Image"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.darkGray]
    
            // Calculate the text size and position
            let textSize = text.size(withAttributes: attributes)
            let textPosition = CGPoint(
                x: (200 - textSize.width) / 2, // Center horizontally
                y: (200 - textSize.height) / 2 // Center vertically
            )
    
            // Draw the text
            text.draw(at: textPosition, withAttributes: attributes)
        }
    
    
    private init() {} // Prevents other instances from being created
}
