//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import SwiftUI
import WidgetKit
import Intents

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
            .frame(width: 25, height: 25, alignment: .trailing)
            .cornerRadius(2)
                .animation(.easeInOut)
            //.frame(width: 35, height: 35, alignment: .bottomLeading)
    //         ORIGINAL IMAGE SIZE BELOW
//        .resizable()
        //    .frame(width: 35, height: 35, alignment: .center)
       // .cornerRadius(30)
         //   .animation(.easeInOut)
    }

    private var pureTextView: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Text(rss.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                
            Text(rss.desc)
                .font(.subheadline)
                .lineLimit(1)
                        
            Text(rss.createTimeStr)
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    if self.imageLoader.image != nil {
                        iconImageView(self.imageLoader.image!)
                            
                        pureTextView
                        
                    } else {
                        
                        Image(systemName:"square.3.stack.3d.top.fill")
                            //"info.circle.fill"
                            .foregroundColor(Color("footnoteColor"))
                                .frame(width: 25, height: 25, alignment: .trailing)
                                .cornerRadius(2)
                                    .animation(.easeInOut)
                            //.padding(.top, 35.0)
                            //.frame(width: 15.0, height: /*@START_MENU_TOKEN@*/15.0/*@END_MENU_TOKEN@*/)
                            //.font(.system(size:24, weight: .bold))
                            
                            //.frame(width: 10, height: 10, alignment: .trailing)
                            //.cornerRadius(2)
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
        //.padding(.top, 10)
        //.padding(.bottom, 10)
    }
}

struct RSSRow_Previews: PreviewProvider {
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    static var previews: some View {
        RSSListView(viewModel: self.viewModel)
            .preferredColorScheme(.dark)
            
    }
}
