//
//  GradientAnimation.swift
//  ImageFeed
//
//  Created by Сегрей Баскаков on 12.05.2024.
//

import UIKit

final class GradientAnimation {
    static let shared = GradientAnimation()
    private init() {}
    
    private var animationLayers = [CALayer]()
    
    func addGradient(view: UIView, width: Double, height: Double, cornerRadius: Double) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        animationLayers.append(gradient)
        view.layer.addSublayer(gradient)
        addAnimation(gradient: gradient)
    }
    
    private func addAnimation(gradient: CAGradientLayer) {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func removeFromSuperLayer(views: [UIView]) {
        views.forEach { v in
            guard let sublayers = v.layer.sublayers else { return }
                sublayers.forEach { layer in
                for l in animationLayers {
                    if layer == l {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
}
