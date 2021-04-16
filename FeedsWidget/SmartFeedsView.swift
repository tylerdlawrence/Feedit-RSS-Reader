//
//  SmartFeedsView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import SwiftUI
import WidgetKit
import CoreData
import Foundation

struct SmartFeedSummaryWidgetView: View {
    
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        smallWidget
            .widgetURL(WidgetDeepLink.icon.url)
            
    }
    
    @ViewBuilder
    var smallWidget: some View {
        ZStack(alignment: .topLeading) {
//            Image("launch")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .opacity(0.4).padding([.top, .leading], -25)
//                .frame(width: 135, height: 135)
        
            VStack(alignment: .leading) {
                Spacer()
                Link(destination: WidgetDeepLink.today.url, label: {
                    HStack {
                        todayImage
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(formattedCount(entry.widgetData.currentTodayCount)).font(Font.system(.caption, design: .rounded)).bold()
                            Text(L10n.today).font(.caption).textCase(.uppercase).foregroundColor(.gray)
                        })
                        Spacer()
                    }
                })
                
                Link(destination: WidgetDeepLink.unread.url, label: {
                    HStack {
                        unreadImage
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(formattedCount(entry.widgetData.currentUnreadCount)).font(Font.system(.caption, design: .rounded)).bold()
                            Text(L10n.unread).font(.caption).textCase(.uppercase).foregroundColor(.gray)
                        })
                        Spacer()
                    }
                })
                
                Link(destination: WidgetDeepLink.starred.url, label: {
                    HStack {
                        starredImage
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(formattedCount(entry.widgetData.currentStarredCount)).font(Font.system(.caption, design: .rounded)).bold()
                            Text(L10n.starred).font(.caption).textCase(.uppercase).foregroundColor(.gray)
                        })
                        Spacer()
                    }
                })
                Spacer()
            }//.background(Color(UIColor.systemBackground).blur(radius: 10.0).opacity(0.5))
            .padding()
        }
    }
    
    func formattedCount(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count))!
    }
    
    var unreadImage: some View {
        Image(systemName: "largecircle.fill.circle")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(Color("tab"))
    }
    
    var nnwImage: some View {
        Image("CornerIcon")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .cornerRadius(4)
    }
    
    var starredImage: some View {
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(Color("tab"))
    }
    
    var todayImage: some View {
        Image(systemName: "chart.bar.doc.horizontal")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(Color("tab"))
    }
}

struct SmartFeedSummaryWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmartFeedSummaryWidgetView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .dark)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SmartFeedSummaryWidgetView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
                .background(Color(UIColor.systemBackground)).environment(\.colorScheme, .light)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

struct SmartFeedSummaryWidget: Widget {
    let kind: String = "SmartFeedSummaryWidget"
    
    var body: some WidgetConfiguration {
        
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            SmartFeedSummaryWidgetView(entry: entry)
        })
        .configurationDisplayName(L10n.smartFeedSummaryWidgetTitle)
        .description(L10n.smartFeedSummaryWidgetDescription)
        .supportedFamilies([.systemSmall])
        
    }
}



