//
//  LoginData.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class LoginData{
    
    static let sharedInstance = LoginData()
    
    private var _login:Bool = false
    
    var isLogin: Bool {
        
        get {
            return _login
        }
        set(login){
            _login = login
        }
    }
    
}
