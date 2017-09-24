//
//  BusinessListCell.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/20/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import UIKit

class BusinessListCell: UITableViewCell {
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessDistanceLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var business: Business! {
        didSet {
            businessNameLabel.text = business.name
            businessDistanceLabel.text = business.distance
            reviewsCountLabel.text = "\(business.reviewCount ?? 0) reviews"
            addressLabel.text = business.address
            categoryLabel.text = business.categories
            
            if let imageUrl = business.imageURL {
                businessImageView.setImageUrl(url: imageUrl.absoluteString, radius: 5.0)
            }
            
            if let ratingUrl = business.ratingImageURL {
                ratingImageView.setImageUrl(url: ratingUrl.absoluteString, radius: 5.0)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
