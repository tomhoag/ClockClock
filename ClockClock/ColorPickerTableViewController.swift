//
//  ColorPickerTableViewController.swift
//  ClockClock
//
//  Created by Tom on 5/25/19.
//  Copyright © 2019 SquarePi Software. All rights reserved.
//

import UIKit
import IGColorPicker

class ColorPickerTableViewController: UITableViewController, UIGestureRecognizerDelegate, ColorPickerViewDelegate  {

    @IBOutlet var tableViewCells: [UITableViewCell]!
    @IBOutlet weak var foregroundColorPicker: ColorPickerView!
    @IBOutlet weak var backgroundColorPicker: ColorPickerView!
    @IBOutlet weak var digitView: DigitView!
    @IBOutlet weak var widthSlider: UISlider!
    private var timer = Timer()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @IBAction func didSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {

        digitView.handWidth = CGFloat(Int((sender as! UISlider).value))
        //digitView.circleWidth = max(0.5 * log(digitView.circleWidth), 1.0)
        
        let defaults = UserDefaults.standard
        defaults.set(CGFloat(Int((sender as! UISlider).value)), forKey: "handWidth")
    }

    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foregroundColorPicker.delegate = self
        backgroundColorPicker.delegate = self
        
        foregroundColorPicker.isSelectedColorTappable = false
        backgroundColorPicker.isSelectedColorTappable = false
        
        foregroundColorPicker.scrollToPreselectedIndex = true
        backgroundColorPicker.scrollToPreselectedIndex = true
        
        foregroundColorPicker.colors.append(.white)
        foregroundColorPicker.colors.append(UIColor(white: 0.95, alpha: 1))
        foregroundColorPicker.colors.append(UIColor(white: 0.9, alpha: 1))
        backgroundColorPicker.colors.append(.white)
        backgroundColorPicker.colors.append(UIColor(white: 0.95, alpha: 1))
        backgroundColorPicker.colors.append(UIColor(white: 0.9, alpha: 1))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
            let value = Int.random(in: 1..<10)
            self.digitView.digit(self.digitView.value + value, completion: {})
        })
        
        let defaults = UserDefaults.standard
        digitView.handColor = defaults.colorForKey(key: "foregroundColor") ?? .white
        digitView.circleColor = defaults.colorForKey(key: "foregroundColor") ?? .white
        
        let backgroundColor = defaults.colorForKey(key: "backgroundColor") ?? .black
        self.view.backgroundColor =  backgroundColor
        digitView.backgroundColor = backgroundColor
        backgroundColorPicker.backgroundColor = backgroundColor
        foregroundColorPicker.backgroundColor = backgroundColor
        tableViewCells.forEach { $0.backgroundColor = backgroundColor}
        
        backgroundColorPicker.preselectedIndex = defaults.integer(forKey: "backgroundColorIndex")
        foregroundColorPicker.preselectedIndex = defaults.integer(forKey: "foregroundColorIndex")
        
        let handWidth = defaults.float(forKey: "handWidth")
        widthSlider.value = handWidth
        digitView.handWidth = CGFloat(handWidth)
        //digitView.circleWidth = CGFloat(0.5 * handWidth)
    }

    // MARK: - ColorPicker delegate
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        
        // A color has been selected
        if(0 == colorPickerView.tag) { // foreground picker
            digitView.circleColor = colorPickerView.colors[indexPath.row]
            digitView.handColor = colorPickerView.colors[indexPath.row]
            let defaults = UserDefaults.standard
            defaults.setColor(color: colorPickerView.colors[indexPath.row], forKey: "foregroundColor")
            defaults.set(indexPath.row, forKey:"foregroundColorIndex")

        } else { // background picker
            let color = colorPickerView.colors[indexPath.row]
            self.view.backgroundColor =  color
            digitView.backgroundColor = color
            backgroundColorPicker.backgroundColor = color
            foregroundColorPicker.backgroundColor = color
            tableViewCells.forEach { $0.backgroundColor = color}
            
            let defaults = UserDefaults.standard
            defaults.setColor(color: colorPickerView.colors[indexPath.row], forKey: "backgroundColor")
            defaults.set(indexPath.row, forKey: "backgroundColorIndex")
        }
    }
}

extension UserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
}
