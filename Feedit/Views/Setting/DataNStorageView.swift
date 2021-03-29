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
                VStack(spacing: 10){
                    HStack{
                        VStack(alignment: .leading){
                            Text("All Articles").fontWeight(.bold)
                            Text("1840").fontWeight(.bold).font(.system(size: 18))
                        }
                        Spacer()
                        Image(systemName: "archivebox.fill").font(.system(size: 24))
                    }.padding()
                    .frame(width: (UIScreen.main.bounds.width - 30) / 1)
                    .background(Color.gray)
                    .cornerRadius(15)
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("Unread").fontWeight(.bold)
                            Text("228").fontWeight(.bold).font(.system(size: 18))
                        }
                        Spacer()
                        Image(systemName: "circle.fill").font(.system(size: 24))
                    }.padding()
                    .frame(width: (UIScreen.main.bounds.width - 30) / 1)
                    .background(Color.blue)
                    .cornerRadius(15)
                    
                    HStack{
                       VStack(alignment: .leading){
                            Text("Starred").fontWeight(.bold)
                            Text("10").fontWeight(.bold).font(.system(size: 18))
                        }
                        Spacer()
                        Image(systemName: "star.fill").font(.system(size: 24))
                    }.padding()
                    .frame(width: (UIScreen.main.bounds.width - 30) / 1)
                    .background(Color.yellow)
                    .cornerRadius(15)
                }.foregroundColor(.white)
                
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


