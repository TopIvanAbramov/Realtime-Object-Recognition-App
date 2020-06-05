//
//  ViewController.swift
//  RealTimeObjectRecognition
//
//  Created by Иван Абрамов on 01.04.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let label = UILabel()
    let previewLayer = AVCaptureVideoPreviewLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video)  else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice)  else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        
        previewLayer.session = captureSession
        
        view.layer.addSublayer(previewLayer)
        
        addLabel()
        
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(dataOutput)
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    }
    
//    Add label which will  display recognized object
    
    func addLabel() {
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = "Here will name of recognized object"
        label.font = UIFont(name: "Apple Symbols", size: 25.0)
        label.numberOfLines = 0
        label.numberOfLines = 0
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70.0),
            label.widthAnchor.constraint(equalToConstant: 200.0),
            label.heightAnchor.constraint(equalToConstant: 50.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

//    Recognize object from camera
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if error == nil {
                guard let results = request.results as? [VNClassificationObservation] else { return }
                
                guard let firstObservation = results.first else  { return }
                let firstRecognizedELement = firstObservation.identifier.components(separatedBy: ",")[0]
                self.changelabel(text: "\(firstRecognizedELement.capitalized) \(self.roundFloat(value: firstObservation.confidence * 100))")
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func changelabel(text : String) {
        DispatchQueue.main.async {
            self.label.text = text
        }
    }
    
    func roundFloat(value : Float) -> String {
        return String(format: "%.2f", value)
    }
}

