import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class CustomLocationSourceViewController: UIViewController, NGLMapViewDelegate {
    
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
        }
    }
    
    var currentRouteIndex = 0
    
    var startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        
        navigationMapView?.locationManager = CustomMapLocationManager()
        
        navigationMapView?.userTrackingMode = .followWithHeading
        
        let singleTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        navigationMapView?.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(singleTap.require(toFail:))
        navigationMapView?.addGestureRecognizer(singleTap)
        
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
        let navigationService = NBNavigationService(routes: routes, routeIndex: currentRouteIndex,locationSource: CustomNavigationLocationManager())
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        
        let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let navigationMapView = navigationMapView, tap.state == .began else {
            return
        }
        let coordinates = navigationMapView.convert(tap.location(in: navigationMapView), toCoordinateFrom: navigationMapView)
        // Note: The destination name can be modified. The value is used in the top banner when arriving at a destination.
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
