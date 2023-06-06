import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import NbmapDirections
import Nbmap

class CustomCameraController: UIViewController, NGLMapViewDelegate, NavigationViewControllerDelegate {
    
    var mapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let mapView = mapView {
                view.insertSubview(mapView, at: 0)
            }
        }
    }
    
    var routes : [Route]? {
        didSet {
            guard let routes = routes,
                  let current = routes.first
            else {
                mapView?.removeRoutes()
                mapView?.removeRouteDurationSymbol()
                if let annotation = mapView?.annotations?.last {
                    mapView?.removeAnnotation(annotation)
                }
                return
                
            }
            
            mapView?.showRoutes(routes)
            mapView?.showWaypoints(current)
            mapView?.showRouteDurationSymbol(routes)
            
            fitCameraWithRoutes(routes: routes)
        }
    }
    
    var startButton = UIButton()
    
    var trackingImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView = NavigationMapView(frame: view.bounds)
        
        mapView?.userTrackingMode = .followWithHeading
        
        let singleTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        mapView?.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(singleTap.require(toFail:))
        mapView?.addGestureRecognizer(singleTap)
        mapView?.delegate = self
        
        setupStartButton()
        setupLocationTrackingButton()
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
    
    func setupLocationTrackingButton(){
        trackingImage.isUserInteractionEnabled = true
        trackingImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trackingClick)))
        trackingImage.image = UIImage(named: "my_location")
        view.addSubview(trackingImage)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
    }
    
    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let mapView = mapView, tap.state == .began else {
            return
        }
        let coordinates = mapView.convert(tap.location(in: mapView), toCoordinateFrom: mapView)
        let destination = Waypoint(coordinate: coordinates, name: "\(coordinates.latitude),\(coordinates.longitude)")
        
        guard let currentLocation =  mapView.userLocation?.coordinate else { return}
        let currentWayPoint = Waypoint.init(coordinate: currentLocation, name: "My Location")
        
        requestRoutes(origin: currentWayPoint, destination: destination)
    }
    
    
    @objc func tappedButton(sender: UIButton) {
        guard let routes = self.routes else {
            return
        }
        var engineConfig = NavigationEngineConfig()
        // Config mininum and maxnum camera zoom
        engineConfig.minNavigationCameraZoom = 16
        engineConfig.maxNavigationCameraZoom = 18
        let navigationService = NBNavigationService(routes: routes, routeIndex: 0,navigationEngConfig: engineConfig)
        
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        navigationViewController.delegate = self
        
        // Start navigation
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func trackingClick() {
        guard let location = mapView?.userLocation else {
            return
        }
        guard let newCamera = mapView?.camera else {
            return
        }
        newCamera.centerCoordinate = location.coordinate
        newCamera.viewingDistance = 1000
        mapView?.setCamera(newCamera, animated: true)
    }
    
    func fitCameraWithRoutes(routes: [Route]) {
        guard let mapView = mapView else {
            return
        }
        
        var coordinates: [CLLocationCoordinate2D] = []
        routes.forEach({route in
            coordinates.append(contentsOf: route.coordinates!)
        })
        let polyLine = NGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        let camera = mapView.cameraThatFitsShape(polyLine, direction: mapView.camera.heading, edgePadding: UIEdgeInsets(top: view.safeAreaInsets.top, left: view.safeAreaInsets.left, bottom: view.safeAreaInsets.bottom, right: view.safeAreaInsets.right))
        mapView.setCamera(camera, animated: true)
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
            weakSelf.routes = routes
        }
    }
    
}
