//
//  ChatViewModel.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//

import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    // System instruction for the AI
    private var systemInstruction: String {
        return "Eres Pym, la inteligencia artificial diseñada por BBVA para ayudarte a resolver tus dudas en MiPyMES. Das estadísticas y siempre resuelves las dudas de tus usuarios. Como fuiste desarrollado por BBVA, siempre buscas que los usuarios se sientan cómodos con BBVA. Das la información de manera resumida."
    }
    
    // Gemini API configuration
    private let apiKey = "AIzaSyBQKPY9AaQIbAFeMHdymFu0dYqyorvZJfw"
    private let modelId = "gemini-2.0-flash"
    
    // For local persistence
    private let userDefaultsKey = "chatHistory"
    
    // Initialize with stored messages
    init() {
        loadMessages()
    }
    
    func setup() {
        // Any additional setup if needed
        print("ChatViewModel initialized with \(messages.count) saved messages")
    }
    
    // Save messages to UserDefaults
    private func saveMessages() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    // Load messages from UserDefaults
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                messages = try decoder.decode([ChatMessage].self, from: data)
            } catch {
                print("Failed to load messages: \(error)")
                messages = []
            }
        }
    }
    
    // Clear chat history
    func clearHistory() {
        messages = []
        saveMessages()
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = ChatMessage(
            author: "Me",
            text: text
        )
        
        messages.append(userMessage)
        saveMessages()
        
        // Prepare conversation history for context
        var contents: [[String: Any]] = []
        
        // For Gemini, we need to use a different approach since it doesn't support system role
        // First message will be our system instruction, marked as from the model
        contents.append([
            "role": "user",
            "parts": [["text": "Please act as follows in our conversation: " + systemInstruction]]
        ])
        
        // Add a model confirmation to simulate the system instruction being accepted
        contents.append([
            "role": "model",
            "parts": [["text": "I understand. I'll act as Pym, your BBVA financial assistant."]]
        ])
        
        // Add previous messages as context (limiting to last 10 messages for efficiency)
        let historyMessages = messages.suffix(10) // Get the most recent 10 messages
        for message in historyMessages {
            let role = message.author == "Me" ? "user" : "model"
            contents.append([
                "role": role,
                "parts": [["text": message.text]]
            ])
        }
        
        let apiURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelId):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare request body with conversation history
        let requestBody: [String: Any] = [
            "contents": contents
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error serializing JSON: \(error)")
            completion("Error preparing the message")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error sending message: \(error)")
                completion("Error: Unable to connect to Pym")
                return
            }
            
            guard let data = data else {
                print("No data received from Gemini")
                completion("Error: No response received")
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                // Parse Gemini response
                if let candidates = jsonResponse?["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let geminiResponse = firstPart["text"] as? String {
                    
                    DispatchQueue.main.async {
                        let geminiMessage = ChatMessage(author: "Pym", text: geminiResponse)
                        self.messages.append(geminiMessage)
                        self.saveMessages()
                        completion(geminiResponse)
                    }
                } else {
                    if let error = jsonResponse?["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("API Error: \(message)")
                        completion("Error: \(message)")
                    } else {
                        print("Unexpected response from Gemini: \(String(describing: jsonResponse))")
                        completion("Error: Could not parse response")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion("Error: Could not understand response")
            }
        }
        
        task.resume()
    }
}

// Message model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let author: String
    let text: String
    let timestamp: Date
    
    init(author: String, text: String) {
        self.id = UUID()
        self.author = author
        self.text = text
        self.timestamp = Date()
    }
}
