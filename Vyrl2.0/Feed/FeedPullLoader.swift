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
    
    lazy var refreshLoadingImageView : UIImageView = {
        
        let imageView = UIImageView.init(image: UIImage.init(named: "icon_loader_02_1"))
        
        var imgList = [UIImage]()
        
        for count in 1...3 {
            let strImageName : String = "icon_loader_02_\(count)"
            let image = UIImage(named: strImageName)
            imgList.append(image!)
        }
        
        imageView.animationImages = imgList
        imageView.animationDuration = 1.0
        
        return imageView
    }()
    
    var shouldSetConstraints = true
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if shouldSetConstraints {
            setUp()
        }
        shouldSetConstraints = false
    }
    
    open func setUp(){        
        self.refreshLoadingImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.refreshLoadingImageView)
        
        addConstraints([
            NSLayoutConstraint(item: refreshLoadingImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: refreshLoadingImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: refreshLoadingImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
        ])
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
