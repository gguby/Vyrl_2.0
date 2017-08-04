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
        
        static func feedLike(articleId :Int)-> String{
            
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "feeds/likes/" + str
        }
        
        static func usersFeedLike(articleId :Int)-> String{
            
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "feeds/users/" + str + "/likes"
        }
        
        static func feed(articleId :Int)-> String{
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "feeds/" + str
        }
        
        static func feedComment(articleId:Int)-> String{
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "feeds/" + str + "/comments"
        }
    }
    
    struct VyrlFanAPIURL {
        static let FANPAGE = VyrlAPIConstants.baseURL + "fan-pages"
        static let FANPAGELIST = VyrlAPIConstants.baseURL + "fan-pages/my"
        static let SUGGESTFANPAGELIST = VyrlAPIConstants.baseURL + "fan-pages/suggests"
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
