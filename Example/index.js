const { NodeConsole, testLogger, testConsole } = require('./.build/Module.node');

const nodeConsole = new NodeConsole();

// Register the callback from Swift
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);   // Make it obvious this message came from Swift
});
console.log("Registered the NodeConsole.logCallback");

// Bootstrap the SwiftLog LoggingSystem, showing logging of .info level or higher
nodeConsole.bootstrapLoggingSystem("info");
console.log("Bootstrapped the LoggingSystem");

// Invoke the two test functions that execute and use the callback registered above and
// the SwiftLog backend that was bootstrapped.
testLogger();   // Swift> info: Invoked Logger(label: "NodeSwiftLogger").info from Swift!
testConsole();  // Swift> Invoked NodeConsole.log from Swift!
