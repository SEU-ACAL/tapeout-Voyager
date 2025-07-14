
./coremark.bare.riscv:     file format elf64-littleriscv


Disassembly of section .text.init:

0000000080000000 <_start>:
    80000000:	4081                	li	ra,0
    80000002:	4101                	li	sp,0
    80000004:	4181                	li	gp,0
    80000006:	4201                	li	tp,0
    80000008:	4281                	li	t0,0
    8000000a:	4301                	li	t1,0
    8000000c:	4381                	li	t2,0
    8000000e:	4401                	li	s0,0
    80000010:	4481                	li	s1,0
    80000012:	4501                	li	a0,0
    80000014:	4581                	li	a1,0
    80000016:	4601                	li	a2,0
    80000018:	4681                	li	a3,0
    8000001a:	4701                	li	a4,0
    8000001c:	4781                	li	a5,0
    8000001e:	4801                	li	a6,0
    80000020:	4881                	li	a7,0
    80000022:	4901                	li	s2,0
    80000024:	4981                	li	s3,0
    80000026:	4a01                	li	s4,0
    80000028:	4a81                	li	s5,0
    8000002a:	4b01                	li	s6,0
    8000002c:	4b81                	li	s7,0
    8000002e:	4c01                	li	s8,0
    80000030:	4c81                	li	s9,0
    80000032:	4d01                	li	s10,0
    80000034:	4d81                	li	s11,0
    80000036:	4e01                	li	t3,0
    80000038:	4e81                	li	t4,0
    8000003a:	4f01                	li	t5,0
    8000003c:	4f81                	li	t6,0
    8000003e:	62f9                	lui	t0,0x1e
    80000040:	3002a073          	csrs	mstatus,t0
    80000044:	4285                	li	t0,1
    80000046:	02fe                	slli	t0,t0,0x1f
    80000048:	0002d863          	bgez	t0,80000058 <_start+0x58>
    8000004c:	4505                	li	a0,1
    8000004e:	00001297          	auipc	t0,0x1
    80000052:	faa2a923          	sw	a0,-78(t0) # 80001000 <tohost>
    80000056:	bfdd                	j	8000004c <_start+0x4c>
    80000058:	00000297          	auipc	t0,0x0
    8000005c:	09028293          	addi	t0,t0,144 # 800000e8 <_start+0xe8>
    80000060:	30529073          	csrw	mtvec,t0
    80000064:	00301073          	fscsr	zero
    80000068:	f0000053          	fmv.w.x	ft0,zero
    8000006c:	f00000d3          	fmv.w.x	ft1,zero
    80000070:	f0000153          	fmv.w.x	ft2,zero
    80000074:	f00001d3          	fmv.w.x	ft3,zero
    80000078:	f0000253          	fmv.w.x	ft4,zero
    8000007c:	f00002d3          	fmv.w.x	ft5,zero
    80000080:	f0000353          	fmv.w.x	ft6,zero
    80000084:	f00003d3          	fmv.w.x	ft7,zero
    80000088:	f0000453          	fmv.w.x	fs0,zero
    8000008c:	f00004d3          	fmv.w.x	fs1,zero
    80000090:	f0000553          	fmv.w.x	fa0,zero
    80000094:	f00005d3          	fmv.w.x	fa1,zero
    80000098:	f0000653          	fmv.w.x	fa2,zero
    8000009c:	f00006d3          	fmv.w.x	fa3,zero
    800000a0:	f0000753          	fmv.w.x	fa4,zero
    800000a4:	f00007d3          	fmv.w.x	fa5,zero
    800000a8:	f0000853          	fmv.w.x	fa6,zero
    800000ac:	f00008d3          	fmv.w.x	fa7,zero
    800000b0:	f0000953          	fmv.w.x	fs2,zero
    800000b4:	f00009d3          	fmv.w.x	fs3,zero
    800000b8:	f0000a53          	fmv.w.x	fs4,zero
    800000bc:	f0000ad3          	fmv.w.x	fs5,zero
    800000c0:	f0000b53          	fmv.w.x	fs6,zero
    800000c4:	f0000bd3          	fmv.w.x	fs7,zero
    800000c8:	f0000c53          	fmv.w.x	fs8,zero
    800000cc:	f0000cd3          	fmv.w.x	fs9,zero
    800000d0:	f0000d53          	fmv.w.x	fs10,zero
    800000d4:	f0000dd3          	fmv.w.x	fs11,zero
    800000d8:	f0000e53          	fmv.w.x	ft8,zero
    800000dc:	f0000ed3          	fmv.w.x	ft9,zero
    800000e0:	f0000f53          	fmv.w.x	ft10,zero
    800000e4:	f0000fd3          	fmv.w.x	ft11,zero
    800000e8:	00000297          	auipc	t0,0x0
    800000ec:	03828293          	addi	t0,t0,56 # 80000120 <trap_entry>
    800000f0:	30529073          	csrw	mtvec,t0
    800000f4:	00004197          	auipc	gp,0x4
    800000f8:	32c18193          	addi	gp,gp,812 # 80004420 <__global_pointer$>
    800000fc:	03f18213          	addi	tp,gp,63 # 8000445f <__global_pointer$+0x3f>
    80000100:	fc027213          	andi	tp,tp,-64
    80000104:	f1402573          	csrr	a0,mhartid
    80000108:	4585                	li	a1,1
    8000010a:	00b57063          	bgeu	a0,a1,8000010a <_start+0x10a>
    8000010e:	01151613          	slli	a2,a0,0x11
    80000112:	9232                	add	tp,tp,a2
    80000114:	00150113          	addi	sp,a0,1
    80000118:	0146                	slli	sp,sp,0x11
    8000011a:	9112                	add	sp,sp,tp
    8000011c:	7980206f          	j	800028b4 <_init>

0000000080000120 <trap_entry>:
    80000120:	716d                	addi	sp,sp,-272
    80000122:	e406                	sd	ra,8(sp)
    80000124:	e80a                	sd	sp,16(sp)
    80000126:	ec0e                	sd	gp,24(sp)
    80000128:	f012                	sd	tp,32(sp)
    8000012a:	f416                	sd	t0,40(sp)
    8000012c:	f81a                	sd	t1,48(sp)
    8000012e:	fc1e                	sd	t2,56(sp)
    80000130:	e0a2                	sd	s0,64(sp)
    80000132:	e4a6                	sd	s1,72(sp)
    80000134:	e8aa                	sd	a0,80(sp)
    80000136:	ecae                	sd	a1,88(sp)
    80000138:	f0b2                	sd	a2,96(sp)
    8000013a:	f4b6                	sd	a3,104(sp)
    8000013c:	f8ba                	sd	a4,112(sp)
    8000013e:	fcbe                	sd	a5,120(sp)
    80000140:	e142                	sd	a6,128(sp)
    80000142:	e546                	sd	a7,136(sp)
    80000144:	e94a                	sd	s2,144(sp)
    80000146:	ed4e                	sd	s3,152(sp)
    80000148:	f152                	sd	s4,160(sp)
    8000014a:	f556                	sd	s5,168(sp)
    8000014c:	f95a                	sd	s6,176(sp)
    8000014e:	fd5e                	sd	s7,184(sp)
    80000150:	e1e2                	sd	s8,192(sp)
    80000152:	e5e6                	sd	s9,200(sp)
    80000154:	e9ea                	sd	s10,208(sp)
    80000156:	edee                	sd	s11,216(sp)
    80000158:	f1f2                	sd	t3,224(sp)
    8000015a:	f5f6                	sd	t4,232(sp)
    8000015c:	f9fa                	sd	t5,240(sp)
    8000015e:	fdfe                	sd	t6,248(sp)
    80000160:	34202573          	csrr	a0,mcause
    80000164:	341025f3          	csrr	a1,mepc
    80000168:	860a                	mv	a2,sp
    8000016a:	614020ef          	jal	ra,8000277e <handle_trap>
    8000016e:	34151073          	csrw	mepc,a0
    80000172:	6289                	lui	t0,0x2
    80000174:	8002829b          	addiw	t0,t0,-2048 # 1800 <_tbss_end+0x1800>
    80000178:	3002a073          	csrs	mstatus,t0
    8000017c:	60a2                	ld	ra,8(sp)
    8000017e:	6142                	ld	sp,16(sp)
    80000180:	61e2                	ld	gp,24(sp)
    80000182:	7202                	ld	tp,32(sp)
    80000184:	72a2                	ld	t0,40(sp)
    80000186:	7342                	ld	t1,48(sp)
    80000188:	73e2                	ld	t2,56(sp)
    8000018a:	6406                	ld	s0,64(sp)
    8000018c:	64a6                	ld	s1,72(sp)
    8000018e:	6546                	ld	a0,80(sp)
    80000190:	65e6                	ld	a1,88(sp)
    80000192:	7606                	ld	a2,96(sp)
    80000194:	76a6                	ld	a3,104(sp)
    80000196:	7746                	ld	a4,112(sp)
    80000198:	77e6                	ld	a5,120(sp)
    8000019a:	680a                	ld	a6,128(sp)
    8000019c:	68aa                	ld	a7,136(sp)
    8000019e:	694a                	ld	s2,144(sp)
    800001a0:	69ea                	ld	s3,152(sp)
    800001a2:	7a0a                	ld	s4,160(sp)
    800001a4:	7aaa                	ld	s5,168(sp)
    800001a6:	7b4a                	ld	s6,176(sp)
    800001a8:	7bea                	ld	s7,184(sp)
    800001aa:	6c0e                	ld	s8,192(sp)
    800001ac:	6cae                	ld	s9,200(sp)
    800001ae:	6d4e                	ld	s10,208(sp)
    800001b0:	6dee                	ld	s11,216(sp)
    800001b2:	7e0e                	ld	t3,224(sp)
    800001b4:	7eae                	ld	t4,232(sp)
    800001b6:	7f4e                	ld	t5,240(sp)
    800001b8:	7fee                	ld	t6,248(sp)
    800001ba:	6151                	addi	sp,sp,272
    800001bc:	30200073          	mret
	...

Disassembly of section .text:

0000000080001048 <cmp_idx>:
    80001048:	c619                	beqz	a2,80001056 <cmp_idx+0xe>
    8000104a:	00251503          	lh	a0,2(a0)
    8000104e:	00259783          	lh	a5,2(a1)
    80001052:	9d1d                	subw	a0,a0,a5
    80001054:	8082                	ret
    80001056:	00051783          	lh	a5,0(a0)
    8000105a:	0107971b          	slliw	a4,a5,0x10
    8000105e:	0107571b          	srliw	a4,a4,0x10
    80001062:	0087571b          	srliw	a4,a4,0x8
    80001066:	f007f793          	andi	a5,a5,-256
    8000106a:	8fd9                	or	a5,a5,a4
    8000106c:	00f51023          	sh	a5,0(a0)
    80001070:	00059783          	lh	a5,0(a1)
    80001074:	00251503          	lh	a0,2(a0)
    80001078:	0107971b          	slliw	a4,a5,0x10
    8000107c:	0107571b          	srliw	a4,a4,0x10
    80001080:	0087571b          	srliw	a4,a4,0x8
    80001084:	f007f793          	andi	a5,a5,-256
    80001088:	8fd9                	or	a5,a5,a4
    8000108a:	00f59023          	sh	a5,0(a1)
    8000108e:	00259783          	lh	a5,2(a1)
    80001092:	9d1d                	subw	a0,a0,a5
    80001094:	8082                	ret

0000000080001096 <calc_func>:
    80001096:	7179                	addi	sp,sp,-48
    80001098:	f022                	sd	s0,32(sp)
    8000109a:	00051403          	lh	s0,0(a0)
    8000109e:	f406                	sd	ra,40(sp)
    800010a0:	ec26                	sd	s1,24(sp)
    800010a2:	4074579b          	sraiw	a5,s0,0x7
    800010a6:	e84a                	sd	s2,16(sp)
    800010a8:	e44e                	sd	s3,8(sp)
    800010aa:	8b85                	andi	a5,a5,1
    800010ac:	cb91                	beqz	a5,800010c0 <calc_func+0x2a>
    800010ae:	70a2                	ld	ra,40(sp)
    800010b0:	07f47513          	andi	a0,s0,127
    800010b4:	7402                	ld	s0,32(sp)
    800010b6:	64e2                	ld	s1,24(sp)
    800010b8:	6942                	ld	s2,16(sp)
    800010ba:	69a2                	ld	s3,8(sp)
    800010bc:	6145                	addi	sp,sp,48
    800010be:	8082                	ret
    800010c0:	4034571b          	sraiw	a4,s0,0x3
    800010c4:	8b3d                	andi	a4,a4,15
    800010c6:	84ae                	mv	s1,a1
    800010c8:	00747693          	andi	a3,s0,7
    800010cc:	00471593          	slli	a1,a4,0x4
    800010d0:	0604d783          	lhu	a5,96(s1)
    800010d4:	89aa                	mv	s3,a0
    800010d6:	8dd9                	or	a1,a1,a4
    800010d8:	ce95                	beqz	a3,80001114 <calc_func+0x7e>
    800010da:	4705                	li	a4,1
    800010dc:	06e68963          	beq	a3,a4,8000114e <calc_func+0xb8>
    800010e0:	03041513          	slli	a0,s0,0x30
    800010e4:	9141                	srli	a0,a0,0x30
    800010e6:	8922                	mv	s2,s0
    800010e8:	85be                	mv	a1,a5
    800010ea:	1a4010ef          	jal	ra,8000228e <crcu16>
    800010ee:	87aa                	mv	a5,a0
    800010f0:	f0047413          	andi	s0,s0,-256
    800010f4:	07f97513          	andi	a0,s2,127
    800010f8:	8c49                	or	s0,s0,a0
    800010fa:	06f49023          	sh	a5,96(s1)
    800010fe:	08046413          	ori	s0,s0,128
    80001102:	00899023          	sh	s0,0(s3)
    80001106:	70a2                	ld	ra,40(sp)
    80001108:	7402                	ld	s0,32(sp)
    8000110a:	64e2                	ld	s1,24(sp)
    8000110c:	6942                	ld	s2,16(sp)
    8000110e:	69a2                	ld	s3,8(sp)
    80001110:	6145                	addi	sp,sp,48
    80001112:	8082                	ret
    80001114:	02200693          	li	a3,34
    80001118:	872e                	mv	a4,a1
    8000111a:	00d5d463          	bge	a1,a3,80001122 <calc_func+0x8c>
    8000111e:	02200713          	li	a4,34
    80001122:	00249683          	lh	a3,2(s1)
    80001126:	00049603          	lh	a2,0(s1)
    8000112a:	708c                	ld	a1,32(s1)
    8000112c:	5488                	lw	a0,40(s1)
    8000112e:	0ff77713          	zext.b	a4,a4
    80001132:	7b1000ef          	jal	ra,800020e2 <core_bench_state>
    80001136:	0664d783          	lhu	a5,102(s1)
    8000113a:	e399                	bnez	a5,80001140 <calc_func+0xaa>
    8000113c:	06a49323          	sh	a0,102(s1)
    80001140:	0105191b          	slliw	s2,a0,0x10
    80001144:	0604d783          	lhu	a5,96(s1)
    80001148:	4109591b          	sraiw	s2,s2,0x10
    8000114c:	bf71                	j	800010e8 <calc_func+0x52>
    8000114e:	863e                	mv	a2,a5
    80001150:	04048513          	addi	a0,s1,64
    80001154:	425000ef          	jal	ra,80001d78 <core_bench_matrix>
    80001158:	0644d783          	lhu	a5,100(s1)
    8000115c:	f3f5                	bnez	a5,80001140 <calc_func+0xaa>
    8000115e:	06a49223          	sh	a0,100(s1)
    80001162:	bff9                	j	80001140 <calc_func+0xaa>

0000000080001164 <cmp_complex>:
    80001164:	1101                	addi	sp,sp,-32
    80001166:	e426                	sd	s1,8(sp)
    80001168:	84ae                	mv	s1,a1
    8000116a:	85b2                	mv	a1,a2
    8000116c:	ec06                	sd	ra,24(sp)
    8000116e:	e822                	sd	s0,16(sp)
    80001170:	8432                	mv	s0,a2
    80001172:	f25ff0ef          	jal	ra,80001096 <calc_func>
    80001176:	87aa                	mv	a5,a0
    80001178:	85a2                	mv	a1,s0
    8000117a:	8526                	mv	a0,s1
    8000117c:	843e                	mv	s0,a5
    8000117e:	f19ff0ef          	jal	ra,80001096 <calc_func>
    80001182:	60e2                	ld	ra,24(sp)
    80001184:	40a4053b          	subw	a0,s0,a0
    80001188:	6442                	ld	s0,16(sp)
    8000118a:	64a2                	ld	s1,8(sp)
    8000118c:	6105                	addi	sp,sp,32
    8000118e:	8082                	ret

0000000080001190 <copy_info>:
    80001190:	00059703          	lh	a4,0(a1)
    80001194:	00259783          	lh	a5,2(a1)
    80001198:	00e51023          	sh	a4,0(a0)
    8000119c:	00f51123          	sh	a5,2(a0)
    800011a0:	8082                	ret

00000000800011a2 <core_list_insert_new>:
    800011a2:	00063803          	ld	a6,0(a2)
    800011a6:	01080893          	addi	a7,a6,16
    800011aa:	02e8ff63          	bgeu	a7,a4,800011e8 <core_list_insert_new+0x46>
    800011ae:	6298                	ld	a4,0(a3)
    800011b0:	00470313          	addi	t1,a4,4
    800011b4:	02f37a63          	bgeu	t1,a5,800011e8 <core_list_insert_new+0x46>
    800011b8:	01163023          	sd	a7,0(a2)
    800011bc:	611c                	ld	a5,0(a0)
    800011be:	00059883          	lh	a7,0(a1)
    800011c2:	00259603          	lh	a2,2(a1)
    800011c6:	00f83023          	sd	a5,0(a6)
    800011ca:	01053023          	sd	a6,0(a0)
    800011ce:	00e83423          	sd	a4,8(a6)
    800011d2:	629c                	ld	a5,0(a3)
    800011d4:	8542                	mv	a0,a6
    800011d6:	0791                	addi	a5,a5,4
    800011d8:	e29c                	sd	a5,0(a3)
    800011da:	00883783          	ld	a5,8(a6)
    800011de:	01179023          	sh	a7,0(a5)
    800011e2:	00c79123          	sh	a2,2(a5)
    800011e6:	8082                	ret
    800011e8:	4801                	li	a6,0
    800011ea:	8542                	mv	a0,a6
    800011ec:	8082                	ret

00000000800011ee <core_list_remove>:
    800011ee:	87aa                	mv	a5,a0
    800011f0:	6108                	ld	a0,0(a0)
    800011f2:	6794                	ld	a3,8(a5)
    800011f4:	6510                	ld	a2,8(a0)
    800011f6:	6118                	ld	a4,0(a0)
    800011f8:	e790                	sd	a2,8(a5)
    800011fa:	e514                	sd	a3,8(a0)
    800011fc:	e398                	sd	a4,0(a5)
    800011fe:	00053023          	sd	zero,0(a0)
    80001202:	8082                	ret

0000000080001204 <core_list_undo_remove>:
    80001204:	6590                	ld	a2,8(a1)
    80001206:	6514                	ld	a3,8(a0)
    80001208:	6198                	ld	a4,0(a1)
    8000120a:	e510                	sd	a2,8(a0)
    8000120c:	e594                	sd	a3,8(a1)
    8000120e:	e118                	sd	a4,0(a0)
    80001210:	e188                	sd	a0,0(a1)
    80001212:	8082                	ret

0000000080001214 <core_list_find>:
    80001214:	00259703          	lh	a4,2(a1)
    80001218:	00074c63          	bltz	a4,80001230 <core_list_find+0x1c>
    8000121c:	e501                	bnez	a0,80001224 <core_list_find+0x10>
    8000121e:	a03d                	j	8000124c <core_list_find+0x38>
    80001220:	6108                	ld	a0,0(a0)
    80001222:	c11d                	beqz	a0,80001248 <core_list_find+0x34>
    80001224:	651c                	ld	a5,8(a0)
    80001226:	00279783          	lh	a5,2(a5)
    8000122a:	fee79be3          	bne	a5,a4,80001220 <core_list_find+0xc>
    8000122e:	8082                	ret
    80001230:	cd01                	beqz	a0,80001248 <core_list_find+0x34>
    80001232:	00059703          	lh	a4,0(a1)
    80001236:	a019                	j	8000123c <core_list_find+0x28>
    80001238:	6108                	ld	a0,0(a0)
    8000123a:	c901                	beqz	a0,8000124a <core_list_find+0x36>
    8000123c:	651c                	ld	a5,8(a0)
    8000123e:	0007c783          	lbu	a5,0(a5)
    80001242:	fee79be3          	bne	a5,a4,80001238 <core_list_find+0x24>
    80001246:	8082                	ret
    80001248:	4501                	li	a0,0
    8000124a:	8082                	ret
    8000124c:	8082                	ret

000000008000124e <core_list_reverse>:
    8000124e:	c901                	beqz	a0,8000125e <core_list_reverse+0x10>
    80001250:	4701                	li	a4,0
    80001252:	a011                	j	80001256 <core_list_reverse+0x8>
    80001254:	853e                	mv	a0,a5
    80001256:	611c                	ld	a5,0(a0)
    80001258:	e118                	sd	a4,0(a0)
    8000125a:	872a                	mv	a4,a0
    8000125c:	ffe5                	bnez	a5,80001254 <core_list_reverse+0x6>
    8000125e:	8082                	ret

0000000080001260 <core_list_mergesort>:
    80001260:	711d                	addi	sp,sp,-96
    80001262:	fc4e                	sd	s3,56(sp)
    80001264:	f456                	sd	s5,40(sp)
    80001266:	ec5e                	sd	s7,24(sp)
    80001268:	e862                	sd	s8,16(sp)
    8000126a:	e06a                	sd	s10,0(sp)
    8000126c:	ec86                	sd	ra,88(sp)
    8000126e:	e8a2                	sd	s0,80(sp)
    80001270:	e4a6                	sd	s1,72(sp)
    80001272:	e0ca                	sd	s2,64(sp)
    80001274:	f852                	sd	s4,48(sp)
    80001276:	f05a                	sd	s6,32(sp)
    80001278:	e466                	sd	s9,8(sp)
    8000127a:	89aa                	mv	s3,a0
    8000127c:	8c2e                	mv	s8,a1
    8000127e:	8bb2                	mv	s7,a2
    80001280:	4a85                	li	s5,1
    80001282:	4d05                	li	s10,1
    80001284:	08098463          	beqz	s3,8000130c <core_list_mergesort+0xac>
    80001288:	4c81                	li	s9,0
    8000128a:	4481                	li	s1,0
    8000128c:	4b01                	li	s6,0
    8000128e:	2c85                	addiw	s9,s9,1
    80001290:	87ce                	mv	a5,s3
    80001292:	4401                	li	s0,0
    80001294:	639c                	ld	a5,0(a5)
    80001296:	2405                	addiw	s0,s0,1
    80001298:	c399                	beqz	a5,8000129e <core_list_mergesort+0x3e>
    8000129a:	fe8a9de3          	bne	s5,s0,80001294 <core_list_mergesort+0x34>
    8000129e:	894e                	mv	s2,s3
    800012a0:	8a56                	mv	s4,s5
    800012a2:	89be                	mv	s3,a5
    800012a4:	00805d63          	blez	s0,800012be <core_list_mergesort+0x5e>
    800012a8:	020a1863          	bnez	s4,800012d8 <core_list_mergesort+0x78>
    800012ac:	87ca                	mv	a5,s2
    800012ae:	00093903          	ld	s2,0(s2)
    800012b2:	347d                	addiw	s0,s0,-1
    800012b4:	cc99                	beqz	s1,800012d2 <core_list_mergesort+0x72>
    800012b6:	e09c                	sd	a5,0(s1)
    800012b8:	84be                	mv	s1,a5
    800012ba:	fe8047e3          	bgtz	s0,800012a8 <core_list_mergesort+0x48>
    800012be:	03405c63          	blez	s4,800012f6 <core_list_mergesort+0x96>
    800012c2:	02098c63          	beqz	s3,800012fa <core_list_mergesort+0x9a>
    800012c6:	e819                	bnez	s0,800012dc <core_list_mergesort+0x7c>
    800012c8:	87ce                	mv	a5,s3
    800012ca:	3a7d                	addiw	s4,s4,-1
    800012cc:	0009b983          	ld	s3,0(s3)
    800012d0:	f0fd                	bnez	s1,800012b6 <core_list_mergesort+0x56>
    800012d2:	8b3e                	mv	s6,a5
    800012d4:	84be                	mv	s1,a5
    800012d6:	b7d5                	j	800012ba <core_list_mergesort+0x5a>
    800012d8:	fc098ae3          	beqz	s3,800012ac <core_list_mergesort+0x4c>
    800012dc:	0089b583          	ld	a1,8(s3)
    800012e0:	00893503          	ld	a0,8(s2)
    800012e4:	865e                	mv	a2,s7
    800012e6:	9c02                	jalr	s8
    800012e8:	fca052e3          	blez	a0,800012ac <core_list_mergesort+0x4c>
    800012ec:	87ce                	mv	a5,s3
    800012ee:	3a7d                	addiw	s4,s4,-1
    800012f0:	0009b983          	ld	s3,0(s3)
    800012f4:	b7c1                	j	800012b4 <core_list_mergesort+0x54>
    800012f6:	f8099ce3          	bnez	s3,8000128e <core_list_mergesort+0x2e>
    800012fa:	0004b023          	sd	zero,0(s1)
    800012fe:	01ac8a63          	beq	s9,s10,80001312 <core_list_mergesort+0xb2>
    80001302:	89da                	mv	s3,s6
    80001304:	001a9a9b          	slliw	s5,s5,0x1
    80001308:	f80990e3          	bnez	s3,80001288 <core_list_mergesort+0x28>
    8000130c:	00003023          	sd	zero,0(zero) # 0 <_tbss_end>
    80001310:	9002                	ebreak
    80001312:	60e6                	ld	ra,88(sp)
    80001314:	6446                	ld	s0,80(sp)
    80001316:	64a6                	ld	s1,72(sp)
    80001318:	6906                	ld	s2,64(sp)
    8000131a:	79e2                	ld	s3,56(sp)
    8000131c:	7a42                	ld	s4,48(sp)
    8000131e:	7aa2                	ld	s5,40(sp)
    80001320:	6be2                	ld	s7,24(sp)
    80001322:	6c42                	ld	s8,16(sp)
    80001324:	6ca2                	ld	s9,8(sp)
    80001326:	6d02                	ld	s10,0(sp)
    80001328:	855a                	mv	a0,s6
    8000132a:	7b02                	ld	s6,32(sp)
    8000132c:	6125                	addi	sp,sp,96
    8000132e:	8082                	ret

0000000080001330 <core_bench_list>:
    80001330:	00451303          	lh	t1,4(a0)
    80001334:	7139                	addi	sp,sp,-64
    80001336:	f822                	sd	s0,48(sp)
    80001338:	fc06                	sd	ra,56(sp)
    8000133a:	f426                	sd	s1,40(sp)
    8000133c:	f04a                	sd	s2,32(sp)
    8000133e:	ec4e                	sd	s3,24(sp)
    80001340:	e852                	sd	s4,16(sp)
    80001342:	e456                	sd	s5,8(sp)
    80001344:	7d00                	ld	s0,56(a0)
    80001346:	862a                	mv	a2,a0
    80001348:	1c605163          	blez	t1,8000150a <core_bench_list+0x1da>
    8000134c:	892e                	mv	s2,a1
    8000134e:	4881                	li	a7,0
    80001350:	4e01                	li	t3,0
    80001352:	4801                	li	a6,0
    80001354:	4501                	li	a0,0
    80001356:	0ff8fa13          	zext.b	s4,a7
    8000135a:	14094e63          	bltz	s2,800014b6 <core_bench_list+0x186>
    8000135e:	1a040a63          	beqz	s0,80001512 <core_bench_list+0x1e2>
    80001362:	87a2                	mv	a5,s0
    80001364:	a019                	j	8000136a <core_bench_list+0x3a>
    80001366:	639c                	ld	a5,0(a5)
    80001368:	c791                	beqz	a5,80001374 <core_bench_list+0x44>
    8000136a:	6798                	ld	a4,8(a5)
    8000136c:	00271703          	lh	a4,2(a4)
    80001370:	ff271be3          	bne	a4,s2,80001366 <core_bench_list+0x36>
    80001374:	4681                	li	a3,0
    80001376:	a011                	j	8000137a <core_bench_list+0x4a>
    80001378:	843a                	mv	s0,a4
    8000137a:	6018                	ld	a4,0(s0)
    8000137c:	e014                	sd	a3,0(s0)
    8000137e:	86a2                	mv	a3,s0
    80001380:	ff65                	bnez	a4,80001378 <core_bench_list+0x48>
    80001382:	14078663          	beqz	a5,800014ce <core_bench_list+0x19e>
    80001386:	6798                	ld	a4,8(a5)
    80001388:	00071703          	lh	a4,0(a4)
    8000138c:	00177693          	andi	a3,a4,1
    80001390:	ca81                	beqz	a3,800013a0 <core_bench_list+0x70>
    80001392:	4097571b          	sraiw	a4,a4,0x9
    80001396:	8b05                	andi	a4,a4,1
    80001398:	9f29                	addw	a4,a4,a0
    8000139a:	03071513          	slli	a0,a4,0x30
    8000139e:	9141                	srli	a0,a0,0x30
    800013a0:	6398                	ld	a4,0(a5)
    800013a2:	c711                	beqz	a4,800013ae <core_bench_list+0x7e>
    800013a4:	6314                	ld	a3,0(a4)
    800013a6:	e394                	sd	a3,0(a5)
    800013a8:	601c                	ld	a5,0(s0)
    800013aa:	e31c                	sd	a5,0(a4)
    800013ac:	e018                	sd	a4,0(s0)
    800013ae:	2805                	addiw	a6,a6,1
    800013b0:	1842                	slli	a6,a6,0x30
    800013b2:	03085813          	srli	a6,a6,0x30
    800013b6:	00094763          	bltz	s2,800013c4 <core_bench_list+0x94>
    800013ba:	2905                	addiw	s2,s2,1
    800013bc:	0109191b          	slliw	s2,s2,0x10
    800013c0:	4109591b          	sraiw	s2,s2,0x10
    800013c4:	2885                	addiw	a7,a7,1
    800013c6:	0108989b          	slliw	a7,a7,0x10
    800013ca:	4108d89b          	sraiw	a7,a7,0x10
    800013ce:	f91314e3          	bne	t1,a7,80001356 <core_bench_list+0x26>
    800013d2:	0028149b          	slliw	s1,a6,0x2
    800013d6:	41c484bb          	subw	s1,s1,t3
    800013da:	9ca9                	addw	s1,s1,a0
    800013dc:	14c2                	slli	s1,s1,0x30
    800013de:	90c1                	srli	s1,s1,0x30
    800013e0:	00b05a63          	blez	a1,800013f4 <core_bench_list+0xc4>
    800013e4:	8522                	mv	a0,s0
    800013e6:	00000597          	auipc	a1,0x0
    800013ea:	d7e58593          	addi	a1,a1,-642 # 80001164 <cmp_complex>
    800013ee:	e73ff0ef          	jal	ra,80001260 <core_list_mergesort>
    800013f2:	842a                	mv	s0,a0
    800013f4:	601c                	ld	a5,0(s0)
    800013f6:	89a2                	mv	s3,s0
    800013f8:	0007ba83          	ld	s5,0(a5)
    800013fc:	6798                	ld	a4,8(a5)
    800013fe:	008ab603          	ld	a2,8(s5)
    80001402:	000ab683          	ld	a3,0(s5)
    80001406:	e790                	sd	a2,8(a5)
    80001408:	00eab423          	sd	a4,8(s5)
    8000140c:	e394                	sd	a3,0(a5)
    8000140e:	000ab023          	sd	zero,0(s5)
    80001412:	00095763          	bgez	s2,80001420 <core_bench_list+0xf0>
    80001416:	a849                	j	800014a8 <core_bench_list+0x178>
    80001418:	0009b983          	ld	s3,0(s3)
    8000141c:	0c098763          	beqz	s3,800014ea <core_bench_list+0x1ba>
    80001420:	0089b783          	ld	a5,8(s3)
    80001424:	00279783          	lh	a5,2(a5)
    80001428:	ff2798e3          	bne	a5,s2,80001418 <core_bench_list+0xe8>
    8000142c:	641c                	ld	a5,8(s0)
    8000142e:	85a6                	mv	a1,s1
    80001430:	00079503          	lh	a0,0(a5)
    80001434:	75d000ef          	jal	ra,80002390 <crc16>
    80001438:	0009b983          	ld	s3,0(s3)
    8000143c:	84aa                	mv	s1,a0
    8000143e:	fe0997e3          	bnez	s3,8000142c <core_bench_list+0xfc>
    80001442:	00043983          	ld	s3,0(s0)
    80001446:	008ab703          	ld	a4,8(s5)
    8000144a:	0089b683          	ld	a3,8(s3)
    8000144e:	0009b783          	ld	a5,0(s3)
    80001452:	8522                	mv	a0,s0
    80001454:	00dab423          	sd	a3,8(s5)
    80001458:	00e9b423          	sd	a4,8(s3)
    8000145c:	00fab023          	sd	a5,0(s5)
    80001460:	4601                	li	a2,0
    80001462:	0159b023          	sd	s5,0(s3)
    80001466:	00000597          	auipc	a1,0x0
    8000146a:	be258593          	addi	a1,a1,-1054 # 80001048 <cmp_idx>
    8000146e:	df3ff0ef          	jal	ra,80001260 <core_list_mergesort>
    80001472:	6100                	ld	s0,0(a0)
    80001474:	892a                	mv	s2,a0
    80001476:	c819                	beqz	s0,8000148c <core_bench_list+0x15c>
    80001478:	00893783          	ld	a5,8(s2)
    8000147c:	85a6                	mv	a1,s1
    8000147e:	00079503          	lh	a0,0(a5)
    80001482:	70f000ef          	jal	ra,80002390 <crc16>
    80001486:	6000                	ld	s0,0(s0)
    80001488:	84aa                	mv	s1,a0
    8000148a:	f47d                	bnez	s0,80001478 <core_bench_list+0x148>
    8000148c:	70e2                	ld	ra,56(sp)
    8000148e:	7442                	ld	s0,48(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	8526                	mv	a0,s1
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	6121                	addi	sp,sp,64
    8000149e:	8082                	ret
    800014a0:	0009b983          	ld	s3,0(s3)
    800014a4:	04098363          	beqz	s3,800014ea <core_bench_list+0x1ba>
    800014a8:	0089b783          	ld	a5,8(s3)
    800014ac:	0007c783          	lbu	a5,0(a5)
    800014b0:	fefa18e3          	bne	s4,a5,800014a0 <core_bench_list+0x170>
    800014b4:	bfa5                	j	8000142c <core_bench_list+0xfc>
    800014b6:	cc31                	beqz	s0,80001512 <core_bench_list+0x1e2>
    800014b8:	87a2                	mv	a5,s0
    800014ba:	a021                	j	800014c2 <core_bench_list+0x192>
    800014bc:	639c                	ld	a5,0(a5)
    800014be:	ea078be3          	beqz	a5,80001374 <core_bench_list+0x44>
    800014c2:	6798                	ld	a4,8(a5)
    800014c4:	00074703          	lbu	a4,0(a4)
    800014c8:	feea1ae3          	bne	s4,a4,800014bc <core_bench_list+0x18c>
    800014cc:	b565                	j	80001374 <core_bench_list+0x44>
    800014ce:	601c                	ld	a5,0(s0)
    800014d0:	2e05                	addiw	t3,t3,1
    800014d2:	1e42                	slli	t3,t3,0x30
    800014d4:	679c                	ld	a5,8(a5)
    800014d6:	030e5e13          	srli	t3,t3,0x30
    800014da:	00178783          	lb	a5,1(a5)
    800014de:	8b85                	andi	a5,a5,1
    800014e0:	9fa9                	addw	a5,a5,a0
    800014e2:	03079513          	slli	a0,a5,0x30
    800014e6:	9141                	srli	a0,a0,0x30
    800014e8:	b5f9                	j	800013b6 <core_bench_list+0x86>
    800014ea:	00043983          	ld	s3,0(s0)
    800014ee:	f4098ee3          	beqz	s3,8000144a <core_bench_list+0x11a>
    800014f2:	641c                	ld	a5,8(s0)
    800014f4:	85a6                	mv	a1,s1
    800014f6:	00079503          	lh	a0,0(a5)
    800014fa:	697000ef          	jal	ra,80002390 <crc16>
    800014fe:	0009b983          	ld	s3,0(s3)
    80001502:	84aa                	mv	s1,a0
    80001504:	f20994e3          	bnez	s3,8000142c <core_bench_list+0xfc>
    80001508:	bf2d                	j	80001442 <core_bench_list+0x112>
    8000150a:	4a01                	li	s4,0
    8000150c:	892e                	mv	s2,a1
    8000150e:	4481                	li	s1,0
    80001510:	bdc1                	j	800013e0 <core_bench_list+0xb0>
    80001512:	00003783          	ld	a5,0(zero) # 0 <_tbss_end>
    80001516:	9002                	ebreak

0000000080001518 <core_list_init>:
    80001518:	47d1                	li	a5,20
    8000151a:	02f55e3b          	divuw	t3,a0,a5
    8000151e:	77e1                	lui	a5,0xffff8
    80001520:	0005b023          	sd	zero,0(a1)
    80001524:	08078713          	addi	a4,a5,128 # ffffffffffff8080 <__global_pointer$+0xffffffff7fff3c60>
    80001528:	02058693          	addi	a3,a1,32
    8000152c:	852e                	mv	a0,a1
    8000152e:	01058313          	addi	t1,a1,16
    80001532:	ffee0f9b          	addiw	t6,t3,-2
    80001536:	020f9f13          	slli	t5,t6,0x20
    8000153a:	020f5f13          	srli	t5,t5,0x20
    8000153e:	004f1e93          	slli	t4,t5,0x4
    80001542:	9eae                	add	t4,t4,a1
    80001544:	01d5b423          	sd	t4,8(a1)
    80001548:	0f0a                	slli	t5,t5,0x2
    8000154a:	00ee9023          	sh	a4,0(t4)
    8000154e:	000e9123          	sh	zero,2(t4)
    80001552:	000f829b          	sext.w	t0,t6
    80001556:	9f76                	add	t5,t5,t4
    80001558:	004e8713          	addi	a4,t4,4
    8000155c:	11d6f463          	bgeu	a3,t4,80001664 <core_list_init+0x14c>
    80001560:	008e8893          	addi	a7,t4,8
    80001564:	11e8f063          	bgeu	a7,t5,80001664 <core_list_init+0x14c>
    80001568:	ed98                	sd	a4,24(a1)
    8000156a:	0005b823          	sd	zero,16(a1)
    8000156e:	0065b023          	sd	t1,0(a1)
    80001572:	fff7c793          	not	a5,a5
    80001576:	577d                	li	a4,-1
    80001578:	00ee9223          	sh	a4,4(t4)
    8000157c:	00fe9323          	sh	a5,6(t4)
    80001580:	0e028763          	beqz	t0,8000166e <core_list_init+0x156>
    80001584:	1141                	addi	sp,sp,-16
    80001586:	e422                	sd	s0,8(sp)
    80001588:	03061393          	slli	t2,a2,0x30
    8000158c:	7461                	lui	s0,0xffff8
    8000158e:	0303d393          	srli	t2,t2,0x30
    80001592:	4801                	li	a6,0
    80001594:	fff44413          	not	s0,s0
    80001598:	03081713          	slli	a4,a6,0x30
    8000159c:	9341                	srli	a4,a4,0x30
    8000159e:	00e3c7b3          	xor	a5,t2,a4
    800015a2:	0037979b          	slliw	a5,a5,0x3
    800015a6:	8b1d                	andi	a4,a4,7
    800015a8:	0787f793          	andi	a5,a5,120
    800015ac:	8fd9                	or	a5,a5,a4
    800015ae:	0087959b          	slliw	a1,a5,0x8
    800015b2:	01068713          	addi	a4,a3,16
    800015b6:	2805                	addiw	a6,a6,1
    800015b8:	00488e13          	addi	t3,a7,4
    800015bc:	8fcd                	or	a5,a5,a1
    800015be:	03d77063          	bgeu	a4,t4,800015de <core_list_init+0xc6>
    800015c2:	01ee7e63          	bgeu	t3,t5,800015de <core_list_init+0xc6>
    800015c6:	0066b023          	sd	t1,0(a3)
    800015ca:	e114                	sd	a3,0(a0)
    800015cc:	0116b423          	sd	a7,8(a3)
    800015d0:	00f89023          	sh	a5,0(a7)
    800015d4:	00889123          	sh	s0,2(a7)
    800015d8:	8336                	mv	t1,a3
    800015da:	88f2                	mv	a7,t3
    800015dc:	86ba                	mv	a3,a4
    800015de:	fb029de3          	bne	t0,a6,80001598 <core_list_init+0x80>
    800015e2:	00033803          	ld	a6,0(t1)
    800015e6:	06080763          	beqz	a6,80001654 <core_list_init+0x13c>
    800015ea:	4795                	li	a5,5
    800015ec:	6e91                	lui	t4,0x4
    800015ee:	02ffde3b          	divuw	t3,t6,a5
    800015f2:	20000713          	li	a4,512
    800015f6:	4685                	li	a3,1
    800015f8:	1efd                	addi	t4,t4,-1 # 3fff <_tbss_end+0x3fff>
    800015fa:	a015                	j	8000161e <core_list_init+0x106>
    800015fc:	0106979b          	slliw	a5,a3,0x10
    80001600:	00083883          	ld	a7,0(a6)
    80001604:	4107d79b          	sraiw	a5,a5,0x10
    80001608:	1007071b          	addiw	a4,a4,256
    8000160c:	1742                	slli	a4,a4,0x30
    8000160e:	00f59123          	sh	a5,2(a1)
    80001612:	8342                	mv	t1,a6
    80001614:	2685                	addiw	a3,a3,1
    80001616:	9341                	srli	a4,a4,0x30
    80001618:	02088e63          	beqz	a7,80001654 <core_list_init+0x13c>
    8000161c:	8846                	mv	a6,a7
    8000161e:	00c6c5b3          	xor	a1,a3,a2
    80001622:	70077793          	andi	a5,a4,1792
    80001626:	8fcd                	or	a5,a5,a1
    80001628:	01d7f7b3          	and	a5,a5,t4
    8000162c:	00833583          	ld	a1,8(t1)
    80001630:	fdc6e6e3          	bltu	a3,t3,800015fc <core_list_init+0xe4>
    80001634:	00083883          	ld	a7,0(a6)
    80001638:	0107979b          	slliw	a5,a5,0x10
    8000163c:	4107d79b          	sraiw	a5,a5,0x10
    80001640:	1007071b          	addiw	a4,a4,256
    80001644:	1742                	slli	a4,a4,0x30
    80001646:	00f59123          	sh	a5,2(a1)
    8000164a:	8342                	mv	t1,a6
    8000164c:	2685                	addiw	a3,a3,1
    8000164e:	9341                	srli	a4,a4,0x30
    80001650:	fc0896e3          	bnez	a7,8000161c <core_list_init+0x104>
    80001654:	6422                	ld	s0,8(sp)
    80001656:	4601                	li	a2,0
    80001658:	00000597          	auipc	a1,0x0
    8000165c:	9f058593          	addi	a1,a1,-1552 # 80001048 <cmp_idx>
    80001660:	0141                	addi	sp,sp,16
    80001662:	befd                	j	80001260 <core_list_mergesort>
    80001664:	869a                	mv	a3,t1
    80001666:	88ba                	mv	a7,a4
    80001668:	4301                	li	t1,0
    8000166a:	f0029de3          	bnez	t0,80001584 <core_list_init+0x6c>
    8000166e:	00033803          	ld	a6,0(t1)
    80001672:	04080c63          	beqz	a6,800016ca <core_list_init+0x1b2>
    80001676:	4795                	li	a5,5
    80001678:	6e91                	lui	t4,0x4
    8000167a:	02ffde3b          	divuw	t3,t6,a5
    8000167e:	20000713          	li	a4,512
    80001682:	4685                	li	a3,1
    80001684:	1efd                	addi	t4,t4,-1 # 3fff <_tbss_end+0x3fff>
    80001686:	a015                	j	800016aa <core_list_init+0x192>
    80001688:	0106979b          	slliw	a5,a3,0x10
    8000168c:	4107d79b          	sraiw	a5,a5,0x10
    80001690:	00083883          	ld	a7,0(a6)
    80001694:	1007071b          	addiw	a4,a4,256
    80001698:	1742                	slli	a4,a4,0x30
    8000169a:	00f59123          	sh	a5,2(a1)
    8000169e:	8342                	mv	t1,a6
    800016a0:	2685                	addiw	a3,a3,1
    800016a2:	9341                	srli	a4,a4,0x30
    800016a4:	02088363          	beqz	a7,800016ca <core_list_init+0x1b2>
    800016a8:	8846                	mv	a6,a7
    800016aa:	00c6c5b3          	xor	a1,a3,a2
    800016ae:	70077793          	andi	a5,a4,1792
    800016b2:	8fcd                	or	a5,a5,a1
    800016b4:	01d7f7b3          	and	a5,a5,t4
    800016b8:	00833583          	ld	a1,8(t1)
    800016bc:	fdc6e6e3          	bltu	a3,t3,80001688 <core_list_init+0x170>
    800016c0:	0107979b          	slliw	a5,a5,0x10
    800016c4:	4107d79b          	sraiw	a5,a5,0x10
    800016c8:	b7e1                	j	80001690 <core_list_init+0x178>
    800016ca:	4601                	li	a2,0
    800016cc:	00000597          	auipc	a1,0x0
    800016d0:	97c58593          	addi	a1,a1,-1668 # 80001048 <cmp_idx>
    800016d4:	b671                	j	80001260 <core_list_mergesort>

00000000800016d6 <iterate>:
    800016d6:	1101                	addi	sp,sp,-32
    800016d8:	e04a                	sd	s2,0(sp)
    800016da:	02c52903          	lw	s2,44(a0)
    800016de:	ec06                	sd	ra,24(sp)
    800016e0:	e822                	sd	s0,16(sp)
    800016e2:	e426                	sd	s1,8(sp)
    800016e4:	06053023          	sd	zero,96(a0)
    800016e8:	02090e63          	beqz	s2,80001724 <iterate+0x4e>
    800016ec:	842a                	mv	s0,a0
    800016ee:	4481                	li	s1,0
    800016f0:	4585                	li	a1,1
    800016f2:	8522                	mv	a0,s0
    800016f4:	c3dff0ef          	jal	ra,80001330 <core_bench_list>
    800016f8:	06045583          	lhu	a1,96(s0) # ffffffffffff8060 <__global_pointer$+0xffffffff7fff3c40>
    800016fc:	393000ef          	jal	ra,8000228e <crcu16>
    80001700:	55fd                	li	a1,-1
    80001702:	06a41023          	sh	a0,96(s0)
    80001706:	8522                	mv	a0,s0
    80001708:	c29ff0ef          	jal	ra,80001330 <core_bench_list>
    8000170c:	06045583          	lhu	a1,96(s0)
    80001710:	37f000ef          	jal	ra,8000228e <crcu16>
    80001714:	06a41023          	sh	a0,96(s0)
    80001718:	e099                	bnez	s1,8000171e <iterate+0x48>
    8000171a:	06a41123          	sh	a0,98(s0)
    8000171e:	2485                	addiw	s1,s1,1
    80001720:	fc9918e3          	bne	s2,s1,800016f0 <iterate+0x1a>
    80001724:	60e2                	ld	ra,24(sp)
    80001726:	6442                	ld	s0,16(sp)
    80001728:	64a2                	ld	s1,8(sp)
    8000172a:	6902                	ld	s2,0(sp)
    8000172c:	4501                	li	a0,0
    8000172e:	6105                	addi	sp,sp,32
    80001730:	8082                	ret

0000000080001732 <core_init_matrix>:
    80001732:	1141                	addi	sp,sp,-16
    80001734:	e422                	sd	s0,8(sp)
    80001736:	e026                	sd	s1,0(sp)
    80001738:	88aa                	mv	a7,a0
    8000173a:	e211                	bnez	a2,8000173e <core_init_matrix+0xc>
    8000173c:	4605                	li	a2,1
    8000173e:	4801                	li	a6,0
    80001740:	0c088663          	beqz	a7,8000180c <core_init_matrix+0xda>
    80001744:	0018071b          	addiw	a4,a6,1
    80001748:	02e707bb          	mulw	a5,a4,a4
    8000174c:	0008051b          	sext.w	a0,a6
    80001750:	0007081b          	sext.w	a6,a4
    80001754:	0037979b          	slliw	a5,a5,0x3
    80001758:	ff17e6e3          	bltu	a5,a7,80001744 <core_init_matrix+0x12>
    8000175c:	02a503bb          	mulw	t2,a0,a0
    80001760:	15fd                	addi	a1,a1,-1
    80001762:	ffc5f793          	andi	a5,a1,-4
    80001766:	00478e13          	addi	t3,a5,4
    8000176a:	0005041b          	sext.w	s0,a0
    8000176e:	02039793          	slli	a5,t2,0x20
    80001772:	01f7d393          	srli	t2,a5,0x1f
    80001776:	007e08b3          	add	a7,t3,t2
    8000177a:	c15d                	beqz	a0,80001820 <core_init_matrix+0xee>
    8000177c:	6ec1                	lui	t4,0x10
    8000177e:	00150f1b          	addiw	t5,a0,1
    80001782:	4f81                	li	t6,0
    80001784:	4585                	li	a1,1
    80001786:	1efd                	addi	t4,t4,-1 # ffff <_tbss_end+0xffff>
    80001788:	0005829b          	sext.w	t0,a1
    8000178c:	000f031b          	sext.w	t1,t5
    80001790:	02b6063b          	mulw	a2,a2,a1
    80001794:	fff5879b          	addiw	a5,a1,-1
    80001798:	02079813          	slli	a6,a5,0x20
    8000179c:	01f85793          	srli	a5,a6,0x1f
    800017a0:	03059713          	slli	a4,a1,0x30
    800017a4:	9341                	srli	a4,a4,0x30
    800017a6:	00f884b3          	add	s1,a7,a5
    800017aa:	97f2                	add	a5,a5,t3
    800017ac:	2585                	addiw	a1,a1,1
    800017ae:	41f6581b          	sraiw	a6,a2,0x1f
    800017b2:	0108581b          	srliw	a6,a6,0x10
    800017b6:	0106063b          	addw	a2,a2,a6
    800017ba:	01d67633          	and	a2,a2,t4
    800017be:	4106063b          	subw	a2,a2,a6
    800017c2:	00e6083b          	addw	a6,a2,a4
    800017c6:	1842                	slli	a6,a6,0x30
    800017c8:	03085813          	srli	a6,a6,0x30
    800017cc:	00e8073b          	addw	a4,a6,a4
    800017d0:	01049023          	sh	a6,0(s1)
    800017d4:	0ff77713          	zext.b	a4,a4
    800017d8:	00e79023          	sh	a4,0(a5)
    800017dc:	fa659ae3          	bne	a1,t1,80001790 <core_init_matrix+0x5e>
    800017e0:	2f85                	addiw	t6,t6,1
    800017e2:	005505bb          	addw	a1,a0,t0
    800017e6:	01e50f3b          	addw	t5,a0,t5
    800017ea:	f8af9fe3          	bne	t6,a0,80001788 <core_init_matrix+0x56>
    800017ee:	007887b3          	add	a5,a7,t2
    800017f2:	17fd                	addi	a5,a5,-1
    800017f4:	c280                	sw	s0,0(a3)
    800017f6:	9bf1                	andi	a5,a5,-4
    800017f8:	6422                	ld	s0,8(sp)
    800017fa:	0791                	addi	a5,a5,4
    800017fc:	01c6b423          	sd	t3,8(a3)
    80001800:	0116b823          	sd	a7,16(a3)
    80001804:	ee9c                	sd	a5,24(a3)
    80001806:	6482                	ld	s1,0(sp)
    80001808:	0141                	addi	sp,sp,16
    8000180a:	8082                	ret
    8000180c:	15fd                	addi	a1,a1,-1
    8000180e:	ffc5f893          	andi	a7,a1,-4
    80001812:	00488e13          	addi	t3,a7,4
    80001816:	547d                	li	s0,-1
    80001818:	0899                	addi	a7,a7,6
    8000181a:	4389                	li	t2,2
    8000181c:	557d                	li	a0,-1
    8000181e:	bfb9                	j	8000177c <core_init_matrix+0x4a>
    80001820:	4401                	li	s0,0
    80001822:	b7f1                	j	800017ee <core_init_matrix+0xbc>

0000000080001824 <matrix_sum>:
    80001824:	8e2a                	mv	t3,a0
    80001826:	c13d                	beqz	a0,8000188c <matrix_sum+0x68>
    80001828:	832a                	mv	t1,a0
    8000182a:	4e81                	li	t4,0
    8000182c:	4f01                	li	t5,0
    8000182e:	4501                	li	a0,0
    80001830:	4681                	li	a3,0
    80001832:	4881                	li	a7,0
    80001834:	8776                	mv	a4,t4
    80001836:	a801                	j	80001846 <matrix_sum+0x22>
    80001838:	0107951b          	slliw	a0,a5,0x10
    8000183c:	2705                	addiw	a4,a4,1
    8000183e:	4105551b          	sraiw	a0,a0,0x10
    80001842:	02e30d63          	beq	t1,a4,8000187c <matrix_sum+0x58>
    80001846:	02071793          	slli	a5,a4,0x20
    8000184a:	01e7d813          	srli	a6,a5,0x1e
    8000184e:	982e                	add	a6,a6,a1
    80001850:	87b6                	mv	a5,a3
    80001852:	00082683          	lw	a3,0(a6)
    80001856:	1542                	slli	a0,a0,0x30
    80001858:	9141                	srli	a0,a0,0x30
    8000185a:	00d7a7b3          	slt	a5,a5,a3
    8000185e:	00d888bb          	addw	a7,a7,a3
    80001862:	00a5081b          	addiw	a6,a0,10
    80001866:	9fa9                	addw	a5,a5,a0
    80001868:	fd1658e3          	bge	a2,a7,80001838 <matrix_sum+0x14>
    8000186c:	0108151b          	slliw	a0,a6,0x10
    80001870:	2705                	addiw	a4,a4,1
    80001872:	4105551b          	sraiw	a0,a0,0x10
    80001876:	4881                	li	a7,0
    80001878:	fce317e3          	bne	t1,a4,80001846 <matrix_sum+0x22>
    8000187c:	2f05                	addiw	t5,t5,1
    8000187e:	01c3033b          	addw	t1,t1,t3
    80001882:	01ce8ebb          	addw	t4,t4,t3
    80001886:	fbee17e3          	bne	t3,t5,80001834 <matrix_sum+0x10>
    8000188a:	8082                	ret
    8000188c:	4501                	li	a0,0
    8000188e:	8082                	ret

0000000080001890 <matrix_mul_const>:
    80001890:	cd0d                	beqz	a0,800018ca <matrix_mul_const+0x3a>
    80001892:	88aa                	mv	a7,a0
    80001894:	4301                	li	t1,0
    80001896:	4e01                	li	t3,0
    80001898:	871a                	mv	a4,t1
    8000189a:	02071793          	slli	a5,a4,0x20
    8000189e:	9381                	srli	a5,a5,0x20
    800018a0:	00179813          	slli	a6,a5,0x1
    800018a4:	9832                	add	a6,a6,a2
    800018a6:	00081803          	lh	a6,0(a6)
    800018aa:	078a                	slli	a5,a5,0x2
    800018ac:	97ae                	add	a5,a5,a1
    800018ae:	02d8083b          	mulw	a6,a6,a3
    800018b2:	2705                	addiw	a4,a4,1
    800018b4:	0107a023          	sw	a6,0(a5)
    800018b8:	fee891e3          	bne	a7,a4,8000189a <matrix_mul_const+0xa>
    800018bc:	2e05                	addiw	t3,t3,1
    800018be:	0065033b          	addw	t1,a0,t1
    800018c2:	011508bb          	addw	a7,a0,a7
    800018c6:	fdc519e3          	bne	a0,t3,80001898 <matrix_mul_const+0x8>
    800018ca:	8082                	ret

00000000800018cc <matrix_add_const>:
    800018cc:	cd0d                	beqz	a0,80001906 <matrix_add_const+0x3a>
    800018ce:	03061813          	slli	a6,a2,0x30
    800018d2:	03085813          	srli	a6,a6,0x30
    800018d6:	862a                	mv	a2,a0
    800018d8:	4881                	li	a7,0
    800018da:	4301                	li	t1,0
    800018dc:	8746                	mv	a4,a7
    800018de:	02071693          	slli	a3,a4,0x20
    800018e2:	01f6d793          	srli	a5,a3,0x1f
    800018e6:	97ae                	add	a5,a5,a1
    800018e8:	0007d683          	lhu	a3,0(a5)
    800018ec:	2705                	addiw	a4,a4,1
    800018ee:	010686bb          	addw	a3,a3,a6
    800018f2:	00d79023          	sh	a3,0(a5)
    800018f6:	fee614e3          	bne	a2,a4,800018de <matrix_add_const+0x12>
    800018fa:	2305                	addiw	t1,t1,1
    800018fc:	011508bb          	addw	a7,a0,a7
    80001900:	9e29                	addw	a2,a2,a0
    80001902:	fc651de3          	bne	a0,t1,800018dc <matrix_add_const+0x10>
    80001906:	8082                	ret

0000000080001908 <matrix_mul_vect>:
    80001908:	c529                	beqz	a0,80001952 <matrix_mul_vect+0x4a>
    8000190a:	02051793          	slli	a5,a0,0x20
    8000190e:	01e7df13          	srli	t5,a5,0x1e
    80001912:	9f2e                	add	t5,t5,a1
    80001914:	8e2a                	mv	t3,a0
    80001916:	4e81                	li	t4,0
    80001918:	8836                	mv	a6,a3
    8000191a:	8776                	mv	a4,t4
    8000191c:	4881                	li	a7,0
    8000191e:	02071313          	slli	t1,a4,0x20
    80001922:	01f35793          	srli	a5,t1,0x1f
    80001926:	97b2                	add	a5,a5,a2
    80001928:	00081303          	lh	t1,0(a6)
    8000192c:	00079783          	lh	a5,0(a5)
    80001930:	2705                	addiw	a4,a4,1
    80001932:	0809                	addi	a6,a6,2
    80001934:	026787bb          	mulw	a5,a5,t1
    80001938:	011788bb          	addw	a7,a5,a7
    8000193c:	feee11e3          	bne	t3,a4,8000191e <matrix_mul_vect+0x16>
    80001940:	0115a023          	sw	a7,0(a1)
    80001944:	0591                	addi	a1,a1,4
    80001946:	01d50ebb          	addw	t4,a0,t4
    8000194a:	01c50e3b          	addw	t3,a0,t3
    8000194e:	fcbf15e3          	bne	t5,a1,80001918 <matrix_mul_vect+0x10>
    80001952:	8082                	ret

0000000080001954 <matrix_mul_matrix>:
    80001954:	82ae                	mv	t0,a1
    80001956:	8332                	mv	t1,a2
    80001958:	88b6                	mv	a7,a3
    8000195a:	882a                	mv	a6,a0
    8000195c:	4f81                	li	t6,0
    8000195e:	4381                	li	t2,0
    80001960:	c52d                	beqz	a0,800019ca <matrix_mul_matrix+0x76>
    80001962:	4f01                	li	t5,0
    80001964:	01ff07bb          	addw	a5,t5,t6
    80001968:	02079713          	slli	a4,a5,0x20
    8000196c:	01e75793          	srli	a5,a4,0x1e
    80001970:	00f28eb3          	add	t4,t0,a5
    80001974:	867a                	mv	a2,t5
    80001976:	877e                	mv	a4,t6
    80001978:	4581                	li	a1,0
    8000197a:	02071693          	slli	a3,a4,0x20
    8000197e:	02061e13          	slli	t3,a2,0x20
    80001982:	01f6d793          	srli	a5,a3,0x1f
    80001986:	01fe5693          	srli	a3,t3,0x1f
    8000198a:	979a                	add	a5,a5,t1
    8000198c:	96c6                	add	a3,a3,a7
    8000198e:	00079783          	lh	a5,0(a5)
    80001992:	00069683          	lh	a3,0(a3)
    80001996:	2705                	addiw	a4,a4,1
    80001998:	9e29                	addw	a2,a2,a0
    8000199a:	02d787bb          	mulw	a5,a5,a3
    8000199e:	9dbd                	addw	a1,a1,a5
    800019a0:	fce81de3          	bne	a6,a4,8000197a <matrix_mul_matrix+0x26>
    800019a4:	00bea023          	sw	a1,0(t4)
    800019a8:	001f079b          	addiw	a5,t5,1
    800019ac:	00f50463          	beq	a0,a5,800019b4 <matrix_mul_matrix+0x60>
    800019b0:	8f3e                	mv	t5,a5
    800019b2:	bf4d                	j	80001964 <matrix_mul_matrix+0x10>
    800019b4:	0013879b          	addiw	a5,t2,1
    800019b8:	01f50fbb          	addw	t6,a0,t6
    800019bc:	0105083b          	addw	a6,a0,a6
    800019c0:	01e38463          	beq	t2,t5,800019c8 <matrix_mul_matrix+0x74>
    800019c4:	83be                	mv	t2,a5
    800019c6:	bf71                	j	80001962 <matrix_mul_matrix+0xe>
    800019c8:	8082                	ret
    800019ca:	8082                	ret

00000000800019cc <matrix_mul_matrix_bitextract>:
    800019cc:	8fae                	mv	t6,a1
    800019ce:	8332                	mv	t1,a2
    800019d0:	88b6                	mv	a7,a3
    800019d2:	882a                	mv	a6,a0
    800019d4:	4f01                	li	t5,0
    800019d6:	4281                	li	t0,0
    800019d8:	cd35                	beqz	a0,80001a54 <matrix_mul_matrix_bitextract+0x88>
    800019da:	4e81                	li	t4,0
    800019dc:	01ee87bb          	addw	a5,t4,t5
    800019e0:	02079713          	slli	a4,a5,0x20
    800019e4:	01e75793          	srli	a5,a4,0x1e
    800019e8:	00ff83b3          	add	t2,t6,a5
    800019ec:	8676                	mv	a2,t4
    800019ee:	86fa                	mv	a3,t5
    800019f0:	4581                	li	a1,0
    800019f2:	02069713          	slli	a4,a3,0x20
    800019f6:	02061e13          	slli	t3,a2,0x20
    800019fa:	01f75793          	srli	a5,a4,0x1f
    800019fe:	01fe5713          	srli	a4,t3,0x1f
    80001a02:	979a                	add	a5,a5,t1
    80001a04:	9746                	add	a4,a4,a7
    80001a06:	00071703          	lh	a4,0(a4)
    80001a0a:	00079783          	lh	a5,0(a5)
    80001a0e:	2685                	addiw	a3,a3,1
    80001a10:	9e29                	addw	a2,a2,a0
    80001a12:	02e787bb          	mulw	a5,a5,a4
    80001a16:	4027d71b          	sraiw	a4,a5,0x2
    80001a1a:	4057d79b          	sraiw	a5,a5,0x5
    80001a1e:	8b3d                	andi	a4,a4,15
    80001a20:	07f7f793          	andi	a5,a5,127
    80001a24:	02f707bb          	mulw	a5,a4,a5
    80001a28:	9dbd                	addw	a1,a1,a5
    80001a2a:	fcd814e3          	bne	a6,a3,800019f2 <matrix_mul_matrix_bitextract+0x26>
    80001a2e:	00b3a023          	sw	a1,0(t2)
    80001a32:	001e879b          	addiw	a5,t4,1
    80001a36:	00f50463          	beq	a0,a5,80001a3e <matrix_mul_matrix_bitextract+0x72>
    80001a3a:	8ebe                	mv	t4,a5
    80001a3c:	b745                	j	800019dc <matrix_mul_matrix_bitextract+0x10>
    80001a3e:	0012879b          	addiw	a5,t0,1
    80001a42:	01e50f3b          	addw	t5,a0,t5
    80001a46:	0105083b          	addw	a6,a0,a6
    80001a4a:	01d28463          	beq	t0,t4,80001a52 <matrix_mul_matrix_bitextract+0x86>
    80001a4e:	82be                	mv	t0,a5
    80001a50:	b769                	j	800019da <matrix_mul_matrix_bitextract+0xe>
    80001a52:	8082                	ret
    80001a54:	8082                	ret

0000000080001a56 <matrix_test>:
    80001a56:	715d                	addi	sp,sp,-80
    80001a58:	e0a2                	sd	s0,64(sp)
    80001a5a:	fc26                	sd	s1,56(sp)
    80001a5c:	f052                	sd	s4,32(sp)
    80001a5e:	e486                	sd	ra,72(sp)
    80001a60:	f84a                	sd	s2,48(sp)
    80001a62:	f44e                	sd	s3,40(sp)
    80001a64:	ec56                	sd	s5,24(sp)
    80001a66:	e85a                	sd	s6,16(sp)
    80001a68:	e45e                	sd	s7,8(sp)
    80001a6a:	e062                	sd	s8,0(sp)
    80001a6c:	84ae                	mv	s1,a1
    80001a6e:	8a32                	mv	s4,a2
    80001a70:	8436                	mv	s0,a3
    80001a72:	28050e63          	beqz	a0,80001d0e <matrix_test+0x2b8>
    80001a76:	03071993          	slli	s3,a4,0x30
    80001a7a:	8baa                	mv	s7,a0
    80001a7c:	0309d993          	srli	s3,s3,0x30
    80001a80:	4801                	li	a6,0
    80001a82:	4581                	li	a1,0
    80001a84:	86c2                	mv	a3,a6
    80001a86:	02069613          	slli	a2,a3,0x20
    80001a8a:	01f65793          	srli	a5,a2,0x1f
    80001a8e:	97d2                	add	a5,a5,s4
    80001a90:	0007d603          	lhu	a2,0(a5)
    80001a94:	2685                	addiw	a3,a3,1
    80001a96:	0136063b          	addw	a2,a2,s3
    80001a9a:	00c79023          	sh	a2,0(a5)
    80001a9e:	fed514e3          	bne	a0,a3,80001a86 <matrix_test+0x30>
    80001aa2:	0015889b          	addiw	a7,a1,1
    80001aa6:	010b883b          	addw	a6,s7,a6
    80001aaa:	00ab853b          	addw	a0,s7,a0
    80001aae:	011b8463          	beq	s7,a7,80001ab6 <matrix_test+0x60>
    80001ab2:	85c6                	mv	a1,a7
    80001ab4:	bfc1                	j	80001a84 <matrix_test+0x2e>
    80001ab6:	885e                	mv	a6,s7
    80001ab8:	4301                	li	t1,0
    80001aba:	4e01                	li	t3,0
    80001abc:	869a                	mv	a3,t1
    80001abe:	02069793          	slli	a5,a3,0x20
    80001ac2:	9381                	srli	a5,a5,0x20
    80001ac4:	00179613          	slli	a2,a5,0x1
    80001ac8:	9652                	add	a2,a2,s4
    80001aca:	00061603          	lh	a2,0(a2)
    80001ace:	078a                	slli	a5,a5,0x2
    80001ad0:	97a6                	add	a5,a5,s1
    80001ad2:	02e6063b          	mulw	a2,a2,a4
    80001ad6:	2685                	addiw	a3,a3,1
    80001ad8:	c390                	sw	a2,0(a5)
    80001ada:	ff0692e3          	bne	a3,a6,80001abe <matrix_test+0x68>
    80001ade:	001e079b          	addiw	a5,t3,1
    80001ae2:	0068833b          	addw	t1,a7,t1
    80001ae6:	0116883b          	addw	a6,a3,a7
    80001aea:	00be0463          	beq	t3,a1,80001af2 <matrix_test+0x9c>
    80001aee:	8e3e                	mv	t3,a5
    80001af0:	b7f1                	j	80001abc <matrix_test+0x66>
    80001af2:	77fd                	lui	a5,0xfffff
    80001af4:	00f76933          	or	s2,a4,a5
    80001af8:	8346                	mv	t1,a7
    80001afa:	4e01                	li	t3,0
    80001afc:	4501                	li	a0,0
    80001afe:	4681                	li	a3,0
    80001b00:	4801                	li	a6,0
    80001b02:	4e81                	li	t4,0
    80001b04:	8772                	mv	a4,t3
    80001b06:	a809                	j	80001b18 <matrix_test+0xc2>
    80001b08:	0107951b          	slliw	a0,a5,0x10
    80001b0c:	2705                	addiw	a4,a4,1
    80001b0e:	4105551b          	sraiw	a0,a0,0x10
    80001b12:	87ba                	mv	a5,a4
    80001b14:	02670d63          	beq	a4,t1,80001b4e <matrix_test+0xf8>
    80001b18:	02071793          	slli	a5,a4,0x20
    80001b1c:	01e7d613          	srli	a2,a5,0x1e
    80001b20:	9626                	add	a2,a2,s1
    80001b22:	87b6                	mv	a5,a3
    80001b24:	4214                	lw	a3,0(a2)
    80001b26:	1542                	slli	a0,a0,0x30
    80001b28:	9141                	srli	a0,a0,0x30
    80001b2a:	00d7a7b3          	slt	a5,a5,a3
    80001b2e:	00d8083b          	addw	a6,a6,a3
    80001b32:	00a5061b          	addiw	a2,a0,10
    80001b36:	9fa9                	addw	a5,a5,a0
    80001b38:	fd0958e3          	bge	s2,a6,80001b08 <matrix_test+0xb2>
    80001b3c:	0106151b          	slliw	a0,a2,0x10
    80001b40:	2705                	addiw	a4,a4,1
    80001b42:	4105551b          	sraiw	a0,a0,0x10
    80001b46:	4801                	li	a6,0
    80001b48:	87ba                	mv	a5,a4
    80001b4a:	fc6717e3          	bne	a4,t1,80001b18 <matrix_test+0xc2>
    80001b4e:	001e871b          	addiw	a4,t4,1
    80001b52:	0117833b          	addw	t1,a5,a7
    80001b56:	011e0e3b          	addw	t3,t3,a7
    80001b5a:	01d58463          	beq	a1,t4,80001b62 <matrix_test+0x10c>
    80001b5e:	8eba                	mv	t4,a4
    80001b60:	b755                	j	80001b04 <matrix_test+0xae>
    80001b62:	4581                	li	a1,0
    80001b64:	02d000ef          	jal	ra,80002390 <crc16>
    80001b68:	86a2                	mv	a3,s0
    80001b6a:	85a6                	mv	a1,s1
    80001b6c:	8b2a                	mv	s6,a0
    80001b6e:	8652                	mv	a2,s4
    80001b70:	855e                	mv	a0,s7
    80001b72:	d97ff0ef          	jal	ra,80001908 <matrix_mul_vect>
    80001b76:	4a81                	li	s5,0
    80001b78:	885e                	mv	a6,s7
    80001b7a:	4881                	li	a7,0
    80001b7c:	4501                	li	a0,0
    80001b7e:	4681                	li	a3,0
    80001b80:	4581                	li	a1,0
    80001b82:	8746                	mv	a4,a7
    80001b84:	a801                	j	80001b94 <matrix_test+0x13e>
    80001b86:	0107951b          	slliw	a0,a5,0x10
    80001b8a:	2705                	addiw	a4,a4,1
    80001b8c:	4105551b          	sraiw	a0,a0,0x10
    80001b90:	03070b63          	beq	a4,a6,80001bc6 <matrix_test+0x170>
    80001b94:	02071793          	slli	a5,a4,0x20
    80001b98:	01e7d613          	srli	a2,a5,0x1e
    80001b9c:	9626                	add	a2,a2,s1
    80001b9e:	87b6                	mv	a5,a3
    80001ba0:	4214                	lw	a3,0(a2)
    80001ba2:	1542                	slli	a0,a0,0x30
    80001ba4:	9141                	srli	a0,a0,0x30
    80001ba6:	00d7a7b3          	slt	a5,a5,a3
    80001baa:	9db5                	addw	a1,a1,a3
    80001bac:	00a5061b          	addiw	a2,a0,10
    80001bb0:	9fa9                	addw	a5,a5,a0
    80001bb2:	fcb95ae3          	bge	s2,a1,80001b86 <matrix_test+0x130>
    80001bb6:	0106151b          	slliw	a0,a2,0x10
    80001bba:	2705                	addiw	a4,a4,1
    80001bbc:	4105551b          	sraiw	a0,a0,0x10
    80001bc0:	4581                	li	a1,0
    80001bc2:	fd0719e3          	bne	a4,a6,80001b94 <matrix_test+0x13e>
    80001bc6:	001a8c1b          	addiw	s8,s5,1
    80001bca:	0177083b          	addw	a6,a4,s7
    80001bce:	011b88bb          	addw	a7,s7,a7
    80001bd2:	018b8463          	beq	s7,s8,80001bda <matrix_test+0x184>
    80001bd6:	8ae2                	mv	s5,s8
    80001bd8:	b76d                	j	80001b82 <matrix_test+0x12c>
    80001bda:	85da                	mv	a1,s6
    80001bdc:	7b4000ef          	jal	ra,80002390 <crc16>
    80001be0:	86a2                	mv	a3,s0
    80001be2:	85a6                	mv	a1,s1
    80001be4:	8b2a                	mv	s6,a0
    80001be6:	8652                	mv	a2,s4
    80001be8:	8562                	mv	a0,s8
    80001bea:	d6bff0ef          	jal	ra,80001954 <matrix_mul_matrix>
    80001bee:	8862                	mv	a6,s8
    80001bf0:	4881                	li	a7,0
    80001bf2:	4501                	li	a0,0
    80001bf4:	4681                	li	a3,0
    80001bf6:	4581                	li	a1,0
    80001bf8:	4301                	li	t1,0
    80001bfa:	8746                	mv	a4,a7
    80001bfc:	a809                	j	80001c0e <matrix_test+0x1b8>
    80001bfe:	0107951b          	slliw	a0,a5,0x10
    80001c02:	2705                	addiw	a4,a4,1
    80001c04:	4105551b          	sraiw	a0,a0,0x10
    80001c08:	87ba                	mv	a5,a4
    80001c0a:	03070c63          	beq	a4,a6,80001c42 <matrix_test+0x1ec>
    80001c0e:	02071793          	slli	a5,a4,0x20
    80001c12:	01e7d613          	srli	a2,a5,0x1e
    80001c16:	9626                	add	a2,a2,s1
    80001c18:	87b6                	mv	a5,a3
    80001c1a:	4214                	lw	a3,0(a2)
    80001c1c:	1542                	slli	a0,a0,0x30
    80001c1e:	9141                	srli	a0,a0,0x30
    80001c20:	00d7a7b3          	slt	a5,a5,a3
    80001c24:	9db5                	addw	a1,a1,a3
    80001c26:	00a5061b          	addiw	a2,a0,10
    80001c2a:	9fa9                	addw	a5,a5,a0
    80001c2c:	fcb959e3          	bge	s2,a1,80001bfe <matrix_test+0x1a8>
    80001c30:	0106151b          	slliw	a0,a2,0x10
    80001c34:	2705                	addiw	a4,a4,1
    80001c36:	4105551b          	sraiw	a0,a0,0x10
    80001c3a:	4581                	li	a1,0
    80001c3c:	87ba                	mv	a5,a4
    80001c3e:	fd0718e3          	bne	a4,a6,80001c0e <matrix_test+0x1b8>
    80001c42:	0013071b          	addiw	a4,t1,1
    80001c46:	0187883b          	addw	a6,a5,s8
    80001c4a:	011c08bb          	addw	a7,s8,a7
    80001c4e:	006a8463          	beq	s5,t1,80001c56 <matrix_test+0x200>
    80001c52:	833a                	mv	t1,a4
    80001c54:	b75d                	j	80001bfa <matrix_test+0x1a4>
    80001c56:	85da                	mv	a1,s6
    80001c58:	738000ef          	jal	ra,80002390 <crc16>
    80001c5c:	87aa                	mv	a5,a0
    80001c5e:	86a2                	mv	a3,s0
    80001c60:	85a6                	mv	a1,s1
    80001c62:	8562                	mv	a0,s8
    80001c64:	8652                	mv	a2,s4
    80001c66:	843e                	mv	s0,a5
    80001c68:	d65ff0ef          	jal	ra,800019cc <matrix_mul_matrix_bitextract>
    80001c6c:	8862                	mv	a6,s8
    80001c6e:	4881                	li	a7,0
    80001c70:	4501                	li	a0,0
    80001c72:	4681                	li	a3,0
    80001c74:	4581                	li	a1,0
    80001c76:	4301                	li	t1,0
    80001c78:	8746                	mv	a4,a7
    80001c7a:	a801                	j	80001c8a <matrix_test+0x234>
    80001c7c:	0107951b          	slliw	a0,a5,0x10
    80001c80:	2705                	addiw	a4,a4,1
    80001c82:	4105551b          	sraiw	a0,a0,0x10
    80001c86:	02e80b63          	beq	a6,a4,80001cbc <matrix_test+0x266>
    80001c8a:	02071793          	slli	a5,a4,0x20
    80001c8e:	01e7d613          	srli	a2,a5,0x1e
    80001c92:	9626                	add	a2,a2,s1
    80001c94:	87b6                	mv	a5,a3
    80001c96:	4214                	lw	a3,0(a2)
    80001c98:	1542                	slli	a0,a0,0x30
    80001c9a:	9141                	srli	a0,a0,0x30
    80001c9c:	00d7a7b3          	slt	a5,a5,a3
    80001ca0:	9db5                	addw	a1,a1,a3
    80001ca2:	00a5061b          	addiw	a2,a0,10
    80001ca6:	9fa9                	addw	a5,a5,a0
    80001ca8:	fcb95ae3          	bge	s2,a1,80001c7c <matrix_test+0x226>
    80001cac:	0106151b          	slliw	a0,a2,0x10
    80001cb0:	2705                	addiw	a4,a4,1
    80001cb2:	4105551b          	sraiw	a0,a0,0x10
    80001cb6:	4581                	li	a1,0
    80001cb8:	fce819e3          	bne	a6,a4,80001c8a <matrix_test+0x234>
    80001cbc:	0013079b          	addiw	a5,t1,1
    80001cc0:	010c083b          	addw	a6,s8,a6
    80001cc4:	011c08bb          	addw	a7,s8,a7
    80001cc8:	006a8463          	beq	s5,t1,80001cd0 <matrix_test+0x27a>
    80001ccc:	833e                	mv	t1,a5
    80001cce:	b76d                	j	80001c78 <matrix_test+0x222>
    80001cd0:	85a2                	mv	a1,s0
    80001cd2:	6be000ef          	jal	ra,80002390 <crc16>
    80001cd6:	8662                	mv	a2,s8
    80001cd8:	4581                	li	a1,0
    80001cda:	4801                	li	a6,0
    80001cdc:	872e                	mv	a4,a1
    80001cde:	02071693          	slli	a3,a4,0x20
    80001ce2:	01f6d793          	srli	a5,a3,0x1f
    80001ce6:	97d2                	add	a5,a5,s4
    80001ce8:	0007d683          	lhu	a3,0(a5) # fffffffffffff000 <__global_pointer$+0xffffffff7fffabe0>
    80001cec:	2705                	addiw	a4,a4,1
    80001cee:	413686bb          	subw	a3,a3,s3
    80001cf2:	00d79023          	sh	a3,0(a5)
    80001cf6:	fec714e3          	bne	a4,a2,80001cde <matrix_test+0x288>
    80001cfa:	0018079b          	addiw	a5,a6,1
    80001cfe:	00bc05bb          	addw	a1,s8,a1
    80001d02:	00cc063b          	addw	a2,s8,a2
    80001d06:	050a8963          	beq	s5,a6,80001d58 <matrix_test+0x302>
    80001d0a:	883e                	mv	a6,a5
    80001d0c:	bfc1                	j	80001cdc <matrix_test+0x286>
    80001d0e:	4581                	li	a1,0
    80001d10:	680000ef          	jal	ra,80002390 <crc16>
    80001d14:	86a2                	mv	a3,s0
    80001d16:	892a                	mv	s2,a0
    80001d18:	8652                	mv	a2,s4
    80001d1a:	4501                	li	a0,0
    80001d1c:	85a6                	mv	a1,s1
    80001d1e:	bebff0ef          	jal	ra,80001908 <matrix_mul_vect>
    80001d22:	85ca                	mv	a1,s2
    80001d24:	4501                	li	a0,0
    80001d26:	66a000ef          	jal	ra,80002390 <crc16>
    80001d2a:	86a2                	mv	a3,s0
    80001d2c:	8652                	mv	a2,s4
    80001d2e:	892a                	mv	s2,a0
    80001d30:	85a6                	mv	a1,s1
    80001d32:	4501                	li	a0,0
    80001d34:	c21ff0ef          	jal	ra,80001954 <matrix_mul_matrix>
    80001d38:	85ca                	mv	a1,s2
    80001d3a:	4501                	li	a0,0
    80001d3c:	654000ef          	jal	ra,80002390 <crc16>
    80001d40:	87aa                	mv	a5,a0
    80001d42:	86a2                	mv	a3,s0
    80001d44:	4501                	li	a0,0
    80001d46:	85a6                	mv	a1,s1
    80001d48:	8652                	mv	a2,s4
    80001d4a:	843e                	mv	s0,a5
    80001d4c:	c81ff0ef          	jal	ra,800019cc <matrix_mul_matrix_bitextract>
    80001d50:	85a2                	mv	a1,s0
    80001d52:	4501                	li	a0,0
    80001d54:	63c000ef          	jal	ra,80002390 <crc16>
    80001d58:	60a6                	ld	ra,72(sp)
    80001d5a:	6406                	ld	s0,64(sp)
    80001d5c:	0105151b          	slliw	a0,a0,0x10
    80001d60:	74e2                	ld	s1,56(sp)
    80001d62:	7942                	ld	s2,48(sp)
    80001d64:	79a2                	ld	s3,40(sp)
    80001d66:	7a02                	ld	s4,32(sp)
    80001d68:	6ae2                	ld	s5,24(sp)
    80001d6a:	6b42                	ld	s6,16(sp)
    80001d6c:	6ba2                	ld	s7,8(sp)
    80001d6e:	6c02                	ld	s8,0(sp)
    80001d70:	4105551b          	sraiw	a0,a0,0x10
    80001d74:	6161                	addi	sp,sp,80
    80001d76:	8082                	ret

0000000080001d78 <core_bench_matrix>:
    80001d78:	1141                	addi	sp,sp,-16
    80001d7a:	e022                	sd	s0,0(sp)
    80001d7c:	6914                	ld	a3,16(a0)
    80001d7e:	8432                	mv	s0,a2
    80001d80:	872e                	mv	a4,a1
    80001d82:	6510                	ld	a2,8(a0)
    80001d84:	6d0c                	ld	a1,24(a0)
    80001d86:	4108                	lw	a0,0(a0)
    80001d88:	e406                	sd	ra,8(sp)
    80001d8a:	ccdff0ef          	jal	ra,80001a56 <matrix_test>
    80001d8e:	85a2                	mv	a1,s0
    80001d90:	6402                	ld	s0,0(sp)
    80001d92:	60a2                	ld	ra,8(sp)
    80001d94:	0141                	addi	sp,sp,16
    80001d96:	abed                	j	80002390 <crc16>

0000000080001d98 <core_init_state>:
    80001d98:	fff5089b          	addiw	a7,a0,-1
    80001d9c:	4785                	li	a5,1
    80001d9e:	1117fa63          	bgeu	a5,a7,80001eb2 <core_init_state+0x11a>
    80001da2:	2585                	addiw	a1,a1,1
    80001da4:	03059813          	slli	a6,a1,0x30
    80001da8:	03085813          	srli	a6,a6,0x30
    80001dac:	00385793          	srli	a5,a6,0x3
    80001db0:	4e9d                	li	t4,7
    80001db2:	00787593          	andi	a1,a6,7
    80001db6:	4701                	li	a4,0
    80001db8:	00002f17          	auipc	t5,0x2
    80001dbc:	b90f0f13          	addi	t5,t5,-1136 # 80003948 <intpat>
    80001dc0:	4e11                	li	t3,4
    80001dc2:	4305                	li	t1,1
    80001dc4:	02c00f93          	li	t6,44
    80001dc8:	8b8d                	andi	a5,a5,3
    80001dca:	0dd58763          	beq	a1,t4,80001e98 <core_init_state+0x100>
    80001dce:	0cbe6d63          	bltu	t3,a1,80001ea8 <core_init_state+0x110>
    80001dd2:	ffd5869b          	addiw	a3,a1,-3
    80001dd6:	16c2                	slli	a3,a3,0x30
    80001dd8:	078e                	slli	a5,a5,0x3
    80001dda:	92c1                	srli	a3,a3,0x30
    80001ddc:	97fa                	add	a5,a5,t5
    80001dde:	0cd36263          	bltu	t1,a3,80001ea2 <core_init_state+0x10a>
    80001de2:	739c                	ld	a5,32(a5)
    80001de4:	45a1                	li	a1,8
    80001de6:	0017069b          	addiw	a3,a4,1
    80001dea:	00b683bb          	addw	t2,a3,a1
    80001dee:	0f13f263          	bgeu	t2,a7,80001ed2 <core_init_state+0x13a>
    80001df2:	1141                	addi	sp,sp,-16
    80001df4:	e422                	sd	s0,8(sp)
    80001df6:	1702                	slli	a4,a4,0x20
    80001df8:	02059413          	slli	s0,a1,0x20
    80001dfc:	9301                	srli	a4,a4,0x20
    80001dfe:	00e606b3          	add	a3,a2,a4
    80001e02:	9001                	srli	s0,s0,0x20
    80001e04:	95be                	add	a1,a1,a5
    80001e06:	0007c283          	lbu	t0,0(a5)
    80001e0a:	0785                	addi	a5,a5,1
    80001e0c:	0685                	addi	a3,a3,1
    80001e0e:	fe568fa3          	sb	t0,-1(a3)
    80001e12:	fef59ae3          	bne	a1,a5,80001e06 <core_init_state+0x6e>
    80001e16:	2805                	addiw	a6,a6,1
    80001e18:	9432                	add	s0,s0,a2
    80001e1a:	1842                	slli	a6,a6,0x30
    80001e1c:	943a                	add	s0,s0,a4
    80001e1e:	03085813          	srli	a6,a6,0x30
    80001e22:	00385793          	srli	a5,a6,0x3
    80001e26:	01f40023          	sb	t6,0(s0)
    80001e2a:	00787593          	andi	a1,a6,7
    80001e2e:	871e                	mv	a4,t2
    80001e30:	8b8d                	andi	a5,a5,3
    80001e32:	05d58e63          	beq	a1,t4,80001e8e <core_init_state+0xf6>
    80001e36:	04be6763          	bltu	t3,a1,80001e84 <core_init_state+0xec>
    80001e3a:	ffd5869b          	addiw	a3,a1,-3
    80001e3e:	16c2                	slli	a3,a3,0x30
    80001e40:	078e                	slli	a5,a5,0x3
    80001e42:	92c1                	srli	a3,a3,0x30
    80001e44:	97fa                	add	a5,a5,t5
    80001e46:	02d36c63          	bltu	t1,a3,80001e7e <core_init_state+0xe6>
    80001e4a:	739c                	ld	a5,32(a5)
    80001e4c:	45a1                	li	a1,8
    80001e4e:	0017069b          	addiw	a3,a4,1
    80001e52:	00b683bb          	addw	t2,a3,a1
    80001e56:	fb13e0e3          	bltu	t2,a7,80001df6 <core_init_state+0x5e>
    80001e5a:	00a76563          	bltu	a4,a0,80001e64 <core_init_state+0xcc>
    80001e5e:	a829                	j	80001e78 <core_init_state+0xe0>
    80001e60:	0017069b          	addiw	a3,a4,1
    80001e64:	02071793          	slli	a5,a4,0x20
    80001e68:	9381                	srli	a5,a5,0x20
    80001e6a:	97b2                	add	a5,a5,a2
    80001e6c:	0006871b          	sext.w	a4,a3
    80001e70:	00078023          	sb	zero,0(a5)
    80001e74:	fea766e3          	bltu	a4,a0,80001e60 <core_init_state+0xc8>
    80001e78:	6422                	ld	s0,8(sp)
    80001e7a:	0141                	addi	sp,sp,16
    80001e7c:	8082                	ret
    80001e7e:	639c                	ld	a5,0(a5)
    80001e80:	4591                	li	a1,4
    80001e82:	b7f1                	j	80001e4e <core_init_state+0xb6>
    80001e84:	078e                	slli	a5,a5,0x3
    80001e86:	97fa                	add	a5,a5,t5
    80001e88:	63bc                	ld	a5,64(a5)
    80001e8a:	45a1                	li	a1,8
    80001e8c:	b7c9                	j	80001e4e <core_init_state+0xb6>
    80001e8e:	078e                	slli	a5,a5,0x3
    80001e90:	97fa                	add	a5,a5,t5
    80001e92:	73bc                	ld	a5,96(a5)
    80001e94:	45a1                	li	a1,8
    80001e96:	bf65                	j	80001e4e <core_init_state+0xb6>
    80001e98:	078e                	slli	a5,a5,0x3
    80001e9a:	97fa                	add	a5,a5,t5
    80001e9c:	73bc                	ld	a5,96(a5)
    80001e9e:	45a1                	li	a1,8
    80001ea0:	b799                	j	80001de6 <core_init_state+0x4e>
    80001ea2:	639c                	ld	a5,0(a5)
    80001ea4:	4591                	li	a1,4
    80001ea6:	b781                	j	80001de6 <core_init_state+0x4e>
    80001ea8:	078e                	slli	a5,a5,0x3
    80001eaa:	97fa                	add	a5,a5,t5
    80001eac:	63bc                	ld	a5,64(a5)
    80001eae:	45a1                	li	a1,8
    80001eb0:	bf1d                	j	80001de6 <core_init_state+0x4e>
    80001eb2:	4701                	li	a4,0
    80001eb4:	4685                	li	a3,1
    80001eb6:	a019                	j	80001ebc <core_init_state+0x124>
    80001eb8:	0017069b          	addiw	a3,a4,1
    80001ebc:	02071793          	slli	a5,a4,0x20
    80001ec0:	9381                	srli	a5,a5,0x20
    80001ec2:	97b2                	add	a5,a5,a2
    80001ec4:	0006871b          	sext.w	a4,a3
    80001ec8:	00078023          	sb	zero,0(a5)
    80001ecc:	fea766e3          	bltu	a4,a0,80001eb8 <core_init_state+0x120>
    80001ed0:	8082                	ret
    80001ed2:	fea765e3          	bltu	a4,a0,80001ebc <core_init_state+0x124>
    80001ed6:	8082                	ret

0000000080001ed8 <core_state_transition>:
    80001ed8:	6118                	ld	a4,0(a0)
    80001eda:	862a                	mv	a2,a0
    80001edc:	00074683          	lbu	a3,0(a4)
    80001ee0:	1c068563          	beqz	a3,800020aa <core_state_transition+0x1d2>
    80001ee4:	02c00793          	li	a5,44
    80001ee8:	4501                	li	a0,0
    80001eea:	16f68063          	beq	a3,a5,8000204a <core_state_transition+0x172>
    80001eee:	fd06851b          	addiw	a0,a3,-48
    80001ef2:	0ff57513          	zext.b	a0,a0
    80001ef6:	4825                	li	a6,9
    80001ef8:	02a87863          	bgeu	a6,a0,80001f28 <core_state_transition+0x50>
    80001efc:	02d00513          	li	a0,45
    80001f00:	14a68e63          	beq	a3,a0,8000205c <core_state_transition+0x184>
    80001f04:	02e00513          	li	a0,46
    80001f08:	06a68663          	beq	a3,a0,80001f74 <core_state_transition+0x9c>
    80001f0c:	02b00513          	li	a0,43
    80001f10:	14a68663          	beq	a3,a0,8000205c <core_state_transition+0x184>
    80001f14:	41d4                	lw	a3,4(a1)
    80001f16:	419c                	lw	a5,0(a1)
    80001f18:	0705                	addi	a4,a4,1
    80001f1a:	2685                	addiw	a3,a3,1
    80001f1c:	2785                	addiw	a5,a5,1
    80001f1e:	c1d4                	sw	a3,4(a1)
    80001f20:	c19c                	sw	a5,0(a1)
    80001f22:	4505                	li	a0,1
    80001f24:	e218                	sd	a4,0(a2)
    80001f26:	8082                	ret
    80001f28:	4188                	lw	a0,0(a1)
    80001f2a:	00170693          	addi	a3,a4,1
    80001f2e:	2505                	addiw	a0,a0,1
    80001f30:	c188                	sw	a0,0(a1)
    80001f32:	00174703          	lbu	a4,1(a4)
    80001f36:	16070463          	beqz	a4,8000209e <core_state_transition+0x1c6>
    80001f3a:	10f70663          	beq	a4,a5,80002046 <core_state_transition+0x16e>
    80001f3e:	02e00793          	li	a5,46
    80001f42:	0ef70e63          	beq	a4,a5,8000203e <core_state_transition+0x166>
    80001f46:	fd07071b          	addiw	a4,a4,-48
    80001f4a:	0ff77713          	zext.b	a4,a4
    80001f4e:	47a5                	li	a5,9
    80001f50:	00e7ea63          	bltu	a5,a4,80001f64 <core_state_transition+0x8c>
    80001f54:	0016c703          	lbu	a4,1(a3)
    80001f58:	0685                	addi	a3,a3,1
    80001f5a:	14070263          	beqz	a4,8000209e <core_state_transition+0x1c6>
    80001f5e:	02c00793          	li	a5,44
    80001f62:	bfe1                	j	80001f3a <core_state_transition+0x62>
    80001f64:	499c                	lw	a5,16(a1)
    80001f66:	00168713          	addi	a4,a3,1
    80001f6a:	4505                	li	a0,1
    80001f6c:	2785                	addiw	a5,a5,1
    80001f6e:	c99c                	sw	a5,16(a1)
    80001f70:	e218                	sd	a4,0(a2)
    80001f72:	8082                	ret
    80001f74:	4188                	lw	a0,0(a1)
    80001f76:	00170693          	addi	a3,a4,1
    80001f7a:	2505                	addiw	a0,a0,1
    80001f7c:	c188                	sw	a0,0(a1)
    80001f7e:	00174703          	lbu	a4,1(a4)
    80001f82:	12070163          	beqz	a4,800020a4 <core_state_transition+0x1cc>
    80001f86:	14f70363          	beq	a4,a5,800020cc <core_state_transition+0x1f4>
    80001f8a:	0df77793          	andi	a5,a4,223
    80001f8e:	04500513          	li	a0,69
    80001f92:	02a78063          	beq	a5,a0,80001fb2 <core_state_transition+0xda>
    80001f96:	fd07071b          	addiw	a4,a4,-48
    80001f9a:	0ff77713          	zext.b	a4,a4
    80001f9e:	47a5                	li	a5,9
    80001fa0:	0ae7e763          	bltu	a5,a4,8000204e <core_state_transition+0x176>
    80001fa4:	0016c703          	lbu	a4,1(a3)
    80001fa8:	0685                	addi	a3,a3,1
    80001faa:	cf6d                	beqz	a4,800020a4 <core_state_transition+0x1cc>
    80001fac:	02c00793          	li	a5,44
    80001fb0:	bfd9                	j	80001f86 <core_state_transition+0xae>
    80001fb2:	49dc                	lw	a5,20(a1)
    80001fb4:	00168713          	addi	a4,a3,1
    80001fb8:	2785                	addiw	a5,a5,1
    80001fba:	c9dc                	sw	a5,20(a1)
    80001fbc:	0016c783          	lbu	a5,1(a3)
    80001fc0:	cbed                	beqz	a5,800020b2 <core_state_transition+0x1da>
    80001fc2:	02c00513          	li	a0,44
    80001fc6:	0ea78863          	beq	a5,a0,800020b6 <core_state_transition+0x1de>
    80001fca:	45d8                	lw	a4,12(a1)
    80001fcc:	fd57879b          	addiw	a5,a5,-43
    80001fd0:	0fd7f793          	andi	a5,a5,253
    80001fd4:	2705                	addiw	a4,a4,1
    80001fd6:	c5d8                	sw	a4,12(a1)
    80001fd8:	c791                	beqz	a5,80001fe4 <core_state_transition+0x10c>
    80001fda:	00268713          	addi	a4,a3,2
    80001fde:	4505                	li	a0,1
    80001fe0:	e218                	sd	a4,0(a2)
    80001fe2:	8082                	ret
    80001fe4:	0026c783          	lbu	a5,2(a3)
    80001fe8:	00268713          	addi	a4,a3,2
    80001fec:	c3e9                	beqz	a5,800020ae <core_state_transition+0x1d6>
    80001fee:	0ca78763          	beq	a5,a0,800020bc <core_state_transition+0x1e4>
    80001ff2:	4d88                	lw	a0,24(a1)
    80001ff4:	fd07879b          	addiw	a5,a5,-48
    80001ff8:	0ff7f793          	zext.b	a5,a5
    80001ffc:	2505                	addiw	a0,a0,1
    80001ffe:	4825                	li	a6,9
    80002000:	cd88                	sw	a0,24(a1)
    80002002:	00f87763          	bgeu	a6,a5,80002010 <core_state_transition+0x138>
    80002006:	00368713          	addi	a4,a3,3
    8000200a:	4505                	li	a0,1
    8000200c:	e218                	sd	a4,0(a2)
    8000200e:	8082                	ret
    80002010:	4525                	li	a0,9
    80002012:	00174683          	lbu	a3,1(a4)
    80002016:	883a                	mv	a6,a4
    80002018:	02c00893          	li	a7,44
    8000201c:	fd06879b          	addiw	a5,a3,-48
    80002020:	0705                	addi	a4,a4,1
    80002022:	0ff7f793          	zext.b	a5,a5
    80002026:	c2cd                	beqz	a3,800020c8 <core_state_transition+0x1f0>
    80002028:	09168d63          	beq	a3,a7,800020c2 <core_state_transition+0x1ea>
    8000202c:	fef573e3          	bgeu	a0,a5,80002012 <core_state_transition+0x13a>
    80002030:	41dc                	lw	a5,4(a1)
    80002032:	00280713          	addi	a4,a6,2
    80002036:	4505                	li	a0,1
    80002038:	2785                	addiw	a5,a5,1
    8000203a:	c1dc                	sw	a5,4(a1)
    8000203c:	bf15                	j	80001f70 <core_state_transition+0x98>
    8000203e:	499c                	lw	a5,16(a1)
    80002040:	2785                	addiw	a5,a5,1
    80002042:	c99c                	sw	a5,16(a1)
    80002044:	b785                	j	80001fa4 <core_state_transition+0xcc>
    80002046:	8736                	mv	a4,a3
    80002048:	4511                	li	a0,4
    8000204a:	0705                	addi	a4,a4,1
    8000204c:	b715                	j	80001f70 <core_state_transition+0x98>
    8000204e:	49dc                	lw	a5,20(a1)
    80002050:	00168713          	addi	a4,a3,1
    80002054:	4505                	li	a0,1
    80002056:	2785                	addiw	a5,a5,1
    80002058:	c9dc                	sw	a5,20(a1)
    8000205a:	bf19                	j	80001f70 <core_state_transition+0x98>
    8000205c:	4188                	lw	a0,0(a1)
    8000205e:	00170693          	addi	a3,a4,1
    80002062:	2505                	addiw	a0,a0,1
    80002064:	c188                	sw	a0,0(a1)
    80002066:	00174803          	lbu	a6,1(a4)
    8000206a:	06080963          	beqz	a6,800020dc <core_state_transition+0x204>
    8000206e:	06f80363          	beq	a6,a5,800020d4 <core_state_transition+0x1fc>
    80002072:	4598                	lw	a4,8(a1)
    80002074:	fd08079b          	addiw	a5,a6,-48
    80002078:	0ff7f793          	zext.b	a5,a5
    8000207c:	4525                	li	a0,9
    8000207e:	2705                	addiw	a4,a4,1
    80002080:	00f57b63          	bgeu	a0,a5,80002096 <core_state_transition+0x1be>
    80002084:	02e00793          	li	a5,46
    80002088:	00f80963          	beq	a6,a5,8000209a <core_state_transition+0x1c2>
    8000208c:	c598                	sw	a4,8(a1)
    8000208e:	4505                	li	a0,1
    80002090:	00168713          	addi	a4,a3,1
    80002094:	bdf1                	j	80001f70 <core_state_transition+0x98>
    80002096:	c598                	sw	a4,8(a1)
    80002098:	bd75                	j	80001f54 <core_state_transition+0x7c>
    8000209a:	c598                	sw	a4,8(a1)
    8000209c:	b721                	j	80001fa4 <core_state_transition+0xcc>
    8000209e:	8736                	mv	a4,a3
    800020a0:	4511                	li	a0,4
    800020a2:	b5f9                	j	80001f70 <core_state_transition+0x98>
    800020a4:	8736                	mv	a4,a3
    800020a6:	4515                	li	a0,5
    800020a8:	b5e1                	j	80001f70 <core_state_transition+0x98>
    800020aa:	4501                	li	a0,0
    800020ac:	b5d1                	j	80001f70 <core_state_transition+0x98>
    800020ae:	4519                	li	a0,6
    800020b0:	b5c1                	j	80001f70 <core_state_transition+0x98>
    800020b2:	450d                	li	a0,3
    800020b4:	bd75                	j	80001f70 <core_state_transition+0x98>
    800020b6:	450d                	li	a0,3
    800020b8:	0705                	addi	a4,a4,1
    800020ba:	bd5d                	j	80001f70 <core_state_transition+0x98>
    800020bc:	4519                	li	a0,6
    800020be:	0705                	addi	a4,a4,1
    800020c0:	bd45                	j	80001f70 <core_state_transition+0x98>
    800020c2:	451d                	li	a0,7
    800020c4:	0705                	addi	a4,a4,1
    800020c6:	b56d                	j	80001f70 <core_state_transition+0x98>
    800020c8:	451d                	li	a0,7
    800020ca:	b55d                	j	80001f70 <core_state_transition+0x98>
    800020cc:	8736                	mv	a4,a3
    800020ce:	4515                	li	a0,5
    800020d0:	0705                	addi	a4,a4,1
    800020d2:	bd79                	j	80001f70 <core_state_transition+0x98>
    800020d4:	8736                	mv	a4,a3
    800020d6:	4509                	li	a0,2
    800020d8:	0705                	addi	a4,a4,1
    800020da:	bd59                	j	80001f70 <core_state_transition+0x98>
    800020dc:	8736                	mv	a4,a3
    800020de:	4509                	li	a0,2
    800020e0:	bd41                	j	80001f70 <core_state_transition+0x98>

00000000800020e2 <core_bench_state>:
    800020e2:	7135                	addi	sp,sp,-160
    800020e4:	e526                	sd	s1,136(sp)
    800020e6:	fcce                	sd	s3,120(sp)
    800020e8:	0804                	addi	s1,sp,16
    800020ea:	03010993          	addi	s3,sp,48
    800020ee:	e922                	sd	s0,144(sp)
    800020f0:	e14a                	sd	s2,128(sp)
    800020f2:	f8d2                	sd	s4,112(sp)
    800020f4:	f0da                	sd	s6,96(sp)
    800020f6:	ecde                	sd	s7,88(sp)
    800020f8:	e8e2                	sd	s8,80(sp)
    800020fa:	8b36                	mv	s6,a3
    800020fc:	8a3a                	mv	s4,a4
    800020fe:	893e                	mv	s2,a5
    80002100:	ed06                	sd	ra,152(sp)
    80002102:	f4d6                	sd	s5,104(sp)
    80002104:	842e                	mv	s0,a1
    80002106:	8c2a                	mv	s8,a0
    80002108:	8bb2                	mv	s7,a2
    8000210a:	e42e                	sd	a1,8(sp)
    8000210c:	0894                	addi	a3,sp,80
    8000210e:	8726                	mv	a4,s1
    80002110:	87ce                	mv	a5,s3
    80002112:	0007a023          	sw	zero,0(a5)
    80002116:	00072023          	sw	zero,0(a4)
    8000211a:	0791                	addi	a5,a5,4
    8000211c:	0711                	addi	a4,a4,4
    8000211e:	fed79ae3          	bne	a5,a3,80002112 <core_bench_state+0x30>
    80002122:	00044783          	lbu	a5,0(s0)
    80002126:	00810a93          	addi	s5,sp,8
    8000212a:	c3ed                	beqz	a5,8000220c <core_bench_state+0x12a>
    8000212c:	180c                	addi	a1,sp,48
    8000212e:	8556                	mv	a0,s5
    80002130:	da9ff0ef          	jal	ra,80001ed8 <core_state_transition>
    80002134:	02051793          	slli	a5,a0,0x20
    80002138:	01e7d813          	srli	a6,a5,0x1e
    8000213c:	05080793          	addi	a5,a6,80
    80002140:	00278833          	add	a6,a5,sp
    80002144:	6722                	ld	a4,8(sp)
    80002146:	fc082783          	lw	a5,-64(a6)
    8000214a:	00074703          	lbu	a4,0(a4)
    8000214e:	2785                	addiw	a5,a5,1
    80002150:	fcf82023          	sw	a5,-64(a6)
    80002154:	ff61                	bnez	a4,8000212c <core_bench_state+0x4a>
    80002156:	1c02                	slli	s8,s8,0x20
    80002158:	020c5c13          	srli	s8,s8,0x20
    8000215c:	e422                	sd	s0,8(sp)
    8000215e:	9c22                	add	s8,s8,s0
    80002160:	03847563          	bgeu	s0,s8,8000218a <core_bench_state+0xa8>
    80002164:	87a2                	mv	a5,s0
    80002166:	02c00613          	li	a2,44
    8000216a:	0007c703          	lbu	a4,0(a5)
    8000216e:	017746b3          	xor	a3,a4,s7
    80002172:	00c70463          	beq	a4,a2,8000217a <core_bench_state+0x98>
    80002176:	00d78023          	sb	a3,0(a5)
    8000217a:	97d2                	add	a5,a5,s4
    8000217c:	ff87e7e3          	bltu	a5,s8,8000216a <core_bench_state+0x88>
    80002180:	00044783          	lbu	a5,0(s0)
    80002184:	00810a93          	addi	s5,sp,8
    80002188:	c795                	beqz	a5,800021b4 <core_bench_state+0xd2>
    8000218a:	180c                	addi	a1,sp,48
    8000218c:	8556                	mv	a0,s5
    8000218e:	d4bff0ef          	jal	ra,80001ed8 <core_state_transition>
    80002192:	02051793          	slli	a5,a0,0x20
    80002196:	01e7d613          	srli	a2,a5,0x1e
    8000219a:	05060793          	addi	a5,a2,80
    8000219e:	00278633          	add	a2,a5,sp
    800021a2:	6722                	ld	a4,8(sp)
    800021a4:	fc062783          	lw	a5,-64(a2)
    800021a8:	00074703          	lbu	a4,0(a4)
    800021ac:	2785                	addiw	a5,a5,1
    800021ae:	fcf62023          	sw	a5,-64(a2)
    800021b2:	ff61                	bnez	a4,8000218a <core_bench_state+0xa8>
    800021b4:	e422                	sd	s0,8(sp)
    800021b6:	02c00693          	li	a3,44
    800021ba:	01847d63          	bgeu	s0,s8,800021d4 <core_bench_state+0xf2>
    800021be:	00044783          	lbu	a5,0(s0)
    800021c2:	0167c733          	xor	a4,a5,s6
    800021c6:	00d78463          	beq	a5,a3,800021ce <core_bench_state+0xec>
    800021ca:	00e40023          	sb	a4,0(s0)
    800021ce:	9452                	add	s0,s0,s4
    800021d0:	ff8467e3          	bltu	s0,s8,800021be <core_bench_state+0xdc>
    800021d4:	02048413          	addi	s0,s1,32
    800021d8:	4088                	lw	a0,0(s1)
    800021da:	85ca                	mv	a1,s2
    800021dc:	0491                	addi	s1,s1,4
    800021de:	104000ef          	jal	ra,800022e2 <crcu32>
    800021e2:	85aa                	mv	a1,a0
    800021e4:	0009a503          	lw	a0,0(s3)
    800021e8:	0991                	addi	s3,s3,4
    800021ea:	0f8000ef          	jal	ra,800022e2 <crcu32>
    800021ee:	892a                	mv	s2,a0
    800021f0:	fe9414e3          	bne	s0,s1,800021d8 <core_bench_state+0xf6>
    800021f4:	60ea                	ld	ra,152(sp)
    800021f6:	644a                	ld	s0,144(sp)
    800021f8:	64aa                	ld	s1,136(sp)
    800021fa:	690a                	ld	s2,128(sp)
    800021fc:	79e6                	ld	s3,120(sp)
    800021fe:	7a46                	ld	s4,112(sp)
    80002200:	7aa6                	ld	s5,104(sp)
    80002202:	7b06                	ld	s6,96(sp)
    80002204:	6be6                	ld	s7,88(sp)
    80002206:	6c46                	ld	s8,80(sp)
    80002208:	610d                	addi	sp,sp,160
    8000220a:	8082                	ret
    8000220c:	1c02                	slli	s8,s8,0x20
    8000220e:	020c5c13          	srli	s8,s8,0x20
    80002212:	9c22                	add	s8,s8,s0
    80002214:	f58468e3          	bltu	s0,s8,80002164 <core_bench_state+0x82>
    80002218:	bf75                	j	800021d4 <core_bench_state+0xf2>

000000008000221a <get_seed_32>:
    8000221a:	4795                	li	a5,5
    8000221c:	04a7e263          	bltu	a5,a0,80002260 <get_seed_32+0x46>
    80002220:	00001717          	auipc	a4,0x1
    80002224:	7a870713          	addi	a4,a4,1960 # 800039c8 <errpat+0x20>
    80002228:	050a                	slli	a0,a0,0x2
    8000222a:	953a                	add	a0,a0,a4
    8000222c:	411c                	lw	a5,0(a0)
    8000222e:	97ba                	add	a5,a5,a4
    80002230:	8782                	jr	a5
    80002232:	00002517          	auipc	a0,0x2
    80002236:	a0e52503          	lw	a0,-1522(a0) # 80003c40 <seed5_volatile>
    8000223a:	8082                	ret
    8000223c:	00002517          	auipc	a0,0x2
    80002240:	a1052503          	lw	a0,-1520(a0) # 80003c4c <seed1_volatile>
    80002244:	8082                	ret
    80002246:	00002517          	auipc	a0,0x2
    8000224a:	a0252503          	lw	a0,-1534(a0) # 80003c48 <seed2_volatile>
    8000224e:	8082                	ret
    80002250:	80c1a503          	lw	a0,-2036(gp) # 80003c2c <seed3_volatile>
    80002254:	8082                	ret
    80002256:	00002517          	auipc	a0,0x2
    8000225a:	9ee52503          	lw	a0,-1554(a0) # 80003c44 <seed4_volatile>
    8000225e:	8082                	ret
    80002260:	4501                	li	a0,0
    80002262:	8082                	ret

0000000080002264 <crcu8>:
    80002264:	86aa                	mv	a3,a0
    80002266:	852e                	mv	a0,a1
    80002268:	75e9                	lui	a1,0xffffa
    8000226a:	47a1                	li	a5,8
    8000226c:	0585                	addi	a1,a1,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    8000226e:	00a6c733          	xor	a4,a3,a0
    80002272:	37fd                	addiw	a5,a5,-1
    80002274:	8105                	srli	a0,a0,0x1
    80002276:	8b05                	andi	a4,a4,1
    80002278:	0ff7f793          	zext.b	a5,a5
    8000227c:	00b54633          	xor	a2,a0,a1
    80002280:	8285                	srli	a3,a3,0x1
    80002282:	c701                	beqz	a4,8000228a <crcu8+0x26>
    80002284:	03061513          	slli	a0,a2,0x30
    80002288:	9141                	srli	a0,a0,0x30
    8000228a:	f3f5                	bnez	a5,8000226e <crcu8+0xa>
    8000228c:	8082                	ret

000000008000228e <crcu16>:
    8000228e:	86aa                	mv	a3,a0
    80002290:	7869                	lui	a6,0xffffa
    80002292:	852e                	mv	a0,a1
    80002294:	0ff6f613          	zext.b	a2,a3
    80002298:	47a1                	li	a5,8
    8000229a:	0805                	addi	a6,a6,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    8000229c:	00a64733          	xor	a4,a2,a0
    800022a0:	37fd                	addiw	a5,a5,-1
    800022a2:	8105                	srli	a0,a0,0x1
    800022a4:	8b05                	andi	a4,a4,1
    800022a6:	0ff7f793          	zext.b	a5,a5
    800022aa:	010545b3          	xor	a1,a0,a6
    800022ae:	8205                	srli	a2,a2,0x1
    800022b0:	c701                	beqz	a4,800022b8 <crcu16+0x2a>
    800022b2:	03059513          	slli	a0,a1,0x30
    800022b6:	9141                	srli	a0,a0,0x30
    800022b8:	f3f5                	bnez	a5,8000229c <crcu16+0xe>
    800022ba:	75e9                	lui	a1,0xffffa
    800022bc:	82a1                	srli	a3,a3,0x8
    800022be:	47a1                	li	a5,8
    800022c0:	0585                	addi	a1,a1,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    800022c2:	00a6c733          	xor	a4,a3,a0
    800022c6:	37fd                	addiw	a5,a5,-1
    800022c8:	8105                	srli	a0,a0,0x1
    800022ca:	8b05                	andi	a4,a4,1
    800022cc:	0ff7f793          	zext.b	a5,a5
    800022d0:	00b54633          	xor	a2,a0,a1
    800022d4:	8285                	srli	a3,a3,0x1
    800022d6:	c701                	beqz	a4,800022de <crcu16+0x50>
    800022d8:	03061513          	slli	a0,a2,0x30
    800022dc:	9141                	srli	a0,a0,0x30
    800022de:	f3f5                	bnez	a5,800022c2 <crcu16+0x34>
    800022e0:	8082                	ret

00000000800022e2 <crcu32>:
    800022e2:	872a                	mv	a4,a0
    800022e4:	03071613          	slli	a2,a4,0x30
    800022e8:	78e9                	lui	a7,0xffffa
    800022ea:	852e                	mv	a0,a1
    800022ec:	9241                	srli	a2,a2,0x30
    800022ee:	0ff77593          	zext.b	a1,a4
    800022f2:	47a1                	li	a5,8
    800022f4:	0885                	addi	a7,a7,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    800022f6:	00a5c6b3          	xor	a3,a1,a0
    800022fa:	37fd                	addiw	a5,a5,-1
    800022fc:	8105                	srli	a0,a0,0x1
    800022fe:	8a85                	andi	a3,a3,1
    80002300:	0ff7f793          	zext.b	a5,a5
    80002304:	01154833          	xor	a6,a0,a7
    80002308:	8185                	srli	a1,a1,0x1
    8000230a:	c681                	beqz	a3,80002312 <crcu32+0x30>
    8000230c:	03081513          	slli	a0,a6,0x30
    80002310:	9141                	srli	a0,a0,0x30
    80002312:	f3f5                	bnez	a5,800022f6 <crcu32+0x14>
    80002314:	7869                	lui	a6,0xffffa
    80002316:	8221                	srli	a2,a2,0x8
    80002318:	47a1                	li	a5,8
    8000231a:	0805                	addi	a6,a6,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    8000231c:	00a646b3          	xor	a3,a2,a0
    80002320:	37fd                	addiw	a5,a5,-1
    80002322:	8105                	srli	a0,a0,0x1
    80002324:	8a85                	andi	a3,a3,1
    80002326:	0ff7f793          	zext.b	a5,a5
    8000232a:	010545b3          	xor	a1,a0,a6
    8000232e:	8205                	srli	a2,a2,0x1
    80002330:	c681                	beqz	a3,80002338 <crcu32+0x56>
    80002332:	03059513          	slli	a0,a1,0x30
    80002336:	9141                	srli	a0,a0,0x30
    80002338:	f3f5                	bnez	a5,8000231c <crcu32+0x3a>
    8000233a:	0107561b          	srliw	a2,a4,0x10
    8000233e:	7869                	lui	a6,0xffffa
    80002340:	8732                	mv	a4,a2
    80002342:	47a1                	li	a5,8
    80002344:	0ff67613          	zext.b	a2,a2
    80002348:	0805                	addi	a6,a6,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    8000234a:	00a646b3          	xor	a3,a2,a0
    8000234e:	37fd                	addiw	a5,a5,-1
    80002350:	8105                	srli	a0,a0,0x1
    80002352:	8a85                	andi	a3,a3,1
    80002354:	0ff7f793          	zext.b	a5,a5
    80002358:	010545b3          	xor	a1,a0,a6
    8000235c:	8205                	srli	a2,a2,0x1
    8000235e:	c681                	beqz	a3,80002366 <crcu32+0x84>
    80002360:	03059513          	slli	a0,a1,0x30
    80002364:	9141                	srli	a0,a0,0x30
    80002366:	f3f5                	bnez	a5,8000234a <crcu32+0x68>
    80002368:	75e9                	lui	a1,0xffffa
    8000236a:	8321                	srli	a4,a4,0x8
    8000236c:	47a1                	li	a5,8
    8000236e:	0585                	addi	a1,a1,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    80002370:	00a746b3          	xor	a3,a4,a0
    80002374:	37fd                	addiw	a5,a5,-1
    80002376:	8105                	srli	a0,a0,0x1
    80002378:	8a85                	andi	a3,a3,1
    8000237a:	0ff7f793          	zext.b	a5,a5
    8000237e:	00b54633          	xor	a2,a0,a1
    80002382:	8305                	srli	a4,a4,0x1
    80002384:	c681                	beqz	a3,8000238c <crcu32+0xaa>
    80002386:	03061513          	slli	a0,a2,0x30
    8000238a:	9141                	srli	a0,a0,0x30
    8000238c:	f3f5                	bnez	a5,80002370 <crcu32+0x8e>
    8000238e:	8082                	ret

0000000080002390 <crc16>:
    80002390:	86aa                	mv	a3,a0
    80002392:	03069613          	slli	a2,a3,0x30
    80002396:	7869                	lui	a6,0xffffa
    80002398:	852e                	mv	a0,a1
    8000239a:	9241                	srli	a2,a2,0x30
    8000239c:	0ff6f693          	zext.b	a3,a3
    800023a0:	47a1                	li	a5,8
    800023a2:	0805                	addi	a6,a6,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    800023a4:	00a6c733          	xor	a4,a3,a0
    800023a8:	37fd                	addiw	a5,a5,-1
    800023aa:	8105                	srli	a0,a0,0x1
    800023ac:	8b05                	andi	a4,a4,1
    800023ae:	0ff7f793          	zext.b	a5,a5
    800023b2:	010545b3          	xor	a1,a0,a6
    800023b6:	8285                	srli	a3,a3,0x1
    800023b8:	c701                	beqz	a4,800023c0 <crc16+0x30>
    800023ba:	03059513          	slli	a0,a1,0x30
    800023be:	9141                	srli	a0,a0,0x30
    800023c0:	f3f5                	bnez	a5,800023a4 <crc16+0x14>
    800023c2:	75e9                	lui	a1,0xffffa
    800023c4:	00865693          	srli	a3,a2,0x8
    800023c8:	47a1                	li	a5,8
    800023ca:	0585                	addi	a1,a1,1 # ffffffffffffa001 <__global_pointer$+0xffffffff7fff5be1>
    800023cc:	00a6c733          	xor	a4,a3,a0
    800023d0:	37fd                	addiw	a5,a5,-1
    800023d2:	8105                	srli	a0,a0,0x1
    800023d4:	8b05                	andi	a4,a4,1
    800023d6:	0ff7f793          	zext.b	a5,a5
    800023da:	00b54633          	xor	a2,a0,a1
    800023de:	8285                	srli	a3,a3,0x1
    800023e0:	c701                	beqz	a4,800023e8 <crc16+0x58>
    800023e2:	03061513          	slli	a0,a2,0x30
    800023e6:	9141                	srli	a0,a0,0x30
    800023e8:	f3f5                	bnez	a5,800023cc <crc16+0x3c>
    800023ea:	8082                	ret

00000000800023ec <check_data_types>:
    800023ec:	4501                	li	a0,0
    800023ee:	8082                	ret

00000000800023f0 <portable_malloc>:
    800023f0:	4501                	li	a0,0
    800023f2:	8082                	ret

00000000800023f4 <portable_free>:
    800023f4:	8082                	ret

00000000800023f6 <start_time>:
    800023f6:	c00027f3          	rdcycle	a5
    800023fa:	00002717          	auipc	a4,0x2
    800023fe:	82f73f23          	sd	a5,-1986(a4) # 80003c38 <start_time_val>
    80002402:	8082                	ret

0000000080002404 <stop_time>:
    80002404:	c00027f3          	rdcycle	a5
    80002408:	00002717          	auipc	a4,0x2
    8000240c:	82f73423          	sd	a5,-2008(a4) # 80003c30 <stop_time_val>
    80002410:	8082                	ret

0000000080002412 <get_time>:
    80002412:	00002517          	auipc	a0,0x2
    80002416:	81e53503          	ld	a0,-2018(a0) # 80003c30 <stop_time_val>
    8000241a:	00002797          	auipc	a5,0x2
    8000241e:	81e7b783          	ld	a5,-2018(a5) # 80003c38 <start_time_val>
    80002422:	8d1d                	sub	a0,a0,a5
    80002424:	8082                	ret

0000000080002426 <time_in_secs>:
    80002426:	6789                	lui	a5,0x2
    80002428:	7107879b          	addiw	a5,a5,1808 # 2710 <_tbss_end+0x2710>
    8000242c:	02f5553b          	divuw	a0,a0,a5
    80002430:	8082                	ret

0000000080002432 <portable_init>:
    80002432:	4785                	li	a5,1
    80002434:	00f50023          	sb	a5,0(a0)
    80002438:	8082                	ret

000000008000243a <portable_fini>:
    8000243a:	00050023          	sb	zero,0(a0)
    8000243e:	8082                	ret

0000000080002440 <putchar>:
    80002440:	0ff57693          	zext.b	a3,a0
    80002444:	64000737          	lui	a4,0x64000
    80002448:	40d727af          	amoor.w	a5,a3,(a4)
    8000244c:	2781                	sext.w	a5,a5
    8000244e:	fe07cde3          	bltz	a5,80002448 <putchar+0x8>
    80002452:	8082                	ret

0000000080002454 <sprintf_putch>:
    80002454:	619c                	ld	a5,0(a1)
    80002456:	00a78023          	sb	a0,0(a5)
    8000245a:	619c                	ld	a5,0(a1)
    8000245c:	0785                	addi	a5,a5,1
    8000245e:	e19c                	sd	a5,0(a1)
    80002460:	8082                	ret

0000000080002462 <vprintfmt>:
    80002462:	7149                	addi	sp,sp,-368
    80002464:	f2a2                	sd	s0,352(sp)
    80002466:	eea6                	sd	s1,344(sp)
    80002468:	eaca                	sd	s2,336(sp)
    8000246a:	e2d2                	sd	s4,320(sp)
    8000246c:	fe56                	sd	s5,312(sp)
    8000246e:	fa5a                	sd	s6,304(sp)
    80002470:	f65e                	sd	s7,296(sp)
    80002472:	f686                	sd	ra,360(sp)
    80002474:	e6ce                	sd	s3,328(sp)
    80002476:	f262                	sd	s8,288(sp)
    80002478:	ee66                	sd	s9,280(sp)
    8000247a:	ea6a                	sd	s10,272(sp)
    8000247c:	e66e                	sd	s11,264(sp)
    8000247e:	892a                	mv	s2,a0
    80002480:	84ae                	mv	s1,a1
    80002482:	8432                	mv	s0,a2
    80002484:	8ab6                	mv	s5,a3
    80002486:	02500a13          	li	s4,37
    8000248a:	05500b93          	li	s7,85
    8000248e:	00001b17          	auipc	s6,0x1
    80002492:	552b0b13          	addi	s6,s6,1362 # 800039e0 <errpat+0x38>
    80002496:	a029                	j	800024a0 <vprintfmt+0x3e>
    80002498:	cd1d                	beqz	a0,800024d6 <vprintfmt+0x74>
    8000249a:	85a6                	mv	a1,s1
    8000249c:	0405                	addi	s0,s0,1
    8000249e:	9902                	jalr	s2
    800024a0:	00044503          	lbu	a0,0(s0)
    800024a4:	ff451ae3          	bne	a0,s4,80002498 <vprintfmt+0x36>
    800024a8:	00144683          	lbu	a3,1(s0)
    800024ac:	00140993          	addi	s3,s0,1
    800024b0:	874e                	mv	a4,s3
    800024b2:	02000c93          	li	s9,32
    800024b6:	5c7d                	li	s8,-1
    800024b8:	5dfd                	li	s11,-1
    800024ba:	4601                	li	a2,0
    800024bc:	fdd6879b          	addiw	a5,a3,-35
    800024c0:	0ff7f793          	zext.b	a5,a5
    800024c4:	00170413          	addi	s0,a4,1 # 64000001 <_tbss_end+0x64000001>
    800024c8:	04fbe263          	bltu	s7,a5,8000250c <vprintfmt+0xaa>
    800024cc:	078a                	slli	a5,a5,0x2
    800024ce:	97da                	add	a5,a5,s6
    800024d0:	439c                	lw	a5,0(a5)
    800024d2:	97da                	add	a5,a5,s6
    800024d4:	8782                	jr	a5
    800024d6:	70b6                	ld	ra,360(sp)
    800024d8:	7416                	ld	s0,352(sp)
    800024da:	64f6                	ld	s1,344(sp)
    800024dc:	6956                	ld	s2,336(sp)
    800024de:	69b6                	ld	s3,328(sp)
    800024e0:	6a16                	ld	s4,320(sp)
    800024e2:	7af2                	ld	s5,312(sp)
    800024e4:	7b52                	ld	s6,304(sp)
    800024e6:	7bb2                	ld	s7,296(sp)
    800024e8:	7c12                	ld	s8,288(sp)
    800024ea:	6cf2                	ld	s9,280(sp)
    800024ec:	6d52                	ld	s10,272(sp)
    800024ee:	6db2                	ld	s11,264(sp)
    800024f0:	6175                	addi	sp,sp,368
    800024f2:	8082                	ret
    800024f4:	8cb6                	mv	s9,a3
    800024f6:	00174683          	lbu	a3,1(a4)
    800024fa:	8722                	mv	a4,s0
    800024fc:	00170413          	addi	s0,a4,1
    80002500:	fdd6879b          	addiw	a5,a3,-35
    80002504:	0ff7f793          	zext.b	a5,a5
    80002508:	fcfbf2e3          	bgeu	s7,a5,800024cc <vprintfmt+0x6a>
    8000250c:	85a6                	mv	a1,s1
    8000250e:	02500513          	li	a0,37
    80002512:	9902                	jalr	s2
    80002514:	844e                	mv	s0,s3
    80002516:	b769                	j	800024a0 <vprintfmt+0x3e>
    80002518:	fd068c1b          	addiw	s8,a3,-48
    8000251c:	00174683          	lbu	a3,1(a4)
    80002520:	47a5                	li	a5,9
    80002522:	fd06871b          	addiw	a4,a3,-48
    80002526:	0006859b          	sext.w	a1,a3
    8000252a:	20e7e863          	bltu	a5,a4,8000273a <vprintfmt+0x2d8>
    8000252e:	8722                	mv	a4,s0
    80002530:	4825                	li	a6,9
    80002532:	00174683          	lbu	a3,1(a4)
    80002536:	002c179b          	slliw	a5,s8,0x2
    8000253a:	018787bb          	addw	a5,a5,s8
    8000253e:	0017979b          	slliw	a5,a5,0x1
    80002542:	9fad                	addw	a5,a5,a1
    80002544:	fd06851b          	addiw	a0,a3,-48
    80002548:	0705                	addi	a4,a4,1
    8000254a:	fd078c1b          	addiw	s8,a5,-48
    8000254e:	0006859b          	sext.w	a1,a3
    80002552:	fea870e3          	bgeu	a6,a0,80002532 <vprintfmt+0xd0>
    80002556:	f60dd3e3          	bgez	s11,800024bc <vprintfmt+0x5a>
    8000255a:	8de2                	mv	s11,s8
    8000255c:	5c7d                	li	s8,-1
    8000255e:	bfb9                	j	800024bc <vprintfmt+0x5a>
    80002560:	46c1                	li	a3,16
    80002562:	4785                	li	a5,1
    80002564:	008a8713          	addi	a4,s5,8
    80002568:	1ac7c363          	blt	a5,a2,8000270e <vprintfmt+0x2ac>
    8000256c:	1a061163          	bnez	a2,8000270e <vprintfmt+0x2ac>
    80002570:	000ae783          	lwu	a5,0(s5)
    80002574:	8aba                	mv	s5,a4
    80002576:	02d7f5b3          	remu	a1,a5,a3
    8000257a:	000c899b          	sext.w	s3,s9
    8000257e:	0050                	addi	a2,sp,4
    80002580:	4705                	li	a4,1
    80002582:	c02e                	sw	a1,0(sp)
    80002584:	18d7e963          	bltu	a5,a3,80002716 <vprintfmt+0x2b4>
    80002588:	02d7d7b3          	divu	a5,a5,a3
    8000258c:	0611                	addi	a2,a2,4
    8000258e:	8c3a                	mv	s8,a4
    80002590:	2705                	addiw	a4,a4,1
    80002592:	02d7f5b3          	remu	a1,a5,a3
    80002596:	feb62e23          	sw	a1,-4(a2)
    8000259a:	fed7f7e3          	bgeu	a5,a3,80002588 <vprintfmt+0x126>
    8000259e:	fffd8c9b          	addiw	s9,s11,-1
    800025a2:	fff70d1b          	addiw	s10,a4,-1
    800025a6:	01b75863          	bge	a4,s11,800025b6 <vprintfmt+0x154>
    800025aa:	3cfd                	addiw	s9,s9,-1
    800025ac:	85a6                	mv	a1,s1
    800025ae:	854e                	mv	a0,s3
    800025b0:	9902                	jalr	s2
    800025b2:	ffac9ce3          	bne	s9,s10,800025aa <vprintfmt+0x148>
    800025b6:	0c0a                	slli	s8,s8,0x2
    800025b8:	018109b3          	add	s3,sp,s8
    800025bc:	ffc10c93          	addi	s9,sp,-4
    800025c0:	4c25                	li	s8,9
    800025c2:	0009a783          	lw	a5,0(s3)
    800025c6:	05700513          	li	a0,87
    800025ca:	00fc6463          	bltu	s8,a5,800025d2 <vprintfmt+0x170>
    800025ce:	03000513          	li	a0,48
    800025d2:	19f1                	addi	s3,s3,-4
    800025d4:	85a6                	mv	a1,s1
    800025d6:	9d3d                	addw	a0,a0,a5
    800025d8:	9902                	jalr	s2
    800025da:	ff3c94e3          	bne	s9,s3,800025c2 <vprintfmt+0x160>
    800025de:	b5c9                	j	800024a0 <vprintfmt+0x3e>
    800025e0:	000abd03          	ld	s10,0(s5)
    800025e4:	0aa1                	addi	s5,s5,8
    800025e6:	040d0263          	beqz	s10,8000262a <vprintfmt+0x1c8>
    800025ea:	09b05d63          	blez	s11,80002684 <vprintfmt+0x222>
    800025ee:	02d00793          	li	a5,45
    800025f2:	04fc9e63          	bne	s9,a5,8000264e <vprintfmt+0x1ec>
    800025f6:	000d4503          	lbu	a0,0(s10)
    800025fa:	c105                	beqz	a0,8000261a <vprintfmt+0x1b8>
    800025fc:	59fd                	li	s3,-1
    800025fe:	000c4563          	bltz	s8,80002608 <vprintfmt+0x1a6>
    80002602:	3c7d                	addiw	s8,s8,-1
    80002604:	013c0963          	beq	s8,s3,80002616 <vprintfmt+0x1b4>
    80002608:	85a6                	mv	a1,s1
    8000260a:	0d05                	addi	s10,s10,1
    8000260c:	9902                	jalr	s2
    8000260e:	000d4503          	lbu	a0,0(s10)
    80002612:	3dfd                	addiw	s11,s11,-1
    80002614:	f56d                	bnez	a0,800025fe <vprintfmt+0x19c>
    80002616:	e9b055e3          	blez	s11,800024a0 <vprintfmt+0x3e>
    8000261a:	3dfd                	addiw	s11,s11,-1
    8000261c:	85a6                	mv	a1,s1
    8000261e:	02000513          	li	a0,32
    80002622:	9902                	jalr	s2
    80002624:	fe0d9be3          	bnez	s11,8000261a <vprintfmt+0x1b8>
    80002628:	bda5                	j	800024a0 <vprintfmt+0x3e>
    8000262a:	00001d17          	auipc	s10,0x1
    8000262e:	22ed0d13          	addi	s10,s10,558 # 80003858 <main+0xcf6>
    80002632:	02800513          	li	a0,40
    80002636:	fdb053e3          	blez	s11,800025fc <vprintfmt+0x19a>
    8000263a:	02d00793          	li	a5,45
    8000263e:	00001d17          	auipc	s10,0x1
    80002642:	21ad0d13          	addi	s10,s10,538 # 80003858 <main+0xcf6>
    80002646:	02800513          	li	a0,40
    8000264a:	fafc89e3          	beq	s9,a5,800025fc <vprintfmt+0x19a>
    8000264e:	000d861b          	sext.w	a2,s11
    80002652:	87ea                	mv	a5,s10
    80002654:	018d06b3          	add	a3,s10,s8
    80002658:	000c1663          	bnez	s8,80002664 <vprintfmt+0x202>
    8000265c:	a829                	j	80002676 <vprintfmt+0x214>
    8000265e:	0785                	addi	a5,a5,1
    80002660:	00d78563          	beq	a5,a3,8000266a <vprintfmt+0x208>
    80002664:	0007c703          	lbu	a4,0(a5)
    80002668:	fb7d                	bnez	a4,8000265e <vprintfmt+0x1fc>
    8000266a:	41a787b3          	sub	a5,a5,s10
    8000266e:	40f60dbb          	subw	s11,a2,a5
    80002672:	01b05963          	blez	s11,80002684 <vprintfmt+0x222>
    80002676:	2c81                	sext.w	s9,s9
    80002678:	3dfd                	addiw	s11,s11,-1
    8000267a:	85a6                	mv	a1,s1
    8000267c:	8566                	mv	a0,s9
    8000267e:	9902                	jalr	s2
    80002680:	fe0d9ce3          	bnez	s11,80002678 <vprintfmt+0x216>
    80002684:	000d4503          	lbu	a0,0(s10)
    80002688:	e0050ce3          	beqz	a0,800024a0 <vprintfmt+0x3e>
    8000268c:	59fd                	li	s3,-1
    8000268e:	bf85                	j	800025fe <vprintfmt+0x19c>
    80002690:	fffdc793          	not	a5,s11
    80002694:	97fd                	srai	a5,a5,0x3f
    80002696:	00fdf7b3          	and	a5,s11,a5
    8000269a:	00174683          	lbu	a3,1(a4)
    8000269e:	00078d9b          	sext.w	s11,a5
    800026a2:	8722                	mv	a4,s0
    800026a4:	bd21                	j	800024bc <vprintfmt+0x5a>
    800026a6:	00174683          	lbu	a3,1(a4)
    800026aa:	8722                	mv	a4,s0
    800026ac:	bd01                	j	800024bc <vprintfmt+0x5a>
    800026ae:	85a6                	mv	a1,s1
    800026b0:	02500513          	li	a0,37
    800026b4:	9902                	jalr	s2
    800026b6:	b3ed                	j	800024a0 <vprintfmt+0x3e>
    800026b8:	000aac03          	lw	s8,0(s5)
    800026bc:	00174683          	lbu	a3,1(a4)
    800026c0:	0aa1                	addi	s5,s5,8
    800026c2:	8722                	mv	a4,s0
    800026c4:	bd49                	j	80002556 <vprintfmt+0xf4>
    800026c6:	000aa503          	lw	a0,0(s5)
    800026ca:	85a6                	mv	a1,s1
    800026cc:	0aa1                	addi	s5,s5,8
    800026ce:	9902                	jalr	s2
    800026d0:	bbc1                	j	800024a0 <vprintfmt+0x3e>
    800026d2:	4785                	li	a5,1
    800026d4:	008a8c13          	addi	s8,s5,8
    800026d8:	00c7c363          	blt	a5,a2,800026de <vprintfmt+0x27c>
    800026dc:	ce1d                	beqz	a2,8000271a <vprintfmt+0x2b8>
    800026de:	000ab983          	ld	s3,0(s5)
    800026e2:	0409c363          	bltz	s3,80002728 <vprintfmt+0x2c6>
    800026e6:	87ce                	mv	a5,s3
    800026e8:	8ae2                	mv	s5,s8
    800026ea:	46a9                	li	a3,10
    800026ec:	b569                	j	80002576 <vprintfmt+0x114>
    800026ee:	00174683          	lbu	a3,1(a4)
    800026f2:	2605                	addiw	a2,a2,1
    800026f4:	8722                	mv	a4,s0
    800026f6:	b3d9                	j	800024bc <vprintfmt+0x5a>
    800026f8:	03000513          	li	a0,48
    800026fc:	85a6                	mv	a1,s1
    800026fe:	9902                	jalr	s2
    80002700:	85a6                	mv	a1,s1
    80002702:	07800513          	li	a0,120
    80002706:	9902                	jalr	s2
    80002708:	46c1                	li	a3,16
    8000270a:	008a8713          	addi	a4,s5,8
    8000270e:	000ab783          	ld	a5,0(s5)
    80002712:	8aba                	mv	s5,a4
    80002714:	b58d                	j	80002576 <vprintfmt+0x114>
    80002716:	4c01                	li	s8,0
    80002718:	b559                	j	8000259e <vprintfmt+0x13c>
    8000271a:	000aa983          	lw	s3,0(s5)
    8000271e:	b7d1                	j	800026e2 <vprintfmt+0x280>
    80002720:	46a9                	li	a3,10
    80002722:	b581                	j	80002562 <vprintfmt+0x100>
    80002724:	46a1                	li	a3,8
    80002726:	bd35                	j	80002562 <vprintfmt+0x100>
    80002728:	85a6                	mv	a1,s1
    8000272a:	02d00513          	li	a0,45
    8000272e:	9902                	jalr	s2
    80002730:	8ae2                	mv	s5,s8
    80002732:	413007b3          	neg	a5,s3
    80002736:	46a9                	li	a3,10
    80002738:	bd3d                	j	80002576 <vprintfmt+0x114>
    8000273a:	8722                	mv	a4,s0
    8000273c:	bd29                	j	80002556 <vprintfmt+0xf4>

000000008000273e <setStats>:
    8000273e:	8082                	ret

0000000080002740 <tohost_exit>:
    80002740:	1141                	addi	sp,sp,-16
    80002742:	e406                	sd	ra,8(sp)
    80002744:	ed01                	bnez	a0,8000275c <tohost_exit+0x1c>
    80002746:	00001517          	auipc	a0,0x1
    8000274a:	11a50513          	addi	a0,a0,282 # 80003860 <main+0xcfe>
    8000274e:	2bc000ef          	jal	ra,80002a0a <kputs>
    80002752:	10500073          	wfi
    80002756:	10500073          	wfi
    8000275a:	bfe5                	j	80002752 <tohost_exit+0x12>
    8000275c:	85aa                	mv	a1,a0
    8000275e:	2581                	sext.w	a1,a1
    80002760:	00001517          	auipc	a0,0x1
    80002764:	13050513          	addi	a0,a0,304 # 80003890 <main+0xd2e>
    80002768:	2e0000ef          	jal	ra,80002a48 <kprintf>
    8000276c:	00001517          	auipc	a0,0x1
    80002770:	09450513          	addi	a0,a0,148 # 80003800 <main+0xc9e>
    80002774:	296000ef          	jal	ra,80002a0a <kputs>
    80002778:	10500073          	wfi
    8000277c:	bfe9                	j	80002756 <tohost_exit+0x16>

000000008000277e <handle_trap>:
    8000277e:	1141                	addi	sp,sp,-16
    80002780:	53900513          	li	a0,1337
    80002784:	e406                	sd	ra,8(sp)
    80002786:	fbbff0ef          	jal	ra,80002740 <tohost_exit>

000000008000278a <exit>:
    8000278a:	1141                	addi	sp,sp,-16
    8000278c:	e406                	sd	ra,8(sp)
    8000278e:	fb3ff0ef          	jal	ra,80002740 <tohost_exit>

0000000080002792 <abort>:
    80002792:	1141                	addi	sp,sp,-16
    80002794:	08600513          	li	a0,134
    80002798:	e406                	sd	ra,8(sp)
    8000279a:	fa7ff0ef          	jal	ra,80002740 <tohost_exit>

000000008000279e <printstr>:
    8000279e:	a4b5                	j	80002a0a <kputs>

00000000800027a0 <thread_entry>:
    800027a0:	e101                	bnez	a0,800027a0 <thread_entry>
    800027a2:	8082                	ret

00000000800027a4 <printhex>:
    800027a4:	85aa                	mv	a1,a0
    800027a6:	00001517          	auipc	a0,0x1
    800027aa:	13250513          	addi	a0,a0,306 # 800038d8 <main+0xd76>
    800027ae:	ac69                	j	80002a48 <kprintf>

00000000800027b0 <printf>:
    800027b0:	711d                	addi	sp,sp,-96
    800027b2:	02810313          	addi	t1,sp,40
    800027b6:	8e2a                	mv	t3,a0
    800027b8:	f42e                	sd	a1,40(sp)
    800027ba:	f832                	sd	a2,48(sp)
    800027bc:	fc36                	sd	a3,56(sp)
    800027be:	00000517          	auipc	a0,0x0
    800027c2:	c8250513          	addi	a0,a0,-894 # 80002440 <putchar>
    800027c6:	869a                	mv	a3,t1
    800027c8:	8672                	mv	a2,t3
    800027ca:	4581                	li	a1,0
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e0ba                	sd	a4,64(sp)
    800027d0:	e4be                	sd	a5,72(sp)
    800027d2:	e8c2                	sd	a6,80(sp)
    800027d4:	ecc6                	sd	a7,88(sp)
    800027d6:	e41a                	sd	t1,8(sp)
    800027d8:	c8bff0ef          	jal	ra,80002462 <vprintfmt>
    800027dc:	60e2                	ld	ra,24(sp)
    800027de:	4501                	li	a0,0
    800027e0:	6125                	addi	sp,sp,96
    800027e2:	8082                	ret

00000000800027e4 <puts>:
    800027e4:	1141                	addi	sp,sp,-16
    800027e6:	e406                	sd	ra,8(sp)
    800027e8:	222000ef          	jal	ra,80002a0a <kputs>
    800027ec:	60a2                	ld	ra,8(sp)
    800027ee:	4501                	li	a0,0
    800027f0:	0141                	addi	sp,sp,16
    800027f2:	8082                	ret

00000000800027f4 <sprintf>:
    800027f4:	711d                	addi	sp,sp,-96
    800027f6:	03010313          	addi	t1,sp,48
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	e42a                	sd	a0,8(sp)
    800027fe:	f832                	sd	a2,48(sp)
    80002800:	fc36                	sd	a3,56(sp)
    80002802:	842a                	mv	s0,a0
    80002804:	862e                	mv	a2,a1
    80002806:	00000517          	auipc	a0,0x0
    8000280a:	c4e50513          	addi	a0,a0,-946 # 80002454 <sprintf_putch>
    8000280e:	002c                	addi	a1,sp,8
    80002810:	869a                	mv	a3,t1
    80002812:	f406                	sd	ra,40(sp)
    80002814:	e4be                	sd	a5,72(sp)
    80002816:	e0ba                	sd	a4,64(sp)
    80002818:	e8c2                	sd	a6,80(sp)
    8000281a:	ecc6                	sd	a7,88(sp)
    8000281c:	ec1a                	sd	t1,24(sp)
    8000281e:	c45ff0ef          	jal	ra,80002462 <vprintfmt>
    80002822:	67a2                	ld	a5,8(sp)
    80002824:	00078023          	sb	zero,0(a5)
    80002828:	6522                	ld	a0,8(sp)
    8000282a:	70a2                	ld	ra,40(sp)
    8000282c:	9d01                	subw	a0,a0,s0
    8000282e:	7402                	ld	s0,32(sp)
    80002830:	6125                	addi	sp,sp,96
    80002832:	8082                	ret

0000000080002834 <memcpy>:
    80002834:	00b567b3          	or	a5,a0,a1
    80002838:	8fd1                	or	a5,a5,a2
    8000283a:	8b9d                	andi	a5,a5,7
    8000283c:	00c506b3          	add	a3,a0,a2
    80002840:	cf91                	beqz	a5,8000285c <memcpy+0x28>
    80002842:	962e                	add	a2,a2,a1
    80002844:	87aa                	mv	a5,a0
    80002846:	02d57663          	bgeu	a0,a3,80002872 <memcpy+0x3e>
    8000284a:	0005c703          	lbu	a4,0(a1)
    8000284e:	0585                	addi	a1,a1,1
    80002850:	0785                	addi	a5,a5,1
    80002852:	fee78fa3          	sb	a4,-1(a5)
    80002856:	feb61ae3          	bne	a2,a1,8000284a <memcpy+0x16>
    8000285a:	8082                	ret
    8000285c:	fed57fe3          	bgeu	a0,a3,8000285a <memcpy+0x26>
    80002860:	87aa                	mv	a5,a0
    80002862:	6198                	ld	a4,0(a1)
    80002864:	07a1                	addi	a5,a5,8
    80002866:	05a1                	addi	a1,a1,8
    80002868:	fee7bc23          	sd	a4,-8(a5)
    8000286c:	fed7ebe3          	bltu	a5,a3,80002862 <memcpy+0x2e>
    80002870:	8082                	ret
    80002872:	8082                	ret

0000000080002874 <memset>:
    80002874:	00c567b3          	or	a5,a0,a2
    80002878:	8b9d                	andi	a5,a5,7
    8000287a:	962a                	add	a2,a2,a0
    8000287c:	0ff5f713          	zext.b	a4,a1
    80002880:	cb91                	beqz	a5,80002894 <memset+0x20>
    80002882:	87aa                	mv	a5,a0
    80002884:	02c57763          	bgeu	a0,a2,800028b2 <memset+0x3e>
    80002888:	0785                	addi	a5,a5,1
    8000288a:	fee78fa3          	sb	a4,-1(a5)
    8000288e:	fec79de3          	bne	a5,a2,80002888 <memset+0x14>
    80002892:	8082                	ret
    80002894:	00001797          	auipc	a5,0x1
    80002898:	38c7b783          	ld	a5,908(a5) # 80003c20 <.got.plt+0x10>
    8000289c:	02f70733          	mul	a4,a4,a5
    800028a0:	fec579e3          	bgeu	a0,a2,80002892 <memset+0x1e>
    800028a4:	87aa                	mv	a5,a0
    800028a6:	07a1                	addi	a5,a5,8
    800028a8:	fee7bc23          	sd	a4,-8(a5)
    800028ac:	fec7ede3          	bltu	a5,a2,800028a6 <memset+0x32>
    800028b0:	8082                	ret
    800028b2:	8082                	ret

00000000800028b4 <_init>:
    800028b4:	7179                	addi	sp,sp,-48
    800028b6:	670d                	lui	a4,0x3
    800028b8:	f406                	sd	ra,40(sp)
    800028ba:	640007b7          	lui	a5,0x64000
    800028be:	f022                	sd	s0,32(sp)
    800028c0:	ec26                	sd	s1,24(sp)
    800028c2:	e84a                	sd	s2,16(sp)
    800028c4:	e44e                	sd	s3,8(sp)
    800028c6:	e052                	sd	s4,0(sp)
    800028c8:	8b070713          	addi	a4,a4,-1872 # 28b0 <_tbss_end+0x28b0>
    800028cc:	cf98                	sw	a4,24(a5)
    800028ce:	4705                	li	a4,1
    800028d0:	c798                	sw	a4,8(a5)
    800028d2:	c7d8                	sw	a4,12(a5)
    800028d4:	0007a823          	sw	zero,16(a5) # 64000010 <_tbss_end+0x64000010>
    800028d8:	00001417          	auipc	s0,0x1
    800028dc:	32043403          	ld	s0,800(s0) # 80003bf8 <_GLOBAL_OFFSET_TABLE_+0x8>
    800028e0:	892a                	mv	s2,a0
    800028e2:	00001497          	auipc	s1,0x1
    800028e6:	31e4b483          	ld	s1,798(s1) # 80003c00 <_GLOBAL_OFFSET_TABLE_+0x10>
    800028ea:	00001517          	auipc	a0,0x1
    800028ee:	ff650513          	addi	a0,a0,-10 # 800038e0 <main+0xd7e>
    800028f2:	89ae                	mv	s3,a1
    800028f4:	116000ef          	jal	ra,80002a0a <kputs>
    800028f8:	00001517          	auipc	a0,0x1
    800028fc:	01050513          	addi	a0,a0,16 # 80003908 <main+0xda6>
    80002900:	10a000ef          	jal	ra,80002a0a <kputs>
    80002904:	409404b3          	sub	s1,s0,s1
    80002908:	8512                	mv	a0,tp
    8000290a:	00018593          	mv	a1,gp
    8000290e:	8626                	mv	a2,s1
    80002910:	8a12                	mv	s4,tp
    80002912:	f23ff0ef          	jal	ra,80002834 <memcpy>
    80002916:	00001617          	auipc	a2,0x1
    8000291a:	2f263603          	ld	a2,754(a2) # 80003c08 <_GLOBAL_OFFSET_TABLE_+0x18>
    8000291e:	4581                	li	a1,0
    80002920:	009a0533          	add	a0,s4,s1
    80002924:	8e01                	sub	a2,a2,s0
    80002926:	f4fff0ef          	jal	ra,80002874 <memset>
    8000292a:	85ce                	mv	a1,s3
    8000292c:	854a                	mv	a0,s2
    8000292e:	e73ff0ef          	jal	ra,800027a0 <thread_entry>
    80002932:	4581                	li	a1,0
    80002934:	4501                	li	a0,0
    80002936:	22c000ef          	jal	ra,80002b62 <main>
    8000293a:	e07ff0ef          	jal	ra,80002740 <tohost_exit>

000000008000293e <strlen>:
    8000293e:	00054783          	lbu	a5,0(a0)
    80002942:	cb89                	beqz	a5,80002954 <strlen+0x16>
    80002944:	87aa                	mv	a5,a0
    80002946:	0017c703          	lbu	a4,1(a5)
    8000294a:	0785                	addi	a5,a5,1
    8000294c:	ff6d                	bnez	a4,80002946 <strlen+0x8>
    8000294e:	40a78533          	sub	a0,a5,a0
    80002952:	8082                	ret
    80002954:	4501                	li	a0,0
    80002956:	8082                	ret

0000000080002958 <strnlen>:
    80002958:	00b506b3          	add	a3,a0,a1
    8000295c:	87aa                	mv	a5,a0
    8000295e:	e589                	bnez	a1,80002968 <strnlen+0x10>
    80002960:	a829                	j	8000297a <strnlen+0x22>
    80002962:	0785                	addi	a5,a5,1
    80002964:	00f68863          	beq	a3,a5,80002974 <strnlen+0x1c>
    80002968:	0007c703          	lbu	a4,0(a5)
    8000296c:	fb7d                	bnez	a4,80002962 <strnlen+0xa>
    8000296e:	40a78533          	sub	a0,a5,a0
    80002972:	8082                	ret
    80002974:	40a68533          	sub	a0,a3,a0
    80002978:	8082                	ret
    8000297a:	4501                	li	a0,0
    8000297c:	8082                	ret

000000008000297e <strcmp>:
    8000297e:	00054783          	lbu	a5,0(a0)
    80002982:	0585                	addi	a1,a1,1
    80002984:	0505                	addi	a0,a0,1
    80002986:	fff5c703          	lbu	a4,-1(a1)
    8000298a:	c799                	beqz	a5,80002998 <strcmp+0x1a>
    8000298c:	fee789e3          	beq	a5,a4,8000297e <strcmp>
    80002990:	0007851b          	sext.w	a0,a5
    80002994:	9d19                	subw	a0,a0,a4
    80002996:	8082                	ret
    80002998:	4501                	li	a0,0
    8000299a:	bfed                	j	80002994 <strcmp+0x16>

000000008000299c <atol>:
    8000299c:	00054703          	lbu	a4,0(a0)
    800029a0:	02000693          	li	a3,32
    800029a4:	87aa                	mv	a5,a0
    800029a6:	00d71763          	bne	a4,a3,800029b4 <atol+0x18>
    800029aa:	0017c703          	lbu	a4,1(a5)
    800029ae:	0785                	addi	a5,a5,1
    800029b0:	fed70de3          	beq	a4,a3,800029aa <atol+0xe>
    800029b4:	02d00693          	li	a3,45
    800029b8:	04d70263          	beq	a4,a3,800029fc <atol+0x60>
    800029bc:	02b00693          	li	a3,43
    800029c0:	02d70763          	beq	a4,a3,800029ee <atol+0x52>
    800029c4:	0007c683          	lbu	a3,0(a5)
    800029c8:	4581                	li	a1,0
    800029ca:	c69d                	beqz	a3,800029f8 <atol+0x5c>
    800029cc:	4501                	li	a0,0
    800029ce:	0785                	addi	a5,a5,1
    800029d0:	00251713          	slli	a4,a0,0x2
    800029d4:	fd06861b          	addiw	a2,a3,-48
    800029d8:	0007c683          	lbu	a3,0(a5)
    800029dc:	972a                	add	a4,a4,a0
    800029de:	0706                	slli	a4,a4,0x1
    800029e0:	00e60533          	add	a0,a2,a4
    800029e4:	f6ed                	bnez	a3,800029ce <atol+0x32>
    800029e6:	c991                	beqz	a1,800029fa <atol+0x5e>
    800029e8:	40a00533          	neg	a0,a0
    800029ec:	8082                	ret
    800029ee:	0017c683          	lbu	a3,1(a5)
    800029f2:	4581                	li	a1,0
    800029f4:	0785                	addi	a5,a5,1
    800029f6:	faf9                	bnez	a3,800029cc <atol+0x30>
    800029f8:	4501                	li	a0,0
    800029fa:	8082                	ret
    800029fc:	0017c683          	lbu	a3,1(a5)
    80002a00:	4585                	li	a1,1
    80002a02:	0785                	addi	a5,a5,1
    80002a04:	f6e1                	bnez	a3,800029cc <atol+0x30>
    80002a06:	4501                	li	a0,0
    80002a08:	bfcd                	j	800029fa <atol+0x5e>

0000000080002a0a <kputs>:
    80002a0a:	00054683          	lbu	a3,0(a0)
    80002a0e:	ce81                	beqz	a3,80002a26 <kputs+0x1c>
    80002a10:	64000737          	lui	a4,0x64000
    80002a14:	40d727af          	amoor.w	a5,a3,(a4)
    80002a18:	2781                	sext.w	a5,a5
    80002a1a:	fe07cde3          	bltz	a5,80002a14 <kputs+0xa>
    80002a1e:	00154683          	lbu	a3,1(a0)
    80002a22:	0505                	addi	a0,a0,1
    80002a24:	fae5                	bnez	a3,80002a14 <kputs+0xa>
    80002a26:	64000737          	lui	a4,0x64000
    80002a2a:	46b5                	li	a3,13
    80002a2c:	40d727af          	amoor.w	a5,a3,(a4)
    80002a30:	2781                	sext.w	a5,a5
    80002a32:	fe07cde3          	bltz	a5,80002a2c <kputs+0x22>
    80002a36:	64000737          	lui	a4,0x64000
    80002a3a:	46a9                	li	a3,10
    80002a3c:	40d727af          	amoor.w	a5,a3,(a4)
    80002a40:	2781                	sext.w	a5,a5
    80002a42:	fe07cde3          	bltz	a5,80002a3c <kputs+0x32>
    80002a46:	8082                	ret

0000000080002a48 <kprintf>:
    80002a48:	715d                	addi	sp,sp,-80
    80002a4a:	00054303          	lbu	t1,0(a0)
    80002a4e:	fc3e                	sd	a5,56(sp)
    80002a50:	083c                	addi	a5,sp,24
    80002a52:	ec2e                	sd	a1,24(sp)
    80002a54:	f032                	sd	a2,32(sp)
    80002a56:	f436                	sd	a3,40(sp)
    80002a58:	f83a                	sd	a4,48(sp)
    80002a5a:	e0c2                	sd	a6,64(sp)
    80002a5c:	e4c6                	sd	a7,72(sp)
    80002a5e:	e43e                	sd	a5,8(sp)
    80002a60:	06030163          	beqz	t1,80002ac2 <kprintf+0x7a>
    80002a64:	00150593          	addi	a1,a0,1
    80002a68:	4e81                	li	t4,0
    80002a6a:	4681                	li	a3,0
    80002a6c:	4701                	li	a4,0
    80002a6e:	02500e13          	li	t3,37
    80002a72:	64000637          	lui	a2,0x64000
    80002a76:	48d5                	li	a7,21
    80002a78:	00001817          	auipc	a6,0x1
    80002a7c:	0c080813          	addi	a6,a6,192 # 80003b38 <errpat+0x190>
    80002a80:	c755                	beqz	a4,80002b2c <kprintf+0xe4>
    80002a82:	f9d3031b          	addiw	t1,t1,-99
    80002a86:	0ff37313          	zext.b	t1,t1
    80002a8a:	0268e463          	bltu	a7,t1,80002ab2 <kprintf+0x6a>
    80002a8e:	030a                	slli	t1,t1,0x2
    80002a90:	9342                	add	t1,t1,a6
    80002a92:	00032783          	lw	a5,0(t1)
    80002a96:	97c2                	add	a5,a5,a6
    80002a98:	8782                	jr	a5
    80002a9a:	67a2                	ld	a5,8(sp)
    80002a9c:	64000737          	lui	a4,0x64000
    80002aa0:	0007c683          	lbu	a3,0(a5)
    80002aa4:	07a1                	addi	a5,a5,8
    80002aa6:	e43e                	sd	a5,8(sp)
    80002aa8:	40d727af          	amoor.w	a5,a3,(a4)
    80002aac:	2781                	sext.w	a5,a5
    80002aae:	fe07cde3          	bltz	a5,80002aa8 <kprintf+0x60>
    80002ab2:	4e81                	li	t4,0
    80002ab4:	4681                	li	a3,0
    80002ab6:	4701                	li	a4,0
    80002ab8:	0005c303          	lbu	t1,0(a1)
    80002abc:	0585                	addi	a1,a1,1
    80002abe:	fc0311e3          	bnez	t1,80002a80 <kprintf+0x38>
    80002ac2:	6161                	addi	sp,sp,80
    80002ac4:	8082                	ret
    80002ac6:	67a2                	ld	a5,8(sp)
    80002ac8:	00878713          	addi	a4,a5,8
    80002acc:	cebd                	beqz	a3,80002b4a <kprintf+0x102>
    80002ace:	0007bf83          	ld	t6,0(a5)
    80002ad2:	e43a                	sd	a4,8(sp)
    80002ad4:	03c00513          	li	a0,60
    80002ad8:	4f25                	li	t5,9
    80002ada:	64000737          	lui	a4,0x64000
    80002ade:	5ef1                	li	t4,-4
    80002ae0:	00afd7b3          	srl	a5,t6,a0
    80002ae4:	00f7f313          	andi	t1,a5,15
    80002ae8:	05730693          	addi	a3,t1,87
    80002aec:	006f6463          	bltu	t5,t1,80002af4 <kprintf+0xac>
    80002af0:	03030693          	addi	a3,t1,48
    80002af4:	40d727af          	amoor.w	a5,a3,(a4)
    80002af8:	2781                	sext.w	a5,a5
    80002afa:	fe07cde3          	bltz	a5,80002af4 <kprintf+0xac>
    80002afe:	1571                	addi	a0,a0,-4
    80002b00:	ffd510e3          	bne	a0,t4,80002ae0 <kprintf+0x98>
    80002b04:	b77d                	j	80002ab2 <kprintf+0x6a>
    80002b06:	67a2                	ld	a5,8(sp)
    80002b08:	6388                	ld	a0,0(a5)
    80002b0a:	07a1                	addi	a5,a5,8
    80002b0c:	e43e                	sd	a5,8(sp)
    80002b0e:	00054683          	lbu	a3,0(a0)
    80002b12:	d2c5                	beqz	a3,80002ab2 <kprintf+0x6a>
    80002b14:	64000737          	lui	a4,0x64000
    80002b18:	40d727af          	amoor.w	a5,a3,(a4)
    80002b1c:	2781                	sext.w	a5,a5
    80002b1e:	fe07cde3          	bltz	a5,80002b18 <kprintf+0xd0>
    80002b22:	00154683          	lbu	a3,1(a0)
    80002b26:	0505                	addi	a0,a0,1
    80002b28:	fae5                	bnez	a3,80002b18 <kprintf+0xd0>
    80002b2a:	b761                	j	80002ab2 <kprintf+0x6a>
    80002b2c:	01c31463          	bne	t1,t3,80002b34 <kprintf+0xec>
    80002b30:	4705                	li	a4,1
    80002b32:	b759                	j	80002ab8 <kprintf+0x70>
    80002b34:	406627af          	amoor.w	a5,t1,(a2)
    80002b38:	2781                	sext.w	a5,a5
    80002b3a:	f607dfe3          	bgez	a5,80002ab8 <kprintf+0x70>
    80002b3e:	406627af          	amoor.w	a5,t1,(a2)
    80002b42:	2781                	sext.w	a5,a5
    80002b44:	fe07c8e3          	bltz	a5,80002b34 <kprintf+0xec>
    80002b48:	bf85                	j	80002ab8 <kprintf+0x70>
    80002b4a:	e43a                	sd	a4,8(sp)
    80002b4c:	0007ef83          	lwu	t6,0(a5)
    80002b50:	4571                	li	a0,28
    80002b52:	f80e83e3          	beqz	t4,80002ad8 <kprintf+0x90>
    80002b56:	4511                	li	a0,4
    80002b58:	b741                	j	80002ad8 <kprintf+0x90>
    80002b5a:	8eba                	mv	t4,a4
    80002b5c:	bfb1                	j	80002ab8 <kprintf+0x70>
    80002b5e:	86ba                	mv	a3,a4
    80002b60:	bfa1                	j	80002ab8 <kprintf+0x70>

Disassembly of section .text.startup:

0000000080002b62 <main>:
    80002b62:	7151                	addi	sp,sp,-240
    80002b64:	0030                	addi	a2,sp,8
    80002b66:	004c                	addi	a1,sp,4
    80002b68:	07a10513          	addi	a0,sp,122
    80002b6c:	f586                	sd	ra,232(sp)
    80002b6e:	f1a2                	sd	s0,224(sp)
    80002b70:	eda6                	sd	s1,216(sp)
    80002b72:	e9ca                	sd	s2,208(sp)
    80002b74:	e5ce                	sd	s3,200(sp)
    80002b76:	e1d2                	sd	s4,192(sp)
    80002b78:	fd56                	sd	s5,184(sp)
    80002b7a:	f95a                	sd	s6,176(sp)
    80002b7c:	f55e                	sd	s7,168(sp)
    80002b7e:	f162                	sd	s8,160(sp)
    80002b80:	ed66                	sd	s9,152(sp)
    80002b82:	e96a                	sd	s10,144(sp)
    80002b84:	e56e                	sd	s11,136(sp)
    80002b86:	c202                	sw	zero,4(sp)
    80002b88:	8abff0ef          	jal	ra,80002432 <portable_init>
    80002b8c:	4505                	li	a0,1
    80002b8e:	e8cff0ef          	jal	ra,8000221a <get_seed_32>
    80002b92:	87aa                	mv	a5,a0
    80002b94:	4509                	li	a0,2
    80002b96:	00f11823          	sh	a5,16(sp)
    80002b9a:	e80ff0ef          	jal	ra,8000221a <get_seed_32>
    80002b9e:	87aa                	mv	a5,a0
    80002ba0:	450d                	li	a0,3
    80002ba2:	00f11923          	sh	a5,18(sp)
    80002ba6:	e74ff0ef          	jal	ra,8000221a <get_seed_32>
    80002baa:	87aa                	mv	a5,a0
    80002bac:	4511                	li	a0,4
    80002bae:	00f11a23          	sh	a5,20(sp)
    80002bb2:	e68ff0ef          	jal	ra,8000221a <get_seed_32>
    80002bb6:	87aa                	mv	a5,a0
    80002bb8:	4515                	li	a0,5
    80002bba:	de3e                	sw	a5,60(sp)
    80002bbc:	e5eff0ef          	jal	ra,8000221a <get_seed_32>
    80002bc0:	2501                	sext.w	a0,a0
    80002bc2:	e111                	bnez	a0,80002bc6 <main+0x64>
    80002bc4:	451d                	li	a0,7
    80002bc6:	67c2                	ld	a5,16(sp)
    80002bc8:	c0aa                	sw	a0,64(sp)
    80002bca:	01079713          	slli	a4,a5,0x10
    80002bce:	e719                	bnez	a4,80002bdc <main+0x7a>
    80002bd0:	06600793          	li	a5,102
    80002bd4:	c802                	sw	zero,16(sp)
    80002bd6:	00f11a23          	sh	a5,20(sp)
    80002bda:	67c2                	ld	a5,16(sp)
    80002bdc:	07c2                	slli	a5,a5,0x10
    80002bde:	83c1                	srli	a5,a5,0x10
    80002be0:	4705                	li	a4,1
    80002be2:	00e79b63          	bne	a5,a4,80002bf8 <main+0x96>
    80002be6:	341537b7          	lui	a5,0x34153
    80002bea:	41578793          	addi	a5,a5,1045 # 34153415 <_tbss_end+0x34153415>
    80002bee:	c83e                	sw	a5,16(sp)
    80002bf0:	06600793          	li	a5,102
    80002bf4:	00f11a23          	sh	a5,20(sp)
    80002bf8:	00001897          	auipc	a7,0x1
    80002bfc:	05888893          	addi	a7,a7,88 # 80003c50 <static_memblk>
    80002c00:	00257793          	andi	a5,a0,2
    80002c04:	00157713          	andi	a4,a0,1
    80002c08:	00f037b3          	snez	a5,a5
    80002c0c:	ec46                	sd	a7,24(sp)
    80002c0e:	06011c23          	sh	zero,120(sp)
    80002c12:	00457693          	andi	a3,a0,4
    80002c16:	973e                	add	a4,a4,a5
    80002c18:	c681                	beqz	a3,80002c20 <main+0xbe>
    80002c1a:	2705                	addiw	a4,a4,1 # 64000001 <_tbss_end+0x64000001>
    80002c1c:	1742                	slli	a4,a4,0x30
    80002c1e:	9341                	srli	a4,a4,0x30
    80002c20:	7d000793          	li	a5,2000
    80002c24:	02e7d33b          	divuw	t1,a5,a4
    80002c28:	0814                	addi	a3,sp,16
    80002c2a:	4701                	li	a4,0
    80002c2c:	4601                	li	a2,0
    80002c2e:	4805                	li	a6,1
    80002c30:	458d                	li	a1,3
    80002c32:	dc1a                	sw	t1,56(sp)
    80002c34:	00e817bb          	sllw	a5,a6,a4
    80002c38:	8fe9                	and	a5,a5,a0
    80002c3a:	2781                	sext.w	a5,a5
    80002c3c:	2705                	addiw	a4,a4,1
    80002c3e:	52079463          	bnez	a5,80003166 <main+0x604>
    80002c42:	06a1                	addi	a3,a3,8
    80002c44:	feb718e3          	bne	a4,a1,80002c34 <main+0xd2>
    80002c48:	4786                	lw	a5,64(sp)
    80002c4a:	0017f713          	andi	a4,a5,1
    80002c4e:	cb09                	beqz	a4,80002c60 <main+0xfe>
    80002c50:	01011603          	lh	a2,16(sp)
    80002c54:	7582                	ld	a1,32(sp)
    80002c56:	5562                	lw	a0,56(sp)
    80002c58:	8c1fe0ef          	jal	ra,80001518 <core_list_init>
    80002c5c:	4786                	lw	a5,64(sp)
    80002c5e:	e4aa                	sd	a0,72(sp)
    80002c60:	0027f713          	andi	a4,a5,2
    80002c64:	1e071363          	bnez	a4,80002e4a <main+0x2e8>
    80002c68:	8b91                	andi	a5,a5,4
    80002c6a:	c799                	beqz	a5,80002c78 <main+0x116>
    80002c6c:	7642                	ld	a2,48(sp)
    80002c6e:	01011583          	lh	a1,16(sp)
    80002c72:	5562                	lw	a0,56(sp)
    80002c74:	924ff0ef          	jal	ra,80001d98 <core_init_state>
    80002c78:	57f2                	lw	a5,60(sp)
    80002c7a:	ef9d                	bnez	a5,80002cb8 <main+0x156>
    80002c7c:	4785                	li	a5,1
    80002c7e:	de3e                	sw	a5,60(sp)
    80002c80:	5772                	lw	a4,60(sp)
    80002c82:	0027179b          	slliw	a5,a4,0x2
    80002c86:	9fb9                	addw	a5,a5,a4
    80002c88:	0017979b          	slliw	a5,a5,0x1
    80002c8c:	de3e                	sw	a5,60(sp)
    80002c8e:	f68ff0ef          	jal	ra,800023f6 <start_time>
    80002c92:	0808                	addi	a0,sp,16
    80002c94:	a43fe0ef          	jal	ra,800016d6 <iterate>
    80002c98:	f6cff0ef          	jal	ra,80002404 <stop_time>
    80002c9c:	f76ff0ef          	jal	ra,80002412 <get_time>
    80002ca0:	f86ff0ef          	jal	ra,80002426 <time_in_secs>
    80002ca4:	2501                	sext.w	a0,a0
    80002ca6:	dd69                	beqz	a0,80002c80 <main+0x11e>
    80002ca8:	47a9                	li	a5,10
    80002caa:	02a7d7bb          	divuw	a5,a5,a0
    80002cae:	5772                	lw	a4,60(sp)
    80002cb0:	2785                	addiw	a5,a5,1
    80002cb2:	02e787bb          	mulw	a5,a5,a4
    80002cb6:	de3e                	sw	a5,60(sp)
    80002cb8:	f3eff0ef          	jal	ra,800023f6 <start_time>
    80002cbc:	0808                	addi	a0,sp,16
    80002cbe:	a19fe0ef          	jal	ra,800016d6 <iterate>
    80002cc2:	f42ff0ef          	jal	ra,80002404 <stop_time>
    80002cc6:	f4cff0ef          	jal	ra,80002412 <get_time>
    80002cca:	8a2a                	mv	s4,a0
    80002ccc:	01011503          	lh	a0,16(sp)
    80002cd0:	4581                	li	a1,0
    80002cd2:	ebeff0ef          	jal	ra,80002390 <crc16>
    80002cd6:	85aa                	mv	a1,a0
    80002cd8:	01211503          	lh	a0,18(sp)
    80002cdc:	eb4ff0ef          	jal	ra,80002390 <crc16>
    80002ce0:	85aa                	mv	a1,a0
    80002ce2:	01411503          	lh	a0,20(sp)
    80002ce6:	eaaff0ef          	jal	ra,80002390 <crc16>
    80002cea:	85aa                	mv	a1,a0
    80002cec:	03811503          	lh	a0,56(sp)
    80002cf0:	ea0ff0ef          	jal	ra,80002390 <crc16>
    80002cf4:	67a1                	lui	a5,0x8
    80002cf6:	0005099b          	sext.w	s3,a0
    80002cfa:	b0578793          	addi	a5,a5,-1275 # 7b05 <_tbss_end+0x7b05>
    80002cfe:	52f98c63          	beq	s3,a5,80003236 <main+0x6d4>
    80002d02:	1937e563          	bltu	a5,s3,80002e8c <main+0x32a>
    80002d06:	6789                	lui	a5,0x2
    80002d08:	8f278793          	addi	a5,a5,-1806 # 18f2 <_tbss_end+0x18f2>
    80002d0c:	4ef98963          	beq	s3,a5,800031fe <main+0x69c>
    80002d10:	6795                	lui	a5,0x5
    80002d12:	eaf78793          	addi	a5,a5,-337 # 4eaf <_tbss_end+0x4eaf>
    80002d16:	52f99e63          	bne	s3,a5,80003252 <main+0x6f0>
    80002d1a:	00000517          	auipc	a0,0x0
    80002d1e:	5c650513          	addi	a0,a0,1478 # 800032e0 <main+0x77e>
    80002d22:	a8fff0ef          	jal	ra,800027b0 <printf>
    80002d26:	00001517          	auipc	a0,0x1
    80002d2a:	ada50513          	addi	a0,a0,-1318 # 80003800 <main+0xc9e>
    80002d2e:	cddff0ef          	jal	ra,80002a0a <kputs>
    80002d32:	4789                	li	a5,2
    80002d34:	00001917          	auipc	s2,0x1
    80002d38:	ef490913          	addi	s2,s2,-268 # 80003c28 <default_num_contexts>
    80002d3c:	00092703          	lw	a4,0(s2)
    80002d40:	16070e63          	beqz	a4,80002ebc <main+0x35a>
    80002d44:	0786                	slli	a5,a5,0x1
    80002d46:	00001d17          	auipc	s10,0x1
    80002d4a:	bd2d0d13          	addi	s10,s10,-1070 # 80003918 <list_known_crc>
    80002d4e:	4d81                	li	s11,0
    80002d50:	4c81                	li	s9,0
    80002d52:	4b01                	li	s6,0
    80002d54:	9d3e                	add	s10,s10,a5
    80002d56:	00000c17          	auipc	s8,0x0
    80002d5a:	61ac0c13          	addi	s8,s8,1562 # 80003370 <main+0x80e>
    80002d5e:	00001a97          	auipc	s5,0x1
    80002d62:	aa2a8a93          	addi	s5,s5,-1374 # 80003800 <main+0xc9e>
    80002d66:	00000b97          	auipc	s7,0x0
    80002d6a:	63ab8b93          	addi	s7,s7,1594 # 800033a0 <main+0x83e>
    80002d6e:	a815                	j	80002da2 <main+0x240>
    80002d70:	08040793          	addi	a5,s0,128
    80002d74:	00278433          	add	s0,a5,sp
    80002d78:	ff845783          	lhu	a5,-8(s0)
    80002d7c:	2c85                	addiw	s9,s9,1
    80002d7e:	00092703          	lw	a4,0(s2)
    80002d82:	00fd87bb          	addw	a5,s11,a5
    80002d86:	1cc2                	slli	s9,s9,0x30
    80002d88:	030cdc93          	srli	s9,s9,0x30
    80002d8c:	03079493          	slli	s1,a5,0x30
    80002d90:	01079d9b          	slliw	s11,a5,0x10
    80002d94:	90c1                	srli	s1,s1,0x30
    80002d96:	410ddd9b          	sraiw	s11,s11,0x10
    80002d9a:	000c8b1b          	sext.w	s6,s9
    80002d9e:	12ecf063          	bgeu	s9,a4,80002ebe <main+0x35c>
    80002da2:	003b1413          	slli	s0,s6,0x3
    80002da6:	416404b3          	sub	s1,s0,s6
    80002daa:	0492                	slli	s1,s1,0x4
    80002dac:	08048793          	addi	a5,s1,128
    80002db0:	002784b3          	add	s1,a5,sp
    80002db4:	fc04a783          	lw	a5,-64(s1)
    80002db8:	fe049c23          	sh	zero,-8(s1)
    80002dbc:	0017f713          	andi	a4,a5,1
    80002dc0:	c70d                	beqz	a4,80002dea <main+0x288>
    80002dc2:	ff24d603          	lhu	a2,-14(s1)
    80002dc6:	000d5683          	lhu	a3,0(s10)
    80002dca:	02d60063          	beq	a2,a3,80002dea <main+0x288>
    80002dce:	85da                	mv	a1,s6
    80002dd0:	8562                	mv	a0,s8
    80002dd2:	9dfff0ef          	jal	ra,800027b0 <printf>
    80002dd6:	8556                	mv	a0,s5
    80002dd8:	c33ff0ef          	jal	ra,80002a0a <kputs>
    80002ddc:	ff84d703          	lhu	a4,-8(s1)
    80002de0:	fc04a783          	lw	a5,-64(s1)
    80002de4:	2705                	addiw	a4,a4,1
    80002de6:	fee49c23          	sh	a4,-8(s1)
    80002dea:	0027f713          	andi	a4,a5,2
    80002dee:	cf05                	beqz	a4,80002e26 <main+0x2c4>
    80002df0:	416404b3          	sub	s1,s0,s6
    80002df4:	0492                	slli	s1,s1,0x4
    80002df6:	08048713          	addi	a4,s1,128
    80002dfa:	002704b3          	add	s1,a4,sp
    80002dfe:	ff44d603          	lhu	a2,-12(s1)
    80002e02:	010d5683          	lhu	a3,16(s10)
    80002e06:	02d60063          	beq	a2,a3,80002e26 <main+0x2c4>
    80002e0a:	85da                	mv	a1,s6
    80002e0c:	855e                	mv	a0,s7
    80002e0e:	9a3ff0ef          	jal	ra,800027b0 <printf>
    80002e12:	8556                	mv	a0,s5
    80002e14:	bf7ff0ef          	jal	ra,80002a0a <kputs>
    80002e18:	ff84d703          	lhu	a4,-8(s1)
    80002e1c:	fc04a783          	lw	a5,-64(s1)
    80002e20:	2705                	addiw	a4,a4,1
    80002e22:	fee49c23          	sh	a4,-8(s1)
    80002e26:	41640433          	sub	s0,s0,s6
    80002e2a:	8b91                	andi	a5,a5,4
    80002e2c:	0412                	slli	s0,s0,0x4
    80002e2e:	d3a9                	beqz	a5,80002d70 <main+0x20e>
    80002e30:	08040793          	addi	a5,s0,128
    80002e34:	00278433          	add	s0,a5,sp
    80002e38:	ff645603          	lhu	a2,-10(s0)
    80002e3c:	020d5683          	lhu	a3,32(s10)
    80002e40:	02d61463          	bne	a2,a3,80002e68 <main+0x306>
    80002e44:	ff845783          	lhu	a5,-8(s0)
    80002e48:	bf15                	j	80002d7c <main+0x21a>
    80002e4a:	01211603          	lh	a2,18(sp)
    80002e4e:	01011783          	lh	a5,16(sp)
    80002e52:	75a2                	ld	a1,40(sp)
    80002e54:	5562                	lw	a0,56(sp)
    80002e56:	0106161b          	slliw	a2,a2,0x10
    80002e5a:	8e5d                	or	a2,a2,a5
    80002e5c:	0894                	addi	a3,sp,80
    80002e5e:	2601                	sext.w	a2,a2
    80002e60:	8d3fe0ef          	jal	ra,80001732 <core_init_matrix>
    80002e64:	4786                	lw	a5,64(sp)
    80002e66:	b509                	j	80002c68 <main+0x106>
    80002e68:	85da                	mv	a1,s6
    80002e6a:	00000517          	auipc	a0,0x0
    80002e6e:	56650513          	addi	a0,a0,1382 # 800033d0 <main+0x86e>
    80002e72:	93fff0ef          	jal	ra,800027b0 <printf>
    80002e76:	8556                	mv	a0,s5
    80002e78:	b93ff0ef          	jal	ra,80002a0a <kputs>
    80002e7c:	ff845783          	lhu	a5,-8(s0)
    80002e80:	2785                	addiw	a5,a5,1
    80002e82:	17c2                	slli	a5,a5,0x30
    80002e84:	93c1                	srli	a5,a5,0x30
    80002e86:	fef41c23          	sh	a5,-8(s0)
    80002e8a:	bdcd                	j	80002d7c <main+0x21a>
    80002e8c:	67a5                	lui	a5,0x9
    80002e8e:	a0278793          	addi	a5,a5,-1534 # 8a02 <_tbss_end+0x8a02>
    80002e92:	38f98463          	beq	s3,a5,8000321a <main+0x6b8>
    80002e96:	67bd                	lui	a5,0xf
    80002e98:	9f578793          	addi	a5,a5,-1547 # e9f5 <_tbss_end+0xe9f5>
    80002e9c:	3af99b63          	bne	s3,a5,80003252 <main+0x6f0>
    80002ea0:	00000517          	auipc	a0,0x0
    80002ea4:	47050513          	addi	a0,a0,1136 # 80003310 <main+0x7ae>
    80002ea8:	909ff0ef          	jal	ra,800027b0 <printf>
    80002eac:	00001517          	auipc	a0,0x1
    80002eb0:	95450513          	addi	a0,a0,-1708 # 80003800 <main+0xc9e>
    80002eb4:	b57ff0ef          	jal	ra,80002a0a <kputs>
    80002eb8:	478d                	li	a5,3
    80002eba:	bdad                	j	80002d34 <main+0x1d2>
    80002ebc:	4481                	li	s1,0
    80002ebe:	d2eff0ef          	jal	ra,800023ec <check_data_types>
    80002ec2:	03816583          	lwu	a1,56(sp)
    80002ec6:	9ca9                	addw	s1,s1,a0
    80002ec8:	00000517          	auipc	a0,0x0
    80002ecc:	53850513          	addi	a0,a0,1336 # 80003400 <main+0x89e>
    80002ed0:	8e1ff0ef          	jal	ra,800027b0 <printf>
    80002ed4:	00001517          	auipc	a0,0x1
    80002ed8:	92c50513          	addi	a0,a0,-1748 # 80003800 <main+0xc9e>
    80002edc:	b2fff0ef          	jal	ra,80002a0a <kputs>
    80002ee0:	85d2                	mv	a1,s4
    80002ee2:	00000517          	auipc	a0,0x0
    80002ee6:	53650513          	addi	a0,a0,1334 # 80003418 <main+0x8b6>
    80002eea:	8c7ff0ef          	jal	ra,800027b0 <printf>
    80002eee:	00001517          	auipc	a0,0x1
    80002ef2:	91250513          	addi	a0,a0,-1774 # 80003800 <main+0xc9e>
    80002ef6:	b15ff0ef          	jal	ra,80002a0a <kputs>
    80002efa:	8552                	mv	a0,s4
    80002efc:	d2aff0ef          	jal	ra,80002426 <time_in_secs>
    80002f00:	0005059b          	sext.w	a1,a0
    80002f04:	00000517          	auipc	a0,0x0
    80002f08:	52c50513          	addi	a0,a0,1324 # 80003430 <main+0x8ce>
    80002f0c:	8a5ff0ef          	jal	ra,800027b0 <printf>
    80002f10:	00001517          	auipc	a0,0x1
    80002f14:	8f050513          	addi	a0,a0,-1808 # 80003800 <main+0xc9e>
    80002f18:	af3ff0ef          	jal	ra,80002a0a <kputs>
    80002f1c:	8552                	mv	a0,s4
    80002f1e:	d08ff0ef          	jal	ra,80002426 <time_in_secs>
    80002f22:	14c2                	slli	s1,s1,0x30
    80002f24:	2501                	sext.w	a0,a0
    80002f26:	90c1                	srli	s1,s1,0x30
    80002f28:	28051f63          	bnez	a0,800031c6 <main+0x664>
    80002f2c:	8552                	mv	a0,s4
    80002f2e:	cf8ff0ef          	jal	ra,80002426 <time_in_secs>
    80002f32:	2501                	sext.w	a0,a0
    80002f34:	47a5                	li	a5,9
    80002f36:	26a7fa63          	bgeu	a5,a0,800031aa <main+0x648>
    80002f3a:	03c16783          	lwu	a5,60(sp)
    80002f3e:	00096583          	lwu	a1,0(s2)
    80002f42:	00000517          	auipc	a0,0x0
    80002f46:	55e50513          	addi	a0,a0,1374 # 800034a0 <main+0x93e>
    80002f4a:	0104949b          	slliw	s1,s1,0x10
    80002f4e:	02f585b3          	mul	a1,a1,a5
    80002f52:	4104d49b          	sraiw	s1,s1,0x10
    80002f56:	85bff0ef          	jal	ra,800027b0 <printf>
    80002f5a:	00001517          	auipc	a0,0x1
    80002f5e:	8a650513          	addi	a0,a0,-1882 # 80003800 <main+0xc9e>
    80002f62:	aa9ff0ef          	jal	ra,80002a0a <kputs>
    80002f66:	00000597          	auipc	a1,0x0
    80002f6a:	55258593          	addi	a1,a1,1362 # 800034b8 <main+0x956>
    80002f6e:	00000517          	auipc	a0,0x0
    80002f72:	55a50513          	addi	a0,a0,1370 # 800034c8 <main+0x966>
    80002f76:	83bff0ef          	jal	ra,800027b0 <printf>
    80002f7a:	00001517          	auipc	a0,0x1
    80002f7e:	88650513          	addi	a0,a0,-1914 # 80003800 <main+0xc9e>
    80002f82:	a89ff0ef          	jal	ra,80002a0a <kputs>
    80002f86:	00000597          	auipc	a1,0x0
    80002f8a:	55a58593          	addi	a1,a1,1370 # 800034e0 <main+0x97e>
    80002f8e:	00000517          	auipc	a0,0x0
    80002f92:	5f250513          	addi	a0,a0,1522 # 80003580 <main+0xa1e>
    80002f96:	81bff0ef          	jal	ra,800027b0 <printf>
    80002f9a:	00001517          	auipc	a0,0x1
    80002f9e:	86650513          	addi	a0,a0,-1946 # 80003800 <main+0xc9e>
    80002fa2:	a69ff0ef          	jal	ra,80002a0a <kputs>
    80002fa6:	00000597          	auipc	a1,0x0
    80002faa:	5f258593          	addi	a1,a1,1522 # 80003598 <main+0xa36>
    80002fae:	00000517          	auipc	a0,0x0
    80002fb2:	63a50513          	addi	a0,a0,1594 # 800035e8 <main+0xa86>
    80002fb6:	ffaff0ef          	jal	ra,800027b0 <printf>
    80002fba:	00001517          	auipc	a0,0x1
    80002fbe:	84650513          	addi	a0,a0,-1978 # 80003800 <main+0xc9e>
    80002fc2:	a49ff0ef          	jal	ra,80002a0a <kputs>
    80002fc6:	85ce                	mv	a1,s3
    80002fc8:	00000517          	auipc	a0,0x0
    80002fcc:	63850513          	addi	a0,a0,1592 # 80003600 <main+0xa9e>
    80002fd0:	fe0ff0ef          	jal	ra,800027b0 <printf>
    80002fd4:	00001517          	auipc	a0,0x1
    80002fd8:	82c50513          	addi	a0,a0,-2004 # 80003800 <main+0xc9e>
    80002fdc:	a2fff0ef          	jal	ra,80002a0a <kputs>
    80002fe0:	4786                	lw	a5,64(sp)
    80002fe2:	0017f713          	andi	a4,a5,1
    80002fe6:	c739                	beqz	a4,80003034 <main+0x4d2>
    80002fe8:	00092703          	lw	a4,0(s2)
    80002fec:	c721                	beqz	a4,80003034 <main+0x4d2>
    80002fee:	4401                	li	s0,0
    80002ff0:	4581                	li	a1,0
    80002ff2:	00000a17          	auipc	s4,0x0
    80002ff6:	62ea0a13          	addi	s4,s4,1582 # 80003620 <main+0xabe>
    80002ffa:	00001997          	auipc	s3,0x1
    80002ffe:	80698993          	addi	s3,s3,-2042 # 80003800 <main+0xc9e>
    80003002:	00359793          	slli	a5,a1,0x3
    80003006:	8f8d                	sub	a5,a5,a1
    80003008:	0792                	slli	a5,a5,0x4
    8000300a:	08078793          	addi	a5,a5,128
    8000300e:	978a                	add	a5,a5,sp
    80003010:	ff27d603          	lhu	a2,-14(a5)
    80003014:	8552                	mv	a0,s4
    80003016:	2405                	addiw	s0,s0,1
    80003018:	f98ff0ef          	jal	ra,800027b0 <printf>
    8000301c:	854e                	mv	a0,s3
    8000301e:	9edff0ef          	jal	ra,80002a0a <kputs>
    80003022:	00092783          	lw	a5,0(s2)
    80003026:	1442                	slli	s0,s0,0x30
    80003028:	9041                	srli	s0,s0,0x30
    8000302a:	0004059b          	sext.w	a1,s0
    8000302e:	fcf46ae3          	bltu	s0,a5,80003002 <main+0x4a0>
    80003032:	4786                	lw	a5,64(sp)
    80003034:	0027f713          	andi	a4,a5,2
    80003038:	cb21                	beqz	a4,80003088 <main+0x526>
    8000303a:	00092703          	lw	a4,0(s2)
    8000303e:	1a070c63          	beqz	a4,800031f6 <main+0x694>
    80003042:	4401                	li	s0,0
    80003044:	4581                	li	a1,0
    80003046:	00000a17          	auipc	s4,0x0
    8000304a:	5faa0a13          	addi	s4,s4,1530 # 80003640 <main+0xade>
    8000304e:	00000997          	auipc	s3,0x0
    80003052:	7b298993          	addi	s3,s3,1970 # 80003800 <main+0xc9e>
    80003056:	00359793          	slli	a5,a1,0x3
    8000305a:	8f8d                	sub	a5,a5,a1
    8000305c:	0792                	slli	a5,a5,0x4
    8000305e:	08078793          	addi	a5,a5,128
    80003062:	978a                	add	a5,a5,sp
    80003064:	ff47d603          	lhu	a2,-12(a5)
    80003068:	8552                	mv	a0,s4
    8000306a:	2405                	addiw	s0,s0,1
    8000306c:	f44ff0ef          	jal	ra,800027b0 <printf>
    80003070:	854e                	mv	a0,s3
    80003072:	999ff0ef          	jal	ra,80002a0a <kputs>
    80003076:	00092783          	lw	a5,0(s2)
    8000307a:	1442                	slli	s0,s0,0x30
    8000307c:	9041                	srli	s0,s0,0x30
    8000307e:	0004059b          	sext.w	a1,s0
    80003082:	fcf46ae3          	bltu	s0,a5,80003056 <main+0x4f4>
    80003086:	4786                	lw	a5,64(sp)
    80003088:	8b91                	andi	a5,a5,4
    8000308a:	00092703          	lw	a4,0(s2)
    8000308e:	c7a1                	beqz	a5,800030d6 <main+0x574>
    80003090:	4401                	li	s0,0
    80003092:	4581                	li	a1,0
    80003094:	00000a17          	auipc	s4,0x0
    80003098:	5cca0a13          	addi	s4,s4,1484 # 80003660 <main+0xafe>
    8000309c:	00000997          	auipc	s3,0x0
    800030a0:	76498993          	addi	s3,s3,1892 # 80003800 <main+0xc9e>
    800030a4:	cf35                	beqz	a4,80003120 <main+0x5be>
    800030a6:	00359793          	slli	a5,a1,0x3
    800030aa:	8f8d                	sub	a5,a5,a1
    800030ac:	0792                	slli	a5,a5,0x4
    800030ae:	08078793          	addi	a5,a5,128
    800030b2:	978a                	add	a5,a5,sp
    800030b4:	ff67d603          	lhu	a2,-10(a5)
    800030b8:	8552                	mv	a0,s4
    800030ba:	2405                	addiw	s0,s0,1
    800030bc:	ef4ff0ef          	jal	ra,800027b0 <printf>
    800030c0:	854e                	mv	a0,s3
    800030c2:	949ff0ef          	jal	ra,80002a0a <kputs>
    800030c6:	00092783          	lw	a5,0(s2)
    800030ca:	1442                	slli	s0,s0,0x30
    800030cc:	9041                	srli	s0,s0,0x30
    800030ce:	0004059b          	sext.w	a1,s0
    800030d2:	fcf46ae3          	bltu	s0,a5,800030a6 <main+0x544>
    800030d6:	00092783          	lw	a5,0(s2)
    800030da:	4401                	li	s0,0
    800030dc:	4581                	li	a1,0
    800030de:	00000a17          	auipc	s4,0x0
    800030e2:	5a2a0a13          	addi	s4,s4,1442 # 80003680 <main+0xb1e>
    800030e6:	00000997          	auipc	s3,0x0
    800030ea:	71a98993          	addi	s3,s3,1818 # 80003800 <main+0xc9e>
    800030ee:	cb8d                	beqz	a5,80003120 <main+0x5be>
    800030f0:	00359793          	slli	a5,a1,0x3
    800030f4:	8f8d                	sub	a5,a5,a1
    800030f6:	0792                	slli	a5,a5,0x4
    800030f8:	08078793          	addi	a5,a5,128
    800030fc:	978a                	add	a5,a5,sp
    800030fe:	ff07d603          	lhu	a2,-16(a5)
    80003102:	8552                	mv	a0,s4
    80003104:	2405                	addiw	s0,s0,1
    80003106:	eaaff0ef          	jal	ra,800027b0 <printf>
    8000310a:	854e                	mv	a0,s3
    8000310c:	8ffff0ef          	jal	ra,80002a0a <kputs>
    80003110:	00092783          	lw	a5,0(s2)
    80003114:	1442                	slli	s0,s0,0x30
    80003116:	9041                	srli	s0,s0,0x30
    80003118:	0004059b          	sext.w	a1,s0
    8000311c:	fcf46ae3          	bltu	s0,a5,800030f0 <main+0x58e>
    80003120:	c8a5                	beqz	s1,80003190 <main+0x62e>
    80003122:	04904a63          	bgtz	s1,80003176 <main+0x614>
    80003126:	00000517          	auipc	a0,0x0
    8000312a:	5c250513          	addi	a0,a0,1474 # 800036e8 <main+0xb86>
    8000312e:	e82ff0ef          	jal	ra,800027b0 <printf>
    80003132:	00000517          	auipc	a0,0x0
    80003136:	6ce50513          	addi	a0,a0,1742 # 80003800 <main+0xc9e>
    8000313a:	8d1ff0ef          	jal	ra,80002a0a <kputs>
    8000313e:	07a10513          	addi	a0,sp,122
    80003142:	af8ff0ef          	jal	ra,8000243a <portable_fini>
    80003146:	70ae                	ld	ra,232(sp)
    80003148:	740e                	ld	s0,224(sp)
    8000314a:	64ee                	ld	s1,216(sp)
    8000314c:	694e                	ld	s2,208(sp)
    8000314e:	69ae                	ld	s3,200(sp)
    80003150:	6a0e                	ld	s4,192(sp)
    80003152:	7aea                	ld	s5,184(sp)
    80003154:	7b4a                	ld	s6,176(sp)
    80003156:	7baa                	ld	s7,168(sp)
    80003158:	7c0a                	ld	s8,160(sp)
    8000315a:	6cea                	ld	s9,152(sp)
    8000315c:	6d4a                	ld	s10,144(sp)
    8000315e:	6daa                	ld	s11,136(sp)
    80003160:	4501                	li	a0,0
    80003162:	616d                	addi	sp,sp,240
    80003164:	8082                	ret
    80003166:	026607b3          	mul	a5,a2,t1
    8000316a:	2605                	addiw	a2,a2,1 # 64000001 <_tbss_end+0x64000001>
    8000316c:	1642                	slli	a2,a2,0x30
    8000316e:	9241                	srli	a2,a2,0x30
    80003170:	97c6                	add	a5,a5,a7
    80003172:	ea9c                	sd	a5,16(a3)
    80003174:	b4f9                	j	80002c42 <main+0xe0>
    80003176:	00000517          	auipc	a0,0x0
    8000317a:	5da50513          	addi	a0,a0,1498 # 80003750 <main+0xbee>
    8000317e:	e32ff0ef          	jal	ra,800027b0 <printf>
    80003182:	00000517          	auipc	a0,0x0
    80003186:	67e50513          	addi	a0,a0,1662 # 80003800 <main+0xc9e>
    8000318a:	881ff0ef          	jal	ra,80002a0a <kputs>
    8000318e:	bf45                	j	8000313e <main+0x5dc>
    80003190:	00000517          	auipc	a0,0x0
    80003194:	51050513          	addi	a0,a0,1296 # 800036a0 <main+0xb3e>
    80003198:	e18ff0ef          	jal	ra,800027b0 <printf>
    8000319c:	00000517          	auipc	a0,0x0
    800031a0:	66450513          	addi	a0,a0,1636 # 80003800 <main+0xc9e>
    800031a4:	867ff0ef          	jal	ra,80002a0a <kputs>
    800031a8:	bf59                	j	8000313e <main+0x5dc>
    800031aa:	00000517          	auipc	a0,0x0
    800031ae:	2b650513          	addi	a0,a0,694 # 80003460 <main+0x8fe>
    800031b2:	dfeff0ef          	jal	ra,800027b0 <printf>
    800031b6:	00000517          	auipc	a0,0x0
    800031ba:	64a50513          	addi	a0,a0,1610 # 80003800 <main+0xc9e>
    800031be:	84dff0ef          	jal	ra,80002a0a <kputs>
    800031c2:	2485                	addiw	s1,s1,1
    800031c4:	bb9d                	j	80002f3a <main+0x3d8>
    800031c6:	57f2                	lw	a5,60(sp)
    800031c8:	00092403          	lw	s0,0(s2)
    800031cc:	8552                	mv	a0,s4
    800031ce:	02f4043b          	mulw	s0,s0,a5
    800031d2:	a54ff0ef          	jal	ra,80002426 <time_in_secs>
    800031d6:	85aa                	mv	a1,a0
    800031d8:	00000517          	auipc	a0,0x0
    800031dc:	27050513          	addi	a0,a0,624 # 80003448 <main+0x8e6>
    800031e0:	02b455bb          	divuw	a1,s0,a1
    800031e4:	dccff0ef          	jal	ra,800027b0 <printf>
    800031e8:	00000517          	auipc	a0,0x0
    800031ec:	61850513          	addi	a0,a0,1560 # 80003800 <main+0xc9e>
    800031f0:	81bff0ef          	jal	ra,80002a0a <kputs>
    800031f4:	bb25                	j	80002f2c <main+0x3ca>
    800031f6:	8b91                	andi	a5,a5,4
    800031f8:	ec078fe3          	beqz	a5,800030d6 <main+0x574>
    800031fc:	b715                	j	80003120 <main+0x5be>
    800031fe:	00000517          	auipc	a0,0x0
    80003202:	14250513          	addi	a0,a0,322 # 80003340 <main+0x7de>
    80003206:	daaff0ef          	jal	ra,800027b0 <printf>
    8000320a:	00000517          	auipc	a0,0x0
    8000320e:	5f650513          	addi	a0,a0,1526 # 80003800 <main+0xc9e>
    80003212:	ff8ff0ef          	jal	ra,80002a0a <kputs>
    80003216:	4791                	li	a5,4
    80003218:	be31                	j	80002d34 <main+0x1d2>
    8000321a:	00000517          	auipc	a0,0x0
    8000321e:	06650513          	addi	a0,a0,102 # 80003280 <main+0x71e>
    80003222:	d8eff0ef          	jal	ra,800027b0 <printf>
    80003226:	00000517          	auipc	a0,0x0
    8000322a:	5da50513          	addi	a0,a0,1498 # 80003800 <main+0xc9e>
    8000322e:	fdcff0ef          	jal	ra,80002a0a <kputs>
    80003232:	4781                	li	a5,0
    80003234:	b601                	j	80002d34 <main+0x1d2>
    80003236:	00000517          	auipc	a0,0x0
    8000323a:	07a50513          	addi	a0,a0,122 # 800032b0 <main+0x74e>
    8000323e:	d72ff0ef          	jal	ra,800027b0 <printf>
    80003242:	00000517          	auipc	a0,0x0
    80003246:	5be50513          	addi	a0,a0,1470 # 80003800 <main+0xc9e>
    8000324a:	fc0ff0ef          	jal	ra,80002a0a <kputs>
    8000324e:	4785                	li	a5,1
    80003250:	b4d5                	j	80002d34 <main+0x1d2>
    80003252:	6441                	lui	s0,0x10
    80003254:	fff40493          	addi	s1,s0,-1 # ffff <_tbss_end+0xffff>
    80003258:	00001917          	auipc	s2,0x1
    8000325c:	9d090913          	addi	s2,s2,-1584 # 80003c28 <default_num_contexts>
    80003260:	b9b9                	j	80002ebe <main+0x35c>
    80003262:	1141                	addi	sp,sp,-16
    80003264:	00000517          	auipc	a0,0x0
    80003268:	65c50513          	addi	a0,a0,1628 # 800038c0 <main+0xd5e>
    8000326c:	e406                	sd	ra,8(sp)
    8000326e:	f9cff0ef          	jal	ra,80002a0a <kputs>
    80003272:	60a2                	ld	ra,8(sp)
    80003274:	557d                	li	a0,-1
    80003276:	0141                	addi	sp,sp,16
    80003278:	8082                	ret
