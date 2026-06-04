import SwiftUI

struct SearchView: View {

    @State private var searchText = ""

    @ObservedObject var mymovieData = sharedData
    @State var myMovies: [Film] = []

    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading) {
                List{
                    ForEach(myMovies) { movie in
                                     NavigationLink{
                                         movieView(movie: movie, emoji: "no")
                                        } label: {
                                            Text(movie.title)
                                        }                    .swipeActions(edge: .leading) {
                                            Button {
                                                mymovieData.watchlist.append(movie)
                                            } label: {
                                                Label("Added to Watchlist", systemImage: "plus.circle")
                                            }
                                        }.tint(.green)
                                    }
                } .listStyle(GroupedListStyle())
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: "Search for a movie")
                    .onSubmit (of: .search) {
                        Task {
                            if(!searchText.isEmpty){
                                myMovies = try! await FilmAPI.getMovieSearch(titolo: searchText)
                            }
                        }
                    }
                    
            }

        }
    }
                      
    func update (){
        Task{
            myMovies = try! await FilmAPI.getMovieSearch(titolo: searchText)
        }
         
    }
}



struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
