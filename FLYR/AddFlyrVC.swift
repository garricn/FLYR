//
//  AddFlyrVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import MapKit
import Bond
import GGNLocationPicker

protocol AddFlyrDelegate: class {
    func controllerDidFinish()
    func controllerFailed(with error: ErrorType)
}

class AddFlyrVC: UIViewController {
    weak var addFlyrDelegate: AddFlyrDelegate?

    private let viewModel: AddFlyrVMProtocol
    private let tableView = UITableView(frame: CGRect.zero, style: .Grouped)
    private var shouldEnableDoneButton: Bool {
        return pickedImage != nil && pickedAnnotation != nil
    }
    private var pickedImage: UIImage? {
        didSet {
            navigationItem.rightBarButtonItem?.enabled = shouldEnableDoneButton
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    private var pickedAnnotation: MKAnnotation? {
        didSet {
            navigationItem.rightBarButtonItem?.enabled = shouldEnableDoneButton
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    init(viewModel: AddFlyrVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = resolvedAddFlyrVM()
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
        navigationItem.rightBarButtonItem = {
            let item = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: #selector(doneButtonTapped)
            )
            item.enabled = false
            return item
        }()

        navigationItem.leftBarButtonItem = {
            let item = UIBarButtonItem(
                barButtonSystemItem: .Cancel,
                target: self,
                action: #selector(cancelButtonTapped)
            )
            return item
        }()

        navigationItem.title = "Add Flyr"
    }

    func setupObservers() {
        viewModel
            .responseOutput
            .deliverOn(Queue.Main)
            .observe { response in
                appCoordinator.didFinishAddingFlyr()
        }.disposeIn(bnd_bag)

        viewModel
            .alertOutput
            .deliverOn(Queue.Main)
            .observe { [weak self] alert in
                self?.presentViewController(alert, animated: true) {
                    self?.navigationItem.rightBarButtonItem?.enabled = true
                    self?.navigationItem.leftBarButtonItem?.enabled = true

                }
        }.disposeIn(bnd_bag)
    }

    func cancelButtonTapped() {
        appCoordinator.cancelButtonTapped()
    }

    func doneButtonTapped() {
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.leftBarButtonItem?.enabled = false

        let flyr = Flyr(
            image: pickedImage!,
            location: toLocation(from: pickedAnnotation!)
        )
        viewModel.flyrInput.next(flyr)
    }
}

extension AddFlyrVC: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let text: String

        switch indexPath.section {
        case 0:
            if let image = pickedImage {
                let cell = AddImageCell()
                cell.flyrImageView.image = image
                cell.accessoryType = .None
                cell.textLabel?.text = ""
                return cell
            } else {
                text = "Add Image"
            }
        case 1:
            if let annotation = pickedAnnotation {
                let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = annotation.title!
                cell.detailTextLabel?.text = annotation.subtitle!
                return cell
            } else {
                text = "Add Location"
            }
        default:
            text = ""
        }

        cell.textLabel?.text = text
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let image = pickedImage where indexPath.section == 0 {
            return rowHeight(from: image)
        } else {
            return UITableViewAutomaticDimension
        }
    }
}

extension AddFlyrVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        switch indexPath.section {
        case 0: presentImagePicker()
        case 1: presentLocationPicker()
        default: break
        }
    }

}

extension AddFlyrVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            let picker = UIImagePickerController()
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
            return
        }

        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        let camera = UIAlertAction(title: "Camera", style: .Default) { [unowned self] alertAction in
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }

        let photoLibrary = UIAlertAction(title: "Photo Library", style: .Default) { [unowned self] alertAction in
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(cancel)
        alert.addAction(camera)
        alert.addAction(photoLibrary)
        presentViewController(alert, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        pickedImage = image
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddFlyrVC {
    func presentLocationPicker() {
        let locationPicker = LocationPickerVC()
        locationPicker.didPickLocation = { annotation in
            self.pickedAnnotation = annotation
            self.navigationController?.popViewControllerAnimated(true)
        }
        navigationController?.pushViewController(locationPicker, animated: true)
    }
}

func toLocation(from annotation: MKAnnotation) -> CLLocation {
    let coordinate = annotation.coordinate
    return CLLocation(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
    )
}
