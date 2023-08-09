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
import NbmapDirections

class ArriveNavigationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let waypoint = CLLocation(latitude: 37.77640680146262, longitude: -122.43939772352648)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
       
        let options = NavigationRouteOptions(waypoints: [Waypoint(location: origin),Waypoint(location: waypoint),Waypoint(location: destination)], profile: .mode4W)
       
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
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool{
        print("didArriveAt : \(waypoint.description)")
        // When the user arrives, present a view controller that prompts the user to continue to their next destination
        // This type of screen could show information about a destination, pickup/dropoff confirmation, instructions upon arrival, etc.
        
        //Arrived destination , If we're not in a "Multiple Stops" demo, show the normal EORVC
        if navigationViewController.navigationService.router.routeProgress.isFinalLeg {
            return true
        }
        
        guard let confirmationController = self.storyboard?.instantiateViewController(withIdentifier: "waypointConfirmation") as? WaypointConfirmationViewController else {
            return true
        }
        
        confirmationController.delegate = self
        
        navigationViewController.present(confirmationController, animated: true, completion: nil)
        return false
    }
}

// MARK: WaypointConfirmationViewControllerDelegate
extension ArriveNavigationViewController: WaypointConfirmationViewControllerDelegate {
    func confirmationControllerDidConfirm(_ confirmationController: WaypointConfirmationViewController) {
        confirmationController.dismiss(animated: true, completion: {
            guard let navigationViewController = self.presentedViewController as? NavigationViewController else { return }
            
            guard navigationViewController.navigationService.router.routeProgress.route.legs.count > navigationViewController.navigationService.router.routeProgress.legIndex + 1 else { return }
            navigationViewController.navigationService.router.routeProgress.legIndex += 1
            navigationViewController.navigationService.start()  // todo qiu need to comfirm
        })
    }
}
