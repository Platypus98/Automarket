//
//  ViewController.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 10.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

	private lazy var loginButton: Button = {
		let button = Button()
		button.setTitle("Найти", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(tappedToLogin), for: .touchUpInside)
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupLayout()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		.darkContent
	}

	private func setupLayout() {
		view.addSubview(loginButton)
		NSLayoutConstraint.activate([
			loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			loginButton.widthAnchor.constraint(equalToConstant: 200),
			loginButton.heightAnchor.constraint(equalToConstant: 40)])
	}

	// MARK: Helpers
	@objc private func tappedToLogin() {
		let cameraViewController = NewCameraViewController()
		cameraViewController.modalPresentationStyle = .fullScreen
		present(cameraViewController, animated: true, completion: nil)
	}
}
