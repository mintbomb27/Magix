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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //helloLabel.font = UIFont(name: "BebasNeue", size: 50)
        //logoLabel.font = UIFont(name: "BebasNeue", size: 30)
        Auth.auth().addStateDidChangeListener{ [self] (auth,user) in
            if(user != nil){
                if let phone = user?.phoneNumber{
                    print(phone)
                    phoneLabel.text = phone
                }
                if let name = user?.displayName{
                    //let firstName = name.components(separatedBy: " ")[0]
                    helloLabel.text = name
                }
                if let email = user?.email{
                    emailLabel.text = email
                }
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
