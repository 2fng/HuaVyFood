//
//  ImageSliderCollectionViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/09/2022.
//

import UIKit

final class ImageSliderCollectionViewCell: UICollectionViewCell, ReuseableCell {
    @IBOutlet weak var sliderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(image: UIImage) {
        sliderImageView.image = image
    }
}
