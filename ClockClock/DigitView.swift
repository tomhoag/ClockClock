//
//  DigitView.swift
//  ClockClock
//
//  Created by Tom on 5/23/19.
//  Copyright © 2019 SquarePi Software. All rights reserved.
//

import Foundation
import UIKit

final class DigitView: UIView {

    var clocks = [AnalogClockView]()
    
    var digitFunctions = Array<((_ completion:@escaping()->Void) -> Void)>()

    var animationTime: CFTimeInterval = 3 {
        didSet {
            clocks.forEach { $0.animationTime = animationTime }
        }
    }
    
    var handColor: UIColor! {
        didSet {
            clocks.forEach { $0.handColor = handColor }
            self.setNeedsDisplay()
        }
    }
    
    var circleColor: UIColor! {
        didSet {
            clocks.forEach { $0.circleColor = circleColor }
            self.setNeedsDisplay()
        }
    }
    
    var handWidth:CGFloat = 3.0 {
        didSet {
            clocks.forEach { $0.handWidth = handWidth }
        }
    }
    
//    var circleWidth:CGFloat = 1.0 {
//        didSet {
//            clocks.forEach { $0.circleWidth = circleWidth }
//        }
//    }
    
    var value:Int = -1
    
    /**
     * Set the clock faces to represent the digit; call complettion when the digit has been
     * set on the clock face
    */
    public func digit(_ digit:Int, completion:@escaping ()->Void) {
        value = digit
        let d = digit >= 0 ? digit : -digit
        let (_, remainder) = d.quotientAndRemainder(dividingBy: 10)
        // use remainder to index into the digit functions and execute it
        digitFunctions[remainder](completion)        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup(frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setup(self.frame);
    }
    
    func setup(_ frame:CGRect) {
        // Create the array of functions that move the component analog clock hands
        // Order is important as this array will be indexed by position
        digitFunctions.append(zero)
        digitFunctions.append(one)
        digitFunctions.append(two)
        digitFunctions.append(three)
        digitFunctions.append(four)
        digitFunctions.append(five)
        digitFunctions.append(six)
        digitFunctions.append(seven)
        digitFunctions.append(eight)
        digitFunctions.append(nine)
        
        let diameter:CGFloat = min(frame.size.width/2, frame.size.height/3)

        print("setup: ", diameter, frame.size.width, frame.size.height)

        for col in 0...2 {
            for row in 0...1 {
                let view = AnalogClockView(frame: CGRect(x: CGFloat(row) * diameter, y: CGFloat(col) * diameter, width: diameter, height: diameter))
                self.addSubview(view);
                clocks.append(view);
            }
        }
    }
    
    func update() {
        
        let diameter:CGFloat = min(frame.size.width/2, frame.size.height/3)
        
        var i = 0
        for col in 0...2 {
            for row in 0...1 {
                clocks[i].frame = CGRect(x: CGFloat(row) * diameter, y: CGFloat(col) * diameter, width: diameter, height: diameter)
                i += 1
            }
        }
    }
    
    /**
     * Move the hands on the individual analog clock faces to represent a digit '1
     * When all clock faces have been updated, the completion block is executed.
     *
     * Probably could hang the completion block on one of the clocks[] as they all have
     * the same animation time, but feels more robust to call completion when all animations
     * have actually completed.
    */
    func one(_ completion:@escaping ()->Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        clear(clocks[0], { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours:6, minutes: 30, { group.leave() })
        
        group.enter()
        clear(clocks[2], { group.leave() })
        
        group.enter()
        vert(clocks[3], { group.leave() })
        
        group.enter()
        clear(clocks[4], { group.leave() })
        
        group.enter()
        noon(clocks[5], { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func two(_ completion:@escaping ()->Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[2].setTime(hours: 3, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[3].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 0, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 45, { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func three(_ completion:@escaping ()->Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[2].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        vert(clocks[3], { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func four(_ completion:@escaping ()->Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 6, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 6, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[2].setTime(hours: 3, minutes: 00, { group.leave() })
        
        group.enter()
        vert(clocks[3], { group.leave() })
        
        group.enter()
        clear(clocks[4], { group.leave() })
        
        group.enter()
        noon(clocks[5], { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func five(_ completion:@escaping ()->Void) {
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 45, { group.leave() })
        
        group.enter()
        clocks[2].setTime(hours: 3, minutes: 0, { group.leave() })
        
        group.enter()
        clocks[3].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func six(_ completion:@escaping ()->Void) {
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 45, { group.leave() })
        
        group.enter()
        vert(clocks[2], { group.leave() })
        
        group.enter()
        clocks[3].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 0, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func seven(_ completion:@escaping ()->Void) {
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clear(clocks[2], { group.leave() })
        
        group.enter()
        vert(clocks[3], { group.leave() })
        
        group.enter()
        clear(clocks[4], { group.leave() })
        
        group.enter()
        noon(clocks[5], { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func eight(_ completion:@escaping ()->Void) {
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[2].setTime(hours: 3, minutes: 30, { group.leave() });
        
        group.enter()
        clocks[3].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 0, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func nine(_ completion:@escaping ()->Void) {
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[2].setTime(hours: 3, minutes: 0, { group.leave() })
        
        group.enter()
        vert(clocks[3], { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 15, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.notify(queue: .main) { completion() }
    }
    
    func zero(_ completion:@escaping ()->Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        clocks[0].setTime(hours: 3, minutes: 30, { group.leave() })
        
        group.enter()
        clocks[1].setTime(hours: 9, minutes: 30, { group.leave() })
        
        group.enter()
        vert(clocks[2], { group.leave() })
        
        group.enter()
        vert(clocks[3], { group.leave() })
        
        group.enter()
        clocks[4].setTime(hours: 3, minutes: 0, { group.leave() })
        
        group.enter()
        clocks[5].setTime(hours: 9, minutes: 0, { group.leave() })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func clear(_ clock:AnalogClockView, _ completion:@escaping ()->Void) {
        clock.setTime(hours: 7.5, minutes: 37.5, { completion() })
    }
    
    private func noon(_ clock:AnalogClockView, _ completion:@escaping ()->Void) {
        clock.setTime(hours:12, minutes:0, { completion() })
    }
    
    private func vert(_ clock:AnalogClockView, _ completion:@escaping ()->Void) {
        clock.setTime(hours: 6, minutes: 0, { completion() })
    }
}
