const { NodeConsole, testNodeConsole, testLogger } = require("./.build/Module.node");

// Register the callback from Swift, including swift-log Logger info and higher messages
const nodeConsole = new NodeConsole();
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);
}, "info");

testLogger();       // Swift> info: Invoked Logger(label: "NSLogger").info from Swift!
testNodeConsole();  // Swift> Invoked NodeConsole.log from Swift!
