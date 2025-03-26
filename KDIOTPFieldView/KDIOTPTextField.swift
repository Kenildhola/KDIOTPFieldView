//
//  KDIOTPTextField.swift
//  KDIOTPFieldView
//
//  Created by iMac on 26/03/25.
//

import UIKit

@objc class KDIOTPTextField: UITextField {
    /// Border color for the OTP field
    public var otpBorderColor: UIColor = UIColor.black
    
    /// Border width for the OTP field
    public var otpBorderWidth: CGFloat = 2

    /// Text color for the OTP field
    public var otpTextColor: UIColor = UIColor.black {
        didSet {
            textColor = otpTextColor
        }
    }
    
    public var shapeLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    /// Sets up default properties for the text field
    private func setupTextField() {
        textColor = otpTextColor
        autocorrectionType = .no
        textAlignment = .center
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        }
    }

    /// Initializes the UI for different OTP field styles
    public func initializeUI(forFieldType type: OTPFieldStyle) {
        switch type {
        case .roundShape:
            layer.cornerRadius = bounds.size.width / 2
        case .roundedCorner:
            layer.cornerRadius = 4
        case .rectangle:
            layer.cornerRadius = 0
        case .diamond:
            addDiamondMask()
        case .underlined:
            addBottomView()
        }

        // Apply border color and width for applicable styles
        if type != .diamond && type != .underlined {
            layer.borderColor = otpBorderColor.cgColor
            layer.borderWidth = otpBorderWidth
        }
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        _ = delegate?.textField?(self, shouldChangeCharactersIn: NSMakeRange(0, 0), replacementString: "")
    }
    
    /// Creates a diamond-shaped view
    fileprivate func addDiamondMask() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.size.width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height / 2.0))
        path.addLine(to: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.size.height / 2.0))
        path.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = otpBorderWidth
        shapeLayer.fillColor = backgroundColor?.cgColor
        shapeLayer.strokeColor = otpBorderColor.cgColor
        
        layer.addSublayer(shapeLayer)
    }
    
    /// Creates an underlined text field style
    fileprivate func addBottomView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.size.height))
        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        path.close()
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = otpBorderWidth
        shapeLayer.fillColor = backgroundColor?.cgColor
        shapeLayer.strokeColor = otpBorderColor.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}
