//
//  GetInfo.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 1/3/21.
//

import SwiftUI
import MobileCoreServices
import SwipeCell
import Combine
import Foundation
import CoreData
import KingfisherSwiftUI

struct InfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    @ObservedObject var rss: RSS
    @State private var isSelected: Bool = false
    
    enum InfoItem: CaseIterable {
        case webView
        
        var label: String {
            switch self {
            case .webView: return "Read Mode"
            }
        }
    }
    
    var rssSource: RSS {
        return self.rss
    }

    var body: some View {
        Form {
            Text(rssSource.title).font(.system(size: 18, weight: .medium, design: .rounded))
            HStack{
                KFImage(URL(string: rssSource.imageURL))
                    .placeholder({
                        Image("Thumbnail")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50,alignment: .center)
                            .cornerRadius(5)
                            .border(Color.clear, width: 1)
                            .multilineTextAlignment(.center)

                    })
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50,alignment: .center)
                    .cornerRadius(5)
                    .border(Color.clear, width: 1)
                    .multilineTextAlignment(.center)

                Text(rssSource.desc)
                    
            }

            Section(header: Text("date added")) {
                Text(rssSource.createTimeStr)
//                    .onTapGesture(count: 1) {
//                        UIPasteboard.general.setValue(self.rssSource.createTimeStr,
//                                                      forPasteboardType: kUTTypePlainText as String)
//                        }
                }
            Section(header: Text("Feed URL")) {
                Text(rssSource.url)
                    .onTapGesture(count: 1) {
                        UIPasteboard.general.setValue(self.rssSource.url,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }
                }
            Section(header: Text("Image URL")) {
                Text(rssSource.imageURL)
                    .onTapGesture(count: 1) {
                        UIPasteboard.general.setValue(self.rssSource.imageURL,
                                                      forPasteboardType: kUTTypePlainText as String)
                    }
                }
            HStack {
                Image(systemName: "safari")
                    .fixedSize()
                ForEach([InfoItem.webView], id: \.self) { _ in
                        Toggle("Safari Reader View", isOn: self.$isSelected)
                    }.toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .navigationBarTitle(rssSource.title)
            .navigationBarItems(leading:
                Button(action: {
                print("dismisses form")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                }, trailing: EditButton())
        }
    }
