//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/27/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "annotationID")
        let loc = locationManager.location
        
        guard let latitude = loc?.coordinate.latitude,
            let longitude = loc?.coordinate.longitude else {return}
        
        let myLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let myLocationAnnotation = MyLocationAnnotation(coordinate: myLocation, title: "myLocaion Baby!!")
        mapView.addAnnotation(myLocationAnnotation)
        mapView.setRegion(myLocationAnnotation.region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let myLocationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationID") as? MKMarkerAnnotationView {
            myLocationAnnotationView.animatesWhenAdded = true
            //myLocationAnnotationView.titleVisibility = .adaptive
            return myLocationAnnotationView
        } else {
            return nil
        }
    }
}
