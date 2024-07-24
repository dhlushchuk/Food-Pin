//
//  MapViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 22.07.24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let identifier = "MyMarker"
    
    var restaurant: Restaurant!

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.showsCompass = true
            mapView.showsTraffic = true
            mapView.showsScale = true
            mapView.delegate = self
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnnotation()
        
    }

    private func setupAnnotation() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(restaurant.location) { [weak self] placemarks, error in
            guard let self else { return }
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let placemarks {
                let placemark = placemarks[0]
                let annotation = MKPointAnnotation()
                annotation.title = restaurant.name
                annotation.subtitle = restaurant.type
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! MKMarkerAnnotationView
        annotationView.glyphText = "😋"
        annotationView.markerTintColor = .orange
        return annotationView
    }
    
}
