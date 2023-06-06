import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import NbmapDirections
import Turf

class RouteInitializationViewController: UIViewController {
    
    // MARK: - UIViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.776818, -122.399076)
        let destination: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.777407, -122.399814)
        let distance: CLLocationDistance = 92.2
        let expectedTravelTime: TimeInterval = 24.6
        let routeCoordinates = [origin, destination]
        let distanceAlongArrivalStep = 18.7
        
        // Add two spoken instructions about an upcoming maneuver.
        let departureSpokenInstruction = SpokenInstruction(distanceAlongStep: distance,
                                                           text: "Head northwest on 5th Street, then you have arrived at your destination",
                                                           ssmlText: "", unit: .meters)
        let arrivalSpokenInstruction = SpokenInstruction(distanceAlongStep: distanceAlongArrivalStep,
                                                         text: "You have arrived at your destination",
                                                         ssmlText: "", unit: .meters)
        
        // Add two instruction banners which give visual cue about a given `RouteStep`.
        let departureVisualInstructionBanner = createVisualInstructionBanner(text: "You will arrive",
                                                                             distanceAlongStep: distance)
        let arrivalVisualInstructionBanner = createVisualInstructionBanner(text: "You have arrived",
                                                                           distanceAlongStep: distanceAlongArrivalStep)
        
        let departureStepCoordinates = [
            origin,
            CLLocationCoordinate2D(latitude: 37.777368, longitude: -122.399767),
            destination
        ]
        let routeOptions = NavigationRouteOptions(coordinates: routeCoordinates)
        
        let departureStep = createRouteStep(maneuverLocation: origin,
                                            maneuverType: .depart,
                                            instructions: "Head northwest on 5th Street",
                                            distance: distance,
                                            expectedTravelTime: expectedTravelTime,
                                            instructionsSpokenAlongStep: [departureSpokenInstruction, arrivalSpokenInstruction],
                                            instructionsDisplayedAlongStep: [departureVisualInstructionBanner, arrivalVisualInstructionBanner], stepCoordinates: departureStepCoordinates)
        
        let arrivalStep = createRouteStep(maneuverLocation: destination,
                                          maneuverType: .arrive,
                                          instructions: "You have arrived at your destination",
                                          distance: 0,
                                          expectedTravelTime: 0, stepCoordinates: [destination])
        
        let routeLeg = RouteLeg(steps: [departureStep, arrivalStep],
                                name: "5th Street",
                                distance: distance,
                                expectedTravelTime: expectedTravelTime,
                                source: routeOptions.waypoints.first!,
                                destination: routeOptions.waypoints.last!,
                                profileIdentifier: routeOptions.profileIdentifier,
                                segmentDistances: [],
                                expectedSegmentTravelTimes: [
                                    20.6,
                                    2,
                                    1.1,
                                    0.9
                                ],
                                segmentSpeeds: [],
                                congestionLevels: [
                                    .heavy,
                                    .low,
                                    .low,
                                    .moderate
                                ])
        
        let route = Route(json: nil, legs: [routeLeg], distance: distance ,expectedTravelTime: expectedTravelTime,coordinates: departureStepCoordinates ,speechLocale:Locale.current,options:routeOptions)
        /**
         Initialize the `NBNavigationService`  with fetched routes , and set the default index to 0 . If `simulationIsEnabled` is `true`  , Set the navigation to simulation mode, otherwise only use simulation navigation mode in tunnels.
         */
        let navigationService = NBNavigationService(routes: [route], routeIndex: 0, simulating: simulationIsEnabled ? SimulationMode.always : SimulationMode.inTunnels)
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: [route],navigationOptions: navigationOptions)
        
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    // MARK: - Utility methods
    
    private func createRouteStep(maneuverLocation: CLLocationCoordinate2D,
                                 maneuverType: ManeuverType,
                                 instructions: String,
                                 distance: CLLocationDistance,
                                 expectedTravelTime: TimeInterval,
                                 instructionsSpokenAlongStep: [SpokenInstruction]? = nil,
                                 instructionsDisplayedAlongStep: [VisualInstructionBanner]? = nil,
                                 stepCoordinates: [CLLocationCoordinate2D]?) -> RouteStep {
        
        
        
        let routeStep = RouteStep(transportType: .automobile,
                                  maneuverType: maneuverType,
                                  maneuverDirection: .straightAhead,
                                  maneuverLocation: maneuverLocation,
                                  exitIndex: 0,
                                  instructions: instructions,
                                  stepCoordinates: stepCoordinates,
                                  initialHeading: 0.0,
                                  finalHeading: 0.0,
                                  startLocation: nil,
                                  endLocation: nil,
                                  drivingSide: .left,
                                  exitCodes: [],
                                  exitNames: [],
                                  phoneticExitNames: [],
                                  distance: distance,
                                  expectedTravelTime: expectedTravelTime,
                                  names: [],
                                  phoneticNames: [],
                                  codes: [],
                                  destinationCodes: [],
                                  destinations: [],
                                  shiledImageUrl: nil,
                                  shiledLabel: nibName,
                                  intersections: [],
                                  instructionsSpokenAlongStep: instructionsSpokenAlongStep,
                                  instructionsDisplayedAlongStep: instructionsDisplayedAlongStep, muted: false)
        
        return routeStep
    }
    
    private func createVisualInstructionBanner(text: String, distanceAlongStep: CLLocationDistance) -> VisualInstructionBanner {
        
        let component = VisualInstructionComponent(type: VisualInstructionComponentType.text,text: text,imageURL:nil,label: nil,abbreviation: nil,abbreviationPriority:0)
        
        
        let visualInstruction = VisualInstruction(text: text,
                                                  instruction:nil,
                                                  maneuverType: .arrive,
                                                  maneuverDirection: .straightAhead,
                                                  components: [component],
                                                  degrees:180)
        
        let visualInstructionBanner = VisualInstructionBanner(distanceAlongStep: distanceAlongStep,
                                                              primaryInstruction: visualInstruction,
                                                              secondaryInstruction: nil,
                                                              tertiaryInstruction: nil,
                                                              drivingSide: .right)
        
        return visualInstructionBanner
    }
}

