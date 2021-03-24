//
//  WidgetBundle.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import WidgetKit
import SwiftUI

// MARK: - Supported Widgets

struct UnreadWidget: Widget {
    let kind: String = "com.ranchero.NetNewsWire.UnreadWidget"
    
    var body: some WidgetConfiguration {
        
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            UnreadWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
            
        })
        .configurationDisplayName(L10n.unreadWidgetTitle)
        .description(L10n.unreadWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
        
    }
}

struct AllArticlesWidget: Widget {
    let kind: String = "com.ranchero.NetNewsWire.TodayWidget"
    
    var body: some WidgetConfiguration {
        
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            AllArticlesWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
            
        })
        .configurationDisplayName(L10n.todayWidgetTitle)
        .description(L10n.todayWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
        
    }
}

struct StarredWidget: Widget {
    let kind: String = "com.ranchero.NetNewsWire.StarredWidget"
    
    var body: some WidgetConfiguration {
        
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            StarredWidgetView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
            
        })
        .configurationDisplayName(L10n.starredWidgetTitle)
        .description(L10n.starredWidgetDescription)
        .supportedFamilies([.systemMedium, .systemLarge])
        
    }
}

struct SmartFeedSummaryWidget: Widget {
    let kind: String = "com.ranchero.NetNewsWire.SmartFeedSummaryWidget"
    
    var body: some WidgetConfiguration {
        
        return StaticConfiguration(kind: kind, provider: Provider(), content: { entry in
            SmartFeedsView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("AccentColor"))
            
        })
        .configurationDisplayName(L10n.smartFeedSummaryWidgetTitle)
        .description(L10n.smartFeedSummaryWidgetDescription)
        .supportedFamilies([.systemSmall])
        
    }
}


// MARK: - WidgetBundle
@main
struct FeeditWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        UnreadWidget()
        AllArticlesWidget()
        StarredWidget()
        SmartFeedSummaryWidget()
    }
}

