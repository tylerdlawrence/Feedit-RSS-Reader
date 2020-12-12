//
//  BatchImportView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/15/20.
//
//
//import SwiftUI
//import UIKit
//import UniformTypeIdentifiers
//
//struct BatchImportView: View {
//
//    let viewModel: BatchImportViewModel
//
//    @State private var isSheetPresented = false
//    @State private var isJSONHintPresented = true
//    @State private var buttonStatus: RoundRectangeButton.Status = .normal("Select File")
//    @State private var JSONText = ""
//
//    @ObservedObject private var pickerViewModel: DocumentPickerViewModel
//
//    init(viewModel: BatchImportViewModel) {
//        self.viewModel = viewModel
//        self.pickerViewModel = DocumentPickerViewModel()
//    }
//
//    var body: some View {
        //OPEN AND SAVE
//        VStack {
//            Text(fileName)
//                .fontWeight(.bold)
//
//            Button(action: {
//                openFile.toggle()
//            }, label: {
//                Text("Open")
//                    .foregroundColor(.white)
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 35)
//                    .background(Color.blue)
//                    .clipShape(Capsule())
//            })
//
//            Button(action: {
//                saveFile.toggle()
//            }, label: {
//                Text("Save")
//                    .foregroundColor(.white)
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 35)
//                    .background(Color.blue)
//                    .clipShape(Capsule())
//            })
//        }
//        .fileImporter(isPresented: self.$openFile, allowedContentTypes: [.json]) { (result) in
//            do {
//                let fileURL = try result.get()
//                self.fileName = fileURL.lastPathComponent
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        .fileExporter(isPresented: self.$saveFile, document: DocumentPicker(viewModel: Bundle.main.path(forResource: "default", ofType: "json")!), contentType: .json) { (result) in
//            do {
//                let fileURL = try result.get()
//                print(fileURL)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//
import SwiftUI

struct BatchImportView: View {
    
    let viewModel: BatchImportViewModel
    
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
        VStack {
            Text("Import")
                .font(.largeTitle)
                .fontWeight(.black)
                .padding(.top)
            HStack {
                if #available(iOS 14.0, *) {
                    Text("Supports Json Format")

                        .font(.system(size: 18, weight: .bold))
                        .fixedSize()
                        .padding(.leading, 20)
                } else {
                    // Fallback on earlier versions
                }
               //Spacer()
                Image(systemName: "chevron.down.circle")
                    .fixedSize()
                    .font(.system(size: 16, weight: .bold))
                    //.foregroundColor(.white)
                    .padding(.trailing, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .onTapGesture {
                self.isJSONHintPresented.toggle()
            }
            if isJSONHintPresented {
                Image("BatchImportImage")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40)/1.6)
                    .cornerRadius(8)
            }
            TextEditor(text: $JSONText) //, textStyle: .constant(.body))
                .frame(height: 300)
                .border(Color.gray, width: 1.0)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            Spacer()
            RoundRectangeButton(status: $buttonStatus) { status in
                switch status {
                case .error:
                    print("import error !!!")
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

//        VStack {
//            Text("Import")
//                .font(.largeTitle)
//                .fontWeight(.black)
//                .padding(.top)
//            HStack {
//                if #available(iOS 14.0, *) {
//                    Text("Supports Json Format")
//                        .font(.system(size: 18, weight: .bold))
//                        .fixedSize()
//                        .padding(.leading, 20)
//                } else {
//                    // Fallback on earlier versions
//                }
//               //Spacer()
//                Image(systemName: "chevron.down.circle")
//                    .fixedSize()
//                    .font(.system(size: 16, weight: .bold))
//                    //.foregroundColor(.white)
//                    .padding(.trailing, 20)
//            }
//            .padding(.top, 8)
//            .padding(.bottom, 8)
//            .onTapGesture {
//                self.isJSONHintPresented.toggle()
//            }
//            if isJSONHintPresented {
//                Image("BatchImportImage")
//                    .resizable()
//                    .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40)/1.6)
//                    .foregroundColor(.clear)
//                    .cornerRadius(12)
//            }
//            TextView(text: $JSONText, textStyle: .constant(.body))
//                .frame(height: 300)
//                .border(Color.gray, width: 1.0)
//                .padding(.leading, 20)
//                .padding(.trailing, 20)
//
//            Spacer()
//            RoundRectangeButton(status: $buttonStatus) { status in
//                switch status {
//                case .error:
//                    print("import error")
//                case .normal:
//                    print("normal")
//                    self.isSheetPresented = true
//                case .ok:
//                    self.viewModel.batchInsert(JSONText: self.JSONText)
//                    self.buttonStatus = .normal("Import Successful")
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
//                        self.buttonStatus = .normal("Select File")
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $isSheetPresented, content: {
//            DocumentPicker(viewModel: self.pickerViewModel)
//        })
//        .onReceive(self.pickerViewModel.$jsonURL, perform: { output in
//            guard let jsonURL = output else { return }
//            guard let jsonStr = try? String(contentsOf: jsonURL, encoding: .utf8) else {
//                return
//            }
//            self.JSONText = jsonStr
//            self.buttonStatus = .ok("Import")
//        })
//        .padding(.top, 20)
//        .padding(.bottom, 20)
//        .onDisappear {
//            self.viewModel.discardCreateContext()
//        }
//    }
//}
//
//struct DocumentManager: FileDocument {
//    var url: String
//    static var readableContentTypes: [UTType] { [.audio] }
//
//    init(url: String)  {
//        self.url = url
//    }
//
//    init(configuration: ReadConfiguration) throws {
//        url = ""
//    }
//
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        let file = try! FileWrapper(url: URL(fileURLWithPath: url), options: .immediate)
//        return file
//    }
//}

//struct BatchImportView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dataSource = DataSourceService.current.rss
//        return BatchImportView(viewModel: BatchImportViewModel(dataSource: dataSource))
//    }
//}
