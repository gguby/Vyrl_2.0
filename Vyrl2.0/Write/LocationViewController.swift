//
//  LocationViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 7. 19..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class LocationViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationBtn: UIButton!
    
    var locationManager : CLLocationManager!
    var currentCLLocation: CLLocation?
    
    @IBAction func refreshLocation(_ sender: UIButton) {
    }
    
    @IBAction func cancel(_ sender: UIButton) {        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initLocation()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

}

extension LocationViewController : CLLocationManagerDelegate {
    func initLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.locationManager.stopUpdatingLocation()
            self.currentCLLocation = location
            
            self.fetchPlaces(location.coordinate.latitude, longitude: location.coordinate.longitude, radius: 500, key: Constants.GoogleMapsAPIServerKey)
        }
    }
    
    func fetchPlaces(_ latitude: Double, longitude: Double, radius: Double, key: String){
        let urlStr = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&key=\(key)"
        
        Alamofire.request(urlStr, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
//                self.nickNameField.text = jsonData["nickName"] as? String
//                self.introField.text = jsonData["selfIntro"] as? String
//                self.webURLField.text = jsonData["homepageUrl"] as? String
//                
//                if(jsonData["imagePata"] != nil) {
//                    let url = NSURL(string: jsonData["imagePath"] as! String)
//                    self.photoView.af_setImage(for: UIControlState.normal, url: url! as URL)
//                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension LocationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :AlbumCell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell") as! AlbumCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}


class CurrentPlaceCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBAction func remove(_ sender: UIButton) {
    }
}

class PlaceCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!    
    @IBOutlet weak var location: UILabel!
}
