//
//  SourceDisplayView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import KingfisherSwiftUI

struct RSSDisplayView: View {
    
    @ObservedObject var rss: RSS
    
    var body: some View {
        Group {
            TextFieldView(label: "Title", placeholder: "", text: $rss.title)
            TextFieldView(label: "Description", placeholder: "", text: $rss.desc)
            TextFieldView(label: "Feed URL", placeholder: "", text: $rss.url)
            TextFieldView(label: "Image URL", placeholder: "", text: $rss.imageURL)
           // Image("3icon")
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
                             imageURL: "https://cdn.vox-cdn.com/thumbor/dgXIXzW1oEzobScwyCZSFxY1pek=/0x0:3200x1800/2070x1164/filters:focal(1344x644:1856x1156):format(webp)/cdn.vox-cdn.com/uploads/chorus_image/image/67845097/Lromeo_2011_Ringer_Kanye_v2.7.jpg", in:
                                Persistence.current.context)
        
        return RSSDisplayView(rss: rss)
    }
}

#endif
