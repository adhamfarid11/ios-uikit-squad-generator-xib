//
//  RootTabBarViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit

final class RootTabBarController: UITabBarController {
    @IBOutlet weak var item1: UIViewController!
    @IBOutlet weak var item2: UIViewController!
    
    @IBOutlet weak var item1Child: UITabBarItem!
    @IBOutlet weak var item2Child: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create your two main controllers
        let home = UINavigationController(rootViewController: GeneratorModule.build())
        let timer = UINavigationController(rootViewController: TimerViewController())

        // Assign them to your outlets
        home.tabBarItem = item1Child
        timer.tabBarItem = item2Child

        // Set them as the tab bar's view controllers
        viewControllers = [home, timer]

        // Optional: modern iOS tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
