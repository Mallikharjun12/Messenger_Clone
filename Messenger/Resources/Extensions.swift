//
//  Extensions.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit

extension UIView {
    
    var width:CGFloat {
        return self.frame.size.width
    }
    
    var height:CGFloat {
        return self.frame.size.height
    }
    
    var top:CGFloat {
        return self.frame.origin.y
    }
    
    var bottom:CGFloat {
        return self.frame.size.height+self.frame.origin.y
    }
    
    var left:CGFloat {
        return self.frame.origin.x
    }
    
    var right:CGFloat {
        return self.frame.size.width+self.frame.origin.x
    }
    
    func addSubviews(_ views:UIView...) {
        views.forEach({self.addSubview($0)})
    }
    
}
