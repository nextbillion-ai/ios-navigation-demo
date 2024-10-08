import UIKit
import NbmapNavigation
import NbmapCoreNavigation

// MARK: - CustomBottomBarViewController
 
class CustomBottomBarViewController: ContainerViewController, CustomBottomBannerViewDelegate {
    var navigationDataEventTracking: NbmapCoreNavigation.NavigationEventTracking?
    
 
    weak var navigationViewController: NavigationViewController?
 
    // Or you can implement your own UI elements
    lazy var bannerView: CustomBottomBannerView = {
    let banner = CustomBottomBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.delegate = self
        return banner
    }()
     
    override func loadView() {
        super.loadView()
     
        view.addSubview(bannerView)
     
        let safeArea = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
        bannerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
        bannerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        bannerView.heightAnchor.constraint(equalTo: view.heightAnchor),
        bannerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
    }
     
    private func setupConstraints() {
            if let superview = view.superview?.superview {
                view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
            }
    }
     
    // MARK: - NavigationServiceDelegate implementation
     
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        // Update your controls manually
        bannerView.progress = Float(progress.fractionTraveled)
        bannerView.eta = "~\(Int(round(progress.durationRemaining / 60))) min"
    }
     
    // MARK: - CustomBottomBannerViewDelegate implementation
     
    func customBottomBannerDidCancel(_ banner: CustomBottomBannerView) {
        navigationViewController?.dismiss(animated: true,
                                          completion: nil)
    }
}
