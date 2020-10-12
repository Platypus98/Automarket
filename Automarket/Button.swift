//
//  Button.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 10.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit

final class Button: UIButton {

	var label: UITextView!

	override init(frame: CGRect) {
	  super.init(frame: frame)
	  setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		backgroundColor = SemanticColors.buttonColor
		layer.cornerRadius = 8
		layer.masksToBounds = true
	}
}
