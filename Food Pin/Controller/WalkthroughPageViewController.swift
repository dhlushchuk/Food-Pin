//
//  WalktroughPageViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 23.07.24.
//

import UIKit

protocol WalkthroughPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController {
    
    var pageHeadings = [
        String(localized: "CREATE YOUR OWN FOOD GUIDE"),
        String(localized: "SHOW YOU THE LOCATION"),
        String(localized: "DISCOVER GREAT RESTAURANTS")
    ]
    
    var pageImages = [
        "onboarding-1",
        "onboarding-2",
        "onboarding-3"
    ]
    
    var pageSubHeading = [
        String(localized: "Pin your favorite restaurants and create your own food guide"),
        String(localized: "Search and locate your favorite restaurant on Map"),
        String(localized: "Find restaurants shared by your friends and other foodies")
    ]

    var currentIndex = 0
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        // create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true)
        }
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count { return nil }
        if let pageContentViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeading[index]
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil
    }
    
    func setPage(at index: Int) {
        currentIndex = index
        if let nextViewController = contentViewController(at: index) {
            setViewControllers([nextViewController], direction: .forward, animated: true)
        }
    }

}

// MARK: - UIPageViewControllerDataSource
extension WalkthroughPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return contentViewController(at: index)
    }

}

// MARK: - UIPageViewControllerDelegate
extension WalkthroughPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                currentIndex = contentViewController.index
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.index)
            }
        }
    }
    
}
