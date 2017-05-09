// ldc2 -O3 threadrng.d

import std.stdio;
import std.concurrency;

void start(int nTasks, int token)
{
    // 最後に送るTidは必ずメインスレッド
    Tid tid = thisTid;

    // id: nのスレッドはid: n+1のスレッドに送る
    foreach (id; 1 .. nTasks) {
        Tid currTid = spawn(&roundtrip, tid, thisTid, id, nTasks);
        // 次に生成するスレッドは現在のスレッドIDに送信する
        tid = currTid;
    }

    // メインスレッドは最後のIDを持つスレッドに送信
    Tid firstTid = spawn(&roundtrip, tid, thisTid, nTasks, nTasks);

    while (token > 0) {
        send(firstTid, token);
        token = receiveOnly!int();
    }
}

void roundtrip(Tid tid, Tid ownerTid, int id, int nTasks)
{
    int token;
    while (true) {
        receive(
                (int _token) {
                    token = _token;
                });

        if (token == 1) {
            writefln("id: %d", id);
            send(ownerTid, token - 1);
            break;
        }
        else
            send(tid, token - 1);
        if (token <= nTasks)
            break;
    }
}

void main(string[] args)
{
    auto token = 1000;
    auto nTasks = 503;
    start(nTasks, token);
}
