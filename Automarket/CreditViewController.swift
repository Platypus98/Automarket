//
//  CreditViewController.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 11.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit

final class CreditViewController: UIViewController {

	let calculateRequest = CalculateRequest()
	let stepYear: Float = 1
	let stepFirstPay: Float = 1
	let stepLastPay: Float = 1000
	private let carMainInfo: CarRecognitionResponse

	private var scrollView: UIScrollView!

	let year = 0.0
	let firstPay = 0.0
	var lastPay = 0.0

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Рассчитать стоимость покупки"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		return label
	}()

	private lazy var kaskoLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .left
		label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		return label
	}()

	private lazy var yearSlider: UISlider = {
		let slider = UISlider()
		slider.isContinuous = true
		slider.minimumValue = 1
		slider.maximumValue = 7
		slider.value = 3
		slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(yearSliderValueDidChange(_:)), for: .valueChanged)
		return slider
	}()

	private lazy var yearLabel: UILabel = {
		let label = UILabel()
		label.text = "3"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
		return label
	}()

	private lazy var yearLabelDescription: UILabel = {
		let label = UILabel()
		label.text = "Срок (лет)"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		return label
	}()

	private var formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = Locale.current
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 0
		formatter.currencySymbol = "₽"
		return formatter
	}()

	private lazy var firstPayLabel: UILabel = {
		let label = UILabel()
		label.text = "30"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
		return label
	}()

	private lazy var firstPayDescription: UILabel = {
		let label = UILabel()
		label.text = "Первичный платеж (%)"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		return label
	}()

	private lazy var firstPaySlider: UISlider = {
		let slider = UISlider()
		slider.isContinuous = true
		slider.minimumValue = 20
		slider.maximumValue = 99
		slider.value = 30
		slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(firstPaySliderValueDidChange(_:)), for: .valueChanged)
		return slider
	}()

	private lazy var lastPayLabel: UILabel = {
		let label = UILabel()
		label.text = "0"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
		return label
	}()

	private lazy var lastPayDescription: UILabel = {
		let label = UILabel()
		label.text = "Остаточный платеж (₽)"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		return label
	}()

	private lazy var lastPaySlider: UISlider = {
		let slider = UISlider()
		slider.isContinuous = true
		slider.minimumValue = 0
		slider.maximumValue = Float(self.carMainInfo.carInfo!.minPrice) * 0.5
		slider.value = 0
		slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(lastPaySliderValueDidChange(_:)), for: .valueChanged)
		return slider
	}()

	private lazy var everyMounthButton: Button = {
		let button = Button()
		let label = UILabel()
		button.setTitle("Рассчитать ежемесячный платеж", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(tappedEveryMounthButton), for: .touchUpInside)
		return button
	}()

	private lazy var everyMounthLabel: UILabel = {
		let label = UILabel()
		label.text = "Ежемесячный платеж"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
		return label
	}()

	private lazy var everyMounthResultLabel: UILabel = {
		let label = UILabel()
		label.text = " ₽"
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
		return label
	}()

	private lazy var rateMounthLabel: UILabel = {
		let label = UILabel()
		label.text = "ставка %"
		label.textColor = .systemGray
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
		return label
	}()

	private lazy var takeCreditButton: Button = {
		let button = Button()
		button.setTitle("Оформить заявку на кредит", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(takeCreditButtonTapped), for: .touchUpInside)
		return button
	}()

	init(carMainInfo: CarRecognitionResponse) {
		self.carMainInfo = carMainInfo
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc func yearSliderValueDidChange(_ sender:UISlider!) {
        print("Slider value changed")

        let roundedStepValue = round(sender.value / stepYear) * stepYear
        sender.value = roundedStepValue
		yearLabel.text = String(Int(sender.value))
        print("Slider step value \(Int(roundedStepValue))")
    }

	@objc func firstPaySliderValueDidChange(_ sender:UISlider!) {
        let roundedStepValue = round(sender.value / stepFirstPay) * stepFirstPay
        sender.value = roundedStepValue
		firstPayLabel.text = String(Int(sender.value))
        print("Slider step value \(Int(roundedStepValue))")
    }

	@objc func lastPaySliderValueDidChange(_ sender:UISlider!) {
        let roundedStepValue = round(sender.value / stepLastPay) * stepLastPay
        sender.value = roundedStepValue
		lastPay = Double(sender.value)
		lastPayLabel.text = formatter.string(from: sender.value as NSNumber)
        print("Slider step value \(Int(roundedStepValue))")
    }

	@objc func tappedEveryMounthButton() {
		let model = CalculateRequestModel(cost: self.carMainInfo.carInfo!.minPrice,
										  initialFee: Int((Float(self.carMainInfo.carInfo!.minPrice) * firstPaySlider.value) / 100.0),
										  kaskoValue: Int(Double(carMainInfo.carInfo!.minPrice) * 0.05),
										  residualPayment: Int(lastPay),
										  term: Int(yearSlider.value))
		calculateRequest.viewDelegate = self
		calculateRequest.sendCalculate(model: model)
	}

	@objc func takeCreditButtonTapped() {
//		let alert = UIAlertController(title: "Автокредит", message: "Ваша заявка успешно отправлена на обработку", preferredStyle: .alert)
//		alert.addAction(T##action: UIAlertAction##UIAlertAction)
//		alert.addAction(UIAlertAction(title: "Отлично!", style: .default, handler: {
//			self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//		}))
//		self.present(alert, animated: true) {}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let screensize: CGRect = UIScreen.main.bounds
		let screenWidth = screensize.width
		let screenHeight = screensize.height
		scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))

		self.view.backgroundColor = .white
		if let carPriceUnw = carMainInfo.carInfo?.minPrice {
			self.kaskoLabel.text = "Расчётная стоимость КАСКО: " + String(formatter.string(from: Double(carPriceUnw) * 0.05 as NSNumber) ?? "")
		}
		setupUI()
	}

	private func setupUI() {
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(kaskoLabel)
		scrollView.addSubview(yearSlider)
		scrollView.addSubview(yearLabel)
		scrollView.addSubview(yearLabelDescription)

		scrollView.addSubview(firstPaySlider)
		scrollView.addSubview(firstPayLabel)
		scrollView.addSubview(firstPayDescription)

		scrollView.addSubview(lastPayLabel)
		scrollView.addSubview(lastPaySlider)
		scrollView.addSubview(lastPayDescription)

		scrollView.addSubview(everyMounthButton)
		scrollView.addSubview(everyMounthLabel)
		scrollView.addSubview(everyMounthResultLabel)
		scrollView.addSubview(rateMounthLabel)
		scrollView.addSubview(takeCreditButton)

		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
			titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			titleLabel.heightAnchor.constraint(equalToConstant: 50)
		])

		NSLayoutConstraint.activate([
			kaskoLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			kaskoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
			kaskoLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			kaskoLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			kaskoLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			yearLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			yearLabel.topAnchor.constraint(equalTo: kaskoLabel.bottomAnchor, constant: 15),
			yearLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			yearLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			yearLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			yearSlider.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			yearSlider.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 10),
			yearSlider.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			yearSlider.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			yearSlider.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			yearLabelDescription.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			yearLabelDescription.topAnchor.constraint(equalTo: yearSlider.bottomAnchor, constant: 10),
			yearLabelDescription.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			yearLabelDescription.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			yearLabelDescription.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			firstPayLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			firstPayLabel.topAnchor.constraint(equalTo: yearLabelDescription.bottomAnchor, constant: 15),
			firstPayLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			firstPayLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			firstPayLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			firstPaySlider.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			firstPaySlider.topAnchor.constraint(equalTo: firstPayLabel.bottomAnchor, constant: 10),
			firstPaySlider.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			firstPaySlider.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			firstPaySlider.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			firstPayDescription.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			firstPayDescription.topAnchor.constraint(equalTo: firstPaySlider.bottomAnchor, constant: 10),
			firstPayDescription.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			firstPayDescription.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			firstPayDescription.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			lastPayLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			lastPayLabel.topAnchor.constraint(equalTo: firstPayDescription.bottomAnchor, constant: 15),
			lastPayLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			lastPayLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			lastPayLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			lastPaySlider.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			lastPaySlider.topAnchor.constraint(equalTo: lastPayLabel.bottomAnchor, constant: 10),
			lastPaySlider.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			lastPaySlider.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			lastPaySlider.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			lastPayDescription.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			lastPayDescription.topAnchor.constraint(equalTo: lastPaySlider.bottomAnchor, constant: 10),
			lastPayDescription.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			lastPayDescription.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			lastPayDescription.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			everyMounthButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			everyMounthButton.topAnchor.constraint(equalTo: lastPayDescription.bottomAnchor, constant: 30),
			everyMounthButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			everyMounthButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			everyMounthButton.heightAnchor.constraint(equalToConstant: 50)
		])

		NSLayoutConstraint.activate([
			everyMounthLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			everyMounthLabel.topAnchor.constraint(equalTo: everyMounthButton.bottomAnchor, constant: 15),
			everyMounthLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			everyMounthLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			everyMounthLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			everyMounthResultLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			everyMounthResultLabel.topAnchor.constraint(equalTo: everyMounthLabel.bottomAnchor, constant: 10),
			everyMounthResultLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			everyMounthResultLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			everyMounthResultLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			rateMounthLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			rateMounthLabel.topAnchor.constraint(equalTo: everyMounthResultLabel.bottomAnchor, constant: 5),
			rateMounthLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			rateMounthLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			rateMounthLabel.heightAnchor.constraint(equalToConstant: 25)
		])

		NSLayoutConstraint.activate([
			takeCreditButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			takeCreditButton.topAnchor.constraint(equalTo: rateMounthLabel.bottomAnchor, constant: 30),
			takeCreditButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 15),
			takeCreditButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -15.0),
			takeCreditButton.heightAnchor.constraint(equalToConstant: 50)
		])

		view.addSubview(scrollView)

		let screensize: CGRect = UIScreen.main.bounds
		let screenWidth = screensize.width
		 scrollView.contentSize = CGSize(width: screenWidth, height: 5000)
	}

	func creditResultSuccess(model: CalculateResponse) {
		DispatchQueue.main.async {
			self.everyMounthResultLabel.text = self.formatter.string(from: model.result.payment as NSNumber)
			self.rateMounthLabel.text = "ставка " + String(model.result.contractRate) + " %"
		}
	}
}
