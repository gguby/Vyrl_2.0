//
//  FeedPullLoader.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 8. 17..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import KRPullLoader

public protocol FeedPullLoaderDelegate: class {
    
    func pullLoadView(_ pullLoadView : FeedPullLoaderView, didChageState state: KRPullLoaderState, viewType type: KRPullLoaderType)
}


open class FeedPullLoaderView : UIView, KRPullLoadable {
    
    open weak var delegate :FeedPullLoaderDelegate?

    var refreshLoadingImageView = UIImageView.init(image: UIImage.init(named: "icon_loader_02_1"))
    
    var shouldSetConstraints = true
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if shouldSetConstraints {
            setUp()
        }
        shouldSetConstraints = false
    }
    
    open func setUp(){
        
        var imgList = [UIImage]()
        
        for count in 1...3 {
            let strImageName : String = "icon_loader_02_\(count)"
            let image = UIImage(named: strImageName)
            imgList.append(image!)
        }
        
        self.refreshLoadingImageView.animationImages = imgList
        self.refreshLoadingImageView.animationDuration = 1.0
        
//        self.refreshLoadingImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.refreshLoadingImageView)
        
        self.refreshLoadingImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.refreshLoadingImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.refreshLoadingImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.refreshLoadingImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    open func didChangeState(_ state: KRPullLoaderState, viewType type: KRPullLoaderType){
        switch state {
        case .none:
            self.refreshLoadingImageView.stopAnimating()
            
        case .pulling:
            break
            
        case .loading:
            self.refreshLoadingImageView.startAnimating()
            
        }
        
        delegate?.pullLoadView(self, didChageState: state, viewType: type)
    }
}
