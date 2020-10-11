//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import Intents
import UIKit

struct RSSRow: View {
    
    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS

    init(rss: RSS) {
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.image)
    }
    
    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .cornerRadius(0)
            .animation(.easeInOut)
            .border(Color.white, width: 1)
        
    }

    private var pureTextView: some View {
        VStack(spacing: 0.0) {
            Text(rss.title)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .contextMenu {
                    EditButton()
                    //Spacer()
                    Text("Article List")
                    Text("Details")
                    Text("Unsubscribe")
                }
// below are options to have parsed feed description and last updated time
        
            //Text(rss.desc)
                //.font(.subheadline)
                //.lineLimit(1)
                        
            //Text(rss.createTimeStr)
                //.font(.footnote)
                //.foregroundColor(.gray)
            
        }
    }

    var body: some View {
        HStack() {
            VStack(alignment: .center) {
                HStack {
                    if
                        self.imageLoader.image != nil {
                        iconImageView(self.imageLoader.image!)
                            .font(.body)
                            .frame(width: 20.0, height: 20.0,alignment: .center)
                            //.layoutPriority(10)
                            
                            
                            
                        pureTextView
                        
                    } else {
                        
                        Image(systemName:"dot.squareshape")
                            .font(.body)
                            
                            //"dock.rectangle"

                            .foregroundColor(Color.gray)
                            .frame(width: 20, height: 20, alignment: .center)
                                //.cornerRadius(2)
                                    .animation(.easeInOut)
                            .imageScale(.large)
    
                        pureTextView
                        //circle.bottomthird.split
                        //systemName:(globe)
                        //info.circle
                        //asterisk.circle
                        //globe
                        //waveform.circle
                    }
                }
                
                
                
                
                
                
               // Text(rss.createTimeStr)
                 //   .font(.footnote)
                //    .foregroundColor(.gray)
                    
            }
            
            
            
            
        }
        
        
        
        .padding(.top, 10)
        .padding(.bottom, 10)
        //.frame(maxWidth: .infinity, alignment: .leading)
        //.background(Color(red: 32/255, green: 32/255, blue: 32/255))
    }
}

struct RSSRow_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11")
    }
}
