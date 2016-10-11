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
    
    var coachOnTheWay = false
    
    var locationManger = CLLocationManager()
    
    var userRequestActive = true
    
    var userLocation: CLLocationCoordinate2D = Constants.Map.Location.BaseInitializer

    
    @IBOutlet weak var riderOnMapView: MKMapView!
    @IBOutlet weak var callCoachLabel: UIButton!
    @IBAction func callCoachButton(_ sender: AnyObject)
    {
        if userRequestActive
        {
            callCoachLabel.setBackgroundImage(#imageLiteral(resourceName: " Call Coach"), for: [])
            userRequestActive = false
            
            let query = PFQuery(className: Constants.Parse.Object.UserRequest)
            query.whereKey(Constants.Parse.Object.UserName, equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground(block: { (objects, error) in
                if let userRequests = objects
                {
                    for userRequest in userRequests
                    {
                        userRequest.deleteInBackground()
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
                userRequestActive = true
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
            locationManger.stopUpdatingLocation()
            PFUser.logOut()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        callCoachLabel.isHidden = true
        
        let query = PFQuery(className: Constants.Parse.Object.UserRequest)
        
        query.whereKey(Constants.Parse.Object.UserName, equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            if let userRequests = objects
            {
                if userRequests.count > 0
                {
                    self.userRequestActive = true
                    self.callCoachLabel.setBackgroundImage(#imageLiteral(resourceName: " Cancel"), for: [])
                }
            }
            self.callCoachLabel.isHidden = false
        })

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate
        {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if coachOnTheWay == false
            {
                let region = MKCoordinateRegionMakeWithDistance(userLocation, Constants.Map.Distance.SpanHeight, Constants.Map.Distance.SpanWidth)
                
                self.riderOnMapView.setRegion(region, animated: true)
                
                self.riderOnMapView.removeAnnotations(self.riderOnMapView.annotations)
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = userLocation
                
                annotation.title = Constants.Map.Annotation.TitleForCurrentLocation
                
                self.riderOnMapView.addAnnotation(annotation)
            }
            
            let query = PFQuery(className: Constants.Parse.Object.UserRequest)
            
            query.whereKey(Constants.Parse.Object.UserName, equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground(block: { (objects, error) in
                if let userRequests = objects
                {
                    for userRequest in userRequests
                    {
                        userRequest[Constants.Parse.UserRequest.Location] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        userRequest.saveInBackground()
                    }
                }
            })
        }
        if userRequestActive == true
        {
            let query = PFQuery(className: Constants.Parse.Object.UserRequest)
            query.whereKey(Constants.Parse.Properties.UserName, equalTo: (PFUser.current()?.username!)!)
            query.findObjectsInBackground(block: { (objects, error) in
                if let userRequests = objects
                {
                    for userRequest in userRequests
                    {
                        if let coachUserName = userRequest[Constants.Parse.UserRequest.CoachResponded]
                        {
                            let query = PFQuery(className: Constants.Parse.Object.CoachLocation)
                            query.whereKey(Constants.Parse.Properties.UserName, equalTo: coachUserName)
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let coachLocations = objects
                                {
                                    for coachLocationObject in coachLocations
                                    {
                                        if let coachLocation = coachLocationObject[Constants.Parse.Properties.Location] as? PFGeoPoint
                                        {
                                            self.coachOnTheWay = true
                                            
                                            let coachCLLocation = CLLocation(latitude: coachLocation.latitude, longitude: coachLocation.longitude)
                                            let userCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            let distanceInMs = userCLLocation.distance(from: coachCLLocation)
                                            let distanceInKMs = round(distanceInMs) / Constants.Conversions.Distance.MetersInKilometers
                                            //print("DRIVER is \(distanceInKMs) kms away.")
                                            self.callCoachLabel.setBackgroundImage(#imageLiteral(resourceName: " Track"), for: [])
                                            
                                            let latDeltaSpan = (abs(coachLocation.latitude - self.userLocation.latitude) * Constants.Map.Display.DefaultLatitudeScaling) + Constants.Map.Display.DefaultLatitudeOffsetDegress
                                            let longDeltaSpan = (abs(coachLocation.longitude - self.userLocation.longitude) * Constants.Map.Display.DefaultLongitudeScaling) + Constants.Map.Display.DefaultLongitudeOffsetDegrees
                                            let latDeltaCenter = 0.00
                                                //(coachLocation.latitude - self.userLocation.latitude) / 2
                                            let longDeltaCenter = 0.00
                                                //(coachLocation.longitude - self.userLocation.longitude) / 2
                                            let center = CLLocationCoordinate2DMake((self.userLocation.latitude + latDeltaCenter), (self.userLocation.longitude + longDeltaCenter))
                                            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latDeltaSpan, longDeltaSpan))
                                            
                                            self.riderOnMapView.removeAnnotations(self.riderOnMapView.annotations)
                                            self.riderOnMapView.setRegion(region, animated: true)
                                            
                                            let userLocationAnnotation = MKPointAnnotation()
                                            userLocationAnnotation.coordinate = self.userLocation
                                            userLocationAnnotation.title = Constants.Map.Annotation.TitleForUserLocation
                                            self.riderOnMapView.addAnnotation(userLocationAnnotation)
                                            
                                            let coachLocationAnnotation = MKPointAnnotation()
                                            coachLocationAnnotation.coordinate = CLLocationCoordinate2DMake(coachLocation.latitude, coachLocation.longitude)
                                            coachLocationAnnotation.title = Constants.Map.Annotation.TitleForCoachLocation
                                            self.riderOnMapView.addAnnotation(coachLocationAnnotation)
                                            
                                        }
                                    }
                                }
                            })
                        }
                        
                    }
                }
            })
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
