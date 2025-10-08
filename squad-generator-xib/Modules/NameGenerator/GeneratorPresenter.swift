//
//  GeneratorPresenter.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import Foundation

protocol GeneratorView: AnyObject {
    func show(name: String)
}

protocol GeneratorPresenting: AnyObject {
    func viewDidLoad()
    func didTapGenerate()
}

final class GeneratorPresenter: GeneratorPresenting {
    private weak var view: GeneratorView?
    private let interactor: GeneratorUseCase
    // Router kept for future navigation, not used now
    private let router: GeneratorRouting

    init(view: GeneratorView,
         interactor: GeneratorUseCase,
         router: GeneratorRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        view?.show(name: "Tap Generate")
    }

    func didTapGenerate() {
        let result = interactor.generateName()
        view?.show(name: result.raw)
    }
}
