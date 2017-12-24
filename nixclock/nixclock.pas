{$M 1024,0,0}
uses dos,crt;

const
  BASE_PORT = $218;
  DATA_PORT = BASE_PORT;
  CTL_PORT = BASE_PORT + 3;

  RTC_CTL = $70;
  RTC_DATA = $71;

  DATA_BIT = 1;
  CLK_BIT = 2;
  LATCH_BIT = 4;

var
  last_seconds: word;

procedure transfer_latch;
begin
    port[DATA_PORT] := LATCH_BIT;
    port[DATA_PORT] := 0;
end;

procedure out_bit(b: boolean);
begin
   if b then begin
      port[DATA_PORT] := DATA_BIT;
      port[DATA_PORT] := DATA_BIT + CLK_BIT;
      port[DATA_PORT] := DATA_BIT;
   end else begin
      port[DATA_PORT] := 0;
      port[DATA_PORT] := CLK_BIT;
      port[DATA_PORT] := 0;
   end;
end;

procedure out_digit(dg: word);
begin
    out_bit((dg and 8) <> 0);
    out_bit((dg and 4) <> 0);
    out_bit((dg and 2) <> 0);
    out_bit((dg and 1) <> 0);
end;

function from_bcd(x: word): word;
begin
  from_bcd := (((x and $F0) shr 4) * 10) + (x and $0F);
end;

function to_bcd(x: word): word;
begin
  to_bcd:= ((x div 10) shl 4) + (x mod 10);
end;

procedure update_clock(h: word; m: word; s: word);
var
    th, oh, tm, om, ts, os: word;
begin
    th := trunc(H/10);
    oh := H mod 10;
    tm := trunc(M/10);
    om := M mod 10;
    ts := trunc(S/10);
    os := S mod 10;

    out_digit(tm);
    out_digit(15);       { blank digit }
    out_digit(0);        { decimal points and leds}
    out_digit(0);        { decimal points and leds}
    out_digit(oh);
    out_digit(th);
    out_digit(os);
    out_digit(ts);
    out_digit(0);        { decimal points and leds}
    out_digit(0);        { decimal points and leds}
    out_digit(15);       { blank digit }
    out_digit(om);
    transfer_latch;
end;

procedure check_clock;
var
  h, m, s, hund: word;
  status_b: word;
begin
  { Read directly from RTC, it's faster and prevents the program from
    exploding.
  }

  { Check the seconds first. If the seconds haven't changed then we can
    skip the rest of the function.
  }

  port[RTC_CTL] := $00;
  s:=port[RTC_DATA];
{  writeln('s=', s);}
  if (s = last_seconds) then begin
      exit;
  end;

  last_seconds := s;

  port[RTC_CTL] := $04;
  h:=port[RTC_DATA];
{  writeln('h=', h);}
  port[RTC_CTL] := $02;
  m:=port[RTC_DATA];
{  writeln('m=', m);}

  { check to see if the RTC is in bcd mode. If so, adjust. }

  port[RTC_CTL] := $0B;
  status_b := port[RTC_DATA];
  if ((status_b and 2) <> 0) then begin
      h:=from_bcd(h);
      m:=from_bcd(m);
      s:=from_bcd(s);
  end;

  update_clock(h, m, s);
end;

procedure init_clock;
var
  junk: byte;
begin
  port[RTC_CTL]:=$0A;
  port[RTC_DATA]:=$26;

  port[RTC_CTL]:=$0B;
  port[RTC_DATA]:=$02;

  port[RTC_CTL]:=$0C;
  junk:=port[RTC_DATA];
  writeln('c=', junk);

  port[RTC_CTL]:=$0D;
  junk:=port[RTC_DATA];
  writeln('d=', junk);
end;

procedure set_h(h: integer);
begin
  h:=to_bcd(h);
  port[RTC_CTL]:=$04;
  port[RTC_DATA]:=h;
end;

procedure set_m(m: integer);
begin;
  m:=to_bcd(m);
  port[RTC_CTL]:=$02;
  port[RTC_DATA]:=m;
end;

procedure set_s(s: integer);
begin;
  s:=to_bcd(s);
  port[RTC_CTL]:=$00;
  port[RTC_DATA]:=s;
end;



procedure int1c; interrupt;
begin
  check_clock;
end;

procedure setup_8255;
begin
  { setup 8255, all ports output }
  port[CTL_PORT] := $80;
end;

var
  do_tsr: boolean;
  do_init: boolean;
  do_set_h, do_set_m, do_set_s: integer;

procedure parse_args;
var
  i,j: integer;
  s: string[32];
begin
  do_tsr:=FALSE;
  do_init:=FALSE;
  do_set_h:=-1;
  do_set_m:=-1;
  do_set_s:=-1;

  i:=1;
  while (i<=paramcount) do begin
    s:=paramstr(i);
    for j:=1 to length(s) do begin;
      s[j]:=upcase(s[j]);
    end;

    if (s='/TSR') then begin
      do_tsr:=TRUE;
    end else if (s='/INIT') then begin
      do_init:=TRUE;
    end else if (s='/H') then begin
      i:=i+1;
      val(paramstr(i), do_set_h, j);
    end else if (s='/M') then begin
      i:=i+1;
      val(paramstr(i), do_set_m, j);
    end else if (s='/S') then begin
      i:=i+1;
      val(paramstr(i), do_set_s, j);
    end;
    i:=i+1
  end;
end;

begin
 last_seconds := 9999;
 parse_args;
 if (do_init) then begin
   writeln('Initialize');
   init_clock;
 end;

 if (do_set_s>=0) then begin
   set_s(do_set_s);
 end;
 if (do_set_m>=0) then begin
   set_m(do_set_m);
 end;
 if (do_set_h>=0) then begin;
   set_h(do_set_h);
 end;

 setup_8255;
 check_clock;
 if (do_tsr) then begin
   writeln('Terminate and Stay Resident');
   setintvec($1c,@int1c);
   keep(0);
 end;
end.
