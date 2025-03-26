# NSUtils

I've been using [node-swift](https://github.com/kabiroberai/node-swift) in a project that accesses my Swift code from a VSCode extension (aka, a node server). It works amazingly well, but I have occasionally had difficulty with something going wrong on the Swift side, and have found no easy way to debug. I found myself longing for even a simple way to log to the node console, like I could use `print` for in moments of desperation in Swift when I cannot get to a proper debugger.

# Installation

1. Clone `https://github.com/stevengharris/NSUtils.git` and then run `npm install` from the `NSUtils` directory. The install takes a long time, mainly because it builds `swift-syntax`.

2. 