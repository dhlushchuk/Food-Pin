//
//  RestaurantDetailHeaderView.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 18.07.24.
//

import UIKit

class RestaurantDetailHeaderView: UIView {

    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            if let customFont = UIFont(name: "Nunito-Bold", size: 40) {
                nameLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont)
            }
        }
    }
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            if let customFont = UIFont(name: "Nunito-Bold", size: 20) {
                typeLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
            }
        }
    }
    
}
