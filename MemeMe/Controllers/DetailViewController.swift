//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Robert DeLaurentis on 5/25/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!

  var image: UIImage!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
  }

}
