//
//  DatePickerVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/2/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    var didPick: ((date: NSDate) -> Void)?

    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.date = NSDate()
        picker.datePickerMode = .DateAndTime
        picker.minuteInterval = 5
        return picker
    }()

    override func loadView() {
        view = tableView
        tableView.dataSource = self
        tableView.delegate = self

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.title = "Add Start Date & Time"
    }

    func doneButtonTapped() {
        didPick?(date: datePicker.date)
    }
}

extension DatePickerVC: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.addSubview(datePicker)
        datePicker.topAnchor.constraintEqualToAnchor(datePicker.superview?.topAnchor).active = true
        datePicker.bottomAnchor.constraintEqualToAnchor(datePicker.superview?.bottomAnchor).active = true
        datePicker.leadingAnchor.constraintEqualToAnchor(datePicker.superview?.leadingAnchor).active = true
        datePicker.trailingAnchor.constraintEqualToAnchor(datePicker.superview?.trailingAnchor).active = true
        return cell
    }
}

extension DatePickerVC: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
}
