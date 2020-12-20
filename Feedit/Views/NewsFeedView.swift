//
//  NewsFeedView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/16/20.
//

import SwiftUI
import KingfisherSwiftUI

struct NewsFeedView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var article:Article
//    var itemWrapper:RSSItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    
                    .font(.headline)
                    .lineLimit(3)
                
                Text(article.subtitle)
                    .font(.subheadline)
                    .opacity(0.7)
                    .lineLimit(1)
                
                Text(article.author)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                
            }.padding(.horizontal, 12)
        
        VStack{
            KFImage(URL(string: article.imageUrl)!)
                .placeholder({
                    ProgressView()
                })
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipped()
                .cornerRadius(12)
            }
        .padding(12)
        }
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView(article: Article(
            url: "https://static01.nyt.com/images/2020/07/28/science/28SCI-MARS-JEZERO1/28SCI-MARS-JEZERO1-jumbo.jpg",
            imageUrl: "https://static01.nyt.com/images/2020/07/28/science/28SCI-MARS-JEZERO1/28SCI-MARS-JEZERO1-jumbo.jpg",
            title: "How NASA Found the Ideal Hole on Mars to Land In",
            subtitle: "Jezero crater, the destination of the Perseverance rover, is a promising place to look for evidence of extinct Martian life.",
            author: "KENNETH CHANG"
        ))
        .preferredColorScheme(.dark)
        //            .previewDevice(.init(stringLiteral: "iPhone X"))
        //            .edgesIgnoringSafeArea(.all)
        //            .environment(\.colorScheme, .dark)
    }
}

