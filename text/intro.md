## Hi there.
<p class = "lead">This is `tRakt` or `tRakt_shiny` or whatever (naming stuff is hard).</p>

<p class = "lead">It's a tool to look up tv shows from <a href = 'http://trakt.tv'>trakt.tv</a> <sup><small>which y'all should use anyway</small></sup> and receive some more or less fancy data, including plots with reasonable amounts of fancyness.</p>

### How do you even stuff

* Enter a show title in the search box below 
* **Or** select one from the cache and leave the search box empty
* You can fiddle around with the plot with the inputs on the right
* Or just look at the dataTables, idunno

**Note**: The search API on trakt's side is a little wonky right now, so searching for example for `the americans 2013` will fail. I've implemented a workaraound for this which allows you to use the show's *slug*.  
Example: Enter it like this `trakt:the-americans-2013`, `trakt:game-of-thrones`, …  
The *slug* usually consists of a show's name, separated by - and, if needed, the year it first aired.

<small>Also, pls tell me about bugs 'n stuff, k?</small>
