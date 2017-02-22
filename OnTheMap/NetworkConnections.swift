//
//  NetworkConnections.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 09/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import Foundation
import UIKit


class NetworkConnections : NSObject {
    
    // MARK: Properties
    
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func taskForUdacityGETMethod(_ url: String,_ userKey : String,_ completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        
        let fullUrl = "\(url)\(userKey)"
        
        let request = NSMutableURLRequest(url: URL(string: fullUrl)!)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                completionHandlerForGET(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(uncheckedBounds: (5, data.count))
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        task.resume()
        
    }
    
    func taskForUdacityPOSTMethod(_ url: String,_ jsonBody: String,_ completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: String?) -> Void) {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = Constants.UdacityMethods.Post
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                completionHandlerForPOST(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 403 {
                sendError("Incorrect login credentials, please try again.")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("A network error has occurred, please try again later")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(uncheckedBounds: (5,data.count))
            let newData = data.subdata(in: range)
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    func taskForUdacityDELETEMethod(_ url: String,_ completionHandlerForDELETE: @escaping (_ result: Bool?, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = Constants.UdacityMethods.Delete
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Constants.UdacityHeaderKeys.CookieHeader)
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                completionHandlerForDELETE(false, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            //Got here so no errors
            completionHandlerForDELETE(true, nil)
        }
        task.resume()
        
    }
    
    func taskForParseApiGETMethod(parameters: [String:AnyObject]?,_ isQuery: Bool, completionTaskForParseApiGETMethod: @escaping(_ result: AnyObject?,_ error: String?) -> Void) {
        
        var request: NSMutableURLRequest
        
        
        if(isQuery) {
            
            let escapedString = escapedParameters(parameters: parameters!)
            
            let url = "\(Constants.ParseApi.Scheme)://\(Constants.ParseApi.Host)\(Constants.ParseApi.Path)?where=\(escapedString)"
            
            request = NSMutableURLRequest(url: URL(string: url)!)
            
            
        } else {
            let url = getURLFromParameters(parameters)
            
            request = NSMutableURLRequest(url: url)
            
        }

        request.addValue(Constants.ParseApiHeaderValues.AppId, forHTTPHeaderField: Constants.ParseApiHeaderKeys.ApplicationId)
        request.addValue(Constants.ParseApiHeaderValues.RestKey, forHTTPHeaderField: Constants.ParseApiHeaderKeys.RestApiKey)

        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                print(error)
                completionTaskForParseApiGETMethod(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
        
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionTaskForParseApiGETMethod)
        }
        
        task.resume()
        
    }
    
    func taskForParseApiPOSTMethod(jsonBody: String, completionTaskForParseApiPOSTMethod: @escaping(_ result: AnyObject?,_ error: String?) -> Void) {
        
        
        let url = "\(Constants.ParseApi.Scheme)://\(Constants.ParseApi.Host)\(Constants.ParseApi.Path)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = Constants.ParseApiMethods.Post
        request.addValue(Constants.ParseApiHeaderValues.AppId, forHTTPHeaderField: Constants.ParseApiHeaderKeys.ApplicationId)
        request.addValue(Constants.ParseApiHeaderValues.RestKey, forHTTPHeaderField: Constants.ParseApiHeaderKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                completionTaskForParseApiPOSTMethod(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print(error!)
                sendError("A Network error has occurred, please try again later")
                return
            }
        
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                sendError("A Network error has occurred, please try again later")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionTaskForParseApiPOSTMethod)
        }
        task.resume()
        
    }
    
    func taskForParseApiPUTMethod(objectId: String, jsonBody: String, completionTaskForParseApiPUTMethod: @escaping(_ result: AnyObject?, _ error: String?) -> Void) {
        
        let url = "\(Constants.ParseApi.Scheme)://\(Constants.ParseApi.Host)\(Constants.ParseApi.Path)/\(objectId)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = Constants.ParseApiMethods.Put
        request.addValue(Constants.ParseApiHeaderValues.AppId, forHTTPHeaderField: Constants.ParseApiHeaderKeys.ApplicationId)
        request.addValue(Constants.ParseApiHeaderValues.RestKey, forHTTPHeaderField: Constants.ParseApiHeaderKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                completionTaskForParseApiPUTMethod(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print(error!)
                sendError("A Network error has occurred, please try again later")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                sendError("A Network error has occurred, please try again later")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionTaskForParseApiPUTMethod)
        }
        task.resume()
        
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = "Could not parse the data as JSON: '\(data)'"
            completionHandlerForConvertData(nil, userInfo)
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

    private func getURLFromParameters(_ parameters: [String:AnyObject]?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ParseApi.Scheme
        components.host = Constants.ParseApi.Host
        components.path = Constants.ParseApi.Path
        components.queryItems = [URLQueryItem]()
        
        if let parameter = parameters{
            for (key,value) in parameter{
                let queryitem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryitem)
            }
        }
        return components.url!
    }
    
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var string: String = ""
            
            for(key, value) in parameters{
                let stringValue = "\(value)"
            
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                string = "\(escapedValue!)"
            }
            
            return string
        }
    }

    
    
    class func sharedInstance() -> NetworkConnections{
        struct Singleton{
            static var sharedInstance = NetworkConnections()
        }
        return Singleton.sharedInstance
    }
}
