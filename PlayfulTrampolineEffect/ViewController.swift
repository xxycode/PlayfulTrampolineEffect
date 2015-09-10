//
//  ViewController.swift
//  PlayfulTrampolineEffect
//
//  Created by Xiaoxueyuan on 15/9/2.
//  Copyright (c) 2015年 Xiaoxueyuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var ttView = PlayfulTrampolineEffectView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width , 600))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ttView.backgroundColor = UIColor(red: 108/255.0, green: 189/255.0, blue: 240/255.0, alpha: 1)
        self.view.addSubview(ttView)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func act(sender: AnyObject) {
        ttView.popToNext()
    }



}

