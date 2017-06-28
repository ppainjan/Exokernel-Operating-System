
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 1c 0c 00 00       	call   800c59 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 a0 	movl   $0x8027a0,0x803000
  800046:	27 80 00 

	output_envid = fork();
  800049:	e8 74 0f 00 00       	call   800fc2 <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 ab 27 80 00       	push   $0x8027ab
  80005f:	6a 16                	push   $0x16
  800061:	68 b9 27 80 00       	push   $0x8027b9
  800066:	e8 cb 01 00 00       	call   800236 <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 40 01 00 00       	call   8001bd <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 01 0c 00 00       	call   800c97 <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 ca 27 80 00       	push   $0x8027ca
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 b9 27 80 00       	push   $0x8027b9
  8000aa:	e8 87 01 00 00       	call   800236 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 dd 27 80 00       	push   $0x8027dd
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 7d 07 00 00       	call   800841 <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 e9 27 80 00       	push   $0x8027e9
  8000d2:	e8 38 02 00 00       	call   80030f <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 59 11 00 00       	call   801244 <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 22 0c 00 00       	call   800d1c <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 69 0b 00 00       	call   800c78 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 5c 0d 00 00       	call   800e88 <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 01 	movl   $0x802801,0x803000
  800138:	28 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 33 0b 00 00       	call   800c78 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 3e 0d 00 00       	call   800e88 <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 0a 28 80 00       	push   $0x80280a
  80015e:	6a 0f                	push   $0xf
  800160:	68 1c 28 80 00       	push   $0x80281c
  800165:	e8 cc 00 00 00       	call   800236 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 ce 10 00 00       	call   801244 <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 51 10 00 00       	call   8011d7 <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 28 28 80 00       	push   $0x802828
  80019b:	e8 6f 01 00 00       	call   80030f <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 de 0c 00 00       	call   800e88 <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  8001b1:	c7 05 00 30 80 00 63 	movl   $0x802863,0x803000
  8001b8:	28 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  8001c0:	c7 05 00 30 80 00 6c 	movl   $0x80286c,0x803000
  8001c7:	28 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001d7:	c7 05 0c 40 80 00 00 	movl   $0x0,0x80400c
  8001de:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 73 0a 00 00       	call   800c59 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x37>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 75 12 00 00       	call   80149c <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 e7 09 00 00       	call   800c18 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 10 0a 00 00       	call   800c59 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 80 28 80 00       	push   $0x802880
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 fa 2b 80 00 	movl   $0x802bfa,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 2f 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 d4 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 89 21 00 00       	call   802500 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 76 22 00 00       	call   802630 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 a3 28 80 00 	movsbl 0x8028a3(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 89 03 00 00    	je     8007eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 1a 03 00 00    	ja     8007d0 <vprintfmt+0x38a>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 bb 28 80 00       	push   $0x8028bb
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 f1 2d 80 00       	push   $0x802df1
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 b4 28 80 00       	mov    $0x8028b4,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 86 02 00 00       	call   800873 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	79 74                	jns    80079c <vprintfmt+0x356>
				putch('-', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff d6                	call   *%esi
				num = -(long long) num;
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
  80073d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800745:	eb 55                	jmp    80079c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 83 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 74 fc ff ff       	call   8003d2 <getuint>
		        base = 8;
  80075e:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800763:	eb 37                	jmp    80079c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 30                	push   $0x30
  80076b:	ff d6                	call   *%esi
			putch('x', putdat);
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 78                	push   $0x78
  800773:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800785:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800788:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 3b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 70 fb ff ff       	call   800323 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 ae fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	51                   	push   %ecx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 9c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x39a>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x397>
  8007e6:	e9 81 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 0c 04 80 00       	push   $0x80040c
  800827:	e8 1a fc ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 9f 2b 80 00       	push   $0x802b9f
  800c45:	6a 23                	push   $0x23
  800c47:	68 bc 2b 80 00       	push   $0x802bbc
  800c4c:	e8 e5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 9f 2b 80 00       	push   $0x802b9f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 bc 2b 80 00       	push   $0x802bbc
  800ccd:	e8 64 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 9f 2b 80 00       	push   $0x802b9f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 bc 2b 80 00       	push   $0x802bbc
  800d0f:	e8 22 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 9f 2b 80 00       	push   $0x802b9f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 bc 2b 80 00       	push   $0x802bbc
  800d51:	e8 e0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 9f 2b 80 00       	push   $0x802b9f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 bc 2b 80 00       	push   $0x802bbc
  800d93:	e8 9e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 9f 2b 80 00       	push   $0x802b9f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 bc 2b 80 00       	push   $0x802bbc
  800dd5:	e8 5c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 9f 2b 80 00       	push   $0x802b9f
  800e10:	6a 23                	push   $0x23
  800e12:	68 bc 2b 80 00       	push   $0x802bbc
  800e17:	e8 1a f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 9f 2b 80 00       	push   $0x802b9f
  800e74:	6a 23                	push   $0x23
  800e76:	68 bc 2b 80 00       	push   $0x802bbc
  800e7b:	e8 b6 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 df                	mov    %ebx,%edi
  800ebf:	89 de                	mov    %ebx,%esi
  800ec1:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ed2:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ed4:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ed8:	74 2e                	je     800f08 <pgfault+0x40>
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	c1 ea 16             	shr    $0x16,%edx
  800edf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	74 1d                	je     800f08 <pgfault+0x40>
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	c1 ea 0c             	shr    $0xc,%edx
  800ef0:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ef7:	f6 c1 01             	test   $0x1,%cl
  800efa:	74 0c                	je     800f08 <pgfault+0x40>
  800efc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f03:	f6 c6 08             	test   $0x8,%dh
  800f06:	75 14                	jne    800f1c <pgfault+0x54>
        panic("Not copy-on-write\n");
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	68 ca 2b 80 00       	push   $0x802bca
  800f10:	6a 1d                	push   $0x1d
  800f12:	68 dd 2b 80 00       	push   $0x802bdd
  800f17:	e8 1a f3 ff ff       	call   800236 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f21:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800f23:	83 ec 04             	sub    $0x4,%esp
  800f26:	6a 07                	push   $0x7
  800f28:	68 00 f0 7f 00       	push   $0x7ff000
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 63 fd ff ff       	call   800c97 <sys_page_alloc>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 14                	jns    800f4f <pgfault+0x87>
		panic("page alloc failed \n");
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	68 e8 2b 80 00       	push   $0x802be8
  800f43:	6a 28                	push   $0x28
  800f45:	68 dd 2b 80 00       	push   $0x802bdd
  800f4a:	e8 e7 f2 ff ff       	call   800236 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	68 00 10 00 00       	push   $0x1000
  800f57:	53                   	push   %ebx
  800f58:	68 00 f0 7f 00       	push   $0x7ff000
  800f5d:	e8 2c fb ff ff       	call   800a8e <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800f62:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f69:	53                   	push   %ebx
  800f6a:	6a 00                	push   $0x0
  800f6c:	68 00 f0 7f 00       	push   $0x7ff000
  800f71:	6a 00                	push   $0x0
  800f73:	e8 62 fd ff ff       	call   800cda <sys_page_map>
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	79 14                	jns    800f93 <pgfault+0xcb>
        panic("page map failed \n");
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 fc 2b 80 00       	push   $0x802bfc
  800f87:	6a 2b                	push   $0x2b
  800f89:	68 dd 2b 80 00       	push   $0x802bdd
  800f8e:	e8 a3 f2 ff ff       	call   800236 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800f93:	83 ec 08             	sub    $0x8,%esp
  800f96:	68 00 f0 7f 00       	push   $0x7ff000
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 7a fd ff ff       	call   800d1c <sys_page_unmap>
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 14                	jns    800fbd <pgfault+0xf5>
        panic("page unmap failed\n");
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	68 0e 2c 80 00       	push   $0x802c0e
  800fb1:	6a 2d                	push   $0x2d
  800fb3:	68 dd 2b 80 00       	push   $0x802bdd
  800fb8:	e8 79 f2 ff ff       	call   800236 <_panic>
	
	//panic("pgfault not implemented");
}
  800fbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800fcb:	68 c8 0e 80 00       	push   $0x800ec8
  800fd0:	e8 51 14 00 00       	call   802426 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fd5:	b8 07 00 00 00       	mov    $0x7,%eax
  800fda:	cd 30                	int    $0x30
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	79 12                	jns    800ffa <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800fe8:	50                   	push   %eax
  800fe9:	68 21 2c 80 00       	push   $0x802c21
  800fee:	6a 7a                	push   $0x7a
  800ff0:	68 dd 2b 80 00       	push   $0x802bdd
  800ff5:	e8 3c f2 ff ff       	call   800236 <_panic>
  800ffa:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fff:	85 c0                	test   %eax,%eax
  801001:	75 21                	jne    801024 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  801003:	e8 51 fc ff ff       	call   800c59 <sys_getenvid>
  801008:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801010:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801015:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  80101a:	b8 00 00 00 00       	mov    $0x0,%eax
  80101f:	e9 91 01 00 00       	jmp    8011b5 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  801024:	89 d8                	mov    %ebx,%eax
  801026:	c1 e8 16             	shr    $0x16,%eax
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801030:	a8 01                	test   $0x1,%al
  801032:	0f 84 06 01 00 00    	je     80113e <fork+0x17c>
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
  80103d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801044:	f6 c2 01             	test   $0x1,%dl
  801047:	0f 84 f1 00 00 00    	je     80113e <fork+0x17c>
  80104d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801054:	f6 c2 04             	test   $0x4,%dl
  801057:	0f 84 e1 00 00 00    	je     80113e <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  80105d:	89 c6                	mov    %eax,%esi
  80105f:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  801062:	89 f2                	mov    %esi,%edx
  801064:	c1 ea 16             	shr    $0x16,%edx
  801067:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  80106e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  801075:	f6 c6 04             	test   $0x4,%dh
  801078:	74 39                	je     8010b3 <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  80107a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	25 07 0e 00 00       	and    $0xe07,%eax
  801089:	50                   	push   %eax
  80108a:	56                   	push   %esi
  80108b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108e:	56                   	push   %esi
  80108f:	6a 00                	push   $0x0
  801091:	e8 44 fc ff ff       	call   800cda <sys_page_map>
  801096:	83 c4 20             	add    $0x20,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	0f 89 9d 00 00 00    	jns    80113e <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  8010a1:	50                   	push   %eax
  8010a2:	68 78 2c 80 00       	push   $0x802c78
  8010a7:	6a 4b                	push   $0x4b
  8010a9:	68 dd 2b 80 00       	push   $0x802bdd
  8010ae:	e8 83 f1 ff ff       	call   800236 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  8010b3:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8010b9:	74 59                	je     801114 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	68 05 08 00 00       	push   $0x805
  8010c3:	56                   	push   %esi
  8010c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c7:	56                   	push   %esi
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 0b fc ff ff       	call   800cda <sys_page_map>
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	79 12                	jns    8010e8 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  8010d6:	50                   	push   %eax
  8010d7:	68 a8 2c 80 00       	push   $0x802ca8
  8010dc:	6a 50                	push   $0x50
  8010de:	68 dd 2b 80 00       	push   $0x802bdd
  8010e3:	e8 4e f1 ff ff       	call   800236 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	68 05 08 00 00       	push   $0x805
  8010f0:	56                   	push   %esi
  8010f1:	6a 00                	push   $0x0
  8010f3:	56                   	push   %esi
  8010f4:	6a 00                	push   $0x0
  8010f6:	e8 df fb ff ff       	call   800cda <sys_page_map>
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	79 3c                	jns    80113e <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  801102:	50                   	push   %eax
  801103:	68 d0 2c 80 00       	push   $0x802cd0
  801108:	6a 53                	push   $0x53
  80110a:	68 dd 2b 80 00       	push   $0x802bdd
  80110f:	e8 22 f1 ff ff       	call   800236 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	6a 05                	push   $0x5
  801119:	56                   	push   %esi
  80111a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111d:	56                   	push   %esi
  80111e:	6a 00                	push   $0x0
  801120:	e8 b5 fb ff ff       	call   800cda <sys_page_map>
  801125:	83 c4 20             	add    $0x20,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	79 12                	jns    80113e <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  80112c:	50                   	push   %eax
  80112d:	68 f8 2c 80 00       	push   $0x802cf8
  801132:	6a 58                	push   $0x58
  801134:	68 dd 2b 80 00       	push   $0x802bdd
  801139:	e8 f8 f0 ff ff       	call   800236 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80113e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801144:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80114a:	0f 85 d4 fe ff ff    	jne    801024 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  801150:	83 ec 04             	sub    $0x4,%esp
  801153:	6a 07                	push   $0x7
  801155:	68 00 f0 bf ee       	push   $0xeebff000
  80115a:	57                   	push   %edi
  80115b:	e8 37 fb ff ff       	call   800c97 <sys_page_alloc>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	79 17                	jns    80117e <fork+0x1bc>
        panic("page alloc failed\n");
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	68 33 2c 80 00       	push   $0x802c33
  80116f:	68 87 00 00 00       	push   $0x87
  801174:	68 dd 2b 80 00       	push   $0x802bdd
  801179:	e8 b8 f0 ff ff       	call   800236 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	68 95 24 80 00       	push   $0x802495
  801186:	57                   	push   %edi
  801187:	e8 56 fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80118c:	83 c4 08             	add    $0x8,%esp
  80118f:	6a 02                	push   $0x2
  801191:	57                   	push   %edi
  801192:	e8 c7 fb ff ff       	call   800d5e <sys_env_set_status>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	79 15                	jns    8011b3 <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80119e:	50                   	push   %eax
  80119f:	68 46 2c 80 00       	push   $0x802c46
  8011a4:	68 8c 00 00 00       	push   $0x8c
  8011a9:	68 dd 2b 80 00       	push   $0x802bdd
  8011ae:	e8 83 f0 ff ff       	call   800236 <_panic>

	return envid;
  8011b3:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sfork>:

// Challenge!
int
sfork(void)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c3:	68 5f 2c 80 00       	push   $0x802c5f
  8011c8:	68 98 00 00 00       	push   $0x98
  8011cd:	68 dd 2b 80 00       	push   $0x802bdd
  8011d2:	e8 5f f0 ff ff       	call   800236 <_panic>

008011d7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8011df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	74 0e                	je     8011f7 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	50                   	push   %eax
  8011ed:	e8 55 fc ff ff       	call   800e47 <sys_ipc_recv>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	eb 10                	jmp    801207 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	68 00 00 00 f0       	push   $0xf0000000
  8011ff:	e8 43 fc ff ff       	call   800e47 <sys_ipc_recv>
  801204:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801207:	85 c0                	test   %eax,%eax
  801209:	74 0e                	je     801219 <ipc_recv+0x42>
    	*from_env_store = 0;
  80120b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801217:	eb 24                	jmp    80123d <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801219:	85 f6                	test   %esi,%esi
  80121b:	74 0a                	je     801227 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80121d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801222:	8b 40 74             	mov    0x74(%eax),%eax
  801225:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801227:	85 db                	test   %ebx,%ebx
  801229:	74 0a                	je     801235 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80122b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801230:	8b 40 78             	mov    0x78(%eax),%eax
  801233:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801235:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80123a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80123d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	53                   	push   %ebx
  80124a:	83 ec 0c             	sub    $0xc,%esp
  80124d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801250:	8b 75 0c             	mov    0xc(%ebp),%esi
  801253:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801256:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80125d:	0f 44 d8             	cmove  %eax,%ebx
  801260:	eb 1c                	jmp    80127e <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801262:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801265:	74 12                	je     801279 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801267:	50                   	push   %eax
  801268:	68 24 2d 80 00       	push   $0x802d24
  80126d:	6a 4b                	push   $0x4b
  80126f:	68 3c 2d 80 00       	push   $0x802d3c
  801274:	e8 bd ef ff ff       	call   800236 <_panic>
        }	
        sys_yield();
  801279:	e8 fa f9 ff ff       	call   800c78 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80127e:	ff 75 14             	pushl  0x14(%ebp)
  801281:	53                   	push   %ebx
  801282:	56                   	push   %esi
  801283:	57                   	push   %edi
  801284:	e8 9b fb ff ff       	call   800e24 <sys_ipc_try_send>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	75 d2                	jne    801262 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012a3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012a6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012ac:	8b 52 50             	mov    0x50(%edx),%edx
  8012af:	39 ca                	cmp    %ecx,%edx
  8012b1:	75 0d                	jne    8012c0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012bb:	8b 40 48             	mov    0x48(%eax),%eax
  8012be:	eb 0f                	jmp    8012cf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012c0:	83 c0 01             	add    $0x1,%eax
  8012c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012c8:	75 d9                	jne    8012a3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    

008012d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8012dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801303:	89 c2                	mov    %eax,%edx
  801305:	c1 ea 16             	shr    $0x16,%edx
  801308:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 11                	je     801325 <fd_alloc+0x2d>
  801314:	89 c2                	mov    %eax,%edx
  801316:	c1 ea 0c             	shr    $0xc,%edx
  801319:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801320:	f6 c2 01             	test   $0x1,%dl
  801323:	75 09                	jne    80132e <fd_alloc+0x36>
			*fd_store = fd;
  801325:	89 01                	mov    %eax,(%ecx)
			return 0;
  801327:	b8 00 00 00 00       	mov    $0x0,%eax
  80132c:	eb 17                	jmp    801345 <fd_alloc+0x4d>
  80132e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801333:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801338:	75 c9                	jne    801303 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80133a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801340:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134d:	83 f8 1f             	cmp    $0x1f,%eax
  801350:	77 36                	ja     801388 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801352:	c1 e0 0c             	shl    $0xc,%eax
  801355:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	c1 ea 16             	shr    $0x16,%edx
  80135f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801366:	f6 c2 01             	test   $0x1,%dl
  801369:	74 24                	je     80138f <fd_lookup+0x48>
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	c1 ea 0c             	shr    $0xc,%edx
  801370:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801377:	f6 c2 01             	test   $0x1,%dl
  80137a:	74 1a                	je     801396 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80137c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137f:	89 02                	mov    %eax,(%edx)
	return 0;
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
  801386:	eb 13                	jmp    80139b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801388:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138d:	eb 0c                	jmp    80139b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801394:	eb 05                	jmp    80139b <fd_lookup+0x54>
  801396:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a6:	ba c4 2d 80 00       	mov    $0x802dc4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ab:	eb 13                	jmp    8013c0 <dev_lookup+0x23>
  8013ad:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013b0:	39 08                	cmp    %ecx,(%eax)
  8013b2:	75 0c                	jne    8013c0 <dev_lookup+0x23>
			*dev = devtab[i];
  8013b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013be:	eb 2e                	jmp    8013ee <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c0:	8b 02                	mov    (%edx),%eax
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	75 e7                	jne    8013ad <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c6:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013cb:	8b 40 48             	mov    0x48(%eax),%eax
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	51                   	push   %ecx
  8013d2:	50                   	push   %eax
  8013d3:	68 48 2d 80 00       	push   $0x802d48
  8013d8:	e8 32 ef ff ff       	call   80030f <cprintf>
	*dev = 0;
  8013dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 10             	sub    $0x10,%esp
  8013f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801408:	c1 e8 0c             	shr    $0xc,%eax
  80140b:	50                   	push   %eax
  80140c:	e8 36 ff ff ff       	call   801347 <fd_lookup>
  801411:	83 c4 08             	add    $0x8,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 05                	js     80141d <fd_close+0x2d>
	    || fd != fd2)
  801418:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141b:	74 0c                	je     801429 <fd_close+0x39>
		return (must_exist ? r : 0);
  80141d:	84 db                	test   %bl,%bl
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	0f 44 c2             	cmove  %edx,%eax
  801427:	eb 41                	jmp    80146a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	ff 36                	pushl  (%esi)
  801432:	e8 66 ff ff ff       	call   80139d <dev_lookup>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 1a                	js     80145a <fd_close+0x6a>
		if (dev->dev_close)
  801440:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801443:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801446:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80144b:	85 c0                	test   %eax,%eax
  80144d:	74 0b                	je     80145a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	56                   	push   %esi
  801453:	ff d0                	call   *%eax
  801455:	89 c3                	mov    %eax,%ebx
  801457:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	56                   	push   %esi
  80145e:	6a 00                	push   $0x0
  801460:	e8 b7 f8 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	89 d8                	mov    %ebx,%eax
}
  80146a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 08             	pushl  0x8(%ebp)
  80147e:	e8 c4 fe ff ff       	call   801347 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 10                	js     80149a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	6a 01                	push   $0x1
  80148f:	ff 75 f4             	pushl  -0xc(%ebp)
  801492:	e8 59 ff ff ff       	call   8013f0 <fd_close>
  801497:	83 c4 10             	add    $0x10,%esp
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <close_all>:

void
close_all(void)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	e8 c0 ff ff ff       	call   801471 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b1:	83 c3 01             	add    $0x1,%ebx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	83 fb 20             	cmp    $0x20,%ebx
  8014ba:	75 ec                	jne    8014a8 <close_all+0xc>
		close(i);
}
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	57                   	push   %edi
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 2c             	sub    $0x2c,%esp
  8014ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	ff 75 08             	pushl  0x8(%ebp)
  8014d4:	e8 6e fe ff ff       	call   801347 <fd_lookup>
  8014d9:	83 c4 08             	add    $0x8,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	0f 88 c1 00 00 00    	js     8015a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	56                   	push   %esi
  8014e8:	e8 84 ff ff ff       	call   801471 <close>

	newfd = INDEX2FD(newfdnum);
  8014ed:	89 f3                	mov    %esi,%ebx
  8014ef:	c1 e3 0c             	shl    $0xc,%ebx
  8014f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f8:	83 c4 04             	add    $0x4,%esp
  8014fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fe:	e8 de fd ff ff       	call   8012e1 <fd2data>
  801503:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801505:	89 1c 24             	mov    %ebx,(%esp)
  801508:	e8 d4 fd ff ff       	call   8012e1 <fd2data>
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801513:	89 f8                	mov    %edi,%eax
  801515:	c1 e8 16             	shr    $0x16,%eax
  801518:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151f:	a8 01                	test   $0x1,%al
  801521:	74 37                	je     80155a <dup+0x99>
  801523:	89 f8                	mov    %edi,%eax
  801525:	c1 e8 0c             	shr    $0xc,%eax
  801528:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152f:	f6 c2 01             	test   $0x1,%dl
  801532:	74 26                	je     80155a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801534:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	25 07 0e 00 00       	and    $0xe07,%eax
  801543:	50                   	push   %eax
  801544:	ff 75 d4             	pushl  -0x2c(%ebp)
  801547:	6a 00                	push   $0x0
  801549:	57                   	push   %edi
  80154a:	6a 00                	push   $0x0
  80154c:	e8 89 f7 ff ff       	call   800cda <sys_page_map>
  801551:	89 c7                	mov    %eax,%edi
  801553:	83 c4 20             	add    $0x20,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 2e                	js     801588 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	c1 e8 0c             	shr    $0xc,%eax
  801562:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	25 07 0e 00 00       	and    $0xe07,%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	6a 00                	push   $0x0
  801575:	52                   	push   %edx
  801576:	6a 00                	push   $0x0
  801578:	e8 5d f7 ff ff       	call   800cda <sys_page_map>
  80157d:	89 c7                	mov    %eax,%edi
  80157f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801582:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801584:	85 ff                	test   %edi,%edi
  801586:	79 1d                	jns    8015a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	6a 00                	push   $0x0
  80158e:	e8 89 f7 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	ff 75 d4             	pushl  -0x2c(%ebp)
  801599:	6a 00                	push   $0x0
  80159b:	e8 7c f7 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	89 f8                	mov    %edi,%eax
}
  8015a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a8:	5b                   	pop    %ebx
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 14             	sub    $0x14,%esp
  8015b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	53                   	push   %ebx
  8015bc:	e8 86 fd ff ff       	call   801347 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 6d                	js     801637 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	ff 30                	pushl  (%eax)
  8015d6:	e8 c2 fd ff ff       	call   80139d <dev_lookup>
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 4c                	js     80162e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e5:	8b 42 08             	mov    0x8(%edx),%eax
  8015e8:	83 e0 03             	and    $0x3,%eax
  8015eb:	83 f8 01             	cmp    $0x1,%eax
  8015ee:	75 21                	jne    801611 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015f5:	8b 40 48             	mov    0x48(%eax),%eax
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	50                   	push   %eax
  8015fd:	68 89 2d 80 00       	push   $0x802d89
  801602:	e8 08 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160f:	eb 26                	jmp    801637 <read+0x8a>
	}
	if (!dev->dev_read)
  801611:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801614:	8b 40 08             	mov    0x8(%eax),%eax
  801617:	85 c0                	test   %eax,%eax
  801619:	74 17                	je     801632 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	52                   	push   %edx
  801625:	ff d0                	call   *%eax
  801627:	89 c2                	mov    %eax,%edx
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb 09                	jmp    801637 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162e:	89 c2                	mov    %eax,%edx
  801630:	eb 05                	jmp    801637 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801632:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801637:	89 d0                	mov    %edx,%eax
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801652:	eb 21                	jmp    801675 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	89 f0                	mov    %esi,%eax
  801659:	29 d8                	sub    %ebx,%eax
  80165b:	50                   	push   %eax
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	03 45 0c             	add    0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	57                   	push   %edi
  801663:	e8 45 ff ff ff       	call   8015ad <read>
		if (m < 0)
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 10                	js     80167f <readn+0x41>
			return m;
		if (m == 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	74 0a                	je     80167d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801673:	01 c3                	add    %eax,%ebx
  801675:	39 f3                	cmp    %esi,%ebx
  801677:	72 db                	jb     801654 <readn+0x16>
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	eb 02                	jmp    80167f <readn+0x41>
  80167d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 14             	sub    $0x14,%esp
  80168e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	53                   	push   %ebx
  801696:	e8 ac fc ff ff       	call   801347 <fd_lookup>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 68                	js     80170c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	ff 30                	pushl  (%eax)
  8016b0:	e8 e8 fc ff ff       	call   80139d <dev_lookup>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 47                	js     801703 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c3:	75 21                	jne    8016e6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8016ca:	8b 40 48             	mov    0x48(%eax),%eax
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	50                   	push   %eax
  8016d2:	68 a5 2d 80 00       	push   $0x802da5
  8016d7:	e8 33 ec ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e4:	eb 26                	jmp    80170c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ec:	85 d2                	test   %edx,%edx
  8016ee:	74 17                	je     801707 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f0:	83 ec 04             	sub    $0x4,%esp
  8016f3:	ff 75 10             	pushl  0x10(%ebp)
  8016f6:	ff 75 0c             	pushl  0xc(%ebp)
  8016f9:	50                   	push   %eax
  8016fa:	ff d2                	call   *%edx
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	eb 09                	jmp    80170c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	89 c2                	mov    %eax,%edx
  801705:	eb 05                	jmp    80170c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801707:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170c:	89 d0                	mov    %edx,%eax
  80170e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <seek>:

int
seek(int fdnum, off_t offset)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801719:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171c:	50                   	push   %eax
  80171d:	ff 75 08             	pushl  0x8(%ebp)
  801720:	e8 22 fc ff ff       	call   801347 <fd_lookup>
  801725:	83 c4 08             	add    $0x8,%esp
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 0e                	js     80173a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80172f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801732:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801735:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	83 ec 14             	sub    $0x14,%esp
  801743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	53                   	push   %ebx
  80174b:	e8 f7 fb ff ff       	call   801347 <fd_lookup>
  801750:	83 c4 08             	add    $0x8,%esp
  801753:	89 c2                	mov    %eax,%edx
  801755:	85 c0                	test   %eax,%eax
  801757:	78 65                	js     8017be <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801763:	ff 30                	pushl  (%eax)
  801765:	e8 33 fc ff ff       	call   80139d <dev_lookup>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 44                	js     8017b5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801774:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801778:	75 21                	jne    80179b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177a:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80177f:	8b 40 48             	mov    0x48(%eax),%eax
  801782:	83 ec 04             	sub    $0x4,%esp
  801785:	53                   	push   %ebx
  801786:	50                   	push   %eax
  801787:	68 68 2d 80 00       	push   $0x802d68
  80178c:	e8 7e eb ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801799:	eb 23                	jmp    8017be <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80179b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179e:	8b 52 18             	mov    0x18(%edx),%edx
  8017a1:	85 d2                	test   %edx,%edx
  8017a3:	74 14                	je     8017b9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	50                   	push   %eax
  8017ac:	ff d2                	call   *%edx
  8017ae:	89 c2                	mov    %eax,%edx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	eb 09                	jmp    8017be <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	eb 05                	jmp    8017be <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017be:	89 d0                	mov    %edx,%eax
  8017c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	53                   	push   %ebx
  8017c9:	83 ec 14             	sub    $0x14,%esp
  8017cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d2:	50                   	push   %eax
  8017d3:	ff 75 08             	pushl  0x8(%ebp)
  8017d6:	e8 6c fb ff ff       	call   801347 <fd_lookup>
  8017db:	83 c4 08             	add    $0x8,%esp
  8017de:	89 c2                	mov    %eax,%edx
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	78 58                	js     80183c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e4:	83 ec 08             	sub    $0x8,%esp
  8017e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ee:	ff 30                	pushl  (%eax)
  8017f0:	e8 a8 fb ff ff       	call   80139d <dev_lookup>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 37                	js     801833 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801803:	74 32                	je     801837 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801805:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801808:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80180f:	00 00 00 
	stat->st_isdir = 0;
  801812:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801819:	00 00 00 
	stat->st_dev = dev;
  80181c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801822:	83 ec 08             	sub    $0x8,%esp
  801825:	53                   	push   %ebx
  801826:	ff 75 f0             	pushl  -0x10(%ebp)
  801829:	ff 50 14             	call   *0x14(%eax)
  80182c:	89 c2                	mov    %eax,%edx
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	eb 09                	jmp    80183c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801833:	89 c2                	mov    %eax,%edx
  801835:	eb 05                	jmp    80183c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80183c:	89 d0                	mov    %edx,%eax
  80183e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	56                   	push   %esi
  801847:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	6a 00                	push   $0x0
  80184d:	ff 75 08             	pushl  0x8(%ebp)
  801850:	e8 e7 01 00 00       	call   801a3c <open>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 1b                	js     801879 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	ff 75 0c             	pushl  0xc(%ebp)
  801864:	50                   	push   %eax
  801865:	e8 5b ff ff ff       	call   8017c5 <fstat>
  80186a:	89 c6                	mov    %eax,%esi
	close(fd);
  80186c:	89 1c 24             	mov    %ebx,(%esp)
  80186f:	e8 fd fb ff ff       	call   801471 <close>
	return r;
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	89 f0                	mov    %esi,%eax
}
  801879:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	89 c6                	mov    %eax,%esi
  801887:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801889:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801890:	75 12                	jne    8018a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	6a 01                	push   $0x1
  801897:	e8 fc f9 ff ff       	call   801298 <ipc_find_env>
  80189c:	a3 04 40 80 00       	mov    %eax,0x804004
  8018a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a4:	6a 07                	push   $0x7
  8018a6:	68 00 50 80 00       	push   $0x805000
  8018ab:	56                   	push   %esi
  8018ac:	ff 35 04 40 80 00    	pushl  0x804004
  8018b2:	e8 8d f9 ff ff       	call   801244 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b7:	83 c4 0c             	add    $0xc,%esp
  8018ba:	6a 00                	push   $0x0
  8018bc:	53                   	push   %ebx
  8018bd:	6a 00                	push   $0x0
  8018bf:	e8 13 f9 ff ff       	call   8011d7 <ipc_recv>
}
  8018c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018df:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e9:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ee:	e8 8d ff ff ff       	call   801880 <fsipc>
}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801901:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801906:	ba 00 00 00 00       	mov    $0x0,%edx
  80190b:	b8 06 00 00 00       	mov    $0x6,%eax
  801910:	e8 6b ff ff ff       	call   801880 <fsipc>
}
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	53                   	push   %ebx
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	8b 40 0c             	mov    0xc(%eax),%eax
  801927:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
  801931:	b8 05 00 00 00       	mov    $0x5,%eax
  801936:	e8 45 ff ff ff       	call   801880 <fsipc>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 2c                	js     80196b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	68 00 50 80 00       	push   $0x805000
  801947:	53                   	push   %ebx
  801948:	e8 47 ef ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80194d:	a1 80 50 80 00       	mov    0x805080,%eax
  801952:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801958:	a1 84 50 80 00       	mov    0x805084,%eax
  80195d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	53                   	push   %ebx
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80197a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80197f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801984:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801987:	53                   	push   %ebx
  801988:	ff 75 0c             	pushl  0xc(%ebp)
  80198b:	68 08 50 80 00       	push   $0x805008
  801990:	e8 91 f0 ff ff       	call   800a26 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	8b 40 0c             	mov    0xc(%eax),%eax
  80199b:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8019a0:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8019a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b0:	e8 cb fe ff ff       	call   801880 <fsipc>
	//panic("devfile_write not implemented");
}
  8019b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	56                   	push   %esi
  8019be:	53                   	push   %ebx
  8019bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8019dd:	e8 9e fe ff ff       	call   801880 <fsipc>
  8019e2:	89 c3                	mov    %eax,%ebx
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 4b                	js     801a33 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019e8:	39 c6                	cmp    %eax,%esi
  8019ea:	73 16                	jae    801a02 <devfile_read+0x48>
  8019ec:	68 d8 2d 80 00       	push   $0x802dd8
  8019f1:	68 df 2d 80 00       	push   $0x802ddf
  8019f6:	6a 7c                	push   $0x7c
  8019f8:	68 f4 2d 80 00       	push   $0x802df4
  8019fd:	e8 34 e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  801a02:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a07:	7e 16                	jle    801a1f <devfile_read+0x65>
  801a09:	68 ff 2d 80 00       	push   $0x802dff
  801a0e:	68 df 2d 80 00       	push   $0x802ddf
  801a13:	6a 7d                	push   $0x7d
  801a15:	68 f4 2d 80 00       	push   $0x802df4
  801a1a:	e8 17 e8 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	50                   	push   %eax
  801a23:	68 00 50 80 00       	push   $0x805000
  801a28:	ff 75 0c             	pushl  0xc(%ebp)
  801a2b:	e8 f6 ef ff ff       	call   800a26 <memmove>
	return r;
  801a30:	83 c4 10             	add    $0x10,%esp
}
  801a33:	89 d8                	mov    %ebx,%eax
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	53                   	push   %ebx
  801a40:	83 ec 20             	sub    $0x20,%esp
  801a43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a46:	53                   	push   %ebx
  801a47:	e8 0f ee ff ff       	call   80085b <strlen>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a54:	7f 67                	jg     801abd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5c:	50                   	push   %eax
  801a5d:	e8 96 f8 ff ff       	call   8012f8 <fd_alloc>
  801a62:	83 c4 10             	add    $0x10,%esp
		return r;
  801a65:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 57                	js     801ac2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	53                   	push   %ebx
  801a6f:	68 00 50 80 00       	push   $0x805000
  801a74:	e8 1b ee ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a84:	b8 01 00 00 00       	mov    $0x1,%eax
  801a89:	e8 f2 fd ff ff       	call   801880 <fsipc>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	79 14                	jns    801aab <open+0x6f>
		fd_close(fd, 0);
  801a97:	83 ec 08             	sub    $0x8,%esp
  801a9a:	6a 00                	push   $0x0
  801a9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9f:	e8 4c f9 ff ff       	call   8013f0 <fd_close>
		return r;
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	89 da                	mov    %ebx,%edx
  801aa9:	eb 17                	jmp    801ac2 <open+0x86>
	}

	return fd2num(fd);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab1:	e8 1b f8 ff ff       	call   8012d1 <fd2num>
  801ab6:	89 c2                	mov    %eax,%edx
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	eb 05                	jmp    801ac2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801abd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac2:	89 d0                	mov    %edx,%eax
  801ac4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801acf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad9:	e8 a2 fd ff ff       	call   801880 <fsipc>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801ae6:	68 0b 2e 80 00       	push   $0x802e0b
  801aeb:	ff 75 0c             	pushl  0xc(%ebp)
  801aee:	e8 a1 ed ff ff       	call   800894 <strcpy>
	return 0;
}
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 10             	sub    $0x10,%esp
  801b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b04:	53                   	push   %ebx
  801b05:	e8 af 09 00 00       	call   8024b9 <pageref>
  801b0a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b12:	83 f8 01             	cmp    $0x1,%eax
  801b15:	75 10                	jne    801b27 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	ff 73 0c             	pushl  0xc(%ebx)
  801b1d:	e8 c0 02 00 00       	call   801de2 <nsipc_close>
  801b22:	89 c2                	mov    %eax,%edx
  801b24:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b27:	89 d0                	mov    %edx,%eax
  801b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b34:	6a 00                	push   $0x0
  801b36:	ff 75 10             	pushl  0x10(%ebp)
  801b39:	ff 75 0c             	pushl  0xc(%ebp)
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	ff 70 0c             	pushl  0xc(%eax)
  801b42:	e8 78 03 00 00       	call   801ebf <nsipc_send>
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    

00801b49 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b4f:	6a 00                	push   $0x0
  801b51:	ff 75 10             	pushl  0x10(%ebp)
  801b54:	ff 75 0c             	pushl  0xc(%ebp)
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	ff 70 0c             	pushl  0xc(%eax)
  801b5d:	e8 f1 02 00 00       	call   801e53 <nsipc_recv>
}
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b6a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b6d:	52                   	push   %edx
  801b6e:	50                   	push   %eax
  801b6f:	e8 d3 f7 ff ff       	call   801347 <fd_lookup>
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 17                	js     801b92 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b84:	39 08                	cmp    %ecx,(%eax)
  801b86:	75 05                	jne    801b8d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b88:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8b:	eb 05                	jmp    801b92 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b8d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	83 ec 1c             	sub    $0x1c,%esp
  801b9c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 51 f7 ff ff       	call   8012f8 <fd_alloc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 1b                	js     801bcb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 d5 f0 ff ff       	call   800c97 <sys_page_alloc>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	79 10                	jns    801bdb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	56                   	push   %esi
  801bcf:	e8 0e 02 00 00       	call   801de2 <nsipc_close>
		return r;
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	89 d8                	mov    %ebx,%eax
  801bd9:	eb 24                	jmp    801bff <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bdb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bf0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bf3:	83 ec 0c             	sub    $0xc,%esp
  801bf6:	50                   	push   %eax
  801bf7:	e8 d5 f6 ff ff       	call   8012d1 <fd2num>
  801bfc:	83 c4 10             	add    $0x10,%esp
}
  801bff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	e8 50 ff ff ff       	call   801b64 <fd2sockid>
		return r;
  801c14:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 1f                	js     801c39 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c1a:	83 ec 04             	sub    $0x4,%esp
  801c1d:	ff 75 10             	pushl  0x10(%ebp)
  801c20:	ff 75 0c             	pushl  0xc(%ebp)
  801c23:	50                   	push   %eax
  801c24:	e8 12 01 00 00       	call   801d3b <nsipc_accept>
  801c29:	83 c4 10             	add    $0x10,%esp
		return r;
  801c2c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 07                	js     801c39 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c32:	e8 5d ff ff ff       	call   801b94 <alloc_sockfd>
  801c37:	89 c1                	mov    %eax,%ecx
}
  801c39:	89 c8                	mov    %ecx,%eax
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    

00801c3d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	e8 19 ff ff ff       	call   801b64 <fd2sockid>
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 12                	js     801c61 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	ff 75 10             	pushl  0x10(%ebp)
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	50                   	push   %eax
  801c59:	e8 2d 01 00 00       	call   801d8b <nsipc_bind>
  801c5e:	83 c4 10             	add    $0x10,%esp
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <shutdown>:

int
shutdown(int s, int how)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	e8 f3 fe ff ff       	call   801b64 <fd2sockid>
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 0f                	js     801c84 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	ff 75 0c             	pushl  0xc(%ebp)
  801c7b:	50                   	push   %eax
  801c7c:	e8 3f 01 00 00       	call   801dc0 <nsipc_shutdown>
  801c81:	83 c4 10             	add    $0x10,%esp
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	e8 d0 fe ff ff       	call   801b64 <fd2sockid>
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 12                	js     801caa <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	ff 75 10             	pushl  0x10(%ebp)
  801c9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ca1:	50                   	push   %eax
  801ca2:	e8 55 01 00 00       	call   801dfc <nsipc_connect>
  801ca7:	83 c4 10             	add    $0x10,%esp
}
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <listen>:

int
listen(int s, int backlog)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	e8 aa fe ff ff       	call   801b64 <fd2sockid>
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 0f                	js     801ccd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801cbe:	83 ec 08             	sub    $0x8,%esp
  801cc1:	ff 75 0c             	pushl  0xc(%ebp)
  801cc4:	50                   	push   %eax
  801cc5:	e8 67 01 00 00       	call   801e31 <nsipc_listen>
  801cca:	83 c4 10             	add    $0x10,%esp
}
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cd5:	ff 75 10             	pushl  0x10(%ebp)
  801cd8:	ff 75 0c             	pushl  0xc(%ebp)
  801cdb:	ff 75 08             	pushl  0x8(%ebp)
  801cde:	e8 3a 02 00 00       	call   801f1d <nsipc_socket>
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 05                	js     801cef <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cea:	e8 a5 fe ff ff       	call   801b94 <alloc_sockfd>
}
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	53                   	push   %ebx
  801cf5:	83 ec 04             	sub    $0x4,%esp
  801cf8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cfa:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801d01:	75 12                	jne    801d15 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	6a 02                	push   $0x2
  801d08:	e8 8b f5 ff ff       	call   801298 <ipc_find_env>
  801d0d:	a3 08 40 80 00       	mov    %eax,0x804008
  801d12:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d15:	6a 07                	push   $0x7
  801d17:	68 00 60 80 00       	push   $0x806000
  801d1c:	53                   	push   %ebx
  801d1d:	ff 35 08 40 80 00    	pushl  0x804008
  801d23:	e8 1c f5 ff ff       	call   801244 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d28:	83 c4 0c             	add    $0xc,%esp
  801d2b:	6a 00                	push   $0x0
  801d2d:	6a 00                	push   $0x0
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 a1 f4 ff ff       	call   8011d7 <ipc_recv>
}
  801d36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	56                   	push   %esi
  801d3f:	53                   	push   %ebx
  801d40:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
  801d46:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d4b:	8b 06                	mov    (%esi),%eax
  801d4d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d52:	b8 01 00 00 00       	mov    $0x1,%eax
  801d57:	e8 95 ff ff ff       	call   801cf1 <nsipc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 20                	js     801d82 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d62:	83 ec 04             	sub    $0x4,%esp
  801d65:	ff 35 10 60 80 00    	pushl  0x806010
  801d6b:	68 00 60 80 00       	push   $0x806000
  801d70:	ff 75 0c             	pushl  0xc(%ebp)
  801d73:	e8 ae ec ff ff       	call   800a26 <memmove>
		*addrlen = ret->ret_addrlen;
  801d78:	a1 10 60 80 00       	mov    0x806010,%eax
  801d7d:	89 06                	mov    %eax,(%esi)
  801d7f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d82:	89 d8                	mov    %ebx,%eax
  801d84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	53                   	push   %ebx
  801d8f:	83 ec 08             	sub    $0x8,%esp
  801d92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d9d:	53                   	push   %ebx
  801d9e:	ff 75 0c             	pushl  0xc(%ebp)
  801da1:	68 04 60 80 00       	push   $0x806004
  801da6:	e8 7b ec ff ff       	call   800a26 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dab:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801db1:	b8 02 00 00 00       	mov    $0x2,%eax
  801db6:	e8 36 ff ff ff       	call   801cf1 <nsipc>
}
  801dbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801dd6:	b8 03 00 00 00       	mov    $0x3,%eax
  801ddb:	e8 11 ff ff ff       	call   801cf1 <nsipc>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <nsipc_close>:

int
nsipc_close(int s)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801df0:	b8 04 00 00 00       	mov    $0x4,%eax
  801df5:	e8 f7 fe ff ff       	call   801cf1 <nsipc>
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	53                   	push   %ebx
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e0e:	53                   	push   %ebx
  801e0f:	ff 75 0c             	pushl  0xc(%ebp)
  801e12:	68 04 60 80 00       	push   $0x806004
  801e17:	e8 0a ec ff ff       	call   800a26 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e1c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e22:	b8 05 00 00 00       	mov    $0x5,%eax
  801e27:	e8 c5 fe ff ff       	call   801cf1 <nsipc>
}
  801e2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e42:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e47:	b8 06 00 00 00       	mov    $0x6,%eax
  801e4c:	e8 a0 fe ff ff       	call   801cf1 <nsipc>
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e63:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e69:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e71:	b8 07 00 00 00       	mov    $0x7,%eax
  801e76:	e8 76 fe ff ff       	call   801cf1 <nsipc>
  801e7b:	89 c3                	mov    %eax,%ebx
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 35                	js     801eb6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e81:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e86:	7f 04                	jg     801e8c <nsipc_recv+0x39>
  801e88:	39 c6                	cmp    %eax,%esi
  801e8a:	7d 16                	jge    801ea2 <nsipc_recv+0x4f>
  801e8c:	68 17 2e 80 00       	push   $0x802e17
  801e91:	68 df 2d 80 00       	push   $0x802ddf
  801e96:	6a 62                	push   $0x62
  801e98:	68 2c 2e 80 00       	push   $0x802e2c
  801e9d:	e8 94 e3 ff ff       	call   800236 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ea2:	83 ec 04             	sub    $0x4,%esp
  801ea5:	50                   	push   %eax
  801ea6:	68 00 60 80 00       	push   $0x806000
  801eab:	ff 75 0c             	pushl  0xc(%ebp)
  801eae:	e8 73 eb ff ff       	call   800a26 <memmove>
  801eb3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801eb6:	89 d8                	mov    %ebx,%eax
  801eb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	53                   	push   %ebx
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ed1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ed7:	7e 16                	jle    801eef <nsipc_send+0x30>
  801ed9:	68 38 2e 80 00       	push   $0x802e38
  801ede:	68 df 2d 80 00       	push   $0x802ddf
  801ee3:	6a 6d                	push   $0x6d
  801ee5:	68 2c 2e 80 00       	push   $0x802e2c
  801eea:	e8 47 e3 ff ff       	call   800236 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eef:	83 ec 04             	sub    $0x4,%esp
  801ef2:	53                   	push   %ebx
  801ef3:	ff 75 0c             	pushl  0xc(%ebp)
  801ef6:	68 0c 60 80 00       	push   $0x80600c
  801efb:	e8 26 eb ff ff       	call   800a26 <memmove>
	nsipcbuf.send.req_size = size;
  801f00:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f06:	8b 45 14             	mov    0x14(%ebp),%eax
  801f09:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f0e:	b8 08 00 00 00       	mov    $0x8,%eax
  801f13:	e8 d9 fd ff ff       	call   801cf1 <nsipc>
}
  801f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f23:	8b 45 08             	mov    0x8(%ebp),%eax
  801f26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f33:	8b 45 10             	mov    0x10(%ebp),%eax
  801f36:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f3b:	b8 09 00 00 00       	mov    $0x9,%eax
  801f40:	e8 ac fd ff ff       	call   801cf1 <nsipc>
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
  801f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	ff 75 08             	pushl  0x8(%ebp)
  801f55:	e8 87 f3 ff ff       	call   8012e1 <fd2data>
  801f5a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f5c:	83 c4 08             	add    $0x8,%esp
  801f5f:	68 44 2e 80 00       	push   $0x802e44
  801f64:	53                   	push   %ebx
  801f65:	e8 2a e9 ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f6a:	8b 46 04             	mov    0x4(%esi),%eax
  801f6d:	2b 06                	sub    (%esi),%eax
  801f6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f75:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f7c:	00 00 00 
	stat->st_dev = &devpipe;
  801f7f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f86:	30 80 00 
	return 0;
}
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	53                   	push   %ebx
  801f99:	83 ec 0c             	sub    $0xc,%esp
  801f9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f9f:	53                   	push   %ebx
  801fa0:	6a 00                	push   $0x0
  801fa2:	e8 75 ed ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa7:	89 1c 24             	mov    %ebx,(%esp)
  801faa:	e8 32 f3 ff ff       	call   8012e1 <fd2data>
  801faf:	83 c4 08             	add    $0x8,%esp
  801fb2:	50                   	push   %eax
  801fb3:	6a 00                	push   $0x0
  801fb5:	e8 62 ed ff ff       	call   800d1c <sys_page_unmap>
}
  801fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    

00801fbf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	57                   	push   %edi
  801fc3:	56                   	push   %esi
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 1c             	sub    $0x1c,%esp
  801fc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fcb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fcd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fd2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fd5:	83 ec 0c             	sub    $0xc,%esp
  801fd8:	ff 75 e0             	pushl  -0x20(%ebp)
  801fdb:	e8 d9 04 00 00       	call   8024b9 <pageref>
  801fe0:	89 c3                	mov    %eax,%ebx
  801fe2:	89 3c 24             	mov    %edi,(%esp)
  801fe5:	e8 cf 04 00 00       	call   8024b9 <pageref>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	39 c3                	cmp    %eax,%ebx
  801fef:	0f 94 c1             	sete   %cl
  801ff2:	0f b6 c9             	movzbl %cl,%ecx
  801ff5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ff8:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801ffe:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802001:	39 ce                	cmp    %ecx,%esi
  802003:	74 1b                	je     802020 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802005:	39 c3                	cmp    %eax,%ebx
  802007:	75 c4                	jne    801fcd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802009:	8b 42 58             	mov    0x58(%edx),%eax
  80200c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80200f:	50                   	push   %eax
  802010:	56                   	push   %esi
  802011:	68 4b 2e 80 00       	push   $0x802e4b
  802016:	e8 f4 e2 ff ff       	call   80030f <cprintf>
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	eb ad                	jmp    801fcd <_pipeisclosed+0xe>
	}
}
  802020:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802023:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802026:	5b                   	pop    %ebx
  802027:	5e                   	pop    %esi
  802028:	5f                   	pop    %edi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    

0080202b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	57                   	push   %edi
  80202f:	56                   	push   %esi
  802030:	53                   	push   %ebx
  802031:	83 ec 28             	sub    $0x28,%esp
  802034:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802037:	56                   	push   %esi
  802038:	e8 a4 f2 ff ff       	call   8012e1 <fd2data>
  80203d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	bf 00 00 00 00       	mov    $0x0,%edi
  802047:	eb 4b                	jmp    802094 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802049:	89 da                	mov    %ebx,%edx
  80204b:	89 f0                	mov    %esi,%eax
  80204d:	e8 6d ff ff ff       	call   801fbf <_pipeisclosed>
  802052:	85 c0                	test   %eax,%eax
  802054:	75 48                	jne    80209e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802056:	e8 1d ec ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80205b:	8b 43 04             	mov    0x4(%ebx),%eax
  80205e:	8b 0b                	mov    (%ebx),%ecx
  802060:	8d 51 20             	lea    0x20(%ecx),%edx
  802063:	39 d0                	cmp    %edx,%eax
  802065:	73 e2                	jae    802049 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802067:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80206e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802071:	89 c2                	mov    %eax,%edx
  802073:	c1 fa 1f             	sar    $0x1f,%edx
  802076:	89 d1                	mov    %edx,%ecx
  802078:	c1 e9 1b             	shr    $0x1b,%ecx
  80207b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80207e:	83 e2 1f             	and    $0x1f,%edx
  802081:	29 ca                	sub    %ecx,%edx
  802083:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802087:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80208b:	83 c0 01             	add    $0x1,%eax
  80208e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802091:	83 c7 01             	add    $0x1,%edi
  802094:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802097:	75 c2                	jne    80205b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802099:	8b 45 10             	mov    0x10(%ebp),%eax
  80209c:	eb 05                	jmp    8020a3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80209e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a6:	5b                   	pop    %ebx
  8020a7:	5e                   	pop    %esi
  8020a8:	5f                   	pop    %edi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	57                   	push   %edi
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 18             	sub    $0x18,%esp
  8020b4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020b7:	57                   	push   %edi
  8020b8:	e8 24 f2 ff ff       	call   8012e1 <fd2data>
  8020bd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c7:	eb 3d                	jmp    802106 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020c9:	85 db                	test   %ebx,%ebx
  8020cb:	74 04                	je     8020d1 <devpipe_read+0x26>
				return i;
  8020cd:	89 d8                	mov    %ebx,%eax
  8020cf:	eb 44                	jmp    802115 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020d1:	89 f2                	mov    %esi,%edx
  8020d3:	89 f8                	mov    %edi,%eax
  8020d5:	e8 e5 fe ff ff       	call   801fbf <_pipeisclosed>
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	75 32                	jne    802110 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020de:	e8 95 eb ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020e3:	8b 06                	mov    (%esi),%eax
  8020e5:	3b 46 04             	cmp    0x4(%esi),%eax
  8020e8:	74 df                	je     8020c9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020ea:	99                   	cltd   
  8020eb:	c1 ea 1b             	shr    $0x1b,%edx
  8020ee:	01 d0                	add    %edx,%eax
  8020f0:	83 e0 1f             	and    $0x1f,%eax
  8020f3:	29 d0                	sub    %edx,%eax
  8020f5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020fd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802100:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802103:	83 c3 01             	add    $0x1,%ebx
  802106:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802109:	75 d8                	jne    8020e3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80210b:	8b 45 10             	mov    0x10(%ebp),%eax
  80210e:	eb 05                	jmp    802115 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5f                   	pop    %edi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802128:	50                   	push   %eax
  802129:	e8 ca f1 ff ff       	call   8012f8 <fd_alloc>
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	89 c2                	mov    %eax,%edx
  802133:	85 c0                	test   %eax,%eax
  802135:	0f 88 2c 01 00 00    	js     802267 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80213b:	83 ec 04             	sub    $0x4,%esp
  80213e:	68 07 04 00 00       	push   $0x407
  802143:	ff 75 f4             	pushl  -0xc(%ebp)
  802146:	6a 00                	push   $0x0
  802148:	e8 4a eb ff ff       	call   800c97 <sys_page_alloc>
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	89 c2                	mov    %eax,%edx
  802152:	85 c0                	test   %eax,%eax
  802154:	0f 88 0d 01 00 00    	js     802267 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80215a:	83 ec 0c             	sub    $0xc,%esp
  80215d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	e8 92 f1 ff ff       	call   8012f8 <fd_alloc>
  802166:	89 c3                	mov    %eax,%ebx
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	85 c0                	test   %eax,%eax
  80216d:	0f 88 e2 00 00 00    	js     802255 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802173:	83 ec 04             	sub    $0x4,%esp
  802176:	68 07 04 00 00       	push   $0x407
  80217b:	ff 75 f0             	pushl  -0x10(%ebp)
  80217e:	6a 00                	push   $0x0
  802180:	e8 12 eb ff ff       	call   800c97 <sys_page_alloc>
  802185:	89 c3                	mov    %eax,%ebx
  802187:	83 c4 10             	add    $0x10,%esp
  80218a:	85 c0                	test   %eax,%eax
  80218c:	0f 88 c3 00 00 00    	js     802255 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802192:	83 ec 0c             	sub    $0xc,%esp
  802195:	ff 75 f4             	pushl  -0xc(%ebp)
  802198:	e8 44 f1 ff ff       	call   8012e1 <fd2data>
  80219d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219f:	83 c4 0c             	add    $0xc,%esp
  8021a2:	68 07 04 00 00       	push   $0x407
  8021a7:	50                   	push   %eax
  8021a8:	6a 00                	push   $0x0
  8021aa:	e8 e8 ea ff ff       	call   800c97 <sys_page_alloc>
  8021af:	89 c3                	mov    %eax,%ebx
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	0f 88 89 00 00 00    	js     802245 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021bc:	83 ec 0c             	sub    $0xc,%esp
  8021bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c2:	e8 1a f1 ff ff       	call   8012e1 <fd2data>
  8021c7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021ce:	50                   	push   %eax
  8021cf:	6a 00                	push   $0x0
  8021d1:	56                   	push   %esi
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 01 eb ff ff       	call   800cda <sys_page_map>
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	83 c4 20             	add    $0x20,%esp
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 55                	js     802237 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021e2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021eb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021f7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802200:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802205:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80220c:	83 ec 0c             	sub    $0xc,%esp
  80220f:	ff 75 f4             	pushl  -0xc(%ebp)
  802212:	e8 ba f0 ff ff       	call   8012d1 <fd2num>
  802217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80221a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80221c:	83 c4 04             	add    $0x4,%esp
  80221f:	ff 75 f0             	pushl  -0x10(%ebp)
  802222:	e8 aa f0 ff ff       	call   8012d1 <fd2num>
  802227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80222d:	83 c4 10             	add    $0x10,%esp
  802230:	ba 00 00 00 00       	mov    $0x0,%edx
  802235:	eb 30                	jmp    802267 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802237:	83 ec 08             	sub    $0x8,%esp
  80223a:	56                   	push   %esi
  80223b:	6a 00                	push   $0x0
  80223d:	e8 da ea ff ff       	call   800d1c <sys_page_unmap>
  802242:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802245:	83 ec 08             	sub    $0x8,%esp
  802248:	ff 75 f0             	pushl  -0x10(%ebp)
  80224b:	6a 00                	push   $0x0
  80224d:	e8 ca ea ff ff       	call   800d1c <sys_page_unmap>
  802252:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802255:	83 ec 08             	sub    $0x8,%esp
  802258:	ff 75 f4             	pushl  -0xc(%ebp)
  80225b:	6a 00                	push   $0x0
  80225d:	e8 ba ea ff ff       	call   800d1c <sys_page_unmap>
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802267:	89 d0                	mov    %edx,%eax
  802269:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802279:	50                   	push   %eax
  80227a:	ff 75 08             	pushl  0x8(%ebp)
  80227d:	e8 c5 f0 ff ff       	call   801347 <fd_lookup>
  802282:	83 c4 10             	add    $0x10,%esp
  802285:	85 c0                	test   %eax,%eax
  802287:	78 18                	js     8022a1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802289:	83 ec 0c             	sub    $0xc,%esp
  80228c:	ff 75 f4             	pushl  -0xc(%ebp)
  80228f:	e8 4d f0 ff ff       	call   8012e1 <fd2data>
	return _pipeisclosed(fd, p);
  802294:	89 c2                	mov    %eax,%edx
  802296:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802299:	e8 21 fd ff ff       	call   801fbf <_pipeisclosed>
  80229e:	83 c4 10             	add    $0x10,%esp
}
  8022a1:	c9                   	leave  
  8022a2:	c3                   	ret    

008022a3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    

008022ad <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ad:	55                   	push   %ebp
  8022ae:	89 e5                	mov    %esp,%ebp
  8022b0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022b3:	68 63 2e 80 00       	push   $0x802e63
  8022b8:	ff 75 0c             	pushl  0xc(%ebp)
  8022bb:	e8 d4 e5 ff ff       	call   800894 <strcpy>
	return 0;
}
  8022c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c5:	c9                   	leave  
  8022c6:	c3                   	ret    

008022c7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	57                   	push   %edi
  8022cb:	56                   	push   %esi
  8022cc:	53                   	push   %ebx
  8022cd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022d3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022d8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022de:	eb 2d                	jmp    80230d <devcons_write+0x46>
		m = n - tot;
  8022e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022e3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022e5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022e8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022ed:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f0:	83 ec 04             	sub    $0x4,%esp
  8022f3:	53                   	push   %ebx
  8022f4:	03 45 0c             	add    0xc(%ebp),%eax
  8022f7:	50                   	push   %eax
  8022f8:	57                   	push   %edi
  8022f9:	e8 28 e7 ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  8022fe:	83 c4 08             	add    $0x8,%esp
  802301:	53                   	push   %ebx
  802302:	57                   	push   %edi
  802303:	e8 d3 e8 ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802308:	01 de                	add    %ebx,%esi
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	89 f0                	mov    %esi,%eax
  80230f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802312:	72 cc                	jb     8022e0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802314:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5f                   	pop    %edi
  80231a:	5d                   	pop    %ebp
  80231b:	c3                   	ret    

0080231c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	83 ec 08             	sub    $0x8,%esp
  802322:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802327:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232b:	74 2a                	je     802357 <devcons_read+0x3b>
  80232d:	eb 05                	jmp    802334 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80232f:	e8 44 e9 ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802334:	e8 c0 e8 ff ff       	call   800bf9 <sys_cgetc>
  802339:	85 c0                	test   %eax,%eax
  80233b:	74 f2                	je     80232f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80233d:	85 c0                	test   %eax,%eax
  80233f:	78 16                	js     802357 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802341:	83 f8 04             	cmp    $0x4,%eax
  802344:	74 0c                	je     802352 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802346:	8b 55 0c             	mov    0xc(%ebp),%edx
  802349:	88 02                	mov    %al,(%edx)
	return 1;
  80234b:	b8 01 00 00 00       	mov    $0x1,%eax
  802350:	eb 05                	jmp    802357 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802352:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802357:	c9                   	leave  
  802358:	c3                   	ret    

00802359 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80235f:	8b 45 08             	mov    0x8(%ebp),%eax
  802362:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802365:	6a 01                	push   $0x1
  802367:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236a:	50                   	push   %eax
  80236b:	e8 6b e8 ff ff       	call   800bdb <sys_cputs>
}
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	c9                   	leave  
  802374:	c3                   	ret    

00802375 <getchar>:

int
getchar(void)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80237b:	6a 01                	push   $0x1
  80237d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802380:	50                   	push   %eax
  802381:	6a 00                	push   $0x0
  802383:	e8 25 f2 ff ff       	call   8015ad <read>
	if (r < 0)
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	85 c0                	test   %eax,%eax
  80238d:	78 0f                	js     80239e <getchar+0x29>
		return r;
	if (r < 1)
  80238f:	85 c0                	test   %eax,%eax
  802391:	7e 06                	jle    802399 <getchar+0x24>
		return -E_EOF;
	return c;
  802393:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802397:	eb 05                	jmp    80239e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802399:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80239e:	c9                   	leave  
  80239f:	c3                   	ret    

008023a0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a9:	50                   	push   %eax
  8023aa:	ff 75 08             	pushl  0x8(%ebp)
  8023ad:	e8 95 ef ff ff       	call   801347 <fd_lookup>
  8023b2:	83 c4 10             	add    $0x10,%esp
  8023b5:	85 c0                	test   %eax,%eax
  8023b7:	78 11                	js     8023ca <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023c2:	39 10                	cmp    %edx,(%eax)
  8023c4:	0f 94 c0             	sete   %al
  8023c7:	0f b6 c0             	movzbl %al,%eax
}
  8023ca:	c9                   	leave  
  8023cb:	c3                   	ret    

008023cc <opencons>:

int
opencons(void)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d5:	50                   	push   %eax
  8023d6:	e8 1d ef ff ff       	call   8012f8 <fd_alloc>
  8023db:	83 c4 10             	add    $0x10,%esp
		return r;
  8023de:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	78 3e                	js     802422 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023e4:	83 ec 04             	sub    $0x4,%esp
  8023e7:	68 07 04 00 00       	push   $0x407
  8023ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ef:	6a 00                	push   $0x0
  8023f1:	e8 a1 e8 ff ff       	call   800c97 <sys_page_alloc>
  8023f6:	83 c4 10             	add    $0x10,%esp
		return r;
  8023f9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	78 23                	js     802422 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023ff:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802405:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802408:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80240a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802414:	83 ec 0c             	sub    $0xc,%esp
  802417:	50                   	push   %eax
  802418:	e8 b4 ee ff ff       	call   8012d1 <fd2num>
  80241d:	89 c2                	mov    %eax,%edx
  80241f:	83 c4 10             	add    $0x10,%esp
}
  802422:	89 d0                	mov    %edx,%eax
  802424:	c9                   	leave  
  802425:	c3                   	ret    

00802426 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80242c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802433:	75 2c                	jne    802461 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802435:	83 ec 04             	sub    $0x4,%esp
  802438:	6a 07                	push   $0x7
  80243a:	68 00 f0 bf ee       	push   $0xeebff000
  80243f:	6a 00                	push   $0x0
  802441:	e8 51 e8 ff ff       	call   800c97 <sys_page_alloc>
  802446:	83 c4 10             	add    $0x10,%esp
  802449:	85 c0                	test   %eax,%eax
  80244b:	79 14                	jns    802461 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80244d:	83 ec 04             	sub    $0x4,%esp
  802450:	68 6f 2e 80 00       	push   $0x802e6f
  802455:	6a 22                	push   $0x22
  802457:	68 86 2e 80 00       	push   $0x802e86
  80245c:	e8 d5 dd ff ff       	call   800236 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802461:	8b 45 08             	mov    0x8(%ebp),%eax
  802464:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802469:	83 ec 08             	sub    $0x8,%esp
  80246c:	68 95 24 80 00       	push   $0x802495
  802471:	6a 00                	push   $0x0
  802473:	e8 6a e9 ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  802478:	83 c4 10             	add    $0x10,%esp
  80247b:	85 c0                	test   %eax,%eax
  80247d:	79 14                	jns    802493 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80247f:	83 ec 04             	sub    $0x4,%esp
  802482:	68 94 2e 80 00       	push   $0x802e94
  802487:	6a 27                	push   $0x27
  802489:	68 86 2e 80 00       	push   $0x802e86
  80248e:	e8 a3 dd ff ff       	call   800236 <_panic>
    
}
  802493:	c9                   	leave  
  802494:	c3                   	ret    

00802495 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802495:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802496:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80249b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80249d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8024a0:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8024a4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8024a9:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8024ad:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8024af:	83 c4 08             	add    $0x8,%esp
	popal
  8024b2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8024b3:	83 c4 04             	add    $0x4,%esp
	popfl
  8024b6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8024b7:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024b8:	c3                   	ret    

008024b9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024bf:	89 d0                	mov    %edx,%eax
  8024c1:	c1 e8 16             	shr    $0x16,%eax
  8024c4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024cb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024d0:	f6 c1 01             	test   $0x1,%cl
  8024d3:	74 1d                	je     8024f2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024d5:	c1 ea 0c             	shr    $0xc,%edx
  8024d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024df:	f6 c2 01             	test   $0x1,%dl
  8024e2:	74 0e                	je     8024f2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024e4:	c1 ea 0c             	shr    $0xc,%edx
  8024e7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024ee:	ef 
  8024ef:	0f b7 c0             	movzwl %ax,%eax
}
  8024f2:	5d                   	pop    %ebp
  8024f3:	c3                   	ret    
  8024f4:	66 90                	xchg   %ax,%ax
  8024f6:	66 90                	xchg   %ax,%ax
  8024f8:	66 90                	xchg   %ax,%ax
  8024fa:	66 90                	xchg   %ax,%ax
  8024fc:	66 90                	xchg   %ax,%ax
  8024fe:	66 90                	xchg   %ax,%ax

00802500 <__udivdi3>:
  802500:	55                   	push   %ebp
  802501:	57                   	push   %edi
  802502:	56                   	push   %esi
  802503:	53                   	push   %ebx
  802504:	83 ec 1c             	sub    $0x1c,%esp
  802507:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80250b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80250f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802513:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802517:	85 f6                	test   %esi,%esi
  802519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80251d:	89 ca                	mov    %ecx,%edx
  80251f:	89 f8                	mov    %edi,%eax
  802521:	75 3d                	jne    802560 <__udivdi3+0x60>
  802523:	39 cf                	cmp    %ecx,%edi
  802525:	0f 87 c5 00 00 00    	ja     8025f0 <__udivdi3+0xf0>
  80252b:	85 ff                	test   %edi,%edi
  80252d:	89 fd                	mov    %edi,%ebp
  80252f:	75 0b                	jne    80253c <__udivdi3+0x3c>
  802531:	b8 01 00 00 00       	mov    $0x1,%eax
  802536:	31 d2                	xor    %edx,%edx
  802538:	f7 f7                	div    %edi
  80253a:	89 c5                	mov    %eax,%ebp
  80253c:	89 c8                	mov    %ecx,%eax
  80253e:	31 d2                	xor    %edx,%edx
  802540:	f7 f5                	div    %ebp
  802542:	89 c1                	mov    %eax,%ecx
  802544:	89 d8                	mov    %ebx,%eax
  802546:	89 cf                	mov    %ecx,%edi
  802548:	f7 f5                	div    %ebp
  80254a:	89 c3                	mov    %eax,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	39 ce                	cmp    %ecx,%esi
  802562:	77 74                	ja     8025d8 <__udivdi3+0xd8>
  802564:	0f bd fe             	bsr    %esi,%edi
  802567:	83 f7 1f             	xor    $0x1f,%edi
  80256a:	0f 84 98 00 00 00    	je     802608 <__udivdi3+0x108>
  802570:	bb 20 00 00 00       	mov    $0x20,%ebx
  802575:	89 f9                	mov    %edi,%ecx
  802577:	89 c5                	mov    %eax,%ebp
  802579:	29 fb                	sub    %edi,%ebx
  80257b:	d3 e6                	shl    %cl,%esi
  80257d:	89 d9                	mov    %ebx,%ecx
  80257f:	d3 ed                	shr    %cl,%ebp
  802581:	89 f9                	mov    %edi,%ecx
  802583:	d3 e0                	shl    %cl,%eax
  802585:	09 ee                	or     %ebp,%esi
  802587:	89 d9                	mov    %ebx,%ecx
  802589:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80258d:	89 d5                	mov    %edx,%ebp
  80258f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802593:	d3 ed                	shr    %cl,%ebp
  802595:	89 f9                	mov    %edi,%ecx
  802597:	d3 e2                	shl    %cl,%edx
  802599:	89 d9                	mov    %ebx,%ecx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	09 c2                	or     %eax,%edx
  80259f:	89 d0                	mov    %edx,%eax
  8025a1:	89 ea                	mov    %ebp,%edx
  8025a3:	f7 f6                	div    %esi
  8025a5:	89 d5                	mov    %edx,%ebp
  8025a7:	89 c3                	mov    %eax,%ebx
  8025a9:	f7 64 24 0c          	mull   0xc(%esp)
  8025ad:	39 d5                	cmp    %edx,%ebp
  8025af:	72 10                	jb     8025c1 <__udivdi3+0xc1>
  8025b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	d3 e6                	shl    %cl,%esi
  8025b9:	39 c6                	cmp    %eax,%esi
  8025bb:	73 07                	jae    8025c4 <__udivdi3+0xc4>
  8025bd:	39 d5                	cmp    %edx,%ebp
  8025bf:	75 03                	jne    8025c4 <__udivdi3+0xc4>
  8025c1:	83 eb 01             	sub    $0x1,%ebx
  8025c4:	31 ff                	xor    %edi,%edi
  8025c6:	89 d8                	mov    %ebx,%eax
  8025c8:	89 fa                	mov    %edi,%edx
  8025ca:	83 c4 1c             	add    $0x1c,%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    
  8025d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d8:	31 ff                	xor    %edi,%edi
  8025da:	31 db                	xor    %ebx,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	89 d8                	mov    %ebx,%eax
  8025f2:	f7 f7                	div    %edi
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 c3                	mov    %eax,%ebx
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	89 fa                	mov    %edi,%edx
  8025fc:	83 c4 1c             	add    $0x1c,%esp
  8025ff:	5b                   	pop    %ebx
  802600:	5e                   	pop    %esi
  802601:	5f                   	pop    %edi
  802602:	5d                   	pop    %ebp
  802603:	c3                   	ret    
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	39 ce                	cmp    %ecx,%esi
  80260a:	72 0c                	jb     802618 <__udivdi3+0x118>
  80260c:	31 db                	xor    %ebx,%ebx
  80260e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802612:	0f 87 34 ff ff ff    	ja     80254c <__udivdi3+0x4c>
  802618:	bb 01 00 00 00       	mov    $0x1,%ebx
  80261d:	e9 2a ff ff ff       	jmp    80254c <__udivdi3+0x4c>
  802622:	66 90                	xchg   %ax,%ax
  802624:	66 90                	xchg   %ax,%ax
  802626:	66 90                	xchg   %ax,%ax
  802628:	66 90                	xchg   %ax,%ax
  80262a:	66 90                	xchg   %ax,%ax
  80262c:	66 90                	xchg   %ax,%ax
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__umoddi3>:
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	83 ec 1c             	sub    $0x1c,%esp
  802637:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80263b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80263f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802643:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802647:	85 d2                	test   %edx,%edx
  802649:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80264d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802651:	89 f3                	mov    %esi,%ebx
  802653:	89 3c 24             	mov    %edi,(%esp)
  802656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80265a:	75 1c                	jne    802678 <__umoddi3+0x48>
  80265c:	39 f7                	cmp    %esi,%edi
  80265e:	76 50                	jbe    8026b0 <__umoddi3+0x80>
  802660:	89 c8                	mov    %ecx,%eax
  802662:	89 f2                	mov    %esi,%edx
  802664:	f7 f7                	div    %edi
  802666:	89 d0                	mov    %edx,%eax
  802668:	31 d2                	xor    %edx,%edx
  80266a:	83 c4 1c             	add    $0x1c,%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5f                   	pop    %edi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    
  802672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802678:	39 f2                	cmp    %esi,%edx
  80267a:	89 d0                	mov    %edx,%eax
  80267c:	77 52                	ja     8026d0 <__umoddi3+0xa0>
  80267e:	0f bd ea             	bsr    %edx,%ebp
  802681:	83 f5 1f             	xor    $0x1f,%ebp
  802684:	75 5a                	jne    8026e0 <__umoddi3+0xb0>
  802686:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80268a:	0f 82 e0 00 00 00    	jb     802770 <__umoddi3+0x140>
  802690:	39 0c 24             	cmp    %ecx,(%esp)
  802693:	0f 86 d7 00 00 00    	jbe    802770 <__umoddi3+0x140>
  802699:	8b 44 24 08          	mov    0x8(%esp),%eax
  80269d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026a1:	83 c4 1c             	add    $0x1c,%esp
  8026a4:	5b                   	pop    %ebx
  8026a5:	5e                   	pop    %esi
  8026a6:	5f                   	pop    %edi
  8026a7:	5d                   	pop    %ebp
  8026a8:	c3                   	ret    
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	85 ff                	test   %edi,%edi
  8026b2:	89 fd                	mov    %edi,%ebp
  8026b4:	75 0b                	jne    8026c1 <__umoddi3+0x91>
  8026b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bb:	31 d2                	xor    %edx,%edx
  8026bd:	f7 f7                	div    %edi
  8026bf:	89 c5                	mov    %eax,%ebp
  8026c1:	89 f0                	mov    %esi,%eax
  8026c3:	31 d2                	xor    %edx,%edx
  8026c5:	f7 f5                	div    %ebp
  8026c7:	89 c8                	mov    %ecx,%eax
  8026c9:	f7 f5                	div    %ebp
  8026cb:	89 d0                	mov    %edx,%eax
  8026cd:	eb 99                	jmp    802668 <__umoddi3+0x38>
  8026cf:	90                   	nop
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	83 c4 1c             	add    $0x1c,%esp
  8026d7:	5b                   	pop    %ebx
  8026d8:	5e                   	pop    %esi
  8026d9:	5f                   	pop    %edi
  8026da:	5d                   	pop    %ebp
  8026db:	c3                   	ret    
  8026dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	8b 34 24             	mov    (%esp),%esi
  8026e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026e8:	89 e9                	mov    %ebp,%ecx
  8026ea:	29 ef                	sub    %ebp,%edi
  8026ec:	d3 e0                	shl    %cl,%eax
  8026ee:	89 f9                	mov    %edi,%ecx
  8026f0:	89 f2                	mov    %esi,%edx
  8026f2:	d3 ea                	shr    %cl,%edx
  8026f4:	89 e9                	mov    %ebp,%ecx
  8026f6:	09 c2                	or     %eax,%edx
  8026f8:	89 d8                	mov    %ebx,%eax
  8026fa:	89 14 24             	mov    %edx,(%esp)
  8026fd:	89 f2                	mov    %esi,%edx
  8026ff:	d3 e2                	shl    %cl,%edx
  802701:	89 f9                	mov    %edi,%ecx
  802703:	89 54 24 04          	mov    %edx,0x4(%esp)
  802707:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	89 c6                	mov    %eax,%esi
  802711:	d3 e3                	shl    %cl,%ebx
  802713:	89 f9                	mov    %edi,%ecx
  802715:	89 d0                	mov    %edx,%eax
  802717:	d3 e8                	shr    %cl,%eax
  802719:	89 e9                	mov    %ebp,%ecx
  80271b:	09 d8                	or     %ebx,%eax
  80271d:	89 d3                	mov    %edx,%ebx
  80271f:	89 f2                	mov    %esi,%edx
  802721:	f7 34 24             	divl   (%esp)
  802724:	89 d6                	mov    %edx,%esi
  802726:	d3 e3                	shl    %cl,%ebx
  802728:	f7 64 24 04          	mull   0x4(%esp)
  80272c:	39 d6                	cmp    %edx,%esi
  80272e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802732:	89 d1                	mov    %edx,%ecx
  802734:	89 c3                	mov    %eax,%ebx
  802736:	72 08                	jb     802740 <__umoddi3+0x110>
  802738:	75 11                	jne    80274b <__umoddi3+0x11b>
  80273a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80273e:	73 0b                	jae    80274b <__umoddi3+0x11b>
  802740:	2b 44 24 04          	sub    0x4(%esp),%eax
  802744:	1b 14 24             	sbb    (%esp),%edx
  802747:	89 d1                	mov    %edx,%ecx
  802749:	89 c3                	mov    %eax,%ebx
  80274b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80274f:	29 da                	sub    %ebx,%edx
  802751:	19 ce                	sbb    %ecx,%esi
  802753:	89 f9                	mov    %edi,%ecx
  802755:	89 f0                	mov    %esi,%eax
  802757:	d3 e0                	shl    %cl,%eax
  802759:	89 e9                	mov    %ebp,%ecx
  80275b:	d3 ea                	shr    %cl,%edx
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	d3 ee                	shr    %cl,%esi
  802761:	09 d0                	or     %edx,%eax
  802763:	89 f2                	mov    %esi,%edx
  802765:	83 c4 1c             	add    $0x1c,%esp
  802768:	5b                   	pop    %ebx
  802769:	5e                   	pop    %esi
  80276a:	5f                   	pop    %edi
  80276b:	5d                   	pop    %ebp
  80276c:	c3                   	ret    
  80276d:	8d 76 00             	lea    0x0(%esi),%esi
  802770:	29 f9                	sub    %edi,%ecx
  802772:	19 d6                	sbb    %edx,%esi
  802774:	89 74 24 04          	mov    %esi,0x4(%esp)
  802778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80277c:	e9 18 ff ff ff       	jmp    802699 <__umoddi3+0x69>
