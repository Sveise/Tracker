//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Svetlana Varenova on 13.08.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            window?.rootViewController = createMainTabBarController()
        } else {
            window?.rootViewController = OnboardingViewController()
        }
        
        window?.makeKeyAndVisible()
    }
    
    func createMainTabBarController() -> UITabBarController {
        let trackerVC = TrackersViewController()
        let trackerNavController = UINavigationController(rootViewController: trackerVC)
        trackerNavController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers"),
            tag: 0
        )
        
        let statsVC = UIViewController()
        statsVC.view.backgroundColor = .white
        statsVC.title = "Статистика"
        let statsNavController = UINavigationController(rootViewController: statsVC)
        statsNavController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "stats"),
            tag: 1
        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [trackerNavController, statsNavController]
        return tabBarController
    }
}

