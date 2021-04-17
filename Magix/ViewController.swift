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
import CryptoKit

class ViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var currentNonce: String = ""
    
    //MARK: OUTLETS
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTitle.font = UIFont(name:"BebasNeue",size:70)
        loginTitle.textAlignment = NSTextAlignment.center
        googleButton.titleLabel?.font = UIFont(name:"BebasNeue",size:20)
        appleButton.titleLabel?.font = UIFont(name:"BebasNeue",size:20)
        phoneButton.titleLabel?.font = UIFont(name:"BebasNeue",size:20)
        emailButton.titleLabel?.font = UIFont(name:"BebasNeue",size:20)
        loginTitle.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
    }
    
    @IBAction func authGoogle(_ sender: Any) {
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.signIn()
    }
    
    func requestAppleID()-> ASAuthorizationAppleIDRequest{
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName,.email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
    @IBAction func authApple(_ sender: Any) {
        let request = requestAppleID()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.presentationContextProvider = self
        controller.delegate = self
        controller.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
}

extension ViewController: ASAuthorizationControllerDelegate{
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
