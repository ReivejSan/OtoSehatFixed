//
//  UIViewExtension.swift
//  OtoSehatFixed
//
//  Created by Jevier Izza Maulana on 12/04/22.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius}
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
