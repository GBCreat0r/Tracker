//
//  SceneDelegate.swift
//  Tracker
//
//  Created by semrumyantsev on 23.06.2025.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Store")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var shared: SceneDelegate {
        return UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let trackersVC = TrackersViewController(context: persistentContainer.viewContext)
        let statisticsVS = StatisticViewController(context: persistentContainer.viewContext)
        
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

