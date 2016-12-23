//
//  RSTransactionRequest.swift
//  RSNetworkSample
//
//  Created by Jon Hoffman on 7/25/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

private func urlEncode(_ s: String) -> String? {
    return s.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
}

class RSTransactionRequest: NSObject {
    
    let dictKey = "results"
    
    typealias dataFromRSTransactionCompletionClosure = ((URLResponse?, Data?, NSError?) -> Void)
    typealias stringFromRSTransactionCompletionClosure = ((URLResponse?, NSString?, NSError?) -> Void)
    typealias dictionaryFromRSTransactionCompletionClosure = ((URLResponse?, NSDictionary?, NSError?) -> Void)
    typealias imageFromRSTransactionCompletionClosure = ((URLResponse?, UIImage?, NSError?) -> Void)
    
    
    func dataFromRSTransaction(_ transaction: RSTransaction, completionHandler handler: @escaping dataFromRSTransactionCompletionClosure)
    {
        if (transaction.transactionType == RSTransactionType.get) {
            dataFromRSTransactionGet(transaction, completionHandler: handler);
        } else if(transaction.transactionType == RSTransactionType.post) {
            dataFromRSTransactionPost(transaction, completionHandler: handler);
        }
    }
    
    fileprivate func dataFromRSTransactionPost(_ transaction: RSTransaction, completionHandler handler: @escaping dataFromRSTransactionCompletionClosure)
    {

        let sessionConfiguration = URLSessionConfiguration.default
        
        let urlString = transaction.getFullURLString()
        let url: URL = URL(string: urlString)!
        
        let request = NSMutableURLRequest(url:url)
        request.httpMethod = "POST"
        let params = dictionaryToQueryString(transaction.parameters)
        request.httpBody = params.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let urlSession = URLSession(configuration:sessionConfiguration, delegate: nil, delegateQueue: nil)
        
        urlSession.dataTask(with: request as URLRequest, completionHandler: {(responseData: Data?, response: URLResponse?, error: NSError?) -> Void in
            
            handler(response,responseData,error)
        } as! (Data?, URLResponse?, Error?) -> Void).resume()
    }
    
    fileprivate func dataFromRSTransactionGet(_ transaction: RSTransaction, completionHandler handler: @escaping dataFromRSTransactionCompletionClosure)
    {
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let urlString = transaction.getFullURLString() + "?" + dictionaryToQueryString(transaction.parameters)
        let url: URL = URL(string: urlString)!
        
        let request = NSMutableURLRequest(url:url)
        request.httpMethod = "GET"
        let urlSession = URLSession(configuration:sessionConfiguration, delegate: nil, delegateQueue: nil)
        
        urlSession.dataTask(with: request as URLRequest, completionHandler: {(responseData: Data?, response: URLResponse?, error: NSError?) -> Void in
            
            handler(response,responseData,error)
        } as! (Data?, URLResponse?, Error?) -> Void).resume()
    }
    
    func stringFromRSTransaction(_ transaction: RSTransaction, completionHandler handler: @escaping stringFromRSTransactionCompletionClosure) {
        dataFromRSTransaction(transaction, completionHandler: {(response: URLResponse!, responseData: Data!, error: NSError!) -> Void in
            
            let responseString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
            handler(response,responseString,error)
        } as! (URLResponse?, Data?, NSError?) -> Void)
    }
    
    
    func dictionaryFromRSTransaction(_ transaction: RSTransaction, completionHandler handler: @escaping dictionaryFromRSTransactionCompletionClosure) {
        dataFromRSTransaction(transaction, completionHandler: {(response: URLResponse!, responseData: Data!, error: NSError!) -> Void in
            
            if error != nil {
                handler(response,nil,error)
                return
            }
            
            var resultDictionary = NSMutableDictionary()
            var jsonResponse : Any?
            do {
            jsonResponse  = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments)
            } catch {}
            
            if let jsonResponse = jsonResponse {
            switch jsonResponse {
            case is NSDictionary:
                resultDictionary = jsonResponse as! NSMutableDictionary
            case is NSArray:
                resultDictionary[self.dictKey] = jsonResponse
            default:
                resultDictionary[self.dictKey] = ""
            }
            } else {
                resultDictionary[self.dictKey] = ""
            }
            handler(response,resultDictionary.copy() as? NSDictionary,error)
        } as! (URLResponse?, Data?, NSError?) -> Void)
    }
    
    
    func imageFromRSTransaction(_ transaction: RSTransaction, completionHandler handler: @escaping imageFromRSTransactionCompletionClosure) {
        dataFromRSTransaction(transaction, completionHandler: {(response: URLResponse!, responseData: Data!, error: NSError!) -> Void in
            
            if error != nil {
                handler(response,nil,error)
                return
            }
            
            let image = UIImage(data: responseData)
            handler(response,image?.copy() as! UIImage?,error)
        } as! (URLResponse?, Data?, NSError?) -> Void)
    }
    
    
    fileprivate func dictionaryToQueryString(_ dict: [String : String]) -> String {
        var parts = [String]()
        for (key, value) in dict {
            if let keyEncoded = urlEncode(key), let valueEncoded = urlEncode(value) {
                parts.append(keyEncoded + "=" + valueEncoded);
            }
        }
        return parts.joined(separator: "&")

    }
}
