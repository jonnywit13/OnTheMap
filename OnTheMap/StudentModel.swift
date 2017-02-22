//
//  StudentModel.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 13/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import Foundation
struct StudentModel{
    var firstName : String
    var lastName : String
    var objectId : String
    var uniqueKey : String
    var mapString : String
    var mediaURL : String
    var latitude : Double
    var longitude : Double
    
    init?(dictionary: [String:AnyObject]){
        guard let firstname = dictionary[Constants.StudentData.Firstname] as? String else{
            return nil
        }
        firstName = firstname
        
        guard let lastname = dictionary[Constants.StudentData.Lastname] as? String else{
            return nil
        }
        lastName = lastname
        
        guard let objectid = dictionary[Constants.StudentData.ObjectId] as? String else{
            return nil
        }
        objectId = objectid
        
        guard let uniquekey = dictionary[Constants.StudentData.UniqueKey] as? String else{
            return nil
        }
        uniqueKey = uniquekey
        
        guard let mapstring = dictionary[Constants.StudentData.MapString] as? String else{
            return nil
        }
        mapString = mapstring
        
        guard let mediaurl = dictionary[Constants.StudentData.MediaURL] as? String else{
            return nil
        }
        mediaURL = mediaurl
        
        guard let lat = dictionary[Constants.StudentData.Latitude] as? Double else{
            return nil
        }
        latitude = lat
        
        guard let long = dictionary[Constants.StudentData.Longitude] as? Double else{
            return nil
        }
        longitude = long
    }
    
    static func studentInformationFromResults(results: [[String:AnyObject]]) -> [StudentModel]{
        var students = [StudentModel]()
        
        for student in results{
            if let eachStudent = StudentModel(dictionary: student){
                students.append(eachStudent)
            }
        }
        return students
    }
}
