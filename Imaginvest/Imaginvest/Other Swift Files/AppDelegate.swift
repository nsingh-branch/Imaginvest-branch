//
//  AppDelegate.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/22/21.
//

import UIKit
import CoreData
import Branch

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureInitialViewController()

        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            let portData = (params as? [String: AnyObject] ?? [:])
            
            if portData["assets"] != nil {
                print("User tapped deeplink. Opening a portfolio using a deeplink. - Name: \(portData["name"] as? String ?? "???") - Assets: \(portData["assets"]?.count ?? -1)")
                
                //Navigate to preview page and pass portData
                
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preview") as? PreviewVC {
                    vc.linkData = portData
                    
                    if let window = self.window, let rootViewController = window.rootViewController {
                        var currentController = rootViewController
                        
                        while let presentController = currentController.presentedViewController {
                            currentController = presentController
                        }
                        
                        currentController.present(vc, animated: true, completion: nil)
                        }
                    }
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return Branch.getInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      // handler for Universal Links
        return Branch.getInstance().continue(userActivity)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // handler for Push Notifications
      Branch.getInstance().handlePushNotification(userInfo)
    }
    
    private func configureInitialViewController() {
            let initialViewController: UIViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            window = UIWindow()

            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainNav")
            initialViewController = mainVC

            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }


    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Imaginvest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

