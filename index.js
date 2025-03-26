// CodeLogLib entry points defined in CodeLogVS.swift
const { testNode, setWorkspace, workspace, workspaceStatus, setBundleName, bundleName, version, testiCloud, ckIdentifier } = require("./.build/Module.node");

// Needed to access CodeLogCLI for entry points needing restricted entitlements
const child_process = require('child_process');
const fs = require('node:fs');
const path = require('path');

//console.log("Set workspace: " + setWorkspace("/Users/steve/CodeLogWorkspace"));
//console.log("Set bundleName: " + setBundleName("CodeLogTest"));

// Exercise the CodeLogLib entry points, none of which requires entitlements
console.log(testNode());
console.log("* " + version);
console.log("* Workspace: " + workspace);
console.log("* Workspace status...")
console.log(workspaceStatus);
console.log("* Bundle name: " + bundleName);
const container = ckIdentifier("CodeLogTest");  // Does not depend on iCloud entitlements
console.log("* ckIdentifier: " + container);

// Invoke the CLI command to access iCloud. The CLI executable has to reside within
// an app that has the proper iCloud entitlements.
try {
    // The post-build-cli script executed after CodeLogCLI builds places a symbolic
    // link in the .build/CodeLogVS directory which links to the executable
    // inside CodeLogCLI.app. However, the link is relative to where it resides,
    // so we have to join it with the .build directory to spawn it.
    const cli = path.join(".build", fs.readlinkSync('./.build/CodeLogCLI'));
    const child = child_process.spawnSync(cli, ['-i']);
    
    // Note the contents of stdout is from print("\(CKHelper.shared.state)") inside
    // of CodeLogTool.run(). The async command being run doesn't return a result.
    console.log("* iCloud state: " + child.stdout.toString().trim()); // The state coming from CodeLogLib
} catch (err) {
    console.log('Error. Build CodeLogCLI before running "node index.js"... ' + err);
}
console.log("Done.")
