//
//  AppDelegate.swift
//  Magix
//
//  Created by Alok N on 15/04/21.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert,.badge,.sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions){_,_ in }
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authStatus = UserDefaults.standard.bool(forKey: "isSignedIn")
        window = UIWindow()
        
        let navVC = storyboard.instantiateViewController(identifier: "navVC") as! NavViewController
        window?.rootViewController = navVC
        if(authStatus == true){
            let profileVC = storyboard.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
            navVC.pushViewController(profileVC, animated: false)
        }
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

extension AppDelegate: MessagingDelegate{
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        return Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token":fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil,userInfo: tokenDict)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
