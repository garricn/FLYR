//
//  FeedVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {
    let feedVM: FeedVM
    let feedView: FeedView

    init(feedVM: FeedVM, feedView: FeedView) {
        self.feedVM = feedVM
        self.feedView = feedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.feedVM = FeedVM(photoFetcher: PhotoFetcher())
        self.feedView = FeedView()
        super.init(coder: aDecoder)
    }

    override func loadView() {
        feedView.backgroundColor = .whiteColor()
        view = feedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        feedVM.imageOutput.bindTo(feedView.imageInput)
    }
}
