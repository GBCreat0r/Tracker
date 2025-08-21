//
//  SceneDelegate.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit
import AppMetricaCore

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        initializeAppMetrica()
        
        window = UIWindow(windowScene: windowScene)
        
        let trackersVC = TrackersViewController()
        let statisticsVS = StatisticViewController()
        
        let navController = UINavigationController(rootViewController: trackersVC)
        
        navController.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers_title", comment: "Кнопка в тапбаре"),
                                                image: UIImage(resource: .tracTabBar), tag: 0)
        statisticsVS.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics_title", comment: "Кнопка в тапбаре")
                                               , image: UIImage(resource: .statTabBar), tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navController, statisticsVS]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    private func initializeAppMetrica() {
        let configuration = AppMetricaConfiguration(apiKey: "b3c96578-26c1-47a2-a733-f883d41a21ea")
        AppMetrica.activate(with: configuration!)
    }
}

