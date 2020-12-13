//
//  UIColor+.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

extension UIColor {
	static func random(opacityLowerBound lower: CGFloat, opacityUpperBound upper: CGFloat) -> UIColor {
		let opacityLower = max(min(lower,upper), 0)
		let opacityUpper = min(max(lower,upper), 1)
		
		
		let opacity: CGFloat = stride(from: opacityLower, to: opacityUpper, by: 0.01)
			.map { $0 }
			.shuffled()
			.randomElement() ?? (Bool.random() ? lower : upper)
		
		return random(opacity: opacity)
	}
	
	static func random(opacity: CGFloat = 1) -> UIColor {
		let getRand: () -> CGFloat = {
			return stride(from: 0.0, to: 1.0, by: 0.01)
				.map { $0 }
				.shuffled()
				.randomElement() ?? (Bool.random() ? 0 : 1)
		}
			
		return UIColor(red: getRand(), green: getRand(), blue: getRand(), alpha: opacity)
	}
	
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		return (red, green, blue, alpha)
	}
	
}

struct Prev: View {
	struct Components: Equatable {
		let r: CGFloat
		let g: CGFloat
		let b: CGFloat
		let a: CGFloat
		
		init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
			self.r = r
			self.g = g
			self.b = b
			self.a = a
		}
		init(_ rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)){
			self.r = rgba.red
			self.g = rgba.green
			self.b = rgba.blue
			self.a = rgba.alpha
		}
	}
	@State private var currentColor: Color? = nil
	@State private var currentRGBFloats: Components? = nil
	
	@State private var textInputR: String = ""
	@State private var textInputG: String = ""
	@State private var textInputB: String = ""
	@State private var textInputA: String = ""
	@State private var testColor: Color?
	
	var body: some View {
		VStack {
			VStack {
				Group {
					if currentRGBFloats != nil {
						Text("\(currentRGBFloats!.r), \(currentRGBFloats!.g), \(currentRGBFloats!.b), \(currentRGBFloats!.a)")
					}else {
						Text("N/A")
					}
				}
				.padding(.vertical, 50)
				Button("New Color") {
					let opacityVal: CGFloat = stride(from: 0.5, to: 1.0, by: 0.01).map({$0}).shuffled().randomElement() ?? (Bool.random() ? 0 : 1)
					let color = UIColor.random(opacity: opacityVal)
					currentRGBFloats = Prev.Components(color.rgba)
					currentColor = Color(color)
				}
			}
			.padding()
			.background(currentColor ?? Color(.systemBackground)).cornerRadius(8)
			Divider()
				.padding(.vertical)
			RoundedRectangle(cornerRadius: 8)
				.fill(testColor ?? .clear)
				.frame(maxHeight: 200)
				.padding(.horizontal)
			Group {
				HStack {
					Group {
					TextField("R", text: $textInputR, onCommit: {
						DispatchQueue.main.async {
							textInputR = textInputR.trimmingCharacters(in: .whitespacesAndNewlines)
						}
					})
					TextField("G", text: $textInputG, onCommit: {
						DispatchQueue.main.async {
							textInputG = textInputG.trimmingCharacters(in: .whitespacesAndNewlines)
						}
					})
					TextField("B", text: $textInputB, onCommit: {
						DispatchQueue.main.async {
							textInputB = textInputB.trimmingCharacters(in: .whitespacesAndNewlines)
						}
					})
					TextField("A", text: $textInputA, onCommit: {
						DispatchQueue.main.async {
							textInputA = textInputA.trimmingCharacters(in: .whitespacesAndNewlines)
						}
					})
					}
					.multilineTextAlignment(.center)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.aspectRatio(1, contentMode: .fit)
					.background(Color(.systemFill))
				}
				.padding(.vertical)
				Button("Test Color") {
					testColor = convertStringsToColor(textInputR, textInputG, textInputB, textInputA)
				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.accentColor))
				.disabled([textInputR, textInputG, textInputB, textInputA].contains(""))
			}
			.padding(.horizontal)
			.disabled(currentRGBFloats == nil)
			Spacer()
		}
		.onChange(of: currentRGBFloats, perform: { value in
			guard let val = value else { return }
			let formatter = NumberFormatter()
			formatter.maximumSignificantDigits = 3
			guard
				let r = formatter.string(from: val.r as NSNumber),
				let g = formatter.string(from: val.g as NSNumber),
				let b = formatter.string(from: val.b as NSNumber),
				let a = formatter.string(from: val.a as NSNumber)
			else { return }
			
			textInputR = r
			textInputG = g
			textInputB = b
			textInputA = a
			
			testColor = convertStringsToColor(r,g,b,a)
		})
	}
	
	private func convertStringsToColor(_ componentsArray: String...) -> Color? {
		let formatter = NumberFormatter()
		formatter.maximumSignificantDigits = 3
		guard
			componentsArray.indices.count == 4,
			let red 	= 	formatter.number(from: componentsArray[0]),
			let green 	= 	formatter.number(from: componentsArray[1]),
			let blue	= 	formatter.number(from: componentsArray[2]),
			let alpha 	= 	formatter.number(from: componentsArray[3])
		else { return nil }
		
		let color = UIColor(red: CGFloat(red.floatValue),
							green: CGFloat(green.floatValue),
							blue: CGFloat(blue.floatValue),
							alpha: CGFloat(alpha.floatValue))
		
		return Color(color)
	}
}


struct ColorTester_Previews: PreviewProvider {
	static var previews: some View {
		Prev()
	}
}
