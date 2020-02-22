//
//  ViewController.swift
//  ClockClock
//
//  Created by Tom on 5/23/19.
//  Copyright © 2019 SquarePi Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tensHours: DigitView!
    @IBOutlet weak var onesHours: DigitView!
    @IBOutlet weak var tensMinutes: DigitView!
    @IBOutlet weak var onesMinutes: DigitView!
    
    var dateFormatter:DateFormatter = DateFormatter()
    var digits = [DigitView]()
    
    var animationTime:CFTimeInterval = 3.0
    var handColor:UIColor = .white
    var circleColor:UIColor = .white
    var backgroundColor:UIColor = .black
    var handWidth:CGFloat = 6
    var circleWith:CGFloat = 1
    
    private var updateTimer:Timer = Timer()
    private var doingLongPress:Bool = false
    private var isAnimating:Bool = false
    
    @IBAction func didSwipeDown(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showOptions", sender: self)
    }
    
    @IBAction func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if(UIGestureRecognizer.State.began == sender.state) {
            if(doingLongPress || isAnimating) {
                return
            }
            doingLongPress = true
            updateTimer.invalidate()
            doEasterEgg()
        } else if(UIGestureRecognizer.State.ended == sender.state) {
            doingLongPress = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let defaults = UserDefaults.standard
        let backgroundColor = defaults.colorForKey(key: "backgroundColor") ?? .black
        self.view.backgroundColor = backgroundColor
        
        let foregroundColor = defaults.colorForKey(key: "foregroundColor") ?? .white
        let handWidth = max(1.0, CGFloat(defaults.float(forKey: "handWidth")))

        digits.forEach {
            $0.update()
            $0.handColor = foregroundColor
            $0.circleColor = foregroundColor
            $0.backgroundColor = backgroundColor
            $0.handWidth = handWidth
            $0.animationTime = 0
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            // empty
        }) { (context) in
            self.digits.forEach { $0.update() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        digits.append(tensHours)
        digits.append(onesHours)
        digits.append(tensMinutes)
        digits.append(onesMinutes)
        
        dateFormatter.dateFormat = "hhmm"
        
        updateClock({
            self.digits.forEach {
                $0.animationTime = self.animationTime
            }
        })
    }
    
   @objc private func startUpdateTimer() {
        
        if(isAnimating || doingLongPress) {
            return
        }
        
        updateTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateTimerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer, forMode: RunLoop.Mode.common)
    }
    
    @objc func updateTimerFired(_ timer:Timer) {
        updateTimer.invalidate() // invalidate the timer so it doesn't fire during the clock hand animations
        updateClock({})
    }
    
    private func updateClock(_ completion:@escaping ()->Void) {
        
        var i = 0
        let group = DispatchGroup()
        
        for char in self.dateFormatter.string(from: Date()) {
            let digit = Int(String(char))!
            if( digit != digits[i].value){
                isAnimating = true
                group.enter()
                digits[i].digit(digit, completion: { group.leave() })
            }
            i += 1
        }
        
        group.notify(queue: .main) {
            completion()
            self.isAnimating = false
            self.startUpdateTimer()
        }
    }
    
    private func doEasterEgg() {

        isAnimating = true
        let group = DispatchGroup()
        digits.forEach {
            group.enter()
            $0.digit($0.value+1, completion: { group.leave() })
        }
        
        group.notify(queue: .main) {
            
            if(self.doingLongPress) {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (t) in
                    self.doEasterEgg()
                })
            } else {
                self.isAnimating = false
                self.updateClock({})
            }
        }
    }
}
