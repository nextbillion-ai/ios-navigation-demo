//
//  MainViewController.swift
//  navigation-ios-demo
//
//  Created by qiu on 2023/4/18.
//


import UIKit

class MainViewController : UITableViewController {
    
    let examples = [
        ViewMode(name: "Basic navigation app", viewCongtroller: BasicNavigationViewController.self),
        ViewMode(name: "Advanced navigation app", viewCongtroller: AdvancedNavigationViewController.self),
        ViewMode(name: "Bring your own route with routing provider", viewCongtroller: CustomRouteNavigationController.self),
        ViewMode(name: "Show Route line on Map", viewCongtroller: DrawRouteLineViewController.self),
        ViewMode(name: "Show Alternative Route line on Map", viewCongtroller: DrawAlternativeRouteController.self),
        ViewMode(name: "Intercept Map click and long click events", viewCongtroller: InterceptClickEventViewController.self),
        ViewMode(name: "Route Initialization", viewCongtroller: RouteInitializationViewController.self),
        ViewMode(name: "Route deserializa", viewCongtroller: RouteDeserializationViewController.self),
        ViewMode(name: "Custom banners", viewCongtroller: CustomBannersViewController.self),
        ViewMode(name: "Custom destination marker", viewCongtroller: CustomDestinationMarkerController.self),
        ViewMode(name: "Custom location indicator", viewCongtroller: CustomLocationViewController.self),
        ViewMode(name: "Custom navigation camera", viewCongtroller: CustomCameraController.self),
        ViewMode(name: "Custom voice controller", viewCongtroller: CustomVoiceInstructionController.self),
        ViewMode(name: "Custom waypoint styling", viewCongtroller: CustomWaypointStylingViewController.self),
        ViewMode(name: "Custom Navigation maps tyle", viewCongtroller: CustomizeMapStyleViewController.self),
        ViewMode(name: "Route Line Styling", viewCongtroller: RouteLinesStylingViewController.self),
        ViewMode(name: "Custom Location Source", viewCongtroller: CustomLocationSourceViewController.self),
        ViewMode(name: "Custom UI Elements", viewCongtroller: CustomUIElementsViewController.self),
        ViewMode(name: "Custom Waypoint screen", viewCongtroller: CustomWaypointScreenController.self),
        ViewMode(name: "Simulation mode", viewCongtroller: SimulationNavigationViewController.self),
        
        
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Examples"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.examples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = self.examples[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewMode = self.examples[indexPath.row]
        let detailViewController = viewMode.viewCongtroller.init()
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
