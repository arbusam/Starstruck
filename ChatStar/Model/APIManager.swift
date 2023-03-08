//
//  APIManager.swift
//  ChatStar
//
//  Created by Arhan Busam on 7/3/2023.
//

import Foundation

struct APIManager {
    let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func chat(with star: String, message: String) {
        let url = URL(string: baseURL)!
        
        // Set the HTTP method to "POST"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Set the headers you want to pass, which are "Authorization" and "Content-Type"
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set the data you want to pass, which is the JSON object with the "model" and "messages" keys
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are \(star) answering interview questions."
                ],
                [
                    "role": "user",
                    "content": message
                ]
            ]
        ]

        // Encode the parameters as JSON data and assign it to the httpBody property
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        // Use the same completion handler as in the above code
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // Check for errors and use JSONDecoder to decode the data into a Swift object that conforms to Codable protocol
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ChatResponse.self, from: data)
                    print(result)
                } catch let decodingError as DecodingError {
                    switch decodingError {
                        case .dataCorrupted(let context):
                            print(context)
                        case .keyNotFound(let key, let context):
                            print("Key '\(key)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        case .valueNotFound(let value, let context):
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                    @unknown default:
                        print("Unknown decoding error")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }

        // Resume the data task to start the request
        task.resume()
    }
}

