//
//  SizeCategories.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 3/24/21.
//

import SwiftUI

struct SizeCategories {
    
    let largeSizeCategories: [ContentSizeCategory] = [.extraExtraLarge,
                                                      .extraExtraExtraLarge,
                                                      .accessibilityMedium,
                                                      .accessibilityLarge,
                                                      .accessibilityExtraLarge,
                                                      .accessibilityExtraExtraLarge,
                                                      .accessibilityExtraExtraExtraLarge]
    
    
    func isSizeCategoryLarge(category: ContentSizeCategory) -> Bool {
        largeSizeCategories.filter{ $0 == category }.count == 1
    }
    
}
