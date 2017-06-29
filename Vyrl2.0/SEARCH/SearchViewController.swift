
//
//  SearchViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnActivity: UIButton!
    @IBOutlet weak var searchTableView: UIView!
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    @IBOutlet weak var btnTag: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnFan: UIButton!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        print("Search");
        
        initSearchBar()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSearchBar()
    {
        searchBar.setImage(UIImage.init(named: "icon_search_02_off"), for: UISearchBarIcon.search, state: UIControlState.normal)
        searchBar.placeholder = "검색"
        searchBar.backgroundImage = UIImage()
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.clear
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.font = UIFont.ivTextStyleFont()
        
        searchBar.delegate = self
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchTableView.isHidden = false
        
        btnCancel.isHidden = false
        btnActivity.isHidden = true
        
        
        return true
    }
    
    @IBAction func hiddenAction(_ sender: Any) {
        btnCancel.isHidden = true
        btnActivity.isHidden = false
        
        searchTableView.isHidden = true
        
        searchBar.resignFirstResponder()
    }
    
    @IBOutlet weak var selectedLine1: UIView!
    @IBOutlet weak var selectedLine2: UIView!
    @IBOutlet weak var selectedLine3: UIView!
    
    @IBAction func tagAction(_ sender: UIButton) {
        sender.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        btnFan.setTitleColor(UIColor.black, for: .normal)
        btnUser.setTitleColor(UIColor.black, for: .normal)
        
        selectedLine1.isHidden = false
        selectedLine2.isHidden = true
        selectedLine3.isHidden = true
    }
    
    @IBAction func userAction(_ sender: UIButton) {
        sender.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        btnTag.setTitleColor(UIColor.black, for: .normal)
        btnFan.setTitleColor(UIColor.black, for: .normal)
        
        selectedLine1.isHidden = true
        selectedLine2.isHidden = false
        selectedLine3.isHidden = true
    }
    
    @IBAction func fanAction(_ sender: UIButton) {
        sender.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        btnTag.setTitleColor(UIColor.black, for: .normal)
        btnUser.setTitleColor(UIColor.black, for: .normal)
        
        selectedLine1.isHidden = true
        selectedLine2.isHidden = true
        selectedLine3.isHidden = false
    }    
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :FollowCell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
        return cell
    }
}

extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.postCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell
            
            return cell
        } else {
          let cell : OfficialCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfficialCollectionCell", for: indexPath) as! OfficialCollectionCell
          
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}

class LeftAlignedSearchBar: UISearchBar, UISearchBarDelegate {
    override var placeholder:String? {
        didSet {
            if #available(iOS 9.0, *) {
                
                if let text = placeholder {
                    if text.characters.last! != " " {
                        // get the font attribute
                        let attr = UITextField.appearance(whenContainedInInstancesOf: [LeftAlignedSearchBar.self]).defaultTextAttributes
                        // define a max size
                        let maxSize = CGSize(width: UIScreen.main.bounds.size.width - 87, height: 40)
                        // let maxSize = CGSize(width:self.bounds.size.width - 92,height: 40)
                        // get the size of the text
                        let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        // get the size of one space
                        let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        let spaces = floor((maxSize.width - widthText) / widthSpace)
                        // add the spaces
                        let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
                        // apply the new text if nescessary
                        if newText != text {
                            placeholder = newText
                        }
                    }
                }
            }
        }
    }
}

extension UIFont {
    class func ivTextStyleFont() -> UIFont? {
        return UIFont(name: "AppleSDGothicNeo-Medium", size: 16.0)
    }
}

extension UIColor {
    class var ivPaleGrey: UIColor {
        return UIColor(red: 242.0 / 255.0, green: 240.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }
}

class OfficialCollectionCell : UICollectionViewCell {
    
    
    
}

class FollowCell : UITableViewCell {
    
    
    
}

