//
//  WatchListView.swift
//  feeelmback
//
//  Created by Renato Duraccio on 07/12/22.
//

import SwiftUI

struct WatchListView: View {
    
    @ObservedObject var mymovieData = sharedData
    @State var myWatchlist:[Film] = []
    
    
    var body: some View {

        NavigationView{
            
            List{
                
                                ForEach(myWatchlist){ movie in
                                        NavigationLink(destination:
                                                        movieView(movie:movie, emoji: "no")){
                
                                            FilmINWhatchlist(poster: movie.poster_path ?? "/lKyd7HGlDDUuRz4YhdY90uhTJ9T.jpg", nome: movie.title, score: String(movie.vote_average), genre: String(movie.genre_ids[0]), year: movie.release_date ?? "No Relase Date")
                                        }
                                    } .onDelete(perform: delete)
            }.scrollContentBackground(.hidden)
                .navigationTitle("WATCHLIST")
                .onAppear(){
                    Task{
                        myWatchlist = mymovieData.watchlist
                    }
                }
            
            
        }
    }
    
    
        func delete(at offsets: IndexSet) {
               myWatchlist.remove(atOffsets: offsets)
            mymovieData.watchlist = myWatchlist
           }
        }
    
    struct WatchListView_Previews: PreviewProvider {
        static var previews: some View {
            WatchListView()
        }
    }

