In this blog post, I describe how to do (one kind of) Comet in a [Ramaze](http://ramaze.net) web application using [jQuery](http://jquery.com).  I begin by glossing over Comet, what problem Comet tries to solve, and some other related concepts.  Those of you already familiar with Comet can jump right to
[the example](#example).

To get the most out of this article, you should be comfortable with Ramaze, HTML and Javascript.  If you need to get up to speed on Ramaze, learn more [at the Ramaze website](http://ramaze.net/learn).

### What's Comet?

From [the Wikipedia article on Comet in web programming](http://en.wikipedia.org/wiki/Comet_(programming)):

> In web development, Comet is a neologism to describe a web application model in which a long-held HTTP request allows a web server to push data to a browser, without the browser explicitly requesting it. Comet is an umbrella term for multiple techniques for achieving this interaction. All methods have in common that they rely on browser-native technologies such as JavaScript

### Why Comet?

In traditional web applications, the process flow is:

![Traditional web app flow](/wp-content/uploads/ramaze-comet-example/traditional-flow.png)

1. time passes until the web browser (the client) wants data
2. client requests data from server
3. server gives data to client
4. repeat from step 1

As web developers got more clever, they wondered how they might get the server to give data to the client when the *server* wanted to give it, not when the client wanted to get it.  So they came up with a flow like this:

![Naive polling flow](/wp-content/uploads/ramaze-comet-example/naive-polling.png)

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

![Long polling flow](/wp-content/uploads/ramaze-comet-example/long-polling.png)

<h2 id="example">A Comet example in Ramaze</h2>

I'll exemplify Comet in Ramaze by building a web application that tails a file on the server and displays the lines on the web page as soon as they are available.  The full source code can be found [on github](http://github.com/Pistos/ramaze-comet-example/tree/master).  You are advised to clone or download from there so you can follow along.  I will not go over every line of code in this article.

I also make use of another data producer which manveru provided.  The application demonstrates that the very same process and implementation can be applied with different producers.

### Client

[The web page](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/view/tail.xhtml) is very simple.  It has this body:

<pre lang="html4strict">
<body>
  <h4>Tailer:</h4>
  <textarea id="tailer" rows="16" cols="80"></textarea>
</body>
</pre>

We'll use a &lt;textarea&gt; to hold the file lines, and give it an id, <code>tailer</code>.

In [the Javascript](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/public/main.js), we have a function called <code>get_more_lines</code>.  The client:

1. calls this function which
2. waits for data
3. receives the data
4. appends the data into the &lt;textarea&gt;
5. calls the function again (repeats from step 1)

### Server

[The interface page](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/view/tail.xhtml) (located at the path <code>/tail</code>) is just static HTML, so it needs no controller code.  But let's examine [the controller code](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/src/main.rb) to see how the server side gives data to clients.

As you saw [in the client code](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/public/main.js#L17), the tailer data is retrieved from the path <code>/next_tailer_lines</code>.  In the controller, <code>next_tailer_lines</code> calls a more generic <code>next_lines</code> method, which has this code in it:

<pre lang="ruby">
60.times do
  lines = producer.new_lines( session.session_id )
  if lines.any?
    Ramaze::Log.debug "New data!"
    return lines
  end

  Ramaze::Log.debug "Waiting for data..."
  sleep 1
end
</pre>

When there is a request for <code>next_lines</code>, the server checks the server-side producer for more data.  If there is no new data, rather than returning any response to the client, the server continues to poll the producer.  They key thing to note here is that the server is doing the polling server-side.  The client is merely waiting for the server to respond to the single request -- no polling is going on between client and server while data is unavailable.

If and when the data becomes available from the producer, the server gives that data to the client right away.

On a basic level that's all you need for Comet!

1. A URI for the client to retrieve data from
2. A client-side loop
3. Server-side polling

Try out this example yourself!  Grab the code with

  git clone git://github.com/Pistos/ramaze-comet-example.git

(or download it with the "download" button
 [on github](http://github.com/Pistos/ramaze-comet-example/tree/master)).

Install the <code>file-tail</code> gem, and then open up a <code>ramaze-comet-example.log</code> file in the same directory as <code>start.rb</code>.  Fill it with some sample text.

Then run <code>start.rb</code> and browse to [http://localhost:7001/tail](http://localhost:7001/tail).  You should see the last 10 lines of your <code>ramaze-comet-example.log</code> file.  Now, with the web page open, add some more lines to the file (don't forget to save if you're using an editor to add lines), and then look at your browser; the new lines should appear (after a tiny delay).

### Details

#### Server-side timeout

You may wonder why we [loop only 60 times](http://github.com/Pistos/ramaze-comet-example/blob/8336ca003822eade42ee1609c4859f55747501c6/src/main.rb#L11) instead of infinitely polling for data.  While this would be possible, it is not practical to do so because the server will continue to poll even if the client disconnects (such as if the browser tab is closed, or the page is refreshed).  It's better to time out the polling and return empty data.  If the client is gone, communications cease, and the server can return to idling, waiting for more clients.  If the client is still around, it will reinitiate a fresh network connection.  But that's why this technique is called "long polling" and not "infinitely long polling".  In contrast with the naive polling implementation, the polls are less frequent and their durations are much longer.

In this example, we loop 60 times, waiting one second per iteration.  You can obviously tweak these numbers for your own needs in your application; sleep less or more; loop fewer or more times for a shorter or longer server-side timeout.  The tradeoff with longer server-side timeouts is that your application is doing a little extra work for nothing for clients that have disconnected.

#### Browser connection limit

You should also be aware that most browsers limit the number of connections to a server (typically only 2).  If you keep one connection open for Comet, that only leaves one other one available, so normal operations like parallel fetching of images, CSS files, etc. will be slowed down.  That also limits you to only one Comet connection.

A common workaround for this issue is to create subdomains on a domain (usually pointing to the same server as the domain), so the browser is tricked into thinking it is making connections to different servers; each domain or subdomain is given a full set of connections to work with.  You could, for example, have a subdomain comet.mydomain.com for Comet connections, and use mydomain.com for normal HTTP requests.

#### The Javascript in detail

For those who are interested, I'll explain the Javascript in greater detail.  Let's look at
[the get_more_lines function](http://github.com/Pistos/ramaze-comet-example/blob/c28c972d05827dffeeb1804768b1a71aba3a7546/public/main.js#L1):

<pre lang="javascript">
$.get(
    data_uri,
    function( data ) {
        if( data != '' ) {
            $( receiver_id ).append( data + "\n" );
            var receiver = $( receiver_id ).get( 0 );
            receiver.scrollTop = receiver.scrollHeight;
        }
        setTimeout( get_more_lines( receiver_id, data_uri ), 0 );
    }
);
</pre>

The first line is the call to jQuery's [get](http://docs.jquery.com/Ajax/jQuery.get#urldatacallbacktype) function.  This issues an HTTP GET request.  The first argument is the URI to call.  The second argument is a callback function used to process the server response.

Inside the callback function, we have a conditional to check whether we actually got data, or the server timed out waiting for the producer to produce new data.  If we have data, then we <code>append</code> the data to the jQuery element (or document element, if you prefer) which we reference by the given id string.  Then we use <code>scrollTop</code> and <code>scrollHeight</code> to auto-scroll the &lt;textarea&gt; to the bottom as new lines are fetched.

The last line of the callback function calls <code>get_more_lines</code> again.  The reason we use <code>setTimeout</code> is because if we called <code>get_more_lines</code> directly, that would be recursion, which runs the risk of consuming memory as each step of recursion grows the call stack.

#### Alternative producer

Browse to [http://localhost:7001/chat](http://localhost:7001/chat) to see the same Comet code work with a different data producer.  New "chat" lines are added to a channel at random intervals, and the browser is updated with the new lines as they come.
