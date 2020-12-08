//
//  IdentifiableAlert.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/6/20.
//

import SwiftUI

struct IdentifiableAlert: Identifiable {
	let id: UUID = UUID()
	let alert: Alert
}
