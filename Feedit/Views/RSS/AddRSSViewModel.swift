//
//  AddRSSSourceViewModel.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import UIKit
import SwiftUI
import Combine

class AddRSSViewModel: NSObject, ObservableObject {
    
    @Published var rss: RSS?
    
    let dataSource: RSSDataSource
    
    init(dataSource: RSSDataSource) {
        self.dataSource = dataSource
        
        super.init()
        beginCreateNewRSS()
    }
    
    func beginCreateNewRSS() {
        dataSource.discardNewObject()
        dataSource.prepareNewObject()
        rss = dataSource.newObject
    }
        
    func commitCreateNewRSS() {
        dataSource.saveCreateContext()
    }
        
    func cancelCreateNewRSS() {
        dataSource.discardCreateContext()
    }
}

class TagViewModel: ObservableObject {
    
    @Published var availableTags: [Tag] = Tag.demoTags
    @Published var selectedTags: [Tag] = []
    @Published var postTitle: String = ""
    @Published var postBody: String = ""
    
    var image: Image? {
        if let img = uiImage {
            return Image(uiImage: img)
        }
        return nil
    }
    private var uiImage: UIImage?
    private var imageURL: URL?
    
    
    @Published var postReady: Bool = false
    private var postReadySub: AnyCancellable?
    
//    private var imageSub: AnyCancellable?
//    private var imagePub: AnyPublisher<PostManagerFetchResponse, PostManagerError>?
    
    private var randomImageSubs = Set<AnyCancellable>()
    
    private var postReadyPublisher: AnyPublisher<Bool, Never>?
    
    init() {
//        fetchNewImage()
        monitorFormFields()
    }
    
    func selectTag(_ tag: Tag) {
        withAnimation {
            if let t = availableTags.first(where: { $0 == tag }) {
                availableTags.removeAll(where: {$0 == t })
                var new = t
                new.select(true)
                selectedTags.insert(new, at: 0)
            }else if let t = selectedTags.first(where: {$0 == tag }) {
                selectedTags.removeAll(where: {$0 == t })
                var new = t
                new.select(false)
                availableTags.append(new)
            }
        }
    }
    
    func resetSubs() {
        availableTags.append(contentsOf: selectedTags)
        postTitle = ""
        postBody = ""
        uiImage = nil
        imageURL = nil
        postReady = false
        
//        imageSub?.cancel()
//        imagePub = nil
        
        randomImageSubs.forEach({$0.cancel()})
        randomImageSubs.removeAll()
        postReadyPublisher = nil
    }
    
//    func createPost(_ completion: ((Result<Bool, PostManagerError>) -> Void)?) {
//        guard postReady, let img = uiImage, let url = imageURL else { fatalError() }
//        let newPost = Post.NewPostInput(id: UUID().uuidString, image: img, imageURL: url,title: postTitle, body: postBody, tags: selectedTags)
//        PostsManager.shared.createPost(newPost) { res in
//            switch res {
//            case .success(let posts):
//                print(posts.count)
//                DispatchQueue.main.async {
//                    self.resetSubs()
//                    completion?(.success(true))
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//                completion?(.failure(error))
//            }
//        }
//    }
    
    func changeColor(forSelectedTag tag: Tag) {
        if let idx = selectedTags.firstIndex(where: { $0 == tag }) {
            
            withAnimation(.easeOut(duration: 0.3)) {[weak self] in
                self?.selectedTags[idx].changeColor(to: UIColor.random(opacityLowerBound: 0.5, opacityUpperBound: 1))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {[weak self] in
                guard let self = self, self.selectedTags.indices.contains(idx) else { return }
                self.selectTag(self.selectedTags[idx])
            }
        }
    }
    
    
//    func fetchNewImage(completion: (() -> Void)? = nil) {
////        imageSub?.cancel()
////        imagePub = PostsManager.shared.randomImage()
////        imageSub = imagePub?
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: {[weak self] (res) in
//                switch res {
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    self?.uiImage = nil //Image(systemName: "person.crop.circle.fill")
//                case .finished:
//                    print("Yay")
//                }
//            }, receiveValue: {[weak self] (output) in
//                DispatchQueue.main.async {
//                    self?.objectWillChange.send()
//                    if let urlString = output.url?.absoluteString {
//                        let correctedURL = PostsManager.shared.urlFromReturnedImageAbsoluteString(urlString)
//                        self?.imageURL = correctedURL
//                        print("Got Image from:\nURL: \(correctedURL?.absoluteString ?? "ERROR")")
//                    }
//                    self?.uiImage = output.image
//                    completion?()
//                }
//            })
//    }
    
    func monitorFormFields() {
        postReadyPublisher = Publishers.CombineLatest($postTitle, $postBody)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map({output in
                if output.0.trimmingCharacters(in: .whitespaces) != "",
                   output.1.trimmingCharacters(in: .whitespaces) != ""
                {
                    return true
                }
                return false
            })
            .eraseToAnyPublisher()
        
        postReadySub = postReadyPublisher?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] ready in
                DispatchQueue.main.async {
                    self?.postReady = ready
                }
            })
    }
}

