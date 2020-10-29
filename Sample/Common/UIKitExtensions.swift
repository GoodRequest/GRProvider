//
//  UIKitExtensions.swift
//  Example
//
//  Created by Dominik Pethö on 5/24/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

extension UIView {
    
    /// View corner radius. Don't forget to set clipsToBounds = true
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
}
