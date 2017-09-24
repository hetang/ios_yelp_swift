//
//  FilterSortCell.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class FilterSortCell: UITableViewCell {
    
    @IBOutlet weak var sortLabel: UILabel!
    
    var sortMode: YelpSortMode! {
        didSet {
            sortLabel.text = sortMode.description
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
