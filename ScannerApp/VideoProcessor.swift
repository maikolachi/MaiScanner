//
//  VideoProcessor.swift
//  ScannerApp
//
//  Created by Faisal Bhombal on 9/26/20.
//

import Foundation
import AVFoundation
import Vision

class VideoProcessor: NSObject {
    
    lazy var barcodeDetectionRequest: VNDetectBarcodesRequest = {
        let barcodeDetectRequest = VNDetectBarcodesRequest(completionHandler: self.handleDetectedBarcodes)
        // Restrict detection to most common symbologies.
//        barcodeDetectRequest.symbologies = [.QR, .Aztec, .UPCE]
        return barcodeDetectRequest
    }()
    
    fileprivate func handleDetectedBarcodes(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            print(nsError)
            return
        }
        if let results = request?.results {
            if results.count == 0 {
                return
            }
            print("READ \(results.count)")
            for b in results {
                if let observation = b as? VNBarcodeObservation {
                    print("\(observation.symbology) \(observation.payloadStringValue ?? "") \(observation.topLeft) \(observation.bottomRight)")
                    print(observation.boundingBox)
                }
            }
        } else {
//            print("No barcodes")
        }
    }
}


extension VideoProcessor: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
        let requests = detectionRequests
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        
        
        // Send the requests to the request handler.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
//                print("performing requests")
                try handler.perform(requests)
            } catch let error as NSError {
                print("request FAILED")
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        print("frame dropped")
    }
    

}

extension VideoProcessor {
    
    fileprivate var detectionRequests: [VNRequest] {
        return [self.barcodeDetectionRequest]
    }
    
//    fileprivate func createDetectionRequests() -> [VNRequest] {
        
        // Create an array to collect all desired requests.
//        var requests: [VNRequest] = []
        
        
//        // Create & include a request if and only if switch is ON.
//        if self.rectSwitch.isOn {
//            requests.append(self.rectangleDetectionRequest)
//        }
//        if self.faceSwitch.isOn {
//            // Break rectangle & face landmark detection into 2 stages to have more fluid feedback in UI.
//            requests.append(self.faceDetectionRequest)
//            requests.append(self.faceLandmarkRequest)
//        }
//        if self.textSwitch.isOn {
//            requests.append(self.textDetectionRequest)
//        }
//        if self.barcodeSwitch.isOn {
//            requests.append(self.barcodeDetectionRequest)
//        }
//
//        // Return grouped requests as a single array.
//        return requests
//    }
}
    
