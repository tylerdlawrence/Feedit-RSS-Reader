////
////  RSSListView.swift
////  Feedit
////
////  Created by Tyler Lawrence on 10/22/20
////
////
////
//import SwiftUI
//
//struct RSSListView: View {
//}

//import SwiftUI
//import Foundation
//
//struct FilterModel: Identifiable {
//    var id: Int
//    var name: String
//    var selected: Bool
//}
//
//struct RSSListView: View {
//    @State var isFilterTapped = false
//    
//    @StateObject var filterViewModel = FilterViewModel.shared
//    
//    var body: some View {
//        
//        VStack {
//            
//            HStack(spacing: 40) {
//                
//                Button("Choose") {
//                    isFilterTapped.toggle()
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 10)
//                .background(Color.red)
//                .foregroundColor(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//                
//                Button("Reset") {
//                    filterViewModel.filterReset()
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 10)
//                .background(Color.red)
//                .foregroundColor(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//                
//            }
//            
//            VStack(alignment: .leading) {
//                Text("Chosen teams")
//                    .padding()
//                
//                ForEach(filterViewModel.items) { filter in
//                    if filter.selected {
//                        Text("- \(filter.name)")
//                            .padding()
//                    }
//                }
//            }
//            
//        }
//        .sheet(isPresented: $isFilterTapped, content: {
//            FilterView(isFilterTapped: $isFilterTapped)
//        })
//    }
//}
//
//struct RSSListView_Previews: PreviewProvider {
//    static var previews: some View {
//        RSSListView()
//    }
//}
//
//struct FilterView: View {
//    @Binding var isFilterTapped: Bool
//    
//    @StateObject var rssFeedViewModel = RSSFeedViewModel.shared
//    
//    var body: some View {
//        
//        HStack {
//            
//            Spacer()
//            
//            Button("Done") {
//                isFilterTapped.toggle()
//            }
//            
//        }
//        .padding()
//        
//        ScrollView {
//            
//            ForEach(rssFeedViewModel.items) { filter in
//                
//                HStack {
//                    Image(systemName: filter.isArchive ? "checkmark.circle.fill" : "circle")
//                    
//                    Text(filter.title)
//                    
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 10)
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    rssFeedViewModel.filterRowTapped(filterRow: filter)
//                }
//                
//            }
//            
//        }
//        
//    }
//}
//
//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView(isFilterTapped: .constant(false))
//    }
//}
//
//class FilterViewModel: ObservableObject {
//    static let shared = FilterViewModel()
//    
//    init () {
//        
//    }
//    
//    @Published var items = [
//        FilterModel(id: 0, name: "Chicage Bulls", selected: false),
//        FilterModel(id: 1, name: "Cleveland Cavaliers", selected: false),
//        FilterModel(id: 2, name: "Los Angeles Lakers", selected: false),
//        FilterModel(id: 3, name: "Miami Heat", selected: false),
//        FilterModel(id: 4, name: "San Antonio Spurs", selected: false)
//    ]
//    
//    func filterRowTapped (filterRow: FilterModel) {
//        
//        self.items[filterRow.id].selected.toggle()
//        
//    }
//    
//    func filterReset() {
//        
//        for element in items {
//            if element.selected {
//                filterRowTapped(filterRow: element)
//            }
//        }
//        
//    }
//    
//}
