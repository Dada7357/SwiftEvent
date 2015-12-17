//
//  UIControl+Extension.swift
//  AlamofireDemo
//
//  Created by Dada on 15/12/16.
//  Copyright © 2015年 Dada. All rights reserved.
//

import Foundation
import UIKit

public class ClosureWrapper : NSObject
{
    let _callback : Void -> Void
    init(callback : Void -> Void) {
        _callback = callback
    }
    
    public func invoke()
    {
        _callback()
    }
}

extension UIControlEvents: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}

public class UIControlEventHelper: NSObject {
    
    weak var control: UIControl?
    let event: Event<UIControlEvents>
    
    init(control uiControl: UIControl) {
        control = uiControl
        event = Event<UIControlEvents>()
        
        super.init()
        
        uiControl.addTarget(self, action: "handleTouchUpInside", forControlEvents: .TouchUpInside)
    }
    
    public func handleTouchUpInside() {
        event.raise(.TouchUpInside)
    }
    
}


var AssociatedObjectHandle: UInt8 = 0

extension UIControl
{
    public func addAction(forControlEvents events: UIControlEvents, withCallback callback: Void -> Void)
    {
        let wrapper = ClosureWrapper(callback: callback)
        addTarget(wrapper, action:"invoke", forControlEvents: events)
        // as @newacct said in comment, we need to retain wrapper object
        // this only support 1 target, you can use array to support multiple target objects
        objc_setAssociatedObject(self, &AssociatedObjectHandle, wrapper,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private struct AssociatedKeys {
        static var EventHelperKey = "EventHelperKey"
    }
    
    public var controlEvent: Event<UIControlEvents> {
        if let eventHelper = objc_getAssociatedObject(self, &AssociatedKeys.EventHelperKey) as? UIControlEventHelper {
            return eventHelper.event
        }
        
        let eventHelper = UIControlEventHelper(control: self)
        objc_setAssociatedObject(self, &AssociatedKeys.EventHelperKey, eventHelper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return eventHelper.event
    }

}
