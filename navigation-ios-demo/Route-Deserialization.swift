

import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import NbmapDirections
import Foundation


typealias JSONDictionary = [String: Any]

class RouteDeserializationViewController: UIViewController {
    
    // MARK: - UIViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin = CLLocationCoordinate2DMake(37.776818, -122.399076)
        let destination = CLLocationCoordinate2DMake(37.777407, -122.399814)
        let routeOptions = NavigationRouteOptions(coordinates: [origin, destination])
        
        // Load previously serialized Route object in JSON format and deserialize it.
        let routeData = JSONFromFileNamed(name: "route")
        var json: JSONDictionary = [:]
        do {
            json = try JSONSerialization.jsonObject(with: routeData, options: []) as! JSONDictionary
        } catch {
            assert(false, "Invalid data")
        }
        let route = Route(json: json, waypoints: routeOptions.waypoints, options: routeOptions, countryCode: nil)
        /**
         Initialize the `NBNavigationService`  with fetched routes , and set the default index to 0 . If `simulationIsEnabled` is `true`  , Set the navigation to simulation mode, otherwise only use simulation navigation mode in tunnels.
         */
        let navigationService = NBNavigationService(routes: [route], routeIndex: 0,simulating: simulationIsEnabled ? SimulationMode.always : SimulationMode.inTunnels)
        
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        
        let navigationViewController = NavigationViewController(for: [route],navigationOptions: navigationOptions)
        
        navigationViewController.modalPresentationStyle = .fullScreen
        
        navigationViewController.routeLineTracksTraversal = true
        present(navigationViewController, animated: true, completion: nil)
        
    }
    
    // MARK: - Utility methods
    
    private func JSONFromFileNamed(name: String) -> Data {
        
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            preconditionFailure("File \(name) not found.")
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            preconditionFailure("No data found at \(path).")
        }
        
        return data
    }
}
