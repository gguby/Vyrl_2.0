//
//  PagingFullViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import FLAnimatedImage

class PagingFullViewController: UIViewController {
    
    @IBOutlet weak var pagingControl: PagingScrollView!
    var mediasArray : [ArticleMedia]!
    
    var downLoadIndex : Int! = -1
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pagingControl.frame = self.view.frame
        pagingControl.delegate   = self
        pagingControl.dataSource = self
        pagingControl.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(#function)")
        
        if(self.player != nil) {
            self.player!.pause()
            self.playerLayer?.removeFromSuperlayer()
        }
    }
    
    func canRotate() -> Void {
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.pagingControl.frame = self.view.frame
           
            guard let zoomingView = self.pagingControl.pageView(at: self.pagingControl.currentPageIndex) as? ZoomingScrollView else { return }
            
            zoomingView.prepareAfterCompleted()
            zoomingView.setMaxMinZoomScalesForCurrentBounds()
            print("finish")
            
            if(self.player != nil) {
                self.playerLayer?.frame = self.pagingControl.frame
            }
        }, completion:  {(UIViewControllerTransitionCoordinatorContext) -> Void in
            
         })
        super.viewWillTransition(to: size, with: coordinator)
        
    }
}

extension PagingFullViewController : PagingScrollViewDelegate, PagingScrollViewDataSource {
    func pagingScrollView(_ pagingScrollView: PagingScrollView, willChangedCurrentPage currentPageIndex: NSInteger) {
         print("current page will be changed to \(currentPageIndex).")
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, didChangedCurrentPage currentPageIndex: NSInteger) {
        print("current page did changed to \(currentPageIndex).")
        
        self.showImageVideo(currentIndex: currentPageIndex, view:  pagingScrollView.pageView(at: currentPageIndex)!)
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, layoutSubview view: UIView?) {
        print("paging control call layoutsubviews. \(self.view.frame)")
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, recycledView view: UIView?, viewForIndex index: NSInteger) -> UIView {
        guard view == nil else { return view! }
        
        let zoomingView = ZoomingScrollView(frame: self.view.bounds)
        zoomingView.backgroundColor = UIColor.blue
        zoomingView.singleTapEvent = {
            print("single tapped...")
        }
        
        zoomingView.doubleTapEvent = {
            print("double tapped...")
        }
        
        zoomingView.pinchTapEvent = {
            print("pinched...")
        }
        
        return zoomingView
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, prepareShowPageView view: UIView, viewForIndex index: NSInteger) {
        guard let zoomingView = view as? ZoomingScrollView else { return }
        guard let zoomContentView = zoomingView.targetView as? ZoomContentView else { return }
        
        if( downLoadIndex < index){
            downLoadIndex = index
            self.requestImageVideo(index: index, zoomingView: zoomingView, zoomContentView: zoomContentView)
        } else {
            zoomingView.prepareAfterCompleted()
            zoomingView.setMaxMinZoomScalesForCurrentBounds()
        }
    }
    
    func startIndexOfPageWith(pagingScrollView: PagingScrollView) -> NSInteger {
        return 0
    }
    
    func numberOfPageWith(pagingScrollView: PagingScrollView) -> NSInteger {
        return mediasArray.count
    }
    
    func requestImageVideo(index:Int , zoomingView : ZoomingScrollView, zoomContentView : ZoomContentView) {
        let uri : URL = URL.init(string: mediasArray[index].imageUrl)!
        
        Alamofire.request(uri)
            .downloadProgress(closure: { (progress) in
                
            }).responseData { response in
                if let data = response.result.value
                {
                    let image = UIImage(data: data)
                    
                    if(uri.pathExtension == "gif") {
                        zoomContentView.animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                    } else {
                        zoomContentView.image = image
                    }
                    // just call this methods after set image for resizing.
                    zoomingView.prepareAfterCompleted()
                    zoomingView.setMaxMinZoomScalesForCurrentBounds()
                }
        }
    }
    
    func showImageVideo(currentIndex:Int, view: UIView) {
        let uri : URL = URL.init(string: mediasArray[currentIndex].url!)!
        
        if(self.player != nil) {
            self.player!.pause()
            self.playerLayer?.removeFromSuperlayer()
        }
        
        if(mediasArray[currentIndex].type == "IMAGE"){
            
        }
        
        else {
            self.player?.pause()

            self.playerItem = AVPlayerItem.init(url: uri)
            self.player = AVPlayer.init(playerItem: self.playerItem)

            // Layer for display… Video plays at the full size of the iPad
            self.playerLayer = AVPlayerLayer(player: player)

            view.layer.addSublayer(self.playerLayer!)

            self.playerLayer?.frame = pagingControl.frame
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
         }
    }
    
}
