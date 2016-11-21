//
//  AddFlyrVM.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import Bond
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
    var shouldEnableDoneButtonOutput: EventProducer<Bool> { get }
    var shouldEnableCancelButtonOutput: EventProducer<Bool> { get }
    var reloadRowAtIndexPathOutput: EventProducer<NSIndexPath> { get }
    var recordSaver: RecordSaveable { get }
    func doneButtonTapped()
}

struct AddFlyrVM: AddFlyrViewModeling {
    let alertOutput = EventProducer<UIAlertController>()
    let imageInput = Observable<UIImage?>(nil)
    let locationInput = Observable<MKAnnotation?>(nil)
    let startDateInput = Observable<NSDate?>(nil)
    let shouldEnableDoneButtonOutput = EventProducer<Bool>()
    let shouldEnableCancelButtonOutput = EventProducer<Bool>()
    let reloadRowAtIndexPathOutput = EventProducer<NSIndexPath>()
    let recordSaver: RecordSaveable
    let viewControllerOutput = EventProducer<UIViewController>()

    private var shouldEnableDoneButton: Bool {
        return imageInput.value != nil
        && locationInput.value != nil
        && startDateInput.value != nil
    }

    init(recordSaver: RecordSaveable) {
        self.recordSaver = recordSaver

        imageInput.observe { _ in
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.reloadRowAtIndexPathOutput.next(indexPath)
            self.shouldEnableDoneButtonOutput.next(self.shouldEnableDoneButton)
        }

        locationInput.observe { _ in
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            self.reloadRowAtIndexPathOutput.next(indexPath)
            self.shouldEnableDoneButtonOutput.next(self.shouldEnableDoneButton)
        }

        startDateInput.observe { _ in
            let indexPath = NSIndexPath(forRow: 0, inSection: 2)
            self.reloadRowAtIndexPathOutput.next(indexPath)
            self.shouldEnableDoneButtonOutput.next(self.shouldEnableDoneButton)
        }
    }

    func doneButtonTapped() {
        shouldEnableDoneButtonOutput.next(false)
        shouldEnableCancelButtonOutput.next(false)

        let image = imageInput.value!
        let _location = location(from: locationInput.value!)
        let startDate = startDateInput.value!
        let reference = AppCoordinator.sharedInstance.ownerReference()!
        let flyr = Flyr(
            image: image,
            location: _location,
            startDate: startDate,
            ownerReference: reference
        )

        let record = toFlyrRecord(from: flyr)
        recordSaver.save(record) { response in
            switch response {
            case .Successful:
                AppCoordinator.sharedInstance.didFinishAddingFlyr()
            case .NotSuccessful(let error):
                let alert = makeAlert(from: error)
                self.alertOutput.next(alert)
                self.shouldEnableDoneButtonOutput.next(true)
                self.shouldEnableCancelButtonOutput.next(true)
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
            if let image = imageInput.value {
                let cell = AddImageCell()
                cell.flyrImageView.image = image
                cell.accessoryType = .None
                cell.textLabel?.text = ""
                return cell
            } else {
                text = "Add Image"
            }
        case 1:
            if let annotation = locationInput.value {
                let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = annotation.title!
                cell.detailTextLabel?.text = annotation.subtitle!
                return cell
            } else {
                text = "Add Location"
            }
        case 2:
            if let date = startDateInput.value {
                cell.textLabel?.text = date.description
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
        if let image = imageInput.value where indexPath.section == 0 {
            return rowHeight(from: image)
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func didSelectRow(at indexPath: NSIndexPath, of tableView: UITableView, en vc: AddFlyrVC) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        switch indexPath.section {
        case 0:
            let imagePicker = makeImagePicker(fore: vc)
            viewControllerOutput.next(imagePicker)
        case 1:
            let nav = UINavigationController(rootViewController: makeLocationPicker())
            viewControllerOutput.next(nav)
        case 2:
            let root = makeDatePicker(fore: vc)
            let nav = UINavigationController(rootViewController: root)
            viewControllerOutput.next(nav)
        default: break
        }
    }

    func makeLocationPicker() -> LocationPickerVC {
        let locationPicker = LocationPickerVC()
        locationPicker.navigationItem.title = "Add Location"
        locationPicker.navigationItem.rightBarButtonItem = makeCancelButton(fore: locationPicker)
        locationPicker.didPick = {
            self.locationInput.next($0)
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
            self.startDateInput.next($0)
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
