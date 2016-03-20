//
//  SoloMode.swift
//  SlugSet
//
//  Created by Julio Franco on 3/13/16.
//  Copyright (c) 2016 Julio Franco. All rights reserved.
//

import UIKit

class SoloMode: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackPressed(sender: AnyObject) {
        let test = UIBarButtonItem(title: "test", style: UIBarButtonItemStyle.Done, target: self, action: nil)
//        test.setValue("fromNickel", forKey: "testing")
        test.tag = 25
//        var another = test.valueForKey("testing") as! String
        println(test.tag)
        

        
        
//        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
