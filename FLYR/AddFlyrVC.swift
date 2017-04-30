//
//  AddFlyrVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import MapKit
import GGNObservable
import GGNLocationPicker
import CloudKit

class AddFlyrVC: UIViewController {
    fileprivate let viewModel: AddFlyrViewModeling
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)

    init(viewModel: AddFlyrViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Awww!")
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItems()
        setupTableView()
        setupObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }

    func setupNavigationItems() {
        navigationItem.title = "Add Flyr"
        navigationItem.rightBarButtonItem = makeCancelButton(for: self)
        navigationItem.leftBarButtonItem = {
            let item = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(doneButtonTapped)
            )
            item.isEnabled = false
            return item
        }()
    }

    func setupObservers() {
        viewModel.shouldEnableDoneButtonOutput.onNext { [weak self] bool in
            self?.navigationItem.leftBarButtonItem?.isEnabled = bool
        }

        viewModel.shouldEnableCancelButtonOutput.onNext { [weak self] bool in
            self?.navigationItem.rightBarButtonItem?.isEnabled = bool
        }

        viewModel.reloadRowAtIndexPathOutput.onNext { [weak self] in
            self?.tableView.reloadRows(at: [$0], with: .automatic)
        }

        viewModel.viewControllerOutput.onNext { [weak self] in
            self?.present($0, animated: true, completion: nil)
        }
    }

    func doneButtonTapped() {
        viewModel.doneButtonTapped()
    }

    func pickerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension AddFlyrVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRows(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForRow(at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
}

extension AddFlyrVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath, of: tableView, in: self)
    }
}

extension AddFlyrVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        viewModel.imageInput.emit(image)
        dismiss(animated: true, completion: nil)
    }
}
