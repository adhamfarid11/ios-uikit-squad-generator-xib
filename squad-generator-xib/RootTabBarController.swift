//
//  RootTabBarViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let home = UINavigationController(rootViewController: GeneratorModule.build())
        home.tabBarItem = UITabBarItem(title: "Squad",
                                       image: UIImage(systemName: "bolt"),
                                       selectedImage: UIImage(systemName: "bolt.fill"))

        let timer = UINavigationController(rootViewController: TimerViewController())
        timer.tabBarItem = UITabBarItem(title: "Timer",
                                         image: UIImage(systemName: "timer"),
                                         selectedImage: nil)
        
        let chats = UINavigationController(rootViewController: ChatModule.build())
        chats.tabBarItem = UITabBarItem(title: "Chats",
                                         image: UIImage(systemName: "message"),
                                         selectedImage: UIImage(systemName: "message.fill"))
        
        let library = UINavigationController(rootViewController: LibraryModule.build())
        library.tabBarItem = UITabBarItem(title: "Library",
                                         image: UIImage(systemName: "books.vertical"),
                                         selectedImage: UIImage(systemName: "books.vertical.fill"))

        viewControllers = [home, chats, timer, library]

        // (Optional) iOS 15+ appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
