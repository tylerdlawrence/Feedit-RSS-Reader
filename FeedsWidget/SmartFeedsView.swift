//
//  SmartFeedsView.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import WidgetKit
import SwiftUI

struct SmartFeedsView: View {
    
    
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        smallWidget
            .widgetURL(WidgetDeepLink.icon.url)
    }
    
    @ViewBuilder
    var smallWidget: some View {
        VStack(alignment: .leading) {
            Spacer()
            Link(destination: WidgetDeepLink.today.url, label: {
                HStack {
                    todayImage
                    VStack(alignment: .leading, spacing: nil, content: {
                        Text(formattedCount(entry.widgetData.currentTodayCount)).font(Font.system(.caption, design: .rounded)).bold()
                        Text(L10n.today).bold().font(.caption).textCase(.uppercase)
                    }).foregroundColor(.blue)
                    Spacer()
                }
            })
            
            Link(destination: WidgetDeepLink.unread.url, label: {
                HStack {
                    unreadImage
                    VStack(alignment: .leading, spacing: nil, content: {
                        Text(formattedCount(entry.widgetData.currentUnreadCount)).font(Font.system(.caption, design: .rounded)).bold()
                        Text(L10n.unread).bold().font(.caption).textCase(.uppercase)
                    }).foregroundColor(.blue)
                    Spacer()
                }
            })
            
            Link(destination: WidgetDeepLink.starred.url, label: {
                HStack {
                    starredImage
                    VStack(alignment: .leading, spacing: nil, content: {
                        Text(formattedCount(entry.widgetData.currentStarredCount)).font(Font.system(.caption, design: .rounded)).bold()
                        Text(L10n.starred).bold().font(.caption).textCase(.uppercase)
                    }).foregroundColor(.blue)
                    Spacer()
                }
            })
            Spacer()
        }.padding()
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
            .foregroundColor(.blue)
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
            .foregroundColor(.blue)
    }
    
    var todayImage: some View {
        Image(systemName: "sun.max.fill")
            .resizable()
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(.blue)
    }
    
}


struct SmartFeedsView_Previews: PreviewProvider {
    
    static var previews: some View {
        SmartFeedsView(entry: Provider.Entry.init(date: Date(), widgetData: WidgetDataDecoder.sampleData()))
    }
}

