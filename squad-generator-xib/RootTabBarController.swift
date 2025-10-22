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
    
    // Use an array to store items since the number is now conditional
    // @IBOutlet properties for UIViewController are usually not needed in this setup
    
    @IBOutlet weak var item1Child: UITabBarItem! // Item for Generator
    @IBOutlet weak var item2Child: UITabBarItem! // Item for Timer (Conditional)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var controllers: [UIViewController] = []
        
        // #if GENERATOR_FEATURE_ON
        let home = UINavigationController(rootViewController: GeneratorModule.build())
        home.tabBarItem = item1Child
        controllers.append(home)
        // #endif
        
        
        #if TIMER_FEATURE_ON
        let timer = UINavigationController(rootViewController: TimerViewController())
        timer.tabBarItem = item2Child
        controllers.append(timer)
        #endif

        viewControllers = controllers

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}