//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Hetang Shah. All rights reserved.
//

import UIKit

class Business: NSObject {
    let name: String?
    let address: String?
    let imageURL: URL?
    let categories: String?
    let distance: String?
    let ratingImageURL: URL?
    let reviewCount: NSNumber?
    
    let latitude: Double
    let longitude: Double
    
    var categoriesArray = [String:String]()
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = URL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var latitude: Double = -1
        var longitude: Double = -1
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
            
            let latLong = location!["coordinate"] as? NSDictionary
            latitude = latLong?["latitude"] as? Double ?? -1
            longitude = latLong?["longitude"] as? Double ?? -1
        }
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            
            for category in categoriesArray! {
                let categoryName = category[0]
                let categoryKey = category[1]
                categoryNames.append(categoryName)
                
                self.categoriesArray[categoryKey] = categoryName
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = URL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(latLong:String, term: String?, offset: Int?, completion: @escaping ([Business]?, Error?) -> Void) {
        _ = YelpClient.sharedInstance.searchWithTerm(latLong, term: term, offset: offset, completion: completion)
    }
    
    class func searchWithTerm(latLong:String, term: String?, sort: YelpSortMode?, categories: [String]?, deals: Bool?, offset: Int?, completion: @escaping ([Business]?, Error?) -> Void) -> Void {
        _ = YelpClient.sharedInstance.searchWithTerm(latLong, term: term, sort: sort, categories: categories, deals: deals, offset: offset, completion: completion)
    }
    
    override var description : String {
        get {
            return "Business : name : `\(name ?? "") - address : `\(address ?? "")` - distance : `\(distance ?? "0")` - reviewCount : `\(reviewCount ?? 0)`"
        }
    }
}

extension Array where Element: Business {
    func getAllCategories() -> [YelpCategory] {
        var categories = [String: String]()
        /**
         We need to run below loop to remove duplicates.
         **/
        for business in self {
            categories += business.categoriesArray
        }
        var result = [YelpCategory]()
        for category in categories {
            result.append(YelpCategory(key: category.key, value: category.value, isSelected: true))
        }
        return result
    }
}

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}
