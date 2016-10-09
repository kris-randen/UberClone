//
//  RiderViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Kris Rajendren on Oct/7/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var callCoachButtonImage: UIImage? = #imageLiteral(resourceName: " Cancel")
    var userRequestActive = true
    var locationManger = CLLocationManager()
    var userLocation: CLLocationCoordinate2D = Constants.Map.Location.BaseInitializer
    
    @IBOutlet weak var riderOnMapView: MKMapView!
    @IBOutlet weak var callCoachLabel: UIButton!
    @IBAction func callCoachButton(_ sender: AnyObject)
    {
        if userRequestActive
        {
            self.callCoachLabel.setBackgroundImage(#imageLiteral(resourceName: " Call Coach"), for: [])
            userRequestActive = false
            
            let query = PFQuery(className: Constants.Parse.Object.UserRequest)
            
            query.whereKey(Constants.Parse.Object.UserName, equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let userRequests = objects
                {
                    for request in userRequests
                    {
                        request.deleteInBackground()
                    }
                }
            })
        }
        else
        {
            if userLocation.latitude != Constants.Map.Location.BaseInitializer.latitude
                &&
               userLocation.longitude != Constants.Map.Location.BaseInitializer.longitude
            {
                self.userRequestActive = true
                self.callCoachLabel.setBackgroundImage(#imageLiteral(resourceName: " Cancel"), for: [])
                
                let userRequest = PFObject(className: Constants.Parse.Object.UserRequest)
                userRequest[Constants.Parse.UserRequest.UserName] = PFUser.current()?.username
                userRequest[Constants.Parse.UserRequest.Location] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                userRequest.saveInBackground(block: { (success, error) in
                    if success
                    {
                        print(Constants.Display.Message.SuccessfullyCalledCoach)
                    }
                    else
                    {
                        self.callCoachLabel.setBackgroundImage(#imageLiteral(resourceName: " Call Coach"), for: [])
                        self.userRequestActive = false
                        
                        displayAlert(target: self, title: Constants.Alert.Title.FailedToCallCoach, message: Constants.Alert.Message.FailedToCallCoach)
                    }
                })
            }
            else
            {
                displayAlert(target: self, title: Constants.Alert.Title.CurrentLocationNotFound, message: Constants.Alert.Message.CurrentLocationNotFound)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.RiderViewController.Segue.Logout
        {
            PFUser.logOut()
            print(Constants.RiderViewController.Segue.Logout)
            print(segue.identifier)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate
        {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegionMakeWithDistance(userLocation, Constants.Map.Distance.SpanHeight, Constants.Map.Distance.SpanWidth)
            self.riderOnMapView.setRegion(region, animated: true)
            
            self.riderOnMapView.removeAnnotations(self.riderOnMapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation
            annotation.title = Constants.Map.Annotation.TitleForUserLocation
            self.riderOnMapView.addAnnotation(annotation)
        }
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
