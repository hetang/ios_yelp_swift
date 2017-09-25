//
//  YelpClient.swift
//  Yelp
//
//  Created by Hetang Shah on 9/19/17.
//  Copyright (c) 2017 Hetang Shah. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"

enum YelpSortMode: Int {
    case bestMatched = 0, distance = 1, highestRated = 2
    
    static let allValues = [bestMatched, distance, highestRated]
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .bestMatched: return "Best Matched";
        case .distance: return "Distance";
        case .highestRated: return "Highest Rated";
        }
    }
}

enum YelpRadius: Decimal {
    case auto = 0, pointThreeMiles = 482.8, oneMile = 1609.4, fiveMiles = 8046.8, twentyMiles = 32186.9
    
    static let allValues = [auto, pointThreeMiles, oneMile, fiveMiles, twentyMiles]
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .auto: return "Auto";
        case .pointThreeMiles: return "0.3 miles";
        case .oneMile: return "1 mile";
        case .fiveMiles: return "5 miles";
        case .twentyMiles: return "20 miles";
        }
    }
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    //MARK: Shared Instance
    
    static let sharedInstance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = URL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(_ latLong: String, term: String?, offset: Int?, completion: @escaping ([Business]?, Error?) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(latLong,term: term, sort: nil, distance: nil, categories: nil, deals: nil, offset: offset, completion: completion)
    }
    
    func searchWithTerm(_ latLong: String, term: String?, sort: YelpSortMode?, distance: YelpRadius?, categories: [String]?, deals: Bool?, offset: Int?, completion: @escaping ([Business]?, Error?) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["ll": latLong as AnyObject]
        
        if term != nil {
            parameters["term"] = term as AnyObject
        }
        
        if sort != nil {
            parameters["sort"] = sort!.rawValue as AnyObject?
        }
        
        if distance != nil {
            parameters["radius_filter"] = distance!.rawValue as AnyObject?
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals! as AnyObject?
        }
        
        if offset != nil {
            parameters["offset"] = offset! as AnyObject?
        }
        
        print(parameters)
        
        return self.get("search", parameters: parameters,
                        success: { (operation: AFHTTPRequestOperation, response: Any) -> Void in
                            if let response = response as? [String: Any]{
                                let dictionaries = response["businesses"] as? [NSDictionary]
                                if dictionaries != nil {
                                    completion(Business.businesses(array: dictionaries!), nil)
                                }
                            }
        },
                        failure: { (operation: AFHTTPRequestOperation?, error: Error) -> Void in
                            completion(nil, error)
        })!
    }
}
