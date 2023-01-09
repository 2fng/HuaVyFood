//
//  DetailProductTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 09/01/2023.
//

import UIKit

final class DetailProductTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(comment: Comment) {
        let date = "\(comment.date)"
        viewContainer.layer.cornerRadius = 5
        textView.text = comment.content
        dateLabel.text = "\(date.prefix(10))"
    }
}
