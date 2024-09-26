//
//  Arrive-Waypoints-Destination.swift
//  navigation-ios-demo
//
//  Created by qiu on 2023/8/9.
//

import Foundation


import UIKit
import NbmapNavigation
import NbmapCoreNavigation

class ArriveNavigationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let waypoint = CLLocation(latitude: 37.77640680146262, longitude: -122.43939772352648)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
       
        let options = NavigationRouteOptions(waypoints: [Waypoint(location: origin),Waypoint(location: waypoint),Waypoint(location: destination)], profile: .car)
       
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
            // Set the delegate to receive call back
            navigationViewController.delegate = self
            // Set the delegate of navigationViewController to subscribe for NavigationView’s events, This is optional
            navigationViewController.modalPresentationStyle = .fullScreen
            
            
            // Start navigation
            strongSelf.present(navigationViewController, animated: true, completion: nil)
        }
        
    }
    
}

extension ArriveNavigationViewController : NavigationViewControllerDelegate {
    
    /**
     Call back for user arrvive each waypoints and dextination
     */
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) {
      
        let alert = UIAlertController(title: "Arrived at \(waypoint.name ?? "Unknown").", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        navigationViewController.present(alert, animated: true, completion: nil)

    }
    
    /**
     Call back for user on tap the exit button
     */
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

