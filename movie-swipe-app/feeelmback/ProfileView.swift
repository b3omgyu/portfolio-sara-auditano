//
//  ProfileView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 09/12/22.
//

import SwiftUI

struct ProfileView: View {
    
    
    @State var myMovies:[Film] = []
    @ObservedObject var mymovieData = sharedData

    var body: some View {
        NavigationView{
            VStack {
                    HeatherProfilo(cover: mymovieData.seen.last?.backdrop_path ?? "/sRvXNDItGlWCqtO3j6wks52FmbD.jpg", pfp: mymovieData.profilo.pfp, username: mymovieData.profilo.username).padding(.bottom, 30)
                
                ScrollView {
                    VStack (alignment: .leading){
                        Text("The movies you watched...").padding(.horizontal, 5)
                        ScrollView (.horizontal, showsIndicators: false){
                            HStack{
                                if(!mymovieData.seen.isEmpty){
                                ForEach(mymovieData.seen){movie in
                                    NavigationLink(destination: movieView(movie:movie, emoji: "emoji")){
                                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + (movie.poster_path ?? "/lKyd7HGlDDUuRz4YhdY90uhTJ9T.jpg"))) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                            
                                        } placeholder: {
                                            ZStack {
                                                Color.gray
                                                Image(systemName: "circle.dashed")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 60)
                                            }
                                        }
                                        .frame(width: 150, height: 250)
                                        .padding(.horizontal, 8)
                                        .shadow(radius: 20)
                                        .padding(.bottom, 10)
                                    }
                                }
                            }
                            }.padding(.horizontal, 5)
                        }
                    }
                    VStack (alignment: .leading){
                        Text("Your emojis...").padding(.horizontal, 5)
                        ScrollView (.horizontal, showsIndicators: false){
                                
                                ChartView()

                        }.padding(.horizontal, 5)
                    }
                    
                    
                }
                
            }
        }
        .accentColor(.black)
    }

}

