//
//  CarRecognitionRequest.swift
//  Automarket
//
//  Created by Ilya Golyshkov on 10.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation
import UIKit

final class CarRecognitionRequest: NSObject, URLSessionDelegate {

	weak var viewDelegate: NewCameraViewController!

	func sendCarRecognitionRequest(image: UIImage) {
		let imageData = image.jpegData(compressionQuality: 0.5)
		let url = URL(string: "https://vtb-automarket.herokuapp.com/api/recognize/car")!
		let json: [String: Any] = ["content": String(imageData?.base64EncodedString() ?? "")]
		let jsonData = try? JSONSerialization.data(withJSONObject: json)
		var request = URLRequest(url: url)
		request.allHTTPHeaderFields = ["Content-Type": "application/json", "Content-Lenght": "\(String(describing: jsonData?.count))"]
		request.httpMethod = "POST"
		request.httpBody = jsonData

		let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: OperationQueue.main)
		session.dataTask(with: request) { [weak self] (data, urlResponse, error) in
			guard (self?.viewDelegate) != nil else { return }

			guard let data = data, error == nil else {
				self?.viewDelegate.recievedCarRecognitionError()
				return
			}

			print(String(decoding: data, as: UTF8.self))

			do {
				guard let parsedResult = try self?.decodeResponse(response: data) else {
					self?.viewDelegate.recievedCarRecognitionError()
					return
				}
				print(parsedResult)
				self?.viewDelegate.recievedCarRecognitionSuccess(carDataResult: parsedResult)
			} catch {
				self?.viewDelegate.recievedCarRecognitionError()
			}
		}.resume()
	}

	private func decodeResponse(response: Data) throws -> CarRecognitionResponse {
		let parsedResult = try JSONDecoder().decode(CarRecognitionResponse.self, from: response)
		return parsedResult
	}

	func urlSession(_ session: URLSession,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			let trust: SecTrust? = challenge.protectionSpace.serverTrust
			if let trust = trust {
				let credential = URLCredential(trust: trust)
				completionHandler(.useCredential, credential)
			}
		} else {
			completionHandler(.useCredential, nil)
		}
	}
}

struct CarRecognitionResponse: Decodable {
	var found: Bool?
	var carName: String?
	var carInfo: CarInfo?
	var dealers: [DealersInfo]
	var youtubeVideos: [YouTubeVideoInfo]
}

struct CarInfo: Decodable {
	var brand: String
	var logoUrl: String
	var photos: [String]
	var minPrice: Int64
	var bodies: [String]
	var country: String
}

struct DealersInfo: Decodable {
	var logo: String
	var title: String
	var address: String
}

struct YouTubeVideoInfo: Decodable {
	var uri: String
	var pictureUri: String
	var name: String
}

struct CarRequest: Codable {
	var content: String
}
