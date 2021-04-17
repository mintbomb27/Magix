//
//  PhoneLoginController.swift
//  Magix
//
//  Created by Alok N on 17/04/21.
//

import UIKit
import Firebase

class PhoneLoginController: UIViewController {

    //OUTLETS
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var phoneAuthButton: UIButton!
    @IBOutlet weak var verifyButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButtonOutlet.isHidden = true
    }

    @IBAction func authPhone(_ sender: Any) {
        if let phoneNumber = phoneField.text {
            if phoneNumber != "" && phoneNumber.count == 10{
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
        })
    }
    
    func alertPrompt(message: String, title: String, prompt: String) -> () {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: prompt, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
