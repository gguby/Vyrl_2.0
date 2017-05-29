//
//   SMLoginViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

protocol SMLoginDelegate {
    func loginCallback()
}

class SMLoginViewController : UIViewController, UIWebViewDelegate {
    
    var loginDelegate : SMLoginDelegate? = nil
    
    @IBOutlet weak var WebView: UIWebView!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var SMLoginLabel: UILabel!
    
    @IBOutlet weak var navi : UINavigationController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        WebView.delegate = self;
        
        if let url = URL(string: "http://api.vyrl.com:8082/ko/auth/social/smtown/ios"){
            let request = URLRequest(url: url)
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
        (UIApplication.shared.delegate as!AppDelegate).popController()
    }
    
    var isLogin :Bool = false
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        var command : String = (request.url?.absoluteString)!.decodeURL()
        
        print (command )
        
        command = command.replacingOccurrences(of: "http://api.vyrl.com:8082/ko/auth/social/smtown/", with: "")
        
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
                
                (UIApplication.shared.delegate as!AppDelegate).popController()
                
                self.loginDelegate?.loginCallback()
                
                LoginData.sharedInstance.isLogin = true                

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
