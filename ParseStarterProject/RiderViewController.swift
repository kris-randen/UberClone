//
//  RiderViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Kris Rajendren on Oct/7/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class RiderViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.Segue.Logout
        {
            PFUser.logOut()
            print(Constants.Storyboard.Segue.Logout)
            print(segue.identifier)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private struct Constants
    {
        struct Storyboard
        {
            struct Segue
            {
                static let Logout = "Logout"
            }
        }
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
