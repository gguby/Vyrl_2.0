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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pagingControl.frame = self.view.frame
        pagingControl.delegate   = self
        pagingControl.dataSource = self
        pagingControl.reloadData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func canRotate() -> Void {
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pagingControl.frame = self.view.frame
    }
}

extension PagingFullViewController : PagingScrollViewDelegate, PagingScrollViewDataSource {
    func pagingScrollView(_ pagingScrollView: PagingScrollView, willChangedCurrentPage currentPageIndex: NSInteger) {
         print("current page will be changed to \(currentPageIndex).")
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, didChangedCurrentPage currentPageIndex: NSInteger) {
        print("current page did changed to \(currentPageIndex).")
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, layoutSubview view: UIView) {
        print("paging control call layoutsubviews.")
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
        
       self.requestImageVideo(index: index, zoomingView: zoomingView, zoomContentView: zoomContentView)
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
    
}
