//
//  UserOrderViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class UserOrderViewController: UIViewController {
    @IBOutlet weak var orderTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        orderTableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(UserOrderTableViewCell.nib, forCellReuseIdentifier: UserOrderTableViewCell.identifier)
        }
    }
}

extension UserOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserOrderTableViewCell.identifier) as? UserOrderTableViewCell else {
            return UITableViewCell()
        }
        cell.layer.cornerRadius = 5
        return cell
    }
}

extension UserOrderViewController: UITableViewDelegate {
    
}
