//
//  SearchBar.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 11/2/20.
//
//
//import SwiftUI
//import Foundation
//
//struct SearchBar: UIViewRepresentable {
//
//    @Binding var text: String
//
//    class Coordinator: NSObject, UISearchBarDelegate {
//        @Binding var text: String
//        init(text: Binding<String>) {
//            _text = text
//        }
//
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            text = searchText
//        }
//    }
//
//    func makeCoordinator() -> SearchBar.Coordinator {
//        return Coordinator(text: $text)
//    }
//
//    func MakeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.delegate = context.coordinator
//        return searchBar
//    }
//
//    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
//        uiView.text = text
//    }
//}
    
//    @Binding var searchText: String
//    @Binding var isSearching: Bool
//
//    var body: some View {
//        //Spacer()
//        HStack {
//            HStack {
//                TextField("Search", text: $searchText)
//                    .font(.custom("Gotham", size: 20))
//                    .padding(.leading, 14)
//            }
//            .padding(3.0)
////            .background(Color.clear)
//            //.background(Color("bg"))
//            .opacity(0.5)
//            .cornerRadius(15)
////            .padding(.vertical)
//            .padding(.horizontal)
//            .onTapGesture(perform: {
//                isSearching = true
//            })
//            .overlay(
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                        .imageScale(.large)
//                    Spacer()
//
//                    if isSearching {
//                        Button(action: { searchText = "" }, label: {
//                            //Image(systemName: "xmark.circle.fill")
//                                //.padding(.vertical)
//                        })
//
//                    }
//
//                }.padding(.horizontal, 0)
//                .opacity(0.5)
//                .foregroundColor(.gray).opacity(0.8)
//            ).transition(.move(edge: .trailing))
//            .animation(.spring())
//
//            if isSearching {
//                Button(action: {
//                    isSearching = false
//                    searchText = ""
//
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//
//                }, label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .imageScale(.medium)
////                    Text("Cancel")
////                        .multilineTextAlignment(.center)
//                        .padding(.trailing, 17)
//                        //.padding(.leading)
//                })
//                .transition(.move(edge: .trailing))
//                .animation(.spring())
//            }
//        }//.background(Color("bg"))
//    }
//}
//
//
//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar()
//    }
//}
