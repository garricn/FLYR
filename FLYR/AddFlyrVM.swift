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
    var startDateInput: Observable<NSDate?> { get }
    var shouldEnableDoneButtonOutput: Observable<Bool> { get }
    var shouldEnableCancelButtonOutput: Observable<Bool> { get }
    var reloadRowAtIndexPathOutput: Observable<NSIndexPath> { get }
    var recordSaver: RecordSaveable { get }
    func doneButtonTapped()
}

struct AddFlyrVM: AddFlyrViewModeling {
    let alertOutput = Observable<UIAlertController>()
    let imageInput = Observable<UIImage?>()
    let locationInput = Observable<MKAnnotation?>()
    let startDateInput = Observable<NSDate?>()
    let shouldEnableDoneButtonOutput = Observable<Bool>()
    let shouldEnableCancelButtonOutput = Observable<Bool>()
    let reloadRowAtIndexPathOutput = Observable<NSIndexPath>()
    let recordSaver: RecordSaveable
    let viewControllerOutput = Observable<UIViewController>()

    private var shouldEnableDoneButton: Bool {
        return imageInput.lastEvent != nil
        && locationInput.lastEvent != nil
        && startDateInput.lastEvent != nil
    }

    init(recordSaver: RecordSaveable) {
        self.recordSaver = recordSaver

        imageInput.onNext { _ in
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.reloadRowAtIndexPathOutput.emit(indexPath)
            self.shouldEnableDoneButtonOutput.emit(self.shouldEnableDoneButton)
        }

        locationInput.onNext { _ in
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            self.reloadRowAtIndexPathOutput.emit(indexPath)
            self.shouldEnableDoneButtonOutput.emit(self.shouldEnableDoneButton)
        }

        startDateInput.onNext { _ in
            let indexPath = NSIndexPath(forRow: 0, inSection: 2)
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
            case .Successful:
                AppCoordinator.sharedInstance.didFinishAddingFlyr()
            case .NotSuccessful(let error):
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

    func cellForRow(at indexPath: NSIndexPath, en tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell()
        let text: String

        switch indexPath.section {
        case 0:
            if let image = imageInput.lastEvent {
                let cell = AddImageCell()
                cell.flyrImageView.image = image
                cell.accessoryType = .None
                cell.textLabel?.text = ""
                return cell
            } else {
                text = "Add Image"
            }
        case 1:
            if let annotation = locationInput.lastEvent {
                let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
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
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

    func heightForRow(at indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let image = imageInput.lastEvent {
                return rowHeight(from: image!)
            }
        }
        return UITableViewAutomaticDimension
    }

    func didSelectRow(at indexPath: NSIndexPath, of tableView: UITableView, en vc: AddFlyrVC) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        switch indexPath.section {
        case 0:
            let imagePicker = makeImagePicker(fore: vc)
            viewControllerOutput.emit(imagePicker)
        case 1:
            let nav = UINavigationController(rootViewController: makeLocationPicker())
            viewControllerOutput.emit(nav)
        case 2:
            let root = makeDatePicker(fore: vc)
            let nav = UINavigationController(rootViewController: root)
            viewControllerOutput.emit(nav)
        default: break
        }
    }

    func makeLocationPicker() -> LocationPickerVC {
        let locationPicker = LocationPickerVC()
        locationPicker.navigationItem.title = "Add Location"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(fore: locationPicker)
        locationPicker.didPick = {
            self.locationInput.emit($0)
            locationPicker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        return locationPicker

    }

    func makeImagePicker(fore vc: AddFlyrVC) -> UIViewController {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            let picker = UIImagePickerController()
            picker.delegate = vc
            return picker
        }

        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let camera = UIAlertAction(title: "Camera", style: .Default) { [unowned vc] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = vc
            vc.presentViewController(picker, animated: true, completion: nil)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .Default) { [unowned vc] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = vc
            vc.presentViewController(picker, animated: true, completion: nil)
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(cancel)
        alert.addAction(camera)
        alert.addAction(photoLibrary)
        return alert
    }

    func makeDatePicker(fore vc: AddFlyrVC) -> DatePickerVC {
        let datePicker = DatePickerVC()
        datePicker.navigationItem.rightBarButtonItem = makeCancelButton(fore: datePicker)
        datePicker.didPick = {
            self.startDateInput.emit($0)
            datePicker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        return datePicker
    }
}

protocol AddFlyrTableViewDelegate {
    func didSelectRow(at indexPath: NSIndexPath, of tableView: UITableView, en vc: AddFlyrVC)
}

func makeCancelButton(fore vc: UIViewController) -> UIBarButtonItem {
    let button = UIBarButtonItem(
        barButtonSystemItem: .Cancel,
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
    flyrRecord.setObject(startDate, forKey: "startDate")

    let ownerReference = flyr.ownerReference
    flyrRecord.setObject(ownerReference, forKey: "ownerReference")

    return flyrRecord
}

func url(from image: UIImage) -> NSURL {
    let dirPaths = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory,
        .UserDomainMask, true
    )
    let docsDir: AnyObject = dirPaths[0]
    let filePath = docsDir.stringByAppendingPathComponent("currentImage.png")
    UIImageJPEGRepresentation(image, 0.75)!.writeToFile(filePath, atomically: true)
    return NSURL.fileURLWithPath(filePath)
}

func location(from annotation: MKAnnotation) -> CLLocation {
    let coordinate = annotation.coordinate
    return CLLocation(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
    )
}
