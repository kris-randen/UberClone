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
        
        alertController.addAction(UIAlertAction(title: Constants.Alert.Title.ok, style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    var signUpMode = true
    
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
                displayAlert(title: Constants.Alert.Title.emptyUserName, message: Constants.Alert.Message.emptyUserName)
            }
            else if !userName.isEmpty() && password.isEmpty()
            {
                displayAlert(title: Constants.Alert.Title.emptyPassword, message: Constants.Alert.Message.emptyPassword)
            }
            else if userName.isEmpty() && password.isEmpty()
            {
                displayAlert(title: Constants.Alert.Title.emptyUserNameAndPassword, message: Constants.Alert.Message.emptyUserNameAndPassword)
            }
            else
            {
                var displayedErrorMessage: String = Constants.String.empty
                if signUpMode
                {
                    let user = PFUser()
                    user.username = userName
                    user.password = password
                    user[Constants.Key.isDriver] = isDriverSwitch.isOn
                    user.signUpInBackground(block: { (success, error) in
                        if let parseError = (error as? NSError)?.userInfo[Constants.Key.error] as? String
                        {
                            displayedErrorMessage = parseError
                            self.displayAlert(title: Constants.Alert.Title.signUpFailed, message: displayedErrorMessage)
                        } else
                        {
                            print(Constants.Display.Message.signUpSuccessful)
                        }
                    })
                } else
                {
                    PFUser.logInWithUsername(inBackground: userName, password: password, block: { (user, error) in
                        if let parseError = (error as? NSError)?.userInfo[Constants.Key.error] as? String
                        {
                            displayedErrorMessage = parseError
                            self.displayAlert(title: Constants.Alert.Title.logInFailed, message: displayedErrorMessage)
                        } else
                        {
                            print(Constants.Display.Message.logInSuccessful)
                        }
                    })
                }
            }
        }
    }

    func parseSignUpLogIn(logInOrSignUp action: String)
    {
        
    }
    
    @IBOutlet weak var signUpOrLoginLabel: UIButton!
    
    @IBAction func signUpSwitchButton(_ sender: AnyObject)
    {
        if signUpMode
        {
            signUpOrLoginLabel.setTitle(Constants.Button.Title.logIn, for: [])
            signUpSwitchLabel.setTitle(Constants.Button.Title.switchToSignUp, for: [])
            signUpMode = false
        } else
        {
            signUpOrLoginLabel.setTitle(Constants.Button.Title.signUp, for: [])
            signUpSwitchLabel.setTitle(Constants.Button.Title.switchToLogIn, for: [])
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
    
    private struct Constants {
        struct String
        {
            static let empty = ""
        }
        struct Button
        {
            struct Title
            {
                static let logIn = "Log In"
                static let signUp = "Sign Up"
                static let switchToLogIn = "Switch to Log In"
                static let switchToSignUp = "Switch to Sign Up"
            }
        }
        struct Alert
        {
            struct Title
            {
                static let ok = "OK"
                static let continue_ = "Continue"
                static let cancel = "Cancel"
                static let signUp = "Sign Up"
                static let logIn = "Log In"
                static let signUpFailed = "Sign Up Failed."
                static let logInFailed = "Log In Failed."
                static let emptyUserName = "User Name Not Captured"
                static let emptyPassword = "Password Not Captured"
                static let emptyUserNameAndPassword = "User Name and Password Not Captured"
            }
            struct Message
            {
                static let signUpFailed = "Sorry, the sign up attempt was not successful."
                static let logInFailed = "Sorry, the log in attempt was not successful."
                static let emptyUserName = "How would you like to be called? Please enter a username of your choice."
                static let emptyPassword = "Your account security is our priority. Please enter a secure password."
                static let emptyUserNameAndPassword = "Your account security is our priority. Please enter a user name and password."
            }
        }
        struct Key
        {
            static let isDriver = "isDriver"
            static let isUser = "isUser"
            static let error = "error"
            static let logIn = "Log In"
            static let signUp = "Sign Up"
        }
        struct Error
        {
            struct Message
            {
                static let tryAgain = "Please, try again later."
            }
        }
        struct Display
        {
            struct Message
            {
                static let logInSuccessful = "You logged in successfully."
                static let signUpSuccessful = "You signed up successfully."
            }
        }
        struct Mirror
        {
            struct Key
            {
                static let alert = "Alert"
                static let key = "Key"
                static let button = "Button"
                static let title = "Title"
                static let message = "Message"
                static let error = "Error"
                static let display = "Display"
                static let logIn = Constants.Key.logIn
                static let logInSuccessful = "logInSuccessful"
                static let signUpSuccessful = "signUpSuccessful"
            }
  
        }
    }
    let constants: [String: [String: [String: String]]] = [
        Constants.Mirror.Key.display: [
                Constants.Mirror.Key.message: [
                    Constants.Mirror.Key.logInSuccessful: Constants.Display.Message.logInSuccessful,
                    Constants.Mirror.Key.signUpSuccessful: Constants.Display.Message.signUpSuccessful
            ]
        ]
    ]
}
