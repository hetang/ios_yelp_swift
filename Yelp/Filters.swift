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
    let isSelected: Bool
    
    init(key: String, value: String, isSelected: Bool = false) {
        self.key = key
        self.value = value
        self.isSelected = isSelected
    }
}

class Filters: NSObject {
    let categories: [YelpCategory]
    
    let allSorts = YelpSortMode.allValues
    let selectedSort = YelpSortMode.bestMatched
    
    let allDistances = YelpRadius.allValues
    let selectedDistance = YelpRadius.auto
    
    let isOfferDeal: Bool = false
    
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
