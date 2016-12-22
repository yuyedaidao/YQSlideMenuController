//
//  UIViewController-Extension.swift
//  YQSlideMenuController
//
//  Created by Wang on 2016/12/22.
//  Copyright © 2016年 Wang. All rights reserved.
//

import UIKit

extension UIViewController {
    var slideMenuController: YQSlideMenuController? {
        var vc: UIViewController? = self
        while vc != nil {
            if vc!.isKind(of: YQSlideMenuController.self) {
                return vc as? YQSlideMenuController
            } else {
                vc = vc!.parent
            }
        }
        return nil;
    }
}
