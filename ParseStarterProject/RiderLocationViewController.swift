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

    // MARK: Outlets
    
    @IBOutlet weak var userLocationMap: MKMapView!
    @IBAction func acceptRequest(_ sender: AnyObject) {
    }
    @IBOutlet weak var acceptRequestButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("REQUEST LOCATION = \(requestLocation)")
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
