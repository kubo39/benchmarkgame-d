import core.stdc.stdio;
import std.algorithm;
import std.conv : parse;
import std.format;
import std.parallelism;
import std.range : iota;
import std.string : toStringz;

enum minDepth = 4;

struct Node
{
    Node* left;
    Node* right;
}

Node* bottomUpTree(int depth)
{
    Node* node = new Node;
    if (depth > 0)
    {
        node.left = bottomUpTree(depth-1);
        node.right = bottomUpTree(depth-1);
    }
    return node;
}

int itemCheck(Node* node)
{
    if (node.left is null)
        return 1;
    return 1 + node.left.itemCheck() + node.right.itemCheck();
}

string inner(int depth, int iterations)
{
    auto sums = taskPool.workerLocalStorage(0);
    foreach (i; parallel(iota(0, iterations)))
        sums.get += bottomUpTree(depth).itemCheck();
    return format("%d\t trees of depth %d\t check: %d\n", iterations, depth, sums.toRange.sum());
}

void main(string[] args)
{
    const n = args.length > 1 ? parse!int(args[1]) : 10;
    const maxDepth = minDepth + 2 > n ? minDepth + 2 : n;
    {
        const depth = maxDepth + 1;
        const check = bottomUpTree(depth).itemCheck();
        printf("strech tree of depth %d\t check: %d\n", depth, check);
    }
    auto longLivedTree = bottomUpTree(maxDepth);
    foreach (halfDepth; iota(minDepth/2, maxDepth/2 + 1))
    {
        const depth = halfDepth * 2;
        auto iterations = 1 << (maxDepth - depth + minDepth);
        string s = inner(depth, iterations);
        printf(s.toStringz);
    }
    printf("long lived tree of depth %d\t check: %d\n", maxDepth, longLivedTree.itemCheck());
}
