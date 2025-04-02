//const { NodeConsole, testNodeConsole, testLogger } = require('./build/Module.node');
//const { NodeConsole, testNodeConsole, testLogger } = require('nslogging/.build/Module.node');
import { NodeConsole, testNodeConsole, testLogger } from './.build/Module.node'

console.log("NSLoggingExample...");

// Register the callback from Swift, including swift-log Logger info and higher messages
const nodeConsole = new NodeConsole();
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);
}, "info");

testLogger();       // Swift> info: Invoked Logger(label: "NSLogger").info from Swift!
testNodeConsole();  // Swift> Invoked NodeConsole.log from Swift!
