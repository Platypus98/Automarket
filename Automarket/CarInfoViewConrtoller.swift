//
//  CarInfoViewConrtoller.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 10.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit
import FSPagerView

final class CarInfoViewController: UIViewController {

	private let carMainInfo: CarRecognitionResponse
	private var carImages: [UIImage] = []
	    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()

	private var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = Locale.current
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 0
		formatter.currencySymbol = "₽"
		return formatter
	}()

	/// Название машины
	private lazy var carNameLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	/// Цена мащины
	private lazy var carPriceLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	/// Фото машины
	private lazy var carImage: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private lazy var carImageCollectionView: FSPagerView = {
		let collectionView = FSPagerView()
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.transformer = FSPagerViewTransformer(type: .linear)
		collectionView.interitemSpacing = 5
		return collectionView
	}()

	/// Сепаратор под фото
	private lazy var firstSeparator: UIView = {
		let separator = UIView()
		separator.backgroundColor = .gray
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()

	/// Сепаратор под страной
	private lazy var secondSeparator: UIView = {
		let separator = UIView()
		separator.backgroundColor = .gray
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()

	/// Типы кузовов
	private lazy var bodyTypes: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.textAlignment = .left
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	/// Страна
	private lazy var countryLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.textAlignment = .left
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var speaksLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.text = "Что говорят про этот автомобиль?"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		return label
	}()

	private lazy var firstYouTubeCell: YouTubeCellView = {
		let cell = YouTubeCellView()
		cell.translatesAutoresizingMaskIntoConstraints = false
		cell.imageView.isUserInteractionEnabled = true

		let singleTap = UITapGestureRecognizer(target: self, action: #selector(openFirstUrlYoutube))
		singleTap.numberOfTapsRequired = 1
		cell.imageView.addGestureRecognizer(singleTap)
		return cell
	}()

	private lazy var secondYouTubeCell: YouTubeCellView = {
		let cell = YouTubeCellView()
		cell.translatesAutoresizingMaskIntoConstraints = false
		cell.imageView.isUserInteractionEnabled = true

		let singleTap = UITapGestureRecognizer(target: self, action: #selector(openSecondUrlYoutube))
		singleTap.numberOfTapsRequired = 1
		cell.imageView.addGestureRecognizer(singleTap)
		return cell
	}()

	private lazy var thirdSeparator: UIView = {
		let separator = UIView()
		separator.backgroundColor = .gray
		separator.translatesAutoresizingMaskIntoConstraints = false
		return separator
	}()

	private lazy var continueButton: Button = {
		let button = Button()
		button.setTitle("Перейти к расчету", for: .normal)
		button.setTitleColor(UIColor.white, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(contiueButtonTapped), for: .touchUpInside)
		return button
	}()

	private lazy var listenLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.text = "Лучше 1 раз увидеть, чем 100 раз услышать"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		return label
	}()

	init(carMainInfo: CarRecognitionResponse) {
		self.carMainInfo = carMainInfo
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.sheetViewController?.handleScrollView(self.scrollView)
		view.backgroundColor = .white
		carNameLabel.text = carMainInfo.carName
		if let carPriceUnw = carMainInfo.carInfo?.minPrice {
			carPriceLabel.text = "От " + String(formatter.string(from: carPriceUnw as NSNumber) ?? "")
		}
		if let bodyTypesUnw = carMainInfo.carInfo?.bodies {
			bodyTypes.text = "Типы кузова: " + bodyTypesUnw.joined(separator: ", ")
		}
		if let carCountry = carMainInfo.carInfo?.country {
			countryLabel.text = "Страна бренда: " + carCountry
		}
		setupUI()

		downloadCarPhotos {
			DispatchQueue.main.async { [weak self] in
				self?.carImageCollectionView.reloadData()
			}
		}

		downloadImage(url: URL(string: self.carMainInfo.youtubeVideos.first!.pictureUri)!) { [weak self] image in
			DispatchQueue.main.async {
				self?.firstYouTubeCell.imageView.image = image
				self?.firstYouTubeCell.label.text = self?.carMainInfo.youtubeVideos.first?.name
			}
		}

		downloadImage(url: URL(string: self.carMainInfo.youtubeVideos[1].pictureUri)!) { [weak self] image in
			DispatchQueue.main.async {
				self?.secondYouTubeCell.imageView.image = image
				self?.secondYouTubeCell.label.text = self?.carMainInfo.youtubeVideos[1].name
			}
		}
	}

	private func downloadCarPhotos(completion: @escaping () -> Void) {
		DispatchQueue.global().async {
			guard let carInfoUnw = self.carMainInfo.carInfo else { return }
			for url in carInfoUnw.photos {
				let semaphore = DispatchSemaphore(value: 0)
				if let urlUnw = URL(string: url) {
					self.downloadImage(url: urlUnw) { [weak self] image in
						self?.carImages.append(image)
						semaphore.signal()
					}
				} else {
					semaphore.signal()
				}

				_ = semaphore.wait(timeout: .distantFuture)
			}
			completion()
		}
	}

	@objc private func contiueButtonTapped() {
		let controller = CreditViewController(carMainInfo: self.carMainInfo)
		self.modalPresentationStyle = .fullScreen
		self.present(controller, animated: true, completion: nil)
	}

	@objc private func openFirstUrlYoutube() {
		UIApplication.shared.open(URL(string: self.carMainInfo.youtubeVideos.first!.uri)!,
								  options: [:],
								  completionHandler: nil)
	}

	@objc private func openSecondUrlYoutube() {
		UIApplication.shared.open(URL(string: self.carMainInfo.youtubeVideos[1].uri)!,
								  options: [:],
								  completionHandler: nil)
	}

	private func setupUI() {
		view.addSubview(scrollView)
		scrollView.addSubview(carNameLabel)
		scrollView.addSubview(carPriceLabel)
		scrollView.addSubview(carImageCollectionView)
		scrollView.addSubview(firstSeparator)
		scrollView.addSubview(bodyTypes)
		scrollView.addSubview(countryLabel)
		scrollView.addSubview(secondSeparator)
		scrollView.addSubview(speaksLabel)
		scrollView.addSubview(firstYouTubeCell)
		scrollView.addSubview(secondYouTubeCell)
		scrollView.addSubview(thirdSeparator)
//		view.addSubview(listenLabel)
		scrollView.addSubview(continueButton)

		NSLayoutConstraint.activate([
			scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
			scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
			scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0),
		])

		NSLayoutConstraint.activate([
			carNameLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			carNameLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35),
			carNameLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			carNameLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
		])

		NSLayoutConstraint.activate([
			carPriceLabel.centerXAnchor.constraint(equalTo: carNameLabel.centerXAnchor),
			carPriceLabel.topAnchor.constraint(equalTo: carNameLabel.bottomAnchor, constant: 11),
			carPriceLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			carPriceLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
		])

		NSLayoutConstraint.activate([
			carImageCollectionView.centerXAnchor.constraint(equalTo: carNameLabel.centerXAnchor),
			carImageCollectionView.topAnchor.constraint(equalTo: carPriceLabel.bottomAnchor, constant: 40),
			carImageCollectionView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			carImageCollectionView.heightAnchor.constraint(equalToConstant: 200)
		])

		NSLayoutConstraint.activate([
			firstSeparator.topAnchor.constraint(equalTo: carImageCollectionView.bottomAnchor, constant: 20),
			firstSeparator.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5),
			firstSeparator.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -5),
			firstSeparator.heightAnchor.constraint(equalToConstant: 1)
		])

		NSLayoutConstraint.activate([
			bodyTypes.centerXAnchor.constraint(equalTo: firstSeparator.centerXAnchor),
			bodyTypes.topAnchor.constraint(equalTo: firstSeparator.bottomAnchor, constant: 20),
			bodyTypes.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			bodyTypes.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
		])

		NSLayoutConstraint.activate([
			countryLabel.centerXAnchor.constraint(equalTo: bodyTypes.centerXAnchor),
			countryLabel.topAnchor.constraint(equalTo: bodyTypes.bottomAnchor, constant: 20),
			countryLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			countryLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
		])

		NSLayoutConstraint.activate([
			secondSeparator.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 20),
			secondSeparator.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5),
			secondSeparator.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -5),
			secondSeparator.heightAnchor.constraint(equalToConstant: 1)
		])

		NSLayoutConstraint.activate([
			speaksLabel.centerXAnchor.constraint(equalTo: secondSeparator.centerXAnchor),
			speaksLabel.topAnchor.constraint(equalTo: secondSeparator.bottomAnchor, constant: 20),
			speaksLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			speaksLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
		])

		NSLayoutConstraint.activate([
			firstYouTubeCell.topAnchor.constraint(equalTo: speaksLabel.bottomAnchor, constant: 5),
			firstYouTubeCell.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			firstYouTubeCell.rightAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: -15),
			firstYouTubeCell.heightAnchor.constraint(equalToConstant: 170)
		])

		NSLayoutConstraint.activate([
			secondYouTubeCell.topAnchor.constraint(equalTo: speaksLabel.bottomAnchor, constant: 5),
			secondYouTubeCell.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
			secondYouTubeCell.leftAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 15),
			secondYouTubeCell.heightAnchor.constraint(equalToConstant: 170)
		])

		NSLayoutConstraint.activate([
			thirdSeparator.topAnchor.constraint(equalTo: secondYouTubeCell.bottomAnchor, constant: 20),
			thirdSeparator.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5),
			thirdSeparator.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -5),
			thirdSeparator.heightAnchor.constraint(equalToConstant: 1)
		])

//		NSLayoutConstraint.activate([
//			listenLabel.centerXAnchor.constraint(equalTo: thirdSeparator.centerXAnchor),
//			listenLabel.topAnchor.constraint(equalTo: thirdSeparator.bottomAnchor, constant: 20),
//			listenLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
//			listenLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
//		])

		NSLayoutConstraint.activate([
			continueButton.centerXAnchor.constraint(equalTo: thirdSeparator.centerXAnchor),
			continueButton.topAnchor.constraint(equalTo: thirdSeparator.bottomAnchor, constant: 20),
			continueButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			continueButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15),
		])
	}
}

// MARK: - Download Images
extension CarInfoViewController {

	private func downloadImage(url: URL, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
						completion(image)
                }
			}
		}
	}
}

extension CarInfoViewController: FSPagerViewDataSource {
	func numberOfItems(in pagerView: FSPagerView) -> Int {
		return self.carImages.count
	}

	func pagerView(_ pagerView: FSPagerView,
				   cellForItemAt index: Int) -> FSPagerViewCell {
		let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
		if self.carImages.count != 0 {
			cell.imageView?.contentMode = .scaleAspectFill
			cell.imageView?.image = self.carImages[index]
			return cell
		}
		return cell
	}
}

extension CarInfoViewController: FSPagerViewDelegate {

}
