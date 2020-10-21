//
//  ImageSizeAPI.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/20/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

final class ImageSizeAPI {
    private lazy var baseURL: URL = {
        return URL(string: "http://FelineFinderServerBackend-env.eba-cacmtkpz.us-east-1.elasticbeanstalk.com/api/sizeImages")!
    }()
    
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    var isLoading = false
    
    func probeImages(imageArray: [String], completion: @escaping (Result<[String: PetImage], DataResponseError>) -> Void) {
        
        if isLoading {return}
        
        isLoading = true

        if (Utilities.isNetworkAvailable() == false) {
            isLoading = false
            return
        }

        var urlRequest = URLRequest(url: baseURL)

        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = ["imageArray": imageArray] as [String: Any]

        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
            else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(PetImages.self, from: data) else {
                    completion(Result.failure(DataResponseError.decoding))
                    return
                }
            
            let imageData = (decodedResponse as PetImages)

            var result: [String: PetImage] = [:]
            
            for img in imageData.ImageArray {
                result[img.URL] = PetImage(url: img.URL, h: img.height, w: img.width)
            }
            
            self.isLoading = false
            completion(Result.success(result))
        }).resume()
    }
}
