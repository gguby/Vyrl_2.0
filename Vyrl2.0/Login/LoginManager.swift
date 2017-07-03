//
//  LoginData.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire
import GoogleSignIn

class LoginManager{
    
    static let sharedInstance = LoginManager()
    
    let baseURL = Constants.VyrlAPIConstants.baseURL
    
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
        return Constants.VyrlAPIConstants.getHeader()
    }
    
    var needSignUpToken:String?
    var needSignUpSecret:String?
    var needSignUpService:ServiceType?
    
    var deviceToken:String?
    
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
                            
                            var cookie : String?
                            
                            if ( callBack.isAddAccount == false ){
                                cookie = self.saveCookies(response: response)
                                self.cookie = cookie
                            }else {
                                cookie = self.addCookie(response: response)
                                self.loadCookies()
                            }
                            
                            let jsonData = json as! NSDictionary
                            
                            let idNum = jsonData["id"] as! NSNumber
                            let idStr = idNum.stringValue
                            
                            let account = Account.init(properties: [
                                "userId" : idStr,
                                "email" : jsonData["email"] as! String,
                                "accessToken" : accessToken,
                                "sessionToken" : cookie!,
                                "nickName" : jsonData["nickName"] as! String,
                                "service" : service.name()
                            ])
                            
                            self.addAccount(account: account)
                            
                            callBack.loginSuccess()
                            
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
    
    func logoutAll(){
        let uri = baseURL + "accounts/signout"
        
        Alamofire.request(uri, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: {
            response in

            switch response.result {
            case .success(let json):

                print("logout: \( json)")
                GIDSignIn.sharedInstance().signOut()
                
                self.clearCookies()
                self.clearAccountAll()
                self.goLoginView()
                
            case .failure(let error):
                print(error)
            }
        })

    }
    
    func signout(completionHandler : @escaping () -> Void)
    {
        let uri = baseURL + "accounts/signout"
        
        Alamofire.request(uri, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: getHeader()).responseString(completionHandler: {
            response in
            
            self.clearCookies()
            
            switch response.result {
            case .success(let json):
                
                let account = self.getCurrentAccount()
                
                if ( account?.service == "GOOGLE"){
                    GIDSignIn.sharedInstance().signIn()
                }
                
                completionHandler()
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func signUp(homePageURL : String , nickName : String, selfIntro:String, profile: UIImage, completionHandler : @escaping () -> Void)
    {
        guard let token = self.deviceToken else {
            return
        }
        
        let parameters : Parameters = [
            "accessToken": self.needSignUpToken!,
            "accessTokenSecret" : self.needSignUpSecret!,
            "socialType" : self.needSignUpService!.name(),
            "homePageUrl": homePageURL,
            "nickName": nickName,
            "selfIntro": selfIntro,
            "type" : Constants.VyrlAPIConstants.AppDevice.uppercased(),
            "pushToken" : token
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
                    
                    if ( (response.response?.statusCode) != 200 ) { return }
                    
                    switch response.result {
                    case .success(let json):
                        
                            self.cookie = self.saveCookies(response: response);
                            
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
    
    func checkNickname(nickname: String, completionHandler : @escaping(DataResponse<String>) -> Void) {
        let uri = baseURL + "accounts/nickname"
        let parameters : Parameters = [
            "nickName": nickname,
            ]
        
        Alamofire.request(uri, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: getHeader()).responseString(completionHandler: completionHandler)
    }
}

enum ServiceType : String {
    case Google = "GOOGLE", Twitter = "TWITTER" , FaceBook = "FACEBOOK" , SM = "SMTOWN"
    
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
    
    func goLoginView() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.goLogin()
    }
}


extension LoginManager {
    
    func changeCookie(account : Account){
        
        let properties = account.cookieProperties
        if let cookie = HTTPCookie(properties: properties as! [HTTPCookiePropertyKey : Any]) {            
            self.cookie = cookie.value
            print("Change Cookie: \(cookie.value)")
            HTTPCookieStorage.shared.setCookie(cookie)
            
            var cookieArray = [[HTTPCookiePropertyKey: Any]]()

            cookieArray.append(properties as! [HTTPCookiePropertyKey : Any])
            
            UserDefaults.standard.set(cookieArray, forKey: "currentCookie")
            UserDefaults.standard.synchronize()
        }
    }
    
    func addCookie(response :DataResponse<Any>) -> String?{
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        
        var cookiesString : String? = nil
        
        if ( cookies.count == 0 ) {
            return cookiesString
        }
        
        for cookie in cookies {
            cookiesString = cookie.value
            print("Add Cookie: \(cookie.value)")
            
            UserDefaults.standard.set(cookie.properties!, forKey: cookiesString! )
        }
        
        return cookiesString
    }
    
    func saveCookies(response: DataResponse<Any>) -> String? {
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        
        let cookiesString : String? = self.addCookie(response: response)
        
        let cookieProperty  = UserDefaults.standard.object(forKey: cookiesString!)
        
        cookieArray.append(cookieProperty as! [HTTPCookiePropertyKey : Any])
        
        UserDefaults.standard.set(cookieArray, forKey: "currentCookie")
        UserDefaults.standard.synchronize()
        
        return cookiesString
    }
    
    func clearCookies(){
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "currentCookie" )
        UserDefaults.standard.synchronize()
    }
    
    func isExistCookie() -> Bool {
        if (self.cookie == nil )
        {
            return false
        }
        
        return true
    }
    
    func loadCookies() {
        guard let cookieArray = UserDefaults.standard.array(forKey: "currentCookie") as? [[HTTPCookiePropertyKey: Any]] else { return  }
        for cookieProperties in cookieArray {
            if let cookie = HTTPCookie(properties: cookieProperties) {
                
                self.cookie = cookie.value
                print("Load Cookie: \(cookie.value)")
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
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
    
    var imagePath : String?
    
    public init(properties : [String : Any]){
        self.email = properties["email"] as? String;
        self.accessToken = properties["accessToken"] as? String;
        self.sessionToken = properties["sessionToken"] as? String;
        self.service = properties["service"] as? String;
        self.userId = properties["userId"] as? String;
        self.nickName = properties["nickName"] as? String;
    }
    
    func removeProfile(){
        UserDefaults.standard.removeObject(forKey: self.userId!)
    }
    
    open var cookieProperties : Any? {
        get {
            return UserDefaults.standard.object(forKey: self.sessionToken!)
        }
    }
    
    open var properties : [String : String] {
        get {
            var imagePath = ""
            
            if self.imagePath != nil {
                imagePath = self.imagePath!
            }else {
                imagePath = ""
            }
            
             return [
                "email" : self.email!,
                "accessToken" : self.accessToken!,
                "sessionToken" : self.sessionToken!,
                "service" : self.service!,
                "userId" : self.userId!,
                "nickName" :self.nickName!,
                "imagePath" : imagePath
            ]
        }
    }
    
    open var logoImage : UIImage {
        get {
            let serviceType : ServiceType = ServiceType.init(rawValue: self.service!)!
            
            switch serviceType {
            case .Google:
                return  UIImage.init(named: "logo_gg_02")!
            case .FaceBook:
                return  UIImage.init(named: "logo_fb_02_on")!
            case .Twitter:
                return  UIImage.init(named: "logo_tw_02_on")!
            case .SM :
                return  UIImage.init(named: "logo_sm_02_on")!
            }
        }
    }
}

extension UserDefaults {
    func set(image: UIImage?, forKey key: String) {
        guard let image = image else {
            set(nil, forKey: key)
            return
        }
        set(UIImageJPEGRepresentation(image, 1.0), forKey: key)
    }
    func image(forKey key:String) -> UIImage? {
        guard let data = data(forKey: key), let image = UIImage(data: data )
            else  { return nil }
        return image
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
    
    func saveProfileImage(image:UIImage ,userId : String )
    {
        let imgData = UIImageJPEGRepresentation(image, 1)
        UserDefaults.standard.set(imgData, forKey: userId)
    }
    
    func loadProfile(userId:String){
       
    }
    
    func syncAccount(){
        var accountArray = [[String: Any]]()
        for account in self.accountList
        {
            print("Sync Account :-----------------------------------------------------")
            print("Sync Account NickName:" + account.nickName!)
            print("Sync Account UserId:" + account.userId!)
            print("Sync Account Session Token :" + account.sessionToken!)
            print("Sync Account :-----------------------------------------------------")
            accountArray.append(account.properties)
        }
        
        UserDefaults.standard.set(accountArray, forKey: "accountList")
        UserDefaults.standard.synchronize()
    }
    
    func replaceAccount(account : Account){
        
        let index = self.accountList.index(where :{ $0.userId == account.userId })
        if let index = index {
            self.accountList[index] = account
            self.syncAccount()
        }
    }
    
    func addAccount(account : Account){
        
        let index = self.accountList.index(where :{ $0.userId == account.userId })
        if let index = index {
            self.accountList[index] = account
        }else {
            self.accountList.append(account)
        }
        
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
        
        for account in self.accountList {
            UserDefaults.standard.removeObject(forKey: account.userId!)
            UserDefaults.standard.removeObject(forKey: account.sessionToken!)
        }
        
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
    
    func includeNotCurrentUser() -> Array<Account> {
        let accountList = LoginManager.sharedInstance.accountList.filter({
            (account) -> Bool in
            self.getCurrentAccount()?.userId != account.userId
        })
        
        return accountList
    }
}


