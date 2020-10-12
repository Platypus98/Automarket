//
//  CameraViewController.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 10.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FittedSheets

final class NewCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

	private lazy var crossButton: UIButton = {
		let button = UIButton()
		button.setTitle("╳", for: .normal)
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
		button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private lazy var activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.startAnimating()
		indicator.isHidden = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()

	private var timer: Timer?
	private let photoOutput = AVCapturePhotoOutput()
	private let carRecognitionRequest = CarRecognitionRequest()

	override func viewDidLoad() {
		super.viewDidLoad()
		carRecognitionRequest.viewDelegate = self
		createTimer()
		openCamera()
		setupUI()
	}

	private func setupUI() {
		view.addSubview(crossButton)
		view.addSubview(activityIndicator)

		NSLayoutConstraint.activate([
			crossButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
			crossButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
			crossButton.widthAnchor.constraint(equalToConstant: 50),
			crossButton.heightAnchor.constraint(equalToConstant: 50)
		])

		NSLayoutConstraint.activate([
			activityIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
			activityIndicator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
			activityIndicator.widthAnchor.constraint(equalToConstant: 50),
			activityIndicator.heightAnchor.constraint(equalToConstant: 50)
		])
	}

    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                }
            }
        case .denied:
            print("the user has denied previously to access the camera.")
        case .restricted:
            print("the user can't give camera access due to some restriction.")
        default:
            print("something has wrong due to we can't access the camera.")
        }
    }

    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
		photoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
			cameraLayer.connection?.videoOrientation = .portrait
            self.view.layer.addSublayer(cameraLayer)

            captureSession.startRunning()
        }
    }

	@objc private func closeButtonTapped() {
		self.dismiss(animated: true, completion: nil)
	}

    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let imageData = photo.fileDataRepresentation() else { return }
		var previewImage = UIImage(data: imageData)
		previewImage = UIImage(cgImage: previewImage!.cgImage!, scale: previewImage!.scale, orientation: .right)
//		UIImageWriteToSavedPhotosAlbum(previewImage!, nil, nil, nil)
		print("Сделали фото")
		activityIndicator.isHidden = false
		DispatchQueue.global(qos: .background).async {
			self.carRecognitionRequest.sendCarRecognitionRequest(image: previewImage!)
		}
    }
}

// MARK: - Timer
extension NewCameraViewController {
	@objc func updateTimer() {
		//  Делаем скриншот - отправляем на сервер
		handleTakePhoto()
	}

	func createTimer() {
		timer = Timer.scheduledTimer(timeInterval: 1.5,
											 target: self,
											 selector: #selector(updateTimer),
											 userInfo: nil,
											 repeats: false)
	}
}

// MARK: ViewDelegate
extension NewCameraViewController {
	func recievedCarRecognitionSuccess(carDataResult: CarRecognitionResponse?) {
		DispatchQueue.main.async {
			if !(carDataResult?.found ?? false) {
				self.activityIndicator.isHidden = true
				self.createTimer()
				return
			}

			guard let carDataResultUnw = carDataResult else {
				self.activityIndicator.isHidden = true
				self.createTimer()
				return
			}

			let controller = CarInfoViewController(carMainInfo: carDataResultUnw)
			let sheetController = SheetViewController(
				controller: controller,
				sizes: [.percent(0.15), .marginFromTop(40)])

			sheetController.didDismiss = { [weak self] _ in
				self?.activityIndicator.isHidden = true
				self?.createTimer()
			}
			self.activityIndicator.isHidden = true
			self.present(sheetController, animated: true, completion: nil)
		}
	}

	func recievedCarRecognitionError() {
		activityIndicator.isHidden = false
		createTimer()
	}

}
