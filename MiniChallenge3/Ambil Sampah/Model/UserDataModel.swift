//
//  UserDataModel.swift
//  MiniChallenge3
//
//  Created by Nanda Mochammad on 21/08/19.
//  Copyright © 2019 Batavia Hack Town. All rights reserved.
//

import Foundation
import MapKit
//import contact to make direction
import Contacts

class UserDataModel: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    let title: String?
    
    let name: String
    let address: String
    let phoneNumber: String
    let latitude: Double
    let longitude: Double
    let status_subs: String
    
    init(name: String, address: String, phoneNumber: String, latitude: Double, longitude: Double, status: String) {
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.latitude = latitude
        self.longitude = longitude
        self.status_subs = status
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = name
        
        super.init()
    }
    
//    init?(json: [[String:String]]) {
//
//        print("Data JSON -> ", json)
//
//        for data in json{
//            self.name = data["Name"]!
//            self.address = data["Address"]!
//            self.phoneNumber = data["phone_number"]!
//            var lat = data["latitude"]
//            var long = data["Longitude"] as! Double
//            self.coordinate = CLLocationCoordinate2D(
//                latitude: Double(data["latitude"]!) as! CLLocationDegrees,
//                longitude: Double(data["logitude"]!) as! CLLocationDegrees)
//        }
//
//    }

    
    var subtitle: String? {
        return address
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    


}
