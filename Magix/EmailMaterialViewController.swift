//
//  EmailMaterialViewController.swift
//  Magix
//
//  Created by Alok N on 20/04/21.
//

import UIKit
import MaterialComponents.MaterialTextControls_FilledTextFields
import Firebase

class EmailMaterialViewController: UIViewController {

    @IBOutlet weak var LoginTitle: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var emailField: MDCFilledTextField? = nil
    var passField: MDCFilledTextField? = nil
    var firstNameField: MDCFilledTextField? = nil
    var phoneNumberField: MDCFilledTextField? = nil
    @IBOutlet weak var newTextField: UIView!
    
    var doneFlag: Bool = false
    var errorColor: UIColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
    var firebaseAuth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField = createTextField(label: "Email Address")
        passField = createTextField(label: "Password")
        guard let eF = emailField else {return}
        guard let pF = passField else {return}
        pF.isSecureTextEntry = true
        stackView.addArrangedSubview(eF)
        stackView.addArrangedSubview(pF)
        
        loginButton.layer.cornerRadius = 20
        registerButton.layer.cornerRadius = 20
        newTextField.roundCorners(corners: [.allCorners], radius: 40.0)
        stackView.addArrangedSubview(newTextField)
    }
    
    func createTextField(label: String, placeholder: String? = nil)->(MDCFilledTextField?){
        let textField: MDCFilledTextField? = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-100, height: 0))
        if let textField = textField {
            textField.setTextColor(UIColor.white, for: .editing)
            textField.setFilledBackgroundColor(UIColor.darkGray, for: .normal)
            textField.setFilledBackgroundColor(UIColor.darkGray, for: .editing)
            textField.tintColor = UIColor.white
            textField.setFloatingLabelColor(UIColor.white, for: .editing)
            textField.setNormalLabelColor(UIColor.white, for: .normal)
            textField.keyboardType = .alphabet
            textField.label.text = label
            if let ph = placeholder{textField.placeholder = ph} else {textField.placeholder = label}
            textField.sizeToFit()
            return textField
        }
        return textField
    }

    @IBAction func loginButton(_ sender: Any) {
        var flag = true
        guard let emailField = emailField else {return}
        guard let passField = passField else {return}
        if(emailField.text!.isEmpty){
            emailField.setFilledBackgroundColor(errorColor, for: .normal)
            flag = false
        } else {setBorders(fieldName: emailField, borderColor: UIColor.darkGray, animate: true)}
        if(passField.text!.isEmpty){
            setBorders(fieldName: passField, borderColor: errorColor, animate: true)
            flag = false
        } else {setBorders(fieldName: passField, borderColor: UIColor.darkGray, animate: true)}
        if(flag){
            firebaseAuth.signIn(withEmail: emailField.text!, password: passField.text!, completion: {(authResult, error) in
                if let error = error as NSError?{
                    print(error)
                    if let code = AuthErrorCode(rawValue: error.code) {
                        switch code.rawValue {
                        case 17009:
                            self.alertPrompt(message: "Invalid username or password", title: "Oops!", prompt: "OK")
                            break
                        case 17011:
                            self.alertPrompt(message: "Invalid username or password", title: "Oops!", prompt: "OK")
                            break
                        default:
                            self.alertPrompt(message: "Unknown Error", title: "Oops!", prompt: "OK")
                        }
                    }
                    else{
                        self.alertPrompt(message: "Unknown Error", title: "Oops!", prompt: "OK")
                    }
                    return
                }
                print("Success Logged In: \(authResult!.user.email!)")
                self.dismiss(animated: true)
            })
        }
    }
    
    @IBAction func registerButton(_ sender: Any) {
        if doneFlag == false{
            firstNameField = createTextField(label: "Full Name")
            phoneNumberField = createTextField(label: "Phone Number",placeholder: "(+91)0000000000")
            guard let fF = firstNameField else {return}
            guard let pF = phoneNumberField else {return}
            pF.alpha = 0.0
            pF.isHidden = true
            fF.alpha = 0.0
            fF.isHidden = true
            self.stackView.addArrangedSubview(fF)
            self.stackView.addArrangedSubview(pF)
            UIView.animate(withDuration: 1.0, animations: {
                pF.alpha = 1.0
                pF.isHidden = false
                fF.isHidden = false
                fF.alpha = 1.0
            })
            doneFlag = true
        }
        
        var flag = true
        guard let eF = emailField else {return}
        guard let pF = passField else {return}
        guard let fF = firstNameField else {return}
        guard let phF = phoneNumberField else {return}
        if(eF.text!.isEmpty){
            setBorders(fieldName: eF, borderColor: errorColor, animate: true)
            flag = false
        } else {
            setBorders(fieldName: eF, borderColor: UIColor.darkGray, animate: true)
        }
        if(pF.text!.isEmpty){
            setBorders(fieldName: pF, borderColor: errorColor, animate: true)
            flag = false
        } else {
            setBorders(fieldName: pF, borderColor: UIColor.darkGray, animate: true)
        }
        if(fF.text!.isEmpty){
            setBorders(fieldName: fF, borderColor: errorColor, animate: true)
            flag = false
        } else {
            setBorders(fieldName: fF, borderColor: UIColor.darkGray, animate: true)
        }
        if(phF.text!.isEmpty){
            setBorders(fieldName: phF, borderColor: errorColor, animate: true)
            flag = false
        } else {
            setBorders(fieldName: phF, borderColor: UIColor.darkGray, animate: true)
        }
        if(flag){
            firebaseAuth.createUser(withEmail: eF.text!, password: pF.text!, completion: {authResult,error in print("Done!")})
        }
    }
    
    func alertPrompt(message: String, title: String, prompt: String) -> () {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: prompt, style: UIAlertAction.Style.default))
        self.present(alert, animated: true)
    }
        
    
    
    func setBorders(fieldName:MDCFilledTextField, borderColor:UIColor, animate:Bool) -> () {
        if(animate){
            UIView.transition(with: fieldName, duration: 0.5, options: .transitionCrossDissolve, animations: { fieldName.setFilledBackgroundColor(borderColor, for: .normal)})
        }
    }
    
}
