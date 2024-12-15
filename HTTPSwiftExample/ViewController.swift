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
    // Modifications: updated to integrate with APIClient

    // MARK: Class Properties

    // interacting with server
    let client = APIClient()  // how we will interact with the server
    
    let qrCodeScanner = QRCodeScanner() // Initialize the scanner helper

    // Photo capture properties
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isCameraRunning = false  // To track the camera state

    var currentResizedImage: UIImage!     // current image to process
    
    // existing sloc unique identifier
    var existing_sloc_UUID: UUID?
    
    // unique identifier for a new storage location
    var new_sloc_UUID: String?
    
    // name of the new storage location
    var new_sloc_name: String?
    
    // description of the storage location
    var new_sloc_description: String?
    
    // date that the storage location was created
    var new_date_created: Date?
    
    var newBaseline: Bool = false  //new Baseline indication
    
    
    // User Interface properties
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var cameraFeedView: UIView!
    @IBOutlet weak var StartStopCamera: UIButton!
    @IBOutlet weak var imgCaptureButton: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!
    
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
        client.inventoryDelegate = self
        client.newStorageLocationDelegate = self
        client.storageLocationsDelegate = self
        client.historyDelegate = self
        
        newBaseline = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTrayViewController" {
            guard let destinationVC = segue.destination as? TrayViewController else {
                print("destinationVC is nil")
                return
            }
            newBaseline = true
            destinationVC.tray_VC_delegate =  self
        }
        else if segue.identifier == "ShowTrayHistoryViewController", // Match the identifier of the segue
           let trayHistoryVC = segue.destination as? TrayHistoryViewController {
            trayHistoryVC.objectImages = Shared_VCdata.sharedData.trayImages // Pass images
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
                    
                    //TEST ONLY - send image to shared object for testing REMOVE AFTER
                    //Shared_VCdata.sharedData.trayImages.append(self.currentResizedImage)
                    
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
    
    @IBAction func uploadImageSelected(_ sender: Any) {
        print("VC-uploadImage selected")
        
        if newBaseline {
           //Initiate creation of the new storage location
           //client.createStorageLocation(withName: new_sloc_name ?? "", andDescription: new_sloc_description ?? "")
        }
        uploadImage()
    }
    
    //UpLoad Image
    func uploadImage() {
        if currentResizedImage == nil {
            currentResizedImage = Shared_VCdata.sharedData.defaultObjectImage
            print("Image was nil, setting to default")
        }
        
        if newBaseline {
            print("VC-uploadImage - Uploading New Baseline Image")
            feedbackLabel.text =  "Uploading New Baseline Image!"
            
            if let storageLocationID = new_sloc_UUID {  // new sloc UUID
                client.uploadImage(image: currentResizedImage, forStorageLocation: storageLocationID)
                newBaseline = false
            }
        }
        else{
            print("VC-uploadImage - Uploading Inventory Check Image")
            feedbackLabel.text =  "Uploading Inventory Check Image!"
            //This is an inventory check, so Scan QR code to retrive the sloc UUID
            
            //Retrieve the existing sloc UUID from the QR code in the image
            //Call the QR code scanner
            qrCodeScanner.detectQRCode(in: currentResizedImage) {  uuid in
                DispatchQueue.main.async {
                    if let uuid = uuid {
                       print("Success", "UUID Found: \(uuid)")
                        self.feedbackLabel.text =  "Success - UUID found in QR Code Scan!"
                        self.client.uploadImage(image: self.currentResizedImage, forStorageLocation: uuid)
                    } else {
                        print("Error", "No valid UUID found in the QR code.")
                        self.feedbackLabel.text =  "Error - No valid UUID found in QR Code Scan!"
                    }
                }
            }
        }

    }
}

//MARK: APIClient Protocol Required Functions
extension ViewController: InventoryDelegate {
    
    func didCreateBaseline(storageLocation: StorageLocation) {
        print("New Baseline Created \(storageLocation.id)")
    }
    
    func didCheckInventory(inventoryCheck: InventoryCheck) {
        print("Performed Inventory Check \(inventoryCheck.id)")
    }
    
    func didFailImageUpload(error: APIError) {
        print("Image Upload Failed: \(error.localizedDescription) ")
    }
}

/// used to notify the delegate when a new storage location has been created
extension ViewController: NewStorageLocationDelegate {
    func didCreateStorageLocation(storageLocation: StorageLocation){
        print("New Storage Location Created \(storageLocation.id)")
        new_sloc_UUID = storageLocation.id
    }
    func didFailCreatingStorageLocation(error: APIError){
        print(" Failed to Create New Storage Location: \(error.localizedDescription) ")
    }
}

extension ViewController: StorageLocationsDelegate {
    func didFetchStorageLocations(locations: [StorageLocation]) {
        print("Successfully Fetched StorageLocations \([locations])")
    }
    func didFailFetchingStorageLocations(error: APIError) {
        print(" Failed to Fetch Storage Locations: \(error.localizedDescription) ")
    }
}

extension ViewController: HistoryDelegate {
    func didFetchHistory(storageLocation: StorageLocation, history: [InventoryCheck]) {
        print("Successfully Fetched History for StorageLocation: \(storageLocation.id)")
    }
    func didFailFetchingHistory(error: APIError) {
        print(" Failed to Fetch History: \(error.localizedDescription) ")
    }
}


// MARK: - TrayViewControllerDelegate
extension ViewController: TrayViewControllerDelegate {
    func didSend_sloc_name (_ sloc_name: String) {
        new_sloc_name = sloc_name
        print("VC: new_sloc_name = \(String(describing: new_sloc_name))")
    }
    func didSend_sloc_description (_ sloc_description: String) {
        new_sloc_description = sloc_description
        print("VC: new_sloc_description = \(String(describing: new_sloc_description))")
    } 

}
