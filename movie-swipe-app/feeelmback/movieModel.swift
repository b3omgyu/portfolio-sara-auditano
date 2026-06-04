//
//  movieModel.swift
//  feeelmback
//
//  Created by Renato [Duraccio] on 07/12/22.
//

import SwiftUI

struct ResultsGeneri: Codable{
    var genres: [Genre]?
}

struct Genre: Codable, Identifiable{
    var id: Int?
    var name: String?
}

struct Risulti: Codable, Identifiable{
    var id: Int?
    var page: Int?
    var results: [Risult]?
    var total_pages: Int?
    var total_results: Int?
}

struct Risult: Codable, Identifiable{
    var author: String?
    var author_details: AuthorDetails?
    var content: String?
    var created_at: String?
    var id: String?
    var updated_at: String?
    var url: String?
}

struct AuthorDetails : Codable{
    var name: String?
    var username: String?
    var avatar_path: String?
    //var rating: Int?
}


struct Risultato: Codable, Identifiable{
    var id: Int
    var cast: [Actor] = []
    var crew: [Actor] = []
}

struct Actor: Codable, Identifiable {
    var id: Int = 1
    var name: String?
    var profile_path: String?
    var department: String?
    var job: String?
}



struct Results : Codable{
    var page: Int?
    var total_pages: Int?
    var total_results: Int?
    var results: [Film] = []
}

struct Film: Codable, Identifiable{
    var adult: Bool = false
    var backdrop_path: String?
    var genre_ids: [Int] = []
    var id: Int = 0
    var original_language: String = "No Original Language"
    var original_title: String = "No Original Title"
    var overview: String = "No Overview"
    var popularity: Float  = 0
    var poster_path: String?
    var release_date: String?
    var title: String = "No Title"
    var video: Bool = false
    var vote_average: Float = 0 
    var vote_count: Int = 0
    var emoji: String? = "💎"
}


struct Review: Identifiable {
    var id = UUID()
    var pfp: String = "pfp"
    var username: String = "username"
    var text: String = "text"
    var emoji: String = "😁"
}

struct Profile: Identifiable {
    var id = UUID()
    var pfp: String = "pfp"
    var username: String = "teal panthers 💎"
}
