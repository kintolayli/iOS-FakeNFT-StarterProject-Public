//
//  AlertActionModel.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 24.12.2024.
//

import UIKit

struct AlertActionModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}
