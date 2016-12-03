//
//  AddFlyrVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import GGNObservable
import CloudKit
import MapKit
import GGNLocationPicker

protocol AddFlyrViewModeling:
AlertOutputing,
ViewControllerOutputing,
FlyrAdding,
TableViewDataSource,
AddFlyrTableViewDelegate {}

protocol FlyrAdding {
    var imageInput: Observable<UIImage?> { get }
    var locationInput: Observable<MKAnnotation?> { get }
    var startDateInput: Observable<Date?> { get }
    var shouldEnableDoneButtonOutput: Observable<Bool> { get }
    var shouldEnableCancelButtonOutput: Observable<Bool> { get }
    var reloadRowAtIndexPathOutput: Observable<IndexPath> { get }
    var recordSaver: RecordSaveable { get }
    func doneButtonTapped()
}

class AddFlyrVM: AddFlyrViewModeling {
    let alertOutput = Observable<UIAlertController>()
    let imageInput = Observable<UIImage?>()
    let locationInput = Observable<MKAnnotation?>()
    let startDateInput = Observable<Date?>()
    let shouldEnableDoneButtonOutput = Observable<Bool>()
    let shouldEnableCancelButtonOutput = Observable<Bool>()
    let reloadRowAtIndexPathOutput = Observable<IndexPath>()
    let recordSaver: RecordSaveable
    let viewControllerOutput = Observable<UIViewController>()

    fileprivate var shouldEnableDoneButton: Bool {
        return imageInput.lastEvent != nil
        && locationInput.lastEvent != nil
        && startDateInput.lastEvent != nil
    }

    init(recordSaver: RecordSaveable) {
        self.recordSaver = recordSaver

        imageInput.onNext { _ in
            let indexPath = IndexPath(row: 0, section: 0)
            self.reloadRowAtIndexPathOutput.emit(indexPath)
            self.shouldEnableDoneButtonOutput.emit(self.shouldEnableDoneButton)
        }

        locationInput.onNext { _ in
            let indexPath = IndexPath(row: 0, section: 1)
            self.reloadRowAtIndexPathOutput.emit(indexPath)
            self.shouldEnableDoneButtonOutput.emit(self.shouldEnableDoneButton)
        }

        startDateInput.onNext { _ in
            let indexPath = IndexPath(row: 0, section: 2)
            self.reloadRowAtIndexPathOutput.emit(indexPath)
            self.shouldEnableDoneButtonOutput.emit(self.shouldEnableDoneButton)
        }
    }

    func doneButtonTapped() {
        shouldEnableDoneButtonOutput.emit(false)
        shouldEnableCancelButtonOutput.emit(false)

        let image = imageInput.lastEvent!
        let _location = location(from: locationInput.lastEvent!!)
        let startDate = startDateInput.lastEvent!
        let reference = AppCoordinator.sharedInstance.ownerReference()!
        let flyr = Flyr(
            image: image!,
            location: _location,
            startDate: startDate!,
            ownerReference: reference
        )

        let record = toFlyrRecord(from: flyr)
        recordSaver.save(record) { response in
            switch response {
            case .successful:
                AppCoordinator.sharedInstance.didFinishAddingFlyr()
            case .notSuccessful(let error):
                let alert = makeAlert(from: error)
                self.alertOutput.emit(alert)
                self.shouldEnableDoneButtonOutput.emit(true)
                self.shouldEnableCancelButtonOutput.emit(true)
            }
        }
    }
}

// MARK: Table view data source & delegate
extension AddFlyrViewModeling {
    func numberOfSections() -> Int {
        return 3
    }

    func numbersOfRows(inSection section: Int) -> Int {
        return 1
    }

    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell()
        let text: String

        switch indexPath.section {
        case 0:
            if let image = imageInput.lastEvent {
                let cell = AddImageCell()
                cell.flyrImageView.image = image
                cell.accessoryType = .none
                cell.textLabel?.text = ""
                return cell
            } else {
                text = "Add Image"
            }
        case 1:
            if let annotation = locationInput.lastEvent {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = annotation!.title!
                cell.detailTextLabel?.text = annotation!.subtitle!
                return cell
            } else {
                text = "Add Location"
            }
        case 2:
            if let date = startDateInput.lastEvent {
                cell.textLabel?.text = date!.description
                return cell
            } else {
                text = "Add Start Date & Time"
            }
        default:
            text = ""
        }

        cell.textLabel?.text = text
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let image = imageInput.lastEvent {
                return rowHeight(from: image!)
            }
        }
        return UITableViewAutomaticDimension
    }

    func didSelectRow(at indexPath: IndexPath, of tableView: UITableView, in vc: AddFlyrVC) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        switch indexPath.section {
        case 0:
            let imagePicker = makeImagePicker(for: vc)
            viewControllerOutput.emit(imagePicker)
        case 1:
            let nav = UINavigationController(rootViewController: makeLocationPicker())
            viewControllerOutput.emit(nav)
        case 2:
            let root = makeDatePicker(for: vc)
            let nav = UINavigationController(rootViewController: root)
            viewControllerOutput.emit(nav)
        default: break
        }
    }

    func makeLocationPicker() -> LocationPickerVC {
        let locationPicker = LocationPickerVC()
        locationPicker.navigationItem.title = "Add Location"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(for: locationPicker)
        locationPicker.didPick = {
            self.locationInput.emit($0)
            locationPicker.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        return locationPicker

    }

    func makeImagePicker(for vc: AddFlyrVC) -> UIViewController {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let picker = UIImagePickerController()
            picker.delegate = vc
            return picker
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let camera = UIAlertAction(title: "Camera", style: .default) { [unowned vc] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = vc
            vc.present(picker, animated: true, completion: nil)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [unowned vc] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = vc
            vc.present(picker, animated: true, completion: nil)
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(cancel)
        alert.addAction(camera)
        alert.addAction(photoLibrary)
        return alert
    }

    func makeDatePicker(for vc: AddFlyrVC) -> DatePickerVC {
        let datePicker = DatePickerVC()
        datePicker.navigationItem.rightBarButtonItem = makeCancelButton(for: datePicker)
        datePicker.didPick = {
            self.startDateInput.emit($0)
            datePicker.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        return datePicker
    }
}

protocol AddFlyrTableViewDelegate {
    func didSelectRow(at indexPath: IndexPath, of tableView: UITableView, in vc: AddFlyrVC)
}

func makeCancelButton(for vc: UIViewController) -> UIBarButtonItem {
    let button = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: vc,
        action: #selector(vc.presentedViewControllerDidCancel)
    )
    return button
}

func toFlyrRecord(from flyr: Flyr) -> CKRecord {
    let image = flyr.image
    let imageURL = url(from: image)
    let imageAsset = CKAsset(fileURL: imageURL)
    let flyrRecord = CKRecord(recordType: "Flyr")
    flyrRecord.setObject(imageAsset, forKey: "image")

    let location = flyr.location
    flyrRecord.setObject(location, forKey: "location")

    let startDate = flyr.startDate
    flyrRecord.setObject(startDate as CKRecordValue?, forKey: "startDate")

    let ownerReference = flyr.ownerReference
    flyrRecord.setObject(ownerReference, forKey: "ownerReference")

    return flyrRecord
}

func url(from image: UIImage) -> URL {
    let directoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectoryPath = directoryPaths[0]
    let baseURL = URL(fileURLWithPath: documentsDirectoryPath)
    let fileURL = URL(string: "currentImage.png", relativeTo: baseURL)!
    try? UIImageJPEGRepresentation(image, 0.75)!.write(to: fileURL, options: [.atomic])
    return fileURL
}

func location(from annotation: MKAnnotation) -> CLLocation {
    let coordinate = annotation.coordinate
    return CLLocation(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
    )
}
