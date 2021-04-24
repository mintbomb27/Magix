//
//  PhoneLoginController.swift
//  Magix
//
//  Created by Alok N on 17/04/21.
//

import UIKit
import Firebase
import PhoneNumberKit
import OTPFieldView
class PhoneLoginController: UIViewController {

    //MARK: OUTLETS
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var phoneAuthButton: UIButton!
    @IBOutlet weak var verifyButtonOutlet: UIButton!
    @IBOutlet weak var phoneNumberField: customPhoneTextField!
    @IBOutlet weak var otpField: OTPFieldView!
    
    var resendFlag: Bool = false // Resend OTP Flag
    var otpString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButtonOutlet.isHidden = true
        resendFlag = false
        if #available(iOS 11.0, *) {
            PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["IN","US", "CA","NP","AE"]
            self.phoneNumberField.withDefaultPickerUI = true
        }
        self.phoneNumberField.withExamplePlaceholder = true
        self.phoneNumberField.withPrefix = true
        self.phoneNumberField.withFlag = true
        self.phoneNumberField.becomeFirstResponder()
        self.otpField.isHidden = true
    }
    
    //Reduce height of Modal
    override func updateViewConstraints() {
            self.view.frame.size.height = UIScreen.main.bounds.height*0.45
            self.view.frame.origin.y =  UIScreen.main.bounds.height - UIScreen.main.bounds.height*0.45
            self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            super.updateViewConstraints()
    }

    //MARK: PHONE AUTHENTICATION
    @IBAction func authPhone(_ sender: Any) {
        if let phoneNumber = phoneNumberField.phoneNumber {
            if String(phoneNumber.nationalNumber).count == 10 && resendFlag == false{ // Form Validation
                PhoneAuthProvider.provider().verifyPhoneNumber("+\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)", uiDelegate: nil) { (verificationID, error) in
                    if let error = error{
                        print(error)
                        self.alertPrompt(message: error.localizedDescription, title: "Oops!", prompt: "OK")
                        return
                    }
                    self.phoneField.text = "" // Reset Text for OTP
                    
                    //Transition from Phone Number to Verification Code
                    UIView.transition(with: self.otpField, duration: 0.5, options: .transitionCrossDissolve, animations: { self.otpField.isHidden = false })
                    UIView.transition(with: self.phoneField, duration: 0.5, options: .transitionFlipFromLeft, animations: { self.phoneField.isHidden = true })
                    UIView.transition(with: self.verifyButtonOutlet, duration: 0.5, options: .transitionCrossDissolve, animations: { self.verifyButtonOutlet.isHidden = false })
                    UIView.transition(with: self.phoneAuthButton, duration: 0.5, options: .transitionCrossDissolve, animations: { self.phoneAuthButton.setTitle("Resend", for: .normal) })
                    UserDefaults.standard.set(verificationID,forKey: "authVerificationID")
                    UserDefaults.standard.set("+\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)", forKey: "phoneNumberTemp") // Storing Phone Number for Resend OTP
                    self.resendFlag = true
                    self.setupOtpView()
                }
            }
            else if resendFlag == true { // Resend OTP
                if let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumberTemp"){
                    PhoneAuthProvider.provider().verifyPhoneNumber("+91\(phoneNumber)", uiDelegate: nil) { (verificationID, error) in
                        if let error = error{
                            self.alertPrompt(message: error.localizedDescription, title: "Oops!", prompt: "OK")
                            return
                        }
                        UserDefaults.standard.set(verificationID,forKey: "authVerificationID")
                    }
                }
            }
            else {alertPrompt(message: "Invalid Format", title: "Oops!", prompt: "OK")}
        }
    }
    //Verify Code and Sign In
    @IBAction func verifyButton(_ sender: Any?, otp: String) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {return}
        let verCode = otp
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verCode)
        Auth.auth().signIn(with: credentials, completion: { (authResult, error) in
            if let error = error{
                print(error.localizedDescription)
                self.alertPrompt(message: error.localizedDescription, title: "Oops!", prompt: "OK")
                return
            }
            print("Signed In with Phone!")
            self.dismiss(animated: true)
        })
    }
    
    //Fix Modal Height on Re-Entering View
    override func viewWillAppear(_ animated: Bool) {
        updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if resendFlag==true{
            self.otpField.becomeFirstResponder()
        }
    }
    
    func setupOtpView(){
            self.otpField.fieldsCount = 6
            self.otpField.fieldBorderWidth = 2
            self.otpField.defaultBorderColor = UIColor.white
            self.otpField.filledBorderColor = UIColor.red
            self.otpField.cursorColor = UIColor.red
            self.otpField.displayType = .underlinedBottom
            self.otpField.fieldSize = 30
            self.otpField.separatorSpace = 6
            self.otpField.fieldTextColor = .white
            self.otpField.shouldAllowIntermediateEditing = false
            self.otpField.delegate = self
            self.otpField.initializeUI()
        }
}

extension PhoneLoginController: OTPFieldViewDelegate{
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp: String) {
        otpString = otp
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        if(hasEnteredAll == true){
            verifyButton(nil, otp: otpString)
        }
        return false
    }
    
    
}
