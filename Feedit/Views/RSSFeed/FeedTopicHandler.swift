//
//  FeedTopicHandler.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/27/21.
//

import CoreML
import NaturalLanguage
import Foundation

class FeedTopicHelper {
    static var classNames:[String] = ["News", "iPhone", "iPad", "Mac", "Tutorial", "Review"]
    
    func getTopic(forText text:String) -> String? {
        var topic:String?
        if let classifier = topicClassifier {
            topic = classifier.predictedLabel(for: text)
        }
        else {
            let words = wordsFromText(text: text)
            if let model = try? AppleTopicsTC(configuration: MLModelConfiguration()),
               let prediction = try? model.prediction(text:words) {
                topic = prediction.label
            }
        }
        return topic
    }
    
    // MARK: - Private
    
    private func wordsFromText(text:String) -> [String:Double] {
        var bagOfWords = [String: Double]()
        
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        let range = NSRange(location: 0, length: text.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.string = text.lowercased()
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { _, tokenRange, _ in
            let word = (text as NSString).substring(with: tokenRange)
            if bagOfWords[word] != nil {
                bagOfWords[word]! += 1
            } else {
                bagOfWords[word] = 1
            }
        }
        
        return bagOfWords
    }
    
    private lazy var topicClassifier: NLModel? = {
        if let topicClassifier = try? AppleTopics(configuration: MLModelConfiguration()).model,
           let model = try? NLModel(mlModel: topicClassifier) {
            print(topicClassifier)
            print(model)
            return model
        }
        return nil
    }()
}
