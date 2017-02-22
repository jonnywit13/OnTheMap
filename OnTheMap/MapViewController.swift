//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 13/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var studentPin: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    
    var students = [StudentModel]()
    
    override func viewDidLoad() {
        
        map.delegate = self
        
        getUserData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentLocations()
        
    }
    
    func getStudentLocations() {
        
        let parameters:[String:Any] = [Constants.ParseApiParameterKeys.Limit : 100,
                                       Constants.ParseApiParameterKeys.Skip : 0,
                                       Constants.ParseApiParameterKeys.Order : "-updatedAt"
        ]
        
        NetworkConnections.sharedInstance().taskForParseApiGETMethod(parameters: parameters as [String:AnyObject]?, false) { (data, error) in
            if error == nil {
                
                guard let results = data?[Constants.ParseApiParameterKeys.Results] as? [[String:AnyObject]] else{
                    print("Could not find data for key results")
                    self.displayError(error: "An error has occurred, please try again")
                    return
                }
                
                performUIUpdatesOnMain {
                    self.students = StudentModel.studentInformationFromResults(results: results)
                    
                    self.updateMapAnnotations(self.students)
                }
            } else {
                print(error!)
                self.displayError(error: "Could not download student data")
                return
            }
            
            
        }
    }
    
    func updateMapAnnotations(_ students: [StudentModel]) {
        
        self.map.removeAnnotations(self.map.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for student in students {
            
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let firstname = student.firstName
            let lastname = student.lastName
            let mediaURL = student.mediaURL
            
           
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstname) \(lastname)"
            annotation.subtitle = mediaURL
      
            annotations.append(annotation)
        }
        
        self.map.addAnnotations(annotations)
        
    }
    
    func getUserData() {
        
        let stringToEscape = "{\"\(Constants.ParseApiParameterKeys.UniqueKey)\":\"\(UserModel.key)\"}"
        
        let parameters:[String:Any] = ["toEscape" : stringToEscape]
        
        //Get the current Users Data in case they already have a pin on the map
        NetworkConnections.sharedInstance().taskForParseApiGETMethod(parameters: parameters as [String : AnyObject]?, true ) { (results, error) in
        
            if error == nil {
                guard let data = results?[Constants.ParseApiParameterKeys.Results] as? [[String:AnyObject]] else{
                    //Not necessary to inform the user of error
                    print("Could not find Results key")
                    return
                }
                
                guard let objectId = data.last?[Constants.StudentData.ObjectId] as? String else{
                    //Not necessary to inform user of error
                    print("Could not find ObjectId key")
                    return
                }
                
                //Add it to the UserModel for use in the Information Posting View
                UserModel.objectID = objectId
            }
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
        
        NetworkConnections.sharedInstance().taskForUdacityDELETEMethod(Constants.UdacityUrls.NewSession) { (response, error) in
            
            performUIUpdatesOnMain {
                if response! {
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    print(error!)
                }
            }
        }
        
    }
    
    //Action when clicking the refresh button
    @IBAction func refreshData(_ sender: Any) {
        
        getStudentLocations()
    }
    
    @IBAction func addStudentPin(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingView") as! InformationPostingViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "StudentMark"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                let url = URL(string: toOpen)!
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    func displayError(error: String) {
        
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
}
