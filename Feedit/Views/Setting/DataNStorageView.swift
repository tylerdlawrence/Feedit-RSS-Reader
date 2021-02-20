//
//  DataNStorageView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI

struct DataNStorageView: View {
    
    @ObservedObject var viewModel: DataNStorageViewModel
    
    init() {
        let db = DataSourceService.current
        viewModel = DataNStorageViewModel(rss: db.rss, rssItem: db.rssItem)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                DataUnitView(label: "Feeds", content: self.$viewModel.rssCount, colorType: .blue)
                DataUnitView(label: "Article Count", content: self.$viewModel.rssItemCount, colorType: .orange)
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .frame(height: 120)
            
            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            self.viewModel.getRSSCount()
            self.viewModel.getRSSItemCount()
        }
    }
}

struct DataNStorageView_Previews: PreviewProvider {
    static var previews: some View {
        DataNStorageView()
    }
}
