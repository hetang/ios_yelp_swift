//
//  FilterDistanceCell.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/24/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class FilterDistanceCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    var distance: YelpRadius! {
        didSet {
            distanceLabel.text = distance.description
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
