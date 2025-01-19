//
//  ShimmerCollectionViewCell.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import UIKit

final class ShimmerCollectionViewCell: UICollectionViewCell, ReuseIdentifying {
    private let shimmerView = ShimmerView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(shimmerView)
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        shimmerView.constraintEdges(to: contentView)
        shimmerView.applyCornerRadius(.small12)
        shimmerView.startShimmer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
