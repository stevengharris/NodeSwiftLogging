//
//  NodeConsole.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 3/22/25.
//

import NodeAPI
import Logging

@NodeClass public final class NodeConsole {

    /// The singleton `NodeConsole`
    private static var console: NodeConsole?

    /// The queue to run the callback on (see https://github.com/kabiroberai/node-swift/issues/17)
    private let nodeQueue: NodeAsyncQueue

    /// The NodeFunction that was passed from node.js when instantiating the NodeConsole.
    private let callback: NodeFunction
    
    /// Log a message in the node.js console using the `console` singleton.
    ///
    /// Note this is the only public method of NodeConsole other than `init`.
    ///
    /// This method can can be called from anywhere because `console.log` will be run
    /// async on @NodeActor.
    public static func log(_ message: String) {
        Task { @NodeActor in
            try? console?.log(message)
        }
    }
    
    /// Create an instance of NodeConsole, keeping that instance in a static singleton `console`
    /// that can be used via `NodeConsole.log` which in turn executes the `callback`.
    ///
    /// We also initialize the `nodeQueue` callback queue to use for async calls back into node.js
    /// from anywhere.
    ///
    /// In node.js, you would have done something like this (where `NodeConsole` is imported from
    /// `Module.node`):
    ///
    ///     NodeConsole((message) => {
    ///         console.log(message);
    ///     });
    @NodeActor
    @NodeConstructor
    public init(callback: NodeFunction) throws {
        nodeQueue = try NodeAsyncQueue(label: "nodeConsoleQueue")
        self.callback = callback
        Self.console = self
    }
    
    /// Run the `callback` on the `nodeQueue`, passing the `message`.
    private func log(_ message: String) throws {
        try nodeQueue.run {
            try callback.call([message])
        }
    }

}
