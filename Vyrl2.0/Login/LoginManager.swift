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
    
    var needSignUpToken:String?
    var needSignUpSecret:String?
    var needSignUpService:ServiceType?
    
    func login(accessToken : String , accessTokenSecret :String, service : ServiceType, callBack : LoginViewController )
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
                
                if let code : HTTPCode = HTTPCode.init(rawValue: (response.response?.statusCode)!) {
                    switch code {
                    
                    case .SUCCESS :
                        callBack.goSearchView()
                    case .USERNOTEXIST :
                        callBack.goAgreement()
                        
                        self.needSignUpToken = accessToken
                        self.needSignUpSecret = accessTokenSecret
                        self.needSignUpService = service
                        
                        break
                    case .UNAUTORIZED :
                        break                        
                    }
                }
                
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func signout(completionHandler : @escaping (DataResponse<String>) -> Void)
    {
        let uri = baseURL + "accounts/signout"
        
        Alamofire.request(uri, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: completionHandler)
    }
    
    func signUp(homePageURL : String , nickName : String, selfIntro:String, completionHandler : @escaping (DataResponse<String>) -> Void)
    {
        let parameters : Parameters = [
            "accessToken": self.needSignUpToken!,
            "accessTokenSecret" : self.needSignUpSecret!,
            "socialType" : self.needSignUpService!.name(),
            "homePageUrl": homePageURL,
            "nickName": nickName,
            "selfIntro": selfIntro,
        ]
        
        let uri = baseURL + "accounts/signup"
        
        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler : completionHandler)
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

enum HTTPCode: Int{
    case SUCCESS     = 200
    case UNAUTORIZED = 401
    case USERNOTEXIST = 901
}
