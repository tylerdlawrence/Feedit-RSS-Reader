//
//  RSSItemRow.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//  View once you choose Feed on Main Screen

import SwiftUI
import KingfisherSwiftUI
import FeedKit

struct RSSItemRow: View {
    
    let image = NSCache<AnyObject, AnyObject>()
    
    @ObservedObject var itemWrapper: RSSItem
    @ObservedObject var imageLoader: ImageLoader

    var contextMenuAction: ((RSSItem) -> Void)?

    init(wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) {
        itemWrapper = wrapper
        contextMenuAction = action
        self.imageLoader = ImageLoader(path: wrapper.image)
        //loadImage(url: itemWrapper.image)

    }
    
//    func iconImageView(url: String) {
//        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
//            self.imageLoader.image = imageFromCache
//        } else {
//            if let imageURL = URL(string: url) {
//                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
//                    guard let data = data, error == nil else { return }
//                    if let imageToCache = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            self.imageCache.setObject(imageToCache, forKey: url as AnyObject)
//                            self.imageLoader.image = imageToCache
//                        }
//                    }
//                }
//                task.resume()
//            }
//        }
//    }

    private func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
        .frame(width: 80, height: 80, alignment: .center)
        .cornerRadius(4)
        .animation(.easeInOut)
    }

    private var pureTextView: some View {

            Text(itemWrapper.title)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
    }
    


    private var descView: some View {
            Text(itemWrapper.desc)
                .font(.subheadline)
                .lineLimit(1)
    }

    var body: some View{
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                Text(itemWrapper.title)
                    .font(.headline)
                    .lineLimit(3)
                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                HStack{
                    
                    Text("\(itemWrapper.createTime?.string() ?? "")")
                        .font(.custom("Gotham", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    
                    if itemWrapper.progress >= 1.0 {
                        Text("DONE")
                            .font(.footnote)
                            .foregroundColor(.blue)

                    } else if itemWrapper.progress > 0 {

                        ProgressBar(
                            boardWidth: 4,
                            font: Font.system(size: 9),
                            color: .blue,
                            content: false,
                            progress: self.$itemWrapper.progress
                        )
                        .frame(width: 13, height: 13, alignment: .center)
                        }

                        if itemWrapper.isArchive {
                            Image(systemName: "tag")
                                .imageScale(.small)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .contextMenu {
                    ActionContextMenu(
                        label: itemWrapper.isArchive ? "Untag" : "Tag",
                        systemName: "bookmark\(itemWrapper.isArchive ? "" : ".slash")",
                        onAction: {
                            self.contextMenuAction?(self.itemWrapper)
                        })
                    }
                    .padding(.horizontal, 12)
                        KFImage(URL(string: itemWrapper.image)) //"3icon"
                            .placeholder({
                                ZStack{
                                    //ProgressView()
                                    iconImageView(self.imageLoader.image ?? UIImage(imageLiteralResourceName: "launch"))
                                        .opacity(0.7)
                                }
                            })
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipped()
                            .cornerRadius(12)
                            .multilineTextAlignment(.trailing)
                            }
                        }
                    }
    //}

//                                HStack(spacing: 10) {
//                                    if itemWrapper.progress >= 1.0 {
//                                        Text("DONE")
//                                            .font(.footnote)
//                                            .foregroundColor(.blue)
//
//                                    } else if itemWrapper.progress > 0 {
//
//                                        ProgressBar(
//                                            boardWidth: 4,
//                                            font: Font.system(size: 9),
//                                            color: .blue,
//                                            content: false,
//                                            progress: self.$itemWrapper.progress
//                                        )
//                                        .frame(width: 13, height: 13, alignment: .center)
//                                    }
//
//                                    Text("\(itemWrapper.createTime?.string() ?? "")")
//                                        .font(.custom("Gotham", size: 14))                                    .foregroundColor(.gray)
//                                        .multilineTextAlignment(.trailing)
//
//
//                    if itemWrapper.isArchive {
//                        Image(systemName: "tag")
//                            .imageScale(.small)
//                    }
//                }
//            }
        
        


//            .padding(.top, 8)
//            .padding(.bottom, 8)
//            .contextMenu {
//                ActionContextMenu(
//                    label: itemWrapper.isArchive ? "Untag" : "Tag",
//                    systemName: "bookmark\(itemWrapper.isArchive ? "" : ".slash")",
//                    onAction: {
//                        self.contextMenuAction?(self.itemWrapper)
//                })
//            }
//        }
//    }


//struct RSSFeedRow_Previews: PreviewProvider {
//    static var previews: some View {
//        let simple = DataSourceService.current.rssItem.simple()
//        return RSSItemRow(wrapper: simple!)
//    }
//}

//        HStack{
//            VStack(alignment: .leading, spacing: 8) {
//                Text(itemWrapper.title)
//
//                    .font(.headline)
//                    .lineLimit(3)
//
//                Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
//                    .font(.subheadline)
//                    .opacity(0.7)
//                    .lineLimit(1)
//
//                Text(itemWrapper.author)
//                    .font(.system(size: 13, weight: .medium, design: .rounded))
//                    .multilineTextAlignment(.leading)
//            }.padding(.horizontal, 12)
//            KFImage(URL(string: itemWrapper.urlToImage))
//                            .placeholder({
//                                ProgressView()
//                            })
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 90, height: 90)
//                            .clipped()
//                            .cornerRadius(12)
//        }
//    }
//}
