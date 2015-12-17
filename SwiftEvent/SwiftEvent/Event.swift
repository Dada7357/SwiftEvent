//
//  Event.swift
//  AlamofireDemo
//
//  Created by Dada on 15/12/17.
//  Copyright © 2015年 Dada. All rights reserved.
//

import Foundation


import Foundation

public class Event<T: Hashable> {
    
    public typealias EventHandler = () -> ()
    
    private var eventHandlers = [T: Invocable]()
    
    public func raise(data: T) {
        eventHandlers[data]?.invoke()
    }
    
    func setTarget<U: AnyObject>(target: U, handler: (U) -> EventHandler, controlEvent: T) {
        eventHandlers[controlEvent] = EventHandlerWrapper(
            target: target, handler: handler)
    }
    
    func removeTargetForControlEvent(controlEvent: T) {
        eventHandlers[controlEvent] = nil
    }
}

private protocol Invocable: class {
    func invoke()
}

private class EventHandlerWrapper<T: AnyObject> : Invocable {
    weak var target: T?
    let handler: T -> () -> ()
    
    init(target: T?, handler: T -> () -> ()) {
        self.target = target
        self.handler = handler
    }
    
    func invoke() {
        if let t = target {
            handler(t)()
        }
    }
}