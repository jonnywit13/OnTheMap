//
//  Constants.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 09/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import UIKit

struct Constants {
    
    struct UdacityUrls {
        static let NewSession = "https://www.udacity.com/api/session"
        static let GetUserData = "https://www.udacity.com/api/users/"
    }
    
    struct UdacityMethods {
        static let Get = "GET"
        static let Post = "POST"
        static let Delete = "DELETE"
    }
    
    struct UdacityHeaderKeys {
        static let CookieHeader = "X-XSRF-TOKEN"
    }
    
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct ParseApi {
        static let Scheme = "https"
        static let Host = "parse.udacity.com"
        static let Path = "/parse/classes/StudentLocation"
    }
    
    struct ParseApiKeys {
        static let ObjectID = "objectId"
    }
    
    struct ParseApiMethods {
        static let Post = "POST"
        static let Put = "PUT"
    }
    
    struct ParseApiHeaderKeys {
        static let ApplicationId = "X-Parse-Application-Id"
        static let RestApiKey = "X-Parse-REST-API-Key"
    }
    
    struct ParseApiHeaderValues {
        static let AppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct ParseApiParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let WhereIs = "where"
        static let Results = "results"
        static let UniqueKey = "uniqueKey"
    }
    
    struct StudentData {
        static let Firstname = "firstName"
        static let Lastname = "lastName"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    
}
