//
//  DrawRouteLineViewController.swift
//  navigation-ios-demo
//
//  Created by Jia on 15/5/23.
//

import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

class CustomizeMapStyleViewController: UIViewController, NGLMapViewDelegate {
    
    var changeStyleButton = UIButton()
    let mapStyleList = ["https://api.nextbillion.io/maps/streets/style.json", "https://api.nextbillion.io/maps/hybrid/style.json", "https://api.nextbillion.io/maps/dark/style.json"]
    var buttonClickCount = 0
    
    var navigationMapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let navigationMapView = navigationMapView {
                view.insertSubview(navigationMapView, at: 0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView?.userTrackingMode = .followWithHeading
        navigationMapView?.delegate = self
        
        setUpChangeStyleButton()
        
        self.view.setNeedsLayout()
    }
    
    func setUpChangeStyleButton(){
        changeStyleButton.setTitle("Switch", for: .normal)
        changeStyleButton.layer.cornerRadius = 5
        changeStyleButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        changeStyleButton.backgroundColor = .blue
        
        changeStyleButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        view.addSubview(changeStyleButton)
        changeStyleButton.translatesAutoresizingMaskIntoConstraints = false
        changeStyleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        changeStyleButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        changeStyleButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    }
    
    @objc func tappedButton(sender: UIButton) {
        buttonClickCount = (buttonClickCount + 1) % 3
        
        self.navigationMapView?.styleURL = URL(string: mapStyleList[buttonClickCount])
    }
}



