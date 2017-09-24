//
//  FilterViewController.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    @IBOutlet weak var filterTableView: UITableView!
    
    var filters: Filters?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyButton(_ sender: Any) {
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableCell", for: indexPath) as? FilterCategoryCell else {
                return UITableViewCell()
            }
            cell.categoryLabel.text = "Offering a deal"
            cell.categorySwitch.isOn = filters?.isOfferDeal ?? false
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSortCell", for: indexPath) as? FilterSortCell else {
                return UITableViewCell()
            }
            let sort = YelpSortMode.allValues[indexPath.row]
            cell.sortMode = sort
            if (sort == filters?.selectedSort) {
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
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableCell", for: indexPath) as? FilterCategoryCell else {
                return UITableViewCell()
            }
            let category = filters?.categories[indexPath.row]
            cell.category = category
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
}
