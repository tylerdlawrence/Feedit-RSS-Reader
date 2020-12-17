//
//  MainView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/16/20.
//

import SwiftUI
import KingfisherSwiftUI

struct MainView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var article:Article
    
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(article: Article(
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

struct ImageView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ScrollView {
                    Spacer()    // TODO: replace with the actual content
                }
                
                // TODO: Unsupported element class: UIVisualEffectView
                
                Text("")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .offset(x: 0, y: 854)
                    .frame(width: 414, height: 0)
                
                Button(action: {
                    //share()
                }) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .frame(width: 44, height: 44, alignment: .center)
                }
                .aspectRatio(contentMode: .fill)
                .accentColor(Color.blue)
                .offset(x: 362, y: 44)
                
                Button(action: {
                    //done()
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .frame(width: 44, height: 44, alignment: .center)
                }
                .clipped()
                .accentColor(Color.blue)
                .offset(x: 8, y: 44)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}

struct ContextMenuPreviewView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ImageView()
                Text("Blog Name")
                    .font(.headline)
                    .foregroundColor(Color.gray)
                    .offset(x: 20, y: 8)
                    .frame(width: 87, height: 20.5)
                
                Text("Blog Author")
                    .font(.body)
                    .offset(x: 20, y: 36.5)
                    .frame(width: 90, height: 21)
                
                Text("Article Title")
                    .font(.title)
                    .offset(x: 20, y: 74.5)
                    .frame(width: 136, height: 33.5)
                
                Text("Label")
                    .font(.headline)
                    .offset(x: 20, y: 116)
                    .frame(width: 44, height: 20.5)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ContextMenuPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuPreviewView()
    }
}
