//
//  FilterTableCell.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import UIKit

class FilterSwitchCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categorySwitch: UISwitch!
    
    var switchAction: (Bool) -> Void = { (isOn: Bool) in }
    
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

    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        switchAction(sender.isOn)
    }
}
