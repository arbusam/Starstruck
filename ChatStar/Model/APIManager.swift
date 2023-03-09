//
//  APIManager.swift
//  ChatStar
//
//  Created by Arhan Busam on 7/3/2023.
//

import Foundation
import MessageKit

struct APIManager {
    let baseURL = "https://api.openai.com/v1/chat/completions"
    
    func chat(with star: String, messages: [MyMessage], user: Sender, chatBot: Sender, finished: @escaping (String) -> Void) {
        var textMessages: [[String: String]] = [
            [
                "role": "system",
                "content": "You are \(star) answering interview questions. Imitate how they would speak and the opinions they would have."
            ]
        ] //An array of dictionaries that would contain first the role of the message and then the text inside the content key
        for message in messages {
            if case.text (let text) = message.kind {
                switch message.sender.senderId {
                case user.senderId:
                    textMessages.append(["role": "user", "content": text])
                case chatBot.senderId:
                    textMessages.append(["role": "assistant", "content": text])
                default:
                    print("Unknown Sender. Skipping message")
                    continue
                }
            }
        }
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
            "messages": textMessages
        ]

        // Encode the parameters as JSON data and assign it to the httpBody property
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("JSON Serialization Error")
            print(error.localizedDescription)
        }

        // Use the same completion handler as in the above code
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // Check for errors and use JSONDecoder to decode the data into a Swift object that conforms to Codable protocol
            if let error = error {
                print("Error calling the API")
                print(error.localizedDescription)
                return
            }

            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ChatResponse.self, from: data)
                    print(result)
                    finished(result.choices[0].message.content)
                } catch let decodingError as DecodingError {
                    switch decodingError {
                        case .dataCorrupted(let context):
                            print("Data Corrupted")
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
                    print("Non DecodingError when Decoding")
                    print(error.localizedDescription)
                }
            }
        }

        // Resume the data task to start the request
        task.resume()
    }
}

