const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsAlloc();
    defer std.process.argsFree(args);

    var num_tasks: usize = 100_000;
    if (args.len > 1) {
        num_tasks = try std.fmt.parseInt(usize, args[1], 10);
    }

    const pool_size = if (num_tasks < 1000) num_tasks else 1000;
    var next_task: usize = 0;
    var remaining: usize = num_tasks;
    var lock = std.Threading.Mutex{};
    var cond = std.Threading.ConditionVariable{};
    var done = false;

    const worker = fn () void {
        while (!done) {
            lock.lock();
            const i = next_task;
            if (i >= num_tasks) {
                if (remaining == 1) {
                    remaining = 0;
                    done = true;
                    cond.broadcast();
                }
                lock.unlock();
                return;
            }
            next_task = i + 1;
            lock.unlock();

            const start = std.time.now();
            const deadline = start + std.time.ns_per_s * 10;
            while (std.time.now() < deadline) |_| {
                std.time.sleep(std.time.ns_per_s / 100);
            }

            lock.lock();
            remaining = remaining - 1;
            if (remaining == 0) {
                done = true;
                cond.broadcast();
            }
            lock.unlock();
        }
    };

    var threads = try allocator.alloc([]std.Thread, pool_size);
    defer allocator.free(threads);

    for (threads, 0..) |*t, i| {
        t.* = try std.Thread.spawn(8 * 1024 * 1024, worker, .{});
    }

    lock.lock();
    while (!done) {
        cond.wait(&lock, 100_000_000); // 100ms
    }
    lock.unlock();

    for (threads) |*t| {
        t.*join();
    }

    std.debug.print("All tasks completed\n", .{});
}
