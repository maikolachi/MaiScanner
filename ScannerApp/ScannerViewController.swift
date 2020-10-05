//
//  Created by Faisal Bhombal on 9/25/20.
//

import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {

    let videoProcessor = VideoProcessor()
    var bufferSize: CGSize = .zero
    
    @IBOutlet weak var previewView: UIView!
    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let outputQueue = DispatchQueue(label: "VIDEOOUTPUT", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private var rootLayer: CALayer!
    private var identityLayer =  CAShapeLayer()
    private var detectionOverlay: CALayer!
    
    @IBOutlet weak var liveView: UIView!

    var trackingLevel = VNRequestTrackingLevel.accurate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
//        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        guard
            let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first,
            let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        session.beginConfiguration()
//        session.sessionPreset = .high
        session.sessionPreset = .high
        // Add a video input
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            output.setSampleBufferDelegate(videoProcessor, queue: outputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let connection = output.connection(with: .video)
        connection?.isEnabled = true
        do {
            try device.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
        
        //
        detectionOverlay = CALayer()
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0, y: 0.0, width: bufferSize.width, height: bufferSize.height)
        let centerRoot = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        detectionOverlay.position = centerRoot
        rootLayer.addSublayer(detectionOverlay)
        
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        let t = CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale)
//        detectionOverlay.setAffineTransform(t)
//        identityLayer.setAffineTransform(t)
        // center the layer
//        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
    
        CATransaction.commit()
    
//        identityLayer.bounds = bounds
        
        let boxWidth: CGFloat = 207// (bounds.width * 0.75) / scale
        let boxHeight: CGFloat = 414 //boxWidth * 2
        
//        let x = bounds.width / 2 - boxWidth / 2
//        let y = bounds.minY + 48 // detectionOverlay.frame.height * 0.3 - boxHeight / 2
//        identityLayer.bounds = detectionOverlay.bounds
//        identityLayer.position = CGPoint(x: detectionOverlay.bounds.midX, y: detectionOverlay.bounds.midY)
//        identityLayer.frame = detectionOverlay.frame
//        identityLayer.position = CGPoint(x: detectionOverlay.bounds.minX, y: detectionOverlay.bounds.midY)
        identityLayer.frame = detectionOverlay.frame
        detectionOverlay.addSublayer(identityLayer)
        
        
//        identityLayer.position = CGPoint(x: detectionOverlay.frame.midX, y: detectionOverlay.frame.midY)

//        identityLayer.setAffineTransform(<#T##m: CGAffineTransform##CGAffineTransform#>)
        
        
        let xOrigin = -detectionOverlay.frame.minY
        let yOrigin = -detectionOverlay.frame.minX
//        identityLayer.path = UIBezierPath(rect: CGRect(x: xOrigin, y: yOrigin, width: boxWidth, height: boxHeight)).cgPath
//
        print(xOrigin)
        print(yOrigin)
        
        let r = CGRect(x: 1000 , y: 2000, width: 100, height: 200)
        // CGRect(x: 200, y: 200, width: boxWidth, height: boxHeight).applying(t)
        identityLayer.path = UIBezierPath(rect: r ).cgPath
        
        identityLayer.fillColor = UIColor.green.cgColor
        identityLayer.lineWidth = 16
        identityLayer.strokeColor = UIColor.red.cgColor
        
        
//        detectionOverlay.addSublayer(identityLayer)
        self.startCaptureSession()
        
        //        let boxXScale = boxWidth / detectionOverlay.frame.width
        //        let boxYScale = boxHeight / detectionOverlay.frame.height

        
        
//        let error: NSError?
        
//        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
//            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
//        }
//        do {
//            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
//                DispatchQueue.main.async(execute: {
//                    // perform all the UI updates on the main queue
//                    if let results = request.results {
//                        self.drawVisionRequestResults(results)
//                    }
//                })
//            })
//            self.requests = [objectRecognition]
//        } catch let error as NSError {
//            print("Model loading went wrong: \(error)")
//        }
//
//        return error
        

        self.startCaptureSession()
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

extension ScannerViewController {
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}
