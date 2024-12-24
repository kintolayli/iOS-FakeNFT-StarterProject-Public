//
//  MyNftHelper.swift
//  FakeNFT
//
//  Created by  Admin on 19.12.2024.
//

import UIKit

final class MyNftHelper {

    // MARK: - Shimmer Methods

    func createShimmerView() -> UIView {
        let shimmerContainer = UIView()
        let shimmerView = ShimmerView()

        shimmerView.applyCornerRadius(.medium16)
        shimmerContainer.addSubview(shimmerView)

        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shimmerView.topAnchor.constraint(equalTo: shimmerContainer.topAnchor, constant: UIConstants.Insets.small8),
            shimmerView.bottomAnchor.constraint(equalTo: shimmerContainer.bottomAnchor, constant: -UIConstants.Insets.small8),
            shimmerView.leadingAnchor.constraint(equalTo: shimmerContainer.leadingAnchor, constant: UIConstants.Insets.medium16),
            shimmerView.trailingAnchor.constraint(equalTo: shimmerContainer.trailingAnchor, constant: -UIConstants.Insets.medium16),
            shimmerView.heightAnchor.constraint(equalToConstant: UIConstants.Heights.height108)
        ])

        shimmerView.startShimmer()
        return shimmerContainer
    }

    func createShimmerViews(count: Int) -> [ShimmerView] {
        var views = [ShimmerView]()
        for _ in 0..<count {
            let shimmerView = ShimmerView()
            views.append(shimmerView)
        }
        return views
    }

    // MARK: - Error Handling

    func presentError(on viewController: UIViewController, message: String, retryHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: LocalizationKey.errorTitle.localized(),
                                                message: message,
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: LocalizationKey.errorRepeat.localized(),
                                        style: .default) { _ in
            retryHandler()
        }
        let cancelAction = UIAlertAction(title: LocalizationKey.actionClose.localized(),
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
