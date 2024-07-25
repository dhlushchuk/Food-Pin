//
//  RestaurantTableViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 18.07.24.
//

import UIKit
import SwiftData
import UserNotifications

protocol RestaurantDataStore {
    func fetchRestaurantData(searchText: String)
    func updateSnapshot(animatingChange: Bool)
}

class RestaurantTableViewController: UITableViewController, RestaurantDataStore {
    
    var restaurants = [Restaurant]() {
        didSet {
            tableView.backgroundView?.isHidden = restaurants.isEmpty ? false : true
        }
    }
    
    // instantiate the model container
    let container = try? ModelContainer(for: Restaurant.self)
    private lazy var dataSource = configureDataSource()
    
    @IBOutlet weak var emptyRestaurantView: UIView!
    var searchController: UISearchController! {
        didSet {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = String(localized: "Search restaurants...")
            searchController.searchBar.tintColor = .navigationBarTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = dataSource
        
        // empty view
        tableView.backgroundView = emptyRestaurantView
        
        // add a search bar
        searchController = UISearchController()
        navigationItem.searchController = searchController
        
        // get data from database
        fetchRestaurantData(searchText: "")
        
        // setup user notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                // configure the notifications
                self.prepareNotification()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
                present(walkthroughViewController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
        guard !searchController.isActive else { return nil }
        
        // delete action
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: String(localized: "Delete")
        ) { action, sourceView, completionHandler in
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteItems([restaurant])
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.container?.mainContext.delete(restaurant)
            completionHandler(true)
        }
        
        // share action
        let shareAction = UIContextualAction(
            style: .normal,
            title: String(localized: "Share")
        ) { action, sourceView, completionHandler in
            let text = "Just checking in at " + restaurant.name
            var activityController: UIActivityViewController
            if let image = restaurant.image {
                activityController = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            }
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            self.present(activityController, animated: true)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        shareAction.backgroundColor = .systemOrange
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        // both actions as swipe action
        let swapActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return swapActionsConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !searchController.isActive else { return nil }
        
        // mark as favorite action
        let favoriteAction = UIContextualAction(style: .normal, title: nil) { action, sourceView, completion in
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
            cell.favoriteImageView.isHidden.toggle()
            self.restaurants[indexPath.row].isFavorite.toggle()
            completion(true)
        }
        let favoritActionImage = self.restaurants[indexPath.row].isFavorite ? UIImage(systemName: "heart.slash.fill") : UIImage(systemName: "heart.fill")
        favoriteAction.backgroundColor = .systemOrange
        favoriteAction.image = favoritActionImage
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let restaurant = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let configuration = UIContextMenuConfiguration(identifier: indexPath.row as NSCopying, previewProvider: {
            guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController else { return nil }
            restaurantDetailViewController.restaurant = restaurant
            return restaurantDetailViewController
        }) { actions in
            let favoriteAction = UIAction(
                title: "Save as favorite",
                image: UIImage(systemName: "heart")
            ) { action in
                let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
                self.restaurants[indexPath.row].isFavorite.toggle()
                cell.favoriteImageView.isHidden = !self.restaurants[indexPath.row].isFavorite
            }
            let shareAction = UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { action in
                let text = "Just checking in at " + restaurant.name
                var activityController: UIActivityViewController
                if let image = restaurant.image {
                    activityController = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
                } else {
                    activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                }
                if let popoverController = activityController.popoverPresentationController {
                    if let cell = tableView.cellForRow(at: indexPath) {
                        popoverController.sourceView = cell
                        popoverController.sourceRect = cell.bounds
                    }
                }
                self.present(activityController, animated: true)
            }
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { action in
                var snapshot = self.dataSource.snapshot()
                snapshot.deleteItems([restaurant])
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.container?.mainContext.delete(restaurant)
            }
            return UIMenu(title: "", children: [favoriteAction, shareAction, deleteAction])
        }
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        guard let selectedRow = configuration.identifier as? Int else { return }
        guard let restaurantDetailViewController = storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController else { return }
        restaurantDetailViewController.restaurant = restaurants[selectedRow]
        animator.preferredCommitStyle = .pop
        animator.addCompletion {
            self.show(restaurantDetailViewController, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            let detailVC = segue.destination as! RestaurantDetailViewController
            
            if let indexPath = tableView.indexPath(for: sender as! RestaurantTableViewCell){
                detailVC.restaurant = restaurants[indexPath.row]
            }
            detailVC.dataStore = self
        } else if segue.identifier == "addRestaurant" {
            if let navController = segue.destination as? UINavigationController {
                let addRestaurantVC = navController.topViewController as! NewRestaurantController
                addRestaurantVC.dataStore = self
            }
        }
    }

    func configureDataSource() -> RestaurantDiffableDataSource {
        let cellIdentifier = "RestaurantCell"
        
        let dataSource = RestaurantDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, restaurant in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
                cell.nameLabel.text = restaurant.name
                cell.locationLabel.text = restaurant.location
                cell.typeLabel.text = restaurant.type
                cell.thumbnailImageView.image = restaurant.image
                cell.favoriteImageView.isHidden = !restaurant.isFavorite
                return cell
            }
        )
        return dataSource
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }
    
    func fetchRestaurantData(searchText: String) {
        let descriptor: FetchDescriptor<Restaurant>
        if searchText.isEmpty {
            descriptor = FetchDescriptor<Restaurant>()
        } else {
            let predicate = #Predicate<Restaurant> {
                $0.name.localizedStandardContains(searchText) ||
                $0.location.localizedStandardContains(searchText)
            }
            descriptor = FetchDescriptor<Restaurant>(predicate: predicate)
        }
        restaurants = (try? container?.mainContext.fetch(descriptor)) ?? []
        updateSnapshot()
    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }
    
    func prepareNotification() {
        if restaurants.count <= 0 { return }
        
        // pick a random restaurant
        let randomNum = Int.random(in: 0..<restaurants.count)
        let suggestedRestaurant = restaurants[randomNum]
        
        // create the user notification
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recomend you to check out \(suggestedRestaurant.name). The restaurant is one of your favorites. It is located at \(suggestedRestaurant.location). Would you like to give it a try?"
        content.sound = UNNotificationSound.default
        let tempDirURL = URL(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        try? suggestedRestaurant.image?.jpegData(compressionQuality: 1)?.write(to: tempFileURL)
        if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
            content.attachments = [restaurantImage]
        }
        let categoryIdentifier = "foodpin.restarantaction"
        let makeReservationAction = UNNotificationAction(identifier: "foodpin.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "foodpin.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        content.categoryIdentifier = categoryIdentifier
        let restaurantID = restaurants.firstIndex(of: suggestedRestaurant)!
        content.userInfo = ["phone": suggestedRestaurant.phone, "restaurantID": restaurantID]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(
            identifier: "foodpin.restaurantSuggestion",
            content: content,
            trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        // add the notification
        center.add(request)
    }
    
}

// MARK: - UISearchResultsUpdating
extension RestaurantTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        fetchRestaurantData(searchText: searchText)
    }
    
}
