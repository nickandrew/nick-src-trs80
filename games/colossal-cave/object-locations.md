# Object initial locations

Inside Building (03)
  Keys (inventory: 01, dropped: 21)
  Lamp (inventory: 02, dropped: 22, nearby: 42)
  Food (inventory: 13, dropped: 33)
  Bottle (inventory: 14, dropped: 34, empty: 54, oil: 74)
  Water (inventory: 15)
  Oil (inventory: 16)

Cobble Crawl (0a)
  Wicker Cage (inventory: 04, dropped: 24)

# Object IDs

There are two sets of objects with overlapping objectIds.  Each object
has 1 or more messages in the object descriptions area.

The messages are numbered objectId, + 0x20, + 0x40, +0x60

Message numbers:

objectId | The description of the object in inventory
+ 0x20   | Description of the object when not carried
+ 0x40   | Variant of the above (open, closed, full, empty etc)
+ 0x60   | Variant

A * prefixing the name means it's not an item which can be carried.

01  Set of Keys
02  Brass Lantern (22: Lamp is off; 42: Lamp is on)
03  * Grate (23: Grate is locked; 43: Grate is open)
04  Wicker Cage
05  Black Rod (with a rusty star)
06  Black Rod (with a rusty mark)
07  * Steps (27: lead down; 28: lead up)
08  Bird in cage (28: bird singing; 48: bird in cage but not carried)
09  * Rusty Door (29: door closed; 49: door open)
0a  Velvet Pillow
0b  * Snake (2b: snake bars the way; 4b: snake chased away)
0c  * Fissure (2c: placeholder; 4c: crystal bridge; 6c: crystal bridge vanished)
0d  * Stone Tablet
0e  Giant Clam (GRUNT!)
0f  Giant Oyster (2f: enormous oyster; 4f: something written under oyster)
10  'LWPI' Magazine
11  -- Unused --
12  -- Unused --
13  Tasty Food
14  Small Bottle (34: bottle of water; 54: empty bottle; 74: bottle of oil)
15  Water in the Bottle
16  Oil in the bottle
17  * Mirror
18  * Plant (38, 58, 78, 98, b8, d8 represent plant states)
19  * Phony Plant (39, 59, 79 represent phony plant states)
1a  * Stalactite
1b  * Shadowy Figure
1c  Dwarf's Axe (3c: axe here; 5c: axe lying beside the bear)
1d  * Cave Drawings
1e  * Pirate
1f  * Dragon (3f: dragon bars the way; 5f: dragon vanquished; 7f: body)

There's a second set of object descriptions immediately following:

00  * Chasm (20: wooden bridge; 40: wrecked bridge)
01  * Troll (21: troll insists on a treasure; 41: troll blocks the way; 61: chased away)
02  * Phony Troll (22: nowhere to be seen)
03  * Bear uses rtext 141 (refers to message 8d; variants 23, 43, 63, 83)
04  * Message in second maze (24)
05  * Volcano and/or Geyser
06  * Vending Machine
07  * Batteries (27: fresh; 47: worn-out)
08  * Carpet and/or Moss
09  * Computers
0a  Unused
0b  Unused
0c  Unused
0d  Unused
0e  Unused
0f  Unused
10  Unused
11  Unused
12  Large Gold Nugget
13  Several Diamonds
14  Bars of Silver
15  Precious Jewelry
16  Rare Coins
17  Treasure Chest
18  Golden Eggs (variants 38, 58, 78)
19  Jeweled Trident
1a  Ming Vase (variants)
1b  Egg-sized Emerald
1c  Platinum Pyramid
1d  Glistening Pearl
1e  Persian Rug
1f  Rare Spices
00  Golden Chain (variants 20, 40, 60)
