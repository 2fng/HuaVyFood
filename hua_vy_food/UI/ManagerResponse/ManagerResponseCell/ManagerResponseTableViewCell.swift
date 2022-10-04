//
//  ManagerResponseTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 04/10/2022.
//

import UIKit

final class ManagerResponseTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private  weak var dateLabel: UILabel!
    @IBOutlet private  weak var contentTextView: UITextView!
    @IBOutlet private  weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
