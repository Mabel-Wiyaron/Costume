//
//  BindingConversions.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

// Binding extension for URL? to get and set non-optional String values
extension Binding where Value == URL? {
    var stringValue: Binding<String> {
        Binding<String>(
            get: { wrappedValue?.absoluteString ?? "" },
            set: { newValue in
                wrappedValue = newValue.isEmpty ? nil : URL(string: newValue)
            }
        )
    }
}

// Binding extension for String? to get and set non-optional String values
extension Binding where Value == String? {
    var stringValue: Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { newValue in
                wrappedValue = newValue.isEmpty ? nil : newValue
            }
        )
    }
}

// Binding extension for [ProfileLink] to get and set URL strings based on platform
extension Binding where Value == [ProfileLink] {
    func urlString(forPlatform platform: LinkPlatform) -> Binding<String> {
        Binding<String>(
            get: {
                wrappedValue.first(where: { $0.platform == platform })?.url.absoluteString ?? ""
            },
            set: { newValue in
                if let existingLink = wrappedValue.first(where: { $0.platform == platform }) {
                    if newValue.isEmpty {
                        wrappedValue.removeAll { $0.platform == platform }
                    } else if let url = URL(string: newValue) {
                        existingLink.url = url
                    }
                } else if !newValue.isEmpty, let url = URL(string: newValue) {
                    wrappedValue.append(ProfileLink(platform: platform, url: url))
                }
            }
        )
    }
}
