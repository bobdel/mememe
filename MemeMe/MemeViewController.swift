//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Robert DeLaurentis on 4/17/18.
//  Copyright © 2018 Robert DeLaurentis. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController,
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

  override var prefersStatusBarHidden: Bool {
    return true
  }

  let memeTextAttributes:[String: Any] = [
    NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
    NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
    NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSAttributedStringKey.strokeWidth.rawValue: -3.0
  ]

  var meme: Meme?

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
    resetTextFields()
    imageView.image = nil
    actionButton.isEnabled = false
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
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    unsubscribeFromKeyboardNotifications()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    topTextField.delegate = self
    bottomTextField.delegate = self

    topTextField.defaultTextAttributes = memeTextAttributes
    bottomTextField.defaultTextAttributes = memeTextAttributes

    topTextField.textAlignment = .center
    bottomTextField.textAlignment = .center

    resetTextFields()

  }

  // MARK: UIImagePickerControllerDelegate conformance

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    imageView.image = info["UIImagePickerControllerOriginalImage"]! as? UIImage
    dismiss(animated: true, completion: nil)
  }

  // MARK: UITextFieldDelegate Conformance and keyboard UI

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    topTextField.resignFirstResponder()
    bottomTextField.resignFirstResponder()
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

    topToolBar.isHidden = true
    bottomToolBar.isHidden = true

    // Render view to an image
    UIGraphicsBeginImageContext(self.view.frame.size)
    view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
    let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    topToolBar.isHidden = false
    bottomToolBar.isHidden = false

    return memedImage
  }

  func resetTextFields() {
    topTextField.text =  "TOP"
    bottomTextField.text = "BOTTOM"
  }

  // save an image to the photo library
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
  }

  // save meme to photo library (called only if used in  activity view controller)
  @objc func save() {
    meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    UIImageWriteToSavedPhotosAlbum((meme?.memedImage)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

}

