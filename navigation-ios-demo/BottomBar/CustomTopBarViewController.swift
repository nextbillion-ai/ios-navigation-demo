
import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import NbmapDirections

// MARK: - CustomTopBarViewController
 
class CustomTopBarViewController: ContainerViewController {
    var navigationDataEventTracking: NbmapCoreNavigation.NavigationEventTracking?
    
private lazy var instructionsBannerTopOffsetConstraint = {
return instructionsBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
}()
private lazy var centerOffset: CGFloat = calculateCenterOffset(with: view.bounds.size)
private lazy var instructionsBannerCenterOffsetConstraint = {
return instructionsBannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
}()
private lazy var instructionsBannerWidthConstraint = {
return instructionsBannerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
}()
 
// You can Include one of the existing Views to display route-specific info
lazy var instructionsBannerView: InstructionsBannerView = {
let banner = InstructionsBannerView()
banner.translatesAutoresizingMaskIntoConstraints = false
banner.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
banner.layer.cornerRadius = 25
banner.layer.opacity = 0.75
return banner
}()
 
override func viewDidLoad() {
view.addSubview(instructionsBannerView)
 
setupConstraints()
}
 
override func viewWillAppear(_ animated: Bool) {
super.viewWillAppear(animated)
 
updateConstraints()
}
 
private func setupConstraints() {
instructionsBannerCenterOffsetConstraint.isActive = true
instructionsBannerTopOffsetConstraint.isActive = true
instructionsBannerWidthConstraint.isActive = true
}
 
private func updateConstraints() {
instructionsBannerCenterOffsetConstraint.constant = centerOffset
}
 
// MARK: - Device rotation
 
private func calculateCenterOffset(with size: CGSize) -> CGFloat {
return (size.height < size.width ? -size.width / 5 : 0)
}
 
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
super.viewWillTransition(to: size, with: coordinator)
centerOffset = calculateCenterOffset(with: size)
}
 
open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
super.traitCollectionDidChange(previousTraitCollection)
updateConstraints()
}
 
// MARK: - NavigationServiceDelegate implementation
 
public func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
// pass updated data to sub-views which also implement `NavigationServiceDelegate`
instructionsBannerView.updateDistance(for: progress.currentLegProgress.currentStepProgress)
}
 
public func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
instructionsBannerView.update(for: instruction)
}
 
public func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
instructionsBannerView.updateDistance(for: service.routeProgress.currentLegProgress.currentStepProgress)
}
}
