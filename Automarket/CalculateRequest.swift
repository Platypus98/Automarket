//
//  CalculateRequest.swift
//  Automarket
//
//  Created by 17815062 on 11.10.2020.
//  Copyright © 2020 17815062. All rights reserved.
//

import Foundation

final class CalculateRequest: NSObject, URLSessionDelegate  {

	weak var viewDelegate: CreditViewController!

	func sendCalculate(model: CalculateRequestModel) {
		let json = ["clientTypes": model.clientTypes,
					"cost": model.cost,
					"initialFee": model.initialFee,
					"kaskoValue": model.kaskoValue,
					"language": model.language,
					"residualPayment": model.residualPayment,
					"settingsName": model.settingsName,
					"specialConditions": model.specialConditions,
					"term": model.term] as [String : Any]

		print(json)
		let jsonData = try? JSONSerialization.data(withJSONObject: json)
		var request = URLRequest(url: URL(string: "https://gw.hackathon.vtb.ru/vtb/hackathon/calculate")!)
		request.allHTTPHeaderFields = ["Content-Type": "application/json", "X-IBM-Client-Id": "cd31ddba6a27956308a96e1478c91e99"]
		request.httpMethod = "POST"
		request.httpBody = jsonData

		let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: OperationQueue.main)
		session.dataTask(with: request) { [weak self] (data, urlResponse, error) in
			guard (self?.viewDelegate) != nil else { return }

			guard let data = data, error == nil else {
				return
			}

			print(String(decoding: data, as: UTF8.self))

			do {
				guard let parsedResult = try self?.decodeResponse(response: data) else {
					return
				}
				print(parsedResult)
				self?.viewDelegate.creditResultSuccess(model: parsedResult)
			} catch {
			}
		}.resume()
	}

	private func decodeResponse(response: Data) throws -> CalculateResponse {
		let parsedResult = try JSONDecoder().decode(CalculateResponse.self, from: response)
		return parsedResult
	}
}

struct CalculateRequestModel: Codable {
	var clientTypes = ["ac43d7e4-cd8c-4f6f-b18a-5ccbc1356f75"]
	var cost: Int64
	var initialFee: Int
	var kaskoValue: Int
	var language = "en"
	var residualPayment: Int
	var settingsName = "Haval"
	var specialConditions = [
	  "57ba0183-5988-4137-86a6-3d30a4ed8dc9",
	  "b907b476-5a26-4b25-b9c0-8091e9d5c65f",
	  "cbfc4ef3-af70-4182-8cf6-e73f361d1e68"
	]
	var term: Int
}

struct CalculateResponse: Decodable {
	var result: ResultResponse
}

struct ResultResponse: Decodable {
	var payment: Int64
	var contractRate: Float
}
