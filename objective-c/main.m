#import <Foundation/Foundation.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSUInteger numTasks = 100000;
        if (argc > 1) {
            numTasks = (NSUInteger)atoi(argv[1]);
        }

        __block NSUInteger remaining = numTasks;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        for (NSUInteger i = 0; i < numTasks; i++) {
            dispatch_async(queue, ^{
                [NSThread sleepForTimeInterval:10.0];
                if (__builtin_atomic_sub(&remaining, 1) == 1) {
                    dispatch_semaphore_signal(sema);
                }
            });
        }

        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"All tasks completed");
    }
    return 0;
}
