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
    
    func chat(with bot: String, messages: [MyMessage], user: Sender, chatBot: Sender, finished: @escaping (String) -> Void) {
        let date = Date() // current date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d'st' yyyy"
        let dateString = formatter.string(from: date) // result is "March 12th 2023"
        var textMessages: [[String: String]] = [
            [
                "role": "system",
                "content": "You are \(bot) having a chat with the user on a messaging app. Imitate how \(bot) would speak, their mannerisms and the opinions they would have. Avoid answering questions they wouldn't be able to answer in real life in order to keep up the appearance you are them. Knowledge cutoff: September 9th 2021 Current date: \(dateString)."
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
        
        let userID = UIDevice.current.identifierForVendor!.uuidString

        // Set the data you want to pass, which is the JSON object with the "model" and "messages" keys
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": textMessages,
            "user": userID
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
                finished("###FAILED###")
                return
            }

            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ChatResponse.self, from: data)
                    print(result)
                    if let choices = result.choices {
                        if let content = choices[0].message.content {
                            finished(content)
                        } else {
                            finished("###FAILED###")
                        }
                    } else {
                        print("ERROR: Choices was blank.")
                        finished("###FAILED###")
                    }
                } catch let decodingError as DecodingError {
                    switch decodingError {
                        case .dataCorrupted(let context):
                            print("Data Corrupted")
                            print(context)
                            finished("###FAILED###")
                        case .keyNotFound(let key, let context):
                            print("Key '\(key)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                            finished("###FAILED###")
                        case .valueNotFound(let value, let context):
                            print("Value '\(value)' not found:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                            finished("###FAILED###")
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch:", context.debugDescription)
                            print("codingPath:", context.codingPath)
                            finished("###FAILED###")
                    @unknown default:
                        print("Unknown decoding error")
                        finished("###FAILED###")
                    }
                } catch let error {
                    print("Non DecodingError when Decoding")
                    print(error.localizedDescription)
                    finished("###FAILED###")
                }
            }
        }

        // Resume the data task to start the request
        task.resume()
    }
}

