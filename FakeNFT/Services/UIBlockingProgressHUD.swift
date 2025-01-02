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
        ProgressHUD.animationType = .none
        ProgressHUD.colorHUD = Asset.ypBlack.color
        ProgressHUD.colorAnimation = .lightGray
    }

    static func show() {
        window?.isUserInteractionEnabled = false
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
    }

    static func status() -> Bool {
        guard let window = window else { return false }
        return window.isUserInteractionEnabled
    }
}
