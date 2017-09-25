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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        filterViewController.delegate = self
    }
}

extension BusinessesViewController {
    /**
     All Api call are managed in this extension
     **/
    func populateList() {
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        presenter.fetchBusinessInfo(latLong: latLong, searchTerm: searchTerm, filters: filters, completed: { businessesList in
            self.businesses = businessesList
            self.businessTableView.reloadData()
            let allAnnotations = self.businessMapView.annotations
            self.businessMapView.removeAnnotations(allAnnotations)
            if let businesses = businessesList {
                self.addAnnotationsOnMap(businesses: businesses)
            }
            self.stopAnimating()
            if(self.filters == nil) {
                self.filters = Filters(categories: self.businesses.getAllCategories())
            }
        })
    }
    
    func fetchNextBusinesses() {
        presenter.fetchNextBusiness(latLong: latLong, searchTerm: searchTerm, filters: filters, completed: { businessesList in
            if let businesses = businessesList {
                self.businesses.append(contentsOf: businesses)
                self.businessTableView.reloadData()
                self.addAnnotationsOnMap(businesses: businesses)
            }
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
        })
        
    }
}

extension BusinessesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = businessTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - businessTableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && businessTableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
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
                businessTableView.setContentOffset(CGPoint.zero, animated: false)
                self.searchTerm = searchTerm
                filters = nil
                populateList()
                
            }
        } else {
            if(searchTerm != "") {
                businessTableView.setContentOffset(CGPoint.zero, animated: false)
                searchTerm = ""
                filters = nil
                populateList()
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
        populateList()
    }
}

extension BusinessesViewController {
    /*
     Map View releated functions
     */
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        businessMapView.setRegion(region, animated: true)
    }
    
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

extension BusinessesViewController: FilterViewControllerDelegate {
    func filterViewController(filterViewController: FilterViewController, didUpdateFilters filters: Filters) {
        self.filters = filters
        populateList()
    }
}
