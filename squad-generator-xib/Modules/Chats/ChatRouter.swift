//
//  ChatRouter.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 29/10/25.
//

import UIKit

final class ChatRouter { }

enum ChatModule {
    static func build() -> UIViewController {
        
        let router = ChatRouter()
        let view = ChatViewController()
        let presenter = ChatPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }
}
