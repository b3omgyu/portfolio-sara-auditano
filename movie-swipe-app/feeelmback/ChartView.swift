//
//  ChartView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 15/12/22.
//

import SwiftUI
import Charts

struct Data: Identifiable {
    
    var id = UUID()
    var emoji: String
    var num: Int
}


struct ChartView: View {
    
    @ObservedObject var mymovieData = sharedData
    
    
    var body: some View {
        
        let dati: [Data] = [
               Data(emoji: "😁", num: getNEmojis(emoji: "😁")),
               Data(emoji: "🤣", num: getNEmojis(emoji: "🤣")),
               Data(emoji: "🥰", num: getNEmojis(emoji: "🥰")),
               Data(emoji: "😔", num: getNEmojis(emoji: "😔")),
               Data(emoji: "🤡", num: getNEmojis(emoji: "🤡")),
               Data(emoji: "🌶️", num: getNEmojis(emoji: "🌶️")),
               Data(emoji: "🪩", num: getNEmojis(emoji: "🪩")),
               Data(emoji: "⛪️", num: getNEmojis(emoji: "⛪️")),
               Data(emoji: "🌋", num: getNEmojis(emoji: "🌋")),
               Data(emoji: "👽", num: getNEmojis(emoji: "👽")),
               Data(emoji: "🦄", num: getNEmojis(emoji: "🦄")),
               Data(emoji: "🧞‍♂️", num: getNEmojis(emoji: "🧞‍♂️")),
           ]
            
            Chart(dati) { data in
                BarMark(
                    x: .value("Emoji", data.emoji),
                    y: .value("Number", data.num))
                .foregroundStyle(Color("AccentColor"))
            }
            .frame(width: 380, height: 200)
    }
    
    func getNEmojis (emoji: String) -> Int{
        var num: Int
        var mymovies:[Film] = []
        
        
        mymovies = mymovieData.seen
        mymovies.removeAll(where: {!($0.emoji == emoji)})
        num = mymovies.count
        return num
    }
    
}

