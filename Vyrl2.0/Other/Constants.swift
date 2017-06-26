//
//  Constants.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation


struct Constants {
    struct GoogleAnalysis {
        static let kTrackingId = "UA-69299126-3"
    }
    struct CrashlyticsConstants {
        static let userType = "User Type";
    }
    
    struct VyrlAPIConstants{
        static let baseURL = "http://api.dev2nd.vyrl.com:8080/"
        static let APPVersion = "1.0.0"
        static let AppDevice = "ios"
    }
    
    enum VyrlResponseCode : Int {
        case NickNameAleadyInUse = 909
    }
}
