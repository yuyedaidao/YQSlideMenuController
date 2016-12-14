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

class YQSlideMenuController: UIViewController, UIGestureRecognizerDelegate {

    var leftMenuViewController: UIViewController?
    var contentViewController: UIViewController?
    var slideStyle: YQSlideStyle = .normal
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
    private lazy var tapGestureRecognizerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var edgePanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    init(contentViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.contentViewController = contentViewController
        self.leftMenuViewController = leftMenuViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.menuViewVisibleWidth = self.view.bounds.width - self.contentViewVisibleWidth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.menuViewContainer)
        self.view.addSubview(self.contentViewContainer)
        layoutViewEqualSuperView(view: self.menuViewContainer)
        layoutViewEqualSuperView(view: self.contentViewContainer)
        
        if let vc = self.leftMenuViewController {
            self.addViewController(vc, inView: self.menuViewContainer)
        }
        if let vc = self.contentViewController {
            self.addViewController(vc, inView: self.contentViewContainer)
        }
        
        self.contentViewContainer.addGestureRecognizer(self.edgePanGesture)
        self.contentViewContainer.addSubview(self.tapGestureRecognizerView)
        self.layoutViewEqualSuperView(view: self.tapGestureRecognizerView)
        self.tapGestureRecognizerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(gesture:))))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: helper
    func addViewController(_ controller: UIViewController, inView view: UIView) {
        self.addChildViewController(controller)
        view.addSubview(controller.view)
        layoutViewEqualSuperView(view: controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func layoutViewEqualSuperView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: view.superview, attribute: .leading, multiplier: 1, constant: 0))
        view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .top, multiplier: 1, constant: 0))
        view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view.superview, attribute: .width, multiplier: 1, constant: 0))
        view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: view.superview, attribute: .height, multiplier: 1, constant: 0))
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
                self.contentViewContainer.transform = CGAffineTransform(translationX: fingerMovedDistance, y: 0)
            case .scaleContent:
                self.menuViewContainer.transform = CGAffineTransform(translationX: (1 - delta) * (-self.menuViewVisibleWidth / 3), y: 0)
                let scale = 1 - (1 - self.minContentScale) * delta
                let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
                let translationTransform = CGAffineTransform(translationX: fingerMovedDistance * scale, y: 0)
                self.contentViewContainer.transform = scaleTransform.concatenating(translationTransform)
            }
            gesture.setTranslation(CGPoint.zero, in: self.view)
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
    
    //MARK: override
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
