//
//  RSSActionSheet.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/23/21.
//

//import SwiftUI
//
//struct RSSActionSheet: View {
//
//    @State var unread = false
//    @State var starred = false
//    @State var show3 = false
//    @State var show4 = false
//    @State var count = 0
//
//    enum FeedSettings: CaseIterable {
//        case webView
//    }
//    @State private var isSelected: Bool = false
//    @State var notificationsEnabled: Bool = false
////    @Binding var fetchContentTime: String
//
//    var body : some View{
//
//        VStack(spacing: 15){
//
////            Picker(selection: $fetchContentTime, label:
////                    Text("Fetch content time")) {
////                ForEach(ContentTimeType.allCases, id: \.self.rawValue) { type in
////                    Text(type.rawValue)
////                }
////            }
//
//            Toggle(isOn: self.$unread) {
//                Text("Unread Only")
//            }.toggleStyle(CheckboxStyle())
//
//            Toggle(isOn: self.$starred) {
//                Text("Starred Only")
//            }.toggleStyle(StarStyle())
//
//            Divider()
//
//            Toggle(isOn: self.$notificationsEnabled) {
//                Text("Notifications")
//            }.toggleStyle(SwitchToggleStyle(tint: .blue))
//
//            ForEach([FeedSettings.webView], id: \.self) { _ in
//                Toggle("Safari Reader", isOn: self.$isSelected)
//            }.toggleStyle(SwitchToggleStyle(tint: .blue))
//
//            Divider()
//
//            Stepper(onIncrement: {
//                self.count += 1
//            }, onDecrement: {
//                if self.count != 0{
//                    self.count -= 1
//                }
//            }) {
//                Text("Line Limit \(self.count)")
//            }
//        }
//        .padding(.bottom, (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 10)
//        .padding(.horizontal)
//        .padding(.top,20)
////        .background(Color(UIColor.systemBackground))
//        .background(Color("secondary"))
////        .cornerRadius(25)
//
//    }
//}
//
//struct RSSActionSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        RSSActionSheet()
//    }
//}
