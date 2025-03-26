
//
//  KDIOTPFieldView.swift
//  KDIOTPFieldView
//
//  Created by Kenil Dhola on 26/03/25.
//

import UIKit

@objc public protocol NDOTPFieldViewDelegate: AnyObject {
    
    func canBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool
    func didEnterOTP(otp: String)
    func otpInputCompleted(hasEnteredAll: Bool) -> Bool
}

@objc public enum OTPFieldStyle: Int {
    case roundShape
    case roundedCorner
    case rectangle
    case diamond
    case underlined
}

/// Different input type for OTP fields.
@objc public enum KeyboardType: Int {
    case numeric
    case alphabet
    case alphaNumeric
}

@objc public class KDIOTPFieldView: UIView {
    
    /// Different display type for text fields.
    
    public var otpFieldStyle: OTPFieldStyle = .roundShape
    public var numberOfFields: Int = 4
    public var inputType: KeyboardType = .numeric
    public var fontStyle: UIFont = UIFont.systemFont(ofSize: 20)
    public var isSecureEntryEnabled: Bool = false
    public var shouldHideEnteredText: Bool = false
    public var isCursorRequired: Bool = true
    public var cursorTintColor: UIColor = UIColor.blue
    public var otpFieldSize: CGFloat = 60
    public var spacingBetweenFields: CGFloat = 16
    public var borderThickness: CGFloat = 1
    public var allowIntermediateEditing: Bool = true
    public var backgroundColorDefault: UIColor = UIColor.clear
    public var backgroundColorFilled: UIColor = UIColor.clear
    public var borderColorDefault: UIColor = UIColor.gray
    public var borderColorFilled: UIColor = UIColor.clear
    public var borderColorError: UIColor?
    public var otpTextColor: UIColor = .black
    
    public weak var delegate: NDOTPFieldViewDelegate?
    
    fileprivate var secureEntryData = [String]()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func initializeUI() {
        layer.masksToBounds = true
        layoutIfNeeded()
        
        initializeOTPFields()
        
        layoutIfNeeded()
        
        // Forcefully try to make first otp field as first responder
        (viewWithTag(1) as? KDIOTPTextField)?.becomeFirstResponder()
    }
    
    fileprivate func initializeOTPFields() {
        secureEntryData.removeAll()
        
        for index in stride(from: 0, to: numberOfFields, by: 1) {
            let oldOtpField = viewWithTag(index + 1) as? KDIOTPTextField
            oldOtpField?.removeFromSuperview()
            
            let otpField = getOTPField(forIndex: index)
            addSubview(otpField)
            
            secureEntryData.append("")
        }
    }
    
    fileprivate func getOTPField(forIndex index: Int) -> KDIOTPTextField {
        let hasOddNumberOfFields = (numberOfFields % 2 == 1)
        var fieldFrame = CGRect(x: 0, y: 0, width: otpFieldSize, height: otpFieldSize)
        
        if hasOddNumberOfFields {
            // Calculate from middle each fields x and y values so as to align the entire view in center
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(numberOfFields / 2 - index) * (otpFieldSize + spacingBetweenFields) + otpFieldSize / 2)
        }
        else {
            // Calculate from middle each fields x and y values so as to align the entire view in center
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(numberOfFields / 2 - index) * otpFieldSize + CGFloat(numberOfFields / 2 - index - 1) * spacingBetweenFields + spacingBetweenFields / 2)
        }
        
        fieldFrame.origin.y = (bounds.size.height - otpFieldSize) / 2
        
        let otpField = KDIOTPTextField(frame: fieldFrame)
        otpField.delegate = self
        otpField.tag = index + 1
        otpField.font = fontStyle
        
        // Set input type for OTP fields
        switch inputType {
        case .numeric:
            otpField.keyboardType = .numberPad
        case .alphabet:
            otpField.keyboardType = .alphabet
        case .alphaNumeric:
            otpField.keyboardType = .namePhonePad
        }
        
        // Set the border values if needed
        otpField.otpBorderColor = borderColorDefault
        otpField.otpBorderWidth = borderThickness
        
        if isCursorRequired {
            otpField.tintColor = cursorTintColor
        }
        else {
            otpField.tintColor = UIColor.clear
        }
        
        // Set the default background color when text not set
        otpField.backgroundColor = backgroundColorDefault
        otpField.otpTextColor = otpTextColor
        // Finally create the fields
        otpField.initializeUI(forFieldType: otpFieldStyle)
        
        return otpField
    }
    
    fileprivate func isPreviousFieldsEntered(forTextField textField: UITextField) -> Bool {
        var isTextFilled = true
        var nextOTPField: UITextField?
        
        // If intermediate editing is not allowed, then check for last filled field in forward direction.
        if !allowIntermediateEditing {
            for index in stride(from: 1, to: numberOfFields + 1, by: 1) {
                let tempNextOTPField = viewWithTag(index) as? UITextField
                
                if let tempNextOTPFieldText = tempNextOTPField?.text, tempNextOTPFieldText.isEmpty {
                    nextOTPField = tempNextOTPField
                    
                    break
                }
            }
            
            if let nextOTPField = nextOTPField {
                isTextFilled = (nextOTPField == textField || (textField.tag) == (nextOTPField.tag - 1))
            }
        }
        
        return isTextFilled
    }
    
    // Helper function to get the OTP String entered
    fileprivate func calculateEnteredOTPSTring(isDeleted: Bool) {
        if isDeleted {
            _ = delegate?.otpInputCompleted(hasEnteredAll: false)
            
            // Set the default enteres state for otp entry
            for index in stride(from: 0, to: numberOfFields, by: 1) {
                var otpField = viewWithTag(index + 1) as? KDIOTPTextField
                
                if otpField == nil {
                    otpField = getOTPField(forIndex: index)
                }
                
                let fieldBackgroundColor = (otpField?.text ?? "").isEmpty ? backgroundColorDefault : backgroundColorFilled
                let fieldBorderColor = (otpField?.text ?? "").isEmpty ? borderColorDefault : borderColorFilled
                
                if otpFieldStyle == .diamond || otpFieldStyle == .underlined {
                    otpField?.shapeLayer.fillColor = fieldBackgroundColor.cgColor
                    otpField?.shapeLayer.strokeColor = fieldBorderColor.cgColor
                } else {
                    otpField?.backgroundColor = fieldBackgroundColor
                    otpField?.layer.borderColor = fieldBorderColor.cgColor
                }
            }
        }
        else {
            var enteredOTPString = ""
            
            // Check for entered OTP
            for index in stride(from: 0, to: secureEntryData.count, by: 1) {
                if !secureEntryData[index].isEmpty {
                    enteredOTPString.append(secureEntryData[index])
                }
            }
            
            if enteredOTPString.count == numberOfFields {
                delegate?.didEnterOTP(otp: enteredOTPString)
                
                // Check if all OTP fields have been filled or not. Based on that call the 2 delegate methods.
                let isValid = delegate?.otpInputCompleted(hasEnteredAll: (enteredOTPString.count == numberOfFields)) ?? false
                
                // Set the error state for invalid otp entry
                for index in stride(from: 0, to: numberOfFields, by: 1) {
                    var otpField = viewWithTag(index + 1) as? KDIOTPTextField
                    
                    if otpField == nil {
                        otpField = getOTPField(forIndex: index)
                    }
                    
                    if !isValid {
                        // Set error border color if set, if not, set default border color
                        otpField?.layer.borderColor = (borderColorError ?? borderColorFilled).cgColor
                    }
                    else {
                        otpField?.layer.borderColor = borderColorFilled.cgColor
                    }
                }
            }
        }
    }
    
}

extension KDIOTPFieldView: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = delegate?.canBecomeFirstResponderForOTP(otpTextFieldIndex: (textField.tag - 1)) ?? true
        if shouldBeginEditing {
            return isPreviousFieldsEntered(forTextField: textField)
        }
        
        return shouldBeginEditing
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // Check since only alphabet keyboard is not available in iOS
        if !replacedText.isEmpty && inputType == .alphabet && replacedText.rangeOfCharacter(from: .letters) == nil {
            return false
        }
        
        if replacedText.count >= 1 {
            // If field has a text already, then replace the text and move to next field if present
            secureEntryData[textField.tag - 1] = string
            
            if shouldHideEnteredText {
                textField.text = " "
            }
            else {
                if isSecureEntryEnabled {
                    textField.text = "•"
                }
                else {
                    textField.text = string
                }
            }
            
            if otpFieldStyle == .diamond || otpFieldStyle == .underlined {
                (textField as! KDIOTPTextField).shapeLayer.fillColor = backgroundColorFilled.cgColor
                (textField as! KDIOTPTextField).shapeLayer.strokeColor = borderColorFilled.cgColor
            }
            else {
                textField.backgroundColor = backgroundColorFilled
                textField.layer.borderColor = borderColorFilled.cgColor
            }
            
            let nextOTPField = viewWithTag(textField.tag + 1)
            
            if let nextOTPField = nextOTPField {
                nextOTPField.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
            
            // Get the entered string
            calculateEnteredOTPSTring(isDeleted: false)
        }
        else {
            let currentText = textField.text ?? ""
            
            if textField.tag > 1 && currentText.isEmpty {
                if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                    deleteText(in: prevOTPField)
                }
            } else {
                deleteText(in: textField)
                
                if textField.tag > 1 {
                    if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                        prevOTPField.becomeFirstResponder()
                    }
                }
            }
        }
        
        return false
    }
    
    private func deleteText(in textField: UITextField) {
        // If deleting the text, then move to previous text field if present
        secureEntryData[textField.tag - 1] = ""
        textField.text = ""
        
        if otpFieldStyle == .diamond || otpFieldStyle == .underlined {
            (textField as! KDIOTPTextField).shapeLayer.fillColor = backgroundColorDefault.cgColor
            (textField as! KDIOTPTextField).shapeLayer.strokeColor = borderColorDefault.cgColor
        } else {
            textField.backgroundColor = backgroundColorDefault
            textField.layer.borderColor = borderColorDefault.cgColor
        }
        
        textField.becomeFirstResponder()
        
        // Get the entered string
        calculateEnteredOTPSTring(isDeleted: true)
    }
}
