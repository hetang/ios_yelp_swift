//
//  Filters.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import Foundation

class YelpCategory: NSObject {
    let key: String
    let value: String
    var isSelected: Bool
    
    init(key: String, value: String, isSelected: Bool = false) {
        self.key = key
        self.value = value
        self.isSelected = isSelected
    }
}

class Filters: NSObject {
    let categories: [YelpCategory]
    
    var selectedSort = YelpSortMode.bestMatched
    var selectedDistance = YelpRadius.auto
    
    var isOfferDeal: Bool = false
    
    init(categories: [YelpCategory]) {
        self.categories = categories
    }
    
    func getAllSelectedCategories() -> [String] {
        var selectedCategories = [String]()
        
        for category in categories {
            if(category.isSelected) {
                selectedCategories.append(category.key)
            }
        }
        
        return selectedCategories
    }
}
