//
//  FanViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class FanViewController: UIViewController {
    @IBOutlet weak var officialFanclubCollectionView: UICollectionView!
    
    @IBOutlet weak var joinFanpageCollectionView: UICollectionView!
    
    @IBOutlet weak var recommandFanpageTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var searchTableView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        
        print("Fan");
        initSearchBar()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
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
        
    }
    @IBAction func hiddenAction(_ sender: Any) {
        searchTableView.isHidden = true;
        searchBar.resignFirstResponder()
    }

}

extension FanViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.officialFanclubCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfficialFanclubCell", for: indexPath) as UICollectionViewCell
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

}

extension FanViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell = UITableViewCell()
        if(tableView == self.searchTable)
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "OfficialBannerCell", for: indexPath) as UITableViewCell
        } else if(tableView == self.recommandFanpageTableView) {
            cell = tableView.dequeueReusableCell(withIdentifier: "RecommandFanpageCell", for: indexPath) as UITableViewCell
        }
        return cell
    }

}

extension FanViewController : UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchTableView.isHidden = false
        return true
    }
}
