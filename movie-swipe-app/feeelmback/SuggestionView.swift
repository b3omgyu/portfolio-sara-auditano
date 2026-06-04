//
//  SuggestionView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 08/12/22.
//

import SwiftUI

struct SuggestionView: View {
    var keyword : String
    var adult: String
    var emoji: String
    @State var myMovies:[Film] = []
    @ObservedObject var mymovieData = sharedData
    var body: some View {
            VStack{
                VStack {
                    Text("Swipe left to discard")
                    Text("Swipe right to add to your watchlist")
                }.padding().offset(y: -20)
                ZStack{
                    Text("That's it for today")
                    ForEach(myMovies){movie in
                        VStack {
                            SwipeView(movie: movie, emoji: emoji)
                        }
                    }
            }
        }.task {
            myMovies = try! await FilmAPI.getMovie(pagine: 2, anno: 0, keyword: keyword, adult: adult, emoji: emoji)
            myMovies.reverse()
        }
    }
}
