//
//  DiscoverTableViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 24.07.24.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var restaurants = [CKRecord]()
    lazy var dataSource = configureDataSource()
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .medium
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.cellLayoutMarginsFollowReadableWidth = true
        fetchRecordsFromCloud()
        setupSpinner()
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: .valueChanged)
    }

    func configureDataSource() -> UITableViewDiffableDataSource<Section, CKRecord> {
        let dataSource = UITableViewDiffableDataSource<Section, CKRecord>(tableView: tableView) { tableView, indexPath, restaurant in
            let cell = tableView.dequeueReusableCell(withIdentifier: "discovercell", for: indexPath) as! DiscoverTableViewCell
            cell.nameLabel.text = restaurant.object(forKey: "name") as? String
            cell.locationLabel.text = restaurant.object(forKey: "location") as? String
            cell.typeLabel.text = restaurant.object(forKey: "type") as? String
            cell.descriptionLabel.text = restaurant.object(forKey: "description") as? String
            cell.thumbnailImageView.image = UIImage(systemName: "photo")?.withTintColor(.black)
            if let imageFileURL = self.imageCache.object(forKey: restaurant.recordID) {
                if let imageData = try? Data(contentsOf: imageFileURL as URL) {
                    cell.thumbnailImageView.image = UIImage(data: imageData)
                }
            } else {
                let publicDatabase = CKContainer.default().publicCloudDatabase
                let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
                fetchRecordsImageOperation.desiredKeys = ["image"]
                fetchRecordsImageOperation.queuePriority = .veryHigh
                fetchRecordsImageOperation.perRecordResultBlock = { recordId, result in
                    do {
                        let restaurantRecord = try result.get()
                        if let image = restaurantRecord.object(forKey: "image"),
                           let imageAsset = image as? CKAsset {
                            if let imageData = try? Data(contentsOf: imageAsset.fileURL!) {
                                DispatchQueue.main.async {
                                    cell.thumbnailImageView.image = UIImage(data: imageData)
                                    cell.setNeedsLayout()
                                }
                            }
                            self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: restaurant.recordID)
                        }
                    } catch {
                        print("Failed to get restaurant image: \(error.localizedDescription)")
                    }
                }
                publicDatabase.add(fetchRecordsImageOperation)
            }
            return cell
        }
        return dataSource
    }
    
//    operational API
    @objc func fetchRecordsFromCloud() {
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "location", "type", "description"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordMatchedBlock = { recordID, result in
            do {
                if let _ = self.restaurants.first(where: { $0.recordID == recordID }) { return }
                self.restaurants.append(try result.get())
            } catch {
                print(error.localizedDescription)
            }
        }
        queryOperation.queryResultBlock = { [unowned self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success:
                self.updateSnapshot()
            }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.refreshControl?.endRefreshing()
            }
        }
        publicDatabase.add(queryOperation)
    }
    
//    convenience API
//    func fetchRecordsFromCloud() async throws {
//        let cloudContainer = CKContainer.default()
//        let publicDatabase = cloudContainer.publicCloudDatabase
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
//        let results = try await publicDatabase.records(matching: query)
//        for record in results.matchResults {
//            restaurants.append(try record.1.get())
//        }
//        updateSnapshot()
//    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CKRecord>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        dataSource.apply(snapshot)
    }
    
    private func setupSpinner() {
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        spinner.startAnimating()
    }
    
}
