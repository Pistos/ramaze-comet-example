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

#### Streaming

In streaming Comet, a connection between client and server is made, and data is pushed from server to client whenever it is available.  The connection remains open after each bit of data is transferred.  The example in this article does not implement this type of Comet.

#### Long polling

Long polling works like the "bad" polling design, except the server does not respond to the client until the data is ready.  As already mentioned, this results in fewer network connections while still maintaining low latency.

<h3 id="example">A Comet example in Ramaze</h3>

I'll exemplify Comet in Ramaze by building a web application that tails a file on the server and displays the lines on the web page as soon as they are available.  The full source code can be found [on github](http://github.com/Pistos/ramaze-comet-example/tree/master).  You are advised to clone or download from there so you can follow along.  I will not go over every line of code in this article.

#### Client

The web page is very simple.  It has this body:

<pre lang="html4strict">
<body>
  <h4>Tailer:</h4>
  <textarea id="tailer" rows="16" cols="80"></textarea>
</body>
</pre>

We use a &lt;textarea&gt; to hold the file lines, and give it an id, <code>tailer</code>.

In [the Javascript](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/public/main.js), we have a function called <code>get_more_lines</code>.  The client:

1. calls this function which
2. waits for data
3. receives the data
4. appends the data into the &lt;textarea&gt;
5. calls the function again (repeats from step 1)

#### Server