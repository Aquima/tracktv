//
//  SplashViewModel.swift
//  TrackTV
//
//  Created by Raul on 7/12/19.
//  Copyright © 2019 Raul Quispe. All rights reserved.
//

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
}
