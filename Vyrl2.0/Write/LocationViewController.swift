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

protocol LocationDelegate {
    func addLocationText(place : Place)
}

class LocationViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationBtn: UIButton!
    
    var locationManager : CLLocationManager!
    var currentCLLocation: CLLocation?
    
    var places = [Place]()
    var currentPlace : Place?
    
    var delegate : LocationDelegate!
    
    @IBAction func refreshLocation(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func cancel(_ sender: UIButton) {        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initLocation()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func enabledLocationBtn(enable : Bool){
        
        self.locationBtn.isEnabled = enable
        
        if enable{
            self.locationBtn.setImage(UIImage.init(named: "icon_gps_01_on"), for: .normal)
        }else {
            self.locationBtn.setImage(UIImage.init(named: "icon_gps_01_off"), for: .normal)
        }
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        self.enabledLocationBtn(enable: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.enabledLocationBtn(enable: true)
        
        if let location = locations.first {
            self.locationManager.stopUpdatingLocation()
            self.currentCLLocation = location
            
            self.fetchPlaces(location.coordinate.latitude, longitude: location.coordinate.longitude, radius: 150, key: Constants.GoogleMapsAPIServerKey)
        }
    }
    
    func fetchPlaces(_ latitude: Double, longitude: Double, radius: Double, key: String){
        
        let urlStr = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&key=\(key)"
        
        Alamofire.request(urlStr, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
                let array :[Dictionary<String, AnyObject>] = jsonData["results"] as! [Dictionary<String, AnyObject>]

                self.places.removeAll()
                
                if let place = self.currentPlace {
                    self.places.append(place)
                }
                
                for result in array {
                    var pName : String?
                    var pFormattedAddress: String?
                    var pGeometry: [String: AnyObject]?
                    
                    if let name: String = result["name"] as? String {
                        pName = name
                    }
                    
                    if let vicinity = result["vicinity"] as? String {
                        pFormattedAddress = vicinity
                    }
                    
                    if let geometry = result["geometry"] as? NSDictionary {
                        pGeometry = geometry as? [String : AnyObject]
                    }
                    
                    if let name = pName, let formattedAddress = pFormattedAddress, let geometry = pGeometry {
                        
                        var place = Place.init(name: name, address: formattedAddress, geometry: geometry)
                        place.latitude = latitude
                        place.longitude = longitude
                        
                        self.places.append(place)
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }

                
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension LocationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let place = self.places[indexPath.row]
        
        if indexPath.row == 0 && place.isSelectedCell == true {
            let cell : CurrentPlaceCell = tableView.dequeueReusableCell(withIdentifier: "CurrentPlaceCell") as! CurrentPlaceCell
            cell.title.text = place.name
            cell.location.text = place.address
            
            cell.delegate = self
            
            return cell
        }
        
        let cell :PlaceCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell") as! PlaceCell
        
        cell.place = place
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var place = places[indexPath.row]
        
        place.isSelectedCell = true
        
        self.delegate.addLocationText(place: place)
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationViewController : PlaceCellDelegate {
    func remove() {
        self.places.remove(at: 0)
        self.currentPlace = nil
        self.tableView.reloadData()
    }
}

protocol PlaceCellDelegate {
    func remove()
}


class CurrentPlaceCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    
    var delegate : PlaceCellDelegate!
    
    @IBAction func remove(_ sender: UIButton) {
        delegate.remove()
    }
}

class PlaceCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!    
    @IBOutlet weak var location: UILabel!
    
    var place : Place! {
        didSet{
            self.title.text = place.name
            self.location.text = place.address
        }
    }
}

extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        let lower = UTF16View.Index(range.lowerBound, within: utf16)
        let upper = UTF16View.Index(range.upperBound, within: utf16)
        return NSRange(location: utf16.startIndex.distance(to: lower), length: lower!.distance(to: upper))
    }
}

struct Place {
    var name : String!
    var address: String!
    var geometry: [String: AnyObject]!
    
    var latitude : Double!
    var longitude : Double!
    
    var isSelectedCell : Bool! = false
    
    init(name :String, address : String, geometry: [String: AnyObject]) {
        self.name = name
        self.address = address
        self.geometry = geometry
    }
    
    func attributeString() -> NSMutableAttributedString{
        let str = " 에서 작성"
        let string = "- \(self.name!)" + str
        
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "AppleSDGothicNeo-Regular", size: 12.0)!, range: NSRange(location: 0, length: 1))
        attributedString.addAttributes([
            NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 12.0)!,
            NSForegroundColorAttributeName: UIColor(red: 134.0 / 255.0, green: 131.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
            ], range: string.nsRange(from: string.range(of: str)!))
        
        return attributedString
    }
}
