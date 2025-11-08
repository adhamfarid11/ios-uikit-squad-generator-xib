//
//  RootTabBarViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit

// NOTE: TimerViewController would need to be in a shared framework or built directly into
// the main app target if it's referenced here, or conditionally imported/stubbed.

final class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var controllers: [UIViewController] = []
        

        let home = UINavigationController(rootViewController: GeneratorModule.build())
        home.tabBarItem = UITabBarItem(
            title: "Generator",
            image: UIImage(systemName: "bolt"),
            selectedImage: UIImage(systemName: "bolt.fill")
        )
        controllers.append(home)

        let timer = UINavigationController(rootViewController: TimerViewController())
        timer.tabBarItem = UITabBarItem(title: "Timer",
                                         image: UIImage(systemName: "timer"),
                                         selectedImage: nil)
        controllers.append(timer)
        
        let chats = UINavigationController(rootViewController: ChatModule.build())
        chats.tabBarItem = UITabBarItem(title: "Chats",
                                         image: UIImage(systemName: "message"),
                                         selectedImage: UIImage(systemName: "message.fill"))
        controllers.append(chats)

        let library = UINavigationController(rootViewController: LibraryModule.build())
        library.tabBarItem = UITabBarItem(title: "Library",
                                         image: UIImage(systemName: "books.vertical"),
                                         selectedImage: UIImage(systemName: "books.vertical.fill"))
        controllers.append(library)
        
        let profile = UINavigationController(rootViewController: ProfileVC())
        profile.tabBarItem = UITabBarItem(title: "Profile",
                                         image: UIImage(systemName: "person.circle"),
                                         selectedImage: UIImage(systemName: "person.circle.fill"))
        controllers.append(profile)

        viewControllers = controllers

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
