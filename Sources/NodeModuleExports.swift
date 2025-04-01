//
//  NodeModuleExports.swift
//  NSLogging
//
//  Created by Steven Harris on 2025/03/26.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI
import Logging

#NodeModule(exports: [
    "NodeConsole": NodeConsoleFacade.deferredConstructor,
    "testNodeConsole": try NodeFunction { _ in
        NodeConsole.log("Invoked NodeConsole.log from Swift!")
        return
    },
    "testLogger": try NodeFunction { _ in
        Logger(label: "NSLogger").info("Invoked Logger(label: \"NSLogger\").info from Swift!")
        return
    },
])
