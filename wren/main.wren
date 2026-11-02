var numTasks = Num.fromString(System.args[1] ?: "100000") || 100000
var remaining = numTasks
var fiber = Fiber

for (i in 0...numTasks) {
    Fiber.new {
        Fiber.sleep(10000)
        remaining = remaining - 1
    }.start()
}

while (remaining > 0) {
    Fiber.sleep(100)
}

System.print("All tasks completed")
