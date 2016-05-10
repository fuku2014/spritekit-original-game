//
//  UserData.swift
//  あるきスマホ
//
//  Created by admin on 2015/09/02.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//
import UIKit

class UserData: NSObject {
    
    
    static func getUserName() ->String!{
        let defaults = NSUserDefaults.standardUserDefaults()
        let userName : String!  = defaults.stringForKey("USER_NAME")
        return userName
    }
    
    static func setUserName(userName : String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userName, forKey: "USER_NAME")
    }
    
    static func getUserId() ->String!{
        let defaults = NSUserDefaults.standardUserDefaults()
        let userId : String!  = defaults.stringForKey("USER_ID")
        return userId
    }
    
    static func setUserId(userId : String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userId, forKey: "USER_ID")
    }
    
    static func getHighScore() ->Int!{
        let defaults = NSUserDefaults.standardUserDefaults()
        let highScore : Int  = defaults.integerForKey("HIGH_SCORE")
        return highScore | 0
    }
    
    static func setHighScore(highScore : Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(highScore, forKey: "HIGH_SCORE")
    }
    
    static func getImageData() ->NSData {
        let defaults      = NSUserDefaults.standardUserDefaults()
        let data : NSData = defaults.dataForKey("USER_IMAGE")!
        return data
    }
    
    static func setImageData(data : NSData) {
        let defaults      = NSUserDefaults.standardUserDefaults()
        defaults.setObject(data, forKey: "USER_IMAGE")
    }
}
