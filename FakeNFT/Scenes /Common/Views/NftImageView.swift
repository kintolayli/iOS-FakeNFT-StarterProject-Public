//
//  NftImageView.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Kingfisher
import UIKit

final class NftImageView: UIView {

    // MARK: - Private Properties

    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .ypGreyUniversal
        return imageView
    }()

    private var placeholder: UIImage {
        return UIImage(named: "NFTcard") ?? UIImage()
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Configure view

extension NftImageView {

    // MARK: - Public Methods

    func setNftImage(from url: String?) {
        if let avatarURLString = url, let avatarURL = URL(string: avatarURLString) {
            updateNftImage(with: avatarURL) { [weak self] image in
                if image != nil {
                    self?.userImageView.tintColor = nil
                } else {
                    self?.updatePlaceholder()
                }
            }
        } else {
            updatePlaceholder()
        }
    }
}

// MARK: - Private Methods

extension NftImageView {
    private func updateNftImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        userImageView.kf.indicatorType = .activity
        userImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        ) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure:
                Logger.shared.error("Ошибка загрузки изображения профиля")
                self.updatePlaceholder()
                completion(nil)
            }
        }
    }

    private func updatePlaceholder() {
        userImageView.image = placeholder
        userImageView.contentMode = .scaleAspectFill
        userImageView.tintColor = .ypGreyUniversal
    }
}

// MARK: - Layout

extension NftImageView {
    private func setupUI() {
        [userImageView].forEach {
            setupView($0)
        }
        userImageView.constraintEdges(to: self)
    }
}
