//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Robert DeLaurentis on 5/24/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit

class MemesTableViewController: UITableViewController {

    // data model
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    //  MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Tableview datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "idTableCell", for: indexPath)
        let meme = memes[indexPath.row]
        cell.textLabel?.text = meme.topText + " " + meme.bottomText
        cell.imageView?.image = meme.memedImage

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "idTableToDetail" {
        if let destination = segue.destination as? DetailViewController {
          let cell  = sender as! UITableViewCell
          let image = cell.imageView?.image
          destination.image = image
        }
      }
    }

} // end of class


