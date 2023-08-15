//
//  CustomizeWaypointSymbolLayer.swift
//  navigation-ios-demo
//
//  Created by lihongjun on 2023/8/14.
//
import UIKit
import Foundation

class CustomizeWaypointSymbol : UIView{
    
    var indexLabel: UILabel
    var view: UIView
    
    init(wayPointIndex: Int) {
        self.view = UIView(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
        self.indexLabel = UILabel(frame: CGRect())
        super.init(frame: CGRect())
        
        self.view.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1.0)
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.cornerRadius = view.frame.width / 2
        self.addSubview(self.view)
        
        self.indexLabel.textColor = UIColor.white
        indexLabel.frame.size = CGSize(width: 24, height: 24)
        indexLabel.font = UIFont.systemFont(ofSize: 12)
        indexLabel.text = "\(wayPointIndex)"
        indexLabel.textAlignment = .center
        self.view.addSubview(indexLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func screenshotImage() -> UIImage? {
        guard self.view.frame.size.height > 0 && self.view.frame.size.width > 0 else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, UIScreen.main.scale)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
