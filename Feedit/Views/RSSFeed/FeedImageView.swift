//
//  FeedRowView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/26/20.
//

import SwiftUI
import KingfisherSwiftUI
import FeedKit

struct FeedImageView: View {
    
    @ObservedObject var itemWrapper: RSSItem
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text(itemWrapper.title)
                    
                    .font(.headline)
                    .lineLimit(3)
                
                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                    .font(.subheadline)
                    .opacity(0.7)
                    .lineLimit(1)
                
                Text(itemWrapper.author)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
            }.padding(.horizontal, 12)
            KFImage(URL(string: itemWrapper.imageURL))
                            .placeholder({
                                ProgressView()
                            })
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipped()
                            .cornerRadius(12)
        }
    }
}
