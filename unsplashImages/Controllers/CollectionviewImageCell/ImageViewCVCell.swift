//
//  ImageViewCVCell.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 13/04/24.
//

import UIKit

class ImageViewCVCell: UICollectionViewCell {

    @IBOutlet weak var mainContainView: UIView!
    @IBOutlet weak var imagView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainContainView.addShadow()
    }

}
