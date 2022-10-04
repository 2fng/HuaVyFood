//
//  ManagerResponseViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 04/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class ManagerResponseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        tableView.do {
            $0.dataSource = self
            $0.delegate = self
            $0.register(ManagerResponseTableViewCell.nib, forCellReuseIdentifier: ManagerResponseTableViewCell.identifier)
        }
    }
}

extension ManagerResponseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManagerResponseTableViewCell.identifier) as? ManagerResponseTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}

extension ManagerResponseViewController: UITableViewDelegate {

}
