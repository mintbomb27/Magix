//
//  ProfileViewController.swift
//  Magix
//
//  Created by Alok N on 17/04/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Populate Fields if User Exists
        Auth.auth().addStateDidChangeListener{ [self] (auth,user) in
            if(user != nil){
                //Fetch User Image if exists and make it Round
                if let url = user?.photoURL, let image = try? Data(contentsOf: url), let imageV = UIImage(data:image){
                    profileImage.image = imageV
                    profileImage.layer.masksToBounds = false
                    profileImage.layer.cornerRadius = imageV.size.width/2
                    profileImage.clipsToBounds = true
                }
                if let phone = user?.phoneNumber{
                    print(phone)
                    phoneLabel.text = phone
                } else { phoneLabel.text = "" }
                if let name = user?.displayName{
                    helloLabel.text = name
                    if(helloLabel.bounds.size.width<helloLabel.frame.width){ //If Name Clipping, choose First Name
                        helloLabel.text = name.components(separatedBy: " ")[0] // First Name
                    }
                }
                if let email = user?.email{
                    emailLabel.text = email
                } else { emailLabel.text = "" }
            }
        }
    }
    //Sign Out and Pop VC
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Error Signing Out!")
        }
    }
    
}
