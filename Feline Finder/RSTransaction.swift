//
//  RSTransaction.swift
//  RSNetworkSample
//
//  Created by Jon Hoffman on 7/25/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

import Foundation

enum RSTransactionType {
    case get
    case post
    case unknown
}   

class RSTransaction: NSObject {
    var transactionType = RSTransactionType.unknown
    var baseURL: String
    var path: String
    var parameters : [String:String]
    
    init(transactionType: RSTransactionType, baseURL: String,  path: String, parameters: [String: String]) {
        self.transactionType = transactionType
        self.baseURL = baseURL
        self.path = path
        self.parameters = parameters
    }
    
    func getFullURLString() -> String {
        return removeSlashFromEndOfString(self.baseURL) + "/" + removeSlashFromStartOfString(self.path)
    }
    
    
    fileprivate func removeSlashFromEndOfString(_ string: String) -> String
    {
        if string.hasSuffix("/") {
            return string.chopPrefix(1)
        } else {
            return string
        }
        
    }
    
    fileprivate func removeSlashFromStartOfString(_ string : String) -> String {
        if string.hasPrefix("/") {
            return string.chopPrefix(1)
        } else {
            return string
        }
    }
}
