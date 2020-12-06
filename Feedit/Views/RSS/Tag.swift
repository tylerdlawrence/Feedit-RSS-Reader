//
//  Tag.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 12/5/20.
//

import SwiftUI

struct Tag: View, Identifiable {
    
    var id = UUID()
    let tagName: String
    private(set) var uiColor: UIColor
    private(set) var showRemovalSymbol: Bool = false
    
    init(id: UUID? = nil, tagName: String, color: UIColor = .random()) {
        if id != nil {
            self.id = id!
        }
        self.tagName = tagName
        self.uiColor = color
    }
    
    var color: Color {
        Color(uiColor)
    }
    
    mutating func select(_ shouldSelect: Bool? = nil) {
        if shouldSelect != nil {
            showRemovalSymbol = shouldSelect!
        }else {
            showRemovalSymbol.toggle()
        }
    }
    
    mutating func changeColor(to newColor: UIColor) {
        self.uiColor = newColor
    }
    
    var body: some View {
            tagText(Color(.systemFill))
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color)
            )
            .overlay(tagText(.white))
        
    }
    func tagText(_ fontColor: Color = .primary) -> some View {
        HStack {
        Text(tagName)
            .font(.headline)
            .foregroundColor(fontColor)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 8)
            .fixedSize(horizontal: true, vertical: false)
            if showRemovalSymbol {
                Image(systemName: "x.square.fill")
                    .offset(x: -8)
                    .foregroundColor(.white)
                    Spacer()
                        .frame(maxWidth: 4)
            }
        }
        
    }
    
}


struct Tag_Previews: PreviewProvider {
    
    static var previews: some View {
        Tag.demoTags.randomElement()!
    }
}


extension Tag {
    static func makeTags(for tagNames: [String]) -> [Tag] {
        tagNames.map({Tag(tagName: $0)})
    }
    static var demoTags: [Tag] = Tag.makeTags(for: ["love", "blessed", "summer", "hot", "TIFU", "TIL", "photooftheday", "fashion", "beautiful", "selfie", "happy", "art", "tbt", "covid20", "like4like", "nature", "girl", "family", "travel", "fun"])
//    static func demoTags(_ count: Int = __demoTags.count) -> [Tag] {
//        let count = min(count, __demoTags.count)
//        return Array(repeating: __demoTags.randomElement()!, count: count)
//    }
}
/*
//Top hashtags from Twitter
#love
#instagood
#photooftheday
#fashion
#beautiful
#happy
#cute
#tbt
#like4like
#followme
#picoftheday
#follow
#me
#selfie
#summer
#art
#instadaily
#friends
#repost
#blessed
#nature
#girl
#fun
#style
#smile
#food
#instalike
#likeforlike
#family
#travel
#fitness
*/

extension Tag: Equatable, Hashable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id && lhs.showRemovalSymbol == rhs.showRemovalSymbol && lhs.color == rhs.color
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Tag: Codable {
    enum CodingKeys: String, CodingKey {
        case id, tagName, color
    }
    func encode(to encoder: Encoder) throws {
        let (red, blue, green, alpha) = uiColor.rgba
        let stringColor = "\(red),\(blue),\(green),\(alpha)"
        
        var container = encoder.container(keyedBy: Tag.CodingKeys.self)
        do {
            try container.encode(id, forKey: .id)
            try container.encode(tagName, forKey: .tagName)
            try container.encode(stringColor, forKey: .color)
        }
    }
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: Tag.CodingKeys.self)
            
            let id = try container.decode(UUID.self, forKey: .id)
            let tagName = try container.decode(String.self, forKey: .tagName)
            let componentsArray = try container.decode(String.self, forKey: .color).split(separator: ",").map({String($0)})
            
            let formatter = NumberFormatter()
            guard
                componentsArray.indices.count == 4,
                let red     =     formatter.number(from: componentsArray[0]),
                let green     =     formatter.number(from: componentsArray[1]),
                let blue    =     formatter.number(from: componentsArray[2]),
                let alpha     =     formatter.number(from: componentsArray[3])
            else {
                self.init(id: id, tagName: tagName)
                return
            }
            
            let color = UIColor(red: CGFloat(red.floatValue),
                                green: CGFloat(green.floatValue),
                                blue: CGFloat(blue.floatValue),
                                alpha: CGFloat(alpha.floatValue))
            
            self.init(id: id, tagName: tagName, color: color)
            
        }
    }
}


