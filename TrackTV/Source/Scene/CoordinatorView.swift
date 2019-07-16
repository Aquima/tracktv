//
//  CoordinatorView.swift
//  TrackTV
//
//  Created by Raul on 7/12/19.
//  Copyright © 2019 Raul Quispe. All rights reserved.
//

import UIKit
import RxSwift
enum SceneTransitionType {
    
    case root       // make view controller the root view controller
    case push       // push view controller to navigation stack
    case modal      // present view controller modally
}

protocol CoordinatorView {
    init(window:UIWindow)
    /// transition to another scene
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable
    
    /// pop scene from navigation stack or dismiss current modal
    @discardableResult
    func pop(animated: Bool) -> Completable
}

extension CoordinatorView {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
