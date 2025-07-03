//
//  SceneDelegate.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let trackersVC = TrackersViewController()
        let statisticsVS = StatisticViewController()
        
        let navController = UINavigationController(rootViewController: trackersVC)
        
        navController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .tracTabBar), tag: 0)
        statisticsVS.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(resource: .statTabBar), tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navController, statisticsVS]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

