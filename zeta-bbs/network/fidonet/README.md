# Fidonet Packet Handlers

This directory contains sources which were used to pack and unpack
messages from my BBS system into Fidonet format. There were:

* <b>bbass</b> would scan the message base for messages which
  need to be packed up, and do the packing, into Fidonet format
  transfer files for messages. This was only for Echomail, I
  think.
* <b>mailass</b> would do the same thing, except for person-to-person
  email.
* <b>packdis</b> would disassemble Fidonet format transfer files,
  and I guess it would insert them into the email or the public
  message bases.
