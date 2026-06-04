//
//  ContentView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 07/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    EllisseMain(title: "FEEL(M)BACK")
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing){
                            ChatBubble(color: .white, content: "Sera!").padding(.bottom, 15)
                                ChatBubble(color: .white, content: "How do you want to feel today?")
                        }.padding()
                            .offset(x: 15, y: -12)
                    }.padding(.trailing, 230).shadow(radius: 10)
                    VStack{
                        HStack{
                            bottone(title: "😁", testo: "Happy", keyword: "289153", adult: "false")
                            bottone(title: "🤣", testo: "Lol", keyword: "8201", adult: "false")
                            bottone(title: "🥰", testo: "In love", keyword: "165086", adult: "false")
                            bottone(title: "😔", testo: "Sad", keyword: "12544", adult: "false")
                        }//END OF HSTACK
                        HStack{
                            bottone(title: "🤡", testo: "Scared", keyword: "13073", adult: "false")
                            bottone(title: "🌶️", testo: "Caliente", keyword: "1664", adult: "false")
                            bottone(title: "🪩", testo: "Party", keyword: "14964", adult: "false")
                            bottone(title: "⛪️", testo: "Jesus", keyword: "10594", adult: "false")
                        }//END OF HSTACK
                        HStack{
                            bottone(title: "🌋", testo: "Hater", keyword: "1952", adult: "false")
                            bottone(title: "👽", testo: "Alien", keyword: "13031", adult: "false")
                            bottone(title: "🦄", testo: "Fantasy", keyword: "2343", adult: "false")
                            bottone(title: "🧞‍♂️", testo: "Inspired", keyword: "6257", adult: "false")
                        }//END OF HSTACK
                    }
                }//END OF VSTACK
                .offset(x: 0, y: -100)
            }//END ZSTACK

        }//END NAVIGATIONVIEW
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
