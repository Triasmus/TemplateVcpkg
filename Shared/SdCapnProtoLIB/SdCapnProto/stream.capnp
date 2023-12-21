@0xfcc282204db5df1b;

interface MyInterface {
    streamingCall @0 (callback :Callback, count :UInt64, size :UInt64) -> ();

    interface Callback {
        sendChunk @0 (chunk :Text) -> stream;
        done @1 ();
    }
}