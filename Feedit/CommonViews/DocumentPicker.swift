//
//  DocumentPicker.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI

class DocumentPickerViewModel: ObservableObject {
    
//@Environment(\.exportFiles) var exportAction

    @Published var jsonURL: URL?
}
//Button("Export") {
//    let url = Bundle.main.url(forResource: "default", withExtension: "json")!
//    
//    exportAction(moving: url) { result in
//        switch result {
//        case .success(let url):
//            print("Success! Moved to: \(url)")
//        case .failure(let error):
//            print("Oops: \(error.localizedDescription")
//        case .none:
//            print("Cancelled")
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
        
        func sendFileWithURL(_ url: URL, completion: @escaping ((_ error: Error?) -> Void)) {
            func finish(_ error: Error?) {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        
        
        DispatchQueue(label: "DownloadingFileData." + UUID().uuidString).async {
                do {
                    let data: Data = try Data(contentsOf: url)
                    _ = data.base64EncodedString()
                    // TODO: send string to server and call the completion
                    finish(nil)
                } catch {
                    finish(error)
                }
            }
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            urls.forEach { sendFileWithURL($0) {_ in
                }
            }
        }
        
        let picker = UIDocumentPickerViewController(documentTypes: [], in: .import)
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
