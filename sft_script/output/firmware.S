
output/firmware.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <reset_vec>:
       0:	0600600b          	0x600600b
       4:	1dc0106f          	j	11e0 <_start>
       8:	00000013          	nop
       c:	00000013          	nop

00000010 <irq_vec>:
      10:	0200a10b          	0x200a10b
      14:	0201218b          	0x201218b
      18:	000000b7          	lui	ra,0x0
      1c:	16008093          	addi	ra,ra,352 # 160 <irq_regs>
      20:	0000410b          	0x410b
      24:	0020a023          	sw	sp,0(ra)
      28:	0001410b          	0x1410b
      2c:	0020a223          	sw	sp,4(ra)
      30:	0001c10b          	0x1c10b
      34:	0020a423          	sw	sp,8(ra)
      38:	0030a623          	sw	gp,12(ra)
      3c:	0040a823          	sw	tp,16(ra)
      40:	0050aa23          	sw	t0,20(ra)
      44:	0060ac23          	sw	t1,24(ra)
      48:	0070ae23          	sw	t2,28(ra)
      4c:	0280a023          	sw	s0,32(ra)
      50:	0290a223          	sw	s1,36(ra)
      54:	02a0a423          	sw	a0,40(ra)
      58:	02b0a623          	sw	a1,44(ra)
      5c:	02c0a823          	sw	a2,48(ra)
      60:	02d0aa23          	sw	a3,52(ra)
      64:	02e0ac23          	sw	a4,56(ra)
      68:	02f0ae23          	sw	a5,60(ra)
      6c:	0500a023          	sw	a6,64(ra)
      70:	0510a223          	sw	a7,68(ra)
      74:	0520a423          	sw	s2,72(ra)
      78:	0530a623          	sw	s3,76(ra)
      7c:	0540a823          	sw	s4,80(ra)
      80:	0550aa23          	sw	s5,84(ra)
      84:	0560ac23          	sw	s6,88(ra)
      88:	0570ae23          	sw	s7,92(ra)
      8c:	0780a023          	sw	s8,96(ra)
      90:	0790a223          	sw	s9,100(ra)
      94:	07a0a423          	sw	s10,104(ra)
      98:	07b0a623          	sw	s11,108(ra)
      9c:	07c0a823          	sw	t3,112(ra)
      a0:	07d0aa23          	sw	t4,116(ra)
      a4:	07e0ac23          	sw	t5,120(ra)
      a8:	07f0ae23          	sw	t6,124(ra)
      ac:	00001137          	lui	sp,0x1
      b0:	1e010113          	addi	sp,sp,480 # 11e0 <_start>
      b4:	00000537          	lui	a0,0x0
      b8:	16050513          	addi	a0,a0,352 # 160 <irq_regs>
      bc:	0000c58b          	0xc58b
      c0:	414010ef          	jal	ra,14d4 <irq>
      c4:	00050093          	mv	ra,a0
      c8:	0000a103          	lw	sp,0(ra)
      cc:	0201200b          	0x201200b
      d0:	0040a103          	lw	sp,4(ra)
      d4:	0201208b          	0x201208b
      d8:	0080a103          	lw	sp,8(ra)
      dc:	0201210b          	0x201210b
      e0:	00c0a183          	lw	gp,12(ra)
      e4:	0100a203          	lw	tp,16(ra)
      e8:	0140a283          	lw	t0,20(ra)
      ec:	0180a303          	lw	t1,24(ra)
      f0:	01c0a383          	lw	t2,28(ra)
      f4:	0200a403          	lw	s0,32(ra)
      f8:	0240a483          	lw	s1,36(ra)
      fc:	0280a503          	lw	a0,40(ra)
     100:	02c0a583          	lw	a1,44(ra)
     104:	0300a603          	lw	a2,48(ra)
     108:	0340a683          	lw	a3,52(ra)
     10c:	0380a703          	lw	a4,56(ra)
     110:	03c0a783          	lw	a5,60(ra)
     114:	0400a803          	lw	a6,64(ra)
     118:	0440a883          	lw	a7,68(ra)
     11c:	0480a903          	lw	s2,72(ra)
     120:	04c0a983          	lw	s3,76(ra)
     124:	0500aa03          	lw	s4,80(ra)
     128:	0540aa83          	lw	s5,84(ra)
     12c:	0580ab03          	lw	s6,88(ra)
     130:	05c0ab83          	lw	s7,92(ra)
     134:	0600ac03          	lw	s8,96(ra)
     138:	0640ac83          	lw	s9,100(ra)
     13c:	0680ad03          	lw	s10,104(ra)
     140:	06c0ad83          	lw	s11,108(ra)
     144:	0700ae03          	lw	t3,112(ra)
     148:	0740ae83          	lw	t4,116(ra)
     14c:	0780af03          	lw	t5,120(ra)
     150:	07c0af83          	lw	t6,124(ra)
     154:	0000c08b          	0xc08b
     158:	0001410b          	0x1410b
     15c:	0400000b          	0x400000b

00000160 <irq_regs>:
	...

000011e0 <_start>:
    11e0:	00000093          	li	ra,0
    11e4:	00000113          	li	sp,0
    11e8:	00000193          	li	gp,0
    11ec:	00000213          	li	tp,0
    11f0:	00000293          	li	t0,0
    11f4:	00000313          	li	t1,0
    11f8:	00000393          	li	t2,0
    11fc:	00000413          	li	s0,0
    1200:	00000493          	li	s1,0
    1204:	00000513          	li	a0,0
    1208:	00000593          	li	a1,0
    120c:	00000613          	li	a2,0
    1210:	00000693          	li	a3,0
    1214:	00000713          	li	a4,0
    1218:	00000793          	li	a5,0
    121c:	00000813          	li	a6,0
    1220:	00000893          	li	a7,0
    1224:	00000913          	li	s2,0
    1228:	00000993          	li	s3,0
    122c:	00000a13          	li	s4,0
    1230:	00000a93          	li	s5,0
    1234:	00000b13          	li	s6,0
    1238:	00000b93          	li	s7,0
    123c:	00000c13          	li	s8,0
    1240:	00000c93          	li	s9,0
    1244:	00000d13          	li	s10,0
    1248:	00000d93          	li	s11,0
    124c:	00000e13          	li	t3,0
    1250:	00000e93          	li	t4,0
    1254:	00000f13          	li	t5,0
    1258:	00000f93          	li	t6,0
    125c:	00008137          	lui	sp,0x8
    1260:	ffc10113          	addi	sp,sp,-4 # 7ffc <server_port+0x624c>
    1264:	0a8000ef          	jal	ra,130c <main>

00001268 <nooop>:
    1268:	00000013          	nop
    126c:	ffdff06f          	j	1268 <nooop>
    1270:	00100073          	ebreak
    1274:	0000                	unimp
	...

00001278 <SM3_WRITE>:
    1278:	fd010113          	addi	sp,sp,-48
    127c:	02812623          	sw	s0,44(sp)
    1280:	03010413          	addi	s0,sp,48
    1284:	fca42e23          	sw	a0,-36(s0)
    1288:	fcb42c23          	sw	a1,-40(s0)
    128c:	fe042623          	sw	zero,-20(s0)
    1290:	0600006f          	j	12f0 <SM3_WRITE+0x78>
    1294:	fd842783          	lw	a5,-40(s0)
    1298:	fff78793          	addi	a5,a5,-1
    129c:	fec42703          	lw	a4,-20(s0)
    12a0:	02f71463          	bne	a4,a5,12c8 <SM3_WRITE+0x50>
    12a4:	fdc42703          	lw	a4,-36(s0)
    12a8:	fec42783          	lw	a5,-20(s0)
    12ac:	00f707b3          	add	a5,a4,a5
    12b0:	0007c783          	lbu	a5,0(a5)
    12b4:	1007e713          	ori	a4,a5,256
    12b8:	000107b7          	lui	a5,0x10
    12bc:	08078793          	addi	a5,a5,128 # 10080 <end+0x68cc>
    12c0:	00e7a023          	sw	a4,0(a5)
    12c4:	0200006f          	j	12e4 <SM3_WRITE+0x6c>
    12c8:	fdc42703          	lw	a4,-36(s0)
    12cc:	fec42783          	lw	a5,-20(s0)
    12d0:	00f707b3          	add	a5,a4,a5
    12d4:	0007c703          	lbu	a4,0(a5)
    12d8:	000107b7          	lui	a5,0x10
    12dc:	08078793          	addi	a5,a5,128 # 10080 <end+0x68cc>
    12e0:	00e7a023          	sw	a4,0(a5)
    12e4:	fec42783          	lw	a5,-20(s0)
    12e8:	00178793          	addi	a5,a5,1
    12ec:	fef42623          	sw	a5,-20(s0)
    12f0:	fec42703          	lw	a4,-20(s0)
    12f4:	fd842783          	lw	a5,-40(s0)
    12f8:	f8f76ee3          	bltu	a4,a5,1294 <SM3_WRITE+0x1c>
    12fc:	00000013          	nop
    1300:	02c12403          	lw	s0,44(sp)
    1304:	03010113          	addi	sp,sp,48
    1308:	00008067          	ret

0000130c <main>:
    130c:	fe010113          	addi	sp,sp,-32
    1310:	00112e23          	sw	ra,28(sp)
    1314:	00812c23          	sw	s0,24(sp)
    1318:	02010413          	addi	s0,sp,32
    131c:	000107b7          	lui	a5,0x10
    1320:	08078793          	addi	a5,a5,128 # 10080 <end+0x68cc>
    1324:	03100713          	li	a4,49
    1328:	00e7a023          	sw	a4,0(a5)
    132c:	000107b7          	lui	a5,0x10
    1330:	08078793          	addi	a5,a5,128 # 10080 <end+0x68cc>
    1334:	03200713          	li	a4,50
    1338:	00e7a023          	sw	a4,0(a5)
    133c:	000107b7          	lui	a5,0x10
    1340:	08078793          	addi	a5,a5,128 # 10080 <end+0x68cc>
    1344:	13300713          	li	a4,307
    1348:	00e7a023          	sw	a4,0(a5)
    134c:	000087b7          	lui	a5,0x8
    1350:	0007a783          	lw	a5,0(a5) # 8000 <ser_port>
    1354:	00078513          	mv	a0,a5
    1358:	259000ef          	jal	ra,1db0 <server_port>
    135c:	1ad000ef          	jal	ra,1d08 <server_start>
    1360:	000107b7          	lui	a5,0x10
    1364:	08078793          	addi	a5,a5,128 # 10080 <end+0x68cc>
    1368:	13100713          	li	a4,305
    136c:	00e7a023          	sw	a4,0(a5)
    1370:	01600613          	li	a2,22
    1374:	00000593          	li	a1,0
    1378:	000047b7          	lui	a5,0x4
    137c:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1380:	384000ef          	jal	ra,1704 <get_bit>
    1384:	00050793          	mv	a5,a0
    1388:	0017c793          	xori	a5,a5,1
    138c:	0ff7f793          	andi	a5,a5,255
    1390:	0a078863          	beqz	a5,1440 <main+0x134>
    1394:	000087b7          	lui	a5,0x8
    1398:	04478513          	addi	a0,a5,68 # 8044 <UDP_rx_data>
    139c:	474000ef          	jal	ra,1810 <UDP_rx>
    13a0:	fea42623          	sw	a0,-20(s0)
    13a4:	fec42783          	lw	a5,-20(s0)
    13a8:	00078593          	mv	a1,a5
    13ac:	000087b7          	lui	a5,0x8
    13b0:	04478513          	addi	a0,a5,68 # 8044 <UDP_rx_data>
    13b4:	4e4000ef          	jal	ra,1898 <UDP_tx>
    13b8:	fec42783          	lw	a5,-20(s0)
    13bc:	00078593          	mv	a1,a5
    13c0:	000087b7          	lui	a5,0x8
    13c4:	04478513          	addi	a0,a5,68 # 8044 <UDP_rx_data>
    13c8:	eb1ff0ef          	jal	ra,1278 <SM3_WRITE>
    13cc:	000087b7          	lui	a5,0x8
    13d0:	0007a783          	lw	a5,0(a5) # 8000 <ser_port>
    13d4:	00178713          	addi	a4,a5,1
    13d8:	000087b7          	lui	a5,0x8
    13dc:	00e7a023          	sw	a4,0(a5) # 8000 <ser_port>
    13e0:	fec42703          	lw	a4,-20(s0)
    13e4:	00100793          	li	a5,1
    13e8:	04f71c63          	bne	a4,a5,1440 <main+0x134>
    13ec:	000087b7          	lui	a5,0x8
    13f0:	0447c703          	lbu	a4,68(a5) # 8044 <UDP_rx_data>
    13f4:	03100793          	li	a5,49
    13f8:	02f71063          	bne	a4,a5,1418 <main+0x10c>
    13fc:	161000ef          	jal	ra,1d5c <server_close>
    1400:	6ec000ef          	jal	ra,1aec <client_close>
    1404:	000087b7          	lui	a5,0x8
    1408:	0007a783          	lw	a5,0(a5) # 8000 <ser_port>
    140c:	00078513          	mv	a0,a5
    1410:	730000ef          	jal	ra,1b40 <client_port>
    1414:	02c0006f          	j	1440 <main+0x134>
    1418:	000087b7          	lui	a5,0x8
    141c:	0447c703          	lbu	a4,68(a5) # 8044 <UDP_rx_data>
    1420:	03200793          	li	a5,50
    1424:	00f71e63          	bne	a4,a5,1440 <main+0x134>
    1428:	00600593          	li	a1,6
    142c:	000087b7          	lui	a5,0x8
    1430:	00478513          	addi	a0,a5,4 # 8004 <zzy>
    1434:	464000ef          	jal	ra,1898 <UDP_tx>
    1438:	0d1000ef          	jal	ra,1d08 <server_start>
    143c:	65c000ef          	jal	ra,1a98 <client_start>
    1440:	01600613          	li	a2,22
    1444:	00800593          	li	a1,8
    1448:	000047b7          	lui	a5,0x4
    144c:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1450:	2b4000ef          	jal	ra,1704 <get_bit>
    1454:	00050793          	mv	a5,a0
    1458:	0017c793          	xori	a5,a5,1
    145c:	0ff7f793          	andi	a5,a5,255
    1460:	02078463          	beqz	a5,1488 <main+0x17c>
    1464:	000097b7          	lui	a5,0x9
    1468:	81478513          	addi	a0,a5,-2028 # 8814 <client_rx_data>
    146c:	510000ef          	jal	ra,197c <client_rx>
    1470:	fea42423          	sw	a0,-24(s0)
    1474:	fe842783          	lw	a5,-24(s0)
    1478:	00078593          	mv	a1,a5
    147c:	000097b7          	lui	a5,0x9
    1480:	81478513          	addi	a0,a5,-2028 # 8814 <client_rx_data>
    1484:	580000ef          	jal	ra,1a04 <client_tx>
    1488:	01600613          	li	a2,22
    148c:	00400593          	li	a1,4
    1490:	000047b7          	lui	a5,0x4
    1494:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1498:	26c000ef          	jal	ra,1704 <get_bit>
    149c:	00050793          	mv	a5,a0
    14a0:	0017c793          	xori	a5,a5,1
    14a4:	0ff7f793          	andi	a5,a5,255
    14a8:	ec0784e3          	beqz	a5,1370 <main+0x64>
    14ac:	000097b7          	lui	a5,0x9
    14b0:	fe478513          	addi	a0,a5,-28 # 8fe4 <server_rx_data>
    14b4:	738000ef          	jal	ra,1bec <server_rx>
    14b8:	fea42223          	sw	a0,-28(s0)
    14bc:	fe442783          	lw	a5,-28(s0)
    14c0:	00078593          	mv	a1,a5
    14c4:	000097b7          	lui	a5,0x9
    14c8:	fe478513          	addi	a0,a5,-28 # 8fe4 <server_rx_data>
    14cc:	7a8000ef          	jal	ra,1c74 <server_tx>
    14d0:	ea1ff06f          	j	1370 <main+0x64>

000014d4 <irq>:
    14d4:	fb010113          	addi	sp,sp,-80
    14d8:	04112623          	sw	ra,76(sp)
    14dc:	04812423          	sw	s0,72(sp)
    14e0:	05010413          	addi	s0,sp,80
    14e4:	faa42e23          	sw	a0,-68(s0)
    14e8:	fab42c23          	sw	a1,-72(s0)
    14ec:	fb842783          	lw	a5,-72(s0)
    14f0:	0017f793          	andi	a5,a5,1
    14f4:	08078c63          	beqz	a5,158c <irq+0xb8>
    14f8:	fe042623          	sw	zero,-20(s0)
    14fc:	0740006f          	j	1570 <irq+0x9c>
    1500:	000107b7          	lui	a5,0x10
    1504:	0a078793          	addi	a5,a5,160 # 100a0 <end+0x68ec>
    1508:	0007a783          	lw	a5,0(a5)
    150c:	fef42223          	sw	a5,-28(s0)
    1510:	00300793          	li	a5,3
    1514:	fef42423          	sw	a5,-24(s0)
    1518:	0440006f          	j	155c <irq+0x88>
    151c:	fe842783          	lw	a5,-24(s0)
    1520:	00379793          	slli	a5,a5,0x3
    1524:	fe442703          	lw	a4,-28(s0)
    1528:	00f756b3          	srl	a3,a4,a5
    152c:	fec42783          	lw	a5,-20(s0)
    1530:	00279793          	slli	a5,a5,0x2
    1534:	00378713          	addi	a4,a5,3
    1538:	fe842783          	lw	a5,-24(s0)
    153c:	40f707b3          	sub	a5,a4,a5
    1540:	0ff6f713          	andi	a4,a3,255
    1544:	ff040693          	addi	a3,s0,-16
    1548:	00f687b3          	add	a5,a3,a5
    154c:	fce78a23          	sb	a4,-44(a5)
    1550:	fe842783          	lw	a5,-24(s0)
    1554:	fff78793          	addi	a5,a5,-1
    1558:	fef42423          	sw	a5,-24(s0)
    155c:	fe842783          	lw	a5,-24(s0)
    1560:	fa07dee3          	bgez	a5,151c <irq+0x48>
    1564:	fec42783          	lw	a5,-20(s0)
    1568:	00178793          	addi	a5,a5,1
    156c:	fef42623          	sw	a5,-20(s0)
    1570:	fec42703          	lw	a4,-20(s0)
    1574:	00700793          	li	a5,7
    1578:	f8e7d4e3          	ble	a4,a5,1500 <irq+0x2c>
    157c:	fc440793          	addi	a5,s0,-60
    1580:	02000593          	li	a1,32
    1584:	00078513          	mv	a0,a5
    1588:	310000ef          	jal	ra,1898 <UDP_tx>
    158c:	fb842783          	lw	a5,-72(s0)
    1590:	0027f793          	andi	a5,a5,2
    1594:	02078663          	beqz	a5,15c0 <irq+0xec>
    1598:	000107b7          	lui	a5,0x10
    159c:	04878793          	addi	a5,a5,72 # 10048 <end+0x6894>
    15a0:	00200713          	li	a4,2
    15a4:	00e7a023          	sw	a4,0(a5)
    15a8:	fbc42783          	lw	a5,-68(s0)
    15ac:	00478713          	addi	a4,a5,4
    15b0:	000107b7          	lui	a5,0x10
    15b4:	04878793          	addi	a5,a5,72 # 10048 <end+0x6894>
    15b8:	00072703          	lw	a4,0(a4)
    15bc:	00e7a023          	sw	a4,0(a5)
    15c0:	fb842783          	lw	a5,-72(s0)
    15c4:	0047f793          	andi	a5,a5,4
    15c8:	02078663          	beqz	a5,15f4 <irq+0x120>
    15cc:	000107b7          	lui	a5,0x10
    15d0:	04878793          	addi	a5,a5,72 # 10048 <end+0x6894>
    15d4:	00300713          	li	a4,3
    15d8:	00e7a023          	sw	a4,0(a5)
    15dc:	fbc42783          	lw	a5,-68(s0)
    15e0:	00878713          	addi	a4,a5,8
    15e4:	000107b7          	lui	a5,0x10
    15e8:	04878793          	addi	a5,a5,72 # 10048 <end+0x6894>
    15ec:	00072703          	lw	a4,0(a4)
    15f0:	00e7a023          	sw	a4,0(a5)
    15f4:	fbc42783          	lw	a5,-68(s0)
    15f8:	00078513          	mv	a0,a5
    15fc:	04c12083          	lw	ra,76(sp)
    1600:	04812403          	lw	s0,72(sp)
    1604:	05010113          	addi	sp,sp,80
    1608:	00008067          	ret

0000160c <Gpio_in>:
    160c:	ff010113          	addi	sp,sp,-16
    1610:	00812623          	sw	s0,12(sp)
    1614:	01010413          	addi	s0,sp,16
    1618:	000107b7          	lui	a5,0x10
    161c:	00c78793          	addi	a5,a5,12 # 1000c <end+0x6858>
    1620:	0007a783          	lw	a5,0(a5)
    1624:	00078513          	mv	a0,a5
    1628:	00c12403          	lw	s0,12(sp)
    162c:	01010113          	addi	sp,sp,16
    1630:	00008067          	ret

00001634 <set_bit>:
    1634:	fe010113          	addi	sp,sp,-32
    1638:	00812e23          	sw	s0,28(sp)
    163c:	02010413          	addi	s0,sp,32
    1640:	fea42623          	sw	a0,-20(s0)
    1644:	feb42423          	sw	a1,-24(s0)
    1648:	fec42223          	sw	a2,-28(s0)
    164c:	00068793          	mv	a5,a3
    1650:	fef401a3          	sb	a5,-29(s0)
    1654:	fe344783          	lbu	a5,-29(s0)
    1658:	0017c793          	xori	a5,a5,1
    165c:	0ff7f793          	andi	a5,a5,255
    1660:	04078863          	beqz	a5,16b0 <set_bit+0x7c>
    1664:	fec42783          	lw	a5,-20(s0)
    1668:	00279713          	slli	a4,a5,0x2
    166c:	fe842783          	lw	a5,-24(s0)
    1670:	00279793          	slli	a5,a5,0x2
    1674:	00f707b3          	add	a5,a4,a5
    1678:	0007a783          	lw	a5,0(a5)
    167c:	00100693          	li	a3,1
    1680:	fe442703          	lw	a4,-28(s0)
    1684:	00e69733          	sll	a4,a3,a4
    1688:	fff74713          	not	a4,a4
    168c:	00070613          	mv	a2,a4
    1690:	fec42703          	lw	a4,-20(s0)
    1694:	00271693          	slli	a3,a4,0x2
    1698:	fe842703          	lw	a4,-24(s0)
    169c:	00271713          	slli	a4,a4,0x2
    16a0:	00e68733          	add	a4,a3,a4
    16a4:	00c7f7b3          	and	a5,a5,a2
    16a8:	00f72023          	sw	a5,0(a4)
    16ac:	0480006f          	j	16f4 <set_bit+0xc0>
    16b0:	fec42783          	lw	a5,-20(s0)
    16b4:	00279713          	slli	a4,a5,0x2
    16b8:	fe842783          	lw	a5,-24(s0)
    16bc:	00279793          	slli	a5,a5,0x2
    16c0:	00f707b3          	add	a5,a4,a5
    16c4:	0007a783          	lw	a5,0(a5)
    16c8:	00100693          	li	a3,1
    16cc:	fe442703          	lw	a4,-28(s0)
    16d0:	00e69733          	sll	a4,a3,a4
    16d4:	00070613          	mv	a2,a4
    16d8:	fec42703          	lw	a4,-20(s0)
    16dc:	00271693          	slli	a3,a4,0x2
    16e0:	fe842703          	lw	a4,-24(s0)
    16e4:	00271713          	slli	a4,a4,0x2
    16e8:	00e68733          	add	a4,a3,a4
    16ec:	00c7e7b3          	or	a5,a5,a2
    16f0:	00f72023          	sw	a5,0(a4)
    16f4:	00000013          	nop
    16f8:	01c12403          	lw	s0,28(sp)
    16fc:	02010113          	addi	sp,sp,32
    1700:	00008067          	ret

00001704 <get_bit>:
    1704:	fe010113          	addi	sp,sp,-32
    1708:	00812e23          	sw	s0,28(sp)
    170c:	02010413          	addi	s0,sp,32
    1710:	fea42623          	sw	a0,-20(s0)
    1714:	feb42423          	sw	a1,-24(s0)
    1718:	fec42223          	sw	a2,-28(s0)
    171c:	fec42783          	lw	a5,-20(s0)
    1720:	00279713          	slli	a4,a5,0x2
    1724:	fe842783          	lw	a5,-24(s0)
    1728:	00279793          	slli	a5,a5,0x2
    172c:	00f707b3          	add	a5,a4,a5
    1730:	0007a783          	lw	a5,0(a5)
    1734:	00100693          	li	a3,1
    1738:	fe442703          	lw	a4,-28(s0)
    173c:	00e69733          	sll	a4,a3,a4
    1740:	00e7f7b3          	and	a5,a5,a4
    1744:	00078663          	beqz	a5,1750 <get_bit+0x4c>
    1748:	00100793          	li	a5,1
    174c:	0080006f          	j	1754 <get_bit+0x50>
    1750:	00000793          	li	a5,0
    1754:	00078513          	mv	a0,a5
    1758:	01c12403          	lw	s0,28(sp)
    175c:	02010113          	addi	sp,sp,32
    1760:	00008067          	ret

00001764 <delay_1s>:
    1764:	fe010113          	addi	sp,sp,-32
    1768:	00812e23          	sw	s0,28(sp)
    176c:	02010413          	addi	s0,sp,32
    1770:	fe042623          	sw	zero,-20(s0)
    1774:	0300006f          	j	17a4 <delay_1s+0x40>
    1778:	fe042423          	sw	zero,-24(s0)
    177c:	0100006f          	j	178c <delay_1s+0x28>
    1780:	fe842783          	lw	a5,-24(s0)
    1784:	00178793          	addi	a5,a5,1
    1788:	fef42423          	sw	a5,-24(s0)
    178c:	fe842703          	lw	a4,-24(s0)
    1790:	5db00793          	li	a5,1499
    1794:	fee7d6e3          	ble	a4,a5,1780 <delay_1s+0x1c>
    1798:	fec42783          	lw	a5,-20(s0)
    179c:	00178793          	addi	a5,a5,1
    17a0:	fef42623          	sw	a5,-20(s0)
    17a4:	fec42703          	lw	a4,-20(s0)
    17a8:	3e700793          	li	a5,999
    17ac:	fce7d6e3          	ble	a4,a5,1778 <delay_1s+0x14>
    17b0:	00000013          	nop
    17b4:	01c12403          	lw	s0,28(sp)
    17b8:	02010113          	addi	sp,sp,32
    17bc:	00008067          	ret

000017c0 <UDP_stat>:
    17c0:	ff010113          	addi	sp,sp,-16
    17c4:	00812623          	sw	s0,12(sp)
    17c8:	01010413          	addi	s0,sp,16
    17cc:	000107b7          	lui	a5,0x10
    17d0:	04078793          	addi	a5,a5,64 # 10040 <end+0x688c>
    17d4:	0007a783          	lw	a5,0(a5)
    17d8:	00078513          	mv	a0,a5
    17dc:	00c12403          	lw	s0,12(sp)
    17e0:	01010113          	addi	sp,sp,16
    17e4:	00008067          	ret

000017e8 <UDP_rx_byte>:
    17e8:	ff010113          	addi	sp,sp,-16
    17ec:	00812623          	sw	s0,12(sp)
    17f0:	01010413          	addi	s0,sp,16
    17f4:	000107b7          	lui	a5,0x10
    17f8:	04c78793          	addi	a5,a5,76 # 1004c <end+0x6898>
    17fc:	0007a783          	lw	a5,0(a5)
    1800:	00078513          	mv	a0,a5
    1804:	00c12403          	lw	s0,12(sp)
    1808:	01010113          	addi	sp,sp,16
    180c:	00008067          	ret

00001810 <UDP_rx>:
    1810:	fd010113          	addi	sp,sp,-48
    1814:	02112623          	sw	ra,44(sp)
    1818:	02812423          	sw	s0,40(sp)
    181c:	03010413          	addi	s0,sp,48
    1820:	fca42e23          	sw	a0,-36(s0)
    1824:	fe042623          	sw	zero,-20(s0)
    1828:	fe042423          	sw	zero,-24(s0)
    182c:	f95ff0ef          	jal	ra,17c0 <UDP_stat>
    1830:	00050713          	mv	a4,a0
    1834:	000107b7          	lui	a5,0x10
    1838:	fff78793          	addi	a5,a5,-1 # ffff <end+0x684b>
    183c:	00f777b3          	and	a5,a4,a5
    1840:	fef42223          	sw	a5,-28(s0)
    1844:	0300006f          	j	1874 <UDP_rx+0x64>
    1848:	fa1ff0ef          	jal	ra,17e8 <UDP_rx_byte>
    184c:	fea42423          	sw	a0,-24(s0)
    1850:	fec42783          	lw	a5,-20(s0)
    1854:	fdc42703          	lw	a4,-36(s0)
    1858:	00f707b3          	add	a5,a4,a5
    185c:	fe842703          	lw	a4,-24(s0)
    1860:	0ff77713          	andi	a4,a4,255
    1864:	00e78023          	sb	a4,0(a5)
    1868:	fec42783          	lw	a5,-20(s0)
    186c:	00178793          	addi	a5,a5,1
    1870:	fef42623          	sw	a5,-20(s0)
    1874:	fe842783          	lw	a5,-24(s0)
    1878:	1007f793          	andi	a5,a5,256
    187c:	fc0786e3          	beqz	a5,1848 <UDP_rx+0x38>
    1880:	fe442783          	lw	a5,-28(s0)
    1884:	00078513          	mv	a0,a5
    1888:	02c12083          	lw	ra,44(sp)
    188c:	02812403          	lw	s0,40(sp)
    1890:	03010113          	addi	sp,sp,48
    1894:	00008067          	ret

00001898 <UDP_tx>:
    1898:	fd010113          	addi	sp,sp,-48
    189c:	02812623          	sw	s0,44(sp)
    18a0:	03010413          	addi	s0,sp,48
    18a4:	fca42e23          	sw	a0,-36(s0)
    18a8:	fcb42c23          	sw	a1,-40(s0)
    18ac:	fe042623          	sw	zero,-20(s0)
    18b0:	0600006f          	j	1910 <UDP_tx+0x78>
    18b4:	fd842783          	lw	a5,-40(s0)
    18b8:	fff78793          	addi	a5,a5,-1
    18bc:	fec42703          	lw	a4,-20(s0)
    18c0:	02f71463          	bne	a4,a5,18e8 <UDP_tx+0x50>
    18c4:	fdc42703          	lw	a4,-36(s0)
    18c8:	fec42783          	lw	a5,-20(s0)
    18cc:	00f707b3          	add	a5,a4,a5
    18d0:	0007c783          	lbu	a5,0(a5)
    18d4:	1007e713          	ori	a4,a5,256
    18d8:	000107b7          	lui	a5,0x10
    18dc:	04878793          	addi	a5,a5,72 # 10048 <end+0x6894>
    18e0:	00e7a023          	sw	a4,0(a5)
    18e4:	0200006f          	j	1904 <UDP_tx+0x6c>
    18e8:	fdc42703          	lw	a4,-36(s0)
    18ec:	fec42783          	lw	a5,-20(s0)
    18f0:	00f707b3          	add	a5,a4,a5
    18f4:	0007c703          	lbu	a4,0(a5)
    18f8:	000107b7          	lui	a5,0x10
    18fc:	04878793          	addi	a5,a5,72 # 10048 <end+0x6894>
    1900:	00e7a023          	sw	a4,0(a5)
    1904:	fec42783          	lw	a5,-20(s0)
    1908:	00178793          	addi	a5,a5,1
    190c:	fef42623          	sw	a5,-20(s0)
    1910:	fec42703          	lw	a4,-20(s0)
    1914:	fd842783          	lw	a5,-40(s0)
    1918:	f8f76ee3          	bltu	a4,a5,18b4 <UDP_tx+0x1c>
    191c:	00000013          	nop
    1920:	02c12403          	lw	s0,44(sp)
    1924:	03010113          	addi	sp,sp,48
    1928:	00008067          	ret

0000192c <client_stat>:
    192c:	ff010113          	addi	sp,sp,-16
    1930:	00812623          	sw	s0,12(sp)
    1934:	01010413          	addi	s0,sp,16
    1938:	000107b7          	lui	a5,0x10
    193c:	06078793          	addi	a5,a5,96 # 10060 <end+0x68ac>
    1940:	0007a783          	lw	a5,0(a5)
    1944:	00078513          	mv	a0,a5
    1948:	00c12403          	lw	s0,12(sp)
    194c:	01010113          	addi	sp,sp,16
    1950:	00008067          	ret

00001954 <client_rx_byte>:
    1954:	ff010113          	addi	sp,sp,-16
    1958:	00812623          	sw	s0,12(sp)
    195c:	01010413          	addi	s0,sp,16
    1960:	000107b7          	lui	a5,0x10
    1964:	06c78793          	addi	a5,a5,108 # 1006c <end+0x68b8>
    1968:	0007a783          	lw	a5,0(a5)
    196c:	00078513          	mv	a0,a5
    1970:	00c12403          	lw	s0,12(sp)
    1974:	01010113          	addi	sp,sp,16
    1978:	00008067          	ret

0000197c <client_rx>:
    197c:	fd010113          	addi	sp,sp,-48
    1980:	02112623          	sw	ra,44(sp)
    1984:	02812423          	sw	s0,40(sp)
    1988:	03010413          	addi	s0,sp,48
    198c:	fca42e23          	sw	a0,-36(s0)
    1990:	fe042623          	sw	zero,-20(s0)
    1994:	fe042423          	sw	zero,-24(s0)
    1998:	f95ff0ef          	jal	ra,192c <client_stat>
    199c:	00050713          	mv	a4,a0
    19a0:	000107b7          	lui	a5,0x10
    19a4:	fff78793          	addi	a5,a5,-1 # ffff <end+0x684b>
    19a8:	00f777b3          	and	a5,a4,a5
    19ac:	fef42223          	sw	a5,-28(s0)
    19b0:	0300006f          	j	19e0 <client_rx+0x64>
    19b4:	fa1ff0ef          	jal	ra,1954 <client_rx_byte>
    19b8:	fea42423          	sw	a0,-24(s0)
    19bc:	fec42783          	lw	a5,-20(s0)
    19c0:	fdc42703          	lw	a4,-36(s0)
    19c4:	00f707b3          	add	a5,a4,a5
    19c8:	fe842703          	lw	a4,-24(s0)
    19cc:	0ff77713          	andi	a4,a4,255
    19d0:	00e78023          	sb	a4,0(a5)
    19d4:	fec42783          	lw	a5,-20(s0)
    19d8:	00178793          	addi	a5,a5,1
    19dc:	fef42623          	sw	a5,-20(s0)
    19e0:	fe842783          	lw	a5,-24(s0)
    19e4:	1007f793          	andi	a5,a5,256
    19e8:	fc0786e3          	beqz	a5,19b4 <client_rx+0x38>
    19ec:	fe442783          	lw	a5,-28(s0)
    19f0:	00078513          	mv	a0,a5
    19f4:	02c12083          	lw	ra,44(sp)
    19f8:	02812403          	lw	s0,40(sp)
    19fc:	03010113          	addi	sp,sp,48
    1a00:	00008067          	ret

00001a04 <client_tx>:
    1a04:	fd010113          	addi	sp,sp,-48
    1a08:	02812623          	sw	s0,44(sp)
    1a0c:	03010413          	addi	s0,sp,48
    1a10:	fca42e23          	sw	a0,-36(s0)
    1a14:	fcb42c23          	sw	a1,-40(s0)
    1a18:	fe042623          	sw	zero,-20(s0)
    1a1c:	0600006f          	j	1a7c <client_tx+0x78>
    1a20:	fd842783          	lw	a5,-40(s0)
    1a24:	fff78713          	addi	a4,a5,-1
    1a28:	fec42783          	lw	a5,-20(s0)
    1a2c:	02f71463          	bne	a4,a5,1a54 <client_tx+0x50>
    1a30:	fec42783          	lw	a5,-20(s0)
    1a34:	fdc42703          	lw	a4,-36(s0)
    1a38:	00f707b3          	add	a5,a4,a5
    1a3c:	0007c783          	lbu	a5,0(a5)
    1a40:	1007e713          	ori	a4,a5,256
    1a44:	000107b7          	lui	a5,0x10
    1a48:	06878793          	addi	a5,a5,104 # 10068 <end+0x68b4>
    1a4c:	00e7a023          	sw	a4,0(a5)
    1a50:	0200006f          	j	1a70 <client_tx+0x6c>
    1a54:	fec42783          	lw	a5,-20(s0)
    1a58:	fdc42703          	lw	a4,-36(s0)
    1a5c:	00f707b3          	add	a5,a4,a5
    1a60:	0007c703          	lbu	a4,0(a5)
    1a64:	000107b7          	lui	a5,0x10
    1a68:	06878793          	addi	a5,a5,104 # 10068 <end+0x68b4>
    1a6c:	00e7a023          	sw	a4,0(a5)
    1a70:	fec42783          	lw	a5,-20(s0)
    1a74:	00178793          	addi	a5,a5,1
    1a78:	fef42623          	sw	a5,-20(s0)
    1a7c:	fec42783          	lw	a5,-20(s0)
    1a80:	fd842703          	lw	a4,-40(s0)
    1a84:	f8e7eee3          	bltu	a5,a4,1a20 <client_tx+0x1c>
    1a88:	00000013          	nop
    1a8c:	02c12403          	lw	s0,44(sp)
    1a90:	03010113          	addi	sp,sp,48
    1a94:	00008067          	ret

00001a98 <client_start>:
    1a98:	ff010113          	addi	sp,sp,-16
    1a9c:	00112623          	sw	ra,12(sp)
    1aa0:	00812423          	sw	s0,8(sp)
    1aa4:	01010413          	addi	s0,sp,16
    1aa8:	00000693          	li	a3,0
    1aac:	01100613          	li	a2,17
    1ab0:	00900593          	li	a1,9
    1ab4:	000047b7          	lui	a5,0x4
    1ab8:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1abc:	b79ff0ef          	jal	ra,1634 <set_bit>
    1ac0:	00100693          	li	a3,1
    1ac4:	01000613          	li	a2,16
    1ac8:	00900593          	li	a1,9
    1acc:	000047b7          	lui	a5,0x4
    1ad0:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1ad4:	b61ff0ef          	jal	ra,1634 <set_bit>
    1ad8:	00000013          	nop
    1adc:	00c12083          	lw	ra,12(sp)
    1ae0:	00812403          	lw	s0,8(sp)
    1ae4:	01010113          	addi	sp,sp,16
    1ae8:	00008067          	ret

00001aec <client_close>:
    1aec:	ff010113          	addi	sp,sp,-16
    1af0:	00112623          	sw	ra,12(sp)
    1af4:	00812423          	sw	s0,8(sp)
    1af8:	01010413          	addi	s0,sp,16
    1afc:	00000693          	li	a3,0
    1b00:	01000613          	li	a2,16
    1b04:	00900593          	li	a1,9
    1b08:	000047b7          	lui	a5,0x4
    1b0c:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1b10:	b25ff0ef          	jal	ra,1634 <set_bit>
    1b14:	00100693          	li	a3,1
    1b18:	01100613          	li	a2,17
    1b1c:	00900593          	li	a1,9
    1b20:	000047b7          	lui	a5,0x4
    1b24:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1b28:	b0dff0ef          	jal	ra,1634 <set_bit>
    1b2c:	00000013          	nop
    1b30:	00c12083          	lw	ra,12(sp)
    1b34:	00812403          	lw	s0,8(sp)
    1b38:	01010113          	addi	sp,sp,16
    1b3c:	00008067          	ret

00001b40 <client_port>:
    1b40:	fd010113          	addi	sp,sp,-48
    1b44:	02812623          	sw	s0,44(sp)
    1b48:	03010413          	addi	s0,sp,48
    1b4c:	fca42e23          	sw	a0,-36(s0)
    1b50:	000107b7          	lui	a5,0x10
    1b54:	06478793          	addi	a5,a5,100 # 10064 <end+0x68b0>
    1b58:	0007a783          	lw	a5,0(a5)
    1b5c:	fef42623          	sw	a5,-20(s0)
    1b60:	fec42703          	lw	a4,-20(s0)
    1b64:	ffff07b7          	lui	a5,0xffff0
    1b68:	00f776b3          	and	a3,a4,a5
    1b6c:	fdc42703          	lw	a4,-36(s0)
    1b70:	000107b7          	lui	a5,0x10
    1b74:	fff78793          	addi	a5,a5,-1 # ffff <end+0x684b>
    1b78:	00f77733          	and	a4,a4,a5
    1b7c:	000107b7          	lui	a5,0x10
    1b80:	06478793          	addi	a5,a5,100 # 10064 <end+0x68b0>
    1b84:	00e6e733          	or	a4,a3,a4
    1b88:	00e7a023          	sw	a4,0(a5)
    1b8c:	00000013          	nop
    1b90:	02c12403          	lw	s0,44(sp)
    1b94:	03010113          	addi	sp,sp,48
    1b98:	00008067          	ret

00001b9c <server_stat>:
    1b9c:	ff010113          	addi	sp,sp,-16
    1ba0:	00812623          	sw	s0,12(sp)
    1ba4:	01010413          	addi	s0,sp,16
    1ba8:	000107b7          	lui	a5,0x10
    1bac:	05078793          	addi	a5,a5,80 # 10050 <end+0x689c>
    1bb0:	0007a783          	lw	a5,0(a5)
    1bb4:	00078513          	mv	a0,a5
    1bb8:	00c12403          	lw	s0,12(sp)
    1bbc:	01010113          	addi	sp,sp,16
    1bc0:	00008067          	ret

00001bc4 <server_rx_byte>:
    1bc4:	ff010113          	addi	sp,sp,-16
    1bc8:	00812623          	sw	s0,12(sp)
    1bcc:	01010413          	addi	s0,sp,16
    1bd0:	000107b7          	lui	a5,0x10
    1bd4:	05c78793          	addi	a5,a5,92 # 1005c <end+0x68a8>
    1bd8:	0007a783          	lw	a5,0(a5)
    1bdc:	00078513          	mv	a0,a5
    1be0:	00c12403          	lw	s0,12(sp)
    1be4:	01010113          	addi	sp,sp,16
    1be8:	00008067          	ret

00001bec <server_rx>:
    1bec:	fd010113          	addi	sp,sp,-48
    1bf0:	02112623          	sw	ra,44(sp)
    1bf4:	02812423          	sw	s0,40(sp)
    1bf8:	03010413          	addi	s0,sp,48
    1bfc:	fca42e23          	sw	a0,-36(s0)
    1c00:	fe042623          	sw	zero,-20(s0)
    1c04:	fe042423          	sw	zero,-24(s0)
    1c08:	f95ff0ef          	jal	ra,1b9c <server_stat>
    1c0c:	00050713          	mv	a4,a0
    1c10:	000107b7          	lui	a5,0x10
    1c14:	fff78793          	addi	a5,a5,-1 # ffff <end+0x684b>
    1c18:	00f777b3          	and	a5,a4,a5
    1c1c:	fef42223          	sw	a5,-28(s0)
    1c20:	0300006f          	j	1c50 <server_rx+0x64>
    1c24:	fa1ff0ef          	jal	ra,1bc4 <server_rx_byte>
    1c28:	fea42423          	sw	a0,-24(s0)
    1c2c:	fec42783          	lw	a5,-20(s0)
    1c30:	fdc42703          	lw	a4,-36(s0)
    1c34:	00f707b3          	add	a5,a4,a5
    1c38:	fe842703          	lw	a4,-24(s0)
    1c3c:	0ff77713          	andi	a4,a4,255
    1c40:	00e78023          	sb	a4,0(a5)
    1c44:	fec42783          	lw	a5,-20(s0)
    1c48:	00178793          	addi	a5,a5,1
    1c4c:	fef42623          	sw	a5,-20(s0)
    1c50:	fe842783          	lw	a5,-24(s0)
    1c54:	1007f793          	andi	a5,a5,256
    1c58:	fc0786e3          	beqz	a5,1c24 <server_rx+0x38>
    1c5c:	fe442783          	lw	a5,-28(s0)
    1c60:	00078513          	mv	a0,a5
    1c64:	02c12083          	lw	ra,44(sp)
    1c68:	02812403          	lw	s0,40(sp)
    1c6c:	03010113          	addi	sp,sp,48
    1c70:	00008067          	ret

00001c74 <server_tx>:
    1c74:	fd010113          	addi	sp,sp,-48
    1c78:	02812623          	sw	s0,44(sp)
    1c7c:	03010413          	addi	s0,sp,48
    1c80:	fca42e23          	sw	a0,-36(s0)
    1c84:	fcb42c23          	sw	a1,-40(s0)
    1c88:	fe042623          	sw	zero,-20(s0)
    1c8c:	0600006f          	j	1cec <server_tx+0x78>
    1c90:	fd842783          	lw	a5,-40(s0)
    1c94:	fff78713          	addi	a4,a5,-1
    1c98:	fec42783          	lw	a5,-20(s0)
    1c9c:	02f71463          	bne	a4,a5,1cc4 <server_tx+0x50>
    1ca0:	fec42783          	lw	a5,-20(s0)
    1ca4:	fdc42703          	lw	a4,-36(s0)
    1ca8:	00f707b3          	add	a5,a4,a5
    1cac:	0007c783          	lbu	a5,0(a5)
    1cb0:	1007e713          	ori	a4,a5,256
    1cb4:	000107b7          	lui	a5,0x10
    1cb8:	05878793          	addi	a5,a5,88 # 10058 <end+0x68a4>
    1cbc:	00e7a023          	sw	a4,0(a5)
    1cc0:	0200006f          	j	1ce0 <server_tx+0x6c>
    1cc4:	fec42783          	lw	a5,-20(s0)
    1cc8:	fdc42703          	lw	a4,-36(s0)
    1ccc:	00f707b3          	add	a5,a4,a5
    1cd0:	0007c703          	lbu	a4,0(a5)
    1cd4:	000107b7          	lui	a5,0x10
    1cd8:	05878793          	addi	a5,a5,88 # 10058 <end+0x68a4>
    1cdc:	00e7a023          	sw	a4,0(a5)
    1ce0:	fec42783          	lw	a5,-20(s0)
    1ce4:	00178793          	addi	a5,a5,1
    1ce8:	fef42623          	sw	a5,-20(s0)
    1cec:	fec42783          	lw	a5,-20(s0)
    1cf0:	fd842703          	lw	a4,-40(s0)
    1cf4:	f8e7eee3          	bltu	a5,a4,1c90 <server_tx+0x1c>
    1cf8:	00000013          	nop
    1cfc:	02c12403          	lw	s0,44(sp)
    1d00:	03010113          	addi	sp,sp,48
    1d04:	00008067          	ret

00001d08 <server_start>:
    1d08:	ff010113          	addi	sp,sp,-16
    1d0c:	00112623          	sw	ra,12(sp)
    1d10:	00812423          	sw	s0,8(sp)
    1d14:	01010413          	addi	s0,sp,16
    1d18:	00000693          	li	a3,0
    1d1c:	01100613          	li	a2,17
    1d20:	00500593          	li	a1,5
    1d24:	000047b7          	lui	a5,0x4
    1d28:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1d2c:	909ff0ef          	jal	ra,1634 <set_bit>
    1d30:	00100693          	li	a3,1
    1d34:	01000613          	li	a2,16
    1d38:	00500593          	li	a1,5
    1d3c:	000047b7          	lui	a5,0x4
    1d40:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1d44:	8f1ff0ef          	jal	ra,1634 <set_bit>
    1d48:	00000013          	nop
    1d4c:	00c12083          	lw	ra,12(sp)
    1d50:	00812403          	lw	s0,8(sp)
    1d54:	01010113          	addi	sp,sp,16
    1d58:	00008067          	ret

00001d5c <server_close>:
    1d5c:	ff010113          	addi	sp,sp,-16
    1d60:	00112623          	sw	ra,12(sp)
    1d64:	00812423          	sw	s0,8(sp)
    1d68:	01010413          	addi	s0,sp,16
    1d6c:	00000693          	li	a3,0
    1d70:	01000613          	li	a2,16
    1d74:	00500593          	li	a1,5
    1d78:	000047b7          	lui	a5,0x4
    1d7c:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1d80:	8b5ff0ef          	jal	ra,1634 <set_bit>
    1d84:	00100693          	li	a3,1
    1d88:	01100613          	li	a2,17
    1d8c:	00500593          	li	a1,5
    1d90:	000047b7          	lui	a5,0x4
    1d94:	01078513          	addi	a0,a5,16 # 4010 <server_port+0x2260>
    1d98:	89dff0ef          	jal	ra,1634 <set_bit>
    1d9c:	00000013          	nop
    1da0:	00c12083          	lw	ra,12(sp)
    1da4:	00812403          	lw	s0,8(sp)
    1da8:	01010113          	addi	sp,sp,16
    1dac:	00008067          	ret

00001db0 <server_port>:
    1db0:	fd010113          	addi	sp,sp,-48
    1db4:	02812623          	sw	s0,44(sp)
    1db8:	03010413          	addi	s0,sp,48
    1dbc:	fca42e23          	sw	a0,-36(s0)
    1dc0:	000107b7          	lui	a5,0x10
    1dc4:	05478793          	addi	a5,a5,84 # 10054 <end+0x68a0>
    1dc8:	0007a783          	lw	a5,0(a5)
    1dcc:	fef42623          	sw	a5,-20(s0)
    1dd0:	fec42703          	lw	a4,-20(s0)
    1dd4:	ffff07b7          	lui	a5,0xffff0
    1dd8:	00f776b3          	and	a3,a4,a5
    1ddc:	fdc42703          	lw	a4,-36(s0)
    1de0:	000107b7          	lui	a5,0x10
    1de4:	fff78793          	addi	a5,a5,-1 # ffff <end+0x684b>
    1de8:	00f77733          	and	a4,a4,a5
    1dec:	000107b7          	lui	a5,0x10
    1df0:	05478793          	addi	a5,a5,84 # 10054 <end+0x68a0>
    1df4:	00e6e733          	or	a4,a3,a4
    1df8:	00e7a023          	sw	a4,0(a5)
    1dfc:	00000013          	nop
    1e00:	02c12403          	lw	s0,44(sp)
    1e04:	03010113          	addi	sp,sp,48
    1e08:	00008067          	ret

Disassembly of section .data:

00008000 <ser_port>:
    8000:	1382                	slli	t2,t2,0x20
	...

00008004 <zzy>:
    8004:	7a7a                	flw	fs4,188(sp)
    8006:	0d79                	addi	s10,s10,30
    8008:	000a                	c.slli	zero,0x2
    800a:	3a434347          	fmsub.d	ft6,ft6,ft4,ft7,rmm
    800e:	2820                	fld	fs0,80(s0)
    8010:	20554e47          	fmsub.s	ft8,fa0,ft5,ft4,rmm
    8014:	434d                	li	t1,19
    8016:	2055                	jal	80ba <UDP_rx_data+0x76>
    8018:	6345                	lui	t1,0x11
    801a:	696c                	flw	fa1,84(a0)
    801c:	7370                	flw	fa2,100(a4)
    801e:	2065                	jal	80c6 <UDP_rx_data+0x82>
    8020:	4952                	lw	s2,20(sp)
    8022:	562d4353          	0x562d4353
    8026:	4520                	lw	s0,72(a0)
    8028:	626d                	lui	tp,0x1b
    802a:	6465                	lui	s0,0x19
    802c:	6564                	flw	fs1,76(a0)
    802e:	2064                	fld	fs1,192(s0)
    8030:	2c434347          	0x2c434347
    8034:	3620                	fld	fs0,104(a2)
    8036:	2d34                	fld	fa3,88(a0)
    8038:	6962                	flw	fs2,24(sp)
    803a:	7374                	flw	fa3,100(a4)
    803c:	2029                	jal	8046 <UDP_rx_data+0x2>
    803e:	2e322e37          	lui	t3,0x2e322
    8042:	0030                	addi	a2,sp,8

00008044 <UDP_rx_data>:
	...

00008814 <client_rx_data>:
	...

00008fe4 <server_rx_data>:
	...
[0, 8192]
right
