//
//  QRCodeScanner.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/14/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit
import Vision

class QRCodeScanner {
    func detectQRCode(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        // for testing without QR code
        completion("6762268096b5d255b8f0cdec")
        return
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("Error detecting QR code: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation] else {
                completion(nil)
                return
            }
            
            for result in results {
                if result.symbology == .qr, let payload = result.payloadStringValue {
                    
                    completion(payload)
                    return

                }
            }
            completion(nil)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform QR code detection: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

