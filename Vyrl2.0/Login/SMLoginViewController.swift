//
//   SMLoginViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class SMLoginViewController : UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var WebView: UIWebView!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var SMLoginLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        WebView.delegate = self;
        
        if let url = URL(string: "http://api.vyrl.com:8082/ko/auth/social/smtown/ios"){
            let request = URLRequest(url: url)
            WebView.loadRequest(request)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func dismiss(sender :AnyObject ) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        
    }
}
