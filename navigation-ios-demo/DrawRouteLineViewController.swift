//
//  DrawRouteLineViewController.swift
//  navigation-ios-demo
//
//  Created by Jia on 15/5/23.
//

import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class DrawRouteLineViewController: UIViewController, NGLMapViewDelegate {
    
    var navigationMapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let navigationMapView = navigationMapView {
                view.insertSubview(navigationMapView, at: 0)
            }
        }
    }
    
    var routes : [Route] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
        
        self.navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView?.userTrackingMode = .followWithHeading
        navigationMapView?.delegate = self
        
        self.view.setNeedsLayout()
        
        requestRoutes(origin: origin, destination: destination)
    }
    
    func requestRoutes(origin: CLLocation, destination: CLLocation){
    
        let options = NavigationRouteOptions(origin: origin, destination: destination)
        /**
         Sets whether the  route contains an alternate route
         By default , it set to `false`
         */
        options.includesAlternativeRoutes = false
        
        /**
         The route classes that the calculated routes will avoid.
         We can set an array road class to avoid.  This property can be set to `.toll`,`.ferry`,`.highway`
         By default ,  this property is set to empty
         */
        options.roadClassesToAvoid = [.toll,.ferry,.highway]
        /**
         Set up the navigation measurement unit
         This property should be set to `.metric` or `.imperial`
         By default ,  this property is set to the unit follow with current system locale.
         */
        options.distanceMeasurementSystem = .imperial
        
        /**
         Set  specifying the primary mode of transportation for the routes.
         This property should be set to `NBNavigationModeCar`, `NBNavigationModeAuto`, `NBNavigationModeBike`, `NBNavigationMode4W`,`NBNavigationMode2W`,`NBNavigationMode6W`, or `NBNavigationModeEscooter`. The default value of this property is `NBNavigationMode4W`,  which specifies driving directions.
        */
        options.profileIdentifier = NBNavigationMode.car
        /**
         Set the  departureTime of the route , By default ,  it sets the current timestamp since from 1970
         */
        options.departureTime = Int(Date().timeIntervalSince1970)
        
        /**
         Set up the locale in which the route’s instructions are written.
         If you use NbmapDirections.swift with the Nbmap Directions API, this property affects the sentence contained within the `RouteStep.instructions` property, but it does not affect any road names contained in that property or other properties such as `RouteStep.name`.
         The Navigation API can provide instructions in [a number of languages]. Set this property to `Bundle.main.preferredLocalizations.first` or `Locale.autoupdatingCurrent` to match the application’s language or the system language, respectively.
         By default, this property is set to the current system locale.
         */
        options.locale = Locale.autoupdatingCurrent
        
        /**
         Set map options, This property may make the ETA more accurate.  If set to `NBMapOption.valhala`, shapeFormat needs to be set to `polyline`.
         By default , the value of this  property is `NBMapOption.none`
         */
        options.mapOption = NBMapOption.none
        /**
         Format of the data from which the shapes of the returned route and its steps are derived.

         This property has no effect on the returned shape objects, although the choice of format can significantly affect the size of the underlying HTTP response.

         The default value of this property is `polyline6`.
         */
        options.shapeFormat = .polyline6
        
        Directions.shared.calculate(options) { [weak self] routes, error in
            guard let weakSelf = self else {
                 return
            }
            guard error == nil else {
                 print(error!)
                return
            }

            guard let routes = routes else { return }
            
            weakSelf.navigationMapView?.showRoutes(routes)

            guard let current = routes.first else { return }
            weakSelf.navigationMapView?.showWaypoints(current)
            weakSelf.routes = routes
        }
    }
}


