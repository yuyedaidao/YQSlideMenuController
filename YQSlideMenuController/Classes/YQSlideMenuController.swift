//
//  YQSlideMenuController.swift
//  YQSlideMenuController
//
//  Created by Wang on 2016/12/12.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

public enum YQSlideStyle {
    case normal
    case scaleContent
}

let kAnimationDuration: TimeInterval = 0.3
let kEdgeRecognizerDistance: CGFloat = 45

protocol YQSlideMenuControllerDelegate {
    func yq_navigationController() -> UINavigationController
}

public class YQSlideMenuController: UIViewController, UIGestureRecognizerDelegate {

    public var leftMenuViewController: UIViewController?
    public var contentViewController: UIViewController?
    public var slideStyle: YQSlideStyle = .normal
    private var menuViewVisibleWidth: CGFloat = 0
    private var contentViewVisibleWidth: CGFloat = 100
    private var isMenuHidden = true
    private var isMenuMoving = false
    private var fingerMovedDistance: CGFloat = 0
    private var minContentScale: CGFloat = 0.8
    private var priorGestures:[AnyClass] = [NSClassFromString("UILongPressGestureRecognizer")!]
    
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
        if #available(iOS 9.0, *) {
            if self.traitCollection.forceTouchCapability == .available {
                //self.traitCollection.
                self.priorGestures.append(NSClassFromString("_UIPreviewGestureRecognizer")!)
                self.priorGestures.append(NSClassFromString("_UIRevealGestureRecognizer")!)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.menuViewVisibleWidth = self.view.bounds.width - self.contentViewVisibleWidth
    }
    
    override public func viewDidLoad() {
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
    
    override public func didReceiveMemoryWarning() {
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
                let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: ((1 - (1 - self.minContentScale) * self.fingerMovedDistance / self.menuViewVisibleWidth) * 0.5 - 0.5) * self.view.bounds.width + self.fingerMovedDistance, ty: 0)
                self.contentViewContainer.transform = transform
            }
            gesture.setTranslation(CGPoint.zero, in: self.view)
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed{
            if fingerMovedDistance < self.menuViewVisibleWidth / 2 {
                //关闭菜单
                self.menuAnimate(show: false, duration: TimeInterval(fingerMovedDistance / self.menuViewVisibleWidth) * kAnimationDuration)
            } else {
                //打开菜单
                self.menuAnimate(show: true, duration: TimeInterval(1 - fingerMovedDistance / self.menuViewVisibleWidth) * kAnimationDuration)
            }
        }

    }
    
    func tapGestureRecognizer(gesture: UITapGestureRecognizer) {
        self.hideMenu()
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
    
    public func showViewController(viewController: UIViewController) {
        var nav: UINavigationController?
        if let delegate = self.contentViewController as? YQSlideMenuControllerDelegate {
            nav = delegate.yq_navigationController()
        } else {
            if let vc = self.contentViewController as? UINavigationController {
                nav = vc
            }
        }
        if let _ = nav {
            nav?.pushViewController(viewController, animated: true)
        }
    }
    
    public func hideMenu() {
        self.menuAnimate(show: false, duration: kAnimationDuration)
    }
    
    public func showMenu() {
        self.menuAnimate(show: true, duration: kAnimationDuration)
    }
    
    func menuAnimate(show: Bool, duration: TimeInterval) {
        var contentTransform: CGAffineTransform
        var menuTransform: CGAffineTransform
        switch slideStyle {
        case .normal:
            if show {
                contentTransform = CGAffineTransform(translationX: self.menuViewVisibleWidth, y: 0)
                menuTransform = CGAffineTransform.identity
            } else {
                contentTransform = CGAffineTransform.identity
                menuTransform = CGAffineTransform(translationX: -self.menuViewVisibleWidth / 3, y: 0)
            }
        case .scaleContent:
            if show {
                contentTransform = CGAffineTransform(a: self.minContentScale, b: 0, c: 0, d: self.minContentScale, tx: (self.minContentScale * 0.5  + 0.5) * self.view.bounds.width - self.contentViewVisibleWidth, ty: 0)
                menuTransform = CGAffineTransform.identity
            } else {
                contentTransform = CGAffineTransform.identity
                menuTransform = CGAffineTransform(translationX: -self.menuViewVisibleWidth / 3, y: 0)
            }
        }
        if duration > 0 {
            UIView.animate(withDuration: duration, animations: { 
                self.contentViewContainer.transform = contentTransform
                self.menuViewContainer.transform = menuTransform
            }, completion: { (finish) in
                self.isMenuMoving = false
                self.isMenuHidden = !show
                self.tapGestureRecognizerView.isHidden = !show
            })
        } else {
            self.contentViewContainer.transform = contentTransform
            self.menuViewContainer.transform = menuTransform
            self.isMenuMoving = false
            self.isMenuHidden = !show
            self.tapGestureRecognizerView.isHidden = !show
        }
    }
    
    //MARK: override
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isMenuHidden {
            let point = gestureRecognizer.location(in: gestureRecognizer.view)
            var nav: UINavigationController?
            if point.x <= kEdgeRecognizerDistance {
                if let delegate = self.contentViewController as? YQSlideMenuControllerDelegate {
                    nav = delegate.yq_navigationController()
                } else {
                    if let _nav = self.contentViewController as? UINavigationController {
                        nav = _nav
                    }
                }
                if let navigationController = nav {
                    if navigationController.childViewControllers.count < 2 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.edgePanGesture {
            for obj in self.priorGestures {
                if otherGestureRecognizer.isKind(of: obj) {
                    return true
                }
            }
        }
        return false
    }
 
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.edgePanGesture {
            return true
        }
        return false
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
