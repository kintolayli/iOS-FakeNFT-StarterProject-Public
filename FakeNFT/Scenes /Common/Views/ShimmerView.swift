//
//  ShimmerView.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 26.12.2024.
//

import UIKit

class ShimmerView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }

    private func setupGradientLayer() {
        gradientLayer.colors = [
            UIColor.segmentInactive,
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.segmentInactive
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.backgroundColor = UIColor.segmentInactive.cgColor
        let cornerRadius = frame.height > 24 ? 12 : frame.height / 2
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }

    func startShimmering() {
        let shimmerAnimation = CABasicAnimation(keyPath: "locations")
        shimmerAnimation.fromValue = [0.0, 0.5, 0.0]
        shimmerAnimation.toValue = [0.5, 1.0, 0.5]
        shimmerAnimation.duration = 2.0
        shimmerAnimation.repeatCount = .infinity
        shimmerAnimation.autoreverses = true
        shimmerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(shimmerAnimation, forKey: "shimmerAnimation")
    }

    func stopShimmering() {
        gradientLayer.removeAnimation(forKey: "shimmerAnimation")
    }
}
