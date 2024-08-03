//
//  LocalePreview.swift
//
//
//  Created by Bakr mohamed on 03/08/2024.
//

import SwiftUI

public var previewLocale: Locale?

// MARK: - LocalePreviewContent
private struct LocalePreviewContent: Identifiable {
    let id = UUID()
    let device: PreviewDevice?
    let locale: Locale
}

// MARK: - LocalePreview
public struct LocalePreview<Content: View>: View {
    let content: () -> Content
    private let previewContent: [LocalePreviewContent]
    
    public init(
        previewDevices: [PreviewDevice],
        locales: [Locale.SupportedLocale],
        _ content: @escaping () -> Content
    ) {
        self.content = content
        self.previewContent = Self.preview(forDevices: previewDevices, locales: locales.map({$0.locale}))
    }
    
    private static func preview(
        forDevices previewDevices: [PreviewDevice],
        locales: [Locale]
    ) -> [LocalePreviewContent] {
        var previewContent = [LocalePreviewContent]()
        for locale in locales {
            guard !previewDevices.isEmpty else {
                previewContent.append(.init(device: nil, locale: locale))
                continue
            }
            for previewDevice in previewDevices {
                previewContent.append(.init(device: previewDevice, locale: locale))
            }
        }
        return previewContent
    }
    
    public var body: some View {
        ForEach(previewContent) { preview in
            content()
                .environment(\.locale, preview.locale)
                .environment(\.layoutDirection, preview.locale.layoutDirection)
                .previewDisplayName("\(preview.device?.rawValue ?? "") Locale: \(preview.locale.identifier)")
                .if(let: preview.device) { $0.previewDevice($1) }
                .onAppear {
                    previewLocale = preview.locale
                }
        }
    }
}

