//
//  myLocationAnnotation.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/27/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class MyLocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D  //this is required for MKAnnotation, NSObject
    var title: String?  //this is not required for MKAnnotation
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
    
    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        return MKCoordinateRegion(center:coordinate, span: span)
    }
}
