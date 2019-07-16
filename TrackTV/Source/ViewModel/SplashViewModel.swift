//
//  SplashViewModel.swift
//  TrackTV
//
//  Created by Raul on 7/12/19.
//  Copyright © 2019 Raul Quispe. All rights reserved.
//

import UIKit
import RxSwift
import TraktKit

struct SplashViewModel {
    let sceneCoordinator: CoordinatorView
    init(coordinator:CoordinatorView) {
        self.sceneCoordinator = coordinator
    }
    func goToHome(){
        let homeViewModel = HomeViewModel(coordinator: sceneCoordinator)
        let homeScene = Scene.home(homeViewModel)
        sceneCoordinator.transition(to: homeScene, type: .push)
    }
//    func getMovies() ->Observable<Bool>{
//        
//        let userObserver = Observable<Bool>.create { observer in
//            TraktManager.sharedManager.getPopularMovies(completion: { result in
//                print(result)
//                switch result {
//                case .success(let completionObject):
//                    var movies: [TraktMovie]!
//                    movies = completionObject.objects
//                   
//                    observer.onNext(true)
//                    
//                case .error(let error):
//                    print("Failed to get search results: \(String(describing: error?.localizedDescription))")
//                    observer.onError(error!)
//                }
//                observer.onCompleted()
//            })
//            return Disposables.create()
//        }
//        return userObserver
//    }
}
