//
//  PopupListViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 18/08/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class PopupListViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var popupView: UIView!
    @IBOutlet private weak var searchViewContainer: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var doneButton: UIButton!

    private let disposeBag = DisposeBag()

    private var tableViewContent: [Any] = []
    private var searchContent: [Any] = []
    private var selectedData: Any?
    var handleDoneButton: ((Any) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(PopupTableViewTableViewCell.nib,
                        forCellReuseIdentifier: PopupTableViewTableViewCell.identifier)
        }

        searchTextField.do {
            $0.delegate = self
            $0.shadowView()
        }

        doneButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, shadowRadius: 5, cornerRadius: 5)
        }

        doneButton.rx.tap
            .map { [unowned self] in
                doneButton.animationSelect()
                handleDoneButton?(selectedData)
                dismiss(animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        clearButton.rx.tap
            .map { [unowned self] in
                clearButton.animationSelect()
                searchTextField.text = nil
                searchContent = tableViewContent
                tableView.reloadData()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func getData(tableViewData: [Any], selectedData: Any? = nil) {
        self.tableViewContent = tableViewData
        self.searchContent = tableViewData
        self.selectedData = selectedData
        tableView.reloadData()
    }
}

extension PopupListViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchContent = tableViewContent
        var _searchContent = [ProductCategory]()
        _searchContent = searchContent as? [ProductCategory] ?? []
        if let textFieldText = textField.text,
           !_searchContent.isEmpty {
            _searchContent = _searchContent.filter({ content in
                content.name.uppercased().contains(textFieldText.uppercased())
            })
            searchContent = _searchContent
            tableView.reloadData()
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PopupListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchContent.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopupTableViewTableViewCell.identifier, for: indexPath) as? PopupTableViewTableViewCell
        guard let cell = cell else { return UITableViewCell() }
        cell.awakeFromNib()
        cell.configCell(data: searchContent[indexPath.row], dataSelected: selectedData)
        return cell
    }
}

extension PopupListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedData = searchContent[indexPath.row]
        tableView.reloadData()
    }
}
