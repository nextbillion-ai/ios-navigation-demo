//
//  Custom-Map-LocationManager.swift
//  navigation-ios-demo
//
//  Created by qiu on 2023/4/20.
//

import Nbmap
import CoreLocation

class CustomMapLocationManager: NSObject,NGLLocationManager {
    
    var delegate: NGLLocationManagerDelegate? {
        didSet {
            locationManager.delegate = self
        }
    }
    
    // Replay with your own location manager
    private let locationManager = CLLocationManager()
    
    var headingOrientation: CLDeviceOrientation {
        get {
            return locationManager.headingOrientation
        }
        set {
            locationManager.headingOrientation = newValue
        }
    }
    
    var desiredAccuracy: CLLocationAccuracy {
        get {
            return locationManager.desiredAccuracy
        }
        set {
            locationManager.desiredAccuracy = newValue
        }
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    var activityType: CLActivityType {
        get {
            return locationManager.activityType
        }
        set {
            locationManager.activityType = newValue
        }
    }
    
    @available(iOS 14.0, *)
    var accuracyAuthorization: CLAccuracyAuthorization {
        return locationManager.accuracyAuthorization
    }
    
    @available(iOS 14.0, *)
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }
    
    func dismissHeadingCalibrationDisplay() {
        locationManager.dismissHeadingCalibrationDisplay()
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.delegate = nil
        delegate = nil
    }
    
}

// MARK: - CLLocationManagerDelegate
extension CustomMapLocationManager : CLLocationManagerDelegate {
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(self, didUpdate: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.locationManager(self, didUpdate: newHeading)
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return delegate?.locationManagerShouldDisplayHeadingCalibration(self) ?? false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(self, didFailWithError: error)
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationManagerDidChangeAuthorization(self)
    }
}
