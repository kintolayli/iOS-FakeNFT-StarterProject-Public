//
//  LikeButtonView.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import UIKit

final class LikeButtonView: UIView {

    // MARK: - Public Properties

    var onTap: (() -> Void)?

    var isSelected: Bool {
        get { button.isSelected }
        set { button.isSelected = newValue }
    }

    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "likeButton"
        button.tintColor = .ypLightGrey
        let heartImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        button.setImage(heartImage, for: .normal)
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public Methods

    func setImage(_ image: UIImage?, for state: UIControl.State) {
        button.setImage(image, for: state)
    }

    func setTintColor(_ color: UIColor) {
        button.tintColor = color
    }

    func setEnabled(_ isEnabled: Bool) {
        button.isEnabled = isEnabled
    }

    // MARK: - Setup

    private func setupView() {
        self.setupView(button)
        button.constraintEdges(to: self)
    }

    // MARK: - Actions

    @objc private func tapButton() {
        onTap?()
    }
}
