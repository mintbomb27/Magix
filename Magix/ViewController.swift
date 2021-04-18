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
        
        Auth.auth().addStateDidChangeListener{ (auth,user) in
            if(user != nil){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        
        loginTitle.font = UIFont(name:"BebasNeue",size:80)
        loginTitle.textAlignment = NSTextAlignment.center
        googleButton.layer.cornerRadius = 20
        appleButton.layer.cornerRadius = 20
        phoneButton.layer.cornerRadius = 20
        emailButton.layer.cornerRadius = 20
        loginTitle.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        
        // Whatever you image view is, obviously not hardcoded like this
        let imageView = UIImageView.init(image: UIImage(named: "movies.jpg"))
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width+100, height: 300)
        self.view.insertSubview(imageView, at: 0)
        // Create the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor]
        // Whatever direction you want the fade. You can use gradientLayer.locations
        // to provide an array of points, with matching colors for each point,
        // which lets you do other than just a uniform gradient.
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0);
        // Use the gradient layer as the mask
        imageView.layer.mask = gradientLayer;
        
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
