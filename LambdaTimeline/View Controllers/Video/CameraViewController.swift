//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        let videoDevice = self.bestCamera()
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput) else {fatalError()}
        
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError()
        }
        captureSession.addOutput(fileOutput)
        self.recordOutput = fileOutput
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        cameraPreviewView.videoPreviewLayer.session = captureSession
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    //MARK: - Action
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: self.newRecordingURL(), recordingDelegate: self)
        }
        
    }
    
    //MARK: private method
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let document = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return document.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private func updateViews() {
        guard isViewLoaded else {return}
        
        let isRecording = recordOutput?.isRecording ?? false
        let recordButtonImage: String = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImage), for: .normal)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        defer {self.updateViews()}
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                NSLog("Please give video recorder access to your photo library")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }, completionHandler: { (sucess, error) in
                if let error = error {
                    NSLog("there is an error \(error)")
                }
                if sucess {
                    DispatchQueue.main.async {
                        self.presentSucessAlert()
                    }
                }
            })
        }
    }
    
    private func presentSucessAlert() {
        let alert = UIAlertController(title: "video saved", message: "yeah!!", preferredStyle: .alert)
        let oakyAction = UIAlertAction(title: "okay", style: .default, handler: nil)
        alert.addAction(oakyAction)
        
        let photosAction = UIAlertAction(title: "open photos", style: .default) { (_) in
            UIApplication.shared.open(URL(string: "photos-redirect://")!, options: [:], completionHandler: nil)
        }
        
        alert.addAction(photosAction)
        self.present(alert, animated: true, completion: nil)
    }
}

/*
 use AVFoundation’s camera capture APIs to capture video from the camera
 use AVPlayer to play video
 AVPlayerLayer for
 */

