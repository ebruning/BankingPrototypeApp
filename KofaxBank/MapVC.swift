//
//  MapVC.swift
//  KofaxBank
//
//  Created by Rupali on 06/07/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    
    private var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupLocationManager()
        
        let initialLocation = CLLocation(latitude: 33.6703872066515, longitude: -117.761670558197)  //Kofax Irvine location
        
        mapview.showsUserLocation = true
        centerMapOnLocation(location: initialLocation)
        addAnnotationsOnMap(location: initialLocation)
    }
    
    
    // Locationmanager methods
/*
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
        else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
        case .authorizedAlways:
            print("Always")
        case .denied:
            print("Denied")
        case .restricted:
            print("Restricted")
        case .notDetermined:
            print("Not determined")
        }
    }

    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        centerMapOnLocation(location: locations.first!)

        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
  */
    func centerMapOnLocation(location: CLLocation) {
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapview.setRegion(coordinateRegion, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to initialize GPS: ", error.localizedDescription)
    }
    
    //Mapview Annotation methods
    
    func addAnnotationsOnMap(location: CLLocation) {
        
       //let locationWithCoordinates = CLLocation();

        let coordType = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordType
        
        annotation.title = "Kofax Bank ATM"
        
        mapview.addAnnotation(annotation)
    }
    
    //mapview delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "Logo")
        annotationView!.image = pinImage
        return annotationView
    }
    
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
