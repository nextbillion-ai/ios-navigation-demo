import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class CustomDestinationMarkerController: UIViewController {
    
    var mapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let mapView = mapView {
                view.insertSubview(mapView, at: 0)
            }
        }
    }
    
    var routes : [Route]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView = NavigationMapView(frame: view.bounds)
        
        mapView?.userTrackingMode = .followWithHeading
        
        let singleTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        mapView?.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(singleTap.require(toFail:))
        mapView?.addGestureRecognizer(singleTap)
        mapView?.delegate = self
        
    }
    
    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let mapView = mapView, tap.state == .began else {
            return
        }
        let coordinates = mapView.convert(tap.location(in: mapView), toCoordinateFrom: mapView)
        // Note: The destination name can be modified. The value is used in the top banner when arriving at a destination.
        let destination = Waypoint(coordinate: coordinates, name: "\(coordinates.latitude),\(coordinates.longitude)")
        addNewDestinationcon(coordinates: coordinates)
        
        guard let currentLocation =  mapView.userLocation?.coordinate else { return}
        let currentWayPoint = Waypoint.init(coordinate: currentLocation, name: "My Location")
        
        requestRoutes(origin: currentWayPoint, destination: destination)
    }
    
    @IBAction func startNavigation(_ sender: Any) {
        guard let routes = self.routes else {
            return
        }
        let navigationService = NBNavigationService(routes: routes, routeIndex: 0)
        
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        
        let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        navigationViewController.delegate = self
        
        present(navigationViewController, animated: true, completion: nil)
        
    }
    
    func addNewDestinationcon(coordinates: CLLocationCoordinate2D){
        guard let mapView = mapView else {
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
        
        let options = RouteOptions.init(origin: origin, destination: destination)
        // Includes alternative routes in the response
        options.includesAlternativeRoutes = true
        
        // Set the measurement format system
        options.distanceMeasurementSystem = MeasurementSystem.metric
        
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
            weakSelf.mapView?.showRoutes(routes)
            weakSelf.mapView?.showRouteDurationSymbol(routes)
            
            guard let current = routes.first else { return }
            weakSelf.mapView?.showWaypoints(current)
            weakSelf.routes = routes
        }
    }
    
}

extension CustomDestinationMarkerController : NGLMapViewDelegate {
    
    func mapView(_ mapView: NGLMapView, imageFor annotation: NGLAnnotation) -> NGLAnnotationImage? {
        let image = UIImage(named: "marker", in: .main, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal)
        return NGLAnnotationImage(image: image, reuseIdentifier: "destination_icon_identifier")
    }
}

extension CustomDestinationMarkerController : NavigationViewControllerDelegate {
    
    func navigationViewController(_ navigationViewController: NavigationViewController, imageFor annotation: NGLAnnotation) -> NGLAnnotationImage? {
        let image = UIImage(named: "marker", in: .main, compatibleWith: nil)!.withRenderingMode(.alwaysOriginal)
        return NGLAnnotationImage(image: image, reuseIdentifier: "destination_icon_identifier")
    }
}
