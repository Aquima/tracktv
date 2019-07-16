//
//  HomeViewModel.swift
//  TrackTV
//
//  Created by Raul on 7/12/19.
//  Copyright © 2019 Raul Quispe. All rights reserved.
//

import RxSwift
import TraktKit
struct HomeViewModel {
    let sceneCoordinator: CoordinatorView
    init(coordinator:CoordinatorView) {
        self.sceneCoordinator = coordinator
    }
    func getMovies()->Observable<[TraktMovie]>{

        let userObserver = Observable<[TraktMovie]>.create { observer in
            TraktManager.sharedManager.getPopularMovies(completion: { result in
                print(result)
                switch result {
                case .success(let completionObject):
                    var movies: [TraktMovie]!
                    movies = completionObject.objects
                    observer.onNext(movies)
                   
                case .error(let error):
                    print("Failed to get search results: \(String(describing: error?.localizedDescription))")
                    observer.onError(error!)
                }
               observer.onCompleted()
            })
            return Disposables.create()
        }
        return userObserver
    }
}
