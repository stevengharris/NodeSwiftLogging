//
//  NodeModuleExports.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 2025/03/26.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI
import Logging              // Access to Logger
import NodeSwiftLogging     // Access to NodeConsoleFacade and NodeConsole

#NodeModule(exports: [
    "NodeConsole": NodeConsoleFacade.deferredConstructor,
    "testConsole": try NodeFunction { _ in
        NodeConsole.log("Invoked NodeConsole.log from Swift!")
        return
    },
    "testLogger": try NodeFunction { _ in
        Logger(label: "NodeSwiftLogger").info("Invoked Logger(label: \"NodeSwiftSLogger\").info from Swift!")
        return
    },
])
