//
//  WalktroughViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 23.07.24.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true)
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkthroughPageViewController?.setPage(at: pageControl.currentPage + 1)
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                createQuickActions()
                dismiss(animated: true)
            default: break
            }
        }
        updateUI()
    }
    
    @IBAction func pageControlPressed(_ sender: UIPageControl) {
        walkthroughPageViewController?.setPage(at: sender.currentPage)
        updateUI()
    }
    
    func updateUI() {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                let headlineFont: UIFont = .preferredFont(forTextStyle: .headline)
                let attributedTitle = NSAttributedString(
                    string: String(localized: "NEXT"),
                    attributes: [.font: headlineFont]
                )
                nextButton.setAttributedTitle(attributedTitle, for: .normal)
                skipButton.isHidden = false
            case 2:
                let headlineFont: UIFont = .preferredFont(forTextStyle: .headline)
                let attributedTitle = NSAttributedString(
                    string: String(localized: "GET STARTED"),
                    attributes: [.font: headlineFont]
                )
                nextButton.setAttributedTitle(attributedTitle, for: .normal)
                skipButton.isHidden = true
            default: break
            }
            pageControl.currentPage = index
        }
    }
    
    func createQuickActions() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let showFavoritesShortcutItem = UIApplicationShortcutItem(
                type: "\(bundleIdentifier).OpenFavorites",
                localizedTitle: "Show Favorites",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "tag"),
                userInfo: nil
            )
            let discoverRestaurantsShortcutItem = UIApplicationShortcutItem(
                type: "\(bundleIdentifier).OpenDiscover",
                localizedTitle: "Discover Restaurants",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "eyes"),
                userInfo: nil
            )
            let newRestaurantShortcutItem = UIApplicationShortcutItem(
                type: "\(bundleIdentifier).NewRestaurant",
                localizedTitle: "New Restaurant",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(type: .add),
                userInfo: nil
            )
            UIApplication.shared.shortcutItems = [
                showFavoritesShortcutItem,
                discoverRestaurantsShortcutItem,
                newRestaurantShortcutItem
            ]
        }
    }
    
}

// MARK: - WalkthroughPageViewControllerDelegate
extension WalkthroughViewController: WalkthroughPageViewControllerDelegate {
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
}
