import UIKit
import SpriteKit
import AVFoundation
import GoogleMobileAds

class ViewController: UIViewController, GADBannerViewDelegate {
    
    var audioPlayer : AVAudioPlayer!
    
    var admobView: GADBannerView = GADBannerView()
    let AdMobID                  = "ca-app-pub-6865266976411360/5264970335"
    
   /*
    * viewDidLoad
    *
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        showAd()
        let mainFrame                = UIScreen.mainScreen().bounds
        let skViewFrame              = CGRectMake(0 , 0, mainFrame.width, mainFrame.height - admobView.frame.height)
        let skView                   = SKView(frame: skViewFrame)
        skView.multipleTouchEnabled  = false
        skView.ignoresSiblingOrder   = true
        self.view.addSubview(skView)
        let scene = TitleScene(size: skView.bounds.size)
        skView.presentScene(scene)
        changeBGM(scene)
    }
    
    func showAd() {
        admobView              = GADBannerView(adSize:kGADAdSizeBanner)
        admobView.frame.origin = CGPointMake(0, self.view.frame.size.height - admobView.frame.height)
        admobView.frame.size   = CGSizeMake(self.view.frame.width, admobView.frame.height)
        admobView.adUnitID     = AdMobID
        admobView.delegate     = self
        admobView.rootViewController = self
        let admobRequest : GADRequest = GADRequest()
//        admobRequest.testDevices = [kGADSimulatorID]
        admobView.loadRequest(admobRequest)
        self.view.addSubview(admobView)
    }
    
    
   /*
    * changeBGM
    *
    */
    func changeBGM(scene: SKScene) {
        if audioPlayer != nil && audioPlayer.playing {
            audioPlayer.stop()
        }
        var bgm : String
        if scene.isKindOfClass(PlayScene) || scene.isKindOfClass(BattleScene){
            bgm = "play_bgm"
        }
        else if scene.isKindOfClass(TitleScene) {
            bgm = "title_bgm"
        }
        else {
            bgm = "home_bgm"
        }
        audioPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(bgm, ofType: "mp3")!))
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
