//
//  RegisterView.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 09/12/22.
//

import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var password: String = ""
    var body: some View {
        NavigationView {
            VStack {
                EllisseMain(title: "FEEL(M)BACK").offset(y: -230 )
                VStack (alignment: .center){
                    Text("Sign Up").font(.title).bold()
                    VStack {
                        HStack (alignment: .center){
                            Text("Username")
                            TextField("Enter your username", text: $name)
                        }.padding(.leading, 70).padding(.bottom)
                        HStack (alignment: .center){
                            Text("Password")
                            SecureField("Enter your password", text: $password)
                        }.padding(.leading, 70)
                    }.padding(.top, 50)
                
                }.offset(y: -200)
                
                HStack{
                    bottoneLogin(simbolo: Image(systemName: "door.left.hand.open"), testo: "Log In")
                }
            }
        }
    }
}
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
