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
    @objc optional func sizeForRow(view:PlayfulTrampolineEffectView,row:Int) -> CGSize
    @objc optional func didSelectAtRow(view:PlayfulTrampolineEffectView,row:Int)
}

class PlayfulTrampolineEffectView: UIView {
    
    private var contentView = UIView()
    private var backgroundLayer = CAShapeLayer()
    private var preAnimateDuration = TimeInterval(0.3)
    private var visiableView = Array<UIView>()
    var beginLocation = CGPoint(x:0, y:0)
    var marginHorizontal = CGFloat(15)
    var marginVertical = CGFloat(30)
    var currentRow = Int(2)
    override var backgroundColor:UIColor?{
        didSet{
            if backgroundColor != UIColor.clear{
                contentView.backgroundColor = backgroundColor!
                backgroundLayer.fillColor = backgroundColor!.cgColor
                backgroundColor = UIColor.clear
            }
        }
    }
    
    override var frame:CGRect{
        didSet{
            if frame.size.width < marginHorizontal * 2 || frame.size.height < marginVertical * 2{
                let e = NSException(name: NSExceptionName(rawValue: "SizeError"), reason: "The width is too small", userInfo: nil)
                e.raise()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutCustomViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        layoutCustomViews()
    }
    
    private func layoutCustomViews(){
        superview?.layoutIfNeeded()
        contentView.frame = bounds
        contentView.backgroundColor = backgroundColor
        backgroundLayer.fillColor = backgroundColor?.cgColor
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0, y:0))
        path.addLine(to: CGPoint(x:width, y:0))
        path.addLine(to: CGPoint(x:width, y:height))
        path.addLine(to: CGPoint(x:0, y:height))
        path.addLine(to: CGPoint(x:0, y:0))
        backgroundLayer.strokeColor = UIColor.clear.cgColor
        backgroundLayer.path = path.cgPath
        backgroundLayer.frame = layer.bounds
        layer.addSublayer(backgroundLayer)
        addSubview(contentView)
        
        for i in 0...2{
            var imageView = UIImageView()
            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
            configureViewAtRow(row: i, view: imageView)
            visiableView.append(imageView)
            contentView.addSubview(imageView)
            imageView.image = UIImage(named: "\(i + 1)")
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(_:)))
        contentView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func initDefaultView(){
        
    }
    
    func panAction(_ sender:UIPanGestureRecognizer){
        if sender.state == .began{
            beginLocation = sender.location(in: contentView)
        }else if sender.state == .changed{
            panGestureRecoginzerChanged(offset:sender.location(in: contentView).x)
        }else{
            panGestureRecoginzerEnded(offset:sender.location(in : contentView).x)
        }
    }
    
    func panGestureRecoginzerChanged(offset:CGFloat){
        let firstView = visiableView[0]
        let secondView = visiableView[1]
        let topView = visiableView[2]
        var deltWidth:CGFloat
        let offsetX = offset - beginLocation.x
        if offsetX > 0{
            deltWidth = contentView.width - beginLocation.x
            let progress = offsetX / deltWidth
            makeTransformForView(view: topView, progress: progress, direction: 1, scale: 1)
            makeTransformForView(view: secondView, progress: progress, direction: 1, scale: 0.9)
            makeTransformForView(view: firstView, progress: progress, direction: 1, scale: 0.8)
        }else{
            deltWidth = beginLocation.x
            let progress = -offsetX / deltWidth
            makeTransformForView(view: topView, progress: progress, direction: -1, scale: 1)
            makeTransformForView(view: secondView, progress: progress, direction: -1, scale: 0.9)
            makeTransformForView(view: firstView, progress: progress, direction: -1, scale: 0.8)
        }
    }
    
    func makeTransformForView(view:UIView,progress:CGFloat,direction:CGFloat,scale:CGFloat){
        let rotationAngle = progress * CGFloat(.pi * Double(direction) * 0.15 * Double(1 - (1 - scale) * 4))
        let rotationTransForm = CGAffineTransform(scaleX: scale, y: scale).concatenating(CGAffineTransform(rotationAngle: rotationAngle))
        let translationTransForm = CGAffineTransform(translationX: progress * direction * contentView.width * (1 - (1 - scale) * 3), y: 0)
        let fullTransForm = rotationTransForm.concatenating(translationTransForm)
        view.transform = fullTransForm
    }
    
    func panGestureRecoginzerEnded(offset:CGFloat){
        let firstView = visiableView[0]
        let secondView = visiableView[1]
        let topView = visiableView[2]
        var deltWidth:CGFloat
        var progress:CGFloat
        let offsetX = offset - beginLocation.x
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
            if topView.transform.isIdentity == false{
                UIView.animate(withDuration: preAnimateDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: {
                    topView.transform = CGAffineTransform.identity
                    secondView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    firstView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: {finished in
                })
            }
        }else{
            let currTransform = topView.transform
            let translationTransform = CGAffineTransform(translationX: direction * contentView.width, y: 0)
            let fullTransForm = currTransform.concatenating(translationTransform)
            UIView.animate(withDuration: preAnimateDuration, animations: {
                topView.transform = fullTransForm
                topView.alpha = 0
                self.configureViewAtRow(row: 1, view: firstView)
                self.configureViewAtRow(row: 2, view: secondView)
            }, completion: {finished in
                topView.alpha = 1
                self.configureViewAtRow(row: 0, view: topView)
                topView.removeFromSuperview()
                secondView.removeFromSuperview()
                firstView.removeFromSuperview()
                self.contentView.addSubview(firstView)
                self.contentView.addSubview(secondView)
                self.contentView.insertSubview(topView, at: 0)
                self.visiableView = [topView,firstView,secondView]
            })
        }
        
    }
    
    private func configureViewAtRow(row:Int,view:UIView){
        let topDelt = CGFloat(5 * row)
        let scale = CGFloat(1 - (CGFloat(2 - row) * 0.1))
        let viewheight = frame.size.height - marginVertical - 60
        let viewY = marginVertical + topDelt - (1 - scale) * viewheight * 0.5
        let viewFrame = CGRect(x:marginHorizontal, y:viewY, width:frame.size.width - 2 * marginHorizontal, height:viewheight)
        view.transform = CGAffineTransform.identity
        view.frame = viewFrame
        view.transform = CGAffineTransform(scaleX: scale, y: scale)
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
        contentScaleAnimation.isRemovedOnCompletion = false
        
        contentView.layer.add(contentScaleAnimation, forKey: "scalesmall")
        executeAfterDelay(delayTime: preAnimateDuration, clurse: {
            self.contentReverseAnimation()
        })
    }
    
    private func contentReverseAnimation(){
        let contentReverseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        contentReverseAnimation.duration = preAnimateDuration
        var values = Array<CGFloat>()
        for i in 0...Int(preAnimateDuration * 60){
            values.append(scaleForContentReverseAnimation(progress: CGFloat(Float(i) / (Float(preAnimateDuration) * 60))))
        }
        contentReverseAnimation.values = values
        contentReverseAnimation.fillMode = kCAFillModeForwards
        contentReverseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        contentView.layer.add(contentReverseAnimation, forKey: "scalesmall")
    }
    
    private func scaleForContentReverseAnimation(progress:CGFloat) -> CGFloat{
        let diff = CGFloat(0.25)
        let res = 0.75 + diff * bounceEaseOut(p: progress)
        return res
    }
    
    private func backgroundAnimationIn(){
        let inAnimation = CAKeyframeAnimation(keyPath: "path")
        
        inAnimation.duration = preAnimateDuration
        inAnimation.fillMode = kCAFillModeForwards
        inAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        var pathValues = Array<CGPath>()
        
        for i in 0...Int(preAnimateDuration * 60) {
            pathValues.append(pathForBackgroundIn(progress: Float(Float(i) / (Float(preAnimateDuration) * 60))))
        }
        
        inAnimation.values = pathValues
        inAnimation.autoreverses = false
        inAnimation.isRemovedOnCompletion = false
        inAnimation.delegate = self as? CAAnimationDelegate
        backgroundLayer.path = pathForBackgroundIn(progress: 1)
        
        backgroundLayer.add(inAnimation, forKey: "inAni")
        
        executeAfterDelay(delayTime: preAnimateDuration, clurse: {
            self.backgroundAnimationReverses()
            self.expansionAnimation()
        })
    }
    
    private func backgroundAnimationReverses(){
        let reverseAnimation = CAKeyframeAnimation(keyPath: "path")
        reverseAnimation.duration = preAnimateDuration
        var rePathValues = Array<CGPath>()
        
        for i in 0...Int(preAnimateDuration * 60) {
            rePathValues.append(pathForBackgroundReverse(progress: Float(Float(i) / Float(preAnimateDuration * 60))))
        }
        reverseAnimation.values = rePathValues
        reverseAnimation.fillMode = kCAFillModeForwards
        reverseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        reverseAnimation.autoreverses = false
        reverseAnimation.isRemovedOnCompletion = false
        backgroundLayer.add(reverseAnimation, forKey: "reAni")
    }
    
    private func pathForBackgroundReverse(progress:Float) -> CGPath{
        //var valuePorgress = CGFloat(0.5 * Float(a) * currentTime * currentTime)
        let valuePorgress = bounceEaseOut(p: CGFloat(progress))
        let controlPointTop = CGPoint(x:width * 0.5, y:height * (0.25 - 0.25 * valuePorgress))
        let controlPointRight = CGPoint(x:width * (0.75 + 0.25 * valuePorgress), y:height * 0.5)
        let controlPointBottom = CGPoint(x:width * 0.5, y:height * (0.75 + 0.25 * valuePorgress))
        let controlPointLeft = CGPoint(x:width * (0.25 - 0.25 * valuePorgress), y:height * 0.5)
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0, y:0))
        path.addQuadCurve(to: CGPoint(x:width, y:0), controlPoint: controlPointTop)
        path.addQuadCurve(to: CGPoint(x:width, y:height), controlPoint: controlPointRight)
        path.addQuadCurve(to: CGPoint(x:0, y:height), controlPoint: controlPointBottom)
        path.addQuadCurve(to: CGPoint(x:0, y:0), controlPoint: controlPointLeft)
        return path.cgPath
    }
    
    private func pathForBackgroundIn(progress:Float) -> CGPath{
        let valuePorgress = CGFloat(0.25 * progress)
        let controlPointTop = CGPoint(x:width * 0.5, y:height * valuePorgress)
        let controlPointRight = CGPoint(x:width * (1 - valuePorgress), y:height * 0.5)
        let controlPointBottom = CGPoint(x:width * 0.5, y:height * (1 - valuePorgress))
        let controlPointLeft = CGPoint(x:width * valuePorgress, y:height * 0.5)
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0, y:0))
        path.addQuadCurve(to: CGPoint(x:width, y:0), controlPoint: controlPointTop)
        path.addQuadCurve(to: CGPoint(x:width, y:height), controlPoint: controlPointRight)
        path.addQuadCurve(to: CGPoint(x:0, y:height), controlPoint: controlPointBottom)
        path.addQuadCurve(to: CGPoint(x:0, y:0), controlPoint: controlPointLeft)
        return path.cgPath
    }
    
    private func expansionAnimation(){
        let zoomTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        let firstView = visiableView[0]
        let secondView = visiableView[1]
        let topView = visiableView[2]
        UIView.animate(withDuration: preAnimateDuration, delay: 0.5 * preAnimateDuration, options: [], animations: {
            topView.transform = zoomTransform
            topView.alpha = 0.2
        }, completion: {finished in
            topView.alpha = 1
            self.configureViewAtRow(row: 0, view: topView)
            topView.removeFromSuperview()
            secondView.removeFromSuperview()
            firstView.removeFromSuperview()
            self.contentView.addSubview(firstView)
            self.contentView.addSubview(secondView)
            UIView.animate(withDuration: self.preAnimateDuration, animations: {
                self.configureViewAtRow(row: 1, view: firstView)
                self.configureViewAtRow(row: 2, view: secondView)
            }, completion: {finished in
                self.contentView.insertSubview(topView, at: 0)
                self.visiableView = [topView,firstView,secondView]
            })
        })
        
    }
    
    private func executeAfterDelay(delayTime:TimeInterval,clurse:@escaping () -> Void
        ){
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
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
            let f = frame
            frame.size.width = newValue
            frame = f
        }
    }
    var height:CGFloat {
        get{
            return frame.size.height
        }
        set{
            let f = frame
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

