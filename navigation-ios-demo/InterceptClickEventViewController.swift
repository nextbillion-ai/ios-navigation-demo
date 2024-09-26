//
//  InterceptClickEventViewController.swift
//  navigation-ios-demo
//
//  Created by Jia on 15/5/23.
//

import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class InterceptClickEventViewController: UIViewController, NGLMapViewDelegate {
    
    var navigationMapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let navigationMapView = navigationMapView {
                view.insertSubview(navigationMapView, at: 0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMapView = NavigationMapView(frame: view.bounds)
        
        navigationMapView?.userTrackingMode = .followWithHeading
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        navigationMapView?.addGestureRecognizer(singleTap)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        navigationMapView?.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(longTap.require(toFail:))
        navigationMapView?.addGestureRecognizer(longTap)
        
        
        navigationMapView?.delegate = self
        
        self.view.setNeedsLayout()
        
    }
    
    @objc func didTap(tap: UITapGestureRecognizer) {
        guard let navigationMapView = navigationMapView else {
            return
        }
        let coordinates = navigationMapView.convert(tap.location(in: navigationMapView), toCoordinateFrom: navigationMapView)
        print("Tapped on Map with latitude: " + String(coordinates.latitude) + " longitude: " + String(coordinates.longitude))
        addNewDestinationcon(coordinates: coordinates)
    }
    
    
    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let navigationMapView = navigationMapView, tap.state == .began else {
            return
        }
        let coordinates = navigationMapView.convert(tap.location(in: navigationMapView), toCoordinateFrom: navigationMapView)
        print("Long Pressed on Map with latitude: " + String(coordinates.latitude) + " longitude: " + String(coordinates.longitude))
        addNewDestinationcon(coordinates: coordinates)
    }
    
    
    func addNewDestinationcon(coordinates: CLLocationCoordinate2D){
        guard let mapView = navigationMapView else {
            return
        }
        
        if let annotation = mapView.annotations?.last {
            mapView.removeAnnotation(annotation)
        }
        
        let annotation = NGLPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
}


