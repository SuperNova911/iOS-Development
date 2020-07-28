//
//  ContentView.swift
//  Memorize
//
//  Created by 김수환 on 2020/07/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                CardView(isFaceUp: false)
            }
        }
        .foregroundColor(Color.orange)
        .padding()
        .font(Font.largeTitle)
    }
}

struct CardView: View{
    var isFaceUp: Bool
    
    var body: some View {
        ZStack {
            if isFaceUp {
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                RoundedRectangle(cornerRadius: 10).fill(Color.white)
                Text("👻 Boo")
            } else {
                RoundedRectangle(cornerRadius: 10).fill()
            }

            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
