import UIKit
import NbmapNavigation
import NbmapCoreNavigation

class SimulationNavigationViewController: UIViewController {
    
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
             A setting of `.always` will simulate route progress at all times.
             */
            /**
             * routes：Initialize  NBNavigationService with the fetched routes,
             * routeIndex：Set routeIndex of the primary route to 0 .
             * simulating：Set the navigation mode. The default is `SimulationMode.inTunnels` if this parameter is not set or set to nil
             *  Set the navigation to simulated navigation mode. If the simulating parameter is set to SimulationMode.always , the navigation mode is switch to simulation mode .
             *  If simulating parameter is set to `SimulationMode.inTunnels ` , the simulating navigation mode is enabled after entering the tunnel and the simulating navigation mode is terminated after exiting the tunnel.
             *  If the simulation is set to  `SimulationMode.onPoorGPS`  , the navigation will enter simulated navigation mode after losing GPS signal, and will end simulated navigation mode after regaining GPS signal
             *  If the simulation is set to  `SimulationMode.never`  ,the navigation will never switch to simulation navigation mode under any circumstances
             */
            let navigationService = NBNavigationService(routes: routes, routeIndex: 0,simulating : SimulationMode.always)
            
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            
            // Initialize the NavigationViewController
            let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
            
            // Set the delegate of navigationViewController to subscribe for NavigationView’s events, This is optional
            navigationViewController.modalPresentationStyle = .fullScreen
            
            // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
            navigationViewController.routeLineTracksTraversal = true
            
            // Start navigation
            strongSelf.present(navigationViewController, animated: true, completion: nil)
        }
        
    }
    
}

