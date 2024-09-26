import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap


class CustomVoiceInstructionController: UIViewController , VoiceControllerDelegate {
    
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
            
            let routeVoiceController = RouteVoiceController()
            routeVoiceController.voiceControllerDelegate = self
            
            let navigationOptions = NavigationOptions(navigationService: navigationService,voiceController: routeVoiceController)
            
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
    
    func voiceController(_ voiceController: RouteVoiceController, willSpeak instruction: SpokenInstruction, routeProgress: RouteProgress) -> SpokenInstruction? {
        let modifiedInstruction = SpokenInstruction(distanceAlongStep: instruction.distanceAlongStep, text: instruction.text, ssmlText: instruction.ssmlText, unit: instruction.unit)
        return modifiedInstruction
    }
}

