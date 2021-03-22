//
//  DataNStorageView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI
import Introspect
import Combine
import CoreData

struct DataNStorageView: View {
    
    @ObservedObject var dataViewModel: DataNStorageViewModel
    
    init() {
        let db = DataSourceService.current
        dataViewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        DataUnitView(label: "Feeds", content: self.$dataViewModel.rssCount, colorType: .blue)
                        DataUnitView(label: "Article Count", content: self.$dataViewModel.rssItemCount, colorType: .orange)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .frame(height: 120)
                Spacer()
                }
                .navigationBarTitle("Archive")
                .padding([.top, .horizontal])
                .offset(x: geo.frame(in: .global).minX / 5)
            }
            .introspectScrollView { scrollView in
                scrollView.refreshControl = UIRefreshControl()
            }
            .onAppear {
                self.dataViewModel.getRSSCount()
                self.dataViewModel.getRSSItemCount()
            }
        }
    }
}

struct DataNStorageView_Previews: PreviewProvider {
    static var previews: some View {
        DataNStorageView()
    }
}


