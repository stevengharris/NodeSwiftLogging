//
//  NodeModuleExports.swift
//  NSLogging
//
//  Created by Steven Harris on 2025/03/26.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI
import NSLogging    // Access to NodeConsoleFacade and NodeConsole

#NodeModule(exports: [
    "NodeConsole": NodeConsoleFacade.deferredConstructor,
])
