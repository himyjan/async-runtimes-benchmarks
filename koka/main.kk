module Main

import Concurrency
import Prelude

main :: IO ()
main = do
    let numTasks = 100000
    sem <- newEmptyMVar
    remaining <- newIORef numTasks
    replicateM_ numTasks $ forkIO $ do
        threadDelay 10000000
        modifyIORef' remaining (\n -> n - 1)
        n <- readIORef remaining
        when (n == 0) $ putMVar sem ()
    takeMVar sem
    putStrLn "All tasks completed"
