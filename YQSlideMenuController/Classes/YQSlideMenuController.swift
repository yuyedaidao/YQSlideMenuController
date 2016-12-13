//
//  YQSlideMenuController.swift
//  YQSlideMenuController
//
//  Created by Wang on 2016/12/12.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

enum YQSlideStyle {
    case normal
    case scaleContent
}

class YQSlideMenuController: UIViewController {

    private let leftMenuViewController: UIViewController
    private let contentViewController: UIViewController
    private var slideStyle: YQSlideStyle = .normal
    private var menuViewVisibleWidth: CGFloat = 0
    private var contentViewVisibleWidth: CGFloat = 80
    private var isMenuHidden = true
    private var isMenuMoving = false
    private var fingerMovedDistance: CGFloat = 0
    private var minContentScale: CGFloat = 0.8
    
    private lazy var menuViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var contentViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var gestureRecognizerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private let edgePanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gesture:)))
        return gesture
    }()
    
    init(contentViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.contentViewController = contentViewController
        self.leftMenuViewController = leftMenuViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.menuViewVisibleWidth = self.view.bounds.width - self.contentViewVisibleWidth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        func layoutViewEqualSuperView(view: UIView) {
            view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: view.superview, attribute: .leading, multiplier: 1, constant: 0))
            view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1, constant: 0))
            view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view.superview, attribute: .width, multiplier: 1, constant: 0))
            view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: view.superview, attribute: .height, multiplier: 1, constant: 0))
        }
        self.view.addSubview(self.menuViewContainer)
        self.view.addSubview(self.contentViewContainer)
        layoutViewEqualSuperView(view: self.menuViewContainer)
        layoutViewEqualSuperView(view: self.contentViewContainer)
        
        self.addChildViewController(self.leftMenuViewController)
        self.leftMenuViewController.view.frame = self.view.bounds
        self.menuViewContainer.addSubview(self.leftMenuViewController.view)
        layoutViewEqualSuperView(view: self.leftMenuViewController.view)
        self.leftMenuViewController.didMove(toParentViewController: self)
        
        self.addChildViewController(self.contentViewController)
        self.contentViewController.view.frame = self.view.bounds
        self.contentViewContainer.addSubview(self.contentViewController.view)
        layoutViewEqualSuperView(view: self.contentViewController.view)
        self.contentViewController.didMove(toParentViewController: self)
        
        self.gestureRecognizerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gesture:))))
        self.contentViewContainer.addSubview(self.gestureRecognizerView)
        layoutViewEqualSuperView(view: self.gestureRecognizerView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    //MARK: selector
    func panGestureRecognizer(gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: self.view)
        if gesture.state == .began {
            self.updateContentViewShadow()
            self.isMenuMoving = true
            fingerMovedDistance = isMenuHidden ? 0 : self.menuViewVisibleWidth
        } else if gesture.state == .changed {
            fingerMovedDistance += point.x//begin的距离就不算了，当做触发
            if fingerMovedDistance > self.menuViewVisibleWidth {
                fingerMovedDistance = self.menuViewVisibleWidth
            } else if fingerMovedDistance < 0 {
                fingerMovedDistance = 0
            }
            let delta = fingerMovedDistance / self.menuViewVisibleWidth
            switch slideStyle {
            case .normal:
                self.menuViewContainer.transform = CGAffineTransform(translationX: (1 - delta) * (-self.menuViewVisibleWidth / 3), y: 0)
                var frame = self.contentViewContainer.frame
                frame.origin.x = fingerMovedDistance
                self.contentViewContainer.frame = frame
                gesture.setTranslation(CGPoint.zero, in: self.view)
            case .scaleContent:
                //TODO:忘了这里是什么效果了
                print("还没实现，快点来实现")
                
            }
        } else if gesture.state == .ended {
            
        } else if gesture.state == .changed || gesture.state == .failed {
            
        }

    }
    
    func tapGestureRecognizer(gesture: UITapGestureRecognizer) {
    
    }
    
    func updateContentViewShadow() {
        let layer = self.contentViewContainer.layer
        let path = UIBezierPath(rect: layer.bounds)
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }
    
    func showViewController(viewController: UIViewController) {
        
    }
    
    func hideMenu() {
        
    }
    
    func showMenu() {
    
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
