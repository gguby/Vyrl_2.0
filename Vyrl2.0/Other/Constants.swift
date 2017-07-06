//
//  Constants.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire


struct Constants {
    struct GoogleAnalysis {
        static let kTrackingId = "UA-69299126-3"
    }
    struct CrashlyticsConstants {
        static let userType = "User Type";
    }
    
    struct VyrlAPIURL{
        static let baseURL = "http://api.dev2nd.vyrl.com:8080/"
        static let MYPROFILE = baseURL + "users/profile/me"
        static let notices = baseURL + "notices"
        static let faqs = baseURL + "faqs"
    }
    
    struct VyrlAPIConstants{
        static let baseURL = "http://api.dev2nd.vyrl.com:8080/"
        static let APPVersion = "1.0.0"
        static let AppDevice = "ios"        
        
        static func getHeader() -> HTTPHeaders {
            let headers: HTTPHeaders = [
                "X-APP-Version": Constants.VyrlAPIConstants.APPVersion,
                "X-Device": Constants.VyrlAPIConstants.AppDevice,
                "Accept-Language" : "ko-kr"
            ]
            
            return headers
        }
    }
    
    enum VyrlResponseCode : Int {
        case NickNameAleadyInUse = 909
    }
}
