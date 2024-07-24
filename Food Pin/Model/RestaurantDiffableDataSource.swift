//
//  RestaurantDiffableDataSource.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 18.07.24.
//

import UIKit

enum Section {
    case all
}

class RestaurantDiffableDataSource: UITableViewDiffableDataSource<Section, Restaurant> {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let restaurant = self.itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                snapshot.deleteItems([restaurant])
                apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
}
