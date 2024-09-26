import UIKit
import NbmapNavigation
import NbmapCoreNavigation

class CustomRouteNavigationController: UIViewController , NGLMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
        let options = NavigationRouteOptions(origin: origin, destination: destination)
        
        let customRoutingProvider = CustomRoutingProvider()
        _ = customRoutingProvider.calculateRoutes(options: options) { [weak self] routes, error in
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
            let navigationService = NBNavigationService(routes: routes, routeIndex: 0,simulating: simulationIsEnabled ? SimulationMode.always : SimulationMode.inTunnels,routingProvider: customRoutingProvider)
            
            let navigationOptions = NavigationOptions(navigationService: navigationService)
            let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
            navigationViewController.modalPresentationStyle = .fullScreen
            strongSelf.present(navigationViewController, animated: true, completion: nil)
        }
        
    }
}

public struct CustomRequest: NavigationProviderRequest {
    /**
     Cancels the request if it is still active.
     */
    public func cancel() {
        dataTask.cancel()
    }
    
    var dataTask : URLSessionDataTask
}

class CustomRoutingProvider : RoutingProvider {
    func calculateRoutes(options: RouteOptions, completionHandler: @escaping Directions.RouteCompletionHandler) -> NbmapCoreNavigation.NavigationProviderRequest? {
        let task = Directions.shared.calculate(options, completionHandler: completionHandler)
        return CustomRequest(dataTask: task)
        
    }
    
}
