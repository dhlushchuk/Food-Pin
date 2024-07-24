//
//  DiscoverTableViewCell.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 24.07.24.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
