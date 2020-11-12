//
//  BatchImportView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct BatchImportView: View {
    
//    @Environment(\.exportFiles) var exportAction

    let viewModel: BatchImportViewModel

    let type = UTType(filenameExtension: "opml")

    @State private var isSheetPresented = false
    @State private var isJSONHintPresented = false
    @State private var buttonStatus: RoundRectangeButton.Status = .normal("Select File")
    @State private var JSONText = ""

    @ObservedObject private var pickerViewModel: DocumentPickerViewModel

    init(viewModel: BatchImportViewModel) {
        self.viewModel = viewModel
        self.pickerViewModel = DocumentPickerViewModel()
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Import/ Export")
                .font(.largeTitle)
                .fontWeight(.black)

            if isJSONHintPresented {
                Image("BatchImportImage")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40)/1.6)
                    .cornerRadius(8)
            }
            TextView(text: $JSONText, textStyle: .constant(.body))
                .frame(height: 300)
                .border(Color.gray, width: 1.0)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            Spacer()
            RoundRectangeButton(status: $buttonStatus) { status in
                switch status {
                case .error:
                    print("import error")
                case .normal:
                    print("normal")
                    self.isSheetPresented = true
                case .ok:
                    self.viewModel.batchInsert(JSONText: self.JSONText)
                    self.buttonStatus = .normal("Import Successful")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                        self.buttonStatus = .normal("Select File")
                    }
                }
            }
        }
        .sheet(isPresented: $isSheetPresented, content: {
            DocumentPicker(viewModel: self.pickerViewModel)
        })
        .onReceive(self.pickerViewModel.$jsonURL, perform: { output in
            guard let jsonURL = output else { return }
            guard let jsonStr = try? String(contentsOf: jsonURL, encoding: .utf8) else {
                return
            }
            self.JSONText = jsonStr
            self.buttonStatus = .ok("Import")
        })
        .padding(.top, 20)
        .padding(.bottom, 20)
        .onDisappear {
            self.viewModel.discardCreateContext()
        }
    }
}

struct BatchImportView_Previews: PreviewProvider {
    static var previews: some View {
        let dataSource = DataSourceService.current.rss
        return BatchImportView(viewModel: BatchImportViewModel(dataSource: dataSource))
    }
}
            
//import UniformTypeIdentifiers
//
//
//struct BatchImportView: View {
//
//
//    let viewModel: BatchImportViewModel
//
//    @State var fileName = ""
//    @State var openFile = false
//    @State var saveFile = false
////    @State var importFile = false
//
//
//    @State private var isSheetPresented = false
//    @State private var isJSONHintPresented = false
//    @State private var buttonStatus: RoundRectangeButton.Status = .normal("Select File")
//    @State private var JSONText = ""
//
//    @ObservedObject private var pickerViewModel: DocumentPickerViewModel
//
//    init(viewModel: BatchImportViewModel) {
//        self.viewModel = viewModel
//        self.pickerViewModel = DocumentPickerViewModel()
//    }
    
//    var body: some View {
//        VStack(spacing: 25) {
//
//            Text(fileName)
//                .fontWeight(.bold)
//
//            Button(action: {openFile.toggle()}, label: {
//
//                Text("Open")
//            })
//
////            Button(action: {saveFile.toggle()}, label: {
////
////                Text("Save")
////            })
//            Button(action: {importFile.toggle()}, label: {
//
//                Text("Import")
//            })
//        }
//        .fileImporter(isPresented: $saveFile, allowedContentTypes: [.json]) { (res) in
//            do{
//                let fileURL = try res.get()
//
//                print(fileURL)
//
//                self.fileName = fileURL.lastPathComponent
//            }
//            catch{
//                print("error reading docs")
//                print(error.localizedDescription)
//            }
//        }
//
//        .fileExporter(isPresented: $saveFile, document: Doc(url: Bundle.main.path(forResource: "json", ofType: "json")!), contentType: .json) { (res) in
//
//            do{
//
//                let fileURL = try res.get()
//
//                print(fileURL)
//            }
//            catch{
//
//                print("cannot save doc")
//
//                print(error.localizedDescription)
//            }
//        }
//    }
//}
//
//struct Doc : FileDocument {
//
//    var url : String
//
//    static var readableContentTypes: [UTType]{[.json]}
//
//    init(url : String) {
//
//        self.url = url
//
//    }
//
//    init(configuration: ReadConfiguration) throws {
//
//        //desetilize the content
//        // we don't need to read contents...
//
//        url = ""
//    }
//
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//
//        //returning and saving file....
//
//        let file = try! FileWrapper(url: URL(fileURLWithPath: url), options: .immediate)
//
//        return file
//    }
//}
//    var body: some View {

//            HStack {
//                Text("Show the JSON format")
//                    .foregroundColor(.white)
//                    .font(.headline)
//                    .fixedSize()
//                    .padding(.leading, 20)
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .fixedSize()
//                    .foregroundColor(.white)
//                    .padding(.trailing, 20)
//            }
//            .padding(.top, 8)
//            .padding(.bottom, 8)
//            .background(Color(0xFFBA5C))
//            .onTapGesture {
//                self.isJSONHintPresented.toggle()
//            }
//        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//            if isJSONHintPresented {
//                Image("BatchImportImage")
//                    .resizable()
//                    .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40)/1.6)
//                    .cornerRadius(8)
//            }
//            TextView(text: $JSONText, textStyle: .constant(.body))
//                .frame(height: 300)
//                .border(Color.gray, width: 1.0)
//                .padding(.leading, 20)
//                .padding(.trailing, 20)
//            //Spacer()
