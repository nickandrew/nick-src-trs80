program queuemanager(input,output,indata,
                     print1,print1a,print2,out1,out2);

(* Manage the two (/one) queues for Simulation asst 1     *)
(* Reads student arrival and service times from file 'in' *)
(* Writes queue 1 times to 'print1', Q2 times to print1a, *)
(* idle time summaries to 'print2'                        *)
(* Writes raw queue 1 data to 'out1' & queue 2 to 'out2'  *)

const  coffeebreak = false;
       TwoQueues   = true;
       SERVERS1    = 3;         (* Number of servers q1    *)
       SERVERS2    = 3;         (* Number of servers q2    *)
       STUDENTS    = 500;

type  norptype = (normal,problem);

       stype = record
                  norp    : norptype;
                  arrtime : real;
                  time1   : real;
                  time2   : real;
               end;

      stafft = record
                  idle    : real;   (* cumulative idle time *)
                  work    : real;   (* cumulative work time *)
                  availt  : real;   (* next available time  *)
               end;

      q1type = record
                  norp     : norptype;
                  arrtime  : real;
                  maindesk : real;
                  depart1  : real;
               end;

      q2type = record
                  arrtime  : real;
                  depart1  : real;
                  probdesk : real;
                  depart2  : real;
               end;

var

    queue1 : array[1..SERVERS1] of stafft;  (* first queue *)
    queue2 : array[1..SERVERS2] of stafft;  (* second queue *)
    stud   : stype;            (* a student input record *)
  stud1rec : q1type;
  stud2rec : q2type;
   q2delay : array[1..SERVERS1] of record
                  q2 : q2type;
                  tt : real;
             end;

    q2used : integer;          (* count of filled q2delay *)

    indata : file of stype;    (* input file of students *)
    print1 : text;             (* show action of queue 1 *)
   print1a : text;             (* show action of queue 2 *)
    print2 : text;             (* idle times report      *)
    out1   : file of q1type;
    out2   : file of q2type;
    i,j    : integer;
    s1time : real;             (* time student gets served *)
    s2time : real;
    q1time : real;             (* first server available *)
    q2time : real;
   server1 : integer;          (* code of first server av *)
   server2 : integer;
   thistud : integer;
    q1idle : real;
    q2idle : real;
extradelay : real;             (* coffeebreak delay if any *)
 lastleave : real;             (* time last person leaves  *)

(*----------------------------------------------------------*)

procedure q2sim;                    (* simulate queue2 *)
var   tempstud : q2type;
      q2place  : integer;
      q2arrive : real;
      studtime : real;
begin

(* can arrive at queue2 in the wrong order so sort them.    *)

    if (q2used<SERVERS1) then begin  (* refuse to consider *)
        q2used := q2used + 1;
        q2delay[q2used].q2 := stud2rec;   (* copy record *)
        q2delay[q2used].tt := stud.time2;
        (* will process these when array is full *)
    end else begin

(* find the q2delay element with first depart1 time, swap for
   current record under consideration to reorder queue2 *)
        q2place  := 1;
        q2arrive := q2delay[1].q2.depart1;
        for j:=1 to SERVERS1 do begin
            if (q2delay[j].q2.depart1 < q2arrive) then begin
                q2arrive := q2delay[j].q2.depart1;
                q2place  := j;
            end;
        end;
        tempstud := stud2rec;
        stud2rec := q2delay[q2place].q2;
        studtime := q2delay[q2place].tt;
        q2delay[q2place].q2 := tempstud;
        q2delay[q2place].tt := stud.time2;

        (* get first available time for any server *)
        server2 := 1;
        s2time  := queue2[server2].availt;
        for j:=1 to SERVERS2 do begin
            if (queue2[j].availt < s2time) then begin
                s2time  := queue2[j].availt;
                server2 := j;
            end;
        end;

(* if student arrives after s2time, then start of service *)
(* happens when student arrives (departs queue 1) *)

        q2time := s2time;
        if (stud2rec.depart1 > q2time) then
            q2time := stud2rec.depart1;
        stud2rec.probdesk := q2time;

(* give it to server (queue2) "server2" *)

        queue2[server2].idle := queue2[server2].idle
                                + q2time - s2time;

(* coffee break, problem student handling guys? *)

        extradelay := 0.0;
        if (coffeebreak) then begin
            if (q2time < 130) then begin
                if (q2time>=120) and (q2time<130)
                    then extradelay := 130.0 - q2time
                    else if (120 < (q2time + studtime))
                        then extradelay := 10.0;
            end;
        end;

        queue2[server2].work := queue2[server2].work +
                                studtime + extradelay;

        queue2[server2].availt := q2time + studtime
                                  + extradelay;

        stud2rec.depart2 := queue2[server2].availt;
        if (lastleave < stud2rec.depart2)
            then lastleave := stud2rec.depart2;

        (* output data discerned from queue 2 *)

        write(out2,stud2rec);

        writeln(print1a,stud2rec.arrtime:7:3,
              stud2rec.depart1:9:3,stud2rec.probdesk:9:3,
              server2:4,stud2rec.depart2:9:3);

    end;
end;

(*----------------------------------------------------------*)

procedure initialise;
var i: integer;
begin
    rewrite(print1);
    rewrite(print1a);
    rewrite(print2);
    rewrite(out1);
    rewrite(out2);

    q2used    := 0;
    lastleave := 0.0;
    for i:=1 to SERVERS1 do begin
        queue1[i].idle   := 0.0;
        queue1[i].work   := 0.0;
        queue1[i].availt := 0.0;
    end;

    for i:=1 to SERVERS2 do begin
        queue2[i].idle   := 0.0;
        queue2[i].work   := 0.0;
        queue2[i].availt := 0.0;
    end;
end;

(*----------------------------------------------------------*)

begin (* simulation assignment 2 queue manager *)
    initialise;

    writeln(print1,
        'No.  Arrive   Mn-desk  S#  Depart1');
    writeln(print1,
        '---  -------  -------  --  -------');
    if (twoqueues) then begin
        writeln(print1a,
            'Arrive   Depart1  Pr-Desk  S#  Depart2');
        writeln(print1a,
            '-------  -------  -------  --  -------');
    end;

    for thistud:=1 to STUDENTS do begin

        read(indata,stud);
        stud1rec.norp     := stud.norp;
        stud1rec.arrtime  := stud.arrtime;
        stud2rec.arrtime  := stud.arrtime;

(* if only one queue, service time in queue 1 FOR A PROBLEM *)
(* is defined as the queue 2 service time, ie: ignoring the *)
(* uniform (0,1) "is it a problem" decision time            *)

        if (not TwoQueues) and (stud.norp = problem)
            then stud.time1 := stud.time2;

(* get first available time *)

        server1 := 1;
        s1time  := queue1[server1].availt;
        for i:= 1 to SERVERS1 do begin
            if (queue1[i].availt < s1time) then begin
                s1time  := queue1[i].availt;
                server1 := i;
            end;
        end;

(* if student arrives after s1time, then start of *)
(* service time is arrival time *)

        q1time := s1time;
        if (stud.arrtime>q1time) then q1time := stud.arrtime;
        stud1rec.maindesk := q1time;

(* give it to server "server1" *)

        (* coffee break, guys? *)

        extradelay := 0.0;
        if (coffeebreak) then begin
            if (q1time < 130) then begin
                if (q1time>=120) and (q1time<130)
                    then extradelay := 130.0 - q1time
                    else if (120 < (q1time + stud.time1))
                        then extradelay := 10.0;
            end;
        end;

        queue1[server1].work := queue1[server1].work
                                + stud.time1 + extradelay;

        queue1[server1].idle := queue1[server1].idle
                                + q1time - s1time;

        queue1[server1].availt := q1time + stud.time1
                                  + extradelay;
        stud1rec.depart1 := queue1[server1].availt;
        stud2rec.depart1 := queue1[server1].availt;

(* output data discerned *)

        writeln(print1,thistud:3,'  ',
                stud1rec.arrtime:7:3,'  ',
                stud1rec.maindesk:7:3,'  ',
                server1:2,'  ',
                stud1rec.depart1:7:3,'  ');

        write(out1,stud1rec);

(* update last person to leave time from depart q1 time *)
        if (lastleave < stud1rec.depart1)
            then lastleave := stud1rec.depart1;

(* give problem students to next queue if two queues  *)

        if (stud.norp = problem) then begin
            if (Twoqueues) then q2sim;
        end;

    end;

(* no more students, ensure queue 2 completed by flushing *)

    for i:=1 to SERVERS1 do begin
        (* enqueue dummy students with late depart1 times *)
        (* to flush remaining students in queue2          *)
        stud2rec.depart1 := 99999.999;
        q2sim;   (* output 1 record, update times etc.... *)
    end;

(* print totals for server idle time, each queue *)

    writeln(print2,'Server, Last Person data for simulation');
    write(print2,'Parameters: ');
    if (TwoQueues)
        then write(print2,'Two queues, ')
        else write(print2,'One queue, ');
    if (coffeebreak)
        then write(print2,'Coffee break, ')
        else write(print2,'No coffee break, ');
    write(print2,'Servers = (',SERVERS1:1);
    if (Twoqueues)
        then writeln(print2,',',SERVERS2:1,').')
        else writeln(print2,').');

(* Server idle time. Update idle time for each server by *)
(* adding difference of last available time and the time *)
(* the last person leaves (then all staff can go home)   *)

    q1idle := 0.0;
    q2idle := 0.0;
    writeln(print2,'Server idle time, queue 1');
    for i:=1 to SERVERS1 do begin
        queue1[i].idle := queue1[i].idle +
                          lastleave - queue1[i].availt;
        writeln(print2,i:5,'  ',queue1[i].idle:8:3,
                ' idle, ',queue1[i].work:8:3,' working.');
        q1idle := q1idle + queue1[i].idle;
    end;
    writeln(print2,'Total  ',q1idle:8:3);
    if (TwoQueues) then begin
        writeln(print2,'Server idle time, queue 2');
        for i:=1 to SERVERS2 do begin
            queue2[i].idle := queue2[i].idle +
                              lastleave - queue2[i].availt;
            writeln(print2,i:5,'  ',queue2[i].idle:8:3,
                    ' idle, ',queue2[i].work:8:3,' working.');
            q2idle := q2idle + queue2[i].idle;
        end;
        writeln(print2,'Total  ',q2idle:8:3);
    end;

    writeln(print2,'Last person leaves at:',lastleave:8:3);

end.
