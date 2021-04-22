//
//  PhoneLoginController.swift
//  Magix
//
//  Created by Alok N on 17/04/21.
//

import UIKit
import Firebase

class PhoneLoginController: UIViewController {

    //MARK: OUTLETS
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var phoneAuthButton: UIButton!
    @IBOutlet weak var verifyButtonOutlet: UIButton!
    
    var resendFlag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButtonOutlet.isHidden = true
        resendFlag = false
    }
    
    override func updateViewConstraints() {
            self.view.frame.size.height = UIScreen.main.bounds.height*0.45
            self.view.frame.origin.y =  UIScreen.main.bounds.height - UIScreen.main.bounds.height*0.45
            self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            super.updateViewConstraints()
    }

    @IBAction func authPhone(_ sender: Any) {
        if let phoneNumber = phoneField.text {
            if phoneNumber != "" && phoneNumber.count == 10 && resendFlag == false{
                PhoneAuthProvider.provider().verifyPhoneNumber("+91\(phoneNumber)", uiDelegate: nil) { (verificationID, error) in
                    if let error = error{
                        print(error)
                        self.alertPrompt(message: error.localizedDescription, title: "Oops!", prompt: "OK")
                        return
                    }
                    self.phoneField.text = ""
                    UIView.transition(with: self.phoneField, duration: 0.5, options: .transitionCrossDissolve, animations: { self.phoneField.placeholder = "Verification Code" })
                    UIView.transition(with: self.verifyButtonOutlet, duration: 0.5, options: .transitionCrossDissolve, animations: { self.verifyButtonOutlet.isHidden = false })
                    UIView.transition(with: self.phoneAuthButton, duration: 0.5, options: .transitionCrossDissolve, animations: { self.phoneAuthButton.setTitle("Resend", for: .normal) })
                    UserDefaults.standard.set(verificationID,forKey: "authVerificationID")
                    UserDefaults.standard.set(phoneNumber, forKey: "phoneNumberTemp")
                    self.resendFlag = true
                }
            }
            else if resendFlag == true {
                if let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumberTemp"){
                    PhoneAuthProvider.provider().verifyPhoneNumber("+91\(phoneNumber)", uiDelegate: nil) { (verificationID, error) in
                        if let error = error{
                            print(error)
                            self.alertPrompt(message: error.localizedDescription, title: "Oops!", prompt: "OK")
                            return
                        }
                        UserDefaults.standard.set(verificationID,forKey: "authVerificationID")
                    }
                }
            }
            else {self.alertPrompt(message: "Invalid Format", title: "Oops!", prompt: "OK")}
        }
    }
    @IBAction func verifyButton(_ sender: Any) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {return}
        guard let verCode = phoneField.text else { return }
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
    
    override func viewWillAppear(_ animated: Bool) {
            updateViewConstraints()
        }
    
    func alertPrompt(message: String, title: String, prompt: String) -> () {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: prompt, style: UIAlertAction.Style.default))
        self.present(alert, animated: true)
    }
    
}
