//
//  Components.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 07/12/22.
//

import Foundation
import SwiftUI

struct bottone : View {
    var title: String
    let testo: String
    let keyword: String
    let adult: String

    
    var body: some View {
        
        VStack {
                Button(action: {
//                    printprint("emoji in bottone" + title)
                }) {
                    NavigationLink(destination: SuggestionView(keyword: keyword, adult: adult, emoji: title)){
                    Text(title)
                        .fontWeight(.bold)
                        .font(.system(size: 36, weight: Font.Weight.bold))
                        .foregroundColor(Color("AccentColor"))
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1.5)
                        )
                }
            
            }
            Text (testo)
        }
        .padding(5)
        
    }
}


struct isSeen : View {
    let testo: String
    var movie: Film
    
    @ObservedObject var mymovieData = sharedData
    @State var color: Color = .red
    @State var icon: String = "eye.slash"
    @State var tapped: Bool = false
    @State var emo: String
    var body: some View {
    
        
        VStack {
            
            Button(action: {
                tapped.toggle()

                    if(tapped){
                        mymovieData.seen.append(movie)
                        icon = "eye"
                        color = .green
                    }else{
                            mymovieData.seen.removeAll {$0.id == movie.id}
                            icon = "eye.slash"
                        color = .red
                    }

                
            }) {
 
                Image(systemName: icon).foregroundColor(color)
                    .padding()
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1.5)
                    )
        }
            Text (testo)
                 
        }.task {
            
//            print("emoji in isseen" + emo)
//            print("esempio" + (movie.emoji ?? "💎"))
            
            tapped = mymovieData.seen.contains(where: { $0.id == movie.id})
            
            if(tapped){
                icon = "eye"
                color = .green
            }else{
                icon = "eye.slash"
                color = .red
            }
        }
        .padding(5)
          
        
    }
        
    }



struct bottoneInfo : View {
    let simbolo: Image
    let testo: String
    let moviee: Film
    var emoji: String
    var body: some View {

        VStack {
                Button(action: {
//                    print("emoji in bottoneinfo" + emoji)
                }) {
                    
                    
                    NavigationLink(destination: movieView(movie: moviee, emoji: emoji)){
                        Text(simbolo)
                            .fontWeight(.bold)
                            .font(.system(size: 36, weight: Font.Weight.bold))
                            .foregroundColor(Color("AccentColor"))
                            .padding()
                    }
            }
            Text (testo)
        }.padding(5)
        
    }
}



struct bottoneSettings : View {
    let simbolo: Image
    let testo: String
    
    var body: some View {

        VStack {
                Button(action: {
//                    print("info button tapped!")
                }) {
                    NavigationLink(destination: SettingsView()){
                    Text(simbolo)
                        .fontWeight(.bold)
                        .font(.system(size: 36, weight: Font.Weight.bold))
                        .foregroundColor(Color("AccentColor"))
                        .shadow(radius: 10)
                        .padding()
                }
            
            }
            Text (testo)
        }.padding(5)
        
    }
}

struct bottoneLogout : View {
    let simbolo: Image
    let testo: String
    
    
    var body: some View {

        VStack {
                Button(action: {
//                    print("info button tapped!")
                }) {
                    NavigationLink(destination: Text("LoggedOut")){
                    Text(simbolo)
                        .fontWeight(.bold)
                        .font(.system(size: 36, weight: Font.Weight.bold))
                        .foregroundColor(.red)
                        .padding()
                }
            
            }
            Text (testo)
        }.padding(5)
        
    }
}

struct bottoneLogin : View {
    let simbolo: Image
    let testo: String
    
    
    var body: some View {

        VStack {
                Button(action: {
                    print("info button tapped!")
                }) {
                    NavigationLink(destination: ContentView()){
                    Text(simbolo)
                        .fontWeight(.bold)
                        .font(.system(size: 36, weight: Font.Weight.bold))
                        .foregroundColor(.green)
                        .padding()
                }
            
            }
            Text (testo)
        }.padding(5)
        
    }
}

struct ChatBubble: View{
    let color: Color
    let content: String
    
    var body: some View {
        
            HStack{
                Text(content)
                    .padding(.all, 15)
                    .foregroundColor(Color("AccentColor"))
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        Image(systemName: "arrowtriangle.left.fill")
                            .foregroundColor(color)
                            .rotationEffect(Angle(degrees: -130))
                            .offset(x: 5)
                            ,alignment: .bottomTrailing
                    )
            }
    }
}



struct EllisseMain: View {
    let title: String
    
    var body: some View {
       
        ZStack {
            Ellipse()
                .foregroundColor(Color("AccentColor"))
                .frame(width: 800, height: 300, alignment: .init(horizontal: .leading, vertical: .top))
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            HStack {
                Image(systemName: "quote.opening")
                Text(title)
                Image(systemName: "quote.closing")
            } .offset(x:0, y: 70)
                .shadow(color: .black, radius: 20)
            .foregroundColor(.white)
            .bold()
            .font(.title)
        }
    }
}

struct FilmINWhatchlist: View {
    let poster: String
    let nome: String
    let score: String
    let genre: String
    let year: String
    
    @State private var gene = ""
    @State private var gen: [Genre] = []
    
    var body: some View {
        VStack (alignment: .leading){
            HStack (alignment: .center){

                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + poster)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                
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

                    .padding(.bottom, 10)
                HStack {
                    VStack (alignment: .leading){
                        Text(nome).bold()
                        HStack{
                            Text(score).padding(.trailing, 1)
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.yellow)
                                .frame(width: 15)
                        }
                        Text(gene).padding(.bottom, 3)
                        
                        Text(year)
                        
                    }.padding(.leading).foregroundColor(.black)
                }.task {
                    gen = try! await FilmAPI.getGenres()
                    var index = -1
                    index = gen.firstIndex(where: {String($0.id ?? -1) == genre}) ?? -1
                    if index != -1{
                        gene = gen[index].name ?? ""
                    }
                }
                Spacer()
            }
        }
    }
}

struct FilmSearch: View {
    let nome: String
    
    var body: some View {
        VStack (alignment: .leading){
            HStack (alignment: .center){

                HStack {
                    VStack (alignment: .leading){
                        Text(nome)
                    }.padding(.leading).foregroundColor(.black)
                }
                Spacer()
            }
        }
    }
}

struct Attore: View {
    let immagine: String
    let nome: String
    
    var body: some View {
        
        HStack {
                            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + immagine)) { image in
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
                                    .frame(width: 100, height: 100)

                .clipShape(Circle())
                .padding(.leading , 20)
            
            VStack {
                Text(nome).bold()
            }.padding(.leading)
        }
    }
}

struct Commento: View {
    let pfp: String
    let emoji: String
    let username: String
    let text: String
    
    @State private var isExpanded: Bool = false
    @State private var ppfp: String = ""
    
    var body: some View {
        HStack{
            VStack {
                if (!pfp.starts(with: "/https:/")){
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + pfp)) { image in
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
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.leading , 20)
                }else{
                    
                    AsyncImage(url: URL(string: ppfp)) { image in
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
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.leading , 20)
                }
                Text(emoji).padding(.leading, 20)
            }.padding(.vertical, 30)
            
            VStack (alignment: .leading){
                Text(username).bold()
                Text(text).padding(.trailing)
                    .lineLimit(isExpanded ? nil : 3)
                                .overlay(
                                    GeometryReader { proxy in
                                        Button(action: {
                                            isExpanded.toggle()
                                        }) {
                                            Text(isExpanded ? "Less" : "More")
                                                .font(.caption).bold()
                                                .padding(.leading, 8.0)
                                                .padding(.top, 4.0)
                                                .background(Color.white)
                                        }
                                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomTrailing)
                                    }.padding(.trailing).offset(y: 25)
                                )
            }.padding(.leading).offset(y: -15)
            Spacer()
        }.offset(y: -130).padding(.top, 20)
            .task {
                ppfp = pfp
                ppfp.remove(at: ppfp.startIndex)
            }
    }
}

struct HeatherProfilo: View {
    let cover: String
    let pfp: String
    let username: String
    
    var body: some View {
        VStack {
            ZStack {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + cover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    
                } placeholder: {
                    ZStack {
                        Color.gray
                        Image(systemName: "circle.dashed")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                    }
                }
                .frame(width: 400, height: 300)
                    .clipShape(Rectangle())
                    .shadow(radius: 20)
                
                bottoneSettings(simbolo: Image(systemName: "gearshape.fill"), testo: "").offset(x: 140 , y: -60)
                
                VStack {
                    Image(pfp)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.leading , 20)
                    Text(username).padding(.leading).bold().font(.title)
                }.padding(.bottom).offset(y: 160)
                
                
            }.ignoresSafeArea()
        }
    }
}


struct Feelmback: View {
    let poster: String
    let text: String
    
    var body: some View {
        VStack (alignment: .leading){
            HStack (alignment: .center){
                Image(poster)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 20)
                    .padding(.bottom, 10)
                HStack {

                    Image(systemName: "quote.opening").foregroundColor(Color("AccentColor"))
                    Text(text).foregroundColor(.black)
                        Image(systemName: "quote.closing").foregroundColor(Color("AccentColor"))
                    
                    
                }
                
            }
        }
    }
}
