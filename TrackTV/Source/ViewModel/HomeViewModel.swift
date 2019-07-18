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
    func getMovies(_ query:String)->Observable<SearchMoviesResponse>{
        return TrackMoviesAPI.sharedAPI.searchMovies(query: query)
    }
}
