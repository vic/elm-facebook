# elm-facebook login example

This app implements a facebook login
and a graph API request to obtain
current user name.

## Use the SRC Luke

Be sure to look at `login.html` to see
how everything gets wired.

## Demo

```shell
# Compile the main app to js *ONLY*
elm make Main.elm --output elm.js

# Start a server, elm reactor will do
elm reactor

# Use localhost for sample FB app
open http://localhost:8000/login.html
```
