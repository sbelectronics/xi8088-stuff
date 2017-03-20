Nixie Tube Clock for Xi8088 with 8255 PIO board

This project is a Nixie Tube Clock using smbaker's shift-register
Nixie Tube driver boards together with an 8255 PIO card.

The 8255 is located at addess 218h. The card used in the demo is
a B-SOFT DIG100. The DIG100 has two 8255 chips. The one connected
to the internal header is at base+18h. The one connected to the
external header is at base+1Ch.

For this demo, the Nixie Boards are connected to the 8255 using 
the following pin assignments:

  A0 - data
  A1 - clock
  A2 - latch

The file dig100-logic.sch contains my reverse engineering of the
DIG100's address decoding. I lost the damn manual, and had no 
idea what addresses the chips were at. I tried the obvious 
(200, 204, 208, 210) but didn't bother looking way out in 
left field at 218 or 21C. I'm guessing they must have done
this to leave room for some other board at the lower 
addresses. 
