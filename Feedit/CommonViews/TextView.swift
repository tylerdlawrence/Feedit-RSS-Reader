//
//  TextView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

//import SwiftUI

//struct TextView: UIViewRepresentable {
//
//    @Binding var text: String
//    @Binding var textStyle: UIFont.TextStyle
//
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
//        textView.autocapitalizationType = .sentences
//        textView.isSelectable = true
//        textView.isUserInteractionEnabled = true
//        textView.isEditable = false
//        return textView
//    }
//
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        uiView.text = text
//        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
//    }
//
//    static func dismantleUIView(_ uiView: UITextView, coordinator: Coordinator) {
//
//    }
//}
//
//struct TextView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextView(text: .constant("JSON Content"), textStyle: .constant(.body))
//    }
//}
import SwiftUI

struct TextView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
    
    static func dismantleUIView(_ uiView: UITextView, coordinator: Coordinator) {
        
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(text: .constant("TextView Previews"), textStyle: .constant(.body))
    }
}

