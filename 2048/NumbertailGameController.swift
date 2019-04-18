//
//  NumbertailGameController.swift
//  2048
//
//  Created by admin on 2019/4/15.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

protocol GameModelProtocol: class {
    func changeScore(score: Int)
    func insertTile(pos: (Int, Int), value: Int)
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
}

class NumbertailGameController: UIViewController, GameModelProtocol {
    
    //variable
    var demension: Int                      //2048游戏中每行每列含有多少个块
    var threshold: Int                      //最高分数，判断输赢时使用
    
    var bord: GameBoardView?
    var scoreV: ScoreView?
    var gameModle: GameModle?
    
    let boardWidth: CGFloat = 360.0         //游戏区域的长度和高度
    let thinPadding: CGFloat = 3.0          //游戏区里面小块间的间距
    
    let viewPadding: CGFloat = 10.0         //记分板和游戏区块的艰巨
    let verticalViewOffset: CGFloat = 0.0   //一个初始化的属性
    
    init(demesion d: Int, threshold t: Int){
        demension = d < 2 ? 2 : d
        threshold = t < 8 ? 8 : t
        super.init(nibName: nil, bundle: nil)
        gameModle = GameModle(dimension: demension, threshold: threshold, delegate: self)
        view.backgroundColor = UIColor(red: 0xE6/255, green: 0xE2/255, blue: 0xD4/255, alpha: 1)
        setupSwipeController()
    }
    
    //注册监听器，舰艇当前视图里的手指滑动操作，上下左右分别对应下面的四个方法
    func setupSwipeController() {
        let upSwize = UISwipeGestureRecognizer(target: self, action: #selector(self.upCommand))
        upSwize.numberOfTouchesRequired = 1
        upSwize.direction = UISwipeGestureRecognizer.Direction.up
        view.addGestureRecognizer(upSwize)
        
        let downSize = UISwipeGestureRecognizer(target: self, action: #selector(self.downCommand))
        downSize.numberOfTouchesRequired = 1
        downSize.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(downSize)
        
        let leftSwize = UISwipeGestureRecognizer(target: self, action: #selector(self.leftCommand))
        leftSwize.numberOfTouchesRequired = 1
        leftSwize.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(leftSwize)
        
        let rightSwize = UISwipeGestureRecognizer(target: self, action: #selector(self.rightCommand))
        rightSwize.numberOfTouchesRequired = 1
        rightSwize.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(rightSwize)
    }
    
    //向上滑动的方法，调用queenMove，传入MoveDirection.Up
    @objc func upCommand(r: UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(direction: MoveDirection.UP) { (changed: Bool) -> () in
            if changed {
                self.followUp()
            }
        }
    }
    
    //向下滑动的方法，调用queenMove，传入MoveDirection.Down
    @objc func downCommand(r: UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(direction: MoveDirection.DOWN) { (changed: Bool) -> () in
            if changed {
                self.followUp()
            }
        }
    }
    
    //向左滑动的方法，调用queenMove，传入MoveDirection.Left
    @objc func leftCommand(r: UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(direction: MoveDirection.LEFT) { (changed: Bool) -> () in
            if changed {
                self.followUp()
            }
        }
    }
    
    //向右滑动的方法，调用queenMove，传入MoveDirection.Right
    @objc func rightCommand(r: UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(direction: MoveDirection.RIGHT) { (changed: Bool) -> () in
            if changed {
                self.followUp()
            }
        }
    }
    
    //移动之后需要判断用户的输赢情况，如果赢了则弹框提示，给一个重玩和取消按钮
    func followUp() {
        assert(gameModle != nil)
        let m = gameModle!
        let (userWon, _) = m.userHasWon()
        if userWon {
            let winAlertView = UIAlertController(title: "result", message: "You Won!", preferredStyle: .alert)
            let resetAction = UIAlertAction(title: "reset", style: .default, handler: { (u: UIAlertAction) -> () in
                self.reset()
                })
            winAlertView.addAction(resetAction)
            let cancleAction = UIAlertAction(title: "cancel", style: .default, handler: nil)
            winAlertView.addAction(cancleAction)
            self.present(winAlertView, animated: true, completion: nil)
            return
        }
        
        //now, insert more tiles
        let randomVal = Int(arc4random_uniform(10))
        m.insertRandomPositionTile(value: randomVal == 1 ? 4 : 2)
        
        //at this point, the user may lose
        if m.userHasLost(){
            //alert delegate we lost
            NSLog("You lost...")
            let lostAlertView = UIAlertController(title: "result", message: "You Lose!", preferredStyle: .alert)
            let resetAction = UIAlertAction(title: "reset", style: .default, handler: { (u: UIAlertAction) -> () in
                self.reset()
            })
            lostAlertView.addAction(resetAction)
            let cancleAction = UIAlertAction(title: "cancel", style: .default, handler: nil)
            lostAlertView.addAction(cancleAction)
            self.present(lostAlertView, animated: true, completion: nil)
        }
    }
    
    func reset() {
        assert(bord != nil && gameModle != nil)
        let b = bord!
        let m = gameModle!
        b.reset()
        m.reset()
        m.insertRandomPositionTile(value: 2)
        m.insertRandomPositionTile(value: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    func setupGame(){
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        
        //获取游戏区域左上角那个点的x坐标
        func xposition2Center(view v: UIView) -> CGFloat {
            let vwidth = v.bounds.width
            return 0.5 * (viewWidth - vwidth)
        }
        
        //获取游戏区域左上角那个点的y坐标
        func yposition2Center(order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            let totalViewHeight = CGFloat(views.count - 1) * viewPadding + views.map({$0.bounds.height}).reduce(verticalViewOffset, {$0 + $1})
            let firstY = 0.5 * (viewHeight - totalViewHeight)
            
            var acc: CGFloat = 0
            for i in 0..<order {
                acc += viewPadding + views[i].bounds.height
            }
            
            return acc + firstY
        }
        
        //获取具体每一个区块的变长，即：（游戏区块长度 - 间隙总和）/ 块数
        let width = (boardWidth - thinPadding * CGFloat(demension + 1)) / CGFloat(demension)
        
        //初始化一个记分板对象
        let scoreView = ScoreView(
            backgroundColor: UIColor(red: 0xA2/255, green: 0x94/255, blue: 0x5E/255, alpha: 1),
            textColor: UIColor(red: 0xF3/255, green: 0xF1/255, blue: 0x1A/255, alpha: 0.5),
            font: UIFont(name: "HelveticaNeue-Bold", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        )
        
        //初始化一个游戏区块对象
        let gamebord = GameBoardView(
            dimension: demension,
            titleWidth: width,
            titlePadding: thinPadding,
            backgroundColor: UIColor(red: 0x90/255, green: 0x8D/255, blue: 0x80/255, alpha: 1),
            foregroundColor: UIColor(red: 0xF9/255, green: 0xF9/255, blue: 0xE3/255, alpha: 0.5)
        )
        //现在面板中所有的视图对象
        let views = [scoreView, gamebord]
        //设置游戏区块在整个面板中的绝对位置，即左上角第一个点
        var f = scoreView.frame
        f.origin.x = xposition2Center(view: scoreView)
        f.origin.y = yposition2Center(order: 0, views: views)
        scoreView.frame = f
        
        f = gamebord.frame
        f.origin.x = xposition2Center(view: gamebord)
        f.origin.y = yposition2Center(order: 1, views: views)
        gamebord.frame = f
        
        //将游戏对象加入当前面板中
        view.addSubview(scoreView)
        view.addSubview(gamebord)
        
        scoreV = scoreView
        bord = gamebord
        
        scoreView.scoreChanged(newScore: 0)
        
        assert(gameModle != nil)
        let modle = gameModle!
        modle.insertRandomPositionTile(value: 2)
        modle.insertRandomPositionTile(value: 2)
        
    }
    
    func insertTile(pos: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.insertTile(pos: pos, value: value)
    }
    
    func changeScore(score: Int) {
        assert(scoreV != nil)
        let s = scoreV!
        s.scoreChanged(newScore: score)
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.moveOneTiles(from: from, to: to, value: value)
    }
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.moveTwoTiles(from: from, to: to, value: value)
    }
}
