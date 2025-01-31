//
//  EditProfilePresenter.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

protocol EditProfilePresenterDelegate: AnyObject {
    func didUpdateProfile(_ profile: Profile)
}

protocol EditProfilePresenterProtocol: AnyObject {
    var view: EditProfileViewControllerProtocol? { get set }
    var sections: [SectionHeader] { get }
    var profile: Profile? { get set }

    func viewDidLoad()
    func tapCloseButton()
    func getSectionTitle(for section: Int) -> String?
    func openImagePicker()
    func getTextForSection(_ section: Int) -> String?
    func updateProfileData(text: String, for section: Int)
    func shouldShowFooter(for section: Int) -> Bool
    func saveProfileChanges()
    func getUpdatedProfile() -> Profile
}

final class EditProfilePresenter {

    // MARK: - Public Properties

    weak var view: EditProfileViewControllerProtocol?
    weak var delegate: EditProfilePresenterDelegate?
    var profile: Profile?
    var sections: [SectionHeader] = [
        .userPic,
        .name,
        .description,
        .webSite
    ]

    // MARK: - Private Properties

    private var isImageChanged = false
    private var profileBuilder: ProfileBuilder
    private let repository: EditProfileRepository

    // MARK: - Init

    init(
        profile: Profile?,
        repository: EditProfileRepository
    ) {
        self.profile = profile
        self.repository = repository
        if let profile {
            self.profileBuilder = ProfileBuilder(profile: profile)
        } else {
            self.profileBuilder = ProfileBuilder(profile: Profile())
        }
    }
}

// MARK: - EditProfilePresenterProtocol

extension EditProfilePresenter: EditProfilePresenterProtocol {

    // MARK: - Public Methods

    func viewDidLoad() {
        view?.updateSections()
    }

    func tapCloseButton() {
        saveProfileChanges()
    }

    func getSectionTitle(for section: Int) -> String? {
        return sections[section].title
    }

    func openImagePicker() {
        isImageChanged.toggle()
        view?.reloadSection(0)
    }

    func getUpdatedProfile() -> Profile {
        return profileBuilder.build()
    }

    func getTextForSection(_ section: Int) -> String? {
        switch sections[section] {
        case .userPic:
            return nil
        case .name:
            return profileBuilder.currentName
        case .description:
            return profileBuilder.currentDescription
        case .webSite:
            return profileBuilder.currentWebsite
        }
    }

    func updateProfileData(text: String, for section: Int) {
        switch sections[section] {
        case .userPic:
            profileBuilder = profileBuilder.setAvatar(text)
        case .name:
            profileBuilder = profileBuilder.setName(text)
        case .description:
            profileBuilder = profileBuilder.setDescription(text)
        case .webSite:
            profileBuilder = profileBuilder.setWebsite(text)
        }
    }

    func shouldShowFooter(for section: Int) -> Bool {
        return section == 0 && isImageChanged
    }
}

// MARK: - Saving Profile Data to Network

extension EditProfilePresenter {
    func saveProfileChanges() {
        let updatedProfile = profileBuilder.build()

        repository.saveProfileChanges(updatedProfile: updatedProfile) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.delegate?.didUpdateProfile(profile)
                self.view?.dismissView()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
}

// MARK: - Show Error

extension EditProfilePresenter {
    private func handleError(_ error: Error) {
        let errorMessage = (error as? CustomError)?.localizedDescription ?? LocalizationKey.errorUnknown.localized()

        let errorModel = ErrorModel(
            message: errorMessage,
            actionText: LocalizationKey.errorRepeat.localized(),
            action: { [weak self] in
                guard let self = self else { return }
                self.saveProfileChanges()
            }
        )

        if let view = self.view as? ErrorView {
            view.showError(errorModel)
        }
    }
}
