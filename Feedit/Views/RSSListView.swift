//
//  RSSListView.swift
//  Feedit
//
//  Created by Tyler Lawrence on 10/22/20
//
//
//
import SwiftUI

struct RSSListView: View {

    var viewModel = RSSListViewModel(dataSource: DataSourceService.current.rss, unreadCount: Int())
    @State private var revealFeedsDisclosureGroup = false
    
    var body: some View {
        VStack {
            DisclosureGroup(
                    isExpanded: $revealFeedsDisclosureGroup,
                    content: {
                    ForEach(viewModel.items, id: \.self) { rss in
                        ZStack {
                            NavigationLink(destination: self.destinationView(rss: rss)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            HStack {
                                RSSRow(rss: rss, viewModel: viewModel)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            self.viewModel.delete(at: index)
                        }
                    }
                    .listRowBackground(Color("accent"))
                    .environmentObject(DataSourceService.current.rss)
                    .environmentObject(DataSourceService.current.rssItem)
                    .environment(\.managedObjectContext, Persistence.current.context)
                    },
                    label: {
                        HStack {
                            Text("Feeds")
                                .font(.system(size: 14, weight: .regular, design: .rounded)).textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        self.revealFeedsDisclosureGroup.toggle()
                                    }
                                }
                        }.frame(maxWidth: .infinity)
                    })
                .listRowBackground(Color("darkerAccent"))
                .accentColor(Color("tab"))
        }
    }
    private func destinationView(rss: RSS) -> some View {
        let item = RSSItem()
        return RSSFeedListView(rss: rss, viewModel: RSSFeedViewModel(rss: rss, dataSource: DataSourceService.current.rssItem), rssItem: item, filter: .all)
            .environmentObject(DataSourceService.current.rss)
    }
}

struct RSSListView_Previews: PreviewProvider {
    static var previews: some View {
        RSSListView()
    }
}
