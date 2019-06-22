// The Computer Language Benchmakrs Game
// http://benchmakrsgame.alioth.debian.org/
//
// dmd -mcpu=native -O -inline binarytrees.d

import core.stdc.stdio;
import std.concurrency;
import std.conv : parse;

void start(int nTasks, int token)
{
    // メインスレッドは最後のIDを持つスレッドに送信
    Tid tid = spawn(&roundtrip, thisTid, 1 /* id */, nTasks);
    // 次に生成するスレッドはひとつ前のidのスレッドに送信
    foreach_reverse (id; 2 .. (nTasks + 1))
        tid = spawn(&roundtrip, tid, id, nTasks);

    while (token > 0)
    {
        tid.send(token);
        token = receiveOnly!int();
    }
}

void roundtrip(Tid tid, int id, int nTasks)
{
    while (true)
    {
        auto token = receiveOnly!int;
        if (token == 1)
        {
            printf("id: %d\n", id);
            ownerTid.send(token - 1);
            break;
        }
        else
            tid.send(token - 1);
        if (token <= nTasks)
            break;
    }
}

void main(string[] args)
{
    auto token = args.length > 1 ? parse!int(args[1]) : 1000;
    auto nTasks = args.length > 2 ? parse!int(args[2]) : 503;
    start(nTasks, token);
}
