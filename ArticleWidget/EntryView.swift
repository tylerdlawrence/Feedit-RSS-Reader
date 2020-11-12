//
//  EntryView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/11/20.
//

import SwiftUI

struct EntryView: View {
  let model: WidgetContent

  var body: some View {
    VStack(alignment: .leading) {
      Text(model.name)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)
        .padding([.trailing], 15)
      
      Text(model.cardViewSubtitle)
        .lineLimit(nil)
        .foregroundColor(.blue)
      
      Text(model.descriptionPlainText)
        .fixedSize(horizontal: false, vertical: true)
        .lineLimit(2)
        .lineSpacing(3)
      
      Text(model.releasedAtDateTimeString)
        .lineLimit(1)
        .foregroundColor(.blue)
    }
    .padding()
    .cornerRadius(6)
  }
}


struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(model: try! WidgetContent(from: JSONDecoder.self as! Decoder))
    }
}
