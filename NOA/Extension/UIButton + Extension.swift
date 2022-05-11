//
//  UIButton + Extension.swift
//  NOA
//
//  Created by wi_seong on 2022/05/16.
//

import UIKit

extension UIButton {
    func applyBorderGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2
        
        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.frame.height/2).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.cornerRadius = self.frame.height/2
        gradientLayer.mask = shape

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        self.titleLabel?.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        self.titleLabel?.textColor = UIColor(red: 154, green: 173, blue: 224)
    }
    
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        self.titleLabel?.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        self.titleLabel?.textColor = UIColor.white
    }
}
