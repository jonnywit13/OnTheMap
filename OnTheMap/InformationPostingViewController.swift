//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 21/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var locationSearch: UITextField!
    @IBOutlet weak var studentMap: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var enterLinkLabel: UILabel!
    @IBOutlet weak var submitLinkButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewDidLoad() {
        
        studentMap.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = true
        
        urlTextField.isHidden = true
        enterLinkLabel.isHidden = true
        submitLinkButton.isHidden = true
        
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func changeUIState(hide: Bool) {
        
        mainTitle.isHidden = hide
        locationSearch.isHidden = hide
        findOnMapButton.isHidden = hide
        urlTextField.isHidden = !hide
        enterLinkLabel.isHidden = !hide
        submitLinkButton.isHidden = !hide
    }
    
    @IBAction func findLocation(_ sender: Any) {
        
        activityIndicator.isHidden = false
        
        if let location = locationSearch.text {
            
            CLGeocoder().geocodeAddressString(location, completionHandler: { (results, error) in
                
                guard error == nil else {
                    print((error?.localizedDescription)!)
                    self.displayError(error: "Your location could not be found, please try again")
                    self.activityIndicator.isHidden = true
                    return
                }
                
                guard let results = results else {
                    self.displayError(error: "Your location could not be found, please try again")
                    self.activityIndicator.isHidden = true
                    return
                }
                
                performUIUpdatesOnMain {
                    if results.count > 0 {
                        let pin = results[0]
                        self.studentMap.showAnnotations([MKPlacemark(placemark: pin)] , animated: true)
                    
                        let location = pin.location
                        let coordinates = location?.coordinate
                        self.latitude = coordinates!.latitude
                        self.longitude = coordinates!.longitude
                        
                        
                        self.changeUIState(hide: true)
                        self.activityIndicator.isHidden = true
                        
                    }
                }
            })
            
        } else {
            self.displayError(error: "Please enter a location")
            self.activityIndicator.isHidden = true
            return
        }
        
        
    }
    
    @IBAction func submitStudentLocation(_ sender: Any) {
        
        activityIndicator.isHidden = false
        
        if let mediaURL = urlTextField.text {
        
            let mapString = locationSearch.text!
            let userKey = UserModel.key
            let firstname = UserModel.firstname
            let lastname = UserModel.lastname
            
            let jsonBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(firstname)\", \"lastName\": \"\(lastname)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(self.latitude), \"longitude\": \(self.longitude)}"
            
            if UserModel.objectID.isEmpty {
                //User does not have a Pin, create a new one
                NetworkConnections.sharedInstance().taskForParseApiPOSTMethod(jsonBody: jsonBody) { (results, error) in
                   performUIUpdatesOnMain {
                        if error == nil {
                            if let objectId = results?[Constants.ParseApiKeys.ObjectID] as? String {
                                UserModel.objectID = objectId
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.activityIndicator.isHidden = true
                                self.displayError(error: "Could not find ObjectID")
                                return
                            }
                        } else {
                            self.activityIndicator.isHidden = true
                            self.displayError(error: error!)
                        return
                        }
            
                    }
                }
            } else {
                //User Pin exists, update the data
                NetworkConnections.sharedInstance().taskForParseApiPUTMethod(objectId: UserModel.objectID, jsonBody: jsonBody) { (results, error) in
                    performUIUpdatesOnMain {
                        if error == nil {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.displayError(error: error!)
                        }
                    }
                }
            }
        } else {
            self.activityIndicator.isHidden = true
            self.displayError(error: "Please enter a URL")
            return
        }
        
    }
    
    func displayError(error: String) {
        
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)

    }
    
}
