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
        let src: UIViewController = self.sourceViewController as! UIViewController
        let dst: UIViewController = self.destinationViewController as! UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.33,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { finished in
                src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
}
