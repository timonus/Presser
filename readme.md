# Presser

A tool for cheating at [Letterpress](http://www.atebits.com/letterpress/).

There are two #warnings in main.m, one needs to be replaced with the path to the Letterpress dictionary directory (which you can grab, it's the 'o' directory in the app's .ipa) and the other needs to be replaced with state about the game being played.

The app loads in the Letterpress dictionary, forms a tree out of it along with the provided game state, then scores every word in the tree. The result is a list of words sorted by highest point value. Scoring is naive to blocking off letters or removing blocks from letters the other player has gotten. It simply tries to get the maximum score given the current board state.

It's pretty ugly, sorry. I wrote it quickly to test some ideas.