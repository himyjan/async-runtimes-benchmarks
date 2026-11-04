import sys
import asyncio

num_tasks = int(sys.argv[1]) if len(sys.argv) > 1 else 100_000

async def worker():
    await asyncio.sleep(10)

async def main():
    tasks = [asyncio.create_task(worker()) for _ in range(num_tasks)]
    await asyncio.gather(*tasks)
    print("All tasks completed")

asyncio.run(main())
