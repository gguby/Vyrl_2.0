//
//  LoginData.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire

class LoginManager{
    
    static let sharedInstance = LoginManager()
    
    let baseURL = "http://api.dev2nd.vyrl.com:8080/"
    let APPVersion = "1.0.0"
    let AppDevice = "ios"
    
    private var _login:Bool = false
    
    var isLogin: Bool {
        
        get {
            return _login
        }
        set(login){
            _login = login
        }
    }
    
    private func getHeader() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "X-APP-Version": APPVersion,
            "X-Device": AppDevice,
            "Accept-Language" : "ko-kr"
        ]
        
        return headers
    }
    
    func login(accessToken : String , accessTokenSecret :String, service : ServiceType)
    {
        let parameters : Parameters = [
            "accessToken": accessToken,
            "accessTokenSecret" : accessTokenSecret,
            "socialType" : service.name()
        ]
        
        let uri = baseURL + "accounts/signin"
        
        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func signout()
    {
        let uri = baseURL + "accounts/signout"
        
        Alamofire.request(uri, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func signUp(accessToken : String , accessTokenSecret :String, service : ServiceType, homePageURL : String , nickName : String, selfIntro:String)
    {
        let parameters : Parameters = [
            "accessToken": accessToken,
            "accessTokenSecret" : accessTokenSecret,
            "socialType" : service.name(),
            "homePageUrl": homePageURL,
            "nickName": nickName,
            "selfIntro": selfIntro,
        ]
        
        let uri = baseURL + "accounts/signup"
        
        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func withDraw()
    {
        let uri = baseURL + "accounts/withdraw"
        
        Alamofire.request(uri, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    
}

enum ServiceType {
    case Google, Twitter, FaceBook , SM
    
    func name() -> String {
        switch self {
        case .Google:
            return "GOOGLE"
        case .Twitter:
            return "TWITTER"
        case .FaceBook:
            return "FACEBOOK"
        case .SM:
            return "SM"
        }
    }
}
