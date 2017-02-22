//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 02/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//
import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func processLogin(_ sender: Any) {
        
        activityIndicator.isHidden = false
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            feedbackLabel.text = "Username or Password Empty."
            activityIndicator.isHidden = true
        } else {
            
            let email = emailTextField.text!
            let password = passwordTextField.text!
            let jsonBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
            
            NetworkConnections.sharedInstance().taskForUdacityPOSTMethod(Constants.UdacityUrls.NewSession, jsonBody) { (result, error) in
                performUIUpdatesOnMain {
                    if error == nil{
                        guard let account = result?["account"] as? [String:AnyObject] else{
                            self.feedbackLabel.text = "The Email / Password is incorrect. Please try again."
                            return
                        }
                        self.completeLogin(account: account)
                    }else{
                        self.activityIndicator.isHidden = true
                        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
        }
        
    }
    
    func completeLogin(account: [String:AnyObject?]) {
        if let key = account["key"] as? String{
            
            UserModel.key = key
            
            NetworkConnections.sharedInstance().taskForUdacityGETMethod(Constants.UdacityUrls.GetUserData, key)    { (results, error) in
                if error == nil {
                    
                    performUIUpdatesOnMain {
                        let userData = results?["user"] as! NSDictionary
                        let firstName = userData["first_name"] as! String
                        let lastName = userData["last_name"] as! String
                    
                    
                        UserModel.firstname = firstName
                        UserModel.lastname = lastName
                    
                        self.activityIndicator.isHidden = true
                        
                        let controller =
                            self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
                        self.present(controller, animated: true, completion: nil)
                    }
                }
                else {
                    print(error!)
                    self.activityIndicator.isHidden = true
                    self.feedbackLabel.text = error
                }
            
            }
            
            
            
            
        } else {
            self.activityIndicator.isHidden = true
            self.feedbackLabel.text = "Could not find key"
            return
        }
        
        
        
    }
}

