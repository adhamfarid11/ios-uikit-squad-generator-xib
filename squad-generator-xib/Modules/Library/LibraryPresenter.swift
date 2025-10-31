//
//  LibraryPresenter.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 30/10/25.
//

import UIKit

protocol LibraryPresenterDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
     func showBooks(_ books: [Book])
     func showError(_ message: String)
}

class LibraryPresenter {
    private weak var view: LibraryTableViewController?
    private let interactor: LibraryInteractor
    private let router: LibraryRouter
    
    init(view: LibraryTableViewController,
         interactor: LibraryInteractor,
         router: LibraryRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func fetchAllBooks() {
        view?.showLoading(true)
        interactor.fetchAllBooks { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.view?.showLoading(false)
                switch result {
                case .success(let books):
                    self.view?.showBooks(books as! [Book])
                case .failure(let error):
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    
}
