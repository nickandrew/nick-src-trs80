program simass1(input,print);
var rv: array[0..20] of integer;
    ex: array[0..20] of real;
    i: integer;
    time: real;
    arrivetime: array[1..20] of real;
    departime: real;
    servetime: real;
    print: text;

function rnd(seed:integer):integer;
begin
    rnd:=(seed*11+251) mod 1000
end;

function exponential(rv:real;lambda:real):real;
begin
   exponential := -ln(1-rv)/lambda
end;

begin (* simulation assignment 1 program 1 *)
    rv[0] := 370;
    for i:=1 to 20 do begin
        rv[i] := rnd(rv[i-1]);
        ex[i] := exponential(rv[i]/1000,1);
        write(print,'R[',i:2,'] = ',rv[i]:3,'              ');
        writeln (print,'Ex[',i:2,'] = ',ex[i]:7:3);
    end;

(* simulate a queueing process *)

    time:=0;
    (* first customer arrives at time 0.000 *)
    arrivetime[1] := 0;
    for i:=2 to 20 do begin
        arrivetime[i]:=arrivetime[i-1] + ex[i]
    end;

    writeln(print,'Cust  Arrive  Served  Departed');
    for i:=1 to 20 do begin
        write(print,i:4);
        write(print,arrivetime[i]:8:3);
        servetime := arrivetime[i];  (* customer hopes *)
        if (time>arrivetime[i]) then begin
            servetime:=time
        end;
        write(print,servetime:8:3);
        departime:=servetime+1/6;   (* 10 second delay *)
        if (rv[i] mod 2 = 0) then
            (* takes a minute to be served *)
            departime := departime+1;
        time:=departime;
        write(print,departime:8:3);
        writeln(print)
    end
end.
