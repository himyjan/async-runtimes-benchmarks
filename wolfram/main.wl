(* Wolfram Language benchmark - ParallelTable *)
numTasks = If[$CommandLine[[2]] =!= "", ToExpression[$CommandLine[[2]]], 100000];

ParallelTable[
    Pause[10],
    {i, 1, numTasks},
    Method -> "ItemsPerEvaluation" -> 1
];

Print["All tasks completed"];
