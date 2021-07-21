//
//  Networking.swift
//  MVVM-register
//
//  Created by talgat on 6/15/21.
//

import Foundation
import RxSwift

class Networking {
    
    // MARK: - Singleton
    
    static let shared = Networking()
    private init () {}
    
    // MARK: - Custom error
    
    enum APIError: Error {
        case unknown
        case serverMessage(String)
        
        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error occured. Please try again later."
            case .serverMessage(let msg):
                return msg
            }
        }
    }
    
    // MARK: - Network Models
    
    struct APIResponse: Codable {
        let message: String
    }
    
    // MARK: - Properties
    
    private let endpointUrl = URL(string: "https://idagotvim.000webhostapp.com/api/create_user")!
    private let endpointUrlLogin = URL(string: "https://idagotvim.000webhostapp.com/api/login")!
    // MARK: - Register user
    
    func registerUser(email: String, pass: String) -> Observable<String> {
        Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            let request = self.postRequest(email: email, password: pass)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    print("No data received!")
                    observer.onError(error ?? APIError.unknown)
                    return
                }
                
                print("Received data: \(data)")
                
                let messageResponse: APIResponse
                do {
                    messageResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Decoded message! \(messageResponse.message)")
                } catch let decodingError {
                    print("Error decoding! \(decodingError)")
                    observer.onError(decodingError)
                    return
                }
                
                guard response.statusCode == 200 else {
                    observer.onError(APIError.serverMessage(messageResponse.message))
                    return
                }
                
                observer.onNext(messageResponse.message)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func loginUser(email: String, pass: String) -> Observable<String> {
        Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            let request = self.postRequestLogin(email: email, password: pass)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    print("No data received!")
                    observer.onError(error ?? APIError.unknown)
                    return
                }
                
                print("Received data(for login): \(data)")
                
                let messageResponse: APIResponse
                do {
                    messageResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Decoded message! \(messageResponse.message)")
                } catch let decodingError {
                    print("Error decoding! \(decodingError)")
                    observer.onError(decodingError)
                    return
                }
                
                guard response.statusCode == 200 else {
                    observer.onError(APIError.serverMessage(messageResponse.message))
                    return
                }
                
                observer.onNext(messageResponse.message)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    // MARK: - Helpers
    
    private func postRequest(email: String, password: String) -> URLRequest {
        let json = ["email": email, "password": password, "firstname": "asd", "lastname": "asd"]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        var request = URLRequest(url: self.endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    private func postRequestLogin(email: String, password: String) -> URLRequest {
        let json = ["email": email, "password": password, "firstname": "asd", "lastname": "asd"]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        var request = URLRequest(url: self.endpointUrlLogin)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
