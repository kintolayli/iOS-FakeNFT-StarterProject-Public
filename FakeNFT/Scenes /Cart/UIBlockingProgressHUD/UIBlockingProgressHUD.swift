//
//  UIBlockingProgressHUD.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 28.12.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    static func show() {
        ProgressHUD.mediaSize = 25
        ProgressHUD.marginSize = 26
        ProgressHUD.show(interaction: false)
    }
    
    static func dismiss() {
        ProgressHUD.dismiss()
    }
}
