/**
 *  BulletinBoard
 *  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BLTNBoard

/**
 * An item that displays a text field.
 *
 * This item demonstrates how to create a bulletin item with a text field and how it will behave
 * when the keyboard is visible.
 */

class TextFieldBulletinPage: FeedbackPageBLTNItem {

    @objc public var textField: UITextField!

    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)? = nil

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        textField = interfaceBuilder.makeTextField(placeholder: "Spotify URL", returnKey: .done, delegate: self)
        return [textField]
    }

    override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }

    override func actionButtonTapped(sender: UIButton) {
        textField.resignFirstResponder()
        super.actionButtonTapped(sender: sender)
    }

}

// MARK: - UITextFieldDelegate

extension TextFieldBulletinPage: UITextFieldDelegate {

    @objc open func isInputValid(text: String?) -> Bool {

        if text == nil || text!.isEmpty {
            return false
        }

        return true

    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        if isInputValid(text: textField.text) {
            textInputHandler?(self, textField.text)
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "You must enter some text to continue."
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }

    }

}

class FeedbackPageBLTNItem: BLTNPageItem {

    private let feedbackGenerator = SelectionFeedbackGenerator()

    override func actionButtonTapped(sender: UIButton) {

        // Play an haptic feedback

        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()

        // Call super

        super.actionButtonTapped(sender: sender)

    }

    override func alternativeButtonTapped(sender: UIButton) {

        // Play an haptic feedback

        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()

        // Call super

        super.alternativeButtonTapped(sender: sender)

    }

}

class SelectionFeedbackGenerator {

    private let anyObject: AnyObject?

    init() {

        if #available(iOS 10, *) {
            anyObject = UISelectionFeedbackGenerator()
        } else {
            anyObject = nil
        }

    }

    func prepare() {

        if #available(iOS 10, *) {
            (anyObject as! UISelectionFeedbackGenerator).prepare()
        }

    }

    func selectionChanged() {

        if #available(iOS 10, *) {
            (anyObject as! UISelectionFeedbackGenerator).selectionChanged()
        }

    }

}

/**
 * A 3D Touch success feedback generator wrapper that uses the API only when available.
 */

class SuccessFeedbackGenerator {

    private let anyObject: AnyObject?

    init() {

        if #available(iOS 10, *) {
            anyObject = UINotificationFeedbackGenerator()
        } else {
            anyObject = nil
        }

    }

    func prepare() {

        if #available(iOS 10, *) {
            (anyObject as! UINotificationFeedbackGenerator).prepare()
        }

    }

    func success() {

        if #available(iOS 10, *) {
            (anyObject as! UINotificationFeedbackGenerator).notificationOccurred(.success)
        }

    }

}
