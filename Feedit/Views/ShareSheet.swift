//
//  ShareSheet.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/7/21.
//

import SwiftUI

struct Screen: View {
    @State var show = false
    @State var items: [Any] = []
    var body: some View {
        VStack {
            Button(action: {
                self.items.removeAll()
                self.items.append(UIImage(named: "886F0165-77FA-4778-8E50-8DD24B230839.jpg") as Any)
                self.show.toggle()
            }) {
                Text("Share Article")
                Image(systemName: "square.and.arrow.up")
            }.sheet(isPresented: $show) {
                ShareSheetView(items: self.items).edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> some UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Screen()
    }
}
