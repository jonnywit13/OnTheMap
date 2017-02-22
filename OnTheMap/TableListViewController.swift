//
//  TableListViewController.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 20/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import Foundation
import UIKit

class TableListViewController: UITableViewController {
    
    @IBOutlet var studentTableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var studentPin: UIBarButtonItem!
    
    var students = [StudentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
                    
                     self.studentTableView.reloadData()
                    
                }
            } else {
                print(error!)
                self.displayError(error: "Could not download student data")
                return
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
    
    @IBAction func refreshData(_ sender: Any) {
        
        getStudentLocations()
        
    }
    
    @IBAction func addStudentPin(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingView") as! InformationPostingViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        let student = students[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = student.firstName + " " + student.lastName
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[(indexPath as NSIndexPath).row]

        let app = UIApplication.shared
        let url = URL(string: student.mediaURL)!
        app.open(url, options: [:], completionHandler: nil)
        
    }
    
    func displayError(error: String) {
        
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
}
