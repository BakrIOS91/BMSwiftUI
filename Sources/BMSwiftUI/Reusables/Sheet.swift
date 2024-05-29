//
//  SwiftUIView.swift
//  
//
//  Created by Bakr mohamed on 29/05/2024.
//

import SwiftUI
struct Sheet<ContentView: View>: ViewModifier {
    
    @Binding private var isPresented: Bool
    @State private var showsContent: Bool = false
    @State private var contentSize: CGSize = .zero
    private var contentView: () -> ContentView
    
    init(
        isPresented: Binding<Bool>,
        @ViewBuilder contentView: @escaping () -> ContentView
    ) {
        self._isPresented = isPresented
        self.contentView = contentView
    }
    
    func body(
        content: Content
    ) -> some View {
        content
            .overlay(contentSheetView)
    }
    
    private var contentSheetView: some View {
        ZStack {
            Color.white
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
                .isHidden(!showsContent)
                .edgesIgnoringSafeArea(.bottom)
                .readSize { contentSize = $0 }
            
            VStack {
                Spacer()
                contentView()
                    .contentShape(Rectangle())
            }
            .isHidden(!showsContent)
            .transition(.move(edge: .bottom))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: isPresented) { newValue in
            withAnimation { showsContent = newValue }
        }
    }
}

public extension View {
    
    func contentSheet<Item, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder contentView: @escaping (Item) -> Destination
    ) -> some View {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in if !value { item.wrappedValue = nil } }
        )
        
        return contentSheet(isPresented: isActive) {
            item.wrappedValue.map(contentView)
        }
    }
    
    func contentSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder contentView: @escaping () -> Content
    ) -> some View {
        modifier(
            Sheet(
                isPresented: isPresented,
                contentView: contentView
            )
        )
    }
    
}
