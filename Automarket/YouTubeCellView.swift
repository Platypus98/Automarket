//
//  YouTubeCellView.swift
//  Automarket
//
//  Created by 17815062 on 11.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit

final class YouTubeCellView: UIView {

	var imageView: UIImageView!
	var label: UILabel!

	override init(frame: CGRect) {
	  super.init(frame: frame)
	  setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		backgroundColor = SemanticColors.buttonColor
		self.backgroundColor = .white
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false

		label = UILabel()
		label.numberOfLines = 0
		label.textColor = .black
		label.textAlignment = .left
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.translatesAutoresizingMaskIntoConstraints = false

		setUpLayout()
	}

	private func setUpLayout() {
		self.addSubview(imageView)
		self.addSubview(label)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: self.topAnchor),
			imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
			imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
			imageView.heightAnchor.constraint(equalToConstant: 125)
		])

		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 2),
			label.leftAnchor.constraint(equalTo: self.leftAnchor),
			label.rightAnchor.constraint(equalTo: self.rightAnchor),
			label.heightAnchor.constraint(equalToConstant: 45)
		])
	}
}
