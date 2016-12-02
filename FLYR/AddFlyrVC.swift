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
    private let viewModel: AddFlyrViewModeling
    private let ownerReference: CKReference
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)

    init(viewModel: AddFlyrViewModeling, ownerReference: CKReference) {
        self.viewModel = viewModel
        self.ownerReference = ownerReference
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = resolvedAddFlyrVM()
        self.ownerReference = CKReference(
            recordID: CKRecordID(recordName: ""),
            action: .None
        )
        super.init(coder: aDecoder)
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbarHidden = true
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }

    func setupNavigationItems() {
        navigationItem.title = "Add Flyr"
        navigationItem.rightBarButtonItem = makeCancelButton(fore: self)
        navigationItem.leftBarButtonItem = {
            let item = UIBarButtonItem(
                barButtonSystemItem: .Done,
                target: self,
                action: #selector(doneButtonTapped)
            )
            item.enabled = false
            return item
        }()
    }

    func setupObservers() {
        viewModel.shouldEnableDoneButtonOutput.onNext { [weak self] bool in
            self?.navigationItem.leftBarButtonItem?.enabled = bool
        }

        viewModel.shouldEnableCancelButtonOutput.onNext { [weak self] bool in
            self?.navigationItem.rightBarButtonItem?.enabled = bool
        }

        viewModel.alertOutput.onNext { [weak self] in
            self?.presentViewController($0, animated: true, completion: nil)
        }

        viewModel.reloadRowAtIndexPathOutput.onNext { [weak self] in
            self?.tableView.reloadRowsAtIndexPaths([$0], withRowAnimation: .Automatic)
        }

        viewModel.viewControllerOutput.onNext { [weak self] in
            self?.presentViewController($0, animated: true, completion: nil)
        }
    }

    func doneButtonTapped() {
        viewModel.doneButtonTapped()
    }

    func pickerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddFlyrVC: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersOfRows(inSection: section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return viewModel.cellForRow(at: indexPath, en: tableView)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
}

extension AddFlyrVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.didSelectRow(at: indexPath, of: tableView, en: self)
    }
}

extension AddFlyrVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        viewModel.imageInput.emit(image)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
