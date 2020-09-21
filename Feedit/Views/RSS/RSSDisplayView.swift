//
//  SourceDisplayView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI

struct RSSDisplayView: View {
    
    @ObservedObject var rss: RSS
    
    var body: some View {
        Group {
            TextFieldView(label: "Title", placeholder: "", text: $rss.title)
            TextFieldView(label: "Description", placeholder: "", text: $rss.desc)
            TextFieldView(label: "Feed URL", placeholder: "", text: $rss.url)
        }
    }
}

#if DEBUG

struct SourceDisplayView_Previews: PreviewProvider {
    static let rss = DataSourceService.current
    static var previews: some View {
        let rss = RSS.create(url: "https://",
                             title: "simple demo",
                            desc: "show me your desc",
                             image: "", in: Persistence.current.context)
        return RSSDisplayView(rss: rss)
    }
}

#endif
