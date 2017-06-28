
obj/user/faultregs.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 28 80 00       	push   $0x802871
  800049:	68 40 28 80 00       	push   $0x802840
  80004e:	e8 81 06 00 00       	call   8006d4 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 28 80 00       	push   $0x802850
  80005c:	68 54 28 80 00       	push   $0x802854
  800061:	e8 6e 06 00 00       	call   8006d4 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 28 80 00       	push   $0x802864
  800077:	e8 58 06 00 00       	call   8006d4 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 68 28 80 00       	push   $0x802868
  80008e:	e8 41 06 00 00       	call   8006d4 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 28 80 00       	push   $0x802872
  8000a6:	68 54 28 80 00       	push   $0x802854
  8000ab:	e8 24 06 00 00       	call   8006d4 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 28 80 00       	push   $0x802864
  8000c3:	e8 0c 06 00 00       	call   8006d4 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 28 80 00       	push   $0x802868
  8000d5:	e8 fa 05 00 00       	call   8006d4 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 28 80 00       	push   $0x802876
  8000ed:	68 54 28 80 00       	push   $0x802854
  8000f2:	e8 dd 05 00 00       	call   8006d4 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 28 80 00       	push   $0x802864
  80010a:	e8 c5 05 00 00       	call   8006d4 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 28 80 00       	push   $0x802868
  80011c:	e8 b3 05 00 00       	call   8006d4 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 28 80 00       	push   $0x80287a
  800134:	68 54 28 80 00       	push   $0x802854
  800139:	e8 96 05 00 00       	call   8006d4 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 28 80 00       	push   $0x802864
  800151:	e8 7e 05 00 00       	call   8006d4 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 28 80 00       	push   $0x802868
  800163:	e8 6c 05 00 00       	call   8006d4 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 28 80 00       	push   $0x80287e
  80017b:	68 54 28 80 00       	push   $0x802854
  800180:	e8 4f 05 00 00       	call   8006d4 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 28 80 00       	push   $0x802864
  800198:	e8 37 05 00 00       	call   8006d4 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 28 80 00       	push   $0x802868
  8001aa:	e8 25 05 00 00       	call   8006d4 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 28 80 00       	push   $0x802882
  8001c2:	68 54 28 80 00       	push   $0x802854
  8001c7:	e8 08 05 00 00       	call   8006d4 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 28 80 00       	push   $0x802864
  8001df:	e8 f0 04 00 00       	call   8006d4 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 28 80 00       	push   $0x802868
  8001f1:	e8 de 04 00 00       	call   8006d4 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 28 80 00       	push   $0x802886
  800209:	68 54 28 80 00       	push   $0x802854
  80020e:	e8 c1 04 00 00       	call   8006d4 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 28 80 00       	push   $0x802864
  800226:	e8 a9 04 00 00       	call   8006d4 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 28 80 00       	push   $0x802868
  800238:	e8 97 04 00 00       	call   8006d4 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 28 80 00       	push   $0x80288a
  800250:	68 54 28 80 00       	push   $0x802854
  800255:	e8 7a 04 00 00       	call   8006d4 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 28 80 00       	push   $0x802864
  80026d:	e8 62 04 00 00       	call   8006d4 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 28 80 00       	push   $0x802868
  80027f:	e8 50 04 00 00       	call   8006d4 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 28 80 00       	push   $0x80288e
  800297:	68 54 28 80 00       	push   $0x802854
  80029c:	e8 33 04 00 00       	call   8006d4 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 28 80 00       	push   $0x802864
  8002b4:	e8 1b 04 00 00       	call   8006d4 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 28 80 00       	push   $0x802895
  8002c4:	68 54 28 80 00       	push   $0x802854
  8002c9:	e8 06 04 00 00       	call   8006d4 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 68 28 80 00       	push   $0x802868
  8002e3:	e8 ec 03 00 00       	call   8006d4 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 28 80 00       	push   $0x802895
  8002f3:	68 54 28 80 00       	push   $0x802854
  8002f8:	e8 d7 03 00 00       	call   8006d4 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 28 80 00       	push   $0x802864
  800312:	e8 bd 03 00 00       	call   8006d4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 28 80 00       	push   $0x802899
  800322:	e8 ad 03 00 00       	call   8006d4 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 68 28 80 00       	push   $0x802868
  800338:	e8 97 03 00 00       	call   8006d4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 28 80 00       	push   $0x802899
  800348:	e8 87 03 00 00       	call   8006d4 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 28 80 00       	push   $0x802864
  80035a:	e8 75 03 00 00       	call   8006d4 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 28 80 00       	push   $0x802868
  80036c:	e8 63 03 00 00       	call   8006d4 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 64 28 80 00       	push   $0x802864
  80037e:	e8 51 03 00 00       	call   8006d4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 28 80 00       	push   $0x802899
  80038e:	e8 41 03 00 00       	call   8006d4 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 00 29 80 00       	push   $0x802900
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 28 80 00       	push   $0x8028a7
  8003c6:	e8 30 02 00 00       	call   8005fb <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 bf 28 80 00       	push   $0x8028bf
  800435:	68 cd 28 80 00       	push   $0x8028cd
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba b8 28 80 00       	mov    $0x8028b8,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 fd 0b 00 00       	call   80105c <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 d4 28 80 00       	push   $0x8028d4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 a7 28 80 00       	push   $0x8028a7
  800473:	e8 83 01 00 00       	call   8005fb <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 03 0e 00 00       	call   80128d <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 34 29 80 00       	push   $0x802934
  800559:	e8 76 01 00 00       	call   8006d4 <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 e7 28 80 00       	push   $0x8028e7
  800573:	68 f8 28 80 00       	push   $0x8028f8
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba b8 28 80 00       	mov    $0x8028b8,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80059c:	c7 05 b4 40 80 00 00 	movl   $0x0,0x8040b4
  8005a3:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a6:	e8 73 0a 00 00       	call   80101e <sys_getenvid>
  8005ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b8:	a3 b4 40 80 00       	mov    %eax,0x8040b4

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005bd:	85 db                	test   %ebx,%ebx
  8005bf:	7e 07                	jle    8005c8 <libmain+0x37>
		binaryname = argv[0];
  8005c1:	8b 06                	mov    (%esi),%eax
  8005c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	e8 a8 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005d2:	e8 0a 00 00 00       	call   8005e1 <exit>
}
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5d                   	pop    %ebp
  8005e0:	c3                   	ret    

008005e1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e7:	e8 ff 0e 00 00       	call   8014eb <close_all>
	sys_env_destroy(0);
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 e7 09 00 00       	call   800fdd <sys_env_destroy>
}
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	c9                   	leave  
  8005fa:	c3                   	ret    

008005fb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
  8005fe:	56                   	push   %esi
  8005ff:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800600:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800603:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800609:	e8 10 0a 00 00       	call   80101e <sys_getenvid>
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	ff 75 08             	pushl  0x8(%ebp)
  800617:	56                   	push   %esi
  800618:	50                   	push   %eax
  800619:	68 60 29 80 00       	push   $0x802960
  80061e:	e8 b1 00 00 00       	call   8006d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800623:	83 c4 18             	add    $0x18,%esp
  800626:	53                   	push   %ebx
  800627:	ff 75 10             	pushl  0x10(%ebp)
  80062a:	e8 54 00 00 00       	call   800683 <vcprintf>
	cprintf("\n");
  80062f:	c7 04 24 70 28 80 00 	movl   $0x802870,(%esp)
  800636:	e8 99 00 00 00       	call   8006d4 <cprintf>
  80063b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063e:	cc                   	int3   
  80063f:	eb fd                	jmp    80063e <_panic+0x43>

00800641 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	53                   	push   %ebx
  800645:	83 ec 04             	sub    $0x4,%esp
  800648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80064b:	8b 13                	mov    (%ebx),%edx
  80064d:	8d 42 01             	lea    0x1(%edx),%eax
  800650:	89 03                	mov    %eax,(%ebx)
  800652:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800655:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800659:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065e:	75 1a                	jne    80067a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	68 ff 00 00 00       	push   $0xff
  800668:	8d 43 08             	lea    0x8(%ebx),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 2f 09 00 00       	call   800fa0 <sys_cputs>
		b->idx = 0;
  800671:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800677:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80067a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800681:	c9                   	leave  
  800682:	c3                   	ret    

00800683 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80068c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800693:	00 00 00 
	b.cnt = 0;
  800696:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80069d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006a0:	ff 75 0c             	pushl  0xc(%ebp)
  8006a3:	ff 75 08             	pushl  0x8(%ebp)
  8006a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ac:	50                   	push   %eax
  8006ad:	68 41 06 80 00       	push   $0x800641
  8006b2:	e8 54 01 00 00       	call   80080b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c6:	50                   	push   %eax
  8006c7:	e8 d4 08 00 00       	call   800fa0 <sys_cputs>

	return b.cnt;
}
  8006cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006dd:	50                   	push   %eax
  8006de:	ff 75 08             	pushl  0x8(%ebp)
  8006e1:	e8 9d ff ff ff       	call   800683 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	57                   	push   %edi
  8006ec:	56                   	push   %esi
  8006ed:	53                   	push   %ebx
  8006ee:	83 ec 1c             	sub    $0x1c,%esp
  8006f1:	89 c7                	mov    %eax,%edi
  8006f3:	89 d6                	mov    %edx,%esi
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800701:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800704:	bb 00 00 00 00       	mov    $0x0,%ebx
  800709:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80070c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070f:	39 d3                	cmp    %edx,%ebx
  800711:	72 05                	jb     800718 <printnum+0x30>
  800713:	39 45 10             	cmp    %eax,0x10(%ebp)
  800716:	77 45                	ja     80075d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	ff 75 18             	pushl  0x18(%ebp)
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800724:	53                   	push   %ebx
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072e:	ff 75 e0             	pushl  -0x20(%ebp)
  800731:	ff 75 dc             	pushl  -0x24(%ebp)
  800734:	ff 75 d8             	pushl  -0x28(%ebp)
  800737:	e8 74 1e 00 00       	call   8025b0 <__udivdi3>
  80073c:	83 c4 18             	add    $0x18,%esp
  80073f:	52                   	push   %edx
  800740:	50                   	push   %eax
  800741:	89 f2                	mov    %esi,%edx
  800743:	89 f8                	mov    %edi,%eax
  800745:	e8 9e ff ff ff       	call   8006e8 <printnum>
  80074a:	83 c4 20             	add    $0x20,%esp
  80074d:	eb 18                	jmp    800767 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	56                   	push   %esi
  800753:	ff 75 18             	pushl  0x18(%ebp)
  800756:	ff d7                	call   *%edi
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 03                	jmp    800760 <printnum+0x78>
  80075d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800760:	83 eb 01             	sub    $0x1,%ebx
  800763:	85 db                	test   %ebx,%ebx
  800765:	7f e8                	jg     80074f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	56                   	push   %esi
  80076b:	83 ec 04             	sub    $0x4,%esp
  80076e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800771:	ff 75 e0             	pushl  -0x20(%ebp)
  800774:	ff 75 dc             	pushl  -0x24(%ebp)
  800777:	ff 75 d8             	pushl  -0x28(%ebp)
  80077a:	e8 61 1f 00 00       	call   8026e0 <__umoddi3>
  80077f:	83 c4 14             	add    $0x14,%esp
  800782:	0f be 80 83 29 80 00 	movsbl 0x802983(%eax),%eax
  800789:	50                   	push   %eax
  80078a:	ff d7                	call   *%edi
}
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5f                   	pop    %edi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80079a:	83 fa 01             	cmp    $0x1,%edx
  80079d:	7e 0e                	jle    8007ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079f:	8b 10                	mov    (%eax),%edx
  8007a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a4:	89 08                	mov    %ecx,(%eax)
  8007a6:	8b 02                	mov    (%edx),%eax
  8007a8:	8b 52 04             	mov    0x4(%edx),%edx
  8007ab:	eb 22                	jmp    8007cf <getuint+0x38>
	else if (lflag)
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	74 10                	je     8007c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007b1:	8b 10                	mov    (%eax),%edx
  8007b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b6:	89 08                	mov    %ecx,(%eax)
  8007b8:	8b 02                	mov    (%edx),%eax
  8007ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bf:	eb 0e                	jmp    8007cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007c1:	8b 10                	mov    (%eax),%edx
  8007c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c6:	89 08                	mov    %ecx,(%eax)
  8007c8:	8b 02                	mov    (%edx),%eax
  8007ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8007e0:	73 0a                	jae    8007ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8007e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	88 02                	mov    %al,(%edx)
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f7:	50                   	push   %eax
  8007f8:	ff 75 10             	pushl  0x10(%ebp)
  8007fb:	ff 75 0c             	pushl  0xc(%ebp)
  8007fe:	ff 75 08             	pushl  0x8(%ebp)
  800801:	e8 05 00 00 00       	call   80080b <vprintfmt>
	va_end(ap);
}
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	57                   	push   %edi
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	83 ec 2c             	sub    $0x2c,%esp
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80081a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80081d:	eb 12                	jmp    800831 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081f:	85 c0                	test   %eax,%eax
  800821:	0f 84 89 03 00 00    	je     800bb0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	ff d6                	call   *%esi
  80082e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800831:	83 c7 01             	add    $0x1,%edi
  800834:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800838:	83 f8 25             	cmp    $0x25,%eax
  80083b:	75 e2                	jne    80081f <vprintfmt+0x14>
  80083d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800841:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800848:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80084f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800856:	ba 00 00 00 00       	mov    $0x0,%edx
  80085b:	eb 07                	jmp    800864 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800860:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	8d 47 01             	lea    0x1(%edi),%eax
  800867:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086a:	0f b6 07             	movzbl (%edi),%eax
  80086d:	0f b6 c8             	movzbl %al,%ecx
  800870:	83 e8 23             	sub    $0x23,%eax
  800873:	3c 55                	cmp    $0x55,%al
  800875:	0f 87 1a 03 00 00    	ja     800b95 <vprintfmt+0x38a>
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
  800885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800888:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80088c:	eb d6                	jmp    800864 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800899:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80089c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8008a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8008a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008a6:	83 fa 09             	cmp    $0x9,%edx
  8008a9:	77 39                	ja     8008e4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008ae:	eb e9                	jmp    800899 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8008b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b9:	8b 00                	mov    (%eax),%eax
  8008bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008c1:	eb 27                	jmp    8008ea <vprintfmt+0xdf>
  8008c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008cd:	0f 49 c8             	cmovns %eax,%ecx
  8008d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d6:	eb 8c                	jmp    800864 <vprintfmt+0x59>
  8008d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008e2:	eb 80                	jmp    800864 <vprintfmt+0x59>
  8008e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ee:	0f 89 70 ff ff ff    	jns    800864 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800901:	e9 5e ff ff ff       	jmp    800864 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800906:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800909:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80090c:	e9 53 ff ff ff       	jmp    800864 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800911:	8b 45 14             	mov    0x14(%ebp),%eax
  800914:	8d 50 04             	lea    0x4(%eax),%edx
  800917:	89 55 14             	mov    %edx,0x14(%ebp)
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	53                   	push   %ebx
  80091e:	ff 30                	pushl  (%eax)
  800920:	ff d6                	call   *%esi
			break;
  800922:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800928:	e9 04 ff ff ff       	jmp    800831 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80092d:	8b 45 14             	mov    0x14(%ebp),%eax
  800930:	8d 50 04             	lea    0x4(%eax),%edx
  800933:	89 55 14             	mov    %edx,0x14(%ebp)
  800936:	8b 00                	mov    (%eax),%eax
  800938:	99                   	cltd   
  800939:	31 d0                	xor    %edx,%eax
  80093b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093d:	83 f8 0f             	cmp    $0xf,%eax
  800940:	7f 0b                	jg     80094d <vprintfmt+0x142>
  800942:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  800949:	85 d2                	test   %edx,%edx
  80094b:	75 18                	jne    800965 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80094d:	50                   	push   %eax
  80094e:	68 9b 29 80 00       	push   $0x80299b
  800953:	53                   	push   %ebx
  800954:	56                   	push   %esi
  800955:	e8 94 fe ff ff       	call   8007ee <printfmt>
  80095a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800960:	e9 cc fe ff ff       	jmp    800831 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800965:	52                   	push   %edx
  800966:	68 a1 2d 80 00       	push   $0x802da1
  80096b:	53                   	push   %ebx
  80096c:	56                   	push   %esi
  80096d:	e8 7c fe ff ff       	call   8007ee <printfmt>
  800972:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800975:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800978:	e9 b4 fe ff ff       	jmp    800831 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 04             	lea    0x4(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800988:	85 ff                	test   %edi,%edi
  80098a:	b8 94 29 80 00       	mov    $0x802994,%eax
  80098f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800992:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800996:	0f 8e 94 00 00 00    	jle    800a30 <vprintfmt+0x225>
  80099c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009a0:	0f 84 98 00 00 00    	je     800a3e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a6:	83 ec 08             	sub    $0x8,%esp
  8009a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8009ac:	57                   	push   %edi
  8009ad:	e8 86 02 00 00       	call   800c38 <strnlen>
  8009b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b5:	29 c1                	sub    %eax,%ecx
  8009b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c9:	eb 0f                	jmp    8009da <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	53                   	push   %ebx
  8009cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8009d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d4:	83 ef 01             	sub    $0x1,%edi
  8009d7:	83 c4 10             	add    $0x10,%esp
  8009da:	85 ff                	test   %edi,%edi
  8009dc:	7f ed                	jg     8009cb <vprintfmt+0x1c0>
  8009de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	0f 49 c1             	cmovns %ecx,%eax
  8009ee:	29 c1                	sub    %eax,%ecx
  8009f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8009f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f9:	89 cb                	mov    %ecx,%ebx
  8009fb:	eb 4d                	jmp    800a4a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a01:	74 1b                	je     800a1e <vprintfmt+0x213>
  800a03:	0f be c0             	movsbl %al,%eax
  800a06:	83 e8 20             	sub    $0x20,%eax
  800a09:	83 f8 5e             	cmp    $0x5e,%eax
  800a0c:	76 10                	jbe    800a1e <vprintfmt+0x213>
					putch('?', putdat);
  800a0e:	83 ec 08             	sub    $0x8,%esp
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	6a 3f                	push   $0x3f
  800a16:	ff 55 08             	call   *0x8(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	eb 0d                	jmp    800a2b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	ff 75 0c             	pushl  0xc(%ebp)
  800a24:	52                   	push   %edx
  800a25:	ff 55 08             	call   *0x8(%ebp)
  800a28:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2b:	83 eb 01             	sub    $0x1,%ebx
  800a2e:	eb 1a                	jmp    800a4a <vprintfmt+0x23f>
  800a30:	89 75 08             	mov    %esi,0x8(%ebp)
  800a33:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a36:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a39:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3c:	eb 0c                	jmp    800a4a <vprintfmt+0x23f>
  800a3e:	89 75 08             	mov    %esi,0x8(%ebp)
  800a41:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a44:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a47:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a4a:	83 c7 01             	add    $0x1,%edi
  800a4d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a51:	0f be d0             	movsbl %al,%edx
  800a54:	85 d2                	test   %edx,%edx
  800a56:	74 23                	je     800a7b <vprintfmt+0x270>
  800a58:	85 f6                	test   %esi,%esi
  800a5a:	78 a1                	js     8009fd <vprintfmt+0x1f2>
  800a5c:	83 ee 01             	sub    $0x1,%esi
  800a5f:	79 9c                	jns    8009fd <vprintfmt+0x1f2>
  800a61:	89 df                	mov    %ebx,%edi
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a69:	eb 18                	jmp    800a83 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a6b:	83 ec 08             	sub    $0x8,%esp
  800a6e:	53                   	push   %ebx
  800a6f:	6a 20                	push   $0x20
  800a71:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a73:	83 ef 01             	sub    $0x1,%edi
  800a76:	83 c4 10             	add    $0x10,%esp
  800a79:	eb 08                	jmp    800a83 <vprintfmt+0x278>
  800a7b:	89 df                	mov    %ebx,%edi
  800a7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a83:	85 ff                	test   %edi,%edi
  800a85:	7f e4                	jg     800a6b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a8a:	e9 a2 fd ff ff       	jmp    800831 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8f:	83 fa 01             	cmp    $0x1,%edx
  800a92:	7e 16                	jle    800aaa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a94:	8b 45 14             	mov    0x14(%ebp),%eax
  800a97:	8d 50 08             	lea    0x8(%eax),%edx
  800a9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9d:	8b 50 04             	mov    0x4(%eax),%edx
  800aa0:	8b 00                	mov    (%eax),%eax
  800aa2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa8:	eb 32                	jmp    800adc <vprintfmt+0x2d1>
	else if (lflag)
  800aaa:	85 d2                	test   %edx,%edx
  800aac:	74 18                	je     800ac6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aae:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab1:	8d 50 04             	lea    0x4(%eax),%edx
  800ab4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab7:	8b 00                	mov    (%eax),%eax
  800ab9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800abc:	89 c1                	mov    %eax,%ecx
  800abe:	c1 f9 1f             	sar    $0x1f,%ecx
  800ac1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ac4:	eb 16                	jmp    800adc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac9:	8d 50 04             	lea    0x4(%eax),%edx
  800acc:	89 55 14             	mov    %edx,0x14(%ebp)
  800acf:	8b 00                	mov    (%eax),%eax
  800ad1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad4:	89 c1                	mov    %eax,%ecx
  800ad6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800adc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800adf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ae2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800aeb:	79 74                	jns    800b61 <vprintfmt+0x356>
				putch('-', putdat);
  800aed:	83 ec 08             	sub    $0x8,%esp
  800af0:	53                   	push   %ebx
  800af1:	6a 2d                	push   $0x2d
  800af3:	ff d6                	call   *%esi
				num = -(long long) num;
  800af5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800afb:	f7 d8                	neg    %eax
  800afd:	83 d2 00             	adc    $0x0,%edx
  800b00:	f7 da                	neg    %edx
  800b02:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b05:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b0a:	eb 55                	jmp    800b61 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b0c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0f:	e8 83 fc ff ff       	call   800797 <getuint>
			base = 10;
  800b14:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b19:	eb 46                	jmp    800b61 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1e:	e8 74 fc ff ff       	call   800797 <getuint>
		        base = 8;
  800b23:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800b28:	eb 37                	jmp    800b61 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	53                   	push   %ebx
  800b2e:	6a 30                	push   $0x30
  800b30:	ff d6                	call   *%esi
			putch('x', putdat);
  800b32:	83 c4 08             	add    $0x8,%esp
  800b35:	53                   	push   %ebx
  800b36:	6a 78                	push   $0x78
  800b38:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3d:	8d 50 04             	lea    0x4(%eax),%edx
  800b40:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b43:	8b 00                	mov    (%eax),%eax
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b4a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b4d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b52:	eb 0d                	jmp    800b61 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b54:	8d 45 14             	lea    0x14(%ebp),%eax
  800b57:	e8 3b fc ff ff       	call   800797 <getuint>
			base = 16;
  800b5c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b68:	57                   	push   %edi
  800b69:	ff 75 e0             	pushl  -0x20(%ebp)
  800b6c:	51                   	push   %ecx
  800b6d:	52                   	push   %edx
  800b6e:	50                   	push   %eax
  800b6f:	89 da                	mov    %ebx,%edx
  800b71:	89 f0                	mov    %esi,%eax
  800b73:	e8 70 fb ff ff       	call   8006e8 <printnum>
			break;
  800b78:	83 c4 20             	add    $0x20,%esp
  800b7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b7e:	e9 ae fc ff ff       	jmp    800831 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b83:	83 ec 08             	sub    $0x8,%esp
  800b86:	53                   	push   %ebx
  800b87:	51                   	push   %ecx
  800b88:	ff d6                	call   *%esi
			break;
  800b8a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b90:	e9 9c fc ff ff       	jmp    800831 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	53                   	push   %ebx
  800b99:	6a 25                	push   $0x25
  800b9b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b9d:	83 c4 10             	add    $0x10,%esp
  800ba0:	eb 03                	jmp    800ba5 <vprintfmt+0x39a>
  800ba2:	83 ef 01             	sub    $0x1,%edi
  800ba5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800ba9:	75 f7                	jne    800ba2 <vprintfmt+0x397>
  800bab:	e9 81 fc ff ff       	jmp    800831 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 18             	sub    $0x18,%esp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bcb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd5:	85 c0                	test   %eax,%eax
  800bd7:	74 26                	je     800bff <vsnprintf+0x47>
  800bd9:	85 d2                	test   %edx,%edx
  800bdb:	7e 22                	jle    800bff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bdd:	ff 75 14             	pushl  0x14(%ebp)
  800be0:	ff 75 10             	pushl  0x10(%ebp)
  800be3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be6:	50                   	push   %eax
  800be7:	68 d1 07 80 00       	push   $0x8007d1
  800bec:	e8 1a fc ff ff       	call   80080b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb 05                	jmp    800c04 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c0c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c0f:	50                   	push   %eax
  800c10:	ff 75 10             	pushl  0x10(%ebp)
  800c13:	ff 75 0c             	pushl  0xc(%ebp)
  800c16:	ff 75 08             	pushl  0x8(%ebp)
  800c19:	e8 9a ff ff ff       	call   800bb8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	eb 03                	jmp    800c30 <strlen+0x10>
		n++;
  800c2d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c34:	75 f7                	jne    800c2d <strlen+0xd>
		n++;
	return n;
}
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	eb 03                	jmp    800c4b <strnlen+0x13>
		n++;
  800c48:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c4b:	39 c2                	cmp    %eax,%edx
  800c4d:	74 08                	je     800c57 <strnlen+0x1f>
  800c4f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c53:	75 f3                	jne    800c48 <strnlen+0x10>
  800c55:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	53                   	push   %ebx
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c63:	89 c2                	mov    %eax,%edx
  800c65:	83 c2 01             	add    $0x1,%edx
  800c68:	83 c1 01             	add    $0x1,%ecx
  800c6b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c6f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c72:	84 db                	test   %bl,%bl
  800c74:	75 ef                	jne    800c65 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c76:	5b                   	pop    %ebx
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	53                   	push   %ebx
  800c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c80:	53                   	push   %ebx
  800c81:	e8 9a ff ff ff       	call   800c20 <strlen>
  800c86:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c89:	ff 75 0c             	pushl  0xc(%ebp)
  800c8c:	01 d8                	add    %ebx,%eax
  800c8e:	50                   	push   %eax
  800c8f:	e8 c5 ff ff ff       	call   800c59 <strcpy>
	return dst;
}
  800c94:	89 d8                	mov    %ebx,%eax
  800c96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	eb 0f                	jmp    800cbe <strncpy+0x23>
		*dst++ = *src;
  800caf:	83 c2 01             	add    $0x1,%edx
  800cb2:	0f b6 01             	movzbl (%ecx),%eax
  800cb5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cb8:	80 39 01             	cmpb   $0x1,(%ecx)
  800cbb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cbe:	39 da                	cmp    %ebx,%edx
  800cc0:	75 ed                	jne    800caf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cc2:	89 f0                	mov    %esi,%eax
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 10             	mov    0x10(%ebp),%edx
  800cd6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd8:	85 d2                	test   %edx,%edx
  800cda:	74 21                	je     800cfd <strlcpy+0x35>
  800cdc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ce0:	89 f2                	mov    %esi,%edx
  800ce2:	eb 09                	jmp    800ced <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ce4:	83 c2 01             	add    $0x1,%edx
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ced:	39 c2                	cmp    %eax,%edx
  800cef:	74 09                	je     800cfa <strlcpy+0x32>
  800cf1:	0f b6 19             	movzbl (%ecx),%ebx
  800cf4:	84 db                	test   %bl,%bl
  800cf6:	75 ec                	jne    800ce4 <strlcpy+0x1c>
  800cf8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cfa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cfd:	29 f0                	sub    %esi,%eax
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d0c:	eb 06                	jmp    800d14 <strcmp+0x11>
		p++, q++;
  800d0e:	83 c1 01             	add    $0x1,%ecx
  800d11:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d14:	0f b6 01             	movzbl (%ecx),%eax
  800d17:	84 c0                	test   %al,%al
  800d19:	74 04                	je     800d1f <strcmp+0x1c>
  800d1b:	3a 02                	cmp    (%edx),%al
  800d1d:	74 ef                	je     800d0e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1f:	0f b6 c0             	movzbl %al,%eax
  800d22:	0f b6 12             	movzbl (%edx),%edx
  800d25:	29 d0                	sub    %edx,%eax
}
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	53                   	push   %ebx
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d33:	89 c3                	mov    %eax,%ebx
  800d35:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d38:	eb 06                	jmp    800d40 <strncmp+0x17>
		n--, p++, q++;
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d40:	39 d8                	cmp    %ebx,%eax
  800d42:	74 15                	je     800d59 <strncmp+0x30>
  800d44:	0f b6 08             	movzbl (%eax),%ecx
  800d47:	84 c9                	test   %cl,%cl
  800d49:	74 04                	je     800d4f <strncmp+0x26>
  800d4b:	3a 0a                	cmp    (%edx),%cl
  800d4d:	74 eb                	je     800d3a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	0f b6 12             	movzbl (%edx),%edx
  800d55:	29 d0                	sub    %edx,%eax
  800d57:	eb 05                	jmp    800d5e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d6b:	eb 07                	jmp    800d74 <strchr+0x13>
		if (*s == c)
  800d6d:	38 ca                	cmp    %cl,%dl
  800d6f:	74 0f                	je     800d80 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d71:	83 c0 01             	add    $0x1,%eax
  800d74:	0f b6 10             	movzbl (%eax),%edx
  800d77:	84 d2                	test   %dl,%dl
  800d79:	75 f2                	jne    800d6d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d8c:	eb 03                	jmp    800d91 <strfind+0xf>
  800d8e:	83 c0 01             	add    $0x1,%eax
  800d91:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d94:	38 ca                	cmp    %cl,%dl
  800d96:	74 04                	je     800d9c <strfind+0x1a>
  800d98:	84 d2                	test   %dl,%dl
  800d9a:	75 f2                	jne    800d8e <strfind+0xc>
			break;
	return (char *) s;
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800da7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800daa:	85 c9                	test   %ecx,%ecx
  800dac:	74 36                	je     800de4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db4:	75 28                	jne    800dde <memset+0x40>
  800db6:	f6 c1 03             	test   $0x3,%cl
  800db9:	75 23                	jne    800dde <memset+0x40>
		c &= 0xFF;
  800dbb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dbf:	89 d3                	mov    %edx,%ebx
  800dc1:	c1 e3 08             	shl    $0x8,%ebx
  800dc4:	89 d6                	mov    %edx,%esi
  800dc6:	c1 e6 18             	shl    $0x18,%esi
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	c1 e0 10             	shl    $0x10,%eax
  800dce:	09 f0                	or     %esi,%eax
  800dd0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dd2:	89 d8                	mov    %ebx,%eax
  800dd4:	09 d0                	or     %edx,%eax
  800dd6:	c1 e9 02             	shr    $0x2,%ecx
  800dd9:	fc                   	cld    
  800dda:	f3 ab                	rep stos %eax,%es:(%edi)
  800ddc:	eb 06                	jmp    800de4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	fc                   	cld    
  800de2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de4:	89 f8                	mov    %edi,%eax
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df9:	39 c6                	cmp    %eax,%esi
  800dfb:	73 35                	jae    800e32 <memmove+0x47>
  800dfd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e00:	39 d0                	cmp    %edx,%eax
  800e02:	73 2e                	jae    800e32 <memmove+0x47>
		s += n;
		d += n;
  800e04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e07:	89 d6                	mov    %edx,%esi
  800e09:	09 fe                	or     %edi,%esi
  800e0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e11:	75 13                	jne    800e26 <memmove+0x3b>
  800e13:	f6 c1 03             	test   $0x3,%cl
  800e16:	75 0e                	jne    800e26 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e18:	83 ef 04             	sub    $0x4,%edi
  800e1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e1e:	c1 e9 02             	shr    $0x2,%ecx
  800e21:	fd                   	std    
  800e22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e24:	eb 09                	jmp    800e2f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e26:	83 ef 01             	sub    $0x1,%edi
  800e29:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e2c:	fd                   	std    
  800e2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e2f:	fc                   	cld    
  800e30:	eb 1d                	jmp    800e4f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	09 c2                	or     %eax,%edx
  800e36:	f6 c2 03             	test   $0x3,%dl
  800e39:	75 0f                	jne    800e4a <memmove+0x5f>
  800e3b:	f6 c1 03             	test   $0x3,%cl
  800e3e:	75 0a                	jne    800e4a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e40:	c1 e9 02             	shr    $0x2,%ecx
  800e43:	89 c7                	mov    %eax,%edi
  800e45:	fc                   	cld    
  800e46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e48:	eb 05                	jmp    800e4f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e4a:	89 c7                	mov    %eax,%edi
  800e4c:	fc                   	cld    
  800e4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e56:	ff 75 10             	pushl  0x10(%ebp)
  800e59:	ff 75 0c             	pushl  0xc(%ebp)
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 87 ff ff ff       	call   800deb <memmove>
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e71:	89 c6                	mov    %eax,%esi
  800e73:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e76:	eb 1a                	jmp    800e92 <memcmp+0x2c>
		if (*s1 != *s2)
  800e78:	0f b6 08             	movzbl (%eax),%ecx
  800e7b:	0f b6 1a             	movzbl (%edx),%ebx
  800e7e:	38 d9                	cmp    %bl,%cl
  800e80:	74 0a                	je     800e8c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e82:	0f b6 c1             	movzbl %cl,%eax
  800e85:	0f b6 db             	movzbl %bl,%ebx
  800e88:	29 d8                	sub    %ebx,%eax
  800e8a:	eb 0f                	jmp    800e9b <memcmp+0x35>
		s1++, s2++;
  800e8c:	83 c0 01             	add    $0x1,%eax
  800e8f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e92:	39 f0                	cmp    %esi,%eax
  800e94:	75 e2                	jne    800e78 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ea6:	89 c1                	mov    %eax,%ecx
  800ea8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800eab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eaf:	eb 0a                	jmp    800ebb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb1:	0f b6 10             	movzbl (%eax),%edx
  800eb4:	39 da                	cmp    %ebx,%edx
  800eb6:	74 07                	je     800ebf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb8:	83 c0 01             	add    $0x1,%eax
  800ebb:	39 c8                	cmp    %ecx,%eax
  800ebd:	72 f2                	jb     800eb1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ebf:	5b                   	pop    %ebx
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ece:	eb 03                	jmp    800ed3 <strtol+0x11>
		s++;
  800ed0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed3:	0f b6 01             	movzbl (%ecx),%eax
  800ed6:	3c 20                	cmp    $0x20,%al
  800ed8:	74 f6                	je     800ed0 <strtol+0xe>
  800eda:	3c 09                	cmp    $0x9,%al
  800edc:	74 f2                	je     800ed0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ede:	3c 2b                	cmp    $0x2b,%al
  800ee0:	75 0a                	jne    800eec <strtol+0x2a>
		s++;
  800ee2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ee5:	bf 00 00 00 00       	mov    $0x0,%edi
  800eea:	eb 11                	jmp    800efd <strtol+0x3b>
  800eec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ef1:	3c 2d                	cmp    $0x2d,%al
  800ef3:	75 08                	jne    800efd <strtol+0x3b>
		s++, neg = 1;
  800ef5:	83 c1 01             	add    $0x1,%ecx
  800ef8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800efd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f03:	75 15                	jne    800f1a <strtol+0x58>
  800f05:	80 39 30             	cmpb   $0x30,(%ecx)
  800f08:	75 10                	jne    800f1a <strtol+0x58>
  800f0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f0e:	75 7c                	jne    800f8c <strtol+0xca>
		s += 2, base = 16;
  800f10:	83 c1 02             	add    $0x2,%ecx
  800f13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f18:	eb 16                	jmp    800f30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f1a:	85 db                	test   %ebx,%ebx
  800f1c:	75 12                	jne    800f30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f23:	80 39 30             	cmpb   $0x30,(%ecx)
  800f26:	75 08                	jne    800f30 <strtol+0x6e>
		s++, base = 8;
  800f28:	83 c1 01             	add    $0x1,%ecx
  800f2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
  800f35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f38:	0f b6 11             	movzbl (%ecx),%edx
  800f3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f3e:	89 f3                	mov    %esi,%ebx
  800f40:	80 fb 09             	cmp    $0x9,%bl
  800f43:	77 08                	ja     800f4d <strtol+0x8b>
			dig = *s - '0';
  800f45:	0f be d2             	movsbl %dl,%edx
  800f48:	83 ea 30             	sub    $0x30,%edx
  800f4b:	eb 22                	jmp    800f6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f50:	89 f3                	mov    %esi,%ebx
  800f52:	80 fb 19             	cmp    $0x19,%bl
  800f55:	77 08                	ja     800f5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f57:	0f be d2             	movsbl %dl,%edx
  800f5a:	83 ea 57             	sub    $0x57,%edx
  800f5d:	eb 10                	jmp    800f6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f62:	89 f3                	mov    %esi,%ebx
  800f64:	80 fb 19             	cmp    $0x19,%bl
  800f67:	77 16                	ja     800f7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f69:	0f be d2             	movsbl %dl,%edx
  800f6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f72:	7d 0b                	jge    800f7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f74:	83 c1 01             	add    $0x1,%ecx
  800f77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f7d:	eb b9                	jmp    800f38 <strtol+0x76>

	if (endptr)
  800f7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f83:	74 0d                	je     800f92 <strtol+0xd0>
		*endptr = (char *) s;
  800f85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f88:	89 0e                	mov    %ecx,(%esi)
  800f8a:	eb 06                	jmp    800f92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f8c:	85 db                	test   %ebx,%ebx
  800f8e:	74 98                	je     800f28 <strtol+0x66>
  800f90:	eb 9e                	jmp    800f30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	f7 da                	neg    %edx
  800f96:	85 ff                	test   %edi,%edi
  800f98:	0f 45 c2             	cmovne %edx,%eax
}
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb1:	89 c3                	mov    %eax,%ebx
  800fb3:	89 c7                	mov    %eax,%edi
  800fb5:	89 c6                	mov    %eax,%esi
  800fb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fce:	89 d1                	mov    %edx,%ecx
  800fd0:	89 d3                	mov    %edx,%ebx
  800fd2:	89 d7                	mov    %edx,%edi
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800feb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	89 cb                	mov    %ecx,%ebx
  800ff5:	89 cf                	mov    %ecx,%edi
  800ff7:	89 ce                	mov    %ecx,%esi
  800ff9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	7e 17                	jle    801016 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	50                   	push   %eax
  801003:	6a 03                	push   $0x3
  801005:	68 7f 2c 80 00       	push   $0x802c7f
  80100a:	6a 23                	push   $0x23
  80100c:	68 9c 2c 80 00       	push   $0x802c9c
  801011:	e8 e5 f5 ff ff       	call   8005fb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5f                   	pop    %edi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	ba 00 00 00 00       	mov    $0x0,%edx
  801029:	b8 02 00 00 00       	mov    $0x2,%eax
  80102e:	89 d1                	mov    %edx,%ecx
  801030:	89 d3                	mov    %edx,%ebx
  801032:	89 d7                	mov    %edx,%edi
  801034:	89 d6                	mov    %edx,%esi
  801036:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_yield>:

void
sys_yield(void)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	ba 00 00 00 00       	mov    $0x0,%edx
  801048:	b8 0b 00 00 00       	mov    $0xb,%eax
  80104d:	89 d1                	mov    %edx,%ecx
  80104f:	89 d3                	mov    %edx,%ebx
  801051:	89 d7                	mov    %edx,%edi
  801053:	89 d6                	mov    %edx,%esi
  801055:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
  801062:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801065:	be 00 00 00 00       	mov    $0x0,%esi
  80106a:	b8 04 00 00 00       	mov    $0x4,%eax
  80106f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801072:	8b 55 08             	mov    0x8(%ebp),%edx
  801075:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801078:	89 f7                	mov    %esi,%edi
  80107a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107c:	85 c0                	test   %eax,%eax
  80107e:	7e 17                	jle    801097 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	50                   	push   %eax
  801084:	6a 04                	push   $0x4
  801086:	68 7f 2c 80 00       	push   $0x802c7f
  80108b:	6a 23                	push   $0x23
  80108d:	68 9c 2c 80 00       	push   $0x802c9c
  801092:	e8 64 f5 ff ff       	call   8005fb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b9:	8b 75 18             	mov    0x18(%ebp),%esi
  8010bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	7e 17                	jle    8010d9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	50                   	push   %eax
  8010c6:	6a 05                	push   $0x5
  8010c8:	68 7f 2c 80 00       	push   $0x802c7f
  8010cd:	6a 23                	push   $0x23
  8010cf:	68 9c 2c 80 00       	push   $0x802c9c
  8010d4:	e8 22 f5 ff ff       	call   8005fb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fa:	89 df                	mov    %ebx,%edi
  8010fc:	89 de                	mov    %ebx,%esi
  8010fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	7e 17                	jle    80111b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	50                   	push   %eax
  801108:	6a 06                	push   $0x6
  80110a:	68 7f 2c 80 00       	push   $0x802c7f
  80110f:	6a 23                	push   $0x23
  801111:	68 9c 2c 80 00       	push   $0x802c9c
  801116:	e8 e0 f4 ff ff       	call   8005fb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801131:	b8 08 00 00 00       	mov    $0x8,%eax
  801136:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801139:	8b 55 08             	mov    0x8(%ebp),%edx
  80113c:	89 df                	mov    %ebx,%edi
  80113e:	89 de                	mov    %ebx,%esi
  801140:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801142:	85 c0                	test   %eax,%eax
  801144:	7e 17                	jle    80115d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	50                   	push   %eax
  80114a:	6a 08                	push   $0x8
  80114c:	68 7f 2c 80 00       	push   $0x802c7f
  801151:	6a 23                	push   $0x23
  801153:	68 9c 2c 80 00       	push   $0x802c9c
  801158:	e8 9e f4 ff ff       	call   8005fb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801173:	b8 09 00 00 00       	mov    $0x9,%eax
  801178:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	89 df                	mov    %ebx,%edi
  801180:	89 de                	mov    %ebx,%esi
  801182:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801184:	85 c0                	test   %eax,%eax
  801186:	7e 17                	jle    80119f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801188:	83 ec 0c             	sub    $0xc,%esp
  80118b:	50                   	push   %eax
  80118c:	6a 09                	push   $0x9
  80118e:	68 7f 2c 80 00       	push   $0x802c7f
  801193:	6a 23                	push   $0x23
  801195:	68 9c 2c 80 00       	push   $0x802c9c
  80119a:	e8 5c f4 ff ff       	call   8005fb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80119f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a2:	5b                   	pop    %ebx
  8011a3:	5e                   	pop    %esi
  8011a4:	5f                   	pop    %edi
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c0:	89 df                	mov    %ebx,%edi
  8011c2:	89 de                	mov    %ebx,%esi
  8011c4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	7e 17                	jle    8011e1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	50                   	push   %eax
  8011ce:	6a 0a                	push   $0xa
  8011d0:	68 7f 2c 80 00       	push   $0x802c7f
  8011d5:	6a 23                	push   $0x23
  8011d7:	68 9c 2c 80 00       	push   $0x802c9c
  8011dc:	e8 1a f4 ff ff       	call   8005fb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ef:	be 00 00 00 00       	mov    $0x0,%esi
  8011f4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801202:	8b 7d 14             	mov    0x14(%ebp),%edi
  801205:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5f                   	pop    %edi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801215:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121f:	8b 55 08             	mov    0x8(%ebp),%edx
  801222:	89 cb                	mov    %ecx,%ebx
  801224:	89 cf                	mov    %ecx,%edi
  801226:	89 ce                	mov    %ecx,%esi
  801228:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80122a:	85 c0                	test   %eax,%eax
  80122c:	7e 17                	jle    801245 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122e:	83 ec 0c             	sub    $0xc,%esp
  801231:	50                   	push   %eax
  801232:	6a 0d                	push   $0xd
  801234:	68 7f 2c 80 00       	push   $0x802c7f
  801239:	6a 23                	push   $0x23
  80123b:	68 9c 2c 80 00       	push   $0x802c9c
  801240:	e8 b6 f3 ff ff       	call   8005fb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801248:	5b                   	pop    %ebx
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	57                   	push   %edi
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801253:	ba 00 00 00 00       	mov    $0x0,%edx
  801258:	b8 0e 00 00 00       	mov    $0xe,%eax
  80125d:	89 d1                	mov    %edx,%ecx
  80125f:	89 d3                	mov    %edx,%ebx
  801261:	89 d7                	mov    %edx,%edi
  801263:	89 d6                	mov    %edx,%esi
  801265:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	57                   	push   %edi
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801272:	bb 00 00 00 00       	mov    $0x0,%ebx
  801277:	b8 0f 00 00 00       	mov    $0xf,%eax
  80127c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127f:	8b 55 08             	mov    0x8(%ebp),%edx
  801282:	89 df                	mov    %ebx,%edi
  801284:	89 de                	mov    %ebx,%esi
  801286:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801293:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  80129a:	75 2c                	jne    8012c8 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	6a 07                	push   $0x7
  8012a1:	68 00 f0 bf ee       	push   $0xeebff000
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 af fd ff ff       	call   80105c <sys_page_alloc>
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	79 14                	jns    8012c8 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	68 aa 2c 80 00       	push   $0x802caa
  8012bc:	6a 22                	push   $0x22
  8012be:	68 c1 2c 80 00       	push   $0x802cc1
  8012c3:	e8 33 f3 ff ff       	call   8005fb <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  8012c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cb:	a3 b8 40 80 00       	mov    %eax,0x8040b8
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	68 fc 12 80 00       	push   $0x8012fc
  8012d8:	6a 00                	push   $0x0
  8012da:	e8 c8 fe ff ff       	call   8011a7 <sys_env_set_pgfault_upcall>
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	79 14                	jns    8012fa <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8012e6:	83 ec 04             	sub    $0x4,%esp
  8012e9:	68 d0 2c 80 00       	push   $0x802cd0
  8012ee:	6a 27                	push   $0x27
  8012f0:	68 c1 2c 80 00       	push   $0x802cc1
  8012f5:	e8 01 f3 ff ff       	call   8005fb <_panic>
    
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012fd:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  801302:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801304:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  801307:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  80130b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  801310:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801314:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801316:	83 c4 08             	add    $0x8,%esp
	popal
  801319:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  80131a:	83 c4 04             	add    $0x4,%esp
	popfl
  80131d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80131e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80131f:	c3                   	ret    

00801320 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	05 00 00 00 30       	add    $0x30000000,%eax
  80132b:	c1 e8 0c             	shr    $0xc,%eax
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	05 00 00 00 30       	add    $0x30000000,%eax
  80133b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801340:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801352:	89 c2                	mov    %eax,%edx
  801354:	c1 ea 16             	shr    $0x16,%edx
  801357:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135e:	f6 c2 01             	test   $0x1,%dl
  801361:	74 11                	je     801374 <fd_alloc+0x2d>
  801363:	89 c2                	mov    %eax,%edx
  801365:	c1 ea 0c             	shr    $0xc,%edx
  801368:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136f:	f6 c2 01             	test   $0x1,%dl
  801372:	75 09                	jne    80137d <fd_alloc+0x36>
			*fd_store = fd;
  801374:	89 01                	mov    %eax,(%ecx)
			return 0;
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
  80137b:	eb 17                	jmp    801394 <fd_alloc+0x4d>
  80137d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801382:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801387:	75 c9                	jne    801352 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801389:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80138f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80139c:	83 f8 1f             	cmp    $0x1f,%eax
  80139f:	77 36                	ja     8013d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013a1:	c1 e0 0c             	shl    $0xc,%eax
  8013a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	c1 ea 16             	shr    $0x16,%edx
  8013ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b5:	f6 c2 01             	test   $0x1,%dl
  8013b8:	74 24                	je     8013de <fd_lookup+0x48>
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	c1 ea 0c             	shr    $0xc,%edx
  8013bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	74 1a                	je     8013e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	eb 13                	jmp    8013ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013dc:	eb 0c                	jmp    8013ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e3:	eb 05                	jmp    8013ea <fd_lookup+0x54>
  8013e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f5:	ba 74 2d 80 00       	mov    $0x802d74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013fa:	eb 13                	jmp    80140f <dev_lookup+0x23>
  8013fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ff:	39 08                	cmp    %ecx,(%eax)
  801401:	75 0c                	jne    80140f <dev_lookup+0x23>
			*dev = devtab[i];
  801403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801406:	89 01                	mov    %eax,(%ecx)
			return 0;
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
  80140d:	eb 2e                	jmp    80143d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80140f:	8b 02                	mov    (%edx),%eax
  801411:	85 c0                	test   %eax,%eax
  801413:	75 e7                	jne    8013fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801415:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80141a:	8b 40 48             	mov    0x48(%eax),%eax
  80141d:	83 ec 04             	sub    $0x4,%esp
  801420:	51                   	push   %ecx
  801421:	50                   	push   %eax
  801422:	68 f4 2c 80 00       	push   $0x802cf4
  801427:	e8 a8 f2 ff ff       	call   8006d4 <cprintf>
	*dev = 0;
  80142c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 10             	sub    $0x10,%esp
  801447:	8b 75 08             	mov    0x8(%ebp),%esi
  80144a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801457:	c1 e8 0c             	shr    $0xc,%eax
  80145a:	50                   	push   %eax
  80145b:	e8 36 ff ff ff       	call   801396 <fd_lookup>
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 05                	js     80146c <fd_close+0x2d>
	    || fd != fd2)
  801467:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80146a:	74 0c                	je     801478 <fd_close+0x39>
		return (must_exist ? r : 0);
  80146c:	84 db                	test   %bl,%bl
  80146e:	ba 00 00 00 00       	mov    $0x0,%edx
  801473:	0f 44 c2             	cmove  %edx,%eax
  801476:	eb 41                	jmp    8014b9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	ff 36                	pushl  (%esi)
  801481:	e8 66 ff ff ff       	call   8013ec <dev_lookup>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 1a                	js     8014a9 <fd_close+0x6a>
		if (dev->dev_close)
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801495:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 0b                	je     8014a9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	56                   	push   %esi
  8014a2:	ff d0                	call   *%eax
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	56                   	push   %esi
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 2d fc ff ff       	call   8010e1 <sys_page_unmap>
	return r;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	89 d8                	mov    %ebx,%eax
}
  8014b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	ff 75 08             	pushl  0x8(%ebp)
  8014cd:	e8 c4 fe ff ff       	call   801396 <fd_lookup>
  8014d2:	83 c4 08             	add    $0x8,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 10                	js     8014e9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	6a 01                	push   $0x1
  8014de:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e1:	e8 59 ff ff ff       	call   80143f <fd_close>
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <close_all>:

void
close_all(void)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	53                   	push   %ebx
  8014fb:	e8 c0 ff ff ff       	call   8014c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801500:	83 c3 01             	add    $0x1,%ebx
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	83 fb 20             	cmp    $0x20,%ebx
  801509:	75 ec                	jne    8014f7 <close_all+0xc>
		close(i);
}
  80150b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	57                   	push   %edi
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 2c             	sub    $0x2c,%esp
  801519:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80151c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	ff 75 08             	pushl  0x8(%ebp)
  801523:	e8 6e fe ff ff       	call   801396 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	0f 88 c1 00 00 00    	js     8015f4 <dup+0xe4>
		return r;
	close(newfdnum);
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	56                   	push   %esi
  801537:	e8 84 ff ff ff       	call   8014c0 <close>

	newfd = INDEX2FD(newfdnum);
  80153c:	89 f3                	mov    %esi,%ebx
  80153e:	c1 e3 0c             	shl    $0xc,%ebx
  801541:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801547:	83 c4 04             	add    $0x4,%esp
  80154a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154d:	e8 de fd ff ff       	call   801330 <fd2data>
  801552:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801554:	89 1c 24             	mov    %ebx,(%esp)
  801557:	e8 d4 fd ff ff       	call   801330 <fd2data>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801562:	89 f8                	mov    %edi,%eax
  801564:	c1 e8 16             	shr    $0x16,%eax
  801567:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156e:	a8 01                	test   $0x1,%al
  801570:	74 37                	je     8015a9 <dup+0x99>
  801572:	89 f8                	mov    %edi,%eax
  801574:	c1 e8 0c             	shr    $0xc,%eax
  801577:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80157e:	f6 c2 01             	test   $0x1,%dl
  801581:	74 26                	je     8015a9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801583:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	25 07 0e 00 00       	and    $0xe07,%eax
  801592:	50                   	push   %eax
  801593:	ff 75 d4             	pushl  -0x2c(%ebp)
  801596:	6a 00                	push   $0x0
  801598:	57                   	push   %edi
  801599:	6a 00                	push   $0x0
  80159b:	e8 ff fa ff ff       	call   80109f <sys_page_map>
  8015a0:	89 c7                	mov    %eax,%edi
  8015a2:	83 c4 20             	add    $0x20,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 2e                	js     8015d7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ac:	89 d0                	mov    %edx,%eax
  8015ae:	c1 e8 0c             	shr    $0xc,%eax
  8015b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c0:	50                   	push   %eax
  8015c1:	53                   	push   %ebx
  8015c2:	6a 00                	push   $0x0
  8015c4:	52                   	push   %edx
  8015c5:	6a 00                	push   $0x0
  8015c7:	e8 d3 fa ff ff       	call   80109f <sys_page_map>
  8015cc:	89 c7                	mov    %eax,%edi
  8015ce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015d1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d3:	85 ff                	test   %edi,%edi
  8015d5:	79 1d                	jns    8015f4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	53                   	push   %ebx
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 ff fa ff ff       	call   8010e1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e2:	83 c4 08             	add    $0x8,%esp
  8015e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e8:	6a 00                	push   $0x0
  8015ea:	e8 f2 fa ff ff       	call   8010e1 <sys_page_unmap>
	return r;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	89 f8                	mov    %edi,%eax
}
  8015f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5e                   	pop    %esi
  8015f9:	5f                   	pop    %edi
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 14             	sub    $0x14,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	e8 86 fd ff ff       	call   801396 <fd_lookup>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	89 c2                	mov    %eax,%edx
  801615:	85 c0                	test   %eax,%eax
  801617:	78 6d                	js     801686 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	ff 30                	pushl  (%eax)
  801625:	e8 c2 fd ff ff       	call   8013ec <dev_lookup>
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 4c                	js     80167d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801631:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801634:	8b 42 08             	mov    0x8(%edx),%eax
  801637:	83 e0 03             	and    $0x3,%eax
  80163a:	83 f8 01             	cmp    $0x1,%eax
  80163d:	75 21                	jne    801660 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163f:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801644:	8b 40 48             	mov    0x48(%eax),%eax
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	53                   	push   %ebx
  80164b:	50                   	push   %eax
  80164c:	68 38 2d 80 00       	push   $0x802d38
  801651:	e8 7e f0 ff ff       	call   8006d4 <cprintf>
		return -E_INVAL;
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165e:	eb 26                	jmp    801686 <read+0x8a>
	}
	if (!dev->dev_read)
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	8b 40 08             	mov    0x8(%eax),%eax
  801666:	85 c0                	test   %eax,%eax
  801668:	74 17                	je     801681 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	ff 75 10             	pushl  0x10(%ebp)
  801670:	ff 75 0c             	pushl  0xc(%ebp)
  801673:	52                   	push   %edx
  801674:	ff d0                	call   *%eax
  801676:	89 c2                	mov    %eax,%edx
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 09                	jmp    801686 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	eb 05                	jmp    801686 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801681:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801686:	89 d0                	mov    %edx,%eax
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	57                   	push   %edi
  801691:	56                   	push   %esi
  801692:	53                   	push   %ebx
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	8b 7d 08             	mov    0x8(%ebp),%edi
  801699:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80169c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a1:	eb 21                	jmp    8016c4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	89 f0                	mov    %esi,%eax
  8016a8:	29 d8                	sub    %ebx,%eax
  8016aa:	50                   	push   %eax
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	03 45 0c             	add    0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	57                   	push   %edi
  8016b2:	e8 45 ff ff ff       	call   8015fc <read>
		if (m < 0)
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 10                	js     8016ce <readn+0x41>
			return m;
		if (m == 0)
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	74 0a                	je     8016cc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c2:	01 c3                	add    %eax,%ebx
  8016c4:	39 f3                	cmp    %esi,%ebx
  8016c6:	72 db                	jb     8016a3 <readn+0x16>
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	eb 02                	jmp    8016ce <readn+0x41>
  8016cc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5f                   	pop    %edi
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 14             	sub    $0x14,%esp
  8016dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	53                   	push   %ebx
  8016e5:	e8 ac fc ff ff       	call   801396 <fd_lookup>
  8016ea:	83 c4 08             	add    $0x8,%esp
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 68                	js     80175b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	ff 30                	pushl  (%eax)
  8016ff:	e8 e8 fc ff ff       	call   8013ec <dev_lookup>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 47                	js     801752 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801712:	75 21                	jne    801735 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801714:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801719:	8b 40 48             	mov    0x48(%eax),%eax
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	53                   	push   %ebx
  801720:	50                   	push   %eax
  801721:	68 54 2d 80 00       	push   $0x802d54
  801726:	e8 a9 ef ff ff       	call   8006d4 <cprintf>
		return -E_INVAL;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801733:	eb 26                	jmp    80175b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801735:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801738:	8b 52 0c             	mov    0xc(%edx),%edx
  80173b:	85 d2                	test   %edx,%edx
  80173d:	74 17                	je     801756 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	ff 75 10             	pushl  0x10(%ebp)
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	50                   	push   %eax
  801749:	ff d2                	call   *%edx
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	eb 09                	jmp    80175b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801752:	89 c2                	mov    %eax,%edx
  801754:	eb 05                	jmp    80175b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801756:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <seek>:

int
seek(int fdnum, off_t offset)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801768:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	ff 75 08             	pushl  0x8(%ebp)
  80176f:	e8 22 fc ff ff       	call   801396 <fd_lookup>
  801774:	83 c4 08             	add    $0x8,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 0e                	js     801789 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80177b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80177e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801781:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	53                   	push   %ebx
  80178f:	83 ec 14             	sub    $0x14,%esp
  801792:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801795:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	53                   	push   %ebx
  80179a:	e8 f7 fb ff ff       	call   801396 <fd_lookup>
  80179f:	83 c4 08             	add    $0x8,%esp
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 65                	js     80180d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ae:	50                   	push   %eax
  8017af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b2:	ff 30                	pushl  (%eax)
  8017b4:	e8 33 fc ff ff       	call   8013ec <dev_lookup>
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 44                	js     801804 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c7:	75 21                	jne    8017ea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c9:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ce:	8b 40 48             	mov    0x48(%eax),%eax
  8017d1:	83 ec 04             	sub    $0x4,%esp
  8017d4:	53                   	push   %ebx
  8017d5:	50                   	push   %eax
  8017d6:	68 14 2d 80 00       	push   $0x802d14
  8017db:	e8 f4 ee ff ff       	call   8006d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e8:	eb 23                	jmp    80180d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ed:	8b 52 18             	mov    0x18(%edx),%edx
  8017f0:	85 d2                	test   %edx,%edx
  8017f2:	74 14                	je     801808 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	50                   	push   %eax
  8017fb:	ff d2                	call   *%edx
  8017fd:	89 c2                	mov    %eax,%edx
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	eb 09                	jmp    80180d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801804:	89 c2                	mov    %eax,%edx
  801806:	eb 05                	jmp    80180d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801808:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80180d:	89 d0                	mov    %edx,%eax
  80180f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	53                   	push   %ebx
  801818:	83 ec 14             	sub    $0x14,%esp
  80181b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	ff 75 08             	pushl  0x8(%ebp)
  801825:	e8 6c fb ff ff       	call   801396 <fd_lookup>
  80182a:	83 c4 08             	add    $0x8,%esp
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 58                	js     80188b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801839:	50                   	push   %eax
  80183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183d:	ff 30                	pushl  (%eax)
  80183f:	e8 a8 fb ff ff       	call   8013ec <dev_lookup>
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	78 37                	js     801882 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80184b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801852:	74 32                	je     801886 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801854:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801857:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185e:	00 00 00 
	stat->st_isdir = 0;
  801861:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801868:	00 00 00 
	stat->st_dev = dev;
  80186b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	53                   	push   %ebx
  801875:	ff 75 f0             	pushl  -0x10(%ebp)
  801878:	ff 50 14             	call   *0x14(%eax)
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	eb 09                	jmp    80188b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801882:	89 c2                	mov    %eax,%edx
  801884:	eb 05                	jmp    80188b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801886:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	6a 00                	push   $0x0
  80189c:	ff 75 08             	pushl  0x8(%ebp)
  80189f:	e8 e7 01 00 00       	call   801a8b <open>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 1b                	js     8018c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ad:	83 ec 08             	sub    $0x8,%esp
  8018b0:	ff 75 0c             	pushl  0xc(%ebp)
  8018b3:	50                   	push   %eax
  8018b4:	e8 5b ff ff ff       	call   801814 <fstat>
  8018b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8018bb:	89 1c 24             	mov    %ebx,(%esp)
  8018be:	e8 fd fb ff ff       	call   8014c0 <close>
	return r;
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	89 f0                	mov    %esi,%eax
}
  8018c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	89 c6                	mov    %eax,%esi
  8018d6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d8:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018df:	75 12                	jne    8018f3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	6a 01                	push   $0x1
  8018e6:	e8 4b 0c 00 00       	call   802536 <ipc_find_env>
  8018eb:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018f0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f3:	6a 07                	push   $0x7
  8018f5:	68 00 50 80 00       	push   $0x805000
  8018fa:	56                   	push   %esi
  8018fb:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801901:	e8 dc 0b 00 00       	call   8024e2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801906:	83 c4 0c             	add    $0xc,%esp
  801909:	6a 00                	push   $0x0
  80190b:	53                   	push   %ebx
  80190c:	6a 00                	push   $0x0
  80190e:	e8 62 0b 00 00       	call   802475 <ipc_recv>
}
  801913:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 40 0c             	mov    0xc(%eax),%eax
  801926:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 02 00 00 00       	mov    $0x2,%eax
  80193d:	e8 8d ff ff ff       	call   8018cf <fsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	8b 40 0c             	mov    0xc(%eax),%eax
  801950:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801955:	ba 00 00 00 00       	mov    $0x0,%edx
  80195a:	b8 06 00 00 00       	mov    $0x6,%eax
  80195f:	e8 6b ff ff ff       	call   8018cf <fsipc>
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 04             	sub    $0x4,%esp
  80196d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	8b 40 0c             	mov    0xc(%eax),%eax
  801976:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 05 00 00 00       	mov    $0x5,%eax
  801985:	e8 45 ff ff ff       	call   8018cf <fsipc>
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 2c                	js     8019ba <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	68 00 50 80 00       	push   $0x805000
  801996:	53                   	push   %ebx
  801997:	e8 bd f2 ff ff       	call   800c59 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199c:	a1 80 50 80 00       	mov    0x805080,%eax
  8019a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a7:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 08             	sub    $0x8,%esp
  8019c6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8019c9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019ce:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8019d3:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019d6:	53                   	push   %ebx
  8019d7:	ff 75 0c             	pushl  0xc(%ebp)
  8019da:	68 08 50 80 00       	push   $0x805008
  8019df:	e8 07 f4 ff ff       	call   800deb <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ea:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8019ef:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ff:	e8 cb fe ff ff       	call   8018cf <fsipc>
	//panic("devfile_write not implemented");
}
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	8b 40 0c             	mov    0xc(%eax),%eax
  801a17:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a1c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
  801a27:	b8 03 00 00 00       	mov    $0x3,%eax
  801a2c:	e8 9e fe ff ff       	call   8018cf <fsipc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 4b                	js     801a82 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a37:	39 c6                	cmp    %eax,%esi
  801a39:	73 16                	jae    801a51 <devfile_read+0x48>
  801a3b:	68 88 2d 80 00       	push   $0x802d88
  801a40:	68 8f 2d 80 00       	push   $0x802d8f
  801a45:	6a 7c                	push   $0x7c
  801a47:	68 a4 2d 80 00       	push   $0x802da4
  801a4c:	e8 aa eb ff ff       	call   8005fb <_panic>
	assert(r <= PGSIZE);
  801a51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a56:	7e 16                	jle    801a6e <devfile_read+0x65>
  801a58:	68 af 2d 80 00       	push   $0x802daf
  801a5d:	68 8f 2d 80 00       	push   $0x802d8f
  801a62:	6a 7d                	push   $0x7d
  801a64:	68 a4 2d 80 00       	push   $0x802da4
  801a69:	e8 8d eb ff ff       	call   8005fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a6e:	83 ec 04             	sub    $0x4,%esp
  801a71:	50                   	push   %eax
  801a72:	68 00 50 80 00       	push   $0x805000
  801a77:	ff 75 0c             	pushl  0xc(%ebp)
  801a7a:	e8 6c f3 ff ff       	call   800deb <memmove>
	return r;
  801a7f:	83 c4 10             	add    $0x10,%esp
}
  801a82:	89 d8                	mov    %ebx,%eax
  801a84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 20             	sub    $0x20,%esp
  801a92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a95:	53                   	push   %ebx
  801a96:	e8 85 f1 ff ff       	call   800c20 <strlen>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa3:	7f 67                	jg     801b0c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	e8 96 f8 ff ff       	call   801347 <fd_alloc>
  801ab1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 57                	js     801b11 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	53                   	push   %ebx
  801abe:	68 00 50 80 00       	push   $0x805000
  801ac3:	e8 91 f1 ff ff       	call   800c59 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad8:	e8 f2 fd ff ff       	call   8018cf <fsipc>
  801add:	89 c3                	mov    %eax,%ebx
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	79 14                	jns    801afa <open+0x6f>
		fd_close(fd, 0);
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	6a 00                	push   $0x0
  801aeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801aee:	e8 4c f9 ff ff       	call   80143f <fd_close>
		return r;
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	89 da                	mov    %ebx,%edx
  801af8:	eb 17                	jmp    801b11 <open+0x86>
	}

	return fd2num(fd);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	ff 75 f4             	pushl  -0xc(%ebp)
  801b00:	e8 1b f8 ff ff       	call   801320 <fd2num>
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	eb 05                	jmp    801b11 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b0c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b11:	89 d0                	mov    %edx,%eax
  801b13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b16:	c9                   	leave  
  801b17:	c3                   	ret    

00801b18 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	b8 08 00 00 00       	mov    $0x8,%eax
  801b28:	e8 a2 fd ff ff       	call   8018cf <fsipc>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b35:	68 bb 2d 80 00       	push   $0x802dbb
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	e8 17 f1 ff ff       	call   800c59 <strcpy>
	return 0;
}
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	53                   	push   %ebx
  801b4d:	83 ec 10             	sub    $0x10,%esp
  801b50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b53:	53                   	push   %ebx
  801b54:	e8 16 0a 00 00       	call   80256f <pageref>
  801b59:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b5c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b61:	83 f8 01             	cmp    $0x1,%eax
  801b64:	75 10                	jne    801b76 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b66:	83 ec 0c             	sub    $0xc,%esp
  801b69:	ff 73 0c             	pushl  0xc(%ebx)
  801b6c:	e8 c0 02 00 00       	call   801e31 <nsipc_close>
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b76:	89 d0                	mov    %edx,%eax
  801b78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b83:	6a 00                	push   $0x0
  801b85:	ff 75 10             	pushl  0x10(%ebp)
  801b88:	ff 75 0c             	pushl  0xc(%ebp)
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	ff 70 0c             	pushl  0xc(%eax)
  801b91:	e8 78 03 00 00       	call   801f0e <nsipc_send>
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b9e:	6a 00                	push   $0x0
  801ba0:	ff 75 10             	pushl  0x10(%ebp)
  801ba3:	ff 75 0c             	pushl  0xc(%ebp)
  801ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba9:	ff 70 0c             	pushl  0xc(%eax)
  801bac:	e8 f1 02 00 00       	call   801ea2 <nsipc_recv>
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bb9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bbc:	52                   	push   %edx
  801bbd:	50                   	push   %eax
  801bbe:	e8 d3 f7 ff ff       	call   801396 <fd_lookup>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 17                	js     801be1 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801bd3:	39 08                	cmp    %ecx,(%eax)
  801bd5:	75 05                	jne    801bdc <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bd7:	8b 40 0c             	mov    0xc(%eax),%eax
  801bda:	eb 05                	jmp    801be1 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bdc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	83 ec 1c             	sub    $0x1c,%esp
  801beb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf0:	50                   	push   %eax
  801bf1:	e8 51 f7 ff ff       	call   801347 <fd_alloc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 1b                	js     801c1a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bff:	83 ec 04             	sub    $0x4,%esp
  801c02:	68 07 04 00 00       	push   $0x407
  801c07:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0a:	6a 00                	push   $0x0
  801c0c:	e8 4b f4 ff ff       	call   80105c <sys_page_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	79 10                	jns    801c2a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	56                   	push   %esi
  801c1e:	e8 0e 02 00 00       	call   801e31 <nsipc_close>
		return r;
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	eb 24                	jmp    801c4e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c2a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c3f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	50                   	push   %eax
  801c46:	e8 d5 f6 ff ff       	call   801320 <fd2num>
  801c4b:	83 c4 10             	add    $0x10,%esp
}
  801c4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	e8 50 ff ff ff       	call   801bb3 <fd2sockid>
		return r;
  801c63:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 1f                	js     801c88 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	ff 75 10             	pushl  0x10(%ebp)
  801c6f:	ff 75 0c             	pushl  0xc(%ebp)
  801c72:	50                   	push   %eax
  801c73:	e8 12 01 00 00       	call   801d8a <nsipc_accept>
  801c78:	83 c4 10             	add    $0x10,%esp
		return r;
  801c7b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 07                	js     801c88 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c81:	e8 5d ff ff ff       	call   801be3 <alloc_sockfd>
  801c86:	89 c1                	mov    %eax,%ecx
}
  801c88:	89 c8                	mov    %ecx,%eax
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	e8 19 ff ff ff       	call   801bb3 <fd2sockid>
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	78 12                	js     801cb0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c9e:	83 ec 04             	sub    $0x4,%esp
  801ca1:	ff 75 10             	pushl  0x10(%ebp)
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	50                   	push   %eax
  801ca8:	e8 2d 01 00 00       	call   801dda <nsipc_bind>
  801cad:	83 c4 10             	add    $0x10,%esp
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <shutdown>:

int
shutdown(int s, int how)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	e8 f3 fe ff ff       	call   801bb3 <fd2sockid>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 0f                	js     801cd3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cc4:	83 ec 08             	sub    $0x8,%esp
  801cc7:	ff 75 0c             	pushl  0xc(%ebp)
  801cca:	50                   	push   %eax
  801ccb:	e8 3f 01 00 00       	call   801e0f <nsipc_shutdown>
  801cd0:	83 c4 10             	add    $0x10,%esp
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	e8 d0 fe ff ff       	call   801bb3 <fd2sockid>
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 12                	js     801cf9 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	ff 75 10             	pushl  0x10(%ebp)
  801ced:	ff 75 0c             	pushl  0xc(%ebp)
  801cf0:	50                   	push   %eax
  801cf1:	e8 55 01 00 00       	call   801e4b <nsipc_connect>
  801cf6:	83 c4 10             	add    $0x10,%esp
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <listen>:

int
listen(int s, int backlog)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	e8 aa fe ff ff       	call   801bb3 <fd2sockid>
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 0f                	js     801d1c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d0d:	83 ec 08             	sub    $0x8,%esp
  801d10:	ff 75 0c             	pushl  0xc(%ebp)
  801d13:	50                   	push   %eax
  801d14:	e8 67 01 00 00       	call   801e80 <nsipc_listen>
  801d19:	83 c4 10             	add    $0x10,%esp
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d24:	ff 75 10             	pushl  0x10(%ebp)
  801d27:	ff 75 0c             	pushl  0xc(%ebp)
  801d2a:	ff 75 08             	pushl  0x8(%ebp)
  801d2d:	e8 3a 02 00 00       	call   801f6c <nsipc_socket>
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 05                	js     801d3e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d39:	e8 a5 fe ff ff       	call   801be3 <alloc_sockfd>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	53                   	push   %ebx
  801d44:	83 ec 04             	sub    $0x4,%esp
  801d47:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d49:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801d50:	75 12                	jne    801d64 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	6a 02                	push   $0x2
  801d57:	e8 da 07 00 00       	call   802536 <ipc_find_env>
  801d5c:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  801d61:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d64:	6a 07                	push   $0x7
  801d66:	68 00 60 80 00       	push   $0x806000
  801d6b:	53                   	push   %ebx
  801d6c:	ff 35 b0 40 80 00    	pushl  0x8040b0
  801d72:	e8 6b 07 00 00       	call   8024e2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d77:	83 c4 0c             	add    $0xc,%esp
  801d7a:	6a 00                	push   $0x0
  801d7c:	6a 00                	push   $0x0
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 f0 06 00 00       	call   802475 <ipc_recv>
}
  801d85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	56                   	push   %esi
  801d8e:	53                   	push   %ebx
  801d8f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d9a:	8b 06                	mov    (%esi),%eax
  801d9c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801da1:	b8 01 00 00 00       	mov    $0x1,%eax
  801da6:	e8 95 ff ff ff       	call   801d40 <nsipc>
  801dab:	89 c3                	mov    %eax,%ebx
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 20                	js     801dd1 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801db1:	83 ec 04             	sub    $0x4,%esp
  801db4:	ff 35 10 60 80 00    	pushl  0x806010
  801dba:	68 00 60 80 00       	push   $0x806000
  801dbf:	ff 75 0c             	pushl  0xc(%ebp)
  801dc2:	e8 24 f0 ff ff       	call   800deb <memmove>
		*addrlen = ret->ret_addrlen;
  801dc7:	a1 10 60 80 00       	mov    0x806010,%eax
  801dcc:	89 06                	mov    %eax,(%esi)
  801dce:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801dd1:	89 d8                	mov    %ebx,%eax
  801dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd6:	5b                   	pop    %ebx
  801dd7:	5e                   	pop    %esi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    

00801dda <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801de4:	8b 45 08             	mov    0x8(%ebp),%eax
  801de7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dec:	53                   	push   %ebx
  801ded:	ff 75 0c             	pushl  0xc(%ebp)
  801df0:	68 04 60 80 00       	push   $0x806004
  801df5:	e8 f1 ef ff ff       	call   800deb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dfa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e00:	b8 02 00 00 00       	mov    $0x2,%eax
  801e05:	e8 36 ff ff ff       	call   801d40 <nsipc>
}
  801e0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
  801e18:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e20:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e25:	b8 03 00 00 00       	mov    $0x3,%eax
  801e2a:	e8 11 ff ff ff       	call   801d40 <nsipc>
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <nsipc_close>:

int
nsipc_close(int s)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e3f:	b8 04 00 00 00       	mov    $0x4,%eax
  801e44:	e8 f7 fe ff ff       	call   801d40 <nsipc>
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	53                   	push   %ebx
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e55:	8b 45 08             	mov    0x8(%ebp),%eax
  801e58:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e5d:	53                   	push   %ebx
  801e5e:	ff 75 0c             	pushl  0xc(%ebp)
  801e61:	68 04 60 80 00       	push   $0x806004
  801e66:	e8 80 ef ff ff       	call   800deb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e6b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e71:	b8 05 00 00 00       	mov    $0x5,%eax
  801e76:	e8 c5 fe ff ff       	call   801d40 <nsipc>
}
  801e7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e86:	8b 45 08             	mov    0x8(%ebp),%eax
  801e89:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e91:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e96:	b8 06 00 00 00       	mov    $0x6,%eax
  801e9b:	e8 a0 fe ff ff       	call   801d40 <nsipc>
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ead:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801eb2:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebb:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ec0:	b8 07 00 00 00       	mov    $0x7,%eax
  801ec5:	e8 76 fe ff ff       	call   801d40 <nsipc>
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 35                	js     801f05 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ed0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ed5:	7f 04                	jg     801edb <nsipc_recv+0x39>
  801ed7:	39 c6                	cmp    %eax,%esi
  801ed9:	7d 16                	jge    801ef1 <nsipc_recv+0x4f>
  801edb:	68 c7 2d 80 00       	push   $0x802dc7
  801ee0:	68 8f 2d 80 00       	push   $0x802d8f
  801ee5:	6a 62                	push   $0x62
  801ee7:	68 dc 2d 80 00       	push   $0x802ddc
  801eec:	e8 0a e7 ff ff       	call   8005fb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	50                   	push   %eax
  801ef5:	68 00 60 80 00       	push   $0x806000
  801efa:	ff 75 0c             	pushl  0xc(%ebp)
  801efd:	e8 e9 ee ff ff       	call   800deb <memmove>
  801f02:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f05:	89 d8                	mov    %ebx,%eax
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	53                   	push   %ebx
  801f12:	83 ec 04             	sub    $0x4,%esp
  801f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f20:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f26:	7e 16                	jle    801f3e <nsipc_send+0x30>
  801f28:	68 e8 2d 80 00       	push   $0x802de8
  801f2d:	68 8f 2d 80 00       	push   $0x802d8f
  801f32:	6a 6d                	push   $0x6d
  801f34:	68 dc 2d 80 00       	push   $0x802ddc
  801f39:	e8 bd e6 ff ff       	call   8005fb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f3e:	83 ec 04             	sub    $0x4,%esp
  801f41:	53                   	push   %ebx
  801f42:	ff 75 0c             	pushl  0xc(%ebp)
  801f45:	68 0c 60 80 00       	push   $0x80600c
  801f4a:	e8 9c ee ff ff       	call   800deb <memmove>
	nsipcbuf.send.req_size = size;
  801f4f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f55:	8b 45 14             	mov    0x14(%ebp),%eax
  801f58:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f5d:	b8 08 00 00 00       	mov    $0x8,%eax
  801f62:	e8 d9 fd ff ff       	call   801d40 <nsipc>
}
  801f67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f72:	8b 45 08             	mov    0x8(%ebp),%eax
  801f75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f82:	8b 45 10             	mov    0x10(%ebp),%eax
  801f85:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f8a:	b8 09 00 00 00       	mov    $0x9,%eax
  801f8f:	e8 ac fd ff ff       	call   801d40 <nsipc>
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f9e:	83 ec 0c             	sub    $0xc,%esp
  801fa1:	ff 75 08             	pushl  0x8(%ebp)
  801fa4:	e8 87 f3 ff ff       	call   801330 <fd2data>
  801fa9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fab:	83 c4 08             	add    $0x8,%esp
  801fae:	68 f4 2d 80 00       	push   $0x802df4
  801fb3:	53                   	push   %ebx
  801fb4:	e8 a0 ec ff ff       	call   800c59 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fb9:	8b 46 04             	mov    0x4(%esi),%eax
  801fbc:	2b 06                	sub    (%esi),%eax
  801fbe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fc4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fcb:	00 00 00 
	stat->st_dev = &devpipe;
  801fce:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801fd5:	30 80 00 
	return 0;
}
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe0:	5b                   	pop    %ebx
  801fe1:	5e                   	pop    %esi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 0c             	sub    $0xc,%esp
  801feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fee:	53                   	push   %ebx
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 eb f0 ff ff       	call   8010e1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ff6:	89 1c 24             	mov    %ebx,(%esp)
  801ff9:	e8 32 f3 ff ff       	call   801330 <fd2data>
  801ffe:	83 c4 08             	add    $0x8,%esp
  802001:	50                   	push   %eax
  802002:	6a 00                	push   $0x0
  802004:	e8 d8 f0 ff ff       	call   8010e1 <sys_page_unmap>
}
  802009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80201a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80201c:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802021:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802024:	83 ec 0c             	sub    $0xc,%esp
  802027:	ff 75 e0             	pushl  -0x20(%ebp)
  80202a:	e8 40 05 00 00       	call   80256f <pageref>
  80202f:	89 c3                	mov    %eax,%ebx
  802031:	89 3c 24             	mov    %edi,(%esp)
  802034:	e8 36 05 00 00       	call   80256f <pageref>
  802039:	83 c4 10             	add    $0x10,%esp
  80203c:	39 c3                	cmp    %eax,%ebx
  80203e:	0f 94 c1             	sete   %cl
  802041:	0f b6 c9             	movzbl %cl,%ecx
  802044:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802047:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  80204d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	74 1b                	je     80206f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802054:	39 c3                	cmp    %eax,%ebx
  802056:	75 c4                	jne    80201c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802058:	8b 42 58             	mov    0x58(%edx),%eax
  80205b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80205e:	50                   	push   %eax
  80205f:	56                   	push   %esi
  802060:	68 fb 2d 80 00       	push   $0x802dfb
  802065:	e8 6a e6 ff ff       	call   8006d4 <cprintf>
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	eb ad                	jmp    80201c <_pipeisclosed+0xe>
	}
}
  80206f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802072:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5f                   	pop    %edi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	57                   	push   %edi
  80207e:	56                   	push   %esi
  80207f:	53                   	push   %ebx
  802080:	83 ec 28             	sub    $0x28,%esp
  802083:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802086:	56                   	push   %esi
  802087:	e8 a4 f2 ff ff       	call   801330 <fd2data>
  80208c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80208e:	83 c4 10             	add    $0x10,%esp
  802091:	bf 00 00 00 00       	mov    $0x0,%edi
  802096:	eb 4b                	jmp    8020e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802098:	89 da                	mov    %ebx,%edx
  80209a:	89 f0                	mov    %esi,%eax
  80209c:	e8 6d ff ff ff       	call   80200e <_pipeisclosed>
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	75 48                	jne    8020ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020a5:	e8 93 ef ff ff       	call   80103d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8020ad:	8b 0b                	mov    (%ebx),%ecx
  8020af:	8d 51 20             	lea    0x20(%ecx),%edx
  8020b2:	39 d0                	cmp    %edx,%eax
  8020b4:	73 e2                	jae    802098 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020c0:	89 c2                	mov    %eax,%edx
  8020c2:	c1 fa 1f             	sar    $0x1f,%edx
  8020c5:	89 d1                	mov    %edx,%ecx
  8020c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8020ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020cd:	83 e2 1f             	and    $0x1f,%edx
  8020d0:	29 ca                	sub    %ecx,%edx
  8020d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020da:	83 c0 01             	add    $0x1,%eax
  8020dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e0:	83 c7 01             	add    $0x1,%edi
  8020e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020e6:	75 c2                	jne    8020aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020eb:	eb 05                	jmp    8020f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5f                   	pop    %edi
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    

008020fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	57                   	push   %edi
  8020fe:	56                   	push   %esi
  8020ff:	53                   	push   %ebx
  802100:	83 ec 18             	sub    $0x18,%esp
  802103:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802106:	57                   	push   %edi
  802107:	e8 24 f2 ff ff       	call   801330 <fd2data>
  80210c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	bb 00 00 00 00       	mov    $0x0,%ebx
  802116:	eb 3d                	jmp    802155 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802118:	85 db                	test   %ebx,%ebx
  80211a:	74 04                	je     802120 <devpipe_read+0x26>
				return i;
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	eb 44                	jmp    802164 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802120:	89 f2                	mov    %esi,%edx
  802122:	89 f8                	mov    %edi,%eax
  802124:	e8 e5 fe ff ff       	call   80200e <_pipeisclosed>
  802129:	85 c0                	test   %eax,%eax
  80212b:	75 32                	jne    80215f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80212d:	e8 0b ef ff ff       	call   80103d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802132:	8b 06                	mov    (%esi),%eax
  802134:	3b 46 04             	cmp    0x4(%esi),%eax
  802137:	74 df                	je     802118 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802139:	99                   	cltd   
  80213a:	c1 ea 1b             	shr    $0x1b,%edx
  80213d:	01 d0                	add    %edx,%eax
  80213f:	83 e0 1f             	and    $0x1f,%eax
  802142:	29 d0                	sub    %edx,%eax
  802144:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80214c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80214f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802152:	83 c3 01             	add    $0x1,%ebx
  802155:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802158:	75 d8                	jne    802132 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80215a:	8b 45 10             	mov    0x10(%ebp),%eax
  80215d:	eb 05                	jmp    802164 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80215f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	56                   	push   %esi
  802170:	53                   	push   %ebx
  802171:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802177:	50                   	push   %eax
  802178:	e8 ca f1 ff ff       	call   801347 <fd_alloc>
  80217d:	83 c4 10             	add    $0x10,%esp
  802180:	89 c2                	mov    %eax,%edx
  802182:	85 c0                	test   %eax,%eax
  802184:	0f 88 2c 01 00 00    	js     8022b6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218a:	83 ec 04             	sub    $0x4,%esp
  80218d:	68 07 04 00 00       	push   $0x407
  802192:	ff 75 f4             	pushl  -0xc(%ebp)
  802195:	6a 00                	push   $0x0
  802197:	e8 c0 ee ff ff       	call   80105c <sys_page_alloc>
  80219c:	83 c4 10             	add    $0x10,%esp
  80219f:	89 c2                	mov    %eax,%edx
  8021a1:	85 c0                	test   %eax,%eax
  8021a3:	0f 88 0d 01 00 00    	js     8022b6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021a9:	83 ec 0c             	sub    $0xc,%esp
  8021ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021af:	50                   	push   %eax
  8021b0:	e8 92 f1 ff ff       	call   801347 <fd_alloc>
  8021b5:	89 c3                	mov    %eax,%ebx
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	0f 88 e2 00 00 00    	js     8022a4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c2:	83 ec 04             	sub    $0x4,%esp
  8021c5:	68 07 04 00 00       	push   $0x407
  8021ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 88 ee ff ff       	call   80105c <sys_page_alloc>
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	0f 88 c3 00 00 00    	js     8022a4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021e1:	83 ec 0c             	sub    $0xc,%esp
  8021e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e7:	e8 44 f1 ff ff       	call   801330 <fd2data>
  8021ec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ee:	83 c4 0c             	add    $0xc,%esp
  8021f1:	68 07 04 00 00       	push   $0x407
  8021f6:	50                   	push   %eax
  8021f7:	6a 00                	push   $0x0
  8021f9:	e8 5e ee ff ff       	call   80105c <sys_page_alloc>
  8021fe:	89 c3                	mov    %eax,%ebx
  802200:	83 c4 10             	add    $0x10,%esp
  802203:	85 c0                	test   %eax,%eax
  802205:	0f 88 89 00 00 00    	js     802294 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80220b:	83 ec 0c             	sub    $0xc,%esp
  80220e:	ff 75 f0             	pushl  -0x10(%ebp)
  802211:	e8 1a f1 ff ff       	call   801330 <fd2data>
  802216:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80221d:	50                   	push   %eax
  80221e:	6a 00                	push   $0x0
  802220:	56                   	push   %esi
  802221:	6a 00                	push   $0x0
  802223:	e8 77 ee ff ff       	call   80109f <sys_page_map>
  802228:	89 c3                	mov    %eax,%ebx
  80222a:	83 c4 20             	add    $0x20,%esp
  80222d:	85 c0                	test   %eax,%eax
  80222f:	78 55                	js     802286 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802231:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802237:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80223c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802246:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80224c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80224f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802254:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80225b:	83 ec 0c             	sub    $0xc,%esp
  80225e:	ff 75 f4             	pushl  -0xc(%ebp)
  802261:	e8 ba f0 ff ff       	call   801320 <fd2num>
  802266:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802269:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80226b:	83 c4 04             	add    $0x4,%esp
  80226e:	ff 75 f0             	pushl  -0x10(%ebp)
  802271:	e8 aa f0 ff ff       	call   801320 <fd2num>
  802276:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802279:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	ba 00 00 00 00       	mov    $0x0,%edx
  802284:	eb 30                	jmp    8022b6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802286:	83 ec 08             	sub    $0x8,%esp
  802289:	56                   	push   %esi
  80228a:	6a 00                	push   $0x0
  80228c:	e8 50 ee ff ff       	call   8010e1 <sys_page_unmap>
  802291:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802294:	83 ec 08             	sub    $0x8,%esp
  802297:	ff 75 f0             	pushl  -0x10(%ebp)
  80229a:	6a 00                	push   $0x0
  80229c:	e8 40 ee ff ff       	call   8010e1 <sys_page_unmap>
  8022a1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022a4:	83 ec 08             	sub    $0x8,%esp
  8022a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8022aa:	6a 00                	push   $0x0
  8022ac:	e8 30 ee ff ff       	call   8010e1 <sys_page_unmap>
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022b6:	89 d0                	mov    %edx,%eax
  8022b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bb:	5b                   	pop    %ebx
  8022bc:	5e                   	pop    %esi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c8:	50                   	push   %eax
  8022c9:	ff 75 08             	pushl  0x8(%ebp)
  8022cc:	e8 c5 f0 ff ff       	call   801396 <fd_lookup>
  8022d1:	83 c4 10             	add    $0x10,%esp
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 18                	js     8022f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022d8:	83 ec 0c             	sub    $0xc,%esp
  8022db:	ff 75 f4             	pushl  -0xc(%ebp)
  8022de:	e8 4d f0 ff ff       	call   801330 <fd2data>
	return _pipeisclosed(fd, p);
  8022e3:	89 c2                	mov    %eax,%edx
  8022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e8:	e8 21 fd ff ff       	call   80200e <_pipeisclosed>
  8022ed:	83 c4 10             	add    $0x10,%esp
}
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    

008022f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    

008022fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802302:	68 13 2e 80 00       	push   $0x802e13
  802307:	ff 75 0c             	pushl  0xc(%ebp)
  80230a:	e8 4a e9 ff ff       	call   800c59 <strcpy>
	return 0;
}
  80230f:	b8 00 00 00 00       	mov    $0x0,%eax
  802314:	c9                   	leave  
  802315:	c3                   	ret    

00802316 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	57                   	push   %edi
  80231a:	56                   	push   %esi
  80231b:	53                   	push   %ebx
  80231c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802322:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802327:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232d:	eb 2d                	jmp    80235c <devcons_write+0x46>
		m = n - tot;
  80232f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802332:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802334:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802337:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80233c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80233f:	83 ec 04             	sub    $0x4,%esp
  802342:	53                   	push   %ebx
  802343:	03 45 0c             	add    0xc(%ebp),%eax
  802346:	50                   	push   %eax
  802347:	57                   	push   %edi
  802348:	e8 9e ea ff ff       	call   800deb <memmove>
		sys_cputs(buf, m);
  80234d:	83 c4 08             	add    $0x8,%esp
  802350:	53                   	push   %ebx
  802351:	57                   	push   %edi
  802352:	e8 49 ec ff ff       	call   800fa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802357:	01 de                	add    %ebx,%esi
  802359:	83 c4 10             	add    $0x10,%esp
  80235c:	89 f0                	mov    %esi,%eax
  80235e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802361:	72 cc                	jb     80232f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802366:	5b                   	pop    %ebx
  802367:	5e                   	pop    %esi
  802368:	5f                   	pop    %edi
  802369:	5d                   	pop    %ebp
  80236a:	c3                   	ret    

0080236b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
  80236e:	83 ec 08             	sub    $0x8,%esp
  802371:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802376:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80237a:	74 2a                	je     8023a6 <devcons_read+0x3b>
  80237c:	eb 05                	jmp    802383 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80237e:	e8 ba ec ff ff       	call   80103d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802383:	e8 36 ec ff ff       	call   800fbe <sys_cgetc>
  802388:	85 c0                	test   %eax,%eax
  80238a:	74 f2                	je     80237e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80238c:	85 c0                	test   %eax,%eax
  80238e:	78 16                	js     8023a6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802390:	83 f8 04             	cmp    $0x4,%eax
  802393:	74 0c                	je     8023a1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802395:	8b 55 0c             	mov    0xc(%ebp),%edx
  802398:	88 02                	mov    %al,(%edx)
	return 1;
  80239a:	b8 01 00 00 00       	mov    $0x1,%eax
  80239f:	eb 05                	jmp    8023a6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023b4:	6a 01                	push   $0x1
  8023b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023b9:	50                   	push   %eax
  8023ba:	e8 e1 eb ff ff       	call   800fa0 <sys_cputs>
}
  8023bf:	83 c4 10             	add    $0x10,%esp
  8023c2:	c9                   	leave  
  8023c3:	c3                   	ret    

008023c4 <getchar>:

int
getchar(void)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ca:	6a 01                	push   $0x1
  8023cc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023cf:	50                   	push   %eax
  8023d0:	6a 00                	push   $0x0
  8023d2:	e8 25 f2 ff ff       	call   8015fc <read>
	if (r < 0)
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 0f                	js     8023ed <getchar+0x29>
		return r;
	if (r < 1)
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	7e 06                	jle    8023e8 <getchar+0x24>
		return -E_EOF;
	return c;
  8023e2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023e6:	eb 05                	jmp    8023ed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023e8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ed:	c9                   	leave  
  8023ee:	c3                   	ret    

008023ef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f8:	50                   	push   %eax
  8023f9:	ff 75 08             	pushl  0x8(%ebp)
  8023fc:	e8 95 ef ff ff       	call   801396 <fd_lookup>
  802401:	83 c4 10             	add    $0x10,%esp
  802404:	85 c0                	test   %eax,%eax
  802406:	78 11                	js     802419 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802411:	39 10                	cmp    %edx,(%eax)
  802413:	0f 94 c0             	sete   %al
  802416:	0f b6 c0             	movzbl %al,%eax
}
  802419:	c9                   	leave  
  80241a:	c3                   	ret    

0080241b <opencons>:

int
opencons(void)
{
  80241b:	55                   	push   %ebp
  80241c:	89 e5                	mov    %esp,%ebp
  80241e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802424:	50                   	push   %eax
  802425:	e8 1d ef ff ff       	call   801347 <fd_alloc>
  80242a:	83 c4 10             	add    $0x10,%esp
		return r;
  80242d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80242f:	85 c0                	test   %eax,%eax
  802431:	78 3e                	js     802471 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802433:	83 ec 04             	sub    $0x4,%esp
  802436:	68 07 04 00 00       	push   $0x407
  80243b:	ff 75 f4             	pushl  -0xc(%ebp)
  80243e:	6a 00                	push   $0x0
  802440:	e8 17 ec ff ff       	call   80105c <sys_page_alloc>
  802445:	83 c4 10             	add    $0x10,%esp
		return r;
  802448:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 23                	js     802471 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80244e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802457:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802463:	83 ec 0c             	sub    $0xc,%esp
  802466:	50                   	push   %eax
  802467:	e8 b4 ee ff ff       	call   801320 <fd2num>
  80246c:	89 c2                	mov    %eax,%edx
  80246e:	83 c4 10             	add    $0x10,%esp
}
  802471:	89 d0                	mov    %edx,%eax
  802473:	c9                   	leave  
  802474:	c3                   	ret    

00802475 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802475:	55                   	push   %ebp
  802476:	89 e5                	mov    %esp,%ebp
  802478:	56                   	push   %esi
  802479:	53                   	push   %ebx
  80247a:	8b 75 08             	mov    0x8(%ebp),%esi
  80247d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802480:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802483:	85 c0                	test   %eax,%eax
  802485:	74 0e                	je     802495 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802487:	83 ec 0c             	sub    $0xc,%esp
  80248a:	50                   	push   %eax
  80248b:	e8 7c ed ff ff       	call   80120c <sys_ipc_recv>
  802490:	83 c4 10             	add    $0x10,%esp
  802493:	eb 10                	jmp    8024a5 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802495:	83 ec 0c             	sub    $0xc,%esp
  802498:	68 00 00 00 f0       	push   $0xf0000000
  80249d:	e8 6a ed ff ff       	call   80120c <sys_ipc_recv>
  8024a2:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	74 0e                	je     8024b7 <ipc_recv+0x42>
    	*from_env_store = 0;
  8024a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8024af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8024b5:	eb 24                	jmp    8024db <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8024b7:	85 f6                	test   %esi,%esi
  8024b9:	74 0a                	je     8024c5 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8024bb:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024c0:	8b 40 74             	mov    0x74(%eax),%eax
  8024c3:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8024c5:	85 db                	test   %ebx,%ebx
  8024c7:	74 0a                	je     8024d3 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8024c9:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024ce:	8b 40 78             	mov    0x78(%eax),%eax
  8024d1:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8024d3:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024d8:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8024db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024de:	5b                   	pop    %ebx
  8024df:	5e                   	pop    %esi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    

008024e2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e2:	55                   	push   %ebp
  8024e3:	89 e5                	mov    %esp,%ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	83 ec 0c             	sub    $0xc,%esp
  8024eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8024f4:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8024f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024fb:	0f 44 d8             	cmove  %eax,%ebx
  8024fe:	eb 1c                	jmp    80251c <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802500:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802503:	74 12                	je     802517 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802505:	50                   	push   %eax
  802506:	68 1f 2e 80 00       	push   $0x802e1f
  80250b:	6a 4b                	push   $0x4b
  80250d:	68 37 2e 80 00       	push   $0x802e37
  802512:	e8 e4 e0 ff ff       	call   8005fb <_panic>
        }	
        sys_yield();
  802517:	e8 21 eb ff ff       	call   80103d <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80251c:	ff 75 14             	pushl  0x14(%ebp)
  80251f:	53                   	push   %ebx
  802520:	56                   	push   %esi
  802521:	57                   	push   %edi
  802522:	e8 c2 ec ff ff       	call   8011e9 <sys_ipc_try_send>
  802527:	83 c4 10             	add    $0x10,%esp
  80252a:	85 c0                	test   %eax,%eax
  80252c:	75 d2                	jne    802500 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80252e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    

00802536 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802536:	55                   	push   %ebp
  802537:	89 e5                	mov    %esp,%ebp
  802539:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80253c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802541:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802544:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80254a:	8b 52 50             	mov    0x50(%edx),%edx
  80254d:	39 ca                	cmp    %ecx,%edx
  80254f:	75 0d                	jne    80255e <ipc_find_env+0x28>
			return envs[i].env_id;
  802551:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802554:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802559:	8b 40 48             	mov    0x48(%eax),%eax
  80255c:	eb 0f                	jmp    80256d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80255e:	83 c0 01             	add    $0x1,%eax
  802561:	3d 00 04 00 00       	cmp    $0x400,%eax
  802566:	75 d9                	jne    802541 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802568:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    

0080256f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802575:	89 d0                	mov    %edx,%eax
  802577:	c1 e8 16             	shr    $0x16,%eax
  80257a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802581:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802586:	f6 c1 01             	test   $0x1,%cl
  802589:	74 1d                	je     8025a8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258b:	c1 ea 0c             	shr    $0xc,%edx
  80258e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802595:	f6 c2 01             	test   $0x1,%dl
  802598:	74 0e                	je     8025a8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259a:	c1 ea 0c             	shr    $0xc,%edx
  80259d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a4:	ef 
  8025a5:	0f b7 c0             	movzwl %ax,%eax
}
  8025a8:	5d                   	pop    %ebp
  8025a9:	c3                   	ret    
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
