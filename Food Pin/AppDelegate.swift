//
//  AppDelegate.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 18.07.24.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupNavigationBar()
        setupTabBar()
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        var backButtonImage = UIImage(systemName: "arrow.backward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        backButtonImage = backButtonImage?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0))
        navBarAppearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        if let customFont = UIFont(name: "Nunito-Bold", size: 40) {
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.navigationBarTitle,
                .font: customFont
            ]
            navBarAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.navigationBarTitle,
                .font: customFont
            ]
        }
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }

    private func setupTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().tintColor = .navigationBarTitle
        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "foodpin.makeReservation" {
            if let phone = response.notification.request.content.userInfo["phone"] {
                let telURL = "tel://\(phone)"
                if let url = URL(string: telURL) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } else {
            let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            if let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                if let restaurantID = response.notification.request.content.userInfo["restaurantID"] as? Int {
                    if let navController = tabBarController.viewControllers?.first {
                        if let restaurantTableViewController = navController.children.first as? RestaurantTableViewController {
                            let indexPath = IndexPath(item: restaurantID, section: 0)
                            let sender = restaurantTableViewController.tableView.cellForRow(at: indexPath)
                            restaurantTableViewController.performSegue(
                                withIdentifier: "showRestaurantDetail",
                                sender: sender
                            )
                        }
                    }
                }
            }
        }
        completionHandler()
    }
    
}
