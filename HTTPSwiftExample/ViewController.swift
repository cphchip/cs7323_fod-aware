//
//  ViewController.swift
//  HTTPSwiftExample
//
//  Created by Eric Larson on 3/30/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//  Updated 2024

// This example is meant to be run with the python example:
//              fastapi_turicreate.py
//              from the course GitHub repository

import AVFoundation
import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, AVCapturePhotoCaptureDelegate
{

    //Ref Cite:  ChatGPT
    // This section of code was generated with the assistance of ChatGPT, an AI language model by OpenAI.
    // Date: 11/22/24
    // Source: OpenAI's ChatGPT (https://openai.com/chatgpt)
    // Prompt: capture a picture taken with phone camera using AVFoundation
    // Modifications: updated to integrate with Mlaas Model

    // MARK: Class Properties

    // interacting with server
    let client = MLClient()  // how we will interact with the server

    // Photo capture properties
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isCameraRunning = false  // To track the camera state


    var imageCount = 0                    // count of images taken
    var currentObjectSelected = "none"
    var currentResizedImage: UIImage!     // current image to process


    // User Interface properties
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var cameraFeedView: UIView!
    @IBOutlet weak var StartStopCamera: UIButton!
    @IBOutlet weak var imgCaptureButton: UIButton!
    
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

    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Initial state for the UIImageView
        capturedImageView.contentMode = .scaleAspectFit
        capturedImageView.isHidden = true  // Hide initially until a photo is cap

        // Set the button's initial title
        StartStopCamera.setTitle("Start Camera", for: .normal)

        // use delegation for interacting with client
        //client.delegate = self

        // Get the labels from the server
        //let labelDataSets = client.getLabels()

        // Extract labels from array of DataSets - [Dataset]
       // let labels = labelDataSets.map { $0.label }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTrayViewController" {
            guard let destinationVC = segue.destination as? TrayViewController else {
                print("destinationVC is nil")
                return
            }
        }
        else if segue.identifier == "ShowTrayHistoryViewController", // Match the identifier of the segue
           let trayHistoryVC = segue.destination as? TrayHistoryViewController {
            trayHistoryVC.objectImages = SharedDataModel.sharedData.trayImages // Pass images
        }
    }
    

    // Photo capture button pressed. Capture photo
    @IBAction func capturePhotoButtonTapped(_ sender: UIButton) {
        if isCameraRunning {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // AVCapturePhotoCaptureDelegate method
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?
    ) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }

        // Convert the captured photo to UIImage
        if let photoData = photo.fileDataRepresentation(),
            let image = UIImage(data: photoData)
        {

            // Resize the image to 512x512
            let targetSize = CGSize(width: 512, height: 512)
            let resizedImage = resizeImage(image: image, targetSize: targetSize)

            // Convert UIImage to JPEG data
            if let jpegData = resizedImage?.jpegData(compressionQuality: 1.0)
            {  // Compression quality: 1.0 = maximum quality

                //save current resized image to send to training/prediction tasks
                currentResizedImage = UIImage(data: jpegData) ?? UIImage()  // if error, provide empty image

                DispatchQueue.main.async {
                    // self.capturedImageView.image = image
                    self.capturedImageView.image = resizedImage
                    self.capturedImageView.isHidden = false

                    // Stop the camera after capturing the photo
                    self.stopCamera()
                    self.restoreUI()  // Restore the initial UI state
                }
            } else {
                print("Error converting image to JPEG format")
            }
        }
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }


    @IBAction func startStopCameraOps(_ sender: Any) {
        if isCameraRunning {  // If Camera is active, stop camera and restore UI
            stopCamera()
            restoreUI()
        } else {
            startCamera()  //If Camera not active, start camera
        }
    }

    func startCamera() {
        // Initialize the capture session if not already initialized
        if captureSession == nil {
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo

            // Configure the camera device
            guard
                let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back)
            else {
                fatalError("No back camera available")
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                fatalError("Error setting up camera input: \(error)")
            }

            // Configure the photo output
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
        }

        // Recreate the preview layer if it was removed
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            //previewLayer.frame = view.bounds
            //view.layer.insertSublayer(previewLayer, at: 0)
            previewLayer.frame = cameraFeedView.bounds  //Match the size of the UIView
            cameraFeedView.layer.addSublayer(previewLayer)
        }

        // Start the capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                // Update UI-related elements on the main thread
                self.isCameraRunning = true
                self.StartStopCamera.setTitle("Stop Camera", for: .normal)
                self.capturedImageView.isHidden = true  // Hide the image view when the camera starts
            }
        }
    }

    func stopCamera() {
        // Stop the capture session
        captureSession.stopRunning()
        isCameraRunning = false
        StartStopCamera.setTitle("Start Camera", for: .normal)

        // Remove the preview layer to restore the initial background/UI
        if previewLayer != nil {
            previewLayer.removeFromSuperlayer()
            previewLayer = nil
        }
    }

    func restoreUI() {
        // Reset the UIImageView and other UI elements to their initial state
        //capturedImageView.image = nil // Clear the captured image
        //capturedImageView.isHidden = true // Hide the image view
        view.backgroundColor = .white  // Reset to the initial background color
    }

    //TODO: Need to update function name for Final Proj
    func uploadTrainingImage() {
        //feedbackLabel.text = "Uploading!"

        if let dsid = client.getLabel(byName: currentObjectSelected)?.dsid {
            print("VC-uploadTrainingImage selected: dsid = \(dsid)")
            client.uploadImage(image: currentResizedImage, dsid: dsid)
//            imageCount += 1
//            imageCountLabel.text = "\(imageCount) / 5"

        }
    }


    
    //TODO: Need to update function name for Final Proj
    @IBAction func uploadImageClicked(_ sender: Any) {
            uploadTrainingImage()
    }

}

//MARK: MLClient Protocol Required Functions
//extension ViewController: MLClientProtocol {
//    // function to print the labels fetched
//    func didFetchLabels(labels: [Dataset]) {
//        print(labels)
//    }
//    // function to print the label added
//    func labelAdded(label: Dataset?, error: APIError?) {
//        if let error = error {
//            print(error.localizedDescription)
//        } else {
//            print("Label added: \(label?.label ?? "")")
//        }
//    }
//    // function to indicate whether the image was uploaded successfully
//    func uploadImageComplete(success: Bool, errMsg: String?) {
//        if success {
//            print("Image uploaded successfully")
//           // feedbackLabel.text = "Image uploaded"
//        } else {
//            print("Image upload failed: \(errMsg ?? "")")
//            //feedbackLabel.text = "upload failed"
//        }
//    }
//    
//}
