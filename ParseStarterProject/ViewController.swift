/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    var signUpMode = true
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBAction func signUpOrLoginButton(_ sender: AnyObject)
    {
        if userNameTextField.text == "" || passwordTextField.text == ""
        {
            displayAlert(title: "Sorry!", message: "Please enter a user name and password.")
        } else
        {
            if signUpMode
            {
                let user = PFUser()
                user.username = userNameTextField.text
                user.password = passwordTextField.text
                user["isDriver"] = isDriverSwitch.isOn
                user.signUpInBackground(block: { (success, error) in
                    if let error = error {
                        var displayedErrorMessage = "Please try again later."
                        let error = error as NSError
                        if let parseError = error.userInfo["error"] as? String {
                            displayedErrorMessage = parseError
                        }
                        self.displayAlert(title: "Sign Up Failed", message: displayedErrorMessage)
                    } else {
                        print("Sign Up Successful.")
                    }
                })
            }
        }
    }
    @IBOutlet weak var signUpOrLoginLabel: UIButton!
    
    @IBAction func signUpSwitchButton(_ sender: AnyObject)
    {
        if signUpMode
        {
            signUpOrLoginLabel.setTitle("Log In", for: [])
            signUpSwitchLabel.setTitle("Switch to Sign Up", for: [])
            signUpMode = false
        } else
        {
            signUpOrLoginLabel.setTitle("Sign Up", for: [])
            signUpSwitchLabel.setTitle("Switch to Log In", for: [])
            signUpMode = true
        }
    }
    
    @IBOutlet weak var signUpSwitchLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let testObject = PFObject(className: "TestObject2")
        
        testObject["foo"] = "bar"
        
        testObject.saveInBackground { (success, error) -> Void in
            
            // added test for success 11th July 2016
            
            if success {
                
                print("Object has been saved.")
                
            } else {
                
                if error != nil {
                    
                    print (error)
                    
                } else {
                    
                    print ("Error")
                }
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
