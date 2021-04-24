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
import PhoneNumberKit

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
        
        //UI Changes Apply
        loginTitle.font = UIFont(name:"BebasNeue",size:80)
        loginTitle.layer.shadowColor = UIColor.black.cgColor
        loginTitle.layer.shadowRadius = 10
        loginTitle.layer.shadowOpacity = 2
        googleButton.layer.cornerRadius = 20
        appleButton.layer.cornerRadius = 20
        phoneButton.layer.cornerRadius = 20
        emailButton.layer.cornerRadius = 20
        
        //Movie Image Background Gradient
        let imageView = UIImageView.init(image: UIImage(named: "movies.jpg"))
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width+100, height: 300)
        self.view.insertSubview(imageView, at: 0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0);
        imageView.layer.mask = gradientLayer;
        
        //Detect AuthChange and Move to ProfileVC
        Auth.auth().addStateDidChangeListener({(auth, user) in
            if(user != nil){
                UserDefaults.standard.set(true, forKey: "isSignedIn")
                let profileVC = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        })
        
    }
    //MARK: GOOGLE AUTHENTICATION
    @IBAction func authGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    //MARK: APPLE AUTHENTICATION
    @IBAction func authApple(_ sender: Any) {
        let request = requestAppleID()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.presentationContextProvider = self
        controller.delegate = self
        controller.performRequests()
    }
    
    //Request AppleID
    func requestAppleID()-> ASAuthorizationAppleIDRequest{
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName,.email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
    //Nonce String for AppleID Request
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
    
    //SHA256 Function for Nonce
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
}

//Connecting Apple to Firebase
extension ViewController: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError("Invalid State: Login callback received, but no request sent")
        }
        guard let appleIDToken = appleIDCredentials.identityToken else {
            print("Unable to fetch the ID Token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to Parse the ID Token")
            return
        }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: currentNonce)
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in
            if let error = error{
                self.alertPrompt(message: error.localizedDescription, title: "Oops!", prompt: "OK")
                return
            }
        })
    }
}
extension ViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//AlertPrompt Extension to be used everywhere
extension UIViewController {
    func alertPrompt(message: String, title: String, prompt: String) -> () {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: prompt, style: UIAlertAction.Style.default))
        self.present(alert, animated: true)
    }
}
