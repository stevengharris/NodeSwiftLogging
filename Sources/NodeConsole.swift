//
//  NodeConsole.swift
//  CodeLog
//
//  Created by Steven Harris on 3/22/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI

@NodeActor
@NodeClass final class NodeConsoleFacade {
    
    @NodeConstructor init() throws {}
    
    @NodeMethod func registerLogCallback(callback: NodeFunction) throws {
        NodeConsole.shared.logCallback = callback
    }

}

@NodeActor
final class NodeConsole {
    
    static let shared = NodeConsole()
    
    let nodeQueue: NodeAsyncQueue
    var logCallback: NodeFunction?
    
    init() {
        nodeQueue = try! NodeAsyncQueue(label: "nodeConsoleQueue")
    }
    
    func registerLogCallback(callback: NodeFunction) throws {
        logCallback = callback
    }
    
    func log(_ string: String) throws {
        guard let logCallback else { throw NSUtilsError.notRegistered("NodeConsole.shared.logCallback") }
        try nodeQueue.run {
            try logCallback.call([string])
        }
    }
}

enum NSUtilsError: Error {
    case notRegistered(_ callback: String)
}
