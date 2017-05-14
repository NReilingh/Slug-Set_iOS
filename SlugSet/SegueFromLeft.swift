//
//  SegueFromLeft.swift
//  SlugSet
//
//  Created by Julio Franco on 3/20/16.
//  Copyright (c) 2016 Julio Franco. All rights reserved.
//

//http://stackoverflow.com/questions/30763519/ios-segue-left-to-right

import UIKit

class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src: UIViewController = self.source 
        let dst: UIViewController = self.destination 
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.33,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: {
                dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: { finished in
                src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
