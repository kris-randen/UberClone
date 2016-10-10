//
//  RiderLocationViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Kris Rajendren on Oct/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RiderLocationViewController: UIViewController, MKMapViewDelegate {
    
    var requestLocation = CLLocationCoordinate2D(latitude: Constants.Map.Location.BaseInitializer.latitude, longitude: Constants.Map.Location.BaseInitializer.longitude)
    var requestUserName: String = Constants.String.Empty

    // MARK: Outlets
    
    @IBOutlet weak var userLocationMap: MKMapView!
    @IBAction func acceptRequest(_ sender: AnyObject) {
        let query = PFQuery(className: Constants.Parse.Object.UserRequest)
        query.whereKey(Constants.Parse.UserRequest.UserName, equalTo: requestUserName)
        query.findObjectsInBackground { (objects, error) in
            if let userRequests = objects
            {
                for userRequest in userRequests
                {
                    userRequest[Constants.Parse.UserRequest.CoachResponded] = PFUser.current()?.username
                    userRequest.saveInBackground()
                    
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        if let placemarks = placemarks
                        {
                            if let placemark = placemarks.first
                            {
                                let mkPlacemark = MKPlacemark(placemark: placemark)
                                let mapItem = MKMapItem(placemark: mkPlacemark)
                                mapItem.name = self.requestUserName
                                
                                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                mapItem.openInMaps(launchOptions: launchOptions)
                            }
                        }
                    })
                }
            }
        }
        
    }
    @IBOutlet weak var acceptRequestButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let region = MKCoordinateRegionMakeWithDistance(requestLocation, Constants.Map.Distance.SpanHeight, Constants.Map.Distance.SpanWidth)
        
        userLocationMap.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = "\(requestUserName)'s Location"
        userLocationMap.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
