//
//  ExpansionHandler.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/15/21.
//

import SwiftUI
import Foundation

class ExpansionHandler<T: Equatable>: ObservableObject {
    @Published private (set) var expandedItem: T?

    func isExpanded(_ item: T) -> Binding<Bool> {
        return Binding(
            get: { item == self.expandedItem },
            set: { self.expandedItem = $0 == true ? item : nil }
        )
    }

    func toggleExpanded(for item: T) {
        self.expandedItem = self.expandedItem == item ? nil : item
    }
}

// Usage:
// Some `Equatable` type, can also use basic types like `String` or `Date`.
enum ExpandableSection: Equatable {
    case section
    case anotherSection
}

//@StateObject private var expansionHandler = ExpansionHandler<ExpandableSection>()
//
//DisclosureGroup(
//    isExpanded: self.expansionHandler.isExpanded(.section),
//    content: {
//        // ...
//    },
//    label: {
//        // ...
//    }
//)
//.contentShape(Rectangle()) // Usability feature to have the whole item tappable, and not just the label/disclosure indicator
//.onTapGesture {
//    withAnimation { self.expansionHandler.toggleExpanded(for: .section) }
//}

//https://www.fivestars.blog/code/swiftui-hierarchy-list.html
struct FileItem: Identifiable {
  let name: String
  var children: [FileItem]?

  var id: String { name }

  static let spmData: [FileItem] = [
    FileItem(name: ".gitignore"),
    FileItem(name: "Package.swift"),
    FileItem(name: "README.md"),
    FileItem(name: "Sources", children: [
      FileItem(name: "fivestars", children: [
        FileItem(name: "main.swift")
      ]),
    ]),
    FileItem(name: "Tests", children: [
      FileItem(name: "fivestarsTests", children: [
        FileItem(name: "fivestarsTests.swift"),
        FileItem(name: "XCTestManifests.swift"),
      ]),
      FileItem(name: "LinuxMain.swift")
    ])
  ]
}

struct TestListView: View {
  let data: [FileItem]

  var body: some View {
//    List(data, children: \.children, rowContent: { Text($0.name) })
    HierarchyList(data: data, children: \.children, rowContent: { Text($0.name) })
  }
}

public struct HierarchyList<Data, RowContent>: View where Data: RandomAccessCollection, Data.Element: Identifiable, RowContent: View {
  private let recursiveView: RecursiveView<Data, RowContent>

  public init(data: Data, children: KeyPath<Data.Element, Data?>, rowContent: @escaping (Data.Element) -> RowContent) {
    self.recursiveView = RecursiveView(data: data, children: children, rowContent: rowContent)
  }

  public var body: some View {
    List {
      recursiveView
    }
  }
}

private struct RecursiveView<Data, RowContent>: View where Data: RandomAccessCollection, Data.Element: Identifiable, RowContent: View {
  let data: Data
  let children: KeyPath<Data.Element, Data?>
  let rowContent: (Data.Element) -> RowContent

  var body: some View {
    ForEach(data) { child in
      if let subChildren = child[keyPath: children] {
        DisclosureGroup(content: {
          RecursiveView(data: subChildren, children: children, rowContent: rowContent).padding(.leading)
        }, label: {
          rowContent(child)
        })
      } else {
        rowContent(child)
      }
    }
  }
}

struct FSDisclosureGroup<Label, Content>: View where Label: View, Content: View {
  @State var isExpanded: Bool = true
  var content: () -> Content
  var label: () -> Label

  var body: some View {
    DisclosureGroup(
      isExpanded: $isExpanded,
      content: content,
      label: label
    )
  }
}

struct FSDisclosureGroup2<Label, Content>: View where Label: View, Content: View {
  @State var isExpanded: Bool = false
  var content: () -> Content
  var label: () -> Label

  var body: some View {
    Button(action: { isExpanded.toggle() }, label: { label().foregroundColor(.blue) })
    if isExpanded {
      content()
    }
  }
}

private struct RecursiveView2<Data, RowContent>: View where Data: RandomAccessCollection, Data.Element: Identifiable, RowContent: View {
  let data: Data
  let children: KeyPath<Data.Element, Data?>
  let rowContent: (Data.Element) -> RowContent

  var body: some View {
    ForEach(data) { child in
      if self.containsSub(child)  {
        FSDisclosureGroup(content: {
          RecursiveView(data: child[keyPath: self.children]!, children: self.children, rowContent: self.rowContent)
          .padding(.leading)
        }, label: {
          self.rowContent(child)
        })
      } else {
        self.rowContent(child)
      }
    }
  }

  func containsSub(_ element: Data.Element) -> Bool {
    element[keyPath: children] != nil
  }
}

#if DEBUG
struct TestListView_Previews: PreviewProvider {
    static var previews: some View {
        let data = [FileItem]()
        return TestListView(data: data)
            .preferredColorScheme(.dark)
    }
}
#endif
