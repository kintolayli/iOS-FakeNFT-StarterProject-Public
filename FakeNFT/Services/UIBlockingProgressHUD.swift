//
//  UIBlockingProgressHUD.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static func configure() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = Asset.ypBlack.color
        ProgressHUD.colorAnimation = .lightGray
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
