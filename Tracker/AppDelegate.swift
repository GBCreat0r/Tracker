//
//  AppDelegate.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        
//        let trackersVC = TrackersViewController()
//        let statisticsVS = StatisticViewController()
//        
//        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .tracTabBar), tag: 0)
//        statisticsVS.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(resource: .statTabBar), tag: 1)
//        
//        let tabBarController = UITabBarController()
//        tabBarController.viewControllers = [trackersVC, statisticsVS]
//        
//        window?.rootViewController = tabBarController
//        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

