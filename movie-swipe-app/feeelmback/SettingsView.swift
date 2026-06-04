//
//  SettingsView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 09/12/22.
//

import SwiftUI

struct SettingsView: View {
    @State private var messagesnotif = true
    @State private var emailnotif = true
    @State private var password = ""
    @State private var mail = ""
    @State private var name: String = ""

    var body: some View {
        NavigationView {
            VStack {
                EllisseMain(title: "FEEL(M)BACK").offset(y: -110)
                ScrollView {
                            VStack (alignment: .leading){
                                
                                VStack(alignment: .leading){
                                    Text("Change Profile").foregroundColor(.black).padding(.horizontal).padding(.bottom).font(.title)
                                    HStack {
                                        Text ("Email")
                                        TextField("Enter your email", text: $mail)
                                    }.padding(.horizontal)
                                    
                                    HStack {
                                        Text ("Password")
                                        SecureField("Enter your password", text: $password)
                                    }.padding(.horizontal)
                                    
                                }.padding(.bottom, 30)
                                
                                
                                VStack (alignment: .leading){
                                    Text("Notifications").foregroundColor(.black).padding(.horizontal).padding(.bottom).font(.title)
                                    HStack{
                                        Toggle("Push", isOn: $messagesnotif).padding(.horizontal).tint(Color("AccentColor"))
                                    }
                                    HStack{
                                        Toggle("Email", isOn: $emailnotif).padding(.horizontal).tint(Color("AccentColor"))
                                    }
                                }
                                
                                bottoneLogout(simbolo: Image(systemName: "rectangle.portrait.and.arrow.forward"), testo: "Log Out").offset(x: 150, y: 50)
                                
                            }
                        
                }.offset(y: -80).frame(height: 500)
            }
            }
        }
    }

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
