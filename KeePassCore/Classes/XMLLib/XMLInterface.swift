//
//  XMLInterface.swift
//  XML2Swift
//
//  Created by igork on 9/9/19.
//

import Foundation

private final class XMLDispatchOncePrivate {
   private var lock = os_unfair_lock()
   private var isPerformed = false
   public func perform(block: () -> Void) {
      os_unfair_lock_lock(&lock)
      if !isPerformed {
         block()
         isPerformed = true
      }
      os_unfair_lock_unlock(&lock)
   }
}

private var dispatchOnce = XMLDispatchOncePrivate()

func setupXMLParsing() {
    dispatchOnce.perform {
        xmlInitParser();
    }
}



