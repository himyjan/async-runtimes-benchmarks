using System;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static int numTasks = 100000;
    static int remaining;
    static ManualResetEventSlim sem;

    static void Worker()
    {
        Thread.Sleep(10000);
        if (Interlocked.Decrement(ref remaining) == 0)
            sem.Set();
    }

    static void Main(string[] args)
    {
        if (args.Length > 0) numTasks = int.Parse(args[0]);
        remaining = numTasks;
        sem = new ManualResetEventSlim(false);

        var tasks = new Task[numTasks];
        for (int i = 0; i < numTasks; i++)
            tasks[i] = Task.Factory.StartNew(Worker);

        Task.WaitAll(tasks);
        Console.WriteLine("All tasks completed");
    }
}
