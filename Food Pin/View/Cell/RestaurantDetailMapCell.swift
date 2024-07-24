//
//  RestaurantDetailMapCell.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 22.07.24.
//

import UIKit
import MapKit

class RestaurantDetailMapCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(location: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            guard let self else { return }
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let placemarks {
                let placemark = placemarks[0]
                let annotation = MKPointAnnotation()
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    let region = MKCoordinateRegion(
                        center: annotation.coordinate,
                        latitudinalMeters: 250,
                        longitudinalMeters: 250
                    )
                    self.mapView.setRegion(region, animated: false)
                }
            }
        }
    }

}
