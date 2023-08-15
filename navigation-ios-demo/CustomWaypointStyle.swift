//
//  CustomWaypointStyle.swift
//  navigation-ios-demo
//
//  Created by lihongjun on 2023/8/15.
//

import Foundation
import UIKit

class CustomWaypointStyle : UIView {
    
    private let circleColor: UIColor = .red
    private let labelText: String
    
    init(frame: CGRect, labelText: String) {
        self.labelText = labelText
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCircularLayout()
    }
    
    private func setupCircularLayout() {
        // Create a circular path
        let circularPath = UIBezierPath(ovalIn: bounds)
        
        // Create a shape layer for the circle
        let circleLayer = CAShapeLayer()
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = circleColor.cgColor
        
        // Add the circle layer to the view's layer
        layer.addSublayer(circleLayer)
        
        // Add a label inside the circle
        let label = UILabel(frame: bounds)
        label.text = labelText
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
    }
    
    func captureScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        let image =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
