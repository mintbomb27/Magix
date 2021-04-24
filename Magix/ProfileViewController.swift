//
//  ProfileViewController.swift
//  Magix
//
//  Created by Alok N on 17/04/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import PhoneNumberKit

class ProfileViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var dbRef: DatabaseReference = Database.database().reference()
    var phone: String = ""
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Populate Fields if User Exist
        Auth.auth().addStateDidChangeListener{ [self] (auth,user) in
            if(user != nil){
                guard let uid = user?.uid else {return}
                //Fetch User Image if exists and make it Round
                if let url = user?.photoURL, let image = try? Data(contentsOf: url), let imageV = UIImage(data:image){
                    profileImage.image = imageV
                    profileImage.layer.masksToBounds = false
                    profileImage.layer.cornerRadius = imageV.size.width/2
                    profileImage.clipsToBounds = true
                }
                if let phone = user?.phoneNumber{
                    let phoneKit = PhoneNumberKit()
                    var phoneNumber = ""
                    do { phoneNumber = try phoneKit.format(phoneKit.parse(phone), toType: .international) } catch { print("Error Parsing PhoneNumber") }
                    print(phoneNumber)
                    phoneLabel.text = phoneNumber
                } else {
                    self.dbRef.child("users/\(uid)/phone").observeSingleEvent(of: .value, with: {
                        (snapShot) in
                        if snapShot.exists(){
                            phone = "\(snapShot.value!)"
                            phoneLabel.text = phone
                        } else {
                            //print("No Data Available")
                        }
                    }) { (error) in
                        print(error)
                    }
                }
                if let name = user?.displayName{
                    helloLabel.text = name
                    if(helloLabel.bounds.size.width<helloLabel.frame.width){ //If Name Clipping, choose First Name
                        helloLabel.text = name.components(separatedBy: " ")[0] // First Name
                    }
                } else {
                    self.dbRef.child("users/\(uid)/name").observeSingleEvent(of: .value, with: {
                        (snapShot) in
                        if snapShot.exists(){
                            name = "\(snapShot.value!)"
                            helloLabel.text = name
                            if(helloLabel.bounds.size.width<helloLabel.frame.width){ //If Name Clipping, choose First Name
                                helloLabel.text = name.components(separatedBy: " ")[0] // First Name
                            }
                        } else {
                            //print("No Data Available")
                        }
                    }) { (error) in
                        print(error)
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
            UserDefaults.standard.set(false, forKey: "isSignedIn")
            self.navigationController?.popViewController(animated: true)
        } catch {
            print("Error Signing Out!")
        }
    }
    
}
