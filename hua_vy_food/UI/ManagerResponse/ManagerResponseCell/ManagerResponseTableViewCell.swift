//
//  ManagerResponseTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 04/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class ManagerResponseTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var deleteButton: UIButton!

    private let disposeBag = DisposeBag()

    var handleDeleteResponse: ((String) -> Void)?

    var response = Response()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    private func setupView() {
        contentTextView.do {
            $0.shadowView(cornerRadius: 5)
        }

        deleteButton.rx.tap
            .map { [unowned self] in
                self.handleDeleteResponse?(self.response.id)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func config(response: Response) {
        self.response = response
        nameLabel.text = response.name
        dateLabel.text = "\(response.date)"
        contentTextView.text = response.content
    }
}
