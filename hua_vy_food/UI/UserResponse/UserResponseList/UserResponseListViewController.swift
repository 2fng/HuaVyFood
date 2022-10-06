//
//  UserResponseListViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 06/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class UserResponseListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var createButton: UIButton!

    private let disposeBag = DisposeBag()
    private let viewModel = UserResponseListViewModel(userRepository: UserRepository())

    private let getResponseTrigger = PublishSubject<Void>()

    private var responses = [Response]()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(ManagerResponseTableViewCell.nib,
                               forCellReuseIdentifier: ManagerResponseTableViewCell.identifier)
        }

        createButton.do {
            $0.layer.cornerRadius = 25
            $0.shadowView(color: .logoPink, cornerRadius: 25)
        }

        createButton.rx.tap
            .map { [unowned self] in
                createButton.animationSelect()
                let vc = UserResponseViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = UserResponseListViewModel.Input(getResponseTrigger: getResponseTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.responses
            .drive(responsesBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        getResponseTrigger.onNext(())
    }
}

extension UserResponseListViewController {
    private var responsesBinder: Binder<[Response]> {
        return Binder(self) { vc, responses in
            vc.responses = responses
            vc.tableView.reloadData()
        }
    }
}

extension UserResponseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManagerResponseTableViewCell.identifier) as? ManagerResponseTableViewCell else {
            return UITableViewCell()
        }
        cell.config(response: responses[indexPath.row])
        cell.handleDeleteResponse = { [unowned self] responseID in
            print("Delete \(responseID)")
        }
        return cell
    }
}

extension UserResponseListViewController: UITableViewDelegate {

}
