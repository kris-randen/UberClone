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

    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Constants.Alert.Title.OK, style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
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
                displayAlert(title: Constants.Alert.Title.EmptyUserName, message: Constants.Alert.Message.EmptyUserName)
            }
            else if !userName.isEmpty() && password.isEmpty()
            {
                displayAlert(title: Constants.Alert.Title.EmptyPassword, message: Constants.Alert.Message.EmptyPassword)
            }
            else if userName.isEmpty() && password.isEmpty()
            {
                displayAlert(title: Constants.Alert.Title.EmptyUserNameAndPassword, message: Constants.Alert.Message.EmptyUserNameAndPassword)
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
                            self.displayAlert(title: Constants.Alert.Title.SignUpFailed, message: displayedErrorMessage)
                        }
                        else
                        {
                            print(Constants.Display.Message.SignUpSuccessful)
                            
                            if let isDriver = PFUser.current()?[Constants.Key.IsDriver] as? Bool
                            {
                                if isDriver
                                {
                                    
                                }
                                else
                                {
                                    self.segue(withIdentifier: Constants.Storyboard.Segue.LogInToRiderOnMap)
                                }
                            }
                        }
                    })
                } else
                {
                    PFUser.logInWithUsername(inBackground: userName, password: password, block: { (user, error) in
                        if let parseError = (error as? NSError)?.userInfo[Constants.Key.Error] as? String
                        {
                            displayedErrorMessage = parseError
                            self.displayAlert(title: Constants.Alert.Title.LogInFailed, message: displayedErrorMessage)
                        } else
                        {
                            print(Constants.Display.Message.LogInSuccessful)
                            self.segue(withIdentifier: Constants.Storyboard.Segue.LogInToRiderOnMap)
                        }
                    })
                }
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
    
    private struct Constants {
        struct Storyboard
        {
            struct Segue
            {
                static let LogInToRiderOnMap = "ShowRiderOnMap"
                static let Logout = "Logout"
            }
        }
        struct String
        {
            static let Empty = ""
        }
        struct Button
        {
            struct Title
            {
                static let LogIn = "Log In"
                static let SignUp = "Sign Up"
                static let SwitchToLogIn = "Switch to Log In"
                static let SwitchToSignUp = "Switch to Sign Up"
            }
        }
        struct Alert
        {
            struct Title
            {
                static let OK = "OK"
                static let Continue = "Continue"
                static let Cancel = "Cancel"
                static let SignUp = "Sign Up"
                static let LogIn = "Log In"
                static let SignUpFailed = "Sign Up Failed."
                static let LogInFailed = "Log In Failed."
                static let EmptyUserName = "User Name Not Captured"
                static let EmptyPassword = "Password Not Captured"
                static let EmptyUserNameAndPassword = "User Name and Password Not Captured"
            }
            struct Message
            {
                static let SignUpFailed = "Sorry, the sign up attempt was not successful."
                static let LogInFailed = "Sorry, the log in attempt was not successful."
                static let EmptyUserName = "How would you like to be called? Please enter a username of your choice."
                static let EmptyPassword = "Your account security is our priority. Please enter a secure password."
                static let EmptyUserNameAndPassword = "Your account security is our priority. Please enter a user name and password."
            }
        }
        struct Key
        {
            static let IsDriver = "isDriver"
            static let IsUser = "isUser"
            static let Error = "error"
            static let LogIn = "Log In"
            static let SignUp = "Sign Up"
        }
        struct Error
        {
            struct Message
            {
                static let TryAgain = "Please, try again later."
            }
        }
        struct Display
        {
            struct Message
            {
                static let LogInSuccessful = "You logged in successfully."
                static let SignUpSuccessful = "You signed up successfully."
            }
        }
        struct Mirror
        {
            struct Key
            {
                static let Alert = "Alert"
                static let Key = "Key"
                static let Button = "Button"
                static let Title = "Title"
                static let Message = "Message"
                static let Error = "Error"
                static let Display = "Display"
                static let LogIn = Constants.Key.LogIn
                static let LogInSuccessful = "logInSuccessful"
                static let SignUpSuccessful = "signUpSuccessful"
            }
  
        }
    }
    let ConstantsDict: [String: [String: [String: String]]] = [
        Constants.Mirror.Key.Display: [
                Constants.Mirror.Key.Message: [
                    Constants.Mirror.Key.LogInSuccessful: Constants.Display.Message.LogInSuccessful,
                    Constants.Mirror.Key.SignUpSuccessful: Constants.Display.Message.SignUpSuccessful
            ]
        ]
    ]
}
