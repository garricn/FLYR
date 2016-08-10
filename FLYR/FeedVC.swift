//
//  FeedVC.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/1/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import Bond

class FeedVC: UIViewController {
    let feedVM: FeedVM
    let feedView: FeedView

    init(feedVM: FeedVM, feedView: FeedView) {
        self.feedVM = feedVM
        self.feedView = feedView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.feedView = FeedView()
        self.feedVM = FeedVM(
            recordFetcher: RecordFetcher(
                database: resolvedPublicDatabase()
            )
        )
        super.init(coder: aDecoder)
    }

    override func loadView() {
        feedView.backgroundColor = .whiteColor()
        view = feedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        feedVM.imageOutput
            .deliverOn(Queue.Main)
            .bindTo(feedView.imageInput)
    }
}
