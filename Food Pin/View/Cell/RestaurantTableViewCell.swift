//
//  RestaurantTableViewCell.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 18.07.24.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
