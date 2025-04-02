//const importCwd = require('import-cwd');
//console.log(__dirname);
//console.log(process.cwd());
//console.log("importCwd: ", importCwd);
//const moduleNode = importCwd('./.build/Module.node');
//console.log("moduleNode: " + moduleNode);
//const NodeConsole = moduleNode.NodeConsole;
//console.log("NodeConsole: " + NodeConsole);
//const { NodeConsole, testNodeConsole, testLogger } = importCwd('./.build/Module.node');
const { NodeConsole } = require('/.build/Module.node');
//const { NodeConsole, testNodeConsole, testLogger } = require('nslogging/.build/Module.node');
//import { NodeConsole, testNodeConsole, testLogger } from './.build/Module.node'

console.log("NSLoggingExample...");

// Register the callback from Swift, including swift-log Logger info and higher messages
//const nodeConsole = new NodeConsole();
//nodeConsole.registerLogCallback((message) => {
//    console.log("Swift> " + message);
//}, "info");

//testLogger();       // Swift> info: Invoked Logger(label: "NSLogger").info from Swift!
//testNodeConsole();  // Swift> Invoked NodeConsole.log from Swift!
