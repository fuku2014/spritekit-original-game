import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /*
     * didFinishLaunchingWithOptions
     *
     * NCMBのイニシャライズ、Push通知の確認、viewControllerの起動を行う
     */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool{
        // init mbaas
        NCMB.setApplicationKey(NCMBConfig.API_KEY, clientKey: NCMBConfig.CLI_KEY)
        // push
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories:nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        // init view
        let viewController: ViewController = ViewController()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        return true
    }
    
   /*
    * didFailToRegisterForRemoteNotificationsWithError
    *
    * Push通知確認が失敗した場合
    */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        
        print( error.localizedDescription )
    }

   /*
    * didRegisterForRemoteNotificationsWithDeviceToken
    *
    * デバイストークンをncmbに送信する
    */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        var error: NSError?
        installation.save(&error)
        if let actualError = error {
            if actualError.code == 409001 {
                self.updateExistInstallation(installation)
            }
        }
    }

   /*
    * updateExistInstallation
    *
    * デバイストークンを上書きする
    */
    func updateExistInstallation(installation : NCMBInstallation) {
        let installationQuery : NCMBQuery = NCMBInstallation.query()
        installationQuery.whereKey("deviceToken", equalTo: installation.deviceToken)
        var error: NSError?
        let searchDevice : NCMBInstallation = try! installationQuery.getFirstObject() as! NCMBInstallation
        installation.objectId = searchDevice.objectId;
        installation.save(&error)
    }
}