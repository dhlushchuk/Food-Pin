//
//  RestaurantDetailViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 18.07.24.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
    var dataStore: RestaurantDataStore?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: RestaurantDetailHeaderView!
    
    struct TableViewCellIdentifiers {
        static let textCell = "RestaurantDetailTextCell"
        static let twoColumnCell = "RestaurantDetailTwoColumnCell"
        static let mapCell = "RestaurantDetailMapCell"
    }
    
    var restaurant: Restaurant!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMap":
            let mapVC = segue.destination as! MapViewController
            mapVC.restaurant = restaurant
        case "showReview":
            let reviewVC = segue.destination as! ReviewViewController
            reviewVC.restaurant = restaurant
        default: break
        }
    }
    
    private func setup() {
        headerView.headerImageView.image = restaurant.image
        headerView.nameLabel.text = restaurant.name
        headerView.typeLabel.text = restaurant.type
        if let image = restaurant.rating?.image {
            headerView.ratingImageView.image = UIImage(named: image)
        }
        tableView.contentInsetAdjustmentBehavior = .never
        navigationItem.backButtonTitle = ""
        updateHeartButton()
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }
    
    @IBAction func rateRestaurant(segue: UIStoryboardSegue) {
        guard let identifier = segue.identifier else { return }
        dismiss(animated: true) {
            if let rating = Restaurant.Rating(rawValue: identifier) {
                self.restaurant.rating = rating
                self.headerView.ratingImageView.image = UIImage(named: rating.image)
            }
            let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.headerView.ratingImageView.transform = scaleTransform
            self.headerView.ratingImageView.alpha = 0
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.3,
                initialSpringVelocity: 0.7
            ) {
                self.headerView.ratingImageView.transform = .identity
                self.headerView.ratingImageView.alpha = 1
            }
        }
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        restaurant.isFavorite.toggle()
        updateHeartButton()
        dataStore?.updateSnapshot(animatingChange: false)
    }
    
    func updateHeartButton() {
        if let heartButton = navigationItem.rightBarButtonItem {
            let heartImageName = restaurant.isFavorite ? "heart.fill" : "heart"
            heartButton.tintColor = restaurant.isFavorite ? .systemYellow : .white
            heartButton.image = UIImage(systemName: heartImageName)
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RestaurantDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.textCell, for: indexPath) as! RestaurantDetailTextCell
            cell.dexriptionLabel.text = restaurant.summary
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.twoColumnCell, for: indexPath) as! RestaurantDetailTwoColumnCell
            cell.fullAddressLabel.text = restaurant.location
            cell.phoneNumberLabel.text = restaurant.phone
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.mapCell, for: indexPath) as! RestaurantDetailMapCell
            cell.configure(location: restaurant.location)
            return cell
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == 2 ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
