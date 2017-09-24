//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

import Alamofire
import AlamofireImage

import NVActivityIndicatorView

class BusinessesViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var businessTableView: UITableView!
    @IBOutlet weak var businessMapView: MKMapView!
    
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet weak var mapListToggleBarButton: UIBarButtonItem!
    
    var businesses: [Business]!
    var presenter: BusinessPresenter = BusinessPresenter()
    
    let searchBar = UISearchBar()
    var searchTerm: String? = nil
    
    let locationManager = CLLocationManager()
    var latLong = "37.785771,-122.406165"
    var userLocation: CLLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        businessMapView.isHidden = true
        
        setupSearchBar()
        
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        requestLocationPermission()
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateList(searchTerm: String? = nil) {
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        presenter.fetchBusinessInfo(latLong: latLong, searchTerm: searchTerm, completed: { businessesList in
            self.businesses = businessesList
            self.businessTableView.reloadData()
            let allAnnotations = self.businessMapView.annotations
            self.businessMapView.removeAnnotations(allAnnotations)
            self.stopAnimating()
        })
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        businessMapView.setRegion(region, animated: true)
    }
    
    @IBAction func navigateToMapOrListView(_ sender: Any) {
        if(mapListToggleBarButton.tag == 0) {
            businessMapView.isHidden = false
            businessTableView.isHidden = true
            mapListToggleBarButton.tag = 1
            
            mapListToggleBarButton.image = UIImage(named: "list")
            goToLocation(location: userLocation)
        } else {
            businessMapView.isHidden = true
            businessTableView.isHidden = false
            
            mapListToggleBarButton.image = UIImage(named: "map")
            mapListToggleBarButton.tag = 0
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension BusinessesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessListCell", for: indexPath) as? BusinessListCell else {
            return UITableViewCell()
        }
        let business = businesses[indexPath.row]
        cell.business = business
        return cell
    }
}

extension BusinessesViewController: UISearchBarDelegate {
    func setupSearchBar() {
        searchBar.placeholder = "Search Restaurant, etc."
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.tintColor = UIColor.white
        navigationItem.titleView = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            if(self.searchTerm != searchTerm) {
                populateList(searchTerm: searchTerm)
                self.searchTerm = searchTerm
            }
        } else {
            if(searchTerm != nil) {
                populateList()
                searchTerm = nil
            }
        }
        searchBar.resignFirstResponder()
    }
    
    //    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    //        searchBar.showsCancelButton = true
    //        return true
    //    }
    
    //    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    //
    //        searchBar.showsCancelButton = false
    //        searchBar.resignFirstResponder()
    //        if(searchTerm != nil) {
    //            populateList()
    //            searchBar.text = ""
    //            searchTerm = nil
    //        }
    //    }
}

extension BusinessesViewController: CLLocationManagerDelegate {
    func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print ("Inside locationManager")
        if let location = manager.location {
            userLocation = location
            latLong = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
        populateList()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("location service fail: \(error)")
        populateList()
    }
}
