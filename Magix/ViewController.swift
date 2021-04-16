//
//  ViewController.swift
//  Magix
//
//  Created by Alok N on 15/04/21.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices

class ViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var loginTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTitle.font = UIFont(name:"BebasNeue",size:50)
        loginTitle.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
    }
    
    @IBAction func authGoogle(_ sender: Any) {
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.signIn()
    }
    
    
    @IBAction func authApple(_ sender: Any) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName,.email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    
}

extension ViewController: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Auth Failed")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            print(credentials.email!)
            break
        default:
            break
        }
    }
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
