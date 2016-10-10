//
//  DriverViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Kris Rajendren on Oct/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class DriverViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var requestUserNames = [String]()
    
    var requestLocations = [CLLocationCoordinate2D]()
    
    var driverLocation = CLLocationCoordinate2D(latitude: Constants.Map.Location.BaseInitializer.latitude, longitude: Constants.Map.Location.BaseInitializer.longitude)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.DriverViewController.Segue.Logout
        {
            locationManager.startUpdatingLocation()
            PFUser.logOut()
            self.navigationController?.navigationBar.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate
        {
            let query = PFQuery(className: Constants.Parse.Object.UserRequest)
            
            driverLocation = location
            
            print("DRIVER LOCATION = \(driverLocation)")
            
            query.whereKey(Constants.Parse.UserRequest.Location, nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            
            query.limit = Constants.Parse.Query.DefaultLimit
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let userRequests = objects
                {
                    self.requestUserNames.removeAll()
                    self.requestLocations.removeAll()
                    
                    for userRequest in userRequests
                    {
                        if let userName = userRequest[Constants.Parse.Object.UserName] as? String
                        {
                            self.requestUserNames.append(userName)
                            if let requestLocation = userRequest[Constants.Parse.UserRequest.Location] as? PFGeoPoint
                            {
                                print("REQUEST LOCATION = \(requestLocation)")
                                self.requestLocations.append(CLLocationCoordinate2D(latitude: requestLocation.latitude, longitude: requestLocation.longitude))
                            }
                            else
                            {
                                print(Constants.Display.Message.UserLocationNotConvertibleToCLLocation)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
                else
                {
                    print(Constants.Display.Message.NoRequestsFound)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Constants.DriverViewController.TableView.DefaultNumberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requestUserNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Finding the distance between driver location and request location
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        
        let userCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        let distanceInMs = driverCLLocation.distance(from: userCLLocation)
        
        let distanceInKMs = round(distanceInMs) / Constants.Conversions.Distance.MetersInKilometers
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.DriverViewController.TableView.DefaultCellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = requestUserNames[indexPath.row] + " - \(distanceInKMs) kms away."

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
