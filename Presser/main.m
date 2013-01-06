//
//  Presser
//
//  Created by Tim Johnsen on 1/1/13.
//  Copyright (c) 2013 tijo. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Nodes

typedef struct Node {
    struct Node **nodes;
    BOOL final;
} Node;

Node *newNode() {
    Node *node = (Node *)malloc(sizeof(Node));
    node->nodes = (Node **)malloc(sizeof(Node*) * 26);
    for (int i = 0 ; i < 26 ; i++) {
        node->nodes[i] = NULL;
    }
    node->final = NO;
    return node;
}

void freeNode(Node *node) {
    if (node != NULL) {
        for (int i = 0 ; i < 26 ; i++) {
            freeNode(node->nodes[i]);
        }
        free(node);
    }
}

#pragma mark - Trees

void addWordToTree(NSString *word, Node *rootNode) {
    Node *currentNode = rootNode;
    for (int i = 0 ; i < [word length] ; i++) {
        char character = [word characterAtIndex:i];
        int index = character - 'a';
        if (currentNode->nodes[index] == NULL) {
            currentNode->nodes[index] = newNode();
        }
        currentNode = currentNode->nodes[index];
    }
    currentNode->final = YES;
}

void printTreeWithAccumulatedString(Node *rootNode, NSString *accumulatedString) {
    if (rootNode != NULL) {
        if (rootNode -> final) {
            NSLog(@"%@", accumulatedString);
        }
        for (int i = 0 ; i < 26 ; i++) {
            if (rootNode->nodes[i] != NULL) {
                printTreeWithAccumulatedString(rootNode->nodes[i], [accumulatedString stringByAppendingFormat:@"%c", 'a' + i]);
            }
        }
    }
}

void printTree(Node *rootNode) {
    printTreeWithAccumulatedString(rootNode, @"");
}

#pragma mark - Dictionary Loading

#warning Fill in the path to the Letterpress dictionary files below
NSString *const path = @"/Users/tim/Desktop/o";

NSArray *dictionary() {
    NSMutableArray *dictionary = [[NSMutableArray alloc] init];
    for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil]) {
        NSString *filePath = [path stringByAppendingPathComponent:filename];
        NSString *file = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *words = [file componentsSeparatedByString:@"\n"];
        for (NSString *word in words) {
            if ([word length] > 0) {
                [dictionary addObject:word];
            }
        }
    }
    return dictionary;
}

BOOL canConstructWordWithLetters(NSString *word, NSArray *letters) {
    NSMutableArray *mutableLetters = [letters mutableCopy];
    for (int i = 0 ; i < [word length] ; i++) {
        BOOL success = NO;
        for (int j = 0 ; j < [mutableLetters count] ; j++) {
            if ([word characterAtIndex:i] == [[mutableLetters objectAtIndex:j] characterAtIndex:0]) {
                [mutableLetters removeObjectAtIndex:j];
                success = YES;
                break;
            }
        }
        if (!success) {
            return NO;
        }
    }
    return YES;
}

Node *treeGivenDictionaryAndAvailableLetters(NSArray *dictionary, NSArray *letters) {
    Node *rootNode = newNode();
    
    for (NSString *word in dictionary) {
        if (canConstructWordWithLetters(word, letters)) {
            addWordToTree(word, rootNode);
        }
    }
    
    return rootNode;
}

#pragma mark - Cheating (Calcluating and sorting scores given state)

void scoreGivenNodeAndPointsForCharactersWithAccumulatedStringAndPoints(Node *node, NSMutableDictionary *pointedCharacters, NSString *string, int points, NSMutableDictionary *results) {
    if (node->final) {
        if (![results objectForKey:@(points)]) {
            [results setObject:[NSMutableArray array] forKey:@(points)];
        }
        [[results objectForKey:@(points)] addObject:string];
    }
    
    for (NSString *key in [pointedCharacters allKeys]) {
        char character = [key characterAtIndex:0];
        int index = character - 'a';
        int pointsForCharacter = [[[pointedCharacters objectForKey:key] objectAtIndex:0] intValue];
        
        if (node->nodes[index] != NULL) {
            NSMutableArray *tmp = [pointedCharacters objectForKey:key];

            if ([[pointedCharacters objectForKey:key] count] > 1) {
                [pointedCharacters setObject:[tmp mutableCopy] forKey:key];
                [[pointedCharacters objectForKey:key] removeObjectAtIndex:0];
            } else {
                [pointedCharacters removeObjectForKey:key];
            }
            
            scoreGivenNodeAndPointsForCharactersWithAccumulatedStringAndPoints(node->nodes[index], pointedCharacters, [string stringByAppendingFormat:@"%c", character], points + pointsForCharacter, results);
            
            [pointedCharacters setObject:tmp forKey:key];
        }
    }
}

NSMutableDictionary *scoreGivenTreeAndPointsForCharacters(Node *tree, NSMutableDictionary *pointedCharacters) {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    scoreGivenNodeAndPointsForCharactersWithAccumulatedStringAndPoints(tree, pointedCharacters, @"", 0, results);
    return results;
}

#pragma mark - Helpers

void assureSortOrderInPointedCharacters(NSMutableDictionary *pointedCharacters) {
    for (NSString *key in [pointedCharacters allKeys]) {
        [(NSMutableArray *)[pointedCharacters objectForKey:key] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue] > [obj2 intValue]) {
                return NSOrderedAscending;
            } else if ([obj2 intValue] > [obj1 intValue]) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
    }
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSArray *theDictionary = dictionary();
        NSLog(@"Loaded %lu words...", [theDictionary count]);
        
#warning Fill in your values here
        // 'characters' is a 25-character long lowercase representation of the board being played
        // 'values' is the point value of each space on the board (1 for 'white', 2 for 'light red', 0 otherwise - OR come up with your own scheme)
        NSString *characters = @"abcdeabcdeabcdeabcdeabcde";
        int values[] = {
            1,1,1,1,1,
            1,1,1,1,1,
            1,1,1,1,1,
            1,1,1,1,1,
            1,1,1,1,1
        };
        
        // FOR EXAMPLE: The board here http://f.cl.ly/items/293V0z2z1w3t370N0J2g/board.png would be
//        NSString *characters = @"zerggixwodlhvhzxthktmkzur";
//        int values[] = {
//            1,0,2,0,2,
//            0,1,2,2,0,
//            1,1,0,0,1,
//            1,0,0,1,0,
//            2,1,1,0,1
//        };
        
        NSMutableArray *board = [NSMutableArray array];
        for (int i = 0 ; i < [characters length] ; i++) {
            [board addObject:[NSString stringWithFormat:@"%c", [characters characterAtIndex:i]]];
        }
        Node *rootNode = treeGivenDictionaryAndAvailableLetters(theDictionary, board);
        
        NSMutableDictionary *pointedCharacters = [NSMutableDictionary dictionary];
        for (int i = 0 ; i < [characters length] ; i++) {
            NSString *key = [NSString stringWithFormat:@"%c", [characters characterAtIndex:i]];
            if (![pointedCharacters objectForKey:key]) {
                [pointedCharacters setObject:[NSMutableArray array] forKey:key];
            }
            [[pointedCharacters objectForKey:key] addObject:@(values[i])];
        }
        
        // ensure sort order above!!
        assureSortOrderInPointedCharacters(pointedCharacters);
        
        NSMutableDictionary *results = scoreGivenTreeAndPointsForCharacters(rootNode, pointedCharacters);
        
        while ([results count]) {
            int max = 0;
            for (NSNumber *key in [results allKeys]) {
                if ([key intValue] > max) {
                    max = [key intValue];
                }
            }
            
            NSLog(@"%d", max);
            NSLog(@"%@", [[results objectForKey:@(max)] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 length] > [obj2 length]) {
                    return NSOrderedAscending;
                } else if ([obj2 length] > [obj1 length]) {
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }]);
            
            [results removeObjectForKey:@(max)];
        }
        
        freeNode(rootNode);
    }
    return 0;
}

