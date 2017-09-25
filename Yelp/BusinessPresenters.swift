//
//  BusinessPresenters.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/20/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import Foundation

class BusinessPresenter: NSObject {
    var lastFetchBusinessCount: Int = 0
    
    func fetchBusinessInfo(latLong:String, searchTerm: String?, filters: Filters?, completed: @escaping (_ business : [Business]?) -> ()) {
        var distance: YelpRadius? = filters?.selectedDistance
        if filters?.selectedDistance == YelpRadius.auto {
            distance = nil
        }
        
        var categories: [String]? = nil
        if(filters?.categories != nil) {
            categories = [String]()
            for category in (filters?.categories)! {
                if(category.isSelected) {
                    categories?.append(category.key)
                }
            }
        }
        
        Business.searchWithTerm(latLong: latLong, term: searchTerm, sort: filters?.selectedSort, distance: distance, categories: categories, deals: filters?.isOfferDeal, offset: nil, completion: {(businesses: [Business]?, error: Error?) -> Void in
            self.lastFetchBusinessCount = businesses?.count ?? 0
            completed(businesses)
        })
    }
    
    func fetchNextBusiness(latLong:String, searchTerm: String?, filters: Filters?, completed: @escaping (_ business : [Business]?) -> ()) {
        var distance: YelpRadius? = filters?.selectedDistance
        if filters?.selectedDistance == YelpRadius.auto {
            distance = nil
        }
        
        var categories: [String]? = nil
        if(filters?.categories != nil) {
            categories = [String]()
            for category in (filters?.categories)! {
                if(category.isSelected) {
                    categories?.append(category.key)
                }
            }
        }
        Business.searchWithTerm(latLong: latLong, term: searchTerm, sort: filters?.selectedSort, distance: distance, categories: categories, deals: filters?.isOfferDeal, offset: lastFetchBusinessCount, completion: {(businesses: [Business]?, error: Error?) -> Void in
            self.lastFetchBusinessCount += businesses?.count ?? 0
            completed(businesses)
        })
    }
}
