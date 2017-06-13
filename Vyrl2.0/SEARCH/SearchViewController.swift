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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        print("Search");
        
        initSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
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
