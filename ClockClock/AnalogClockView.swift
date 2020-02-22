//
//  AnalogClockView.swift
//  ClockClock
//
//  Created by Tom on 5/23/19.
//  Copyright © 2019 SquarePi Software. All rights reserved.
//

import UIKit

class AnalogClockView: UIView {
    
    var hourLayer: CALayer!;
    var hourAngle: CGFloat!;
    var minuteLayer: CALayer!;
    var minuteAngle: CGFloat!;
    var animationTime:CFTimeInterval = 0;
    var circleWidth:CGFloat = 1
    
    var handWidth:CGFloat! = 4 {
        didSet {
            circleWidth = max(0.5 * log(handWidth), 1.0)
            hourLayer.bounds = hourBounds
            minuteLayer.bounds = minuteBounds
            self.setNeedsDisplay()
        }
    }
    
    var handColor:UIColor! = .white {
        didSet {
            hourLayer.backgroundColor = handColor.cgColor
            minuteLayer.backgroundColor = handColor.cgColor
        }
    };
    
    var circleColor:UIColor! = .black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
//    var circleWidth:CGFloat! = 2 {
//        didSet {
//            if(circleWidth < 1) {
//                circleWidth = 1
//            }
//            self.setNeedsDisplay()
//        }
//    }
    
    private var minuteBounds:CGRect {
        get{
            return CGRect(x: 0, y: 0, width: handWidth, height: self.frame.size.width/2 * 0.8 - yoffset);
        }
    }
    
    private var hourBounds:CGRect {
        get {
            return CGRect(x: 0, y: 0, width: handWidth, height: self.frame.size.width/2 * 0.65 - yoffset);
        }
    }
    
    private var yoffset:CGFloat {
        return -2 * handWidth/self.frame.size.width
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {

        backgroundColor = .clear
        hourLayer = CALayer.init();
        hourLayer.backgroundColor = handColor.cgColor
        hourLayer.anchorPoint = CGPoint.init(x: 0.5, y: yoffset);
        hourLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
        hourLayer.bounds = hourBounds
        hourLayer.cornerRadius = handWidth/2
        hourAngle = 0;
        self.layer.addSublayer(hourLayer);
        
        minuteLayer = CALayer.init();
        minuteLayer.backgroundColor = handColor.cgColor
        minuteLayer.anchorPoint = CGPoint.init(x: 0.5, y: yoffset);
        minuteLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
        minuteLayer.bounds = minuteBounds
        minuteLayer.cornerRadius = handWidth/2
        minuteAngle = 0;
        self.layer.addSublayer(minuteLayer);
    }
    
    /**
     * Set the time on the clock face by animating the rotation of the hour and minute layers
     * When the animations are complete, the completion block is called
    */
    func setTime(hours:CGFloat, minutes:CGFloat, _ completion:@escaping ()->Void) {
        
        let group = DispatchGroup()

        CATransaction.begin()
        group.enter()
        let minutesRotationAnimation = CABasicAnimation();
        minutesRotationAnimation.valueFunction = CAValueFunction(name: .rotateZ);
        minutesRotationAnimation.fromValue = minuteAngle;
        var toMinuteAngle = ((minutes.remainder(dividingBy: 60) * 6 * .pi/180) + .pi).remainder(dividingBy: 2 * .pi)
        if(toMinuteAngle - minuteAngle > .pi) {
            toMinuteAngle = toMinuteAngle - 2 * CGFloat.pi
        } else if(toMinuteAngle - minuteAngle < -.pi){
            toMinuteAngle = toMinuteAngle + 2 * CGFloat.pi
        }
        minutesRotationAnimation.toValue = toMinuteAngle
        minutesRotationAnimation.duration = animationTime;
        minutesRotationAnimation.fillMode = .forwards
        minutesRotationAnimation.isRemovedOnCompletion = false;
        CATransaction.setCompletionBlock {
            self.minuteAngle = toMinuteAngle.remainder(dividingBy: 2 * .pi);
            group.leave()
        }
        minuteLayer.add(minutesRotationAnimation, forKey: "transform");
        CATransaction.commit();
        
        CATransaction.begin()
        group.enter()
        let hoursRotationAnimation = CABasicAnimation();
        hoursRotationAnimation.valueFunction = CAValueFunction(name: .rotateZ);
        hoursRotationAnimation.fromValue = hourAngle;
        var toHourAngle = ((hours.remainder(dividingBy: 12) * 30 * .pi/180) + .pi).remainder(dividingBy: 2 * .pi); // 1hr = 30d
        if(toHourAngle - hourAngle > .pi ){
            toHourAngle = toHourAngle - 2 * CGFloat.pi
        } else if(toHourAngle - hourAngle < -.pi) {
            toHourAngle = toHourAngle + 2 * CGFloat.pi
        }
        
        hoursRotationAnimation.toValue = toHourAngle;
        hoursRotationAnimation.duration = animationTime;
        hoursRotationAnimation.fillMode = .forwards;
        hoursRotationAnimation.isRemovedOnCompletion = false;
        CATransaction.setCompletionBlock {
            self.hourAngle = toHourAngle.remainder(dividingBy: 2 * .pi);
            group.leave()
        }
        hourLayer.add(hoursRotationAnimation, forKey: "transform");
        CATransaction.commit()
        
        group.notify(queue: .main) { // completed when both animations completion blocks execute
            completion()
        }
    }
    
    /**
    * Draws the circle that represents the analog clock boundary
    */
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {

            context.setLineWidth(circleWidth);
            
            circleColor.set()
            
            let center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            let radius = (frame.size.width - circleWidth)/2
            
            //print("center: ", center, " radius: ", radius)
            context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
            
            context.strokePath()
        }
    }
}
