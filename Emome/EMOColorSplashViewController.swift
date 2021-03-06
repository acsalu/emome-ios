//
//  EMOColorSplashViewController.swift
//  Emome
//
//  Created by Huai-Che Lu on 11/26/15.
//  Copyright © 2015 Emome. All rights reserved.
//

import UIKit
import QuartzCore

let kAnimationRemoveLayer: String = "animationRemoveLayer"

class EMOColorSplashViewController: UIViewController {
    
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var canvasView: UIView!
    var pusher: UIPushBehavior!
    var animator: UIDynamicAnimator!
    
    var touchStartTime: NSTimeInterval?
    
    var newLayer: CAShapeLayer?
    
    var isPanelSetUp = false
    
    var emotionColorButtons: [EMOEmotionColorButton] = []
    var eraserButton: UIButton!
    
    var currentColor: UIColor?
    
    var colorLayers: [CAShapeLayer] = []
    
    var shouldRemoveLayerIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        // Do any additional setup after loading the view.
//        let circleView = UIView(frame: CGRect(x: 100.0, y: 200.0, width: 40.0, height: 40.0))
//        circleView.backgroundColor = UIColor.emomeThemeColor()
//        circleView.layer.cornerRadius = 20.0
//        self.view.addSubview(circleView)
//        
//        self.animator = UIDynamicAnimator.init(referenceView: self.view)
//        
//        self.pusher = UIPushBehavior.init(items: [circleView], mode: .Instantaneous)
//        self.pusher.pushDirection = CGVector(dx: 0.1, dy: 0.1)
//        self.pusher.active = true
//        
//        self.animator.addBehavior(self.pusher)
//        
//        let collision = UICollisionBehavior.init(items: [circleView])
//        collision.translatesReferenceBoundsIntoBoundary = true
//        self.animator.addBehavior(collision)
        
    }
    
    override func viewDidLayoutSubviews() {
        if !self.isPanelSetUp {
            setUpPanel()
            self.isPanelSetUp = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func backToHome(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func setUpPanel() {
        let maskPath = UIBezierPath.init(roundedRect: self.panelView.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 8.0, height: 8.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.CGPath
        self.panelView.layer.mask = maskLayer
        
        let height = self.panelView.bounds.size.height
        let width = self.panelView.bounds.size.width / CGFloat(EMOEmotion.allValues.count + 1)
        
        // Add Button
        var x: CGFloat = 0.0
        var tag: Int = 0
        for emotion in EMOEmotion.allValues {
            
            let button = EMOEmotionColorButton.init(frame: CGRect(x: x, y: 0, width: width, height: height))
        
            button.emotionColor = UIColor.colorForEmotion(emotion)

            button.setTitle("\(emotion)", forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 60.0, left: 0.0, bottom: 0.0, right: 0.0)
            button.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            button.tag = tag
            button.addTarget(self, action: "toolDidSelect:", forControlEvents: .TouchUpInside)
            self.panelView.addSubview(button)
            
            self.emotionColorButtons.append(button)
            
            x += width
            tag += 1
        }
        
        self.eraserButton = UIButton.init(frame: CGRect(x: x, y: 0, width: width, height: height))
        eraserButton.setImage(UIImage(named: "btn-eraser"), forState: .Normal)
        eraserButton.imageEdgeInsets = UIEdgeInsets(top: 18.0, left: 0.0, bottom: 0.0, right: 0.0)
        eraserButton.addTarget(self, action: "toolDidSelect:", forControlEvents: .TouchUpInside)
        self.panelView.addSubview(eraserButton)
    }
    
    func toolDidSelect(sender: UIButton) {
        
        for button in self.emotionColorButtons {
            button.selected = false
        }
        self.eraserButton.selected = false
        sender.selected = true
        
        
        if sender == self.eraserButton {
            self.currentColor = nil
            self.newLayer = nil
        } else {
            log.verbose("\(EMOEmotion.allValues[sender.tag]) selected")
            self.currentColor = UIColor.colorForEmotion(EMOEmotion.allValues[sender.tag])
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            log.verbose("Touches Began: \(touch.locationInView(self.view))")
            self.touchStartTime = event?.timestamp
            
            if let color = self.currentColor {
                
                self.newLayer = CAShapeLayer()
                self.newLayer!.bounds = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
                self.newLayer!.position = touch.locationInView(self.canvasView)
                self.newLayer!.backgroundColor = color.CGColor
                self.newLayer!.cornerRadius = 20.0
                self.newLayer!.opacity = 0.6
                self.canvasView.layer.addSublayer(self.newLayer!)
                
                let scaleAnimation = CABasicAnimation.init(keyPath: "transform")
                scaleAnimation.fromValue = NSValue.init(CATransform3D: CATransform3DIdentity)
                scaleAnimation.toValue = NSValue.init(CATransform3D: CATransform3DMakeScale(10.0, 10.0, 1.0))
                
                scaleAnimation.duration = 3.0
                scaleAnimation.fillMode = kCAFillModeBoth
                scaleAnimation.removedOnCompletion = false
                
                self.newLayer!.addAnimation(scaleAnimation, forKey: "zoom")
                
            } else {
                
                let touchedLayer = self.canvasView.layer.presentationLayer()?.hitTest(touch.locationInView(self.view))
                let actualLayer = touchedLayer!.modelLayer() as! CALayer
                
                if actualLayer == self.canvasView.layer {
                    log.verbose("touch on canvas. remove nothing.")
                } else {
                    for i in 0..<self.colorLayers.count {
                        if actualLayer == self.colorLayers[i] {
                            self.removeLayer(actualLayer, animated: true)
                            self.colorLayers.removeAtIndex(i)
                            break
                        }
                    }
                }
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            
            if let layer = self.newLayer {
                CATransaction.begin()
                layer.position = touch.locationInView(self.canvasView)
                CATransaction.commit()
            }
            
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            log.verbose("Touches End: \(touch.locationInView(self.canvasView))")
            
            if let layer = self.newLayer {
                if let frame = layer.presentationLayer()?.frame {
                    
                    layer.bounds = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)
                    layer.cornerRadius = frame  .size.width / 2
                    layer.removeAnimationForKey("zoom")
                }
                
                self.colorLayers.append(layer)
            }
        }
    }
    
    func removeLayer(layer: CALayer, animated: Bool) {
        
        let scaleAnimation = CABasicAnimation.init(keyPath: "transform")
        scaleAnimation.fromValue = NSValue.init(CATransform3D: CATransform3DIdentity)
        scaleAnimation.toValue = NSValue.init(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0))
        scaleAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)
        
        scaleAnimation.duration = 0.2
        scaleAnimation.fillMode = kCAFillModeBoth
        scaleAnimation.removedOnCompletion = false
        
        scaleAnimation.delegate = self
        scaleAnimation.setValue(layer, forKey: kAnimationRemoveLayer)
        
        layer.addAnimation(scaleAnimation, forKey: "shrink")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let layer = anim.valueForKeyPath(kAnimationRemoveLayer) {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        
    }
    
    

}
