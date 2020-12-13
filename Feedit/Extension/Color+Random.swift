//
//  Color+Random.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

extension Color {
	static func random() -> Color {
		random(opacityRange: 1...1)
	}
	
	static func random(opacityRange rng: ClosedRange<Double>) -> Color {
		Color(UIColor.random(opacityLowerBound: CGFloat(rng.lowerBound),
							 opacityUpperBound: CGFloat(rng.upperBound)))
	}
}
