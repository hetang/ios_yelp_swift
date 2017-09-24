//
//  FilterTableCell.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import UIKit

@objc protocol FilterCategoryCellDelegate {
    @objc optional func filterCategory(filterCategoryCell: FilterCategoryCell, didChangeValue value: Bool)
}

class FilterCategoryCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categorySwitch: UISwitch!
    
    weak var delegate: FilterCategoryCellDelegate?
    
    var category: YelpCategory! {
        didSet {
            categoryLabel.text = category.value
            categorySwitch.isOn = category.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func onSwitchValueChanged(_ sender: Any) {
        delegate?.filterCategory?(filterCategoryCell: self, didChangeValue: categorySwitch.isOn)
    }
}
