//
//  ViewController.swift
//  2048
//
//  Created by admin on 2019/4/4.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //setupGame()
        view.backgroundColor = UIColor(red: 0xE6/255, green: 0xE2/255, blue: 0xD4/255, alpha: 1)
        
        
    }

    @IBAction func setupGame(_ sender: Any) {
        let game = NumbertailGameController(demesion: 4, threshold: 2048)
        self.present(game, animated: true, completion: nil)
    }
    
}

