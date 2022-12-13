//
//  ViewController.swift
//  VideoRecording
//
//  Created by Aparna Tati on 12/12/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // MARK: - Outlets and Variable Declarations
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imagePickerView: UIView!
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var movieOutput = AVCaptureMovieFileOutput()
    var videoCaptureDevice : AVCaptureDevice?
    
    // MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // livePreviewUsingImagePicker()
        recordVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = "Video Recording"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds: CGRect = imagePickerView.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.bounds = bounds
        previewLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: - Class Methods
    func livePreviewUsingImagePicker() {
        // first way we can do using UIImagePickerController
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            if (UIImagePickerController.availableCaptureModes(for: .front) != nil) {
                imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
                imagePicker.cameraCaptureMode = .video
                imagePicker.cameraDevice = .front
                imagePicker.videoQuality = .typeHigh
                imagePicker.delegate = self
                imagePicker.view.frame = self.imagePickerView.bounds
                self.imagePickerView.addSubview(imagePicker.view)
                addChild(imagePicker)
            } else {
                debugPrint("Front camera is not available")
            }
        } else {
            debugPrint("Camera is Not available")
        }
    }
    
    func recordVideo() {
        // second way we can do using AVFoundation
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        videoCaptureDevice = availableDevices.first
        if let videoCaptureDevice = videoCaptureDevice {
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: videoCaptureDevice))
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                imagePickerView.layer.addSublayer(previewLayer)
                captureSession.addOutput(self.movieOutput)
                captureSession.startRunning()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Action Methods
    @IBAction func buttonClicked(_ sender: UIButton) {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            titleLabel.text = "Recording Stopped"
        } else {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent("output.mov")
            print(fileUrl)
            try? FileManager.default.removeItem(at: fileUrl)
            movieOutput.startRecording(to: fileUrl, recordingDelegate: self as AVCaptureFileOutputRecordingDelegate)
            titleLabel.text = "Recording Started"
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        debugPrint("Video Captured")
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate 
extension ViewController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        }
    }
}
