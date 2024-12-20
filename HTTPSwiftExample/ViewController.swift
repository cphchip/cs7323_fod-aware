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
   // var new_sloc_UUID: String?
    
    // name of the new storage location
    var new_sloc_name: String?
    
    // description of the storage location
    var new_sloc_description: String?
    
    // date that the storage location was created
    var new_date_created: Date?
    
    var trayVC_delegate: TrayViewControllerDelegate?
    
    //var newBaseline: Bool = false  //new Baseline indication
    var newBaselineImage_uploaded: Bool = false  //new Baseline Image uploaded indication
    
    
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

        // Create an attributed string with the desired font
        let title = NSAttributedString(
            string: "Start camera",
            attributes: [
                .font: UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ]
        )
        
        // use delegation for interacting with client
        client.inventoryDelegate = self
        trayVC_delegate = self
        
        
        // Set the attributed title for the button's normal state
        StartStopCamera.setAttributedTitle(title, for: .normal)

        // Call function to create the camera shutter button
        setupShutterButton()
    }
    
    override func viewWillAppear(_ animated:Bool)  {
        super.viewWillAppear(animated)
        // use delegation for interacting with client
        //client.inventoryDelegate = self
        //trayVC_delegate = self
    }
    
    // Create a camera shutter button (code referenced from chatGPT)
    func setupShutterButton() {
        let shutterButton = UIButton(type: .system)
        shutterButton.setTitle("Shutter", for: .normal)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 35
        shutterButton.layer.borderWidth = 4
        shutterButton.layer.borderColor = UIColor.black.cgColor
        
        // Apply a shadow to increase button visibility on white backgrounds
        shutterButton.layer.shadowColor = UIColor.black.cgColor
        shutterButton.layer.shadowOpacity = 0.3
        shutterButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        shutterButton.layer.shadowRadius = 4
        
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.addTarget(self, action: #selector(capturePhotoButtonTapped), for: .touchUpInside)

        view.addSubview(shutterButton)

        // Add constraints
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: StartStopCamera.centerYAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTrayViewController" {
            guard let destinationVC = segue.destination as? TrayViewController else {
                print("destinationVC is nil")
                return
            }
            //newBaseline = true
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
            //let targetSize = CGSize(width: 512, height: 512)
            //let resizedImage = resizeImage(image: image, targetSize: targetSize)
            let resizedImage = image
            print("Image captured: \(resizedImage.size)")
            // Convert UIImage to JPEG data
            if let jpegData = resizedImage.jpegData(compressionQuality: 1.0)
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
                
                // Create an attributed string with the desired font and set it as the button's title
                let stopTitle = NSAttributedString(
                    string: "Stop camera",
                    attributes: [
                        .font: UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17),
                        .foregroundColor: UIColor.black
                    ]
                )
                self.StartStopCamera.setAttributedTitle(stopTitle, for: .normal)
                
                self.capturedImageView.isHidden = true  // Hide the image view when the camera starts
            }
        }
    }

    func stopCamera() {
        // Stop the capture session
        captureSession.stopRunning()
        isCameraRunning = false
        // Set the button's initial title with Avenir Next DemiBold font
        let initialTitle = NSAttributedString(
            string: "Start camera",
            attributes: [
                .font: UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17),
                .foregroundColor: UIColor.black
            ]
        )

        // Apply the attributed title to the button for the normal state
        StartStopCamera.setAttributedTitle(initialTitle, for: .normal)

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
        
        //if newBaseline {
           //Initiate creation of the new storage location
           //client.createStorageLocation(withName: new_sloc_name ?? "", andDescription: new_sloc_description ?? "")
        //}
        uploadImage()
    }
    
    //UpLoad Image
    func uploadImage() {
        if currentResizedImage == nil {
            currentResizedImage = Shared_VCdata.sharedData.defaultObjectImage
            print("Image was nil, setting to default")
            //newBaseline = false
            Shared_VCdata.sharedData.newBaseline = false
            return
        }
        
        if Shared_VCdata.sharedData.newBaseline {
            print("VC-uploadImage - Uploading New Baseline Image")
            feedbackLabel.text =  "Uploading New Baseline Image!"
            
            if let storageLocationID = Shared_VCdata.sharedData.new_sloc_UUID {  // new sloc UUID
                if !newBaselineImage_uploaded {
                    client.uploadImage(image: currentResizedImage, forStorageLocation: storageLocationID)
                    //newBaseline = false
                    Shared_VCdata.sharedData.newBaseline = false
                    newBaselineImage_uploaded = true
                }
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
        print("VC: New Baseline Created \(storageLocation.id)")
        Shared_VCdata.sharedData.new_sloc_UUID = storageLocation.id
        //newBaseline = true
        Shared_VCdata.sharedData.newBaseline = true
        newBaselineImage_uploaded = false
    }
    
    func didCheckInventory(inventoryCheck: InventoryCheck) {
        print("Performed Inventory Check: ID = \(inventoryCheck.id)")
        print("Inventory Check: Inventory_Complete = \(inventoryCheck.inventory_complete)")
        print("Inventory Check: Matches_Baseline = \(inventoryCheck.matches_baseline)")
        print("Inventory Check: Image_Name = \(inventoryCheck.image_name)")
        print("Inventory Check: Date_Created = \(inventoryCheck.created)")
        DispatchQueue.main.async{
            if !inventoryCheck.matches_baseline{
                self.view.backgroundColor = .red  // set background to red if does not match
            }
            else{
                self.view.backgroundColor = .green  // set background to red if does not match
            }
        }

    }
    
    func didFailImageUpload(error: APIError) {
        print("Image Upload Failed: \(error.localizedDescription) ")
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
    func didSend_create_baseline (_ sloc_id: String) {
        print("VC: Baseline Created! Id = \(sloc_id)")
        //newBaseline = true
        Shared_VCdata.sharedData.newBaseline = true
        newBaselineImage_uploaded = false
    }

}
