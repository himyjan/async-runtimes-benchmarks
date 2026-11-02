module Main

import Prelude
import Data.List (replicate)
import Control.Concurrent (forkIO, threadDelay, newMVar, modifyMVar_, readMVar)
import Data.IORef (newIORef, readIORef, writeIORef, atomicModifyIORef')

main :: IO ()
main = do
    args <- getArgs
    let numTasks = case args of
            (n:_) -> read n
            _     -> 100000
    remaining <- newIORef numTasks
    sem <- newEmptyMVar
    replicateM_ numTasks $ forkIO $ do
        threadDelay 10000000
        modifyIORef' remaining (\n -> n - 1)
        n <- readIORef remaining
        when (n == 0) $ putMVar sem ()
    takeMVar sem
    putStrLn "All tasks completed"
