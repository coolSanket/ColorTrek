//
//  GameHandler.swift
//  ColorGame
//
//  Created by sanket kumar on 10/03/18.
//  Copyright © 2018 sanket kumar. All rights reserved.
//

import Foundation

class GameHandler {
    var score : Int
    var highScore : Int
    
    class var sharedInstnace : GameHandler {
        struct Singleton {
            static let instance = GameHandler()
        }
        return Singleton.instance
    }
    
    init() {
        score = 0
        highScore = 0
        
        
        let userDafaults = UserDefaults.standard
        highScore = userDafaults.integer(forKey: "highScore")
    }
    
    func saveGameStats()  {
        highScore = max(score, highScore)
        let userDafaults = UserDefaults.standard
        userDafaults.set(highScore, forKey: "highScore")
        userDafaults.synchronize()
    }
    
    
    
    
    
}
