//
//  Extensions.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit

extension UIView {
    
    var width:CGFloat {
        return frame.size.width
    }
    
    var height:CGFloat {
        return frame.size.height
    }
    
    var top:CGFloat {
        return frame.origin.y
    }
    
    var bottom:CGFloat {
        return frame.size.height+frame.origin.y
    }
    
    var left:CGFloat {
        return self.frame.origin.x
    }
    
    var right:CGFloat {
        return frame.size.width+frame.origin.x
    }
    
    func addSubviews(_ views:UIView...) {
        views.forEach({addSubview($0)})
    }
    
}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogIn")
}
