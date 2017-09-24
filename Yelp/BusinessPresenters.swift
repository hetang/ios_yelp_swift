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
    
    func fetchBusinessInfo(latLong:String, searchTerm: String?, completed: @escaping (_ business : [Business]?) -> ()) {
        Business.searchWithTerm(latLong: latLong, term: searchTerm, offset: nil, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.lastFetchBusinessCount = businesses?.count ?? 0
            completed(businesses)
        })
    }
    
    func fetchNextBusiness(latLong:String, searchTerm: String?, completed: @escaping (_ business : [Business]?) -> ()) {
        Business.searchWithTerm(latLong: latLong, term: searchTerm, offset: lastFetchBusinessCount, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.lastFetchBusinessCount += businesses?.count ?? 0
            completed(businesses)
        })
    }
}
