//
//  AppDelegate.swift
//  Magix
//
//  Created by Alok N on 15/04/21.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        //Fetching ClientID from GoogleServices-Info.plist
        var clientID: [String:Any]?
        if let gservicesPlistPath = Bundle.main.url(forResource: "GoogleService-Info", withExtension:"plist"){
            do{
                let gservicesPlist = try Data(contentsOf: gservicesPlistPath)
                if let dict = try PropertyListSerialization.propertyList(from: gservicesPlist, options: [], format: nil) as? [String: Any]{
                    clientID = dict
                }
            } catch {
                print(error)
            }
        }
        
        GIDSignIn.sharedInstance()?.clientID = clientID?["CLIENT_ID"] as? String
        GIDSignIn.sharedInstance()?.delegate = self
        
        initFirstVC()
        
        return true
    }
    
    private func initFirstVC(){
        let initialVC : UIViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow()
        
        if(Auth.auth().currentUser != nil){
            let profileVC = storyboard.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
            initialVC = profileVC
        }
        else {
            let loginVC = storyboard.instantiateViewController(identifier: "LoginVC") as! ViewController
            initialVC = loginVC
        }
        let nav = storyboard.instantiateViewController(identifier: "navVC") as! NavViewController
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print(error)
            return
        }
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential){ (authResult,error) in
            if let error = error{
                print("Google Auth Failed: \(error.localizedDescription)")
                return
            }
            
        }
        
        print("User Email: \(user.profile.email ?? "No Email") ")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //TODO
    }

}

