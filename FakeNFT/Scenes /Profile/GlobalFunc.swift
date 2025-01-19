//
//  GlobalFunc.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import UIKit

public func dismissKeyboard(view: UIView) {
    let tapGesture = UITapGestureRecognizer(
        target: view,
        action: #selector(UIView.endEditing(_:))
    )
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
}
