//
//  ScrollingBackground.swift
//  ColorGame
//
//  Created by sanket kumar on 10/03/18.
//  Copyright © 2018 sanket kumar. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class ScrollingBackground: SKSpriteNode {
    var scrollingSpeed : CGFloat = 0
    
    static func scrollingNodeWithImage(imageName image : String , containerWidth width : CGFloat) -> ScrollingBackground {
        let bgImage = UIImage(named: image)!
       
        let scrollNode = ScrollingBackground(color: UIColor.clear, size: CGSize(width: width, height: bgImage.size.height))
        
        
        scrollNode.scrollingSpeed = 1
        var totalWidthNeeded : CGFloat = 0
        
        while totalWidthNeeded < width + bgImage.size.width {
            let childNode = SKSpriteNode(imageNamed: image)
            childNode.anchorPoint = CGPoint.zero
            childNode.anchorPoint = CGPoint(x: totalWidthNeeded, y: 0)
            scrollNode.addChild(childNode)
            totalWidthNeeded += childNode.size.width
          
        }
        return scrollNode
        
    }
    
    
    func update(currentTime : TimeInterval) {
        for child in self.children {
            child.position = CGPoint(x: child.position.x - self.scrollingSpeed, y: 0)
            if child.position.x <= -child.frame.size.width {
                print(child.position.x)
                let delta = child.position.x + child.frame.size.width
                child.position = CGPoint(x: child.frame.size.width * CGFloat(self.children.count - 1) + delta, y: child.position.y)
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
}
