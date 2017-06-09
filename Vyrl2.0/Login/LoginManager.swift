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
    
    private let baseURL = "http://api.dev2nd.vyrl.com:8080/"
    private let APPVersion = "1.0.0"
    private let AppDevice = "ios"
    
    var cookie : String?
    
    var accountList :Array<Account> = []
    
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
            response in
            
            switch response.result {
                case .success(let json):
                    
                    self.saveCookies(response: response);
                    
                    let account = Account.init(properties: [
                        "email" : service.name(),
                        "accessToken" : accessToken,
                        "sessionToken" : self.cookie!
                    ])
                    
                    self.addAccount(account: account)
                    
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



extension LoginManager {
    
    func saveCookies(response: DataResponse<String>) {
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            self.cookie = cookie.value
            print("Save Cookie: \(cookie.value)")
            cookieArray.append(cookie.properties!)
        }
        UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
        UserDefaults.standard.synchronize()
    }
    
    func clearCookies(){
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "savedCookies" )
        UserDefaults.standard.synchronize()
    }
    
    func loadCookies() -> Bool {
        guard let cookieArray = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] else { return false }
        for cookieProperties in cookieArray {
            if let cookie = HTTPCookie(properties: cookieProperties) {
                
                self.cookie = cookie.value
                print("Load Cookie: \(cookie.value)")
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        
        return true
    }
    
    func getCookieHeader() -> [String :String]? {

        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                return HTTPCookie.requestHeaderFields(with: [cookie])
            }
        }
        
        return nil
    }

}

class Account {
    
    var email : String?
    var accessToken : String?
    var sessionToken : String?
    
    public init(properties : [String : Any]){
        self.email = properties["email"] as? String;
        self.accessToken = properties["accessToken"] as? String;
        self.sessionToken = properties["sessionToken"] as? String;
    }
    
    open var properties : [String : String] {
        get {
             return [
                "email" : self.email!,
                "accessToken" : self.accessToken!,
                "sessionToken" : self.sessionToken!
            ]
        }
    }
}

extension LoginManager {
    
    open func loadAccountList() {
        guard let accountArray = UserDefaults.standard.array(forKey: "accountList") as? [[String: Any]] else { return }
        
        for account in accountArray {
            let account : Account = Account.init(properties: account)
            self.accountList.append(account)
        }
    }
    
    func addAccount(account : Account){
        
        self.accountList.append(account)
        
        var accountArray = [[String: Any]]()
        for account in self.accountList
        {
            accountArray.append(account.properties)
        }
        
        UserDefaults.standard.set(accountArray, forKey: "accountList")
        UserDefaults.standard.synchronize()
    }
}


