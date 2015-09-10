//
//  PlayfulTrampolineEffectView.swift
//  PlayfulTrampolineEffect
//
//  Created by Xiaoxueyuan on 15/9/2.
//  Copyright (c) 2015年 Xiaoxueyuan. All rights reserved.
//

import UIKit

@objc protocol PlayfulTrampolineEffectViewDataSource{
    func numberOfCell(view:PlayfulTrampolineEffectView) -> Int
    func cellForRow(view:PlayfulTrampolineEffectView,row:Int) -> UIView
}

@objc protocol PlayfulTrampolineEffectViewDelegate{
    optional func sizeForRow(view:PlayfulTrampolineEffectView,row:Int) -> CGSize
    optional func didSelectAtRow(view:PlayfulTrampolineEffectView,row:Int)
}

class PlayfulTrampolineEffectView: UIView {
    
    private var contentView = UIView()
    private var backgroundLayer = CAShapeLayer()
    private var preAnimateDuration = NSTimeInterval(0.3)
    private var visiableView = Array<UIView>()
    var beginLocation = CGPointMake(0, 0)
    var marginHorizontal = CGFloat(15)
    var marginVertical = CGFloat(30)
    var currentRow = Int(2)
    override var backgroundColor:UIColor?{
        didSet{
            if backgroundColor != UIColor.clearColor(){
                contentView.backgroundColor = backgroundColor!
                backgroundLayer.fillColor = backgroundColor!.CGColor
                backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override var frame:CGRect{
        didSet{
            if frame.size.width < marginHorizontal * 2 || frame.size.height < marginVertical * 2{
                var e = NSException(name: "SizeError", reason: "The width is too small", userInfo: nil)
                e.raise()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCustomViews()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutCustomViews()
    }
    
    private func layoutCustomViews(){
        superview?.layoutIfNeeded()
        contentView.frame = bounds
        contentView.backgroundColor = backgroundColor
        backgroundLayer.fillColor = backgroundColor?.CGColor
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(width, 0))
        path.addLineToPoint(CGPointMake(width, height))
        path.addLineToPoint(CGPointMake(0, height))
        path.addLineToPoint(CGPointMake(0, 0))
        backgroundLayer.strokeColor = UIColor.clearColor().CGColor
        backgroundLayer.path = path.CGPath
        backgroundLayer.frame = layer.bounds
        layer.addSublayer(backgroundLayer)
        addSubview(contentView)
        
        for i in 0...2{
            var imageView = UIImageView()
            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
            configureViewAtRow(i, view: imageView)
            visiableView.append(imageView)
            contentView.addSubview(imageView)
            imageView.image = UIImage(named: "\(i + 1)")
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panAction:")
        contentView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func initDefaultView(){
        
    }
    
    func panAction(sender:UIPanGestureRecognizer){
        if sender.state == .Began{
            beginLocation = sender.locationInView(contentView)
        }else if sender.state == .Changed{
            panGestureRecoginzerChanged(sender.locationInView(contentView).x)
        }else{
            panGestureRecoginzerEnded(sender.locationInView(contentView).x)
        }
    }
    
    func panGestureRecoginzerChanged(offset:CGFloat){
        var firstView = visiableView[0]
        var secondView = visiableView[1]
        var topView = visiableView[2]
        var deltWidth:CGFloat
        var offsetX = offset - beginLocation.x
        if offsetX > 0{
            deltWidth = contentView.width - beginLocation.x
            var progress = offsetX / deltWidth
            makeTransformForView(topView, progress: progress, direction: 1, scale: 1)
            makeTransformForView(secondView, progress: progress, direction: 1, scale: 0.9)
            makeTransformForView(firstView, progress: progress, direction: 1, scale: 0.8)
        }else{
            deltWidth = beginLocation.x
            var progress = -offsetX / deltWidth
            makeTransformForView(topView, progress: progress, direction: -1, scale: 1)
            makeTransformForView(secondView, progress: progress, direction: -1, scale: 0.9)
            makeTransformForView(firstView, progress: progress, direction: -1, scale: 0.8)
        }
    }
    
    func makeTransformForView(view:UIView,progress:CGFloat,direction:CGFloat,scale:CGFloat){
        var rotationAngle = progress * CGFloat(M_PI * Double(direction) * 0.15 * Double(1 - (1 - scale) * 4))
        var rotationTransForm = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeRotation(rotationAngle))
        var translationTransForm = CGAffineTransformMakeTranslation(progress * direction * contentView.width * (1 - (1 - scale) * 3), 0)
        var fullTransForm = CGAffineTransformConcat(rotationTransForm, translationTransForm)
        view.transform = fullTransForm
    }
    
    func panGestureRecoginzerEnded(offset:CGFloat){
        var firstView = visiableView[0]
        var secondView = visiableView[1]
        var topView = visiableView[2]
        var deltWidth:CGFloat
        var progress:CGFloat
        var offsetX = offset - beginLocation.x
        var direction = CGFloat(1)
        if offsetX > 0{
            deltWidth = contentView.width - beginLocation.x
            progress = offsetX / deltWidth
            direction = 1
        }else{
            deltWidth = beginLocation.x
            progress = -offsetX / deltWidth
            direction = -1
        }
        if progress < 0.65{
            if CGAffineTransformIsIdentity(topView.transform) == false{
                UIView.animateWithDuration(preAnimateDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
                    topView.transform = CGAffineTransformIdentity
                    secondView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                    firstView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    }, completion: {finished in
                })
            }
        }else{
            var currTransform = topView.transform
            var translationTransform = CGAffineTransformMakeTranslation(direction * contentView.width, 0)
            var fullTransForm = CGAffineTransformConcat(currTransform, translationTransform)
            UIView.animateWithDuration(preAnimateDuration, animations: {
                topView.transform = fullTransForm
                topView.alpha = 0
                self.configureViewAtRow(1, view: firstView)
                self.configureViewAtRow(2, view: secondView)
                }, completion: {finished in
                    topView.alpha = 1
                    self.configureViewAtRow(0, view: topView)
                    topView.removeFromSuperview()
                    secondView.removeFromSuperview()
                    firstView.removeFromSuperview()
                    self.contentView.addSubview(firstView)
                    self.contentView.addSubview(secondView)
                    self.contentView.insertSubview(topView, atIndex: 0)
                    self.visiableView = [topView,firstView,secondView]
            })
        }
        
    }
    
    private func configureViewAtRow(row:Int,view:UIView){
        var topDelt = CGFloat(5 * row)
        var scale = CGFloat(1 - (CGFloat(2 - row) * 0.1))
        var viewheight = frame.size.height - marginVertical - 60
        var viewY = marginVertical + topDelt - (1 - scale) * viewheight * 0.5
        var viewFrame = CGRectMake(marginHorizontal, viewY, frame.size.width - 2 * marginHorizontal, viewheight)
        view.transform = CGAffineTransformIdentity
        view.frame = viewFrame
        view.transform = CGAffineTransformMakeScale(scale, scale)
    }
    
    func popToNext(){
        backgroundAnimationIn()
        contentAnimation()
    }
    
    private func contentAnimation(){
        let contentScaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        contentScaleAnimation.duration = preAnimateDuration
        contentScaleAnimation.toValue = 0.75
        contentScaleAnimation.fillMode = kCAFillModeForwards
        contentScaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        contentScaleAnimation.autoreverses = false
        contentScaleAnimation.removedOnCompletion = false
        
        contentView.layer.addAnimation(contentScaleAnimation, forKey: "scalesmall")
        executeAfterDelay(preAnimateDuration, clurse: {
            self.contentReverseAnimation()
        })
    }
    
    private func contentReverseAnimation(){
        let contentReverseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        contentReverseAnimation.duration = preAnimateDuration
        var values = Array<CGFloat>()
        for(var i = 0; i <= Int(preAnimateDuration * 60); i++){
            values.append(scaleForContentReverseAnimation(CGFloat(Float(i) / (Float(preAnimateDuration) * 60))))
        }
        contentReverseAnimation.values = values
        contentReverseAnimation.fillMode = kCAFillModeForwards
        contentReverseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        contentView.layer.addAnimation(contentReverseAnimation, forKey: "scalesmall")
    }
    
    private func scaleForContentReverseAnimation(progress:CGFloat) -> CGFloat{
        var diff = CGFloat(0.25)
        var res = 0.75 + diff * bounceEaseOut(progress)
        return res
    }
    
    private func backgroundAnimationIn(){
        let inAnimation = CAKeyframeAnimation(keyPath: "path")
        
        inAnimation.duration = preAnimateDuration
        inAnimation.fillMode = kCAFillModeForwards
        inAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        var pathValues = Array<CGPathRef>()
        for(var i = 0; i <= Int(preAnimateDuration * 60); i++){
            pathValues.append(pathForBackgroundIn(Float(Float(i) / (Float(preAnimateDuration) * 60))))
        }
        inAnimation.values = pathValues
        inAnimation.autoreverses = false
        inAnimation.removedOnCompletion = false
        inAnimation.delegate = self
        backgroundLayer.path = pathForBackgroundIn(1)
        
        backgroundLayer.addAnimation(inAnimation, forKey: "inAni")
        
        executeAfterDelay(preAnimateDuration, clurse: {
            self.backgroundAnimationReverses()
            self.expansionAnimation()
        })
    }
    
    private func backgroundAnimationReverses(){
        let reverseAnimation = CAKeyframeAnimation(keyPath: "path")
        reverseAnimation.duration = preAnimateDuration
        var rePathValues = Array<CGPathRef>()
        for(var i = 0; i <= Int(preAnimateDuration * 60); i++){
            rePathValues.append(pathForBackgroundReverse(Float(Float(i) / Float(preAnimateDuration * 60))))
        }
        reverseAnimation.values = rePathValues
        reverseAnimation.fillMode = kCAFillModeForwards
        reverseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        reverseAnimation.autoreverses = false
        reverseAnimation.removedOnCompletion = false
        backgroundLayer.addAnimation(reverseAnimation, forKey: "reAni")
    }
    
    private func pathForBackgroundReverse(progress:Float) -> CGPathRef{
        //var valuePorgress = CGFloat(0.5 * Float(a) * currentTime * currentTime)
        var valuePorgress = bounceEaseOut(CGFloat(progress))
        var controlPointTop = CGPointMake(width * 0.5, height * (0.25 - 0.25 * valuePorgress))
        var controlPointRight = CGPointMake(width * (0.75 + 0.25 * valuePorgress), height * 0.5)
        var controlPointBottom = CGPointMake(width * 0.5, height * (0.75 + 0.25 * valuePorgress))
        var controlPointLeft = CGPointMake(width * (0.25 - 0.25 * valuePorgress), height * 0.5)
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addQuadCurveToPoint(CGPointMake(width, 0), controlPoint: controlPointTop)
        path.addQuadCurveToPoint(CGPointMake(width, height), controlPoint: controlPointRight)
        path.addQuadCurveToPoint(CGPointMake(0, height), controlPoint: controlPointBottom)
        path.addQuadCurveToPoint(CGPointMake(0, 0), controlPoint: controlPointLeft)
        return path.CGPath
    }
    
    private func pathForBackgroundIn(progress:Float) -> CGPathRef{
        var valuePorgress = CGFloat(0.25 * progress)
        var controlPointTop = CGPointMake(width * 0.5, height * valuePorgress)
        var controlPointRight = CGPointMake(width * (1 - valuePorgress), height * 0.5)
        var controlPointBottom = CGPointMake(width * 0.5, height * (1 - valuePorgress))
        var controlPointLeft = CGPointMake(width * valuePorgress, height * 0.5)
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addQuadCurveToPoint(CGPointMake(width, 0), controlPoint: controlPointTop)
        path.addQuadCurveToPoint(CGPointMake(width, height), controlPoint: controlPointRight)
        path.addQuadCurveToPoint(CGPointMake(0, height), controlPoint: controlPointBottom)
        path.addQuadCurveToPoint(CGPointMake(0, 0), controlPoint: controlPointLeft)
        return path.CGPath
    }
    
    private func expansionAnimation(){
        var zoomTransform = CGAffineTransformMakeScale(1.2, 1.2)
        var firstView = visiableView[0]
        var secondView = visiableView[1]
        var topView = visiableView[2]
        UIView.animateWithDuration(preAnimateDuration, delay: 0.5 * preAnimateDuration, options: .CurveEaseOut, animations: {
            topView.transform = zoomTransform
            topView.alpha = 0.2
            }, completion: {finished in
                topView.alpha = 1
                self.configureViewAtRow(0, view: topView)
                topView.removeFromSuperview()
                secondView.removeFromSuperview()
                firstView.removeFromSuperview()
                self.contentView.addSubview(firstView)
                self.contentView.addSubview(secondView)
                UIView.animateWithDuration(self.preAnimateDuration, animations: {
                    self.configureViewAtRow(1, view: firstView)
                    self.configureViewAtRow(2, view: secondView)
                    }, completion: {finished in
                        self.contentView.insertSubview(topView, atIndex: 0)
                        self.visiableView = [topView,firstView,secondView]
                })
        })
        
    }
    
    private func executeAfterDelay(delayTime:NSTimeInterval,clurse:() -> Void
        ){
        let delay = dispatch_time(DISPATCH_TIME_NOW,
            Int64(delayTime * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            clurse()
        }
    }
    
    private func bounceEaseOut(p:CGFloat) -> CGFloat{
        if(p < 4/11.0){
            return (121 * p * p)/16.0
        }else if(p < 8/11.0){
            return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0
        }else if(p < 9/10.0){
            return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0
        }else{
            return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0
        }
    }
}


extension UIView{
    var x:CGFloat {
        get{
            return frame.origin.x
        }
        set{
            var f = frame
            f.origin.x = newValue
            frame = f
        }
    }
    var y:CGFloat {
        get{
            return frame.origin.y
        }
        set{
            var f = frame
            f.origin.y = newValue
            frame = f
        }
    }
    var width:CGFloat {
        get{
            return frame.size.width
        }
        set{
            var f = frame
            frame.size.width = newValue
            frame = f
        }
    }
    var height:CGFloat {
        get{
            return frame.size.height
        }
        set{
            var f = frame
            frame.size.height = newValue
            frame = f
        }
    }
    func removeAllSubViews(){
        for view in subviews{
            view.removeFromSuperview()
        }
    }
}
