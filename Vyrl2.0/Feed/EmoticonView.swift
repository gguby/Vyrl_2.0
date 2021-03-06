//
//  EmoticonView.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 26..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

protocol EmoticonViewDelegate {
    func setEmoticonID(emoticonID : String)
    func unsetEmoticonID()
}

class EmoticonView: UIView {
    var emoticonViewDelegate: EmoticonViewDelegate
    
    var emoticonCount = [Int]()
    var emoticonButtonArray = [EmoticonButton]()
    
    var scrollView : UIScrollView!
    var selectorView : UIScrollView!
    
    var pageControl : UIPageControl!
    var itemRect : CGRect = CGRect.zero
    var emoticonSet : ObjCBool = false
    
    init(frame: CGRect, delegate:EmoticonViewDelegate) {
        self.emoticonViewDelegate = delegate
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if(scrollView == nil){
            drawTopLine(rect: rect)
            
            let userDefault = UserDefaults.standard
            var recentEmoticon = userDefault.object(forKey: "@recentEmoticon") as? String
            var emoticonArray = recentEmoticon?.components(separatedBy: "|")
            
            emoticonCount.append(2)
            emoticonCount.append(19)
            emoticonCount.append(40)
            emoticonCount.append(8)
            emoticonCount.append(8)
            emoticonCount.append(8)
            emoticonCount.append(82)
            emoticonCount.append(16)
            emoticonCount.append(8)
     
            emoticonButtonArray.removeAll()
            
            var scrollRect : CGRect = rect
            scrollRect.size.height = rect.size.height - 40.0
            
            scrollRect.origin.y = 1.0
            var selectorRect : CGRect = scrollRect
            selectorRect.size.height = 40.0;
            selectorRect.origin.y = rect.size.height - 40.0
            
            scrollView = UIScrollView.init(frame: scrollRect)
            self.addSubview(scrollView)
            scrollView.delegate = self as UIScrollViewDelegate
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            
            pageControl = UIPageControl.init(frame: CGRect.init(x: self.frame.size.width/2 - 50, y: 10, width: 100, height: 37))
            pageControl.center = CGPoint.init(x: self.frame.width/2, y: 10)
            pageControl.currentPageIndicatorTintColor = UIColor.black
            pageControl.pageIndicatorTintColor = UIColor.ivGreyish
            
            self.addSubview(pageControl)
        
            if(selectorView == nil) {
                selectorView = UIScrollView.init(frame: selectorRect)
                selectorView.tag = 100
                 
                selectorView.isPagingEnabled = true
                selectorView.showsHorizontalScrollIndicator = false
                selectorView.showsVerticalScrollIndicator = false
                
                self.addSubview(selectorView)
               
                itemRect = CGRect(x: CGFloat(0), y: CGFloat(10), width: CGFloat(scrollRect.size.width / 4), height: CGFloat((scrollRect.size.height - 20) / 2))
                
                var selectorButtonRect : CGRect = CGRect.init(x: 0, y: 0, width: scrollRect.size.width/6, height: selectorRect.size.height)
                
                
                for i in 0..<(emoticonCount.count) {
                    let btn : UIButton = UIButton.init(frame: selectorButtonRect)
                    if(i == 0) {
                        btn.setImage(UIImage.init(named: "feed_textfield_icon_emo_recent_1"), for: .normal)
                    } else {
                        btn.setImage(UIImage.init(named: "feed_textfield_icon_emo_0\(i)"), for: .normal)
                    }
                    btn.addTarget(self, action: #selector(emoticonChangeGroup(sender:)), for: UIControlEvents.touchUpInside)
                    btn.tag = i
                    self.selectorView.addSubview(btn)
                    self.selectorView.contentSize = CGSize.init(width: btn.frame.origin.x + btn.frame.size.width, height: selectorRect.size.height)
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
        
        let itemSelector = sender
       
        var btnRect: CGRect = itemRect
        
        let userDefaults = UserDefaults.standard
        let recentEmoticon: String = "\(userDefaults.object(forKey: "recentEmoticon"))"
        print("recent : \(recentEmoticon)")
        
        let recentEmoticonArray: [Any] = recentEmoticon.components(separatedBy: "|")
        
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
        var emoticonIndex: Int = 0
        var pageCount: Int = 0
        var lineCount: Int = 0
        
        for i in 1...count {
            
            let button: EmoticonButton = EmoticonButton(frame: CGRect(x: CGFloat(btnRect.origin.x), y: CGFloat(btnRect.origin.y), width: CGFloat(btnRect.size.width), height: CGFloat(btnRect.size.height)))
            button.contentHorizontalAlignment = .center
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(setEmoticonId(sender:)), for: .touchUpInside)
           
            if(itemSelector.tag == 0){
                button.setImage(UIImage.init(named:NSString(format:"emoticon_thumb_%@", itemSelector.tag, recentEmoticonArray[i-1] as! String) as String), for: .normal)
                if(emoticonSet).boolValue {
                    button.alpha = 0.5
                }
                button.emoticonID = recentEmoticonArray[i-1] as! String
            } else {
                button.setImage(UIImage.init(named:NSString(format:"emoticon_thumb_%02d_%02d.png", itemSelector.tag, i) as String), for: .normal)
                if(emoticonSet).boolValue {
                    button.alpha = 0.5
                }
                button.emoticonID = NSString(format:"%02d_%02d", itemSelector.tag, i) as String
            }
            
            if(emoticonIndex == 3) { // 2번째 줄
                btnRect.origin.y += btnRect.size.height
                emoticonIndex = 0
                if (lineCount != 0) {
                    lineCount = 0
                    pageCount += 1 // 다음 페이지
                    btnRect.origin.y = 10
                }
                else {
                    lineCount += 1
                }
                btnRect.origin.x = 0 + (CGFloat(pageCount) * (btnRect.size.width * 4))
            }
            else {
                btnRect.origin.x += btnRect.size.width
                emoticonIndex += 1
            }
            //emoticonCount
            scrollView.addSubview(button)
            emoticonButtonArray.append(button)
        }
        
        let wsize = (Int((emoticonCount[itemSelector.tag] - 1) / 8)) + 1
        scrollView.contentSize = CGSize(width: CGFloat(scrollView.frame.size.width * CGFloat(wsize)), height: CGFloat(scrollView.frame.size.height))
        pageControl.numberOfPages = wsize
        pageControl.currentPage = 0

    }

    func setEmoticonId(sender : EmoticonButton) {
        emoticonSet = true;
        
        for case let inBtn in emoticonButtonArray {
            if(inBtn.emoticonID == sender.emoticonID) {
                inBtn.alpha = 1
            } else {
                inBtn.alpha = 0.5
            }
        }
        
        emoticonViewDelegate.setEmoticonID(emoticonID: sender.emoticonID)
        
    }
    
    func drawTopLine(rect : CGRect) {
        let aPath = UIBezierPath()
        aPath.move(to: CGPoint.init(x: 0, y: 0))
        aPath.addLine(to: CGPoint.init(x: rect.size.width, y: 1))
        aPath.close()
        
        UIColor.ivLighterGreyish.set()
        aPath.stroke()
        aPath.fill()
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

class EmoticonButton : UIButton {
    var emoticonID : String = ""
}
