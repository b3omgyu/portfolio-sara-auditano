//
//  SwipeView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 08/12/22.
//

import SwiftUI

struct SwipeView: View {
    
    let movie: Film
    var emoji: String
    @ObservedObject var mymovieData = sharedData
    @State var offset = CGSize.zero
    @State var color = Color.black
    
    var body: some View {
        ZStack {
            VStack {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original/" + (movie.poster_path ?? "/sRvXNDItGlWCqtO3j6wks52FmbD.jpg"))) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 320, height: 480)
                                
                        } placeholder: {
                            ZStack {
                                Color.gray
                                Image(systemName: "circle.dashed")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60)
                            }
                        }
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .opacity(0.2)
                            .foregroundColor(color))
                        
                bottoneInfo(simbolo: Image(systemName: "info.circle"), testo: "", moviee: movie, emoji: emoji)
                
            }
            
        }
        .offset(x: offset.width, y: offset.height * 0.4)
            .rotationEffect(.degrees(Double(offset.width / 40)))
            .gesture(
            DragGesture()
                .onChanged{
                    gesture in
                    offset = gesture.translation
                    withAnimation{
                        changeColor(width: offset.width)
                    }
                }.onEnded{ _ in
                    withAnimation{
                        swipeCard(width: offset.width)
                        changeColor(width: offset.width)
                    }
                }
            )
           
        
    }
    
    func swipeCard (width: CGFloat){
        switch width {
        case -500...(-150):
//            print("removed")
            offset = CGSize(width: -500, height: 0)
        case  150...(500):
//            print("added")
            offset = CGSize(width: 500, height: 0)
            mymovieData.watchlist.append(movie)
            
        default:
            offset = .zero
        }
    }
    
    func changeColor (width: CGFloat) {
        switch width {
        case -500...(-90):
            color = .red
        case  90...(500):
            color = .green
        default:
            color = .black
        }
    }
    
}
