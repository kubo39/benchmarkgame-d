// The Computer Language Benchmakrs Game
// http://benchmakrsgame.alioth.debian.org/
//
// dmd -mcpu=native -O -inline -boundscheck=off binary_trees.d

import core.stdc.stdio;
import std.algorithm : sum;
import std.conv : parse;
import std.format : format;
import std.parallelism;
import std.range : iota;
import std.string : toStringz;

enum minDepth = 4;

struct Node
{
    Node* left;
    Node* right;
}

Node* bottomUpTree(int depth) nothrow pure
{
    auto node = new Node;
    if (depth > 0)
    {
        node.left = bottomUpTree(depth-1);
        node.right = bottomUpTree(depth-1);
    }
    return node;
}

int itemCheck(const(Node)* node) @nogc nothrow pure
{
    if (node.left is null)
        return 1;
    return 1 + node.left.itemCheck() + node.right.itemCheck();
}

string inner(int depth, int iterations)
{
    auto sums = taskPool.workerLocalStorage(0);
    foreach (_; parallel(iota(0, iterations)))
        sums.get += bottomUpTree(depth).itemCheck();
    return format("%d\t trees of depth %d\t check: %d\n", iterations, depth, sums.toRange.sum());
}

void main(string[] args)
{
    immutable n = args.length > 1 ? parse!int(args[1]) : 10;
    immutable maxDepth = minDepth + 2 > n ? minDepth + 2 : n;
    {
        immutable depth = maxDepth + 1;
        immutable check = bottomUpTree(depth).itemCheck();
        printf("stretch tree of depth %d\t check: %d\n", depth, check);
    }
    const longLivedTree = bottomUpTree(maxDepth);
    string[] messages;
    foreach (const halfDepth; iota(minDepth/2, maxDepth/2 + 1))
    {
        immutable depth = halfDepth * 2;
        immutable iterations = 1 << (maxDepth - depth + minDepth);
        const message = inner(depth, iterations);
        messages ~= message;
    }
    foreach (message; messages)
        printf(message.toStringz);
    printf("long lived tree of depth %d\t check: %d\n", maxDepth, longLivedTree.itemCheck());
}
