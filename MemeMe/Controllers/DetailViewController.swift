//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Robert DeLaurentis on 5/25/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // properties and outlets
    var image: UIImage!

    @IBOutlet weak var imageView: UIImageView!

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
    }

}
