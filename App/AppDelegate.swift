//
//  appdeleg.swift
//  TeachMe
//
//  Created by Kobaissy on 4/26/19.
//  Copyright © Kobaissy. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
//import IQKeyboardManagerSwift

import Firebase
import FirebaseMessaging
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  { //, GIDSignInDelegate
    
    var window: UIWindow?
    
    public var showError = true
    public var isArabic = false
    public var config: [String: AnyObject] = [:]
    
    // notification
    var tokenString = ""
    var type = 0
    var recordId = 0
    //var showNotification = false
    var isConnected = false
    let gcmMessageIDKey = "gcm.message_id"
    var openClosingAppLink: String = ""
    
    //var user: GIDGoogleUser!
    
    var isUpdate = false
    var isUserLogin = false
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setLanguage(lang: Language.EN, isRTL: false)
        
        // Language switch
        Localizer.doTheMagic()
        
        // IQKeyboardManager
        // IQKeyboardManager.shared.enable = false
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Push notification
        NotificationManager.shared.setupDelegate()
        NotificationManager.shared.checkNotificationSettingsStatus()
        // registerForPushNotifications(application: application)
        
        // if app wasn’t running
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            handleNotification(show: false, userInfo: notification)
        }
        
        return true
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        print("application continue webpageURL:",url.absoluteString)
        NotificationCenter.default.post(name: Notification.Name("NotificationReceived"), object: url.absoluteString)
        return true
    }
    
    
    func showAlert(vc: UIViewController?, titleTxt: String, msgTxt: String, btnTxt: String){
        appDelegate.showAlert(vc: vc, titleTxt: titleTxt, msgTxt: msgTxt, btnTxt: btnTxt) { (isDone) in
        }
    }
    
    func showAlert(vc: UIViewController?, titleTxt: String, msgTxt: String, btnTxt: String, withCancelButton: Bool = false, withCompletionHandler completionHandler: @escaping (Bool) -> Void){
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindow.Level.alert + 1
        
        let alertController = UIAlertController(title: titleTxt, message: msgTxt , preferredStyle: UIAlertController.Style.alert)
        
        // Change Title With Color and Font:
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: titleTxt as String, attributes: [NSAttributedString.Key.font: getBoldFont(size: 15) ])
        alertController.setValue(myMutableString, forKey: "attributedTitle")
        
        // Change Message With Color and Font
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: msgTxt as String, attributes: [NSAttributedString.Key.font: getFont(size: 15)])
        alertController.setValue(messageMutableString, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: btnTxt.lowercased() == "ok" ? NSLocalizedString("ok", comment: "") : btnTxt , style: withCancelButton ? .default : .cancel){
            UIAlertAction in
            completionHandler(true)
        }
        
        alertController.addAction(okAction)
        
        if withCancelButton {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        if(vc != nil){
            vc!.present(alertController, animated: true, completion: nil)
        }
        else{
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func AddDevice(token: String){
        let url = "http://inoyadi.com/shca/api.php?class=Device&function=creat_token"
        let parameters: Parameters = [
            "imei": (UIDevice.current.identifierForVendor?.uuidString)! ,
            "token": token ,
            "osv": "1"
        ]
        
        print("AddDevice url: " , url)
        print("AddDevice parameters: " , parameters)
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success:
                print("AddDevice result: " , response.result.value ?? "nil")
            case .failure(let error):
                print("AddDevice result: " , error.localizedDescription)
            }
        }
    }
    
}



//MARK: - Notification
extension AppDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("===> App delegate did receive remote notification: \n \(userInfo)")
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        NotificationManager.shared.sendFCMTokenToServer()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("===> App delegate failed to register remote notification with error: \n \(error.localizedDescription)")
    }
}
