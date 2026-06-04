//
//  movieView.swift
//  feeelmback
//
//  Created by Sara Auditano on 08/12/22.
//

import SwiftUI

struct movieView: View {
    
    @ObservedObject var mymovieData = sharedData
    @State var myCrew: [Actor] = []
    @State var myCast: [Actor] = []
    @State var myReviews: [Risult] = []
    @State var director = ""
    @State var gene = ""
    @State var gen: [Genre] = []
    @State var mySeen: [Film] = []
    var movie: Film
    var emoji: String
    @State static var tap: Bool = false
    @State private var selected = 0
    
    var body: some View {
        
        
        ZStack{
            
            
            ScrollView {
                
                VStack{
                    ZStack{
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + (movie.backdrop_path ?? "/lKyd7HGlDDUuRz4YhdY90uhTJ9T.jpg"))) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 150, height: 250)
                        .shadow(radius: 20)
                        
                        
                        HStack {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + (movie.poster_path ?? "/lKyd7HGlDDUuRz4YhdY90uhTJ9T.jpg"))) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 130, height: 160)
                            .shadow(radius: 20)
                            .padding(.top, 240)
                            .padding(.trailing, 220)
                        }
                        
                    }
                    .offset(y: -80)
                    
                    let genere: String = setGenere()
                    
                    
                    VStack{
                        Text(movie.title).padding(.bottom, 0.5).bold()
                        Text((movie.release_date ?? "No Relase Date") + " | "  + String(
                            gene))
                        
                    }.offset(x: 75, y: -140 )
                        .foregroundColor(Color.black)
                        .task {
                            gen = try! await FilmAPI.getGenres()
                            var index = -1
                            index = gen.firstIndex(where: {String($0.id ?? -1) == genere}) ?? -1
                            if index != -1{
                                gene = gen[index].name ?? ""
                            }
                        }
                    
                    Picker("", selection: $selected) {
                        Text("About movie")
                            .tag(0)
                        Text("Reviews")
                            .tag(1)
                    }.pickerStyle(.segmented).padding(.horizontal).offset(y: -130).padding(.top, 30)
                    
                    if (selected == 0){
                        VStack (alignment: .leading) {
                            
                            Text(movie.overview).padding()
                            
                            HStack {
                                Text("Director:").bold().padding(.leading)
                                Text("\(director)")
                                
                            }.padding(.bottom)
                            ForEach(myCast.prefix(5)){attore in
                                
                                Attore(immagine: attore.profile_path ?? "/lKyd7HGlDDUuRz4YhdY90uhTJ9T.jpg", nome: attore.name ?? "name")
                                
                            }
                        }.padding(.bottom)
                            .task {
                                myCrew = try! await FilmAPI.getCrew(id: String(movie.id))
                                
                                myCast = try! await FilmAPI.getActors(id: String(movie.id))
                                
                                var index = -1
                                index = myCrew.firstIndex(where: {$0.job == "Director"}) ?? -1
                                if index != -1{
                                    director = myCrew[index].name ?? ""
                                }}
                        
                            .offset(y: -130)
                    }else{
                        ForEach(myReviews){commento in
                            
                            Commento(pfp: commento.author_details?.avatar_path ?? "/lKyd7HGlDDUuRz4YhdY90uhTJ9T.jpg", emoji: "😎", username: commento.author_details?.username ?? "ciao", text: commento.content ?? "ciao")
                            
                        }
                    }
                }
                .task{
                    myReviews = try! await FilmAPI.getReviews(id: String(movie.id))
                    
                }
            }
            .ignoresSafeArea()
            isSeen(testo: " ", movie: movie, emo: "🤡").offset(x: 150, y: 290)
        }
    }
        
    func setGenere () -> String {
        if(movie.genre_ids.isEmpty){
            return "no genre"
        }else{
            return String(movie.genre_ids[0])
        }
    }
    
    }
