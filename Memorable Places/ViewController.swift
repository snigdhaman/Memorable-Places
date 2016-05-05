//
//  ViewController.swift
//  Memorable Places
//
//  Created by Chatterjee, Snigdhaman on 02/01/16.
//  Copyright © 2016 Chatterjee, Snigdhaman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        } else {
            
            if activePlace <= places.count {
                
                let lat = NSString(string: places[activePlace]["lat"]!).doubleValue
                let long = NSString(string: places[activePlace]["long"]!).doubleValue
            
                let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                let locationInMap : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
                let region : MKCoordinateRegion = MKCoordinateRegionMake(locationInMap, span)
            
                self.map.setRegion(region, animated: true)
            
                let name = places[activePlace]["name"]
            
                let annotation = MKPointAnnotation()
                annotation.coordinate = locationInMap
                annotation.title = name
                self.map.addAnnotation(annotation)
            }
            
        }

        
        let longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        longPress.minimumPressDuration = 1
        map.addGestureRecognizer(longPress)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let locationInMap : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(locationInMap, span)
        
        self.map.setRegion(region, animated: true)
        
    }
    
    func action(gestureRecogniser : UIGestureRecognizer) {
        
        if gestureRecogniser.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecogniser.locationInView(self.map)
            let newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            let geoLocateCoordinate = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(geoLocateCoordinate, completionHandler: { (placeMarks, error) -> Void in
                
                var address = ""
                
                if error == nil {
                    if let subThoroughfare = placeMarks?[0].subThoroughfare {
                        address = address + "\(subThoroughfare),"
                    }
                    if let thoroughfare = placeMarks?[0].thoroughfare {
                        address = address + " \(thoroughfare),"
                    }
                    if let subLocality = placeMarks?[0].subLocality {
                        address = address + " \(subLocality),"
                    }
                    if let locality = placeMarks?[0].locality {
                        address = address + " \(locality)\n"
                    }
                    if let subAdministrativeArea = placeMarks?[0].subAdministrativeArea {
                        address = address + "\(subAdministrativeArea),"
                    }
                    if let administrativeArea = placeMarks?[0].administrativeArea {
                        address = address + " \(administrativeArea)\n"
                    }
                    if let country = placeMarks?[0].country {
                        address = address + "\(country)"
                    }
                    
                    if address.isEmpty {
                        address = "Added on \(NSDate())"
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = newCoordinate
                    annotation.title = address
                    self.map.addAnnotation(annotation)
                    
                    places.append(["name" : address, "lat" : String(newCoordinate.latitude), "long" : String(newCoordinate.longitude)])
                    NSUserDefaults.standardUserDefaults().setObject(places, forKey: "places")
                }
                
            })
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

