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

    var threads = try allocator.alloc([]std.Thread, num_tasks);
    defer allocator.free(threads);

    for (threads, 0..) |*t, _| {
        t.* = try std.Thread.spawn(8 * 1024 * 1024, worker, .{});
    }

    for (threads) |*t| {
        t.*join();
    }

    std.debug.print("All tasks completed\n", .{});
}

fn worker() void {
    std.time.sleep(std.time.ns_per_s * 10);
}
