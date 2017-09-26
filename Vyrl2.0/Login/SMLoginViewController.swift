//
//   SMLoginViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

protocol SMLoginDelegate {
    func login(token:String)
}

class SMLoginViewController : UIViewController, UIWebViewDelegate {
    
    var clientId = "8ecafcf23f6d42cf94806ab807bd2023"
    
    private let authUri = "https://api.smtown.com/OAuth/Authorize?client_id=8ecafcf23f6d42cf94806ab807bd2023&redirect_uri=http://api.dev2nd.vyrl.com/&state=nonce&scope=profile&response_type=token"
    
    var loginDelegate : SMLoginDelegate? = nil
    
    @IBOutlet weak var WebView: UIWebView!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var SMLoginLabel: UILabel!
    
    @IBOutlet weak var navi : UINavigationController!
    
    var token : String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        WebView.delegate = self;
        
        let request = URLRequest.init(url: URL.init(string: authUri)!)
        
        WebView.loadRequest(request)
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
        
        if navigationType != UIWebViewNavigationType.formSubmitted {
            return true
        }
        
        var command : String = (request.url?.absoluteString)!.decodeURL()
        
        command = command.replacingOccurrences(of: "#", with: "?")
        
        let url = URL.init(string: command)
        
        if ( url?.query!.hasPrefix("access_token"))!
        {
            let token = url?.queryParameters!["access_token"]
            loginDelegate?.login(token: token!)
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

extension URL {
    
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
}
