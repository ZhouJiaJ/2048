//
//  ScoreView.swift
//  2048
//
//  Created by admin on 2019/4/15.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

//这里的协议的作用是方便别的类中调用记分板的scoreChanged方法
protocol ScoreProtocol {
    func scoreChanged(newScore s: Int)
}

class ScoreView: UIView, ScoreProtocol {
    //记分板本身是label，作用是显示分数
    var lable: UILabel
    
    //score
    var score: Int = 0 {
        didSet{
            lable.text = "Score:\(score)"
        }
    }
    let defaultFrame = CGRect(x: 0, y: 0, width: 200, height: 40)
    
    init(backgroundColor bgColor: UIColor, textColor tColor: UIColor, font: UIFont){
        lable = UILabel(frame: defaultFrame)
        lable.textAlignment = NSTextAlignment.center
        super.init(frame: defaultFrame)
        backgroundColor = bgColor
        lable.textColor = tColor
        lable.font = font
        lable.layer.cornerRadius = 6
        self.addSubview(lable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(newScore s: Int) {
        score = s
    }
}
