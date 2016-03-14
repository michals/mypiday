# Cloudless My Pi Day

Clone of http://mypiday.com/ designed to work without any cloud backend.
It is proudly hosted on github pages, and relies only on CDN.

See live demo: http://michals.github.io/piday/

If cached (~14MiB) it would work offline.

Some of the data is precomputed and pushed to a webserver.
I used only y-cruncher to generate pi digits and some small scripts to generate the data.
Application fetches needed data and constructs pi drawing on canvas.

App is written in Dart (compiled to ES5) because I like this language.
In particular support for async/await, classes and libraries made it a very pleasant weekend project.

It's not as beautiful as original mypiday.com, because I don't know much about graphic design.
You are welcome to fork, play and send PRs.
