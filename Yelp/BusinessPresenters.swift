//
//  BusinessPresenters.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/20/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import Foundation

class BusinessPresenter: NSObject {
    func fetchBusinessInfo(latLong:String, searchTerm: String?, completed: @escaping (_ business : [Business]?) -> ()) {
        Business.searchWithTerm(latLong: latLong, term: searchTerm, completion: { (businesses: [Business]?, error: Error?) -> Void in
            completed(businesses)
        })
    }
}
