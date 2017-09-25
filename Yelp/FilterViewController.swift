//
//  FilterViewController.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: Filters)
}

class FilterViewController: UIViewController {
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    @IBOutlet weak var filterTableView: UITableView!
    weak var delegate: FilterViewControllerDelegate?
    
    var filters: Filters?
    
    var sortSelectedCellIndex: IndexPath? = nil
    var distanceSelectedCellIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        if(filters != nil) {
            delegate?.filterViewController(filterViewController: self, didUpdateFilters: filters!)
        }
    }
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 1
        case 1:
            return YelpSortMode.allValues.count
        case 2:
            return YelpRadius.allValues.count
        case 3:
            return filters?.categories.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchCell", for: indexPath) as? FilterSwitchCell else {
                return UITableViewCell()
            }
            cell.categoryLabel.text = "Offering a deal"
            cell.categorySwitch.isOn = filters?.isOfferDeal ?? false
            cell.switchAction = { (isOn: Bool) in
                // since this is within the context, we don't have to get the indexPath separately
                self.filters?.isOfferDeal = isOn
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSortCell", for: indexPath) as? FilterSortCell else {
                return UITableViewCell()
            }
            let sort = YelpSortMode.allValues[indexPath.row]
            cell.sortMode = sort
            if (sort == filters?.selectedSort) {
                sortSelectedCellIndex = indexPath
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterDistanceCell", for: indexPath) as? FilterDistanceCell else {
                return UITableViewCell()
            }
            let distance = YelpRadius.allValues[indexPath.row]
            cell.distance = distance
            if (distance == filters?.selectedDistance) {
                distanceSelectedCellIndex = indexPath
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSwitchCell", for: indexPath) as? FilterSwitchCell else {
                return UITableViewCell()
            }
            let category = filters?.categories[indexPath.row]
            cell.category = category
            
            cell.switchAction = { (isOn: Bool) in
                self.filters?.categories[indexPath.row].isSelected = isOn
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView")
        
        if (header == nil) {
            header = UITableViewHeaderFooterView()
        }
        
        header?.backgroundColor = UIColor.darkGray
        header?.textLabel?.textColor = UIColor.white
        
        switch section {
        case 0:
            header?.textLabel?.text = "Deal"
            break
        case 1:
            header?.textLabel?.text = "Sort"
            break
        case 2:
            header?.textLabel?.text = "Distance"
            break
        case 3:
            header?.textLabel?.text = "Category"
            break
        default:
            header?.textLabel?.text = ""
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor = UIColor.lightGray
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterTableView.deselectRow(at: indexPath, animated: true)
        
        switch(indexPath.section) {
        case 1:
            if (sortSelectedCellIndex != nil) {
                let previousSelectedCell = filterTableView.cellForRow(at: sortSelectedCellIndex!)
                previousSelectedCell?.accessoryType = .none
            }
            
            let selectedCell = filterTableView.cellForRow(at: indexPath)
            selectedCell?.accessoryType = .checkmark
            
            sortSelectedCellIndex = indexPath
            let sort = YelpSortMode.allValues[indexPath.row]
            filters?.selectedSort = sort
            
            break
        case 2:
            if (distanceSelectedCellIndex != nil) {
                let previousSelectedCell = filterTableView.cellForRow(at: distanceSelectedCellIndex!)
                previousSelectedCell?.accessoryType = .none
            }
            
            let selectedCell = filterTableView.cellForRow(at: indexPath)
            selectedCell?.accessoryType = .checkmark
            
            distanceSelectedCellIndex = indexPath
            let sort = YelpRadius.allValues[indexPath.row]
            filters?.selectedDistance = sort
            
            break
        default: break
        }
    }
}
