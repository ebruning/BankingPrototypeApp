//
//  ServerManager.swift
//  KofaxBank
//
//  Created by Rupali on 08/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import Foundation

class ServerManager {
    
    // MARK: - Properties
    
    typealias ServerTaskSuccessFul = (Data?) -> Void
    typealias ServerTaskFailed = (Int) -> Void

    private let SERVER_URL_PROTOCOL_PREFIX = "http://"
    private let SERVER_URL_SUFFIX  = "/TotalAgility/Services/SDK"
    private let LOGINSERVICE  = "/UserService.svc/json/LogOnWithPassword2"
    
    private let LOGOUTSERVICE = "/UserService.svc/json/LogOff"
    private let CREATEJOBSERVICE = "/JobService.svc/json/CreateJob"
    private let EXTRACTIONJOBSERVICE = "/JobService.svc/json/CreateJobSyncWithDocuments"
    private let GETDOCUMENTSERVICE = "/CaptureDocumentService.svc/json/GetDocument"
    private let DELETEDOCUMENTSERVICE = "/CaptureDocumentService.svc/json/DeleteDocument"
    
    private let DEFAULT_SERVER_URL = "http://hyd-mob-kta73.asia.kofax.com/TotalAgility/Services/SDK";
//    private let DEFAULT_SERVER_URL = "http://t4cgm8rclt1mnw5.asia.kofax.com/TotalAgility/Services/SDK";
  
    private let DEFAULT_SERVER_IP = "hyd-mob-kta73.asia.kofax.com"
//    private let DEFAULT_SERVER_IP = "t4cgm8rclt1mnw5.asia.kofax.com"

    private let DEFAULT_USERID = "KMDUSER"
    private let DEFAULT_PASSWORD = "DemoPassword"

//    private let DEFAULT_USERID = "administrator"
//    private let DEFAULT_PASSWORD = "K00fax"
    
    private let DEFAULT_USER_DISPLAY_NAME = "Lucy"

    static let shared = ServerManager()
    
    var dataTask: URLSessionDataTask?
    
    // Initialization
    
    private init() {
        
    }
    

    func login(username: String, password: String, successHandler: @escaping LoginComplete, failureHandler: @escaping LoginFailed) throws {
        
        let request = try formLoginRequest(userNameData: username, passwordData: password)
        
        _ = makeConnection(request: request, successHandler: {data in
            successHandler(data)
        }, failureHandler: { statusCode in
            
            print(statusCode)
            failureHandler(statusCode)
        }
        
        )
}
    
  //  let LOGIN_REQUEST = "http://hyd-mob-kta73.asia.kofax.com/TotalAgility/Services/SDK/UserService.svc/json/LogOnWithPassword2"

    func formLoginRequest(userNameData: String, passwordData: String) throws -> NSMutableURLRequest? {
        var request: NSMutableURLRequest? = nil
        
        let params: [String: String] = [
            "UserId": userNameData,
            "Password": passwordData,
            "LogOnProtocol": "\(NSNumber(integerLiteral: 7))",
            "UnconditionalLogOn": "\(NSNumber(booleanLiteral: true))"
        ]
  
        let outerParam: [String: Any] = ["userIdentityWithPassword": params]
        
/*
        let params:Parameters = [
            "UserId": userNameData,
            "Password": passwordData,
            "LogOnProtocol": "\(NSNumber(integerLiteral: 7))",
            "UnconditionalLogOn": "\(NSNumber(booleanLiteral: true))"
            ] as [String : String]
        
        let outerParam: Parameters = [
            "userIdentityWithPassword": params
            ] as [String : Any]
        
*/
        //convert parameters dictionary to Data object
        let jsonData = try JSONSerialization.data(withJSONObject: outerParam, options: .prettyPrinted)
        
       // let LOGIN_REQUEST = "http://hyd-mob-kta73.asia.kofax.com/TotalAgility/Services/SDK/UserService.svc/json/LogOnWithPassword2"
        
        let url = URL(string: "\(SERVER_URL_PROTOCOL_PREFIX)\(DEFAULT_SERVER_IP)\(SERVER_URL_SUFFIX)\(LOGINSERVICE)")
        
        request = NSMutableURLRequest(url: url!)
        
        request?.httpMethod = "POST"
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("\(jsonData.count)", forHTTPHeaderField: "Content-Length")
        request?.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        request?.httpBody = jsonData
        
        print(request as Any)
        
        return request
        
    }
    
    func makeConnection(request: NSMutableURLRequest!, successHandler: @escaping ServerTaskSuccessFul, failureHandler: @escaping ServerTaskFailed) -> Bool {
        var result: Bool = false

        if (request == nil) {
            return result
        }
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        dataTask = session.dataTask(with: request as URLRequest)  {
            (data,response,error) in
            
            if (error != nil) {
                print(error.debugDescription)
                
                failureHandler(0)
                
                result = false
            }
            else {
                //print(error?.localizedDescription)
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    
                    let dataString = NSString(data: (data)!, encoding: String.Encoding.utf8.rawValue)
                    print(dataString!)
                    
/*                        do {
                            let resultDict = try JSONSerialization.jsonObject(with: data!, options: [])
                            
                        } catch {
                            print(error.localizedDescription)
                        }
*/
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        print("httpResponse status code ==> \(httpResponse)")
                        
                        if httpResponse.statusCode == 200 {
                            //self.updateSearchResults(data)
                            
                            print("Task successfully completed!!!")

                            let responseData = data

                            successHandler(responseData)
                            return
                        }
                        else {
                            print("Error code: \(httpResponse.statusCode)")
                            failureHandler(httpResponse.statusCode)
                            return
                        }
                    }
                }
                failureHandler(0)
            }
        }
        dataTask?.resume()
        
        return result
    }
}
