//
//  TraktMoviesAPI.swift
//  TrackTV
//
//  Created by Raul on 7/12/19.
//  Copyright © 2019 Raul Quispe. All rights reserved.
//

import UIKit
import TraktKit
import RxCocoa
import RxSwift

enum MoviesServiceError: Error {
    case offline
    case moviesLimitReached
    case networkError
}

typealias SearchMoviesResponse = Result<(movies: [WraperMovie], nextURL: URL?), MoviesServiceError>
class TrackMoviesAPI {
    
    static let sharedAPI = TrackMoviesAPI(reachabilityService: try! DefaultReachabilityService())

    var paginationSearch:Pagination = Pagination.init(page: 1, limit: 10)
    var paginationTrending:Pagination = Pagination.init(page: 1, limit: 10)
    fileprivate let _reachabilityService: ReachabilityService
    private struct ConstantsApiOMDB {
        static let urlBase = "http://www.omdbapi.com"
        static let apikey = "2a08d4ad"
    }
    private init(reachabilityService: ReachabilityService) {
        _reachabilityService = reachabilityService
    }
}

extension TrackMoviesAPI {
    public func getTenPopularMovies() -> Observable<SearchMoviesResponse> {
        let observable = Observable<SearchMoviesResponse>.create { observer in

            TraktManager.sharedManager.getPopularMovies(pagination: TrackMoviesAPI.sharedAPI.paginationTrending, extended: [.Full], filters: nil, completion: { result in

                switch result {
                case .success(let completionObject):
                    var movies: [TraktMovie]!
                    movies = completionObject.objects

                    self.getObjectsMovies(movies: movies,completionMovie: {(moviews) in
                        DispatchQueue.main.async{
                            observer.onNext(.success((movies: moviews, nextURL: URL.init(string: ""))))
                            observer.onCompleted()
                            TrackMoviesAPI.sharedAPI.paginationTrending = Pagination.init(page: TrackMoviesAPI.sharedAPI.paginationTrending.page + 1, limit: 10)
                        }
                      
                    })
 
                case .error(let error):
                    print("Failed to get search results: \(String(describing: error?.localizedDescription))")
                    observer.onError(error!)
                }
            })
            return Disposables.create()
        }
        return observable.retryOnBecomesReachable(.failure(.offline), reachabilityService: _reachabilityService)
    }
    public func getObjectsMovies(movies:[TraktMovie],completionMovie: @escaping ([WraperMovie]) -> Void){
       

            var wMovies = [WraperMovie]()
            for itemMovie in movies {
                let newMovie = WraperMovie()
                newMovie.title = itemMovie.title
                
                if itemMovie.ids.imdb != nil {
                    newMovie.imdb = itemMovie.ids.imdb
                }else{
                    newMovie.imdb = ""
                }
                if itemMovie.year != nil {
                 newMovie.year = String(itemMovie.year!)
                }else{
                    newMovie.year = "-"
                }
                if itemMovie.overview != nil {
                 newMovie.overView = itemMovie.overview
                } else {
                 newMovie.overView = "-"
                }
                if newMovie.url == nil && newMovie.imdb != nil {
                    TrackMoviesAPI.sharedAPI.getUrlFromID(imdb: newMovie.imdb! , completion: {(data,error) in
                        newMovie.url = data

                        wMovies.append(newMovie)
                        if wMovies.count == 10 {
                            completionMovie(wMovies)
                        }
                    })
                }
                
            }
    }
    public func searchMovies(query:String) -> Observable<SearchMoviesResponse> {
        if query.isEmpty {
            TrackMoviesAPI.sharedAPI.paginationSearch = Pagination.init(page: 1, limit: 10)
            return getTenPopularMovies()
        }else{
             TrackMoviesAPI.sharedAPI.paginationTrending = Pagination.init(page:1, limit: 10)
            let observable = Observable<SearchMoviesResponse>.create { observer in
               
                TraktManager.sharedManager.search(query: query, types: [.movie], extended: [.Full], pagination: TrackMoviesAPI.sharedAPI.paginationSearch, filters: nil, fields: nil) { result in
                    switch result {
                    case .success(let objects):
                        var movies: [TraktMovie]!
                        movies = objects.compactMap { $0.movie }
                        self.getObjectsMovies(movies: movies,completionMovie: {(moviews) in
                            DispatchQueue.main.async{
                                observer.onNext(.success((movies: moviews, nextURL: URL.init(string: ""))))
                                observer.onCompleted()
                                TrackMoviesAPI.sharedAPI.paginationTrending = Pagination.init(page: TrackMoviesAPI.sharedAPI.paginationTrending.page + 1, limit: 10)
                            }
                            
                        })
                    case .error(let error):
                        print("Failed to get search results: \(String(describing: error?.localizedDescription))")
                    }
                }
                
                return Disposables.create()
            }
            return observable.retryOnBecomesReachable(.failure(.offline), reachabilityService: _reachabilityService)
        }
    }

    func getUrlFromID(imdb:String,completion: @escaping (URL?, Error?) -> Void)  {
        let url = URL(string: ConstantsApiOMDB.urlBase + "/?i=" + imdb + "&apikey=" + ConstantsApiOMDB.apikey)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session:URLSession
        session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: { data,response,error in
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let imdbData = try decoder.decode(ImdbData.self, from: data)
                if imdbData.Poster == nil {
                     completion(URL(string: "https://m.media-amazon.com/images/M/MV5BMjAwODg3OTAxMl5BMl5BanBnXkFtZTcwMjg2NjYyMw@@.jpg")!, nil)
                }else{
                     completion(URL(string: imdbData.Poster!)!, nil)
                }
               
            } catch let err {
                print(err)
            }
        })
        task.resume()
    }

}
struct ImdbData: Decodable {
    let Poster: String?

}
