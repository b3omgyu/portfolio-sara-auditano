//
//  FilmAPI.swift
//  feeelmback
//
//  Created by Marzia Pirozzi on 12/12/22.
//

import Foundation
import SwiftUI

class FilmAPI {
    static func getMovie (pagine: Int, anno: Int, keyword: String, adult: String, emoji: String) async throws -> [Film]{
        var url: String = "https://api.themoviedb.org/3/keyword/" + keyword + "/movies?api_key=255a9707c648a5a21175e27b2ed0eb9d&language=en-US&include_adult=" + adult + "&sort_by=popularity.desc"

        if (anno != 0){
            url.append(contentsOf: "&primary_release_year=" + String(anno))
        }
        

        let myUrl: URL = URL(string: url)!

        var request: URLRequest = URLRequest(url: myUrl)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
    
        
        var fetchedData = try! decoder.decode(Results.self, from: data)
        
        let n: Int = fetchedData.results.count
        var i: Int = 0
        
        while (i < n) {
            fetchedData.results[i].emoji = emoji
            i = i+1
        }
        
        return fetchedData.results
    }
    
    
    static func getMovieSearch (titolo: String) async throws -> [Film]{
        
        let title: String  = titolo.replacingOccurrences(of: " ", with: "%20")
        
        let url: String = "https://api.themoviedb.org/3/search/movie?api_key=255a9707c648a5a21175e27b2ed0eb9d&language=en-US&query=" + title + "&page=1&include_adult=false"


        let myUrl: URL = URL(string: url)!

        var request: URLRequest = URLRequest(url: myUrl)
        
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
    
        
        let fetchedData = try! decoder.decode(Results.self, from: data)
        
        return fetchedData.results
    }
    
    
    static func getActors (id: String) async throws -> [Actor]{
        let url: String = "https://api.themoviedb.org/3/movie/" + id + "/credits?api_key=255a9707c648a5a21175e27b2ed0eb9d&language=en-US"

        let myUrl: URL = URL(string: url)!

        var request: URLRequest = URLRequest(url: myUrl)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
    
        
        let fetchedData = try! decoder.decode(Risultato.self, from: data)
        
        return fetchedData.cast
    }
    
    static func getCrew (id: String) async throws -> [Actor]{
        let url: String = "https://api.themoviedb.org/3/movie/" + id + "/credits?api_key=255a9707c648a5a21175e27b2ed0eb9d&language=en-US"

        let myUrl: URL = URL(string: url)!

        var request: URLRequest = URLRequest(url: myUrl)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
    
        
        let fetchedData = try! decoder.decode(Risultato.self, from: data)
        
        return fetchedData.crew
    }
    
    static func getReviews (id: String) async throws -> [Risult]{
        let url: String = "https://api.themoviedb.org/3/movie/" + id + "/reviews?api_key=255a9707c648a5a21175e27b2ed0eb9d&language=en-US&page=1"

        let myUrl: URL = URL(string: url)!

        var request: URLRequest = URLRequest(url: myUrl)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
    
        
        let fetchedData = try! decoder.decode(Risulti.self, from: data)
        
        return fetchedData.results!
    }
    
    static func getGenres () async throws -> [Genre]{
        let url: String = "https://api.themoviedb.org/3/genre/movie/list?api_key=255a9707c648a5a21175e27b2ed0eb9d&language=en-US"

        let myUrl: URL = URL(string: url)!

        var request: URLRequest = URLRequest(url: myUrl)
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
    
        
        let fetchedData = try! decoder.decode(ResultsGeneri.self, from: data)
        
        return fetchedData.genres!
    }
    
    
}
