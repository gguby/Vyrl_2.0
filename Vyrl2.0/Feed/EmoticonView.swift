//
//  EmoticonView.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 26..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class EmoticonView: UIView {
    var emoticonCount = [Int]()
    var emoticonButtonArray = [UIButton]()
    
    var scrollView : UIScrollView!
    var selectorView : UIScrollView!
    
    var pageControl : UIPageControl!
    var itemRect : CGRect = CGRect.zero
    var emoticonSet : ObjCBool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if(scrollView == nil){
            let userDefault = UserDefaults.standard
            var recentEmoticon = userDefault.object(forKey: "@recentEmoticon") as? String
            var emoticonArray = recentEmoticon?.components(separatedBy: "|")
            
            emoticonCount.append(2)
            emoticonCount.append(10)
            emoticonCount.append(20)
            emoticonCount.append(10)
            emoticonCount.append(20)
            emoticonCount.append(10)
            emoticonCount.append(20)

//        emoticonCount[3]=8;
//        emoticonCount[4]=8;
//        emoticonCount[5]=8;
//        emoticonCount[6]=82;
//        emoticonCount[7]=16;
//        emoticonCount[8]=8;
//        emoticonCount[9]=8;
//        emoticonCount[10]=8;
//        emoticonCount[11]=14;
//        emoticonCount[12]=16;
//        emoticonCount[13]=16;

            emoticonButtonArray.removeAll()
            
            var scrollRect : CGRect = rect
            scrollRect.size.height = rect.size.height - 40.0
            
            scrollRect.origin.y = 0.0
            var selectorRect : CGRect = scrollRect
            selectorRect.size.height = 40.0;
            selectorRect.origin.y = rect.size.height - 40.0
            
            scrollView = UIScrollView.init(frame: scrollRect)
            self.addSubview(scrollView)
            scrollView.delegate = self as UIScrollViewDelegate
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            
            pageControl = UIPageControl.init(frame: CGRect.init(x: self.frame.size.width/2 - 50, y: 0, width: 100, height: 37))
            pageControl.center = CGPoint.init(x: self.frame.width/2, y: 10)
            pageControl.currentPageIndicatorTintColor = UIColor.black
            pageControl.pageIndicatorTintColor = UIColor.ivGreyish
            
            self.addSubview(pageControl)
        
            if(selectorView == nil) {
                selectorView = UIScrollView.init(frame: selectorRect)
                selectorView.isPagingEnabled = true
                selectorView.showsHorizontalScrollIndicator = false
                selectorView.showsVerticalScrollIndicator = false
                
                self.addSubview(selectorView)
               
                itemRect = CGRect(x: CGFloat(0), y: CGFloat(10), width: CGFloat(scrollRect.size.width / 4), height: CGFloat((scrollRect.size.height - 20) / 2))
                
                var selectorButtonRect : CGRect = CGRect.init(x: 0, y: 0, width: scrollRect.size.width/6, height: selectorRect.size.height)
                
                
                
                for i in 0..<(emoticonCount.count) {
                    let btn : UIButton = UIButton.init(frame: selectorButtonRect)
                    btn.backgroundColor = UIColor.brown
                    btn.addTarget(self, action: #selector(emoticonChangeGroup(sender:)), for: UIControlEvents.touchUpInside)
                    
                    btn.tag = i
                    self.selectorView.addSubview(btn)
                    
                    selectorButtonRect.origin.x += selectorButtonRect.size.width
                }
            }
        }
    }
    
    func emoticonChangeGroup(sender : UIButton) {
        emoticonSet = false
        for case let inBtn as UIButton in selectorView.subviews {
            inBtn.backgroundColor = UIColor.clear
        }
        
        let gButton: UIButton? = sender
        gButton?.backgroundColor = UIColor(white: CGFloat(0.900), alpha: CGFloat(1.000))
        
        for case let inBtn in emoticonButtonArray {
            inBtn.removeFromSuperview()
        }
        emoticonButtonArray.removeAll()
        
        scrollView.contentOffset = CGPoint(x: CGFloat(0), y: CGFloat(0))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        var itemSelector = sender
       
        var btnRect: CGRect = itemRect
        
        var userDefaults = UserDefaults.standard
        var recentEmoticon: String = "\(userDefaults.object(forKey: "recentEmoticon"))"
        print("recent : \(recentEmoticon)")
        
        var recentEmoticonArray: [Any] = recentEmoticon.components(separatedBy: "|")
        var count = emoticonCount[itemSelector.tag]
        if count <= 8 {
            pageControl.isHidden = true
        }
        else {
            pageControl.isHidden = false
        }
        if (itemSelector.tag == 0)
        {
            count = recentEmoticonArray.count
        }
        var emCnt: Int = 0
        var pgCnt: Int = 0
        var lineCnt: Int = 0
        
        for i in 1...count {
            var btn: UIButton?
            btn?.contentHorizontalAlignment = .center
            btn = UIButton(frame: CGRect(x: CGFloat(btnRect.origin.x), y: CGFloat(btnRect.origin.y), width: CGFloat(btnRect.size.width), height: CGFloat(btnRect.size.height)))
            btn?.imageView?.contentMode = .scaleAspectFit
            btn?.setImage(UIImage(named: "icon_home_01_on.png"), for: .normal)
            
            if(emCnt == 3) { // 2번째 줄
                btnRect.origin.y += btnRect.size.height
                emCnt = 0
                if (lineCnt != 0) {
                    lineCnt = 0
                    pgCnt += 1 // 다음 페이지
                    btnRect.origin.y = 10
                }
                else {
                    lineCnt += 1
                }
                btnRect.origin.x = 0 + (CGFloat(pgCnt) * (btnRect.size.width * 4))
            }
            else {
                btnRect.origin.x += btnRect.size.width
                emCnt += 1
            }
            //emoticonCount
            scrollView.addSubview(btn!)
            emoticonButtonArray.append(btn!)
        }
        
        let wsize = (Int((emoticonCount[itemSelector.tag] - 1) / 8)) + 1
        scrollView.contentSize = CGSize(width: CGFloat(scrollView.frame.size.width * CGFloat(wsize)), height: CGFloat(scrollView.frame.size.height))
        pageControl.numberOfPages = wsize
        pageControl.currentPage = 0

    }

}


extension EmoticonView : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.tag == 100) {
            return;
        }
        
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.tag == 100) {
            return;
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
}
