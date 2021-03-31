//
//  DocumentPicker.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI
import UIKit
import FeedKit

class DocumentPickerViewModel: ObservableObject {
    
    @Published var jsonURL: URL?
}

struct DocumentPicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        private var viewModel: DocumentPickerViewModel
        
        init(viewModel: DocumentPickerViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            self.viewModel.jsonURL = urls.first
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            self.viewModel.jsonURL = nil
        }
    }
    
    @ObservedObject var viewModel: DocumentPickerViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        
        let picker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .import)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {

    }

    func makeCoordinator() -> DocumentPicker.Coordinator {
        return Coordinator(viewModel: viewModel)
    }
}

struct DocumentPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentPicker(viewModel: DocumentPickerViewModel())
    }
}
