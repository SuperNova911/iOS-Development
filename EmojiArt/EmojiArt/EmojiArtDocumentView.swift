//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by 김수환 on 2020/09/17.
//  Copyright © 2020 Suwhan Kim. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTabToZoom(in: geometry.size)
                                .exclusively(before: singleTapToDeselectAllEmojis()))
                    if isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale(for: emoji))
                                .background(Circle()
                                                .stroke(lineWidth: 3)
                                                .foregroundColor(.red)
                                                .opacity(selectedEmojis.contains(matching: emoji) ? 1.0 : 0.0))
                                .position(self.position(for: emoji, in: geometry.size))
                                .gesture(dragEmojiGesture())
                                .gesture(tapToSelectEmoji(for: emoji))
                                .gesture(deleteEmojiGesture(for: emoji))
                        }
                    }
                }
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(document.$backgroundImage) { image in
                    zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y : location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != document.backgroundURL {
                        confirmBackgroundPaste = true
                    } else {
                        explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: $explainBackgroundPaste) {
                            Alert(title: Text("Paste Background"),
                                  message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document."),
                                  dismissButton: .default(Text("OK")))
                        }
                }))
            }
            .zIndex(-1)
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            Alert(title: Text("Paste Background"),
                  message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                  primaryButton: .default(Text("OK")) {
                    document.backgroundURL = UIPasteboard.general.url
                  },
                  secondaryButton: .cancel()
            )
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @State private var selectedEmojis: Set<EmojiArt.Emoji> = []
    
    private func tapToSelectEmoji(for emoji: EmojiArt.Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedEmojis.formSymmetricDifference([emoji])
            }
    }
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        if !selectedEmojis.isEmpty {
            return document.steadyStateZoomScale * 1.0
        } else {
            return document.steadyStateZoomScale * gestureZoomScale
        }
    }
    
    private func zoomScale(for emoji: EmojiArt.Emoji) -> CGFloat {
        if selectedEmojis.contains(matching: emoji) {
            return document.steadyStateZoomScale * gestureZoomScale
        } else {
            return zoomScale
        }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                if !selectedEmojis.isEmpty {
                    selectedEmojis.forEach { emoji in
                        document.scaleEmoji(emoji, by: finalGestureScale)
                    }
                } else {
                    document.steadyStateZoomScale *= finalGestureScale
                }
            }
    }
    
    private func singleTapToDeselectAllEmojis() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedEmojis.removeAll()
            }
    }
    
    private func doubleTabToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }

    @GestureState private var gestureDragEmojiOffset: CGSize = .zero
    
    private var dragEmojiOffset: CGSize {
        return gestureDragEmojiOffset * zoomScale
    }
    
    private func dragEmojiGesture() -> some Gesture {
        DragGesture()
            .updating($gestureDragEmojiOffset) { latestDragGestureValue, gestureDragEmojiOffset, transaction in
                gestureDragEmojiOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                selectedEmojis.forEach { emoji in
                    document.moveEmoji(emoji, by: finalDragGestureValue.translation / zoomScale)
                }
            }
    }
    
    private func deleteEmojiGesture(for emoji: EmojiArt.Emoji) -> some Gesture {
        LongPressGesture()
            .onEnded { _ in
                selectedEmojis.remove(emoji)
                document.removeEmoji(emoji)
            }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        if selectedEmojis.contains(matching: emoji) {
            location = CGPoint(x: location.x + dragEmojiOffset.width, y: location.y + dragEmojiOffset.height)
        }
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
