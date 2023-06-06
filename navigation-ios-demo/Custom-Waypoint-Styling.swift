import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import NbmapDirections
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
        }
    }
    
    private let startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMapView = NavigationMapView(frame: view.bounds)
        
        navigationMapView?.userTrackingMode = .follow
        navigationMapView?.navigationMapDelegate = self
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
        let navigationService = NBNavigationService(routes: routes, routeIndex: 0)
        let styles = [DayStyle(), NightStyle()]
        let navigationOptions = NavigationOptions(styles:styles,navigationService: navigationService)
        
        let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        navigationViewController.delegate = self
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    func requestRoutes(){
        let origin = CLLocation(latitude: 37.775252, longitude: -122.416082)
        let firstWaypoint = CLLocation(latitude: 37.779196, longitude: -122.410833)
        let secondWaypoint = CLLocation(latitude: 37.777342, longitude: -122.404094)
        
        let options = NavigationRouteOptions(locations: [origin,firstWaypoint,secondWaypoint])
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
                "name": waypointIndex + 1
            ]
            features.append(feature)
        }
        
        return NGLShapeCollectionFeature(shapes: features)
    }
    
    func customWaypointCircleStyleLayer(identifier: String, source: NGLSource) -> NGLStyleLayer {
        let circles = NGLCircleStyleLayer(identifier: identifier, source: source)
        let opacity = NSExpression(forConditional: NSPredicate(format: "waypointCompleted == true"), trueExpression: NSExpression(forConstantValue: 0.5), falseExpression: NSExpression(forConstantValue: 1))
        
        circles.circleColor = NSExpression(forConstantValue: UIColor(red:0.9, green:0.9, blue:0.9, alpha:1.0))
        circles.circleOpacity = opacity
        circles.circleRadius = NSExpression(forConstantValue: 10)
        circles.circleStrokeColor = NSExpression(forConstantValue: UIColor.green)
        circles.circleStrokeWidth = NSExpression(forConstantValue: 1)
        circles.circleStrokeOpacity = opacity
        
        return circles
    }
    
    func customWaypointSymbolStyleLayer(identifier: String, source: NGLSource) -> NGLStyleLayer {
        let symbol = NGLSymbolStyleLayer(identifier: identifier, source: source)
        
        symbol.text = NSExpression(format: "CAST(name, 'NSString')")
        symbol.textOpacity = NSExpression(forConditional: NSPredicate(format: "waypointCompleted == true"), trueExpression: NSExpression(forConstantValue: 0.5), falseExpression: NSExpression(forConstantValue: 1))
        symbol.textFontSize = NSExpression(forConstantValue: 10)
        symbol.textHaloWidth = NSExpression(forConstantValue: 0.25)
        symbol.textHaloColor = NSExpression(forConstantValue: UIColor.blue)
        
        return symbol
    }
    
}

extension CustomWaypointStylingViewController: NavigationMapViewDelegate {
    
    func navigationMapView(_ mapView: NavigationMapView, waypointStyleLayerWithIdentifier identifier: String, source: NGLSource) -> NGLStyleLayer? {
        return customWaypointCircleStyleLayer(identifier: identifier, source: source)
    }
    
    func navigationMapView(_ mapView: NavigationMapView, waypointSymbolStyleLayerWithIdentifier identifier: String, source: NGLSource) -> NGLStyleLayer? {
        return customWaypointSymbolStyleLayer(identifier: identifier, source: source)
    }
    
    func navigationMapView(_ mapView: NavigationMapView, shapeFor waypoints: [Waypoint], legIndex: Int) -> NGLShape? {
        return customShape(for: waypoints, legIndex: legIndex)
    }
}

extension CustomWaypointStylingViewController: NavigationViewControllerDelegate {
    func navigationViewController(_ navigationViewController: NavigationViewController, waypointStyleLayerWithIdentifier identifier: String, source: NGLSource) -> NGLStyleLayer? {
        return customWaypointCircleStyleLayer(identifier: identifier, source: source)
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, waypointSymbolStyleLayerWithIdentifier identifier: String, source: NGLSource) -> NGLStyleLayer? {
        return customWaypointSymbolStyleLayer(identifier: identifier, source: source)
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, shapeFor waypoints: [Waypoint], legIndex: Int) -> NGLShape? {
        return customShape(for: waypoints, legIndex: legIndex)
    }
    
}
