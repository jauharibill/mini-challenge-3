//
//  AmbilSampahVC.swift
//  MiniChallenge3
//
//  Created by Nanda Mochammad on 20/08/19.
//  Copyright © 2019 Batavia Hack Town. All rights reserved.
//

import UIKit
//1. import mapkit n core location
import MapKit
import CoreLocation

//5. add CLLocationManagerDelegate
class AmbilSampahVC: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapKitView: MKMapView!
    
    //2. create CLLocationManager
    let manager = CLLocationManager()
    var arrayUserData : [UserDataModel] = []
    
    var statusPelanggan = "sub_with_me"
    var pelangganByStatus = [UserDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayUserData.removeAll()
        
        mapKitView.delegate = self
        manager.delegate = self
        
        loadInitialData()
        mapKitView.addAnnotations(arrayUserData)
        

        getLocation()

    }
    
    @IBAction func lokasiSayaBtn(_ sender: Any) {
        getLocation()
    }
    
    @IBAction func cariPelangganBtn(_ sender: Any) {
        statusPelanggan = "no_sub_yet"
        mapKitView.reloadInputViews()
    }
    
    @IBAction func pelangganSayaBtn(_ sender: Any) {
        statusPelanggan = "sub_with_me"
        mapKitView.reloadInputViews()
    }
    
    func getLocation() {
        mapKitView.showsUserLocation = true
        
        //6. set our location manager to update
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {
                
                //3.4. Call the auth here
                manager.requestAlwaysAuthorization()
                manager.requestWhenInUseAuthorization()
            }

            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 20
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            manager.startUpdatingLocation()
            
        } else {
            print("PLease turn on location services or GPS")
        }
    }
    
    func loadInitialData() {
        do {
            guard let file = Bundle.main.url(forResource: "DataUserDummy", withExtension: "json") else {
                print("json raw not found")
                return
            }
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let object = json as? [[String: Any]] else { print("json invalid"); return}

            for data in object{
                let lat = data["latitude"]
                let long = data["longitude"]
                let phoneNumb = data["phone_number"] as! Int

                let validData = UserDataModel(name: data["name"] as! String, address: data["address"] as! String, phoneNumber: String(phoneNumb), latitude: lat as! Double, longitude: long as! Double, status: data["status_subs"] as! String)
                arrayUserData.append(validData)
            }
            
        } catch  {
            print("Error load Dummy Data, ", error.localizedDescription)
        }
    }

    
}

extension AmbilSampahVC: MKMapViewDelegate{
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBar(withTitle: "Ambil Sampah", destination: self)
    }
    
    //MARK:- Location Manager Protocol
    //7. declare the location manager didUpdateLocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.manager.stopUpdatingLocation()
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")

        let centerLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
//        let region = MKCoordinateRegion(center: centerLocation, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        let regions = MKCoordinateRegion(center: centerLocation, latitudinalMeters: 2500.0, longitudinalMeters: 2500.0)
        
        //bring camera to this position
        self.mapKitView.setRegion(regions, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    //MARK:-MKMapView Protocol
    //to set every view of annotation (same like cellForRowAt in tableview)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        pelangganByStatus.removeAll()
        if statusPelanggan == "sub_with_me"{
            for data in arrayUserData{
                if data.status_subs == "sub_with_me"{
                    pelangganByStatus.append(data)
                }
            }
        }else if statusPelanggan == "no_sub_yet"{
            for data in arrayUserData{
                if data.status_subs == "no_sub_yet"{
                    pelangganByStatus.append(data)
                }
            }
        }
        guard let annotation = annotation as? UserDataModel else { return nil }
        print("ASVC: ViewFor-> Check Annotation, ", annotation)
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! UserDataModel
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }

}


