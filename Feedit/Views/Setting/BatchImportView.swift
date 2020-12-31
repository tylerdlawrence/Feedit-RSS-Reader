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
        
    let viewModel: BatchImportViewModel
    
    @State private var isSheetPresented = false
    @State private var isJSONHintPresented = false
    @State private var buttonStatus: RoundRectangeButton.Status = .normal("Select File")
    @State private var JSONText = ""
    
    @ObservedObject private var pickerViewModel: DocumentPickerViewModel
    
    @State private var document: MessageDocument = MessageDocument(message: "")

    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    
    init(viewModel: BatchImportViewModel) {
        self.viewModel = viewModel
        self.pickerViewModel = DocumentPickerViewModel()
    }
    
    var body: some View {
        
        //VStack {
            GroupBox(label: Text("Import & Export Feeds")) {
                TextEditor(text: $document.message)
            }
        
        GroupBox {
            HStack {
                Spacer()
                
                Button(action: {
                    isImporting = false
                    
                    //fix broken picker sheet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isImporting = true
                    }
                }, label: {
                    Text("Import File")
                })
                
                Spacer()
                
                Button(action: {
                    isExporting = false
                    
                    //fix broken picker sheet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isExporting = true
                    }
                    
                }, label: {
                    Text("Export File")
                })
                
                Spacer()
            }
        }
   // }
    .padding()
    .fileImporter(
        isPresented: $isImporting,
        allowedContentTypes: [UTType.plainText],
        allowsMultipleSelection: false
    ) { result in
        do {
            guard let selectedFile: URL = try result.get().first else { return }
            
            //trying to get access to url contents
            if (CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL)) {
                
                guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                
                document.message = message
                    
                //done accessing the url
                CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
            }
            else {
                print("Permission error!")
            }
        } catch {
            // Handle failure.
            print(error.localizedDescription)
        }
    }
    .fileExporter(
        isPresented: $isExporting,
        document: document,
        contentType: UTType.plainText,
        defaultFilename: "feedit-file"
    ) { result in
        if case .success = result {
            // Handle success.
        } else {
            // Handle failure.
        }
    }
        
        VStack {
//            TextEditor(text: $JSONText) //, textStyle: .constant(.body))
//                .frame(height: 250)
//                .border(Color.gray, width: 1.0)
//                .padding(.leading, 20)
//                .padding(.trailing, 20)
            //Spacer()
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

struct MessageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.plainText] }

    var message: String

    init(message: String) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
}
