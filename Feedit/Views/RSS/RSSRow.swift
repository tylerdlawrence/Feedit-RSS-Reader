//
//  SourceListRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//
import SwiftUI
import UIKit
import Intents
import FeedKit


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
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30,alignment: .center)
            .cornerRadius(1)
            //.animation(.easeInOut)
            .border(Color.gray, width: 1)
        
    }

    private var pureTextView: some View {
        VStack(spacing: 0.0) {
            Text(rss.title)
                .font(.custom("Gotham", size: 18))
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                }
// below are options to have parsed feed description and last updated time
        
            //Text(rss.desc)
                //.font(.subheadline)
                //.lineLimit(1)
                        
            //Text(rss.createTimeStr)
                //.font(.footnote)
                //.foregroundColor(.gray)
            
        }
    
    
    var body: some View {
        HStack() {
            VStack(alignment: .center) {
                HStack {
                    if
                        self.imageLoader.image != nil {
                        iconImageView(self.imageLoader.image!)
                            .frame(width: 30, height: 30,alignment: .center)
                            //.layoutPriority(10)
                        pureTextView
                        
                    } else {
                        
                        Image("i")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.body)
                            .frame(width: 30, height: 30,alignment: .center)
                            .border(Color.gray, width: 1)
                            .layoutPriority(10)
                            .animation(.easeInOut)
                            
                        pureTextView
                    }
                    
                }
//                .environmentObject(sources)

               // Text(rss.createTimeStr)
                 //   .font(.footnote)
                //    .foregroundColor(.gray)
            }

        }

        
        
        
//        .padding(.top, 10)
//        .padding(.bottom, 10)
        //.frame(maxWidth: .infinity, alignment: .leading)
        //.background(Color(red: 32/255, green: 32/255, blue: 32/255))
    }
}

struct RSSRow_Previews: PreviewProvider {
    
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)

    //static let settingViewModel = SettingViewModel()

    static var previews: some View {
        ContentView(archiveListViewModel: self.archiveListViewModel, viewModel: self.viewModel)
        

        }
    }

