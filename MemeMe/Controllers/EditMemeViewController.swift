//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Robert DeLaurentis on 4/17/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UITextFieldDelegate {

    // MARK: Outlets and Properties

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!

    // properties
    var isStatusBarHidden: Bool = false

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }


    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]

    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    // MARK: User Target Action Methods

    @IBAction func actionButton(_ sender: UIBarButtonItem) {
        let compositeImage = generateMemedImage()
        let avc = UIActivityViewController(activityItems: [compositeImage], applicationActivities: nil)
        avc.completionWithItemsHandler = {
            (activityType, completed, items, error) in

            guard completed else { return }

            self.save()
        }

        present(avc, animated: true, completion: nil)
    }

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // choose an image from the album or camera (if available)
    @IBAction  func chooseImage(_ sender: UIBarButtonItem) {

        let pickerController = UIImagePickerController()
        pickerController.delegate = self

        if sender == cameraButton && UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerController.sourceType = .camera
        } else {
            pickerController.sourceType = .photoLibrary
        }

        present(pickerController, animated: true, completion: nil)
    }

    // MARK: ViewController Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        actionButton.isEnabled = imageView.image != nil
        isStatusBarHidden = true
        UIView.animate(withDuration: 0.3) { self.setNeedsStatusBarAppearanceUpdate() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(topTextField, with: "TOP")
        configure(bottomTextField, with: "BOTTOM")

        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)) ))

    }

    // MARK: UIImagePickerControllerDelegate conformance

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info["UIImagePickerControllerOriginalImage"]! as? UIImage
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITextFieldDelegate Conformance and keyboard UI

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // keyboard show/hide behavior
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    // MARK: Utility Methods

    func generateMemedImage() -> UIImage {

        hideUserControls(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        hideUserControls(false)

        return memedImage
    }

    func hideUserControls(_ isHidden: Bool) {
        topToolBar.isHidden = isHidden
        bottomToolBar.isHidden = isHidden
    }

    func configure(_ textField: UITextField, with defaultText: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text =  defaultText
    }

    // save an image to the photo library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    }

    // save meme to photo library (called only if used in activity view controller)
    @objc func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        UIImageWriteToSavedPhotosAlbum((meme.memedImage), self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

        // add meme to shared data model in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }

}

