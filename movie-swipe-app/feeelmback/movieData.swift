//
//  movieData.swift
//  feeelmback
//
//  Created by Renato Duraccio on 07/12/22.
//

import Foundation
import SwiftUI

class SharedData: ObservableObject{

    @Published var movies: [Film] = []
    @Published var search: [Film] = []
    @Published var watchlist: [Film] = []
    @Published var cast: [Actor] = []
    @Published var crew: [Actor] = []
    @Published var seen: [Film] = []
    @Published var profilo: Profile = Profile()
}
var sharedData = SharedData()
