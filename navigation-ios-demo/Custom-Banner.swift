import UIKit
import NbmapNavigation
import NbmapCoreNavigation

class CustomBannersViewController: UIViewController {
    
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
            
            
            // Initialize  NBNavigationService with the fetched routes, set routeIndex of the primary route to 0
            let navigationService = NBNavigationService(routes: routes, routeIndex: 0)
            
            let topBanner = CustomTopBarViewController()
            let bottomBanner = CustomBottomBarViewController()
            let navigationOptions = NavigationOptions(navigationService: navigationService,topBanner: topBanner,bottomBanner:bottomBanner)
            
            // Initialize the NavigationViewController
            let navigationViewController = NavigationViewController(for: routes,navigationOptions: navigationOptions)
            
            bottomBanner.navigationViewController = navigationViewController
            
            let parentSafeArea = navigationViewController.view.safeAreaLayoutGuide
            let bannerHeight: CGFloat = 80.0
            let verticalOffset: CGFloat = 20.0
            let horizontalOffset: CGFloat = 10.0
            
            // To change top and bottom banner size and position change layout constraints directly.
            topBanner.view.topAnchor.constraint(equalTo: parentSafeArea.topAnchor).isActive = true
            
            bottomBanner.view.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
            bottomBanner.view.bottomAnchor.constraint(equalTo: parentSafeArea.bottomAnchor, constant: -verticalOffset).isActive = true
            bottomBanner.view.leadingAnchor.constraint(equalTo: parentSafeArea.leadingAnchor, constant: horizontalOffset).isActive = true
            bottomBanner.view.trailingAnchor.constraint(equalTo: parentSafeArea.trailingAnchor, constant: -horizontalOffset).isActive = true
            
            
            // Set the delegate of navigationViewController to subscribe for NavigationView’s events, This is optional
            navigationViewController.modalPresentationStyle = .fullScreen
            
            // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
            navigationViewController.routeLineTracksTraversal = true
            
            // Start navigation
            strongSelf.present(navigationViewController, animated: true, completion: nil)
        }
        
    }
    
}

