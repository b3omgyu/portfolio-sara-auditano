//
//  TabView.swift
//  feeelmback
//
//  Created by Sara Auditano on 07/12/22.
//

import SwiftUI

struct BarraView: View {
    init() {
            UITabBar.appearance().backgroundColor = UIColor.white
            }
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName:"theatermasks")
                    Text("Suggestions")
                }
            
            SearchView()
                .tabItem{
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            WatchListView()
                .tabItem{
                    Image(systemName: "bookmark")
                    Text("Watchlist")
                }
            
            ProfileView()
                .tabItem{
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

struct BarraView_Previews: PreviewProvider {
    static var previews: some View {
        BarraView()
    }
}
