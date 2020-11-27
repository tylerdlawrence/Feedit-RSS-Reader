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

    @ObservedObject var itemWrapper: RSSItem
    @ObservedObject var imageLoader: ImageLoader
   // @ObservedObject var rssFeedViewModel: RSSFeedViewModel

    var contextMenuAction: ((RSSItem) -> Void)?

    init(wrapper: RSSItem, menu action: ((RSSItem) -> Void)? = nil) {
        itemWrapper = wrapper
        contextMenuAction = action
        self.imageLoader = ImageLoader(path: wrapper.image)

    }

    func iconImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
        .resizable()
            .cornerRadius(5)
            .animation(.easeInOut)
            .border(Color.clear, width: 1)

    }

    private var pureTextView: some View {

            Text(itemWrapper.title)
                .font(.custom("Gotham", size: 20))
                .multilineTextAlignment(.leading)
                .lineLimit(1)
    }

    private var descView: some View {
            Text(itemWrapper.desc)
                .font(.subheadline)
                .lineLimit(1)
    }

    var body: some View{

        VStack(alignment: .leading) {

            Text(itemWrapper.title)
                .font(.headline)
                .lineLimit(3)
            //Spacer()
            Text(itemWrapper.desc.trimHTMLTag.trimWhiteAndSpace)
                .font(.subheadline)
                .foregroundColor(.gray)
                //.foregroundColor(Color("darkerAccent"))
                .lineLimit(1)

                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        HStack {
                            if
                                self.imageLoader.image != nil {
                                iconImageView(self.imageLoader.image!)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
                                    .font(.body)
                                    .frame(width: 20, height: 20,alignment: .center)
                                    .layoutPriority(10)
                                    .animation(.easeIn)

                            } else {

                                Image("3dicon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .font(.body)
                                    .frame(width: 20, height: 20,alignment: .center)
                                    .border(Color.clear, width: 1)
                                    .cornerRadius(5)
                                    .layoutPriority(10)
                                    //.animation(.easeInOut)
                                    //.padding(.trailing, 150)

                            }

                            //Text(itemWrapper.title)

                            HStack(spacing: 10) {
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

                                Text("\(itemWrapper.createTime?.string() ?? "")")
                                    .font(.custom("Gotham", size: 14))                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.trailing)

                //Spacer(minLength: 10)
                if itemWrapper.isArchive {
                    Image(systemName: "tag")
                        .imageScale(.small)
                        .foregroundColor(.accentColor)
                }
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
            }
        }
    }
}

//struct RSSFeedRow_Previews: PreviewProvider {
//    static let viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss)
//
//    static var previews: some View {
//        ContentView(viewModel: self.viewModel)
//            .preferredColorScheme(.dark)
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
