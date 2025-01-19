//
//  UIImage+Image.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 26.12.2024.
//

import Foundation


import UIKit

extension UIImage {
    static func from(color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
