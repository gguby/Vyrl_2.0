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
        static let FOLLOWER = VyrlAPIConstants.baseURL + "follows/follower"
        static let FOLLOWING = VyrlAPIConstants.baseURL + "follows/following"
        static let BLOCKUSER = VyrlAPIConstants.baseURL + "users/block"
        static let ACTIVITY = VyrlAPIConstants.baseURL + "users/activity"
        
        static let changeProfile = VyrlAPIConstants.baseURL + "users/profile"
        static let notices = VyrlAPIConstants.baseURL + "notices"
        static let faqs = VyrlAPIConstants.baseURL + "faqs"
        
        static let alert = VyrlAPIConstants.baseURL + "alerts/"
        
        static func userProfile(userId :Int)-> String{
            let str = "\(userId)"
            return VyrlAPIConstants.baseURL + "users/profile/" + str
        }
        
        static func otherUserFollower(userId : String)-> String{
            let str = "/\(userId)"
            return FOLLOWER + str
        }
        
        static func otherUserFollowing(userId : String)-> String{
            let str = "/\(userId)"
            return FOLLOWING + str
        }
    }
    
    struct VyrlSearchURL {
        static func search(searchWord : String) -> String{
            let str = searchWord.addingPercentEncoding(withAllowedCharacters:  NSCharacterSet.urlQueryAllowed)
            return VyrlAPIConstants.baseURL + "search/" + str!
        }
        
        static func searchHashTag(searchWord : String) -> String {
            let str = searchWord.addingPercentEncoding(withAllowedCharacters:  NSCharacterSet.urlQueryAllowed)
            return VyrlAPIConstants.baseURL + "search/hashtags/" + str! + "/medias"
        }
        
        static let officialAccounts = VyrlAPIConstants.baseURL + "search/official/accounts"
        static let suggestPostList = VyrlAPIConstants.baseURL + "search/suggest/posts"
        static let suggestUsers = VyrlAPIConstants.baseURL + "search/suggest/users"
    }
    
    struct VyrlFeedURL {
        static let FEED = VyrlAPIConstants.baseURL + "feeds"
        static let FEEDMEDIA = VyrlAPIConstants.baseURL + "feeds/medias"
        static let FEEDALL = VyrlAPIConstants.baseURL + "feeds/all"
        static let COMMENTS = VyrlAPIConstants.baseURL + "feeds/comments"
        
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
        
        static func feedOtherMedias(userId :Int)-> String{
            let str = "\(userId)"
            return VyrlAPIConstants.baseURL + "feeds/others/" + str + "/medias"
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
        
        static func feedHide(articleId :Int)-> String{
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "feeds/hide/" + str
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
        
        static func translate(id:Int, type:translateType)-> String {
            let str = "\(id)/"
            return VyrlAPIConstants.baseURL + "translate/" + str + type.rawValue
        }
        
        static func hideComment(id:Int)-> String {
            let str = "\(id)"
            return VyrlAPIConstants.baseURL + "feeds/comments/hides/" + str
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
            return VyrlAPIConstants.baseURL + "feeds/" + str + "/posts"
        }
        
        static func getFanPagePostMedias(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "feeds/" + str + "/posts/medias"
        }
        
        static func search(searchWord : String) -> String{
            let str = searchWord.addingPercentEncoding(withAllowedCharacters:  NSCharacterSet.urlQueryAllowed)
            return VyrlAPIConstants.baseURL + "/fan-pages/searchs/" + str!
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

        static let FANPAGEALLFEED = VyrlAPIConstants.baseURL + "feeds/fan-pages"
        static let AuthChange = VyrlAPIConstants.baseURL + "fan-pages/auth-changes"
        
        static func WithDrawAll(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/request-withdraws/" + str
        }
        
        static func fanPageClose(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/close-requests/" + str
        }
        
        static func fanPagePush(fanPageId : Int)-> String{
            let str = "\(fanPageId)"
            return VyrlAPIConstants.baseURL + "fan-pages/alarms/" + str
        }
        
        static func fanPagePost(articleId : Int)-> String{
            let str = "\(articleId)"
            return VyrlAPIConstants.baseURL + "fan-pages/posts/" + str
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
    
    enum translateType : String {
        case article = "ARTICLE"
        case comment = "COMMENT"
        case fanpage = "FANPAGE"
        case official = "OFFICIAL"
        case channel = "CHANNEL"
    }
}


extension String {
    func localized(comment :String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
}

protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
