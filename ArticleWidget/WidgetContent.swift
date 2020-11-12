//
//  WidgetContent.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/11/20.
//

import Foundation
import WidgetKit

struct WidgetContent: Codable, TimelineEntry {
  var date = Date()
  let name: String
  let cardViewSubtitle: String
  let descriptionPlainText: String
  let releasedAtDateTimeString: String
}
