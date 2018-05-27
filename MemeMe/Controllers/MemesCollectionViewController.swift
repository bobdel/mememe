//
//  MemesCollectionViewController.swift
//  MemeMe
//
//  Created by Robert DeLaurentis on 5/24/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit

class MemesCollectionViewController: UICollectionViewController {

    // data model
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 20) / 3
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize  = CGSize(width: width, height: width)

    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }

     // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "idCollectionToDetail" {
            if let destination = segue.destination as? DetailViewController {
                let cell  = sender as! MemeCollectionViewCell
                let image = cell.memeImageView?.image
                destination.image = image
            }
        }
    }

    // MARK: - UICollectionView datasource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "idMemeCell", for: indexPath) as! MemeCollectionViewCell
        let currentMeme = memes[indexPath.row]
        cell.memeImageView.image = currentMeme.memedImage

        return cell
    }

}
