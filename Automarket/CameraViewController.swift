//
//  CameraViewController.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 10.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit

final class CameraViewController: UIViewController {

	var timer: Timer?

	var cameraPickerViewConrtoller: UIImagePickerController!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		if UIImagePickerController.isSourceTypeAvailable(.camera) {

			let screenSize:CGSize = UIScreen.main.bounds.size
			let ratio:CGFloat = 4.0 / 3.0
			let cameraHeight:CGFloat = screenSize.width * ratio
			let scale:CGFloat = screenSize.height / cameraHeight

			cameraPickerViewConrtoller = UIImagePickerController()
			cameraPickerViewConrtoller.sourceType = .camera
			cameraPickerViewConrtoller.delegate = self
			cameraPickerViewConrtoller.allowsEditing = false
			cameraPickerViewConrtoller.showsCameraControls = false
			cameraPickerViewConrtoller.cameraViewTransform = CGAffineTransform(translationX: 0, y: (screenSize.height - cameraHeight) / 2.0)
			cameraPickerViewConrtoller.cameraViewTransform = cameraPickerViewConrtoller.cameraViewTransform.scaledBy(x: scale, y: scale)
			present(cameraPickerViewConrtoller, animated: true, completion: nil)
			createTimer()
		}
	}
}

// MARK: UIImagePickerControllerDelegate
extension CameraViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[.originalImage] as? UIImage {
			print(image)
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
	}
}

// MARK: - Timer
extension CameraViewController {
	@objc func updateTimer() {
		//  Делаем скриншот - отправляем на сервер
		cameraPickerViewConrtoller.takePicture()
	}

	func createTimer() {
		if timer == nil {
				timer = Timer.scheduledTimer(timeInterval: 1.0,
											 target: self,
											 selector: #selector(updateTimer),
											 userInfo: nil,
											 repeats: true)
		}
	}
}

// MARK: - Helpers
extension CameraViewController {
	/// Takes the screenshot of the screen and returns the corresponding image
	///
	/// - Parameter shouldSave: Boolean flag asking if the image needs to be saved to user's photo library. Default set to 'true'
	/// - Returns: (Optional)image captured as a screenshot
	private func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {

		UIGraphicsBeginImageContext(cameraPickerViewConrtoller.view.frame.size)
		view.layer.render(in: UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}
}
