//
//  BusinessListCell.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/20/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

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
            
            let imageCache = AutoPurgingImageCache()
            if let imageUrl = business.imageURL {
                let radius: CGFloat = 5.0
                if let cachedImage = imageCache.image(withIdentifier: imageUrl.absoluteString) {
                    businessImageView.image = cachedImage.af_imageRounded(withCornerRadius: radius)
                } else {
                    Alamofire.request(imageUrl).responseImage { response in
                        if let image = response.result.value {
                            imageCache.add(image, withIdentifier: imageUrl.absoluteString)
                            self.businessImageView.alpha = 0.0
                            self.businessImageView.image = image.af_imageRounded(withCornerRadius: radius)
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.businessImageView.alpha = 1.0
                            })
                        }
                    }
                }
            }
            
            if let ratingUrl = business.ratingImageURL {
                if let cachedImage = imageCache.image(withIdentifier: ratingUrl.absoluteString) {
                    ratingImageView.image = cachedImage
                } else {
                    Alamofire.request(ratingUrl).responseImage { response in
                        if let image = response.result.value {
                            imageCache.add(image, withIdentifier: ratingUrl.absoluteString)
                            self.ratingImageView.alpha = 0.0
                            self.ratingImageView.image = image
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.ratingImageView.alpha = 1.0
                            })
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
