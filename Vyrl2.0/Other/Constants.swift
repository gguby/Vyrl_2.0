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
    
    static var GoogleMapsAPIServerKey="AIzaSyAv8onWg1agUiUQU_n5HFMaMjnGtlrinSQ"
    
    struct GoogleAnalysis {
        static let kTrackingId = "UA-102838629-1"
    }
    struct CrashlyticsConstants {
        static let userType = "User Type";
    }
    
    struct VyrlAPIURL{
        static let MYPROFILE = VyrlAPIConstants.baseURL + "users/profile/me"
        static let changeProfile = VyrlAPIConstants.baseURL + "users/profile"
        static let notices = VyrlAPIConstants.baseURL + "notices"
        static let faqs = VyrlAPIConstants.baseURL + "faqs"
    }
    
    struct VyrlFeedURL {
        static let FEED = VyrlAPIConstants.baseURL + "feeds"
        
        static func deleteFeedLike(articleId :String)-> String{
            return VyrlAPIConstants.baseURL + "feeds/likes/" + articleId
        }
        
        static func usersFeedLike(articleId :String)-> String{
            return VyrlAPIConstants.baseURL + "feeds/users/" + articleId + "/likes"
        }
        
        static func feed(articleId :String)-> String{
            return VyrlAPIConstants.baseURL + "feeds/" + articleId
        }
        
        static func feedComment(articleId:String)-> String{
            return VyrlAPIConstants.baseURL + "feeds/" + articleId + "/comments"
        }
    }
    
    struct VyrlAPIConstants{
        static let baseURL = "http://api.dev2nd.vyrl.com:8080/"
        static let APPVersion = "1.0.0"
        static let AppDevice = "ios"        
        
        static func getHeader() -> HTTPHeaders {
            let headers: HTTPHeaders = [
                "X-APP-Version": Constants.VyrlAPIConstants.APPVersion,
                "X-Device": Constants.VyrlAPIConstants.AppDevice,
                "Accept-Language" : "ko-kr",
            ]
            
            return headers
        }
    }
    
    enum VyrlResponseCode : Int {
        case NickNameAleadyInUse = 909
    }
}
