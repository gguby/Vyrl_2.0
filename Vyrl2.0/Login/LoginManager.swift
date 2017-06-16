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
    
    func getHeader() -> HTTPHeaders {
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
        print(accessToken)
        
        let parameters : Parameters = [
            "accessToken": accessToken,
            "accessTokenSecret" : accessTokenSecret,
            "socialType" : service.name()
        ]
        
        let uri = baseURL + "accounts/signin"

        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
                case .success(let json):
                    
                    if let code : HTTPCode = HTTPCode.init(rawValue: (response.response?.statusCode)!) {
                        switch code {
                    
                        case .SUCCESS :
                            
                            self.saveCookies(response: response);
                            
                            let jsonData = json as! NSDictionary
                            
                            let idNum = jsonData["id"] as! NSNumber
                            let idStr = idNum.stringValue
                            
                            let account = Account.init(properties: [
                                "userId" : idStr,
                                "email" : jsonData["email"] as! String,
                                "accessToken" : accessToken,
                                "sessionToken" : self.cookie!,
                                "nickName" : jsonData["nickName"] as! String,
                                "service" : service.name()
                            ])
                            
                            self.addAccount(account: account)
                            
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
    
    func signUp(homePageURL : String , nickName : String, selfIntro:String, profile: UIImage, completionHandler : @escaping () -> Void)
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
        let fileName = "\(nickName).jpg"

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let imageData = UIImageJPEGRepresentation(profile, 0.25) {
                multipartFormData.append(imageData, withName: "file", fileName: fileName, mimeType: "image/jpeg")
            }
            
            for (key, value) in parameters {
                let vauleStr = value as! String
                multipartFormData.append(vauleStr.data(using: .utf8)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: uri, method: .post, headers: getHeader(), encodingCompletion: {
            encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                
                upload.responseJSON { response in
                    //print response.result
                    print(response.result)
                    print((response.response?.statusCode)!)
                    print(response)
                    
                    switch response.result {
                    case .success(let json):
                            self.saveCookies(response: response);
                            
                            let jsonData = json as! NSDictionary
                            
                            let idNum = jsonData["id"] as! NSNumber
                            let idStr = idNum.stringValue
                            
                            let account = Account.init(properties: [
                                "userId" : idStr,
                                "email" : jsonData["email"] as! String,
                                "accessToken" : self.needSignUpToken!,
                                "sessionToken" : self.cookie!,
                                "nickName" : jsonData["nickName"] as! String,
                                "service" : jsonData["socialType"] as! String
                                ])
                            
                            self.addAccount(account: account)
                        
                            completionHandler()
                    case .failure(let error):
                        print(error)
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError.localizedDescription)
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
    
    func editNickname(nickname: String, completionHandler : @escaping(DataResponse<String>) -> Void) {
        let uri = baseURL + "accounts/nickname"
        let parameters : Parameters = [
            "nickName": nickname,
            ]
        
        Alamofire.request(uri, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: getHeader()).responseString(completionHandler: completionHandler)
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
            return "SMTOWN"
        }
    }
}

enum HTTPCode: Int{
    case SUCCESS     = 200
    case UNAUTORIZED = 401
    case USERNOTEXIST = 901
}

extension LoginManager {
    
    func checkPush(viewConroller : UIViewController){
        
        let isCheckPush : Bool = UserDefaults.standard.bool(forKey: "pushNotification")
        
        if ( isCheckPush == false ){
            
            let msg = "이벤트 및 프로모션 알림을 받으시겠습니까?"
            
            let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "동의", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
            
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
                
                UserDefaults.standard.set(true, forKey: "pushNotification")
            }))
            
            alert.addAction(UIAlertAction(title: "동의 안함", style: UIAlertActionStyle.cancel, handler: nil))
            viewConroller.present(alert, animated: true, completion: nil)
        }
    }
}



extension LoginManager {
    
    func saveCookies(response: DataResponse<Any>) {
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        
        if ( cookies.count == 0 ) {
            return
        }
        
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
    var service : String?
    var userId : String?
    var nickName :String?
    
    public init(properties : [String : Any]){
        self.email = properties["email"] as? String;
        self.accessToken = properties["accessToken"] as? String;
        self.sessionToken = properties["sessionToken"] as? String;
        self.service = properties["service"] as? String;
        self.userId = properties["userId"] as? String;
        self.nickName = properties["nickName"] as? String;
    }
    
    open var properties : [String : String] {
        get {
             return [
                "email" : self.email!,
                "accessToken" : self.accessToken!,
                "sessionToken" : self.sessionToken!,
                "service" : self.service!,
                "userId" : self.userId!,
                "nickName" :self.nickName!
            ]
        }
    }
}

extension LoginManager {
    
    open func loadAccountList() {
        guard let accountArray = UserDefaults.standard.array(forKey: "accountList") as? [[String: Any]] else { return }
        
        print(accountArray)
        
        self.accountList.removeAll()
        
        for account in accountArray {
            let account : Account = Account.init(properties: account)
            self.accountList.append(account)
        }
    }
    
    func syncAccount(){
        var accountArray = [[String: Any]]()
        for account in self.accountList
        {
            accountArray.append(account.properties)
        }
        
        UserDefaults.standard.set(accountArray, forKey: "accountList")
        UserDefaults.standard.synchronize()
    }
    
    func addAccount(account : Account){
        
        self.accountList.append(account)
        
        self.syncAccount()
    }
    
    func getCurrentAccount() -> Account?{
        for account in self.accountList {
            if ( self.cookie == account.sessionToken ){
                return account
            }
        }
        return nil
    }
    
    func clearAccountAll(){
        self.accountList.removeAll()
        UserDefaults.standard.removeObject(forKey: "accountList")
        UserDefaults.standard.synchronize()
    }
    
    func removeAccount(userId : String )
    {
        print(self.accountList)
        
        let filteredArray = self.accountList.filter{
            (account) -> Bool in
            userId == account.userId
        }
        
        self.accountList = filteredArray
        
        print(self.accountList)
        
        self.syncAccount()
    }
}


