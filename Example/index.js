const { NodeConsole, testLogger, testConsole } = require('./.build/Module.node');

// Get an instance of the NodeConsole class, a facade exposed in Module.node
const nodeConsole = new NodeConsole();

// Optionally, set and pass a logging configuration to be used.
// By default, it is {level: "debug", format: "medium"} without metadata.
// const loggingConfig = {
//     level: "info",                   // <- Set a minimum log level
//     format: "minimum",               // <- "medium by default"
//     metadata: {myKey : "myValue"}    // <- Pass a key and string value to accompany every log message
// }

// Register the callback from Swift
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);   // Make it obvious this message came from Swift
});     // Optionally, pass the stringified loggingConfig... JSON.stringify(loggingConfig));
console.log("Registered the NodeConsole.logCallback");

// Invoke the two test functions that execute and use the callback registered above and
// the SwiftLog backend that was bootstrapped.
testLogger();   // Swift> info: Invoked Logger(label: "NodeSwiftLogger").info from Swift!
testConsole();  // Swift> Invoked NodeConsole.log from Swift!
