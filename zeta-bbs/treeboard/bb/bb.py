#!/usr/bin/env python3
"""Export or decode zeta Treeboard files.

A Treeboard message base consists of 3 files: TXT, HDR, TOP.

The HDR file contains one 16-byte header for each message:
    flag bits (kiled: 0, private: 1, important: 2, rude: 3, netmsg: 4, netsent: 5)
    number of lines (appears merely advisory)
    RBA of start of message (messages are stored in 256-byte chunks, so rba % 256 is always zero)
    creation date
    sender userid (16 bits)
    receiver userid (16 bits)
    topic (8 bits)
    creation time (mostly s/m/h but sometimes, perhaps incorrectly, h/m/s)

The TXT file contains chunks of length 256:
    First chunk looks like a bitmap of used chunks
    Subsequent chunks are message chunks

Message chunk consists of:
    2-byte pointer to next message in the chain (0x0000 if this is the last chunk)
    Message data

Message data consists of:
    3 bytes:
      byte: must be 0xff
      byte: meaning unknown (dummy byte?)
      byte: meaning unknown
    Sender string followed by CR
    Receiver string followed by CR
    Date (dd MMM yy HH:MM:SS) followed by CR
    Subject followed by CR
    Message body (lines ending in CR)
    byte: 0x00 terminator

"""

from dataclasses import dataclass
import argparse
import datetime
import os.path


@dataclass
class Header:
    """A single message header."""
    id: int
    flags: int
    lines: int
    start: int  # starting sector number
    date: datetime.date
    sender: int
    receiver: int
    topic: int
    time: datetime.time

    flag_killed = 0x01
    flag_private = 0x02
    flag_important = 0x04
    flag_rude = 0x08
    flag_netmsg = 0x10
    flag_netsent = 0x20

    def __init__(self, id: int, buf: bytes):
        self.id = id
        self.flags = int(buf[0])
        self.lines = int(buf[1])
        self.start = buf[3] + buf[4] * 0x100
        self.date = datetime.date(day=buf[5], month=buf[6], year=1900 + buf[7])
        self.sender = buf[8] + buf[9] * 0x100
        self.receiver = buf[10] + buf[11] * 0x100
        self.topic = int(buf[12])

        # Looks like sometimes the time is sec/min/hour, sometimes hour/min/sec
        try:
            self.time = datetime.time(hour=buf[15], minute=buf[14], second=buf[13])
        except ValueError:
            try:
                self.time = datetime.time(hour=buf[13], minute=buf[14], second=buf[15])
            except ValueError:
                raise ValueError('Invalid time {}:{}:{}'.format(buf[15], buf[14], buf[13]))

    def is_deleted(self):
        return self.flags & self.flag_killed

    def is_private(self):
        return self.flags & self.flag_private

    def is_important(self):
        return self.flags & self.flag_important

    def is_rude(self):
        return self.flags & self.flag_rude

    def is_netmsg(self):
        return self.flags & self.flag_netmsg

    def is_netsent(self):
        return self.flags & self.flag_netsent

@dataclass
class Message:
    """A complete message."""
    id: int
    header: Header
    sender: str = None
    receiver: str = None
    date: str = None
    subject: str = None
    body: str = None

class BB(object):
    header_len = 16

    def __init__(self, dir: str):
        self.dir = dir
        self.data_text = None
        self.data_header = None
        self.data_topic = None
        self.n_messages = 0

        if not os.path.exists(dir):
            raise DirectoryNotFoundError(f'No such directory {dir}')

        text_path = f'{dir}/msgtxt.zms'
        header_path = f'{dir}/msghdr.zms'
        topic_path = f'{dir}/msgtop.zms'

        with open(text_path, 'rb') as ifp:
            self.data_text = ifp.read()
        with open(header_path, 'rb') as ifp:
            self.data_header = ifp.read()
            self.n_messages = int(len(self.data_header) / BB.header_len)
        with open(topic_path, 'rb') as ifp:
            self.data_topic = ifp.read()

    def header(self, n: int):
        if n > self.n_messages:
            raise ValueError(f'Message numbers go to {self.n_messages}')
        buf = self.data_header[n * BB.header_len:(n + 1) * BB.header_len]
        return Header(n, buf)

    def sector_iter(self, n: int):
        """Generates all the sector numbers for a given message."""
        hdr = self.header(n)
        if hdr.is_deleted():
            return

        start = hdr.start

        while start != 0:
            yield start
            buf = self.data_text[start*256:start*256+2]
            start = buf[0] + buf[1] * 0x100

    def text_iter(self, start: int):
        while start != 0:
            buf = self.data_text[start*256:(start+1)*256]
            next_start = buf[0] + buf[1] * 0x100
            # print(f'Getting text at {start}: (next is {next_start})')
            for b in buf[2:]:
                yield b
            start = next_start

    def messages(self):
        """A generator to yield all messages."""
        n = 1
        while n <= self.n_messages:
            yield self.message(n)
            n += 1

    def message(self, n: int):
        if n > self.n_messages:
            raise ValueError(f'Message numbers go to {self.n_messages}')
        hdr = self.header(n)
        if hdr.is_deleted():
            # A deleted message only has a Header
            return Message(id=n, header=hdr)

        start = hdr.start
        sender = ''
        receiver = ''
        subject = ''
        date_ = ''
        body = ''
        i = self.text_iter(start)
        next(i)
        next(i)
        next(i)

        ch = next(i)
        while ch != 0x0d:
            sender += chr(ch)
            ch = next(i)

        ch = next(i)
        while ch != 0x0d:
            receiver += chr(ch)
            ch = next(i)

        ch = next(i)
        while ch != 0x0d:
            date_ += chr(ch)
            ch = next(i)

        ch = next(i)
        while ch != 0x0d:
            subject += chr(ch)
            ch = next(i)

        ch = next(i)
        while ch != 0x00:
            if ch == 0x0d:
                body += '\n'
            else:
                body += chr(ch)
            ch = next(i)

        return Message(id=n, header=hdr, sender=sender, receiver=receiver, date=date_, subject=subject, body=body)


    def dump(self):
        for msg_id in range(self.n_messages):
            try:
                hdr = self.header(msg_id)
            except ValueError as e:
                print(f'Invalid header {msg_id}: {e}')
                continue
            print(hdr)

def print_message(msg: Message):
    if msg.header.is_deleted():
        print(f'Msg Id:  {msg.id} is deleted')
        return

    more = ''

    if msg.header.is_private():
        more += ' (private)'

    if msg.header.is_important():
        more += ' (important)'

    if msg.header.is_rude():
        more += ' (rude)'

    if msg.header.is_netmsg():
        more += ' (netmsg)'

    if msg.header.is_netsent():
        more += ' (netsent)'

    print(f'Msg Id:  {msg.id}{more}')
    print(f'From:    {msg.sender}')
    print(f'To:      {msg.receiver}')
    print(f'Date:    {msg.date}')
    print(f'Subject: {msg.subject}')
    print('')
    print(msg.body)

def main():
    parser = argparse.ArgumentParser(description='Export or decode Zeta Treeboard files.')
    parser.add_argument('--dir', required=True, help='Data directory')
    parser.add_argument('ids', type=int, nargs='*', help='Message IDs to print')
    parser.add_argument('--read_all', action='store_true', help='Read all messages')
    parser.add_argument('--check_bitmap', action='store_true', help='Check used sector bitmap')
    args = parser.parse_args()

    bb = BB(dir=args.dir)

    if args.read_all:
        for message in bb.messages():
            print('---')
            print_message(message)

    if args.check_bitmap:
        sectors_used = {}
        for message_id in range(1, bb.n_messages):
            sectors = list(bb.sector_iter(message_id))

            if not sectors:
                # Message deleted
                continue

            print(f'{message_id:5} -> {sectors}')

            for sector_id in sectors:
                if sector_id not in sectors_used:
                    sectors_used[sector_id] = message_id
                else:
                    print(f'Sector {sector_id} is used by messages {sectors_used[sector_id]} and {message_id}')

        return

    if args.ids:
        for i in args.ids:
            print('---')
            print_message(bb.message(i))
        return

    bb.dump()


if __name__ == '__main__':
    main()
