const { NodeConsole, testConsole, NodeLogger, testLogger } = require('./.build/Module.node');

// Instantiate the NodeConsole, passing the callback
new NodeConsole((message) => {
    console.log(message);
});

// Optionally, set and pass a logging configuration to be used.
// const loggingConfig = {
//     level: "info",                   // <- "debug" by default
//     label: "MyLabel",                // <- "NodeSwiftLogger" by default
//     metadata: {myKey : "myValue"}    // <- Applied to every log message, null by default
// }

// Instantiate the NodeLogger, passing the callback
new NodeLogger(nsLogHandler)            // <- Pass `JSON.stringify(loggingConfig)` after callback

// A callback function to parse the LogSwift json and log it to the console
function nsLogHandler(json) {
    const data = JSON.parse(json);
    const metadata = (data.metadata) ? JSON.stringify(data.metadata) + ' ' : '';
    const date = new Date();
    // CA, because the only sane way to show a timestamp is yyyy-mm-dd, not US style mm/dd/yyyy
    const timestamp = date.toLocaleDateString('en-CA') + ' ' + date.toLocaleTimeString('en-CA', { hour12: false });
    console.log(timestamp + ' [' + data.level.toUpperCase() + '] ' + metadata + data.message);
};

// Invoke the two test functions that execute and cause the callbacks to be invoked from Swift
testConsole();  // Invoked NodeConsole.log from Swift!
testLogger();   // <Local en-CA timestamp> [INFO] Invoked logger.info from Swift!
