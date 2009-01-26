In this blog post, I describe how to do (one kind of) Comet in a Ramaze web application using jQuery.  I begin by glossing over Comet, what problem Comet tries to solve, and some other related concepts.  Those of you already familiar with Comet can jump right to
[the example](#example).

### What's Comet?

From the Wikipedia article on Comet in web programming:

> In web development, Comet is a neologism to describe a web application model in which a long-held HTTP request allows a web server to push data to a browser, without the browser explicitly requesting it. Comet is an umbrella term for multiple techniques for achieving this interaction. All methods have in common that they rely on browser-native technologies such as JavaScript

### Why Comet?

In traditional web applications, the process flow is:

1. time passes until the web browser (the client) wants data
2. client requests it from server
3. server gives data to client
4. repeat from step 1

As web developers got more clever, they wondered how they might get the server to give data to the client when the *server* wanted to give it, not when the client wanted to get it.  So they came up with a flow like this:

1. client asks for data from server, if any (client polls server)
2. if server doesn't have data ready, server tells client no data is available
3. client waits a "short while"; repeats from step 1
4. if server has data, server gives data to client
5. repeat from step 1

However, when developing an application with this design, you had to make a tradeoff:

 * Frequent polling, paying the creation and teardown costs making the network connections; or
 * Infrequent polling, resulting in the client interface being delayed in reflecting actual readiness of data

Comet tries to address both problems, so no tradeoff has to be made.  With Comet, you can poll infrequently but still get the data to the client very soon after the server is ready to give it.

### Two kinds of Comet

There are roughly two kinds of Comet:

### Producers and consumers

<h3 id="example">A Comet example in Ramaze</h3>

