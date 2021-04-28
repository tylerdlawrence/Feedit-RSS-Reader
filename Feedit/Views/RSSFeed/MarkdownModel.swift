//
//  ParmaDetailView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/26/21.
//

import SwiftUI
import Parma
import Foundation
import UIKit

enum MarkdownType{
    case header
    case image
    case link
    case text
    case spacer
}

public struct MarkdownNode : Identifiable{
    public var id = UUID()
    var type: MarkdownType
    var content: String
    var link: String?
}

public class MarkdownParser {
    private var makrdown: String

    /**
     Parse header including tag
     */
    let headerPattern = #"(#+)(.*)"#
    /**
     Use this to match header tag, eg. #, ##, ###
     */
    let headerTagPattern = #"(#+) "#
    /**
     Match any image. Use this before link
     */
    let imagePattern = #"!\[(.*)\]\(([^)]+)\)"#
    /**
     Match any link
     */
    let linkPattern = #"\[([^\[]+)\]\(([^\)]+)\)"#
    /**
     Link tag
     */
    let linkTagPattern = #"\[([^\[]+)\]"#

    /**
     Match link's link
     */
    let linkLinkPattern = #"\(([^)]+)\)"#


    init(markdown: String) {
        self.makrdown = markdown
    }

    /**
     Parse markdown into markdown nodes
     */
    func parseMarkdown() -> [MarkdownNode] {
        var nodes: [MarkdownNode] = []

        let lines = self.makrdown.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            if line.count == 0 {
                continue
            }
            nodes += parse(line)
            if index < lines.count - 1 {
                nodes.append(MarkdownNode(type: .spacer, content: ""))
            }
        }
        return nodes
    }


    private func parse(_ markdownStr: String) -> [MarkdownNode] {
        let headerRegex = try! NSRegularExpression(pattern: headerPattern)
        let imageRegex = try! NSRegularExpression(pattern: imagePattern)

        let header = headerRegex.firstMatch(in: markdownStr, range: NSRange(markdownStr.startIndex..., in: markdownStr)).map {
            String(markdownStr[Range($0.range, in: markdownStr)!])
        }

        let image = imageRegex.firstMatch(in: markdownStr, range: NSRange(markdownStr.startIndex..., in: markdownStr)).map {
            String(markdownStr[Range($0.range, in: markdownStr)!])
        }

        // If the header
        if let header = header {
            return [parseHeader(header)]
        }

        if let image = image {
            return [parseImage(image)]
        }
        /**
         parse link
         */
        let contentStr = parseLink(markdownStr)

        let firstPartText = contentStr.start
        let link_node = contentStr.link_node
        let secondPartText = contentStr.end

        let firstPartNode = MarkdownNode(type: .text, content: firstPartText)

        if let link_node = link_node {
            if let secondPartText = secondPartText {
                return [firstPartNode, link_node] + parse(secondPartText)
            }
            return [firstPartNode, link_node]
        }
        /**
        End parse link
         */

        return [firstPartNode]

    }


    /**
     Parse  header
     */
    private func parseHeader(_ headerMarkdown: String) -> MarkdownNode {
        let headerRange = headerMarkdown.range(of: self.headerTagPattern, options: .regularExpression)
        if let headerRange = headerRange {
            let content = headerMarkdown.replacingCharacters(in: headerRange, with: "")
            return MarkdownNode(type: .header, content: content)
        }
        return MarkdownNode(type: .header, content: "")
    }

    /**
     Parse Image
     */
    private func parseImage(_ imageMarkdown: String) -> MarkdownNode {
        let linkRegex = try! NSRegularExpression(pattern: self.linkLinkPattern)
        let link = linkRegex.firstMatch(in: imageMarkdown, range: NSRange(imageMarkdown.startIndex..., in: imageMarkdown)).map {
            String(imageMarkdown[Range($0.range, in: imageMarkdown)!])
        }
        if let link = link {
            let linkStr = link[1..<link.count - 1]
            return MarkdownNode(type: .image, content: "", link: linkStr)

        }
        return MarkdownNode(type: .image, content: "")

    }

    private func parseContent(_ contentMarkdown: String) -> MarkdownNode {
        return MarkdownNode(type: .text, content: contentMarkdown)
    }

    /**
     Replace any link markdown to its content.
     [abc](link) -> abc
     */
    private func parseLink(_ markdown: String) -> (link_node: MarkdownNode?, start: String, end: String?) {

        let linkRegex = try! NSRegularExpression(pattern: linkPattern)
        let linkRange = linkRegex.firstMatch(in: markdown, range: NSRange(markdown.startIndex..., in: markdown))?.range



        if let linkRange = linkRange {
            // link itself
            let linkPartStr = markdown[linkRange.lowerBound..<linkRange.upperBound]


            let linkTagRex = try! NSRegularExpression(pattern: linkTagPattern)
            let linkTextRange = linkTagRex.firstMatch(in: linkPartStr, range: NSRange(linkPartStr.startIndex..., in: linkPartStr))?.range

            if let linkTextRange = linkTextRange {
                let linktag = String(linkPartStr[Range(linkTextRange, in: linkPartStr)!])

                // link text
                let linkText = linktag[1..<linktag.count - 1]

                // text before link
                let firstPartStr = markdown.prefix(linkRange.lowerBound)
                // text after link
                let secondPartStr = markdown.suffix(markdown.count - linkRange.upperBound)

                // link url
                var linkURLStr = linkPartStr.replacingOccurrences(of: "[\(linkText)]", with: "")
                linkURLStr = linkURLStr[1..<linkURLStr.count - 1]

                let linkNode = MarkdownNode(type: .link, content: linkText, link: linkURLStr)

                return (linkNode, String(firstPartStr), String(secondPartStr))
            }


        }

        return (nil, markdown, nil)
    }

}


extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIView.ContentMode) {
       
        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
               DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

struct ParmaDetailView: View {
    @State var markdown: String = ""
    var body: some View {
        ScrollView {
            Parma(markdown)
                .padding(.horizontal, 24)
        }
//        .onAppear {
//            let url = Bundle.main.url(forResource: "ContinuousIntegration", withExtension: "md")!
//            markdown = try! String(contentsOf: url)
//        }
    }
}

struct ParmaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ParmaDetailView()
        }.preferredColorScheme(.dark)
    }
}
