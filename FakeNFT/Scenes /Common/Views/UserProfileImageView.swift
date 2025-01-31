//
//  UserProfileImageView.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Kingfisher
import UIKit

enum ProfileImageMode {
    case view
    case edit

    var placeholder: UIImage {
        return UIImage(named: "profile") ?? UIImage()
    }
}

final class UserProfileImageView: UIView {

    // MARK: - Private Properties

    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .ypGreyUniversal
        return imageView
    }()

    private lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizationKey.profChangeImage.localized(), for: .normal)
        button.titleLabel?.font = .medium10
        button.clipsToBounds = true
        button.backgroundColor = .black.withAlphaComponent(0.2)
        button.tintColor = .white
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.isHidden = true
        return button
    }()

    private var mode: ProfileImageMode = .view {
        didSet {
            updatePlaceholder()
            changePhotoButton.isHidden = mode == .view
        }
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

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.applyCornerRadius(userImageView.frame.width / 2)
        changePhotoButton.applyCornerRadius(changePhotoButton.frame.width / 2)
    }
}

// MARK: - Configure view

extension UserProfileImageView {

    // MARK: - Public Methods

    func setProfile(_ profile: Profile?, mode: ProfileImageMode) {
        self.mode = mode
        if let profile, let avatarURLString = profile.avatar, let avatarURL = URL(string: avatarURLString) {
            updateUserProfileImage(with: avatarURL) { [weak self] image in
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

    func addChangePhotoButtonTarget(_ target: Any?, action: Selector) {
        changePhotoButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

// MARK: - Private Methods

extension UserProfileImageView {
    private func updateUserProfileImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        userImageView.kf.indicatorType = .activity
        userImageView.kf.setImage(
            with: url,
            placeholder: mode.placeholder,
            options: [.transition(.fade(0.2))]
        ) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                Logger.shared.error("Ошибка загрузки изображения профиля \(error.localizedDescription)")
                self.updatePlaceholder()
                completion(nil)
            }
        }
    }

    private func updatePlaceholder() {
        userImageView.image = mode.placeholder
        userImageView.contentMode = .scaleAspectFill
        userImageView.tintColor = .ypGreyUniversal
    }
}

// MARK: - Layout

extension UserProfileImageView {
    private func setupUI() {
        [userImageView, changePhotoButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            setupView($0)
        }
        userImageView.constraintEdges(to: self)
        changePhotoButton.constraintEdges(to: userImageView)
    }
}
