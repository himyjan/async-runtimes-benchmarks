program Bench;

uses
  Classes, SysUtils, SyncObjs;

var
  NumTasks: Integer = 100000;
  Remaining: Integer;
  Event: TEvent;
  i: Integer;

procedure Worker(Param: Pointer);
begin
  Sleep(10000);
  Dec(Remaining);
  if Remaining = 0 then
    Event.SetEvent;
end;

begin
  if ParamCount > 0 then
    NumTasks := StrToInt(ParamStr(1));

  Remaining := NumTasks;
  Event := TEvent.Create(nil, False, False, '');

  for i := 1 to NumTasks do
    BeginThread(nil, 0, @Worker, nil, 0, nil);

  Event.WaitFor(INFINITE);
  WriteLn('All tasks completed');
  Event.Free;
end.
