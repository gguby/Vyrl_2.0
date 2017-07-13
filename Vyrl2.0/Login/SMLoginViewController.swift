//
//   SMLoginViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

protocol SMLoginDelegate {
    func signup()
}



class SMLoginViewController : UIViewController, UIWebViewDelegate {
    
    var clientId = "8ecafcf23f6d42cf94806ab807bd2023"
    
    var clientSecret = "2a045e5b07f1fc6c76895daeb8c9099881b9cb0588129c819f0ef71bf70c86d1"
    
    var loginDelegate : SMLoginDelegate? = nil
    
    @IBOutlet weak var WebView: UIWebView!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var SMLoginLabel: UILabel!
    
    @IBOutlet weak var navi : UINavigationController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        WebView.delegate = self;
        
        if let url = URL(string: "https://api.smtown.com/Account/SignIn"){
            let request = URLRequest(url: url)
//            request.addValue(clientId, forHTTPHeaderField: "Client_id")
//            request.addValue(clientSecret, forHTTPHeaderField: "Client_secret")
            WebView.loadRequest(request)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func dismiss(sender :AnyObject ) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isLogin :Bool = false
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        var command : String = (request.url?.absoluteString)!.decodeURL()
        
        print (command )
        
        let component = URLComponents(string: command)
        
        command = command.replacingOccurrences(of: "http://api.vyrl.com:8082/ko/auth/social/smtown/", with: "")
        
        if ( command.hasPrefix("ios?"))
        {
            var dict = [String:String]()
            if let queryItems = component?.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
            
            let alert = UIAlertController(title: "token", message: dict["code"], preferredStyle: UIAlertControllerStyle.alert)
            
            let defaultAction = UIAlertAction(title: "ok", style: .default, handler: nil )
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
            
            print(dict["code"]!)
            
            return false
        }
        
        if ( command.hasPrefix("vyrl_smtown:"))
        {
            // 토큰파싱 해야됨
            var components : Array = command.components(separatedBy: "success?profile=")
            
            let functionName = components[1]

            print( functionName.removingPercentEncoding! )
            
            let jsonString = functionName.replacingOccurrences(of: "&#", with: "\\U")
            
            let jsonData = jsonString.data(using: String.Encoding.utf8)
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
                print(json)
                
                self.navigationController?.popViewController(animated: true)
                
                self.loginDelegate?.signup()
                
                LoginManager.sharedInstance.isLogin = true

                return false;
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
       
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        
    }
}

extension String {
    func encodeURL() -> String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    
    func decodeURL() -> String
    {
        return self.removingPercentEncoding!
    }
}
