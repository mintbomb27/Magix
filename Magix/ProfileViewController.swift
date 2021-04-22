//
//  ProfileViewController.swift
//  Magix
//
//  Created by Alok N on 17/04/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    //MARK: DATA
    var dataMe: String = ""
    
    //MARK: OUTLETS
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener{ [self] (auth,user) in
            if(user != nil){
                if let url = user?.photoURL, let image = try? Data(contentsOf: url), let imageV = UIImage(data:image){
                    profileImage.image = imageV
                    profileImage.layer.borderWidth = 0
                    profileImage.layer.masksToBounds = false
                    profileImage.layer.borderColor = UIColor.white.cgColor
                    profileImage.layer.cornerRadius = imageV.size.width/2
                    profileImage.clipsToBounds = true
                }
                if let phone = user?.phoneNumber{
                    print(phone)
                    phoneLabel.text = phone
                } else { phoneLabel.text = "" }
                if let name = user?.displayName{
                    helloLabel.text = name
                    if(helloLabel.bounds.size.width<helloLabel.frame.width){
                        helloLabel.text = name.components(separatedBy: " ")[0]
                    }
                }
                if let email = user?.email{
                    emailLabel.text = email
                } else { emailLabel.text = "" }
            }
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Error Signing Out!")
        }
    }
    
}
