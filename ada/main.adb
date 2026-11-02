with Ada.Text_IO;  use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Command_Line; use Ada.Command_Line;

procedure Main is
   Num_Tasks : Natural := 100_000;

   protected type Counter is
      entry Wait_For_All (N : in Natural);
      procedure Task_Done;
   private
      Count : Natural := 0;
   end Counter;

   protected body Counter is
      entry Wait_For_All (N : in Natural) when Count = N is
      begin
         null;
      end Wait_For_All;

      procedure Task_Done is
      begin
         Count := Count + 1;
      end Task_Done;
   end Counter;

   task type Worker (C : access Counter);
   task body Worker (C : access Counter) is
   begin
      delay 10.0;
      C.Task_Done;
   end Worker;

   Done : Counter;
   type Task_Access is access Worker;
   Tasks  : array (1 .. Num_Tasks) of Task_Access;
begin
   if Argument_Count > 0 then
      Num_Tasks := Natural'Value(Argument(1));
   end if;

   for I in Tasks'Range loop
      Tasks(I) := new Worker (Done'Access);
   end loop;

   Done.Wait_For_All (Num_Tasks);
   Put_Line ("All tasks completed");
end Main;
