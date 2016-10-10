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

extension String
{
    func isEmpty() -> Bool
    {
        return self == ""
    }
}

extension Optional
{
    func isNil() -> Bool
    {
        return self == nil
    }
}

class ViewController: UIViewController {

//    func displayAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        
//        alertController.addAction(UIAlertAction(title: Constants.Alert.Title.OK, style: .default, handler: nil))
//        
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    var signUpMode = true
    var logInSignUpTransition: String = Constants.String.Empty
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBAction func signUpOrLoginButton(_ sender: AnyObject)
    {
        if let userName = userNameTextField.text,
           let password = passwordTextField.text
        {
            if userName.isEmpty() && !password.isEmpty()
            {
                displayAlert(target: self, title: Constants.Alert.Title.EmptyUserName, message: Constants.Alert.Message.EmptyUserName)
                //displayAlert(title: Constants.Alert.Title.EmptyUserName, message: Constants.Alert.Message.EmptyUserName)
            }
            else if !userName.isEmpty() && password.isEmpty()
            {
                displayAlert(target: self, title: Constants.Alert.Title.EmptyPassword, message: Constants.Alert.Message.EmptyPassword)
                //displayAlert(title: Constants.Alert.Title.EmptyPassword, message: Constants.Alert.Message.EmptyPassword)
            }
            else if userName.isEmpty() && password.isEmpty()
            {
                displayAlert(target: self, title: Constants.Alert.Title.EmptyUserNameAndPassword, message: Constants.Alert.Message.EmptyUserNameAndPassword)
                //displayAlert(title: Constants.Alert.Title.EmptyUserNameAndPassword, message: Constants.Alert.Message.EmptyUserNameAndPassword)
            }
            else
            {
                var displayedErrorMessage: String = Constants.String.Empty
                if signUpMode
                {
                    let user = PFUser()
                    user.username = userName
                    user.password = password
                    user[Constants.Key.IsDriver] = isDriverSwitch.isOn
                    user.signUpInBackground(block: { [weak weakSelf = self] (success, error) in
                        if let parseError = (error as? NSError)?.userInfo[Constants.Key.Error] as? String
                        {
                            displayedErrorMessage = parseError
                            displayAlert(target: self, title: Constants.Alert.Title.SignUpFailed, message: displayedErrorMessage)
                            //self.displayAlert(title: Constants.Alert.Title.SignUpFailed, message: displayedErrorMessage)
                            
                            displayAlert(target: self, title: Constants.Alert.Title.SignUpFailed, message: displayedErrorMessage)
                        }
                        else
                        {
                            print(Constants.Display.Message.SignUpSuccessful)
                            self.logInSignUpRiderDriver()
                        }
                    })
                } else
                {
                    PFUser.logInWithUsername(inBackground: userName, password: password, block: { (user, error) in
                        if let parseError = (error as? NSError)?.userInfo[Constants.Key.Error] as? String
                        {
                            displayedErrorMessage = parseError
                            displayAlert(target: self, title: Constants.Alert.Title.LogInFailed, message: displayedErrorMessage)
                            //self.displayAlert(title: Constants.Alert.Title.LogInFailed, message: displayedErrorMessage)
                        } else
                        {
                            print(Constants.Display.Message.LogInSuccessful)
                            self.logInSignUpRiderDriver()
                        }
                    })
                }
            }
        }
    }
    
    func logInSignUpRiderDriver()
    {
        if let isDriver = PFUser.current()?[Constants.Key.IsDriver] as? Bool
        {
            if isDriver
            {
                self.segue(withIdentifier: Constants.ViewController.Segue.LogInToDriverViewController)
            }
            else
            {
                self.segue(withIdentifier: Constants.ViewController.Segue.LogInToRiderOnMap)
            }
        }

    }
    
    func segue(withIdentifier identifier: String)
    {
        performSegue(withIdentifier: identifier, sender: self)
    }

    func parseSignUpLogIn(logInOrSignUp action: String)
    {
        
    }
    
    @IBOutlet weak var signUpOrLoginLabel: UIButton!
    
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBAction func signUpSwitchButton(_ sender: AnyObject)
    {
        if signUpMode
        {
            signUpOrLoginLabel.setTitle(Constants.Button.Title.LogIn, for: [])
            signUpSwitchLabel.setTitle(Constants.Button.Title.SwitchToSignUp, for: [])
            signUpMode = false
            
            isDriverSwitch.isHidden = true
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            
        } else
        {
            signUpOrLoginLabel.setTitle(Constants.Button.Title.SignUp, for: [])
            signUpSwitchLabel.setTitle(Constants.Button.Title.SwitchToLogIn, for: [])
            signUpMode = true
            
            isDriverSwitch.isHidden = false
            riderLabel.isHidden = false
            driverLabel.isHidden = false
        }
    }
    
    @IBOutlet weak var signUpSwitchLabel: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        self.logInSignUpRiderDriver()
    }
    
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
