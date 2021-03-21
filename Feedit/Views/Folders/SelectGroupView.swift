//
//  SelectGroupView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/14/21.
//

import SwiftUI
import CoreData

struct SelectGroupView: View {
    @AppStorage("darkMode") var darkMode = false
    static var fetchRequest: NSFetchRequest<RSSGroup> {
      let request: NSFetchRequest<RSSGroup> = RSSGroup.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \RSSGroup.name, ascending: true)]
      return request
    }
    @EnvironmentObject private var persistence: Persistence
    @EnvironmentObject var rssDataSource: RSSDataSource
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
      fetchRequest: RSSGroupListView.fetchRequest,
      animation: .default)
    private var groups: FetchedResults<RSSGroup>

    @State var selectedGroups: Set<RSSGroup>
    let onComplete: (Set<RSSGroup>) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    var onDoneAction: (() -> Void)?
    
    var body: some View {
        
        NavigationView {
            List(groups, id: \.id, selection: $selectedGroups) { group in
              SelectRSSGroupRow(group: group, selection: $selectedGroups)
            }
            .navigationBarTitle("Add To Folder")
//            .navigationBarItems(trailing: Button("Done") {
//                formAction()
//                self.onDoneAction?()
//                self.presentationMode.wrappedValue.dismiss()
//            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {Text("")}
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        formAction()
                        self.onDoneAction?()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        .preferredColorScheme(darkMode ? .dark : .light)
        }.environmentObject(Persistence.current)
    }

    private func formAction() {
      onComplete(selectedGroups)
    }
  }

struct SelectGroupView_Previews: PreviewProvider {
    static var previews: some View {
        SelectGroupView(selectedGroups: []) { _ in }
            .environment(\.managedObjectContext, Persistence.current.context)
            .environmentObject(Persistence.current)
    }
}



/** https://github.com/maxnatchanon/trackable-scroll-view */
struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: Content
    
    init(_ axes: Axis.Set = .vertical, showIndicators: Bool = true, contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
                    }
                    VStack {
                        self.content
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.contentOffset = value[0]
            }
        }
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
        } else {
            return outsideProxy.frame(in: .global).minX - insideProxy.frame(in: .global).minX
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}
