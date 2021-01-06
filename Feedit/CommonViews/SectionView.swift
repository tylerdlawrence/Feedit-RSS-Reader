//
//  SectionView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct SectionView<Content: View>: View {
    
    var imageURL: String?
    var title: String?
    var description: String?
    let content: () -> Content
    
    var body: some View {
        Group {
            #if os(iOS)
            if description == nil {
                Section {
                    if title != nil {
                        Text(title!)
                            .font(.headline)
                    }
                    Section {
                        if imageURL == nil {
                            Image(imageURL!)
                            
                        }
                    }
                    content()
                }
            } else {
                Section(footer: Text(description!)) {
                    if title != nil {
                        Text(title!)
                            .font(.headline)
                    }
                    Section {
                    if imageURL == nil {
                        Image(systemName: "chart.bar.doc.horizontal").font(.system(size: 16, weight: .regular)).foregroundColor(.secondary)
                        }
                    }
                    content()
                }
            }
            #else
            Group {
                if let title = title {
                    Text(title).font(.title3).bold()
                }
                content()
                Text(description).font(.body).foregroundColor(.secondary)
                Divider()
            }
            #endif
        }
    }
}
 struct SectionView_Previews: PreviewProvider {
     static var previews: some View {
        SectionView(imageURL: "", title: "Section", description: "Description", content: { Text("Content") })
         .previewLayout(.sizeThatFits)
             .previewLayout(.sizeThatFits)
     }
 }
//import SwiftUI
//
//struct SectionView<Content: View>: View {
//
//    var title: String?
//    var description: String?
//    let content: () -> Content
//
//    var body: some View {
//        Group {
//            #if os(iOS)
//            if description == nil {
//                Section {
//                    if title != nil {
//                        Text(title!)
//                            .font(.headline)
//                    }
//                    content()
//                }
//            } else {
//                Section(footer: Text(description!)) {
//                    if title != nil {
//                        Text(title!)
//                            .font(.headline)
//                    }
//                    content()
//                }
//            }
//            #else
//            Group {
//                if let title = title {
//                    Text(title).font(.title3).bold()
//                }
//                content()
//                Text(description).font(.body).foregroundColor(.secondary)
//                Divider()
//            }
//            #endif
//        }
//    }
//}
//
//struct SectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SectionView(title: "Section", description: "Description", content: { Text("Content") })
//            .previewLayout(.sizeThatFits)
//    }
//}
