//
//  ShadowButton.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 9/28/20.
//

import SwiftUI
import UIKit

class ShadowButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = false
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
        
        layer.shadowRadius = 2
        layer.shadowColor = (UIColor(named: "Black") ?? UIColor.black).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
    }
}


