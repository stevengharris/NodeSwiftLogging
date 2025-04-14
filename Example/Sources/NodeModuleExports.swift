//
//  NodeModuleExports.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 2025/03/26.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI
import NodeSwiftLogging     // Access to NodeConsole and NodeLogger

#NodeModule(exports: [
    "NodeConsole": NodeConsole.deferredConstructor,
    "NodeLogger" : NodeLogger.deferredConstructor,
    "testConsole": try NodeFunction { _ in
        NodeConsole.log("Invoked NodeConsole.log from Swift!")
        return
    },
    "testLogger": try NodeFunction { _ in
        // NodeLogger.backend provides access to the NodeSwiftLogger backend
        let logger = NodeLogger.backend;
        logger.info("Invoked logger.info from Swift!")
        return
    },
])
