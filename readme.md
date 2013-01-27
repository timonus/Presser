# Presser

A tool for cheating at [Letterpress](http://www.atebits.com/letterpress/).

There's one warning in main.m, which you need to fill in with the configuration of the board you're playing.

The app loads in the Letterpress dictionary, forms a tree out of it along with the provided game state, then scores every word in the tree. The result is a list of words sorted by highest point value. Scoring is naive to blocking off letters or removing blocks from letters the other player has gotten. It simply tries to get the maximum score given the current board state.

It's pretty ugly, sorry. I wrote it quickly to test some ideas.

## Sample Input

![](http://f.cl.ly/items/293V0z2z1w3t370N0J2g/board.png)

In main.m, this board would be represented as

```
        NSString *characters = @"zerggixwodlhvhzxthktmkzur";
        int values[] = {
            1,0,2,0,2,
            0,1,2,2,0,
            1,1,0,0,1,
            1,0,0,1,0,
            2,1,1,0,1
        };
```

## Not Working?

Presser depends on the [Letterpress Words repository](https://github.com/atebits/Words), don't forget to update your submodules

```
git submodule update --init
```