//
//  RetriveNavigationProgressViewController.swift
//  navigation-ios-demo
//
//  Created by qiu on 2024/11/5.
//

import UIKit
import NbmapNavigation
import NbmapCoreNavigation

class NavigationDelegatesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
        let options = NavigationRouteOptions(origin: origin, destination: destination)
        Directions.shared.calculate(options) { [weak self] routes, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let routes = routes else { return }
            
            /**
             Initialize the `NBNavigationService`  with fetched routes , and set the default index to 0 . If `simulationIsEnabled` is `true`  , Set the navigation to simulation mode, otherwise only use simulation navigation mode in tunnels.
             */
            let navigationService = NBNavigationService(routes: routes, routeIndex: 0, simulating: simulationIsEnabled ? SimulationMode.always : SimulationMode.inTunnels)
            
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            
            // Initialize the NavigationViewController
            let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
            
            navigationViewController.modalPresentationStyle = .fullScreen
            
            // Set the delegate of navigationViewController to subscribe for NavigationView’s events
            
            navigationViewController.delegate = self
            // Start navigation
            strongSelf.present(navigationViewController, animated: true, completion: nil)
        }
        
    }
    
}

extension NavigationDelegatesViewController: NavigationViewControllerDelegate {
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        // Get data when progress update
        let durationRemaining = progress.durationRemaining
        let distanceRemaining = progress.distanceRemaining
        let lineSyting = progress.route.shape
        let speed = location.speed
        let bearing = location.course
        let coordinate = location.coordinate
        print("durationRemaining :\(durationRemaining)")
        print("distanceRemaining :\(distanceRemaining)")
        print("speed :\(speed)")
        print("bearing :\(bearing)")
        print("durationRemaining :\(durationRemaining)")
        print("coordinate :\(coordinate)")
    }
}
