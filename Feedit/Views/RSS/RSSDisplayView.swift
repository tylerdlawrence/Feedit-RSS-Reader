//
//  SourceDisplayView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import KingfisherSwiftUI
import Combine

struct RSSDisplayView: View {
    
    @ObservedObject var rss: RSS
    @State private var isLoading = false
        
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if rss.isFetched {
                KFImage(URL(string: rss.image ?? ""))
                    .renderingMode(.original)
                    .resizable()
                    .placeholder {
                        Image(systemName: "arrow.clockwise").font(.system(size: 16, weight: .bold))
                            .frame(width: 50, height: 50)
                            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                            .onAppear() {
                                self.isLoading = false
                            }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .border(Color.clear, width: 1)
                    .cornerRadius(3.0)
                
                Text(rss.title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color("text"))

                Text(rss.desc)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color("text"))

                Spacer()
                Text(rss.createTimeStr)
                    .font(.footnote)
                    .foregroundColor(.gray)
                
            } else {
                KFImage(URL(string: rss.image ?? ""))
                    .renderingMode(.original)
                    .resizable()
                    .placeholder {
                        Image("getInfo").font(.system(size: 16, weight: .bold))
                            .frame(width: 50, height: 50)
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .border(Color.clear, width: 1)
                    .cornerRadius(3.0)

                Text(rss.title)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color("text"))

                Text(rss.desc)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color("text"))

            }
            Divider()
            Group {
                TextFieldView(label: "Title:", placeholder: "", text: $rss.title)
                TextFieldView(label: "Description:", placeholder: "", text: $rss.desc)
                TextFieldView(label: "Feed URL:", placeholder: "", text: $rss.url)
                TextFieldView(label: "Image URL:", placeholder: "", text: $rss.image ?? "")
            }.padding(.vertical)
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
