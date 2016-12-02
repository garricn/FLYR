//
//  DatePickerVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/2/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    var didPick: ((_ date: Date) -> Void)?

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.date = Date()
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = 5
        return picker
    }()

    override func loadView() {
        view = tableView
        tableView.dataSource = self
        tableView.delegate = self

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.title = "Add Start Date & Time"
    }

    func doneButtonTapped() {
        didPick?(datePicker.date)
    }
}

extension DatePickerVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: datePicker.superview!.topAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: datePicker.superview!.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: datePicker.superview!.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: datePicker.superview!.trailingAnchor).isActive = true
        return cell
    }
}

extension DatePickerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}
