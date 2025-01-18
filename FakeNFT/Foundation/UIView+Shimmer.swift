//
//  UIView+Shimmer.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 26.12.2024.
//

import UIKit


extension UIView {
    func addShimmer() {
        let shimmer = ShimmerViewCatalog(frame: self.bounds)
        shimmer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(shimmer)
        shimmer.startShimmering()
    }

    func removeShimmer() {
        subviews.compactMap { $0 as? ShimmerViewCatalog }.forEach { $0.removeFromSuperview() }
    }
}
