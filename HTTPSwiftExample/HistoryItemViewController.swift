//
//  ViewController.swift
//  flipped_module_1_smith_davis_hendersonExample
//
//  Created by Eric Larson on 9/2/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit

class HistoryItemViewController: UIViewController, UIScrollViewDelegate {

//    lazy var imageModel = {
//        return ImageModel.sharedInstance()
//    }()
    
//    lazy private var imageView: UIImageView? = {
//        return UIImageView.init(image: self.imageModel.getImageWithName(displayImageName))
//    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView?
    
    var objectImage: UIImage? // Variable to hold the passed object image
    
    var displayImageName = "Eric"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the object image is available
        guard let objectImage = objectImage else {
            print("No object image provided")
            return
        }
        
        // Assign the object image to the image view
        imageView?.image = objectImage
        
        // Do any additional setup after loading the view.

        if let size = self.imageView?.image?.size{
            self.scrollView.addSubview(self.imageView!)
            self.scrollView.contentSize = size
            self.scrollView.minimumZoomScale = 0.1
            self.scrollView.delegate = self
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    


}

