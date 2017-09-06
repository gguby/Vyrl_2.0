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
    static var GoogleADKey = "ca-app-pub-5207930350156417/4448363513"
    static var GoogleADTest = "ca-app-pub-3940256099942544/3986624511"
    
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
        
        static func userProfile(userId :Int)-> String{
            let str = "\(userId)"
            return VyrlAPIConstants.baseURL + "users/profile/" + str
        }
    }
    
    struct VyrlSearchURL {
        static func search(searchWord : String) -> String{
            let str = searchWord.addingPercentEncoding(withAllowedCharacters:  NSCharacterSet.urlQueryAllowed)
            return VyrlAPIConstants.baseURL + "search/" + str!
        }
    }
    
    struct VyrlFeedURL {
        static let FEED = VyrlAPIConstants.baseURL + "feeds"
        static let FEEDALL = VyrlAPIConstants.baseURL + "feeds/all"
        
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
        
        static func feed(userId :Int)-> String{
            let str = "\(userId)"
            return VyrlAPIConstants.baseURL + "feeds/others/" + str
        }
        
        static func feedComment(articleId:Int)-> String{
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "feeds/" + str + "/comments"
        }
        
        static func feedCommentDelete(articleId:Int, commentId:Int)-> String{
            let str = "\(articleId)"
            let commentId = "\(commentId)"
            return VyrlAPIConstants.baseURL + "feeds/" + str + "/comments/" + commentId
        }
        
        static let FEEDBOOKMARK = VyrlAPIConstants.baseURL + "feeds/bookmarks"
        static let FEEDREPORT = VyrlAPIConstants.baseURL + "feeds/reports"
        
        static func follow(followId :Int)-> String{
            let str = "\(followId)"
            return VyrlAPIConstants.baseURL + "follows/" + str
        }
        
        static func share(articleId :Int)-> String{
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "share/" + str
        }
    }
    
    struct VyrlFanAPIURL {
        static let FANPAGE = VyrlAPIConstants.baseURL + "fan-pages"
        static let FANPAGELIST = VyrlAPIConstants.baseURL + "fan-pages/my"
        static let FANPAGEPOST = VyrlAPIConstants.baseURL + "fan-pages/posts"
        static let SUGGESTFANPAGELIST = VyrlAPIConstants.baseURL + "fan-pages/suggests"
        static let HOTPOST = VyrlAPIConstants.baseURL + "fan-pages/hot-fanpage-posts"
        static func checkFanPageName(fanPageName:String)-> String{
            return VyrlAPIConstants.baseURL + "fan-pages/check-names/" + fanPageName
        }
        
        static func fanPage(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/" + str
        }
        
        static func reportFanPage() -> String {
            return VyrlAPIConstants.baseURL + "fan-pages/reports"
        }
        
        static func getFanPagePosts(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/" + str + "/posts"
        }
        
        static func search(searchWord : String) -> String{
            return VyrlAPIConstants.baseURL + "/fan-pages/searchs/" + searchWord
        }
        
        static func withdrawFanPage(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/members/withdraw/" + str 
        }
        
        static func joinFanPage(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/members/join/" + str
        }
        
        static func joinUserList(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/" + str + "/members"
        }

        static let FANPAGEALLFEED = VyrlAPIConstants.baseURL + "fan-pages/feeds"
        static let AuthChange = VyrlAPIConstants.baseURL + "fan-pages/auth-changes"
        
        static func WithDrawAll(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/members/request-withdraws/" + str
        }
        
        static func fanPageClose(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/close-requests/" + str
        }
        
        static func fanPagePush(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/alarms/" + str
        }
    }
    
    static func getHeader() -> HTTPHeaders {
        return VyrlAPIConstants.getHeader()
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


extension String {
    func localized(comment :String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
}
