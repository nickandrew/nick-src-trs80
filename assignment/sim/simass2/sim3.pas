program stats(input,output,out1,out2,print3,print4);


(* Calculate statisctics from output of Queue Manager     *)
(* Reads arrival, queue delay & exit times from files     *)
(* 'out1' & 'out2' (BOTH INPUT FILES) ... out1 is queue1  *)
(* Writes results to 'print3' and raw figures to 'print4' *)

const
       TheWorst    = 50;
       worstarr    = 51;    (* size of worst time arrays *)
       students    = 500;
       normals     = 450;
       problems    = 50;
       s1arr       = 501;   (* size of s1 = students + 1 *)
       s2arr       = 51;    (* size of s2 = problems + 1 *)
       twoqueues   = true;  (* false if only one queue *)

type norptype = (normal,problem);

     q1data  = record
                  arrtime  : real6;  (* save memory *)
                  maindesk : real6;  (* save memory *)
               end;

     q2data  = record
                  depart1  : real;
                  probdesk : real;
               end;

     q1type  = record
                  norp     : norptype;
                  arrtime  : real;
                  maindesk : real;
                  depart1  : real;
               end;

     q2type  = record
                  arrtime  : real;  (* not ordered *)
                  depart1  : real;  (* ordered *)
                  probdesk : real;
                  depart2  : real;
               end;

var
        s1 : array[1..s1arr] of q1data;
        s2 : array[1..s2arr] of q2data;
  stud1rec : q1type;
  stud2rec : q2type;
      out1 : file of q1type;
      out2 : file of q2type;
    print3 : text;
    print4 : text;
         s : integer;
   thistud : integer;
  maintot , proctot  : real;    (* all students *)
  maintotn, proctotn : real;    (* normal students only *)
  maintotp, proctotp : real;    (* problems only *)
  maintotw, proctotw : real;    (* Worst case *)
  maintime, proctime : real;    (* scratchpads *)
     q1max : integer;           (* maximum length of q1 *)
     q2max : integer;
 worstmain : array[1..worstarr] of real;
 worstproc : array[1..worstarr] of real;

(*----------------------------------------------------------*)

procedure initialise;
var i : integer;
begin
    rewrite(print3);
    rewrite(print4);

    maintot  := 0.0;
    proctot  := 0.0;
    maintotn := 0.0;
    proctotn := 0.0;
    maintotp := 0.0;
    proctotp := 0.0;
    maintotw := 0.0;
    proctotw := 0.0;

    for i:=1 to worstarr do begin
        worstmain[i] := 0.0;
        worstproc[i] := 0.0;
    end;

end;

(*----------------------------------------------------------*)

(* Update two arrays of length 50 for the maximum wait times*)
procedure worst10percent;
var i, j : integer;
begin
(* work on worstmain ... worst main desk delay array *)
    i:=1;
(* find place in descending array *)
    while (i<=TheWorst) and (worstmain[i]>=maintime) do begin
        i := i + 1;
    end;

    if (i < TheWorst) then begin  (* move low values right *)
        for j:=TheWorst-1 downto i do
            worstmain[j+1] := worstmain[j];
    end;

    if (i <= TheWorst) then
        worstmain[i] := maintime;  (* replace value *)

(* do same for worstproc array  *)
    i:=1;
    while (i<=TheWorst) and (worstproc[i]>=proctime) do begin
        i := i + 1;
    end;

    if (i < TheWorst) then begin
        for j:=TheWorst-1 downto i do
            worstproc[j+1] := worstproc[j];
    end;

    if (i <= TheWorst) then
        worstproc[i] := proctime;

end;  (* worst10percent *)

(*----------------------------------------------------------*)

procedure queue1length;      (* calculate/update length q1 *)
var q1len   : integer;
    deskpos : integer;
    st      : integer;
    q1tot   : real;          (* it gets a bit big *)
begin
    q1max   := 0;
    q1tot   := 0.0;
    deskpos := 1;
    writeln(print4,'No.  Arrives  Mn-Desk   Q1');
    writeln(print4,'---  -------  -------  ---');
    for st:=1 to students do begin
        while (deskpos < s1arr) and
         (s1[st].arrtime >= s1[deskpos].maindesk) do
            deskpos := deskpos + 1;

        q1len := st - deskpos + 1;

        if (q1len > q1max) then q1max := q1len;
        q1tot := q1tot + q1len;

        writeln(print4,st:3,s1[st].arrtime:9:3,
                s1[st].maindesk:9:3,q1len:5);
    end;
    writeln(print3,'Maximum Queue 1 length =',q1max:5);
    writeln(print3,'Average Queue 1 length =',
            q1tot/students:5:1);
end;

(*----------------------------------------------------------*)

procedure queue2length;      (* calculate/update length q2 *)
var q2len   : integer;
    deskpos : integer;
    st      : integer;
    q2tot   : real;
begin
    q2max   := 0;
    q2tot   := 0;
    deskpos := 1;
    writeln(print4);
    writeln(print4,'No.  Arrives  Pr-Desk   Q2');
    writeln(print4,'---  -------  -------  ---');
    for st:=1 to problems do begin
        while (deskpos < s2arr) and
         (s2[st].depart1 >= s2[deskpos].probdesk) do
            deskpos := deskpos + 1;

        q2len := st - deskpos + 1;
        if (q2len > q2max) then q2max := q2len;
        q2tot := q2tot + q2len;

        writeln(print4,st:3,s2[st].depart1:9:3,
                s2[st].probdesk:9:3,q2len:5);
    end;
    writeln(print3,'Maximum length Queue 2 =',q2max:5);
    writeln(print3,'Average length Queue 2 =',
            q2tot/problems:5:1);
end;

(*----------------------------------------------------------*)

begin   (* Simulation assignment 2 stats calculator *)

    initialise;

(* read data for all students, sum 6 total delay times *)
(* also save delays in s1/s2, find worst 10% times     *)

    for s:=1 to students do begin
        read(out1,stud1rec);

        (* save queue 1 delay data *)
        s1[s].arrtime  := stud1rec.arrtime;
        s1[s].maindesk := stud1rec.maindesk;

        maintime := stud1rec.maindesk - stud1rec.arrtime;
        proctime := stud1rec.depart1 - stud1rec.arrtime;

        maintot  := maintot + maintime;
        if (stud1rec.norp = normal) then begin
            proctot  := proctot + proctime;
            maintotn := maintotn + maintime;
            proctotn := proctotn + proctime;
        end else begin
            maintotp := maintotp + maintime;
        end;

        if (twoqueues = false) and (stud1rec.norp = problem)
        then begin
            (* problems depart after q1 not q2 anymore *)
            proctot  := proctot  + proctime;
            proctotp := proctotp + proctime;
        end;

(* Update 10% of students with greatest wait times *)

        worst10percent;

    end;  (* loop for each normal and problem *)

(* read in queue2 information for problems students only *)

    if (twoqueues) then begin
        for s:=1 to problems do begin
            read(out2,stud2rec);

            (* save queue 2 delay data *)
            s2[s].depart1  := stud2rec.depart1;
            s2[s].probdesk := stud2rec.probdesk;

            (* update proctot, proctotp *)
            maintime := 0.0;       (* fool "worst10percent" *)
            (* maintot already updated by above routine     *)
            proctime := stud2rec.depart2 - stud2rec.arrtime;

            proctot  := proctot  + proctime;
            proctotp := proctotp + proctime;

            worst10percent;   (* update worst 10 % *)
        end;
    end;

(* calculate total wait times for worst 10% of students *)

    for s:=1 to TheWorst do begin
        maintotw := maintotw + worstmain[s];
        proctotw := proctotw + worstproc[s];
    end;

(* calculate average and maximum queue lengths *)

    queue1length;
    if (twoqueues) then queue2length;

(* output data discerned so far *)

    write(print3,'Av. wait, Normals,  Main desk: ');
    writeln(print3,maintotn/normals:7:3);
    write(print3,'Av. wait, Normals,  Processed: ');
    writeln(print3,proctotn/normals:7:3);
    write(print3,'Av. wait, Problems, Main Desk: ');
    writeln(print3,maintotp/problems:7:3);
    write(print3,'Av. wait, Problems, Processed: ');
    writeln(print3,proctotp/problems:7:3);
    write(print3,'Av. wait, Combined, Main Desk: ');
    writeln(print3,maintot/students:7:3);
    write(print3,'Av. wait, Combined, Processed: ');
    writeln(print3,proctot/students:7:3);
    write(print3,'Av. wait, Worst10%, Main Desk: ');
    writeln(print3,maintotw/TheWorst:7:3);
    write(print3,'Av. wait, Worst10%, Processed: ');
    writeln(print3,proctotw/TheWorst:7:3);
    writeln(print3);
end.
