//
//  PopupTableViewTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 18/08/2022.
//

import UIKit

final class PopupTableViewTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkMarkImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configCell(data: Any, dataSelected: Any?) {
        if let data = data as? ProductCategory {
            titleLabel.text = data.name
            if dataSelected != nil,
                let dataSelected = dataSelected as? ProductCategory {
                checkMarkImage.isHidden = data.id == dataSelected.id ? false : true
            } else {
                checkMarkImage.isHidden = true
            }
        }
    }
}
