import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class CustomWaypointStylingViewController: UIViewController {
    
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
            if oldValue != nil || routes == nil || routes?.first == nil {
                navigationMapView?.removeRoutes()
                navigationMapView?.removeRouteDurationSymbol()
                if let annotation = navigationMapView?.annotations?.last {
                    navigationMapView?.removeAnnotation(annotation)
                }
                return
            }
            
            guard let routes = routes,
                  let current = routes.first
            else {
                return
            }
            
            navigationMapView?.showRoutes(routes)
            navigationMapView?.showWaypoints(current)
            navigationMapView?.showRouteDurationSymbol(routes)
            
            guard let newCamera = navigationMapView?.camera else {
                return
            }
            newCamera.centerCoordinate = CLLocationCoordinate2D(latitude: 37.77440680146262, longitude: -122.43539772352648)
            newCamera.viewingDistance = 1000
            navigationMapView?.setCamera(newCamera, animated: true)
        }
    }
    
    private let startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMapView = NavigationMapView(frame: view.bounds)
        
        navigationMapView?.userTrackingMode = .follow
        // Set delegate for navigation map view
        navigationMapView?.navigationMapDelegate = self
        // Set delegate for NGLMapView
        navigationMapView?.delegate = self
        setupStartButton()
        requestRoutes()
        
    }
    
    func setupStartButton() {
        startButton.setTitle("Start", for: .normal)
        startButton.layer.cornerRadius = 5
        startButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        startButton.backgroundColor = .blue
        
        startButton.addTarget(self, action: #selector(performAction), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    }
    
    @objc func performAction(_ sender: Any) {
        guard let routes = self.routes else {
            return
        }
        let navigationService = NBNavigationService(routes: routes, routeIndex: 0, simulating : simulationIsEnabled ? SimulationMode.always : SimulationMode.inTunnels)
        let styles = [DayStyle(), NightStyle()]
        let navigationOptions = NavigationOptions(styles:styles,navigationService: navigationService)
        
        let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        navigationViewController.delegate = self
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    func requestRoutes(){
        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let waypoint = CLLocation(latitude: 37.76856957793795, longitude: -122.42709811526268)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
        let options = NavigationRouteOptions(locations: [origin,waypoint,destination])
        
        Directions.shared.calculate(options) { [weak self] routes, error in
            guard let weakSelf = self else {
                return
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let routes = routes else { return }
            weakSelf.routes = routes
        }
    }
    
    
    func customShape(for waypoints: [Waypoint], legIndex: Int) -> NGLShape? {
        var features = [NGLPointFeature]()
        
        for (waypointIndex, waypoint) in waypoints.enumerated() {
            let feature = NGLPointFeature()
            feature.coordinate = waypoint.coordinate
            feature.attributes = [
                "waypointCompleted": waypointIndex < legIndex,
                "name": "waypoint" + String(waypointIndex + 1)
            ]
            features.append(feature)
        }
        
        return NGLShapeCollectionFeature(shapes: features)
    }
    
    func customWaypointSymbolStyleLayer(style: NGLStyle?,identifier: String, waypoints: [Waypoint], source: NGLSource) -> NGLStyleLayer {
        let circles = NGLSymbolStyleLayer(identifier: identifier, source: source)
        let opacity = NSExpression(forConditional: NSPredicate(format: "waypointCompleted == true"), trueExpression: NSExpression(forConstantValue: 0.5), falseExpression: NSExpression(forConstantValue: 1))
        circles.iconOpacity = opacity
        circles.iconImageName = NSExpression(forKeyPath: "name")
        
        for (waypointIndex, waypoint) in waypoints.enumerated() {
            let indexString = String(waypointIndex + 1)
            let circularView = CustomWaypointStyle(frame: CGRect(x: 0, y: 0, width: 24, height: 24), labelText: indexString)
            if let circularImage = circularView.captureScreenshot() {
                style?.setImage(circularImage, forName: "waypoint" + indexString)
            }
        }
        
        return circles
    }
    
}
// MARK: - Implement NavigationViewControllerDelegate to custom waypoint and receive callback from map screen
extension CustomWaypointStylingViewController: NavigationMapViewDelegate {
    
    func navigationMapView(_ mapView: NavigationMapView, waypointSymbolStyleLayerWithIdentifier identifier: String, waypoints: [Waypoint],source: NGLSource) -> NGLStyleLayer? {
        return customWaypointSymbolStyleLayer(style: mapView.style,identifier: identifier, waypoints: waypoints, source: source)
    }

    
    func navigationMapView(_ mapView: NavigationMapView, shapeFor waypoints: [Waypoint], legIndex: Int) -> NGLShape? {
        return customShape(for: waypoints, legIndex: legIndex)
    }
}

extension CustomWaypointStylingViewController: NavigationViewControllerDelegate {
    
    func navigationViewController(_ navigationViewController: NavigationViewController, shapeFor waypoints: [Waypoint], legIndex: Int) -> NGLShape? {
        return customShape(for: waypoints, legIndex: legIndex)
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, waypointSymbolStyleLayerWithIdentifier identifier: String, waypoints: [Waypoint] , source: NGLSource) -> NGLStyleLayer? {
        return customWaypointSymbolStyleLayer(style: navigationViewController.navigationMapView?.style,identifier: identifier, waypoints: waypoints, source: source)
    }
    
    func navigationMapView(_ mapView: NavigationMapView, didSelect waypoint: Waypoint) {
        let alert = UIAlertController(title: "Did select waypoint", message: "\(waypoint.description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        let alert = UIAlertController(title: "Did select route.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Implement NGLMapViewDelegate to receive click marker event from the  map screen
extension CustomWaypointStylingViewController: NGLMapViewDelegate {
    func mapView(_ mapView: NGLMapView, didSelect annotation: NGLAnnotation) {
        let alert = UIAlertController(title: "Did select marker \(annotation.description).", message: "\(annotation.coordinate)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
