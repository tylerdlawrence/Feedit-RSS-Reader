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
import Combine

struct RSSRow: View {
    
    @EnvironmentObject var rssDataSource: RSSDataSource
//    @State var sources: [RSS] = []

//    @ private var viewModel: RSSListViewModel
    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS
//    @State var sources: [RSS] = []

    var contextMenuAction: ((RSS) -> Void)?

    init(rss: RSS, menu action: ((RSS) -> Void)? = nil) {
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.imageURL)
//works^
        contextMenuAction = action
//        RSSRow.viewModel = RSSRow.viewModel

    }

    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25,alignment: .center)
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)
        
    }

    private var pureTextView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rss.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                //.font(.headline)
                .lineLimit(1)
            Text(rss.desc)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                //.font(.subheadline)
                .foregroundColor(Color.gray)
                .lineLimit(3)
        }
    }
    //    let text : String
    //    let index : Int
        let width : CGFloat = 60
    //    @Binding var indices : [Int]
        @State var offset = CGSize.zero
        @State var offsetY : CGFloat = 0
        @State var scale : CGFloat = 0.5
    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
    static var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
//                HStack {
                if
                    self.imageLoader.image != nil {
                    iconImageView(self.imageLoader.image!)
                        .frame(width: 25, height: 25,alignment: .center)
                        .layoutPriority(10)
                    pureTextView

//                    Spacer()
//                    UnreadCountView(count: RSSRow.viewModel.items.count)
                    } else {
                        
                        Image("Thumbnail") //3icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.body)
                            .frame(width: 25, height: 25,alignment: .center)
                            .cornerRadius(5)
                            .opacity(0.8)
                            .border(Color.clear, width: 1)
                            .layoutPriority(10)
                            .animation(.easeInOut)
                            
                        pureTextView
//                        GridView(viewModel: pureTextView as! RSSListViewModel, rss: rss)
//                        Spacer()
//                        UnreadCountView(count: RSSRow.viewModel.items.count)
                    }
//                }
            }
        }
    }
}

//struct RSSRow_Previews: PreviewProvider {
//    static let archiveListViewModel = ArchiveListViewModel(dataSource: DataSourceService.current.rssItem)
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//    static var previews: some View {
//        ContentView()
//    }
//}

struct GridView : View {
    
    //var rss: [RSS] //fitness_Data
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    @ObservedObject var imageLoader: ImageLoader
    @ObservedObject var rss: RSS

    var contextMenuAction: ((RSS) -> Void)?

    init(viewModel: RSSListViewModel, rss: RSS, menu action: ((RSS) -> Void)? = nil) {
        self.viewModel = viewModel
        self.rss = rss
        self.imageLoader = ImageLoader(path: rss.imageURL)
//works^
        contextMenuAction = action
//        self.viewModel = viewModel

    }

    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25,alignment: .center)
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)
        
    }

    private var pureTextView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rss.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                //.font(.headline)
                .lineLimit(1)
            Text(rss.desc)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                //.font(.subheadline)
                .foregroundColor(Color.gray)
                .lineLimit(3)
        }
    }
    //    let text : String
    //    let index : Int
        let width : CGFloat = 60
    //    @Binding var indices : [Int]
        @State var offset = CGSize.zero
        @State var offsetY : CGFloat = 0
        @State var scale : CGFloat = 0.5
    @ObservedObject var viewModel: RSSListViewModel

    var body: some View{
        
        LazyVGrid(columns: columns,spacing: 30){
            
            ForEach(viewModel.items, id: \.self){rss in
                
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text(rss.title)
                            .foregroundColor(.white)
                        
                        Text(rss.desc)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top,10)
                        
                        HStack{
                            
                            Spacer(minLength: 0)
                            
                            Text(rss.createTimeStr)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    // image name same as color name....
                    .background(Color(rss.image))
                    .cornerRadius(20)
                    // shadow....
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    
                    // top Image....
                    
                    Image(rss.image)
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.top,25)
    }
}

struct GridView_Previews: PreviewProvider {
    
    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
    
    static let rss = DataSourceService.current
    
    static var previews: some View {
        let rss = RSS.create(url: "https://feedbin.com/starred/393a5d17933784928e13bd24e787e4f8.xml",
                             title: "Starred",
                             desc: "Feedbin starred articles",
                             imageURL: "feedbin", in: Persistence.current.context)
        return GridView(viewModel: viewModel, rss: rss)
    
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    static let rss = RSS()
//
//    static let pureTextView = viewModel.items
//
//    static var previews: some View {
//        GridView(viewModel: self.viewModel//pureTextView as! RSSListViewModel, rss: rss)
    }
}
