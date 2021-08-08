//
//  OfflineQueryAPI.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/16/21.
//

import Foundation

enum OfflineQueryAPIError: Error {
    case responseProblem
    case decodingProblem
    case encodingProblem
}

struct OfflineQueryRequest {
    let resourceURL: URL
    
    init(resourceString: String = "") {
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func save(_ offlineQueryToSave: OfflineQuery, completion: @escaping(Result<String, OfflineQueryAPIError>) -> Void) {
        
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(offlineQueryToSave)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    completion(.failure(.decodingProblem))
                    return
                }
                
                let success = String(decoding: data, as: UTF8.self)
                completion(.success(success))
            }
            dataTask.resume()
        } catch {
            completion(.failure(.encodingProblem))
        }
    }
    
    func saveUserId(_ userToSave: User, completion: @escaping(Result<String, OfflineQueryAPIError>) -> Void) {
        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        defer {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
        }
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(userToSave)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    completion(.failure(.responseProblem))
                    return
                }
                
                let success = String(decoding: data, as: UTF8.self)
                DispatchQueue.main.async {
                    completion(.success(success))
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure(.encodingProblem))
        }
    }
    
    func loadOfflineQuery(queryID: String, completion: @escaping(Result<[String:Any], OfflineQueryAPIError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "GET"
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    completion(.failure(.decodingProblem))
                    return
                }
                
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        completion(.success(json))
                    }
                } catch {
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
        }
    }

    static func deleteOfflineQuery(saveName: String) -> Result<String?, NetworkErr> {

        let name = saveName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let query = "https://feline-finder-server-5-4a4nx.ondigitalocean.app/api/search/delete/\(name ?? "")"
        
        guard let _ = URL(string: query) else {
            return .failure(.url)
        }
        
        switch URLSession.makeAPICall(url: query) {
        case .failure(let err):
            return .failure(err)
        case .success(let data):
            return .success(String(data: data!, encoding: .utf8))
        }
    }

    
/*
    func deleteOfflineQuery(saveName: String, completion: @escaping(Result<[String:Any], OfflineQueryAPIError>) -> Void) {

        do {
            var urlRequest = URLRequest(url: URL(string: resourceURL.path + "?id=\(queryID)")!)
            urlRequest.httpMethod = "DELETE"
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    completion(.failure(.decodingProblem))
                    return
                }
                
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        completion(.success(json))
                    }
                } catch {
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
        }
    }
*/

    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
       if let data = text.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
}
