//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Hetang Shah on 9/19/17.
//  Copyright (c) 2015 Hetang Shah. All rights reserved.
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
    var searchTerm: String = ""
    
    let locationManager = CLLocationManager()
    var latLong = "37.785771,-122.406165"
    var userLocation: CLLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
    var locationSet: Bool = false
    
    var filters: Filters?
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        businessMapView.isHidden = true
        
        setupSearchBar()
        
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        requestLocationPermission()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        businessTableView.addSubview(loadingMoreView!)
        
        var insets = businessTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        businessTableView.contentInset = insets
        
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
    }
    
    func populateList(searchTerm: String? = nil) {
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        presenter.fetchBusinessInfo(latLong: latLong, searchTerm: searchTerm, completed: { businessesList in
            self.businesses = businessesList
            self.businessTableView.reloadData()
            let allAnnotations = self.businessMapView.annotations
            self.businessMapView.removeAnnotations(allAnnotations)
            if let businesses = businessesList {
                self.addAnnotationsOnMap(businesses: businesses)
            }
            self.stopAnimating()
            
            self.filters = Filters(categories: self.businesses.getAllCategories())
        })
    }
    
    func fetchNextBusinesses() {
        presenter.fetchNextBusiness(latLong: latLong, searchTerm: searchTerm, completed: { businessesList in
            if let businesses = businessesList {
                self.businesses.append(contentsOf: businesses)
                self.businessTableView.reloadData()
                self.addAnnotationsOnMap(businesses: businesses)
            }
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filterViewController = navigationController.topViewController as! FilterViewController
        filterViewController.filters = filters
    }
}

extension BusinessesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = businessTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - businessTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && businessTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                fetchNextBusinesses()
            }
        }
    }
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
        searchBar.enablesReturnKeyAutomatically = false
        
        navigationItem.titleView = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            if(self.searchTerm != searchTerm) {
                self.businessTableView.setContentOffset(CGPoint.zero, animated: false)
                populateList(searchTerm: searchTerm)
                self.searchTerm = searchTerm
            }
        } else {
            if(searchTerm != "") {
                self.businessTableView.setContentOffset(CGPoint.zero, animated: false)
                populateList()
                searchTerm = ""
            }
        }
        searchBar.resignFirstResponder()
    }
}

extension BusinessesViewController: CLLocationManagerDelegate {
    func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            userLocation = location
            latLong = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
        
        if(!locationSet) {
            locationSet = true
            populateList()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("location service fail: \(error)")
        populateList()
    }
}

extension BusinessesViewController {
    
    func addAnnotationOnMap(business: Business) {
        if(business.latitude != -1 && business.longitude != -1) {
            let annotation = MKPointAnnotation()
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: business.latitude, longitude: business.longitude)
            annotation.coordinate = coordinate
            annotation.title = business.name ?? ""
            businessMapView.addAnnotation(annotation)
        }
    }
    
    func addAnnotationsOnMap(businesses: [Business]) {
        for business in businesses  {
            addAnnotationOnMap(business: business)
        }
    }
}
