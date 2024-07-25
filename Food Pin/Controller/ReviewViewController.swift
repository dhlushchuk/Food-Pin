//
//  ReviewViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 22.07.24.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var rateButtons: [UIButton]!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var restaurant: Restaurant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = restaurant.image
        // applying the blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        setupAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // animate the close button
        UIView.animate(withDuration: 1) {
            self.closeButton.transform = .identity
        }
        var delay = 0.1
        for rateButton in self.rateButtons {
            UIView.animate(withDuration: 0.4, delay: delay) {
                rateButton.alpha = 1
                rateButton.transform = .identity
                delay += 0.05
            }
        }
    }
    
    private func setupAnimation() {
        let moveRightTransform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
        let scaleUpTransform = CGAffineTransform(scaleX: 5, y: 5)
        let moveAndScaleTransform = moveRightTransform.concatenating(scaleUpTransform)
        for rateButton in rateButtons {
            rateButton.alpha = 0
            rateButton.transform = moveAndScaleTransform
        }
        
        let moveTopTransform = CGAffineTransform(translationX: 0, y: -self.view.frame.height / 2)
        closeButton.transform = moveTopTransform
    }

}
