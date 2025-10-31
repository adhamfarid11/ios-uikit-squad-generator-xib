//
//  LibraryRouter.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 30/10/25.
//

import UIKit

final class LibraryRouter { }

enum LibraryModule {
    static func build() -> UIViewController {

        let interactor = LibraryInteractor()
        let router = LibraryRouter()
        let view = LibraryTableViewController()
        let presenter = LibraryPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
}
