//
//  SourceDisplayView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct RSSDisplayView: View {
    
    @ObservedObject var rss: RSS

    //the code below shows w/i the ADD VIEW handle once opened
    
    var body: some View {
        Group {
            ZStack {
            TextFieldView(label: "Title", placeholder: "", text: $rss.title)
                HStack {
                    Image(rss.image)
                }
            }
            TextFieldView(label: "Description", placeholder: "", text: $rss.desc)
            TextFieldView(label: "Feed URL", placeholder: "", text: $rss.url)
        }
    }
}

#if DEBUG

struct SourceDisplayView_Previews: PreviewProvider {
    static let rss = DataSourceService.current
    static var previews: some View {
    let rss = RSS.create(url: "https://feed.podbean.com/HRpreneur/feed.xml",
                             title: "HR{preneur}",
                            desc: "ADP small business podcast",
                             image: "", in: Persistence.current.context)
        return RSSDisplayView(rss: rss)
            
            //.preferredColorScheme(.dark)
            .environment(\.sizeCategory, .small)
    }
}

#endif
