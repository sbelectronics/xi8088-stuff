1 REM clock.bas
2 REM by Scott Baker, http://www.smbaker.com/
3 REM Demonstrates use of BQ4845 RTC on Z80 RC2014 computer

7 REM constants for nixie-tube bits (data, clock, latch)
8 DB=1 : CB = 2 : LB = 4

9 REM internal 8255 is at xx18h; external 8255 is at xx1Ch

10 BA = &H218
20 AA = BA+0 : REM port A address
30 AC = BA+3 : REM control address

40 REM configure parallel port, all ports as output
50 OUT AC, &H80

100 LS=999
120 GOSUB 1000
130 if (LS = S) GOTO 200
140 LS = S
150 GOSUB 2000
160 print T$
165 GOSUB 7000
200 GOTO 120

998 REM read the current time from the RTC
999 REM store it in the variables H, M, S.
1000 X=timer
1010 H=int(X/3600)
1020 X=X-(H*3600)
1030 M=int(X/60)
1040 X=X-(M*60)
1050 S=int(X)
1060 RETURN

1999 REM format H, M, S into a string T$
2000 T$=""
2010 if (H>9) GOTO 2030
2020 T$=T$+"0"
2030 T$=T$+right$(str$(H),len(str$(H))-1)
2040 T$=T$+":"
2050 if (M>9) GOTO 2070
2060 T$=T$+"0"
2070 T$=T$+right$(str$(M),len(str$(M))-1)
2080 T$=T$+":"
2090 if (S>9) GOTO 2110
2100 T$=T$+"0"
2110 T$=T$+right$(str$(S),len(str$(S))-1)
2120 RETURN

4000 REM transfer_latch
4010 OUT AA, LB
4020 OUT AA, 0
4030 RETURN

5000 REM shift_bit, bit is in B
5010 OUT AA, B
5020 OUT AA, B + CB
5030 OUT AA, B
5040 RETURN

6000 REM shift_digit, MSB first, digit is in DG
6001 REM print dg
6005 B=0
6010 IF (DG and 8)<>0 THEN B=1
6020 GOSUB 5000
6030 DG=DG*2
6035 B=0
6040 IF (DG and 8)<>0 THEN B=1
6050 GOSUB 5000
6080 DG=DG*2
6085 B=0
6090 IF (DG and 8)<>0 THEN B=1
6100 GOSUB 5000
6110 DG=DG*2
6115 B=0
6120 IF (DG and 8)<>0 THEN B=1
6130 GOSUB 5000
6140 RETURN

7000 REM display_nixie_clock, time is in H, M, and S
7010 TH=INT(H/10)
7020 OH=H-(TH*10)
7030 TM=INT(M/10)
7040 OM=M-(TM*10)
7050 TS=INT(S/10)
7060 OS=S-(TS*10)
7100 DG=TM
7110 GOSUB 6000
7119 REM skip next digit
7120 DG=15
7130 GOSUB 6000
7140 REM skip decimal point and led lights
7150 DG=0 : GOSUB 6000
7160 DG=0 : GOSUB 6000
7200 DG=OH
7210 GOSUB 6000
7220 DG=TH
7230 GOSUB 6000
7240 DG=OS
7250 GOSUB 6000
7260 DG=TS
7270 GOSUB 6000
7300 REM skip decimal point and led lights
7310 DG=0 : GOSUB 6000
7320 DG=0 : GOSUB 6000
7330 REM skip next digit
7340 DG=15 : GOSUB 6000
7400 DG=OM
7410 GOSUB 6000

7500 GOSUB 4000
7510 RETURN






