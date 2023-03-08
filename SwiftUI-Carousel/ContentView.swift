//
//  ContentView.swift
//  SwiftUI-Carousel
//
//  Created by Shigenari Oshio on 2023/03/08.
//

import SwiftUI

struct ContentView: View {
    
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0
    
    @State var animals: [(name: String, color: Color)] = [
        ("tortoise", .green), ("ladybug", .red), ("ant", .brown)
    ]
    
    private let contentWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    private let spacing: CGFloat = 8
    
    var body: some View {
        contents
        // Apply offset
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        var tanslation = value.translation.width
                        let isScrollingOutOfBounds = (currentIndex == 0 && tanslation > 0) || (currentIndex == animals.count - 1 && tanslation < 0)
                        // Reduce scrolling volume
                        if isScrollingOutOfBounds { tanslation /= 3 }
                        
                        // Offset follows tanslation
                        offset = offset(of: currentIndex) + tanslation
                    }
                    .onEnded { value in
                        let translation = value.predictedEndTranslation.width
                        
                        // Update index
                        let shouldUpdateIndex = abs(translation) > contentWidth / 2
                        if shouldUpdateIndex {
                            let newIndex = translation < 0 ? currentIndex + 1 : currentIndex - 1
                            currentIndex = newIndex.clamp(to: animals.indices)
                        }
                        
                        // Update offset
                        offset = offset(of: currentIndex)
                    }
            )
        //Animating offset changes
            .animation(
                .spring(response: 0.2, dampingFraction: 1),
                value: offset
            )
        
    }
    
    private var contents: some View {
        HStack(spacing: spacing) {
            ForEach(animals, id: \.name) { (name, color) in
                Image(systemName: name)
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .frame(width: contentWidth, height: 200)
                    .background(color)
                    .cornerRadius(16)
                // Use 'onTapGesture' modifier instead of using 'Button' as content, because DragGesture do not work properly.
                    .onTapGesture {
                        print(name)
                    }
            }
        }
        // Adjust to display first content
        .offset(x: (contentWidth + spacing) * CGFloat(animals.count - 1) / 2)
    }
    
    private func offset(of index: Int) -> CGFloat {
        -((contentWidth + spacing) * CGFloat(index))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private extension Comparable where Self == Int {
    func clamp(to range: Range<Self>) -> Self {
        return max(range.lowerBound, min(range.upperBound - 1, self))
    }
}

