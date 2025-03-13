import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class AdvancedNavigationViewController: UIViewController, NGLMapViewDelegate {
    
    var navigationMapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let navigationMapView = navigationMapView {
                view.insertSubview(navigationMapView, at: 0)
            }
        }
    }
    
    var routes : [Route]? {
        didSet {
            guard routes != nil else{
                startButton.isEnabled = false
                return
            }
            startButton.isEnabled = true
            
            guard let routes = routes,
                  let current = routes.first else { navigationMapView?.removeRoutes(); return }
            
            navigationMapView?.showRoutes(routes)
            navigationMapView?.showWaypoints(current)
            navigationMapView?.showRouteDurationSymbol(routes)
        }
    }
    
    var startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMapView = NavigationMapView(frame: view.bounds)
        
        navigationMapView?.userTrackingMode = .followWithHeading
        
        let singleTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        navigationMapView?.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(singleTap.require(toFail:))
        navigationMapView?.addGestureRecognizer(singleTap)
        navigationMapView?.delegate = self
        navigationMapView?.navigationMapDelegate = self
        
        setupStartButton()
        
        self.view.setNeedsLayout()
        
    }
    
    func setupStartButton() {
        startButton.setTitle("Start", for: .normal)
        startButton.layer.cornerRadius = 5
        startButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        startButton.backgroundColor = .blue
        
        startButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    }
    
    @objc func tappedButton(sender: UIButton) {
        guard let routes = self.routes else {
            return
        }
        let navigationService = NBNavigationService(routes: routes, routeIndex: 0,simulating: .always)
        
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
        
        // Set the delegate of navigationViewController to subscribe for NavigationView’s events, This is optional
        // navigationViewController.delegate = weakSelf
        navigationViewController.modalPresentationStyle = .fullScreen
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let navigationMapView = navigationMapView, tap.state == .began else {
            return
        }
        let coordinates = navigationMapView.convert(tap.location(in: navigationMapView), toCoordinateFrom: navigationMapView)
        let destination = Waypoint(coordinate: coordinates, name: "\(coordinates.latitude),\(coordinates.longitude)")
        addNewDestinationcon(coordinates: coordinates)
        
        guard let currentLocation =  navigationMapView.userLocation?.coordinate else { return}
        let currentWayPoint = Waypoint.init(coordinate: currentLocation, name: "My Location")
        
        requestRoutes(origin: currentWayPoint, destination: destination)
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
    
    func requestRoutes(origin: Waypoint, destination: Waypoint){
        
        let options = NavigationRouteOptions(origin: origin, destination: destination)
        /**
         Sets whether the  route contains an alternate route
         By default , it set to `false`
         */
        options.includesAlternativeRoutes = true
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
            
            
            // Process or display routes information.For example,display the routes,waypoints and duration symbol on the map
            weakSelf.navigationMapView?.showRoutes(routes)
            weakSelf.navigationMapView?.showRouteDurationSymbol(routes)
            
            guard let current = routes.first else { return }
            weakSelf.navigationMapView?.showWaypoints(current)
            weakSelf.routes = routes
        }
    }
}

extension AdvancedNavigationViewController: NavigationMapViewDelegate {
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        guard let routes = routes else { return }
        guard let index = routes.firstIndex(where: { $0 == route }) else { return }
        self.routes!.remove(at: index)
        self.routes!.insert(route, at: 0)
    }
}
