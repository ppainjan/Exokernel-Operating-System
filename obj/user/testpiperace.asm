
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 a0 27 80 00       	push   $0x8027a0
  800040:	e8 e2 02 00 00       	call   800327 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 20 21 00 00       	call   802170 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 b9 27 80 00       	push   $0x8027b9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 c2 27 80 00       	push   $0x8027c2
  800064:	e8 e5 01 00 00       	call   80024e <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 6c 0f 00 00       	call   800fda <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 d6 27 80 00       	push   $0x8027d6
  80007a:	6a 10                	push   $0x10
  80007c:	68 c2 27 80 00       	push   $0x8027c2
  800081:	e8 c8 01 00 00       	call   80024e <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 f4 13 00 00       	call   801489 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 1b 22 00 00       	call   8022c3 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 df 27 80 00       	push   $0x8027df
  8000b7:	e8 6b 02 00 00       	call   800327 <cprintf>
				exit();
  8000bc:	e8 73 01 00 00       	call   800234 <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 c7 0b 00 00       	call   800c90 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 13 11 00 00       	call   8011ef <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 fa 27 80 00       	push   $0x8027fa
  8000e8:	e8 3a 02 00 00       	call   800327 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 05 28 80 00       	push   $0x802805
  800108:	e8 1a 02 00 00       	call   800327 <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 bf 13 00 00       	call   8014d9 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 a4 13 00 00       	call   8014d9 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 10 28 80 00       	push   $0x802810
  800148:	e8 da 01 00 00       	call   800327 <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 6b 21 00 00       	call   8022c3 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 6c 28 80 00       	push   $0x80286c
  800167:	6a 3a                	push   $0x3a
  800169:	68 c2 27 80 00       	push   $0x8027c2
  80016e:	e8 db 00 00 00       	call   80024e <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 dd 11 00 00       	call   80135f <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 26 28 80 00       	push   $0x802826
  80018f:	6a 3c                	push   $0x3c
  800191:	68 c2 27 80 00       	push   $0x8027c2
  800196:	e8 b3 00 00 00       	call   80024e <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 53 11 00 00       	call   8012f9 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 4a 19 00 00       	call   801af8 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 3e 28 80 00       	push   $0x80283e
  8001be:	e8 64 01 00 00       	call   800327 <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 54 28 80 00       	push   $0x802854
  8001d5:	e8 4d 01 00 00       	call   800327 <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001ef:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8001f6:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8001f9:	e8 73 0a 00 00       	call   800c71 <sys_getenvid>
  8001fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800203:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800206:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800210:	85 db                	test   %ebx,%ebx
  800212:	7e 07                	jle    80021b <libmain+0x37>
		binaryname = argv[0];
  800214:	8b 06                	mov    (%esi),%eax
  800216:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	e8 0e fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023a:	e8 75 12 00 00       	call   8014b4 <close_all>
	sys_env_destroy(0);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	6a 00                	push   $0x0
  800244:	e8 e7 09 00 00       	call   800c30 <sys_env_destroy>
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800253:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800256:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025c:	e8 10 0a 00 00       	call   800c71 <sys_getenvid>
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	56                   	push   %esi
  80026b:	50                   	push   %eax
  80026c:	68 a0 28 80 00       	push   $0x8028a0
  800271:	e8 b1 00 00 00       	call   800327 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800276:	83 c4 18             	add    $0x18,%esp
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	e8 54 00 00 00       	call   8002d6 <vcprintf>
	cprintf("\n");
  800282:	c7 04 24 1a 2c 80 00 	movl   $0x802c1a,(%esp)
  800289:	e8 99 00 00 00       	call   800327 <cprintf>
  80028e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800291:	cc                   	int3   
  800292:	eb fd                	jmp    800291 <_panic+0x43>

00800294 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	53                   	push   %ebx
  800298:	83 ec 04             	sub    $0x4,%esp
  80029b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029e:	8b 13                	mov    (%ebx),%edx
  8002a0:	8d 42 01             	lea    0x1(%edx),%eax
  8002a3:	89 03                	mov    %eax,(%ebx)
  8002a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b1:	75 1a                	jne    8002cd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	68 ff 00 00 00       	push   $0xff
  8002bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8002be:	50                   	push   %eax
  8002bf:	e8 2f 09 00 00       	call   800bf3 <sys_cputs>
		b->idx = 0;
  8002c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002ca:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002cd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e6:	00 00 00 
	b.cnt = 0;
  8002e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	68 94 02 80 00       	push   $0x800294
  800305:	e8 54 01 00 00       	call   80045e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030a:	83 c4 08             	add    $0x8,%esp
  80030d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800313:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800319:	50                   	push   %eax
  80031a:	e8 d4 08 00 00       	call   800bf3 <sys_cputs>

	return b.cnt;
}
  80031f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800330:	50                   	push   %eax
  800331:	ff 75 08             	pushl  0x8(%ebp)
  800334:	e8 9d ff ff ff       	call   8002d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 1c             	sub    $0x1c,%esp
  800344:	89 c7                	mov    %eax,%edi
  800346:	89 d6                	mov    %edx,%esi
  800348:	8b 45 08             	mov    0x8(%ebp),%eax
  80034b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80034e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800351:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800354:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800357:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80035f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800362:	39 d3                	cmp    %edx,%ebx
  800364:	72 05                	jb     80036b <printnum+0x30>
  800366:	39 45 10             	cmp    %eax,0x10(%ebp)
  800369:	77 45                	ja     8003b0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036b:	83 ec 0c             	sub    $0xc,%esp
  80036e:	ff 75 18             	pushl  0x18(%ebp)
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800377:	53                   	push   %ebx
  800378:	ff 75 10             	pushl  0x10(%ebp)
  80037b:	83 ec 08             	sub    $0x8,%esp
  80037e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800381:	ff 75 e0             	pushl  -0x20(%ebp)
  800384:	ff 75 dc             	pushl  -0x24(%ebp)
  800387:	ff 75 d8             	pushl  -0x28(%ebp)
  80038a:	e8 81 21 00 00       	call   802510 <__udivdi3>
  80038f:	83 c4 18             	add    $0x18,%esp
  800392:	52                   	push   %edx
  800393:	50                   	push   %eax
  800394:	89 f2                	mov    %esi,%edx
  800396:	89 f8                	mov    %edi,%eax
  800398:	e8 9e ff ff ff       	call   80033b <printnum>
  80039d:	83 c4 20             	add    $0x20,%esp
  8003a0:	eb 18                	jmp    8003ba <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	ff 75 18             	pushl  0x18(%ebp)
  8003a9:	ff d7                	call   *%edi
  8003ab:	83 c4 10             	add    $0x10,%esp
  8003ae:	eb 03                	jmp    8003b3 <printnum+0x78>
  8003b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b3:	83 eb 01             	sub    $0x1,%ebx
  8003b6:	85 db                	test   %ebx,%ebx
  8003b8:	7f e8                	jg     8003a2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	56                   	push   %esi
  8003be:	83 ec 04             	sub    $0x4,%esp
  8003c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cd:	e8 6e 22 00 00       	call   802640 <__umoddi3>
  8003d2:	83 c4 14             	add    $0x14,%esp
  8003d5:	0f be 80 c3 28 80 00 	movsbl 0x8028c3(%eax),%eax
  8003dc:	50                   	push   %eax
  8003dd:	ff d7                	call   *%edi
}
  8003df:	83 c4 10             	add    $0x10,%esp
  8003e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e5:	5b                   	pop    %ebx
  8003e6:	5e                   	pop    %esi
  8003e7:	5f                   	pop    %edi
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ed:	83 fa 01             	cmp    $0x1,%edx
  8003f0:	7e 0e                	jle    800400 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f7:	89 08                	mov    %ecx,(%eax)
  8003f9:	8b 02                	mov    (%edx),%eax
  8003fb:	8b 52 04             	mov    0x4(%edx),%edx
  8003fe:	eb 22                	jmp    800422 <getuint+0x38>
	else if (lflag)
  800400:	85 d2                	test   %edx,%edx
  800402:	74 10                	je     800414 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 4a 04             	lea    0x4(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	eb 0e                	jmp    800422 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800414:	8b 10                	mov    (%eax),%edx
  800416:	8d 4a 04             	lea    0x4(%edx),%ecx
  800419:	89 08                	mov    %ecx,(%eax)
  80041b:	8b 02                	mov    (%edx),%eax
  80041d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80042e:	8b 10                	mov    (%eax),%edx
  800430:	3b 50 04             	cmp    0x4(%eax),%edx
  800433:	73 0a                	jae    80043f <sprintputch+0x1b>
		*b->buf++ = ch;
  800435:	8d 4a 01             	lea    0x1(%edx),%ecx
  800438:	89 08                	mov    %ecx,(%eax)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	88 02                	mov    %al,(%edx)
}
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800447:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044a:	50                   	push   %eax
  80044b:	ff 75 10             	pushl  0x10(%ebp)
  80044e:	ff 75 0c             	pushl  0xc(%ebp)
  800451:	ff 75 08             	pushl  0x8(%ebp)
  800454:	e8 05 00 00 00       	call   80045e <vprintfmt>
	va_end(ap);
}
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	57                   	push   %edi
  800462:	56                   	push   %esi
  800463:	53                   	push   %ebx
  800464:	83 ec 2c             	sub    $0x2c,%esp
  800467:	8b 75 08             	mov    0x8(%ebp),%esi
  80046a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800470:	eb 12                	jmp    800484 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800472:	85 c0                	test   %eax,%eax
  800474:	0f 84 89 03 00 00    	je     800803 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	50                   	push   %eax
  80047f:	ff d6                	call   *%esi
  800481:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800484:	83 c7 01             	add    $0x1,%edi
  800487:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048b:	83 f8 25             	cmp    $0x25,%eax
  80048e:	75 e2                	jne    800472 <vprintfmt+0x14>
  800490:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800494:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80049b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	eb 07                	jmp    8004b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8d 47 01             	lea    0x1(%edi),%eax
  8004ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bd:	0f b6 07             	movzbl (%edi),%eax
  8004c0:	0f b6 c8             	movzbl %al,%ecx
  8004c3:	83 e8 23             	sub    $0x23,%eax
  8004c6:	3c 55                	cmp    $0x55,%al
  8004c8:	0f 87 1a 03 00 00    	ja     8007e8 <vprintfmt+0x38a>
  8004ce:	0f b6 c0             	movzbl %al,%eax
  8004d1:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004df:	eb d6                	jmp    8004b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ef:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004f3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004f6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004f9:	83 fa 09             	cmp    $0x9,%edx
  8004fc:	77 39                	ja     800537 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800501:	eb e9                	jmp    8004ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 48 04             	lea    0x4(%eax),%ecx
  800509:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800514:	eb 27                	jmp    80053d <vprintfmt+0xdf>
  800516:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800519:	85 c0                	test   %eax,%eax
  80051b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800520:	0f 49 c8             	cmovns %eax,%ecx
  800523:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	eb 8c                	jmp    8004b7 <vprintfmt+0x59>
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80052e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800535:	eb 80                	jmp    8004b7 <vprintfmt+0x59>
  800537:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80053d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800541:	0f 89 70 ff ff ff    	jns    8004b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800547:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80054a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800554:	e9 5e ff ff ff       	jmp    8004b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800559:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80055f:	e9 53 ff ff ff       	jmp    8004b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	ff 30                	pushl  (%eax)
  800573:	ff d6                	call   *%esi
			break;
  800575:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80057b:	e9 04 ff ff ff       	jmp    800484 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	99                   	cltd   
  80058c:	31 d0                	xor    %edx,%eax
  80058e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800590:	83 f8 0f             	cmp    $0xf,%eax
  800593:	7f 0b                	jg     8005a0 <vprintfmt+0x142>
  800595:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	75 18                	jne    8005b8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005a0:	50                   	push   %eax
  8005a1:	68 db 28 80 00       	push   $0x8028db
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 94 fe ff ff       	call   800441 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b3:	e9 cc fe ff ff       	jmp    800484 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005b8:	52                   	push   %edx
  8005b9:	68 11 2e 80 00       	push   $0x802e11
  8005be:	53                   	push   %ebx
  8005bf:	56                   	push   %esi
  8005c0:	e8 7c fe ff ff       	call   800441 <printfmt>
  8005c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 b4 fe ff ff       	jmp    800484 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005db:	85 ff                	test   %edi,%edi
  8005dd:	b8 d4 28 80 00       	mov    $0x8028d4,%eax
  8005e2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e9:	0f 8e 94 00 00 00    	jle    800683 <vprintfmt+0x225>
  8005ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005f3:	0f 84 98 00 00 00    	je     800691 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ff:	57                   	push   %edi
  800600:	e8 86 02 00 00       	call   80088b <strnlen>
  800605:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800608:	29 c1                	sub    %eax,%ecx
  80060a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80060d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800610:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800614:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800617:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80061a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061c:	eb 0f                	jmp    80062d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	ff 75 e0             	pushl  -0x20(%ebp)
  800625:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800627:	83 ef 01             	sub    $0x1,%edi
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	85 ff                	test   %edi,%edi
  80062f:	7f ed                	jg     80061e <vprintfmt+0x1c0>
  800631:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800634:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800637:	85 c9                	test   %ecx,%ecx
  800639:	b8 00 00 00 00       	mov    $0x0,%eax
  80063e:	0f 49 c1             	cmovns %ecx,%eax
  800641:	29 c1                	sub    %eax,%ecx
  800643:	89 75 08             	mov    %esi,0x8(%ebp)
  800646:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800649:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064c:	89 cb                	mov    %ecx,%ebx
  80064e:	eb 4d                	jmp    80069d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800650:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800654:	74 1b                	je     800671 <vprintfmt+0x213>
  800656:	0f be c0             	movsbl %al,%eax
  800659:	83 e8 20             	sub    $0x20,%eax
  80065c:	83 f8 5e             	cmp    $0x5e,%eax
  80065f:	76 10                	jbe    800671 <vprintfmt+0x213>
					putch('?', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	6a 3f                	push   $0x3f
  800669:	ff 55 08             	call   *0x8(%ebp)
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	ff 75 0c             	pushl  0xc(%ebp)
  800677:	52                   	push   %edx
  800678:	ff 55 08             	call   *0x8(%ebp)
  80067b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067e:	83 eb 01             	sub    $0x1,%ebx
  800681:	eb 1a                	jmp    80069d <vprintfmt+0x23f>
  800683:	89 75 08             	mov    %esi,0x8(%ebp)
  800686:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800689:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068f:	eb 0c                	jmp    80069d <vprintfmt+0x23f>
  800691:	89 75 08             	mov    %esi,0x8(%ebp)
  800694:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800697:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80069d:	83 c7 01             	add    $0x1,%edi
  8006a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a4:	0f be d0             	movsbl %al,%edx
  8006a7:	85 d2                	test   %edx,%edx
  8006a9:	74 23                	je     8006ce <vprintfmt+0x270>
  8006ab:	85 f6                	test   %esi,%esi
  8006ad:	78 a1                	js     800650 <vprintfmt+0x1f2>
  8006af:	83 ee 01             	sub    $0x1,%esi
  8006b2:	79 9c                	jns    800650 <vprintfmt+0x1f2>
  8006b4:	89 df                	mov    %ebx,%edi
  8006b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006bc:	eb 18                	jmp    8006d6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 20                	push   $0x20
  8006c4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 08                	jmp    8006d6 <vprintfmt+0x278>
  8006ce:	89 df                	mov    %ebx,%edi
  8006d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	85 ff                	test   %edi,%edi
  8006d8:	7f e4                	jg     8006be <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 a2 fd ff ff       	jmp    800484 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e2:	83 fa 01             	cmp    $0x1,%edx
  8006e5:	7e 16                	jle    8006fd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 50 08             	lea    0x8(%eax),%edx
  8006ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f0:	8b 50 04             	mov    0x4(%eax),%edx
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006fb:	eb 32                	jmp    80072f <vprintfmt+0x2d1>
	else if (lflag)
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	74 18                	je     800719 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800717:	eb 16                	jmp    80072f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 04             	lea    0x4(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)
  800722:	8b 00                	mov    (%eax),%eax
  800724:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800727:	89 c1                	mov    %eax,%ecx
  800729:	c1 f9 1f             	sar    $0x1f,%ecx
  80072c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800732:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800735:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80073a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80073e:	79 74                	jns    8007b4 <vprintfmt+0x356>
				putch('-', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 2d                	push   $0x2d
  800746:	ff d6                	call   *%esi
				num = -(long long) num;
  800748:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80074e:	f7 d8                	neg    %eax
  800750:	83 d2 00             	adc    $0x0,%edx
  800753:	f7 da                	neg    %edx
  800755:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800758:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80075d:	eb 55                	jmp    8007b4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 83 fc ff ff       	call   8003ea <getuint>
			base = 10;
  800767:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80076c:	eb 46                	jmp    8007b4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	e8 74 fc ff ff       	call   8003ea <getuint>
		        base = 8;
  800776:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80077b:	eb 37                	jmp    8007b4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 30                	push   $0x30
  800783:	ff d6                	call   *%esi
			putch('x', putdat);
  800785:	83 c4 08             	add    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 78                	push   $0x78
  80078b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8d 50 04             	lea    0x4(%eax),%edx
  800793:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800796:	8b 00                	mov    (%eax),%eax
  800798:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80079d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a5:	eb 0d                	jmp    8007b4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007aa:	e8 3b fc ff ff       	call   8003ea <getuint>
			base = 16;
  8007af:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b4:	83 ec 0c             	sub    $0xc,%esp
  8007b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007bb:	57                   	push   %edi
  8007bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bf:	51                   	push   %ecx
  8007c0:	52                   	push   %edx
  8007c1:	50                   	push   %eax
  8007c2:	89 da                	mov    %ebx,%edx
  8007c4:	89 f0                	mov    %esi,%eax
  8007c6:	e8 70 fb ff ff       	call   80033b <printnum>
			break;
  8007cb:	83 c4 20             	add    $0x20,%esp
  8007ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d1:	e9 ae fc ff ff       	jmp    800484 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	51                   	push   %ecx
  8007db:	ff d6                	call   *%esi
			break;
  8007dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e3:	e9 9c fc ff ff       	jmp    800484 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	53                   	push   %ebx
  8007ec:	6a 25                	push   $0x25
  8007ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	eb 03                	jmp    8007f8 <vprintfmt+0x39a>
  8007f5:	83 ef 01             	sub    $0x1,%edi
  8007f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007fc:	75 f7                	jne    8007f5 <vprintfmt+0x397>
  8007fe:	e9 81 fc ff ff       	jmp    800484 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800803:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5f                   	pop    %edi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	83 ec 18             	sub    $0x18,%esp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800817:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800821:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 26                	je     800852 <vsnprintf+0x47>
  80082c:	85 d2                	test   %edx,%edx
  80082e:	7e 22                	jle    800852 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800830:	ff 75 14             	pushl  0x14(%ebp)
  800833:	ff 75 10             	pushl  0x10(%ebp)
  800836:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	68 24 04 80 00       	push   $0x800424
  80083f:	e8 1a fc ff ff       	call   80045e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800844:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800847:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	eb 05                	jmp    800857 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800862:	50                   	push   %eax
  800863:	ff 75 10             	pushl  0x10(%ebp)
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	ff 75 08             	pushl  0x8(%ebp)
  80086c:	e8 9a ff ff ff       	call   80080b <vsnprintf>
	va_end(ap);

	return rc;
}
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	eb 03                	jmp    800883 <strlen+0x10>
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0xd>
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	ba 00 00 00 00       	mov    $0x0,%edx
  800899:	eb 03                	jmp    80089e <strnlen+0x13>
		n++;
  80089b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089e:	39 c2                	cmp    %eax,%edx
  8008a0:	74 08                	je     8008aa <strnlen+0x1f>
  8008a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008a6:	75 f3                	jne    80089b <strnlen+0x10>
  8008a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c2 01             	add    $0x1,%edx
  8008bb:	83 c1 01             	add    $0x1,%ecx
  8008be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c5:	84 db                	test   %bl,%bl
  8008c7:	75 ef                	jne    8008b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d3:	53                   	push   %ebx
  8008d4:	e8 9a ff ff ff       	call   800873 <strlen>
  8008d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008dc:	ff 75 0c             	pushl  0xc(%ebp)
  8008df:	01 d8                	add    %ebx,%eax
  8008e1:	50                   	push   %eax
  8008e2:	e8 c5 ff ff ff       	call   8008ac <strcpy>
	return dst;
}
  8008e7:	89 d8                	mov    %ebx,%eax
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f9:	89 f3                	mov    %esi,%ebx
  8008fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	89 f2                	mov    %esi,%edx
  800900:	eb 0f                	jmp    800911 <strncpy+0x23>
		*dst++ = *src;
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	0f b6 01             	movzbl (%ecx),%eax
  800908:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090b:	80 39 01             	cmpb   $0x1,(%ecx)
  80090e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800911:	39 da                	cmp    %ebx,%edx
  800913:	75 ed                	jne    800902 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800915:	89 f0                	mov    %esi,%eax
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 75 08             	mov    0x8(%ebp),%esi
  800923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800926:	8b 55 10             	mov    0x10(%ebp),%edx
  800929:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092b:	85 d2                	test   %edx,%edx
  80092d:	74 21                	je     800950 <strlcpy+0x35>
  80092f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800933:	89 f2                	mov    %esi,%edx
  800935:	eb 09                	jmp    800940 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800937:	83 c2 01             	add    $0x1,%edx
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800940:	39 c2                	cmp    %eax,%edx
  800942:	74 09                	je     80094d <strlcpy+0x32>
  800944:	0f b6 19             	movzbl (%ecx),%ebx
  800947:	84 db                	test   %bl,%bl
  800949:	75 ec                	jne    800937 <strlcpy+0x1c>
  80094b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80094d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800950:	29 f0                	sub    %esi,%eax
}
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095f:	eb 06                	jmp    800967 <strcmp+0x11>
		p++, q++;
  800961:	83 c1 01             	add    $0x1,%ecx
  800964:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800967:	0f b6 01             	movzbl (%ecx),%eax
  80096a:	84 c0                	test   %al,%al
  80096c:	74 04                	je     800972 <strcmp+0x1c>
  80096e:	3a 02                	cmp    (%edx),%al
  800970:	74 ef                	je     800961 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800972:	0f b6 c0             	movzbl %al,%eax
  800975:	0f b6 12             	movzbl (%edx),%edx
  800978:	29 d0                	sub    %edx,%eax
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	89 c3                	mov    %eax,%ebx
  800988:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098b:	eb 06                	jmp    800993 <strncmp+0x17>
		n--, p++, q++;
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800993:	39 d8                	cmp    %ebx,%eax
  800995:	74 15                	je     8009ac <strncmp+0x30>
  800997:	0f b6 08             	movzbl (%eax),%ecx
  80099a:	84 c9                	test   %cl,%cl
  80099c:	74 04                	je     8009a2 <strncmp+0x26>
  80099e:	3a 0a                	cmp    (%edx),%cl
  8009a0:	74 eb                	je     80098d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	0f b6 12             	movzbl (%edx),%edx
  8009a8:	29 d0                	sub    %edx,%eax
  8009aa:	eb 05                	jmp    8009b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009be:	eb 07                	jmp    8009c7 <strchr+0x13>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 0f                	je     8009d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	84 d2                	test   %dl,%dl
  8009cc:	75 f2                	jne    8009c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009df:	eb 03                	jmp    8009e4 <strfind+0xf>
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e7:	38 ca                	cmp    %cl,%dl
  8009e9:	74 04                	je     8009ef <strfind+0x1a>
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	75 f2                	jne    8009e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009fd:	85 c9                	test   %ecx,%ecx
  8009ff:	74 36                	je     800a37 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a07:	75 28                	jne    800a31 <memset+0x40>
  800a09:	f6 c1 03             	test   $0x3,%cl
  800a0c:	75 23                	jne    800a31 <memset+0x40>
		c &= 0xFF;
  800a0e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a12:	89 d3                	mov    %edx,%ebx
  800a14:	c1 e3 08             	shl    $0x8,%ebx
  800a17:	89 d6                	mov    %edx,%esi
  800a19:	c1 e6 18             	shl    $0x18,%esi
  800a1c:	89 d0                	mov    %edx,%eax
  800a1e:	c1 e0 10             	shl    $0x10,%eax
  800a21:	09 f0                	or     %esi,%eax
  800a23:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a25:	89 d8                	mov    %ebx,%eax
  800a27:	09 d0                	or     %edx,%eax
  800a29:	c1 e9 02             	shr    $0x2,%ecx
  800a2c:	fc                   	cld    
  800a2d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2f:	eb 06                	jmp    800a37 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	fc                   	cld    
  800a35:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a37:	89 f8                	mov    %edi,%eax
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4c:	39 c6                	cmp    %eax,%esi
  800a4e:	73 35                	jae    800a85 <memmove+0x47>
  800a50:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a53:	39 d0                	cmp    %edx,%eax
  800a55:	73 2e                	jae    800a85 <memmove+0x47>
		s += n;
		d += n;
  800a57:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	89 d6                	mov    %edx,%esi
  800a5c:	09 fe                	or     %edi,%esi
  800a5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a64:	75 13                	jne    800a79 <memmove+0x3b>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 0e                	jne    800a79 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a6b:	83 ef 04             	sub    $0x4,%edi
  800a6e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a71:	c1 e9 02             	shr    $0x2,%ecx
  800a74:	fd                   	std    
  800a75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a77:	eb 09                	jmp    800a82 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a79:	83 ef 01             	sub    $0x1,%edi
  800a7c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a7f:	fd                   	std    
  800a80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a82:	fc                   	cld    
  800a83:	eb 1d                	jmp    800aa2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a85:	89 f2                	mov    %esi,%edx
  800a87:	09 c2                	or     %eax,%edx
  800a89:	f6 c2 03             	test   $0x3,%dl
  800a8c:	75 0f                	jne    800a9d <memmove+0x5f>
  800a8e:	f6 c1 03             	test   $0x3,%cl
  800a91:	75 0a                	jne    800a9d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a93:	c1 e9 02             	shr    $0x2,%ecx
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	fc                   	cld    
  800a99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9b:	eb 05                	jmp    800aa2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9d:	89 c7                	mov    %eax,%edi
  800a9f:	fc                   	cld    
  800aa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa9:	ff 75 10             	pushl  0x10(%ebp)
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	ff 75 08             	pushl  0x8(%ebp)
  800ab2:	e8 87 ff ff ff       	call   800a3e <memmove>
}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac4:	89 c6                	mov    %eax,%esi
  800ac6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	eb 1a                	jmp    800ae5 <memcmp+0x2c>
		if (*s1 != *s2)
  800acb:	0f b6 08             	movzbl (%eax),%ecx
  800ace:	0f b6 1a             	movzbl (%edx),%ebx
  800ad1:	38 d9                	cmp    %bl,%cl
  800ad3:	74 0a                	je     800adf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad5:	0f b6 c1             	movzbl %cl,%eax
  800ad8:	0f b6 db             	movzbl %bl,%ebx
  800adb:	29 d8                	sub    %ebx,%eax
  800add:	eb 0f                	jmp    800aee <memcmp+0x35>
		s1++, s2++;
  800adf:	83 c0 01             	add    $0x1,%eax
  800ae2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae5:	39 f0                	cmp    %esi,%eax
  800ae7:	75 e2                	jne    800acb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	53                   	push   %ebx
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800af9:	89 c1                	mov    %eax,%ecx
  800afb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800afe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	eb 0a                	jmp    800b0e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b04:	0f b6 10             	movzbl (%eax),%edx
  800b07:	39 da                	cmp    %ebx,%edx
  800b09:	74 07                	je     800b12 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	39 c8                	cmp    %ecx,%eax
  800b10:	72 f2                	jb     800b04 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b12:	5b                   	pop    %ebx
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b21:	eb 03                	jmp    800b26 <strtol+0x11>
		s++;
  800b23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b26:	0f b6 01             	movzbl (%ecx),%eax
  800b29:	3c 20                	cmp    $0x20,%al
  800b2b:	74 f6                	je     800b23 <strtol+0xe>
  800b2d:	3c 09                	cmp    $0x9,%al
  800b2f:	74 f2                	je     800b23 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b31:	3c 2b                	cmp    $0x2b,%al
  800b33:	75 0a                	jne    800b3f <strtol+0x2a>
		s++;
  800b35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b38:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3d:	eb 11                	jmp    800b50 <strtol+0x3b>
  800b3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b44:	3c 2d                	cmp    $0x2d,%al
  800b46:	75 08                	jne    800b50 <strtol+0x3b>
		s++, neg = 1;
  800b48:	83 c1 01             	add    $0x1,%ecx
  800b4b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b56:	75 15                	jne    800b6d <strtol+0x58>
  800b58:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5b:	75 10                	jne    800b6d <strtol+0x58>
  800b5d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b61:	75 7c                	jne    800bdf <strtol+0xca>
		s += 2, base = 16;
  800b63:	83 c1 02             	add    $0x2,%ecx
  800b66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6b:	eb 16                	jmp    800b83 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b6d:	85 db                	test   %ebx,%ebx
  800b6f:	75 12                	jne    800b83 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b71:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b76:	80 39 30             	cmpb   $0x30,(%ecx)
  800b79:	75 08                	jne    800b83 <strtol+0x6e>
		s++, base = 8;
  800b7b:	83 c1 01             	add    $0x1,%ecx
  800b7e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b8b:	0f b6 11             	movzbl (%ecx),%edx
  800b8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	80 fb 09             	cmp    $0x9,%bl
  800b96:	77 08                	ja     800ba0 <strtol+0x8b>
			dig = *s - '0';
  800b98:	0f be d2             	movsbl %dl,%edx
  800b9b:	83 ea 30             	sub    $0x30,%edx
  800b9e:	eb 22                	jmp    800bc2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	80 fb 19             	cmp    $0x19,%bl
  800ba8:	77 08                	ja     800bb2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800baa:	0f be d2             	movsbl %dl,%edx
  800bad:	83 ea 57             	sub    $0x57,%edx
  800bb0:	eb 10                	jmp    800bc2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bb2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bb5:	89 f3                	mov    %esi,%ebx
  800bb7:	80 fb 19             	cmp    $0x19,%bl
  800bba:	77 16                	ja     800bd2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bbc:	0f be d2             	movsbl %dl,%edx
  800bbf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bc2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc5:	7d 0b                	jge    800bd2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bc7:	83 c1 01             	add    $0x1,%ecx
  800bca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bce:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd0:	eb b9                	jmp    800b8b <strtol+0x76>

	if (endptr)
  800bd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd6:	74 0d                	je     800be5 <strtol+0xd0>
		*endptr = (char *) s;
  800bd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bdb:	89 0e                	mov    %ecx,(%esi)
  800bdd:	eb 06                	jmp    800be5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	74 98                	je     800b7b <strtol+0x66>
  800be3:	eb 9e                	jmp    800b83 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	f7 da                	neg    %edx
  800be9:	85 ff                	test   %edi,%edi
  800beb:	0f 45 c2             	cmovne %edx,%eax
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	89 c3                	mov    %eax,%ebx
  800c06:	89 c7                	mov    %eax,%edi
  800c08:	89 c6                	mov    %eax,%esi
  800c0a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 d3                	mov    %edx,%ebx
  800c25:	89 d7                	mov    %edx,%edi
  800c27:	89 d6                	mov    %edx,%esi
  800c29:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 cb                	mov    %ecx,%ebx
  800c48:	89 cf                	mov    %ecx,%edi
  800c4a:	89 ce                	mov    %ecx,%esi
  800c4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7e 17                	jle    800c69 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	50                   	push   %eax
  800c56:	6a 03                	push   $0x3
  800c58:	68 bf 2b 80 00       	push   $0x802bbf
  800c5d:	6a 23                	push   $0x23
  800c5f:	68 dc 2b 80 00       	push   $0x802bdc
  800c64:	e8 e5 f5 ff ff       	call   80024e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	89 d3                	mov    %edx,%ebx
  800c85:	89 d7                	mov    %edx,%edi
  800c87:	89 d6                	mov    %edx,%esi
  800c89:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_yield>:

void
sys_yield(void)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca0:	89 d1                	mov    %edx,%ecx
  800ca2:	89 d3                	mov    %edx,%ebx
  800ca4:	89 d7                	mov    %edx,%edi
  800ca6:	89 d6                	mov    %edx,%esi
  800ca8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	be 00 00 00 00       	mov    $0x0,%esi
  800cbd:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccb:	89 f7                	mov    %esi,%edi
  800ccd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7e 17                	jle    800cea <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	6a 04                	push   $0x4
  800cd9:	68 bf 2b 80 00       	push   $0x802bbf
  800cde:	6a 23                	push   $0x23
  800ce0:	68 dc 2b 80 00       	push   $0x802bdc
  800ce5:	e8 64 f5 ff ff       	call   80024e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	b8 05 00 00 00       	mov    $0x5,%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 05                	push   $0x5
  800d1b:	68 bf 2b 80 00       	push   $0x802bbf
  800d20:	6a 23                	push   $0x23
  800d22:	68 dc 2b 80 00       	push   $0x802bdc
  800d27:	e8 22 f5 ff ff       	call   80024e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d42:	b8 06 00 00 00       	mov    $0x6,%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 df                	mov    %ebx,%edi
  800d4f:	89 de                	mov    %ebx,%esi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 17                	jle    800d6e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	6a 06                	push   $0x6
  800d5d:	68 bf 2b 80 00       	push   $0x802bbf
  800d62:	6a 23                	push   $0x23
  800d64:	68 dc 2b 80 00       	push   $0x802bdc
  800d69:	e8 e0 f4 ff ff       	call   80024e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d84:	b8 08 00 00 00       	mov    $0x8,%eax
  800d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	89 df                	mov    %ebx,%edi
  800d91:	89 de                	mov    %ebx,%esi
  800d93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7e 17                	jle    800db0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 08                	push   $0x8
  800d9f:	68 bf 2b 80 00       	push   $0x802bbf
  800da4:	6a 23                	push   $0x23
  800da6:	68 dc 2b 80 00       	push   $0x802bdc
  800dab:	e8 9e f4 ff ff       	call   80024e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc6:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 df                	mov    %ebx,%edi
  800dd3:	89 de                	mov    %ebx,%esi
  800dd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	7e 17                	jle    800df2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	50                   	push   %eax
  800ddf:	6a 09                	push   $0x9
  800de1:	68 bf 2b 80 00       	push   $0x802bbf
  800de6:	6a 23                	push   $0x23
  800de8:	68 dc 2b 80 00       	push   $0x802bdc
  800ded:	e8 5c f4 ff ff       	call   80024e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 17                	jle    800e34 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 0a                	push   $0xa
  800e23:	68 bf 2b 80 00       	push   $0x802bbf
  800e28:	6a 23                	push   $0x23
  800e2a:	68 dc 2b 80 00       	push   $0x802bdc
  800e2f:	e8 1a f4 ff ff       	call   80024e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e42:	be 00 00 00 00       	mov    $0x0,%esi
  800e47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e58:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5a:	5b                   	pop    %ebx
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	57                   	push   %edi
  800e63:	56                   	push   %esi
  800e64:	53                   	push   %ebx
  800e65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e72:	8b 55 08             	mov    0x8(%ebp),%edx
  800e75:	89 cb                	mov    %ecx,%ebx
  800e77:	89 cf                	mov    %ecx,%edi
  800e79:	89 ce                	mov    %ecx,%esi
  800e7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	7e 17                	jle    800e98 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	50                   	push   %eax
  800e85:	6a 0d                	push   $0xd
  800e87:	68 bf 2b 80 00       	push   $0x802bbf
  800e8c:	6a 23                	push   $0x23
  800e8e:	68 dc 2b 80 00       	push   $0x802bdc
  800e93:	e8 b6 f3 ff ff       	call   80024e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eab:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb0:	89 d1                	mov    %edx,%ecx
  800eb2:	89 d3                	mov    %edx,%ebx
  800eb4:	89 d7                	mov    %edx,%edi
  800eb6:	89 d6                	mov    %edx,%esi
  800eb8:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eca:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed5:	89 df                	mov    %ebx,%edi
  800ed7:	89 de                	mov    %ebx,%esi
  800ed9:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800eea:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800eec:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ef0:	74 2e                	je     800f20 <pgfault+0x40>
  800ef2:	89 c2                	mov    %eax,%edx
  800ef4:	c1 ea 16             	shr    $0x16,%edx
  800ef7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efe:	f6 c2 01             	test   $0x1,%dl
  800f01:	74 1d                	je     800f20 <pgfault+0x40>
  800f03:	89 c2                	mov    %eax,%edx
  800f05:	c1 ea 0c             	shr    $0xc,%edx
  800f08:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f0f:	f6 c1 01             	test   $0x1,%cl
  800f12:	74 0c                	je     800f20 <pgfault+0x40>
  800f14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1b:	f6 c6 08             	test   $0x8,%dh
  800f1e:	75 14                	jne    800f34 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	68 ea 2b 80 00       	push   $0x802bea
  800f28:	6a 1d                	push   $0x1d
  800f2a:	68 fd 2b 80 00       	push   $0x802bfd
  800f2f:	e8 1a f3 ff ff       	call   80024e <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f39:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	6a 07                	push   $0x7
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	6a 00                	push   $0x0
  800f47:	e8 63 fd ff ff       	call   800caf <sys_page_alloc>
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 14                	jns    800f67 <pgfault+0x87>
		panic("page alloc failed \n");
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	68 08 2c 80 00       	push   $0x802c08
  800f5b:	6a 28                	push   $0x28
  800f5d:	68 fd 2b 80 00       	push   $0x802bfd
  800f62:	e8 e7 f2 ff ff       	call   80024e <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800f67:	83 ec 04             	sub    $0x4,%esp
  800f6a:	68 00 10 00 00       	push   $0x1000
  800f6f:	53                   	push   %ebx
  800f70:	68 00 f0 7f 00       	push   $0x7ff000
  800f75:	e8 2c fb ff ff       	call   800aa6 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800f7a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f81:	53                   	push   %ebx
  800f82:	6a 00                	push   $0x0
  800f84:	68 00 f0 7f 00       	push   $0x7ff000
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 62 fd ff ff       	call   800cf2 <sys_page_map>
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	79 14                	jns    800fab <pgfault+0xcb>
        panic("page map failed \n");
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	68 1c 2c 80 00       	push   $0x802c1c
  800f9f:	6a 2b                	push   $0x2b
  800fa1:	68 fd 2b 80 00       	push   $0x802bfd
  800fa6:	e8 a3 f2 ff ff       	call   80024e <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	68 00 f0 7f 00       	push   $0x7ff000
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 7a fd ff ff       	call   800d34 <sys_page_unmap>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 14                	jns    800fd5 <pgfault+0xf5>
        panic("page unmap failed\n");
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	68 2e 2c 80 00       	push   $0x802c2e
  800fc9:	6a 2d                	push   $0x2d
  800fcb:	68 fd 2b 80 00       	push   $0x802bfd
  800fd0:	e8 79 f2 ff ff       	call   80024e <_panic>
	
	//panic("pgfault not implemented");
}
  800fd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd8:	c9                   	leave  
  800fd9:	c3                   	ret    

00800fda <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800fe3:	68 e0 0e 80 00       	push   $0x800ee0
  800fe8:	e8 8c 14 00 00       	call   802479 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fed:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff2:	cd 30                	int    $0x30
  800ff4:	89 c7                	mov    %eax,%edi
  800ff6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	79 12                	jns    801012 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  801000:	50                   	push   %eax
  801001:	68 41 2c 80 00       	push   $0x802c41
  801006:	6a 7a                	push   $0x7a
  801008:	68 fd 2b 80 00       	push   $0x802bfd
  80100d:	e8 3c f2 ff ff       	call   80024e <_panic>
  801012:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801017:	85 c0                	test   %eax,%eax
  801019:	75 21                	jne    80103c <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  80101b:	e8 51 fc ff ff       	call   800c71 <sys_getenvid>
  801020:	25 ff 03 00 00       	and    $0x3ff,%eax
  801025:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801028:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801032:	b8 00 00 00 00       	mov    $0x0,%eax
  801037:	e9 91 01 00 00       	jmp    8011cd <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	c1 e8 16             	shr    $0x16,%eax
  801041:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801048:	a8 01                	test   $0x1,%al
  80104a:	0f 84 06 01 00 00    	je     801156 <fork+0x17c>
  801050:	89 d8                	mov    %ebx,%eax
  801052:	c1 e8 0c             	shr    $0xc,%eax
  801055:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105c:	f6 c2 01             	test   $0x1,%dl
  80105f:	0f 84 f1 00 00 00    	je     801156 <fork+0x17c>
  801065:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106c:	f6 c2 04             	test   $0x4,%dl
  80106f:	0f 84 e1 00 00 00    	je     801156 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801075:	89 c6                	mov    %eax,%esi
  801077:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  80107a:	89 f2                	mov    %esi,%edx
  80107c:	c1 ea 16             	shr    $0x16,%edx
  80107f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  801086:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  80108d:	f6 c6 04             	test   $0x4,%dh
  801090:	74 39                	je     8010cb <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801092:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a1:	50                   	push   %eax
  8010a2:	56                   	push   %esi
  8010a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 44 fc ff ff       	call   800cf2 <sys_page_map>
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	0f 89 9d 00 00 00    	jns    801156 <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  8010b9:	50                   	push   %eax
  8010ba:	68 98 2c 80 00       	push   $0x802c98
  8010bf:	6a 4b                	push   $0x4b
  8010c1:	68 fd 2b 80 00       	push   $0x802bfd
  8010c6:	e8 83 f1 ff ff       	call   80024e <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  8010cb:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8010d1:	74 59                	je     80112c <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	68 05 08 00 00       	push   $0x805
  8010db:	56                   	push   %esi
  8010dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010df:	56                   	push   %esi
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 0b fc ff ff       	call   800cf2 <sys_page_map>
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 12                	jns    801100 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  8010ee:	50                   	push   %eax
  8010ef:	68 c8 2c 80 00       	push   $0x802cc8
  8010f4:	6a 50                	push   $0x50
  8010f6:	68 fd 2b 80 00       	push   $0x802bfd
  8010fb:	e8 4e f1 ff ff       	call   80024e <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	68 05 08 00 00       	push   $0x805
  801108:	56                   	push   %esi
  801109:	6a 00                	push   $0x0
  80110b:	56                   	push   %esi
  80110c:	6a 00                	push   $0x0
  80110e:	e8 df fb ff ff       	call   800cf2 <sys_page_map>
  801113:	83 c4 20             	add    $0x20,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	79 3c                	jns    801156 <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  80111a:	50                   	push   %eax
  80111b:	68 f0 2c 80 00       	push   $0x802cf0
  801120:	6a 53                	push   $0x53
  801122:	68 fd 2b 80 00       	push   $0x802bfd
  801127:	e8 22 f1 ff ff       	call   80024e <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	6a 05                	push   $0x5
  801131:	56                   	push   %esi
  801132:	ff 75 e4             	pushl  -0x1c(%ebp)
  801135:	56                   	push   %esi
  801136:	6a 00                	push   $0x0
  801138:	e8 b5 fb ff ff       	call   800cf2 <sys_page_map>
  80113d:	83 c4 20             	add    $0x20,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	79 12                	jns    801156 <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801144:	50                   	push   %eax
  801145:	68 18 2d 80 00       	push   $0x802d18
  80114a:	6a 58                	push   $0x58
  80114c:	68 fd 2b 80 00       	push   $0x802bfd
  801151:	e8 f8 f0 ff ff       	call   80024e <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  801156:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80115c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801162:	0f 85 d4 fe ff ff    	jne    80103c <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	6a 07                	push   $0x7
  80116d:	68 00 f0 bf ee       	push   $0xeebff000
  801172:	57                   	push   %edi
  801173:	e8 37 fb ff ff       	call   800caf <sys_page_alloc>
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 17                	jns    801196 <fork+0x1bc>
        panic("page alloc failed\n");
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	68 53 2c 80 00       	push   $0x802c53
  801187:	68 87 00 00 00       	push   $0x87
  80118c:	68 fd 2b 80 00       	push   $0x802bfd
  801191:	e8 b8 f0 ff ff       	call   80024e <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	68 e8 24 80 00       	push   $0x8024e8
  80119e:	57                   	push   %edi
  80119f:	e8 56 fc ff ff       	call   800dfa <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	6a 02                	push   $0x2
  8011a9:	57                   	push   %edi
  8011aa:	e8 c7 fb ff ff       	call   800d76 <sys_env_set_status>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	79 15                	jns    8011cb <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  8011b6:	50                   	push   %eax
  8011b7:	68 66 2c 80 00       	push   $0x802c66
  8011bc:	68 8c 00 00 00       	push   $0x8c
  8011c1:	68 fd 2b 80 00       	push   $0x802bfd
  8011c6:	e8 83 f0 ff ff       	call   80024e <_panic>

	return envid;
  8011cb:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8011cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011db:	68 7f 2c 80 00       	push   $0x802c7f
  8011e0:	68 98 00 00 00       	push   $0x98
  8011e5:	68 fd 2b 80 00       	push   $0x802bfd
  8011ea:	e8 5f f0 ff ff       	call   80024e <_panic>

008011ef <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	74 0e                	je     80120f <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	50                   	push   %eax
  801205:	e8 55 fc ff ff       	call   800e5f <sys_ipc_recv>
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	eb 10                	jmp    80121f <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80120f:	83 ec 0c             	sub    $0xc,%esp
  801212:	68 00 00 00 f0       	push   $0xf0000000
  801217:	e8 43 fc ff ff       	call   800e5f <sys_ipc_recv>
  80121c:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 0e                	je     801231 <ipc_recv+0x42>
    	*from_env_store = 0;
  801223:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80122f:	eb 24                	jmp    801255 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801231:	85 f6                	test   %esi,%esi
  801233:	74 0a                	je     80123f <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801235:	a1 08 40 80 00       	mov    0x804008,%eax
  80123a:	8b 40 74             	mov    0x74(%eax),%eax
  80123d:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80123f:	85 db                	test   %ebx,%ebx
  801241:	74 0a                	je     80124d <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801243:	a1 08 40 80 00       	mov    0x804008,%eax
  801248:	8b 40 78             	mov    0x78(%eax),%eax
  80124b:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  80124d:	a1 08 40 80 00       	mov    0x804008,%eax
  801252:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801255:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801258:	5b                   	pop    %ebx
  801259:	5e                   	pop    %esi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	8b 7d 08             	mov    0x8(%ebp),%edi
  801268:	8b 75 0c             	mov    0xc(%ebp),%esi
  80126b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  80126e:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801275:	0f 44 d8             	cmove  %eax,%ebx
  801278:	eb 1c                	jmp    801296 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80127a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80127d:	74 12                	je     801291 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  80127f:	50                   	push   %eax
  801280:	68 44 2d 80 00       	push   $0x802d44
  801285:	6a 4b                	push   $0x4b
  801287:	68 5c 2d 80 00       	push   $0x802d5c
  80128c:	e8 bd ef ff ff       	call   80024e <_panic>
        }	
        sys_yield();
  801291:	e8 fa f9 ff ff       	call   800c90 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801296:	ff 75 14             	pushl  0x14(%ebp)
  801299:	53                   	push   %ebx
  80129a:	56                   	push   %esi
  80129b:	57                   	push   %edi
  80129c:	e8 9b fb ff ff       	call   800e3c <sys_ipc_try_send>
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	75 d2                	jne    80127a <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8012a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5f                   	pop    %edi
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012bb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012be:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012c4:	8b 52 50             	mov    0x50(%edx),%edx
  8012c7:	39 ca                	cmp    %ecx,%edx
  8012c9:	75 0d                	jne    8012d8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012cb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d3:	8b 40 48             	mov    0x48(%eax),%eax
  8012d6:	eb 0f                	jmp    8012e7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012d8:	83 c0 01             	add    $0x1,%eax
  8012db:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012e0:	75 d9                	jne    8012bb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ff:	05 00 00 00 30       	add    $0x30000000,%eax
  801304:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801309:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801316:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	c1 ea 16             	shr    $0x16,%edx
  801320:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801327:	f6 c2 01             	test   $0x1,%dl
  80132a:	74 11                	je     80133d <fd_alloc+0x2d>
  80132c:	89 c2                	mov    %eax,%edx
  80132e:	c1 ea 0c             	shr    $0xc,%edx
  801331:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801338:	f6 c2 01             	test   $0x1,%dl
  80133b:	75 09                	jne    801346 <fd_alloc+0x36>
			*fd_store = fd;
  80133d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133f:	b8 00 00 00 00       	mov    $0x0,%eax
  801344:	eb 17                	jmp    80135d <fd_alloc+0x4d>
  801346:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80134b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801350:	75 c9                	jne    80131b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801352:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801358:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801365:	83 f8 1f             	cmp    $0x1f,%eax
  801368:	77 36                	ja     8013a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80136a:	c1 e0 0c             	shl    $0xc,%eax
  80136d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801372:	89 c2                	mov    %eax,%edx
  801374:	c1 ea 16             	shr    $0x16,%edx
  801377:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80137e:	f6 c2 01             	test   $0x1,%dl
  801381:	74 24                	je     8013a7 <fd_lookup+0x48>
  801383:	89 c2                	mov    %eax,%edx
  801385:	c1 ea 0c             	shr    $0xc,%edx
  801388:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80138f:	f6 c2 01             	test   $0x1,%dl
  801392:	74 1a                	je     8013ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801394:	8b 55 0c             	mov    0xc(%ebp),%edx
  801397:	89 02                	mov    %eax,(%edx)
	return 0;
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
  80139e:	eb 13                	jmp    8013b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a5:	eb 0c                	jmp    8013b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ac:	eb 05                	jmp    8013b3 <fd_lookup+0x54>
  8013ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013be:	ba e4 2d 80 00       	mov    $0x802de4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013c3:	eb 13                	jmp    8013d8 <dev_lookup+0x23>
  8013c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013c8:	39 08                	cmp    %ecx,(%eax)
  8013ca:	75 0c                	jne    8013d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8013cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d6:	eb 2e                	jmp    801406 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013d8:	8b 02                	mov    (%edx),%eax
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	75 e7                	jne    8013c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013de:	a1 08 40 80 00       	mov    0x804008,%eax
  8013e3:	8b 40 48             	mov    0x48(%eax),%eax
  8013e6:	83 ec 04             	sub    $0x4,%esp
  8013e9:	51                   	push   %ecx
  8013ea:	50                   	push   %eax
  8013eb:	68 68 2d 80 00       	push   $0x802d68
  8013f0:	e8 32 ef ff ff       	call   800327 <cprintf>
	*dev = 0;
  8013f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 10             	sub    $0x10,%esp
  801410:	8b 75 08             	mov    0x8(%ebp),%esi
  801413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801420:	c1 e8 0c             	shr    $0xc,%eax
  801423:	50                   	push   %eax
  801424:	e8 36 ff ff ff       	call   80135f <fd_lookup>
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 05                	js     801435 <fd_close+0x2d>
	    || fd != fd2)
  801430:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801433:	74 0c                	je     801441 <fd_close+0x39>
		return (must_exist ? r : 0);
  801435:	84 db                	test   %bl,%bl
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	0f 44 c2             	cmove  %edx,%eax
  80143f:	eb 41                	jmp    801482 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	ff 36                	pushl  (%esi)
  80144a:	e8 66 ff ff ff       	call   8013b5 <dev_lookup>
  80144f:	89 c3                	mov    %eax,%ebx
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	78 1a                	js     801472 <fd_close+0x6a>
		if (dev->dev_close)
  801458:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80145e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801463:	85 c0                	test   %eax,%eax
  801465:	74 0b                	je     801472 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	56                   	push   %esi
  80146b:	ff d0                	call   *%eax
  80146d:	89 c3                	mov    %eax,%ebx
  80146f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	56                   	push   %esi
  801476:	6a 00                	push   $0x0
  801478:	e8 b7 f8 ff ff       	call   800d34 <sys_page_unmap>
	return r;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	89 d8                	mov    %ebx,%eax
}
  801482:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	ff 75 08             	pushl  0x8(%ebp)
  801496:	e8 c4 fe ff ff       	call   80135f <fd_lookup>
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 10                	js     8014b2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	6a 01                	push   $0x1
  8014a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014aa:	e8 59 ff ff ff       	call   801408 <fd_close>
  8014af:	83 c4 10             	add    $0x10,%esp
}
  8014b2:	c9                   	leave  
  8014b3:	c3                   	ret    

008014b4 <close_all>:

void
close_all(void)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	53                   	push   %ebx
  8014c4:	e8 c0 ff ff ff       	call   801489 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c9:	83 c3 01             	add    $0x1,%ebx
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	83 fb 20             	cmp    $0x20,%ebx
  8014d2:	75 ec                	jne    8014c0 <close_all+0xc>
		close(i);
}
  8014d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	57                   	push   %edi
  8014dd:	56                   	push   %esi
  8014de:	53                   	push   %ebx
  8014df:	83 ec 2c             	sub    $0x2c,%esp
  8014e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	ff 75 08             	pushl  0x8(%ebp)
  8014ec:	e8 6e fe ff ff       	call   80135f <fd_lookup>
  8014f1:	83 c4 08             	add    $0x8,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	0f 88 c1 00 00 00    	js     8015bd <dup+0xe4>
		return r;
	close(newfdnum);
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	56                   	push   %esi
  801500:	e8 84 ff ff ff       	call   801489 <close>

	newfd = INDEX2FD(newfdnum);
  801505:	89 f3                	mov    %esi,%ebx
  801507:	c1 e3 0c             	shl    $0xc,%ebx
  80150a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801510:	83 c4 04             	add    $0x4,%esp
  801513:	ff 75 e4             	pushl  -0x1c(%ebp)
  801516:	e8 de fd ff ff       	call   8012f9 <fd2data>
  80151b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80151d:	89 1c 24             	mov    %ebx,(%esp)
  801520:	e8 d4 fd ff ff       	call   8012f9 <fd2data>
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80152b:	89 f8                	mov    %edi,%eax
  80152d:	c1 e8 16             	shr    $0x16,%eax
  801530:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801537:	a8 01                	test   $0x1,%al
  801539:	74 37                	je     801572 <dup+0x99>
  80153b:	89 f8                	mov    %edi,%eax
  80153d:	c1 e8 0c             	shr    $0xc,%eax
  801540:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801547:	f6 c2 01             	test   $0x1,%dl
  80154a:	74 26                	je     801572 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801553:	83 ec 0c             	sub    $0xc,%esp
  801556:	25 07 0e 00 00       	and    $0xe07,%eax
  80155b:	50                   	push   %eax
  80155c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80155f:	6a 00                	push   $0x0
  801561:	57                   	push   %edi
  801562:	6a 00                	push   $0x0
  801564:	e8 89 f7 ff ff       	call   800cf2 <sys_page_map>
  801569:	89 c7                	mov    %eax,%edi
  80156b:	83 c4 20             	add    $0x20,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 2e                	js     8015a0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801572:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801575:	89 d0                	mov    %edx,%eax
  801577:	c1 e8 0c             	shr    $0xc,%eax
  80157a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801581:	83 ec 0c             	sub    $0xc,%esp
  801584:	25 07 0e 00 00       	and    $0xe07,%eax
  801589:	50                   	push   %eax
  80158a:	53                   	push   %ebx
  80158b:	6a 00                	push   $0x0
  80158d:	52                   	push   %edx
  80158e:	6a 00                	push   $0x0
  801590:	e8 5d f7 ff ff       	call   800cf2 <sys_page_map>
  801595:	89 c7                	mov    %eax,%edi
  801597:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80159a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159c:	85 ff                	test   %edi,%edi
  80159e:	79 1d                	jns    8015bd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	6a 00                	push   $0x0
  8015a6:	e8 89 f7 ff ff       	call   800d34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015b1:	6a 00                	push   $0x0
  8015b3:	e8 7c f7 ff ff       	call   800d34 <sys_page_unmap>
	return r;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	89 f8                	mov    %edi,%eax
}
  8015bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5f                   	pop    %edi
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    

008015c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 14             	sub    $0x14,%esp
  8015cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d2:	50                   	push   %eax
  8015d3:	53                   	push   %ebx
  8015d4:	e8 86 fd ff ff       	call   80135f <fd_lookup>
  8015d9:	83 c4 08             	add    $0x8,%esp
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 6d                	js     80164f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ec:	ff 30                	pushl  (%eax)
  8015ee:	e8 c2 fd ff ff       	call   8013b5 <dev_lookup>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 4c                	js     801646 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015fd:	8b 42 08             	mov    0x8(%edx),%eax
  801600:	83 e0 03             	and    $0x3,%eax
  801603:	83 f8 01             	cmp    $0x1,%eax
  801606:	75 21                	jne    801629 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801608:	a1 08 40 80 00       	mov    0x804008,%eax
  80160d:	8b 40 48             	mov    0x48(%eax),%eax
  801610:	83 ec 04             	sub    $0x4,%esp
  801613:	53                   	push   %ebx
  801614:	50                   	push   %eax
  801615:	68 a9 2d 80 00       	push   $0x802da9
  80161a:	e8 08 ed ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801627:	eb 26                	jmp    80164f <read+0x8a>
	}
	if (!dev->dev_read)
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	8b 40 08             	mov    0x8(%eax),%eax
  80162f:	85 c0                	test   %eax,%eax
  801631:	74 17                	je     80164a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	ff 75 10             	pushl  0x10(%ebp)
  801639:	ff 75 0c             	pushl  0xc(%ebp)
  80163c:	52                   	push   %edx
  80163d:	ff d0                	call   *%eax
  80163f:	89 c2                	mov    %eax,%edx
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 09                	jmp    80164f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	89 c2                	mov    %eax,%edx
  801648:	eb 05                	jmp    80164f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80164a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80164f:	89 d0                	mov    %edx,%eax
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	57                   	push   %edi
  80165a:	56                   	push   %esi
  80165b:	53                   	push   %ebx
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801662:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801665:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166a:	eb 21                	jmp    80168d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	89 f0                	mov    %esi,%eax
  801671:	29 d8                	sub    %ebx,%eax
  801673:	50                   	push   %eax
  801674:	89 d8                	mov    %ebx,%eax
  801676:	03 45 0c             	add    0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	57                   	push   %edi
  80167b:	e8 45 ff ff ff       	call   8015c5 <read>
		if (m < 0)
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 10                	js     801697 <readn+0x41>
			return m;
		if (m == 0)
  801687:	85 c0                	test   %eax,%eax
  801689:	74 0a                	je     801695 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80168b:	01 c3                	add    %eax,%ebx
  80168d:	39 f3                	cmp    %esi,%ebx
  80168f:	72 db                	jb     80166c <readn+0x16>
  801691:	89 d8                	mov    %ebx,%eax
  801693:	eb 02                	jmp    801697 <readn+0x41>
  801695:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801697:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5f                   	pop    %edi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 14             	sub    $0x14,%esp
  8016a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	53                   	push   %ebx
  8016ae:	e8 ac fc ff ff       	call   80135f <fd_lookup>
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 68                	js     801724 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	ff 30                	pushl  (%eax)
  8016c8:	e8 e8 fc ff ff       	call   8013b5 <dev_lookup>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 47                	js     80171b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016db:	75 21                	jne    8016fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8016e2:	8b 40 48             	mov    0x48(%eax),%eax
  8016e5:	83 ec 04             	sub    $0x4,%esp
  8016e8:	53                   	push   %ebx
  8016e9:	50                   	push   %eax
  8016ea:	68 c5 2d 80 00       	push   $0x802dc5
  8016ef:	e8 33 ec ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016fc:	eb 26                	jmp    801724 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801701:	8b 52 0c             	mov    0xc(%edx),%edx
  801704:	85 d2                	test   %edx,%edx
  801706:	74 17                	je     80171f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	ff 75 10             	pushl  0x10(%ebp)
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	50                   	push   %eax
  801712:	ff d2                	call   *%edx
  801714:	89 c2                	mov    %eax,%edx
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	eb 09                	jmp    801724 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171b:	89 c2                	mov    %eax,%edx
  80171d:	eb 05                	jmp    801724 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80171f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801724:	89 d0                	mov    %edx,%eax
  801726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <seek>:

int
seek(int fdnum, off_t offset)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801731:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	ff 75 08             	pushl  0x8(%ebp)
  801738:	e8 22 fc ff ff       	call   80135f <fd_lookup>
  80173d:	83 c4 08             	add    $0x8,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 0e                	js     801752 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801744:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	53                   	push   %ebx
  801758:	83 ec 14             	sub    $0x14,%esp
  80175b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	53                   	push   %ebx
  801763:	e8 f7 fb ff ff       	call   80135f <fd_lookup>
  801768:	83 c4 08             	add    $0x8,%esp
  80176b:	89 c2                	mov    %eax,%edx
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 65                	js     8017d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177b:	ff 30                	pushl  (%eax)
  80177d:	e8 33 fc ff ff       	call   8013b5 <dev_lookup>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 44                	js     8017cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801789:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801790:	75 21                	jne    8017b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801792:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801797:	8b 40 48             	mov    0x48(%eax),%eax
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	53                   	push   %ebx
  80179e:	50                   	push   %eax
  80179f:	68 88 2d 80 00       	push   $0x802d88
  8017a4:	e8 7e eb ff ff       	call   800327 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017b1:	eb 23                	jmp    8017d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b6:	8b 52 18             	mov    0x18(%edx),%edx
  8017b9:	85 d2                	test   %edx,%edx
  8017bb:	74 14                	je     8017d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	ff 75 0c             	pushl  0xc(%ebp)
  8017c3:	50                   	push   %eax
  8017c4:	ff d2                	call   *%edx
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	eb 09                	jmp    8017d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017cd:	89 c2                	mov    %eax,%edx
  8017cf:	eb 05                	jmp    8017d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017d6:	89 d0                	mov    %edx,%eax
  8017d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 14             	sub    $0x14,%esp
  8017e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 08             	pushl  0x8(%ebp)
  8017ee:	e8 6c fb ff ff       	call   80135f <fd_lookup>
  8017f3:	83 c4 08             	add    $0x8,%esp
  8017f6:	89 c2                	mov    %eax,%edx
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 58                	js     801854 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801802:	50                   	push   %eax
  801803:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801806:	ff 30                	pushl  (%eax)
  801808:	e8 a8 fb ff ff       	call   8013b5 <dev_lookup>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 37                	js     80184b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801817:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80181b:	74 32                	je     80184f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80181d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801820:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801827:	00 00 00 
	stat->st_isdir = 0;
  80182a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801831:	00 00 00 
	stat->st_dev = dev;
  801834:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	53                   	push   %ebx
  80183e:	ff 75 f0             	pushl  -0x10(%ebp)
  801841:	ff 50 14             	call   *0x14(%eax)
  801844:	89 c2                	mov    %eax,%edx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	eb 09                	jmp    801854 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	eb 05                	jmp    801854 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80184f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801854:	89 d0                	mov    %edx,%eax
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	56                   	push   %esi
  80185f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	6a 00                	push   $0x0
  801865:	ff 75 08             	pushl  0x8(%ebp)
  801868:	e8 e7 01 00 00       	call   801a54 <open>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 1b                	js     801891 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	ff 75 0c             	pushl  0xc(%ebp)
  80187c:	50                   	push   %eax
  80187d:	e8 5b ff ff ff       	call   8017dd <fstat>
  801882:	89 c6                	mov    %eax,%esi
	close(fd);
  801884:	89 1c 24             	mov    %ebx,(%esp)
  801887:	e8 fd fb ff ff       	call   801489 <close>
	return r;
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	89 f0                	mov    %esi,%eax
}
  801891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	89 c6                	mov    %eax,%esi
  80189f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a8:	75 12                	jne    8018bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018aa:	83 ec 0c             	sub    $0xc,%esp
  8018ad:	6a 01                	push   $0x1
  8018af:	e8 fc f9 ff ff       	call   8012b0 <ipc_find_env>
  8018b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018bc:	6a 07                	push   $0x7
  8018be:	68 00 50 80 00       	push   $0x805000
  8018c3:	56                   	push   %esi
  8018c4:	ff 35 00 40 80 00    	pushl  0x804000
  8018ca:	e8 8d f9 ff ff       	call   80125c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018cf:	83 c4 0c             	add    $0xc,%esp
  8018d2:	6a 00                	push   $0x0
  8018d4:	53                   	push   %ebx
  8018d5:	6a 00                	push   $0x0
  8018d7:	e8 13 f9 ff ff       	call   8011ef <ipc_recv>
}
  8018dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801901:	b8 02 00 00 00       	mov    $0x2,%eax
  801906:	e8 8d ff ff ff       	call   801898 <fsipc>
}
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	8b 40 0c             	mov    0xc(%eax),%eax
  801919:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80191e:	ba 00 00 00 00       	mov    $0x0,%edx
  801923:	b8 06 00 00 00       	mov    $0x6,%eax
  801928:	e8 6b ff ff ff       	call   801898 <fsipc>
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	53                   	push   %ebx
  801933:	83 ec 04             	sub    $0x4,%esp
  801936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	8b 40 0c             	mov    0xc(%eax),%eax
  80193f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801944:	ba 00 00 00 00       	mov    $0x0,%edx
  801949:	b8 05 00 00 00       	mov    $0x5,%eax
  80194e:	e8 45 ff ff ff       	call   801898 <fsipc>
  801953:	85 c0                	test   %eax,%eax
  801955:	78 2c                	js     801983 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	68 00 50 80 00       	push   $0x805000
  80195f:	53                   	push   %ebx
  801960:	e8 47 ef ff ff       	call   8008ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801965:	a1 80 50 80 00       	mov    0x805080,%eax
  80196a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801970:	a1 84 50 80 00       	mov    0x805084,%eax
  801975:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801983:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	53                   	push   %ebx
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801992:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801997:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80199c:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80199f:	53                   	push   %ebx
  8019a0:	ff 75 0c             	pushl  0xc(%ebp)
  8019a3:	68 08 50 80 00       	push   $0x805008
  8019a8:	e8 91 f0 ff ff       	call   800a3e <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b3:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8019b8:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8019be:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c8:	e8 cb fe ff ff       	call   801898 <fsipc>
	//panic("devfile_write not implemented");
}
  8019cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	56                   	push   %esi
  8019d6:	53                   	push   %ebx
  8019d7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019da:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019e5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8019f5:	e8 9e fe ff ff       	call   801898 <fsipc>
  8019fa:	89 c3                	mov    %eax,%ebx
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 4b                	js     801a4b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a00:	39 c6                	cmp    %eax,%esi
  801a02:	73 16                	jae    801a1a <devfile_read+0x48>
  801a04:	68 f8 2d 80 00       	push   $0x802df8
  801a09:	68 ff 2d 80 00       	push   $0x802dff
  801a0e:	6a 7c                	push   $0x7c
  801a10:	68 14 2e 80 00       	push   $0x802e14
  801a15:	e8 34 e8 ff ff       	call   80024e <_panic>
	assert(r <= PGSIZE);
  801a1a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a1f:	7e 16                	jle    801a37 <devfile_read+0x65>
  801a21:	68 1f 2e 80 00       	push   $0x802e1f
  801a26:	68 ff 2d 80 00       	push   $0x802dff
  801a2b:	6a 7d                	push   $0x7d
  801a2d:	68 14 2e 80 00       	push   $0x802e14
  801a32:	e8 17 e8 ff ff       	call   80024e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a37:	83 ec 04             	sub    $0x4,%esp
  801a3a:	50                   	push   %eax
  801a3b:	68 00 50 80 00       	push   $0x805000
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	e8 f6 ef ff ff       	call   800a3e <memmove>
	return r;
  801a48:	83 c4 10             	add    $0x10,%esp
}
  801a4b:	89 d8                	mov    %ebx,%eax
  801a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	53                   	push   %ebx
  801a58:	83 ec 20             	sub    $0x20,%esp
  801a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a5e:	53                   	push   %ebx
  801a5f:	e8 0f ee ff ff       	call   800873 <strlen>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a6c:	7f 67                	jg     801ad5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a74:	50                   	push   %eax
  801a75:	e8 96 f8 ff ff       	call   801310 <fd_alloc>
  801a7a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a7d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 57                	js     801ada <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	53                   	push   %ebx
  801a87:	68 00 50 80 00       	push   $0x805000
  801a8c:	e8 1b ee ff ff       	call   8008ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a94:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa1:	e8 f2 fd ff ff       	call   801898 <fsipc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	79 14                	jns    801ac3 <open+0x6f>
		fd_close(fd, 0);
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	6a 00                	push   $0x0
  801ab4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab7:	e8 4c f9 ff ff       	call   801408 <fd_close>
		return r;
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	89 da                	mov    %ebx,%edx
  801ac1:	eb 17                	jmp    801ada <open+0x86>
	}

	return fd2num(fd);
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac9:	e8 1b f8 ff ff       	call   8012e9 <fd2num>
  801ace:	89 c2                	mov    %eax,%edx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	eb 05                	jmp    801ada <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ad5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ada:	89 d0                	mov    %edx,%eax
  801adc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aec:	b8 08 00 00 00       	mov    $0x8,%eax
  801af1:	e8 a2 fd ff ff       	call   801898 <fsipc>
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afe:	89 d0                	mov    %edx,%eax
  801b00:	c1 e8 16             	shr    $0x16,%eax
  801b03:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0f:	f6 c1 01             	test   $0x1,%cl
  801b12:	74 1d                	je     801b31 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b14:	c1 ea 0c             	shr    $0xc,%edx
  801b17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1e:	f6 c2 01             	test   $0x1,%dl
  801b21:	74 0e                	je     801b31 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b23:	c1 ea 0c             	shr    $0xc,%edx
  801b26:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2d:	ef 
  801b2e:	0f b7 c0             	movzwl %ax,%eax
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b39:	68 2b 2e 80 00       	push   $0x802e2b
  801b3e:	ff 75 0c             	pushl  0xc(%ebp)
  801b41:	e8 66 ed ff ff       	call   8008ac <strcpy>
	return 0;
}
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	53                   	push   %ebx
  801b51:	83 ec 10             	sub    $0x10,%esp
  801b54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b57:	53                   	push   %ebx
  801b58:	e8 9b ff ff ff       	call   801af8 <pageref>
  801b5d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b60:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b65:	83 f8 01             	cmp    $0x1,%eax
  801b68:	75 10                	jne    801b7a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b6a:	83 ec 0c             	sub    $0xc,%esp
  801b6d:	ff 73 0c             	pushl  0xc(%ebx)
  801b70:	e8 c0 02 00 00       	call   801e35 <nsipc_close>
  801b75:	89 c2                	mov    %eax,%edx
  801b77:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b7a:	89 d0                	mov    %edx,%eax
  801b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b87:	6a 00                	push   $0x0
  801b89:	ff 75 10             	pushl  0x10(%ebp)
  801b8c:	ff 75 0c             	pushl  0xc(%ebp)
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	ff 70 0c             	pushl  0xc(%eax)
  801b95:	e8 78 03 00 00       	call   801f12 <nsipc_send>
}
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ba2:	6a 00                	push   $0x0
  801ba4:	ff 75 10             	pushl  0x10(%ebp)
  801ba7:	ff 75 0c             	pushl  0xc(%ebp)
  801baa:	8b 45 08             	mov    0x8(%ebp),%eax
  801bad:	ff 70 0c             	pushl  0xc(%eax)
  801bb0:	e8 f1 02 00 00       	call   801ea6 <nsipc_recv>
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bbd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bc0:	52                   	push   %edx
  801bc1:	50                   	push   %eax
  801bc2:	e8 98 f7 ff ff       	call   80135f <fd_lookup>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 17                	js     801be5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801bd7:	39 08                	cmp    %ecx,(%eax)
  801bd9:	75 05                	jne    801be0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bdb:	8b 40 0c             	mov    0xc(%eax),%eax
  801bde:	eb 05                	jmp    801be5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801be0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	83 ec 1c             	sub    $0x1c,%esp
  801bef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	e8 16 f7 ff ff       	call   801310 <fd_alloc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 1b                	js     801c1e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c03:	83 ec 04             	sub    $0x4,%esp
  801c06:	68 07 04 00 00       	push   $0x407
  801c0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0e:	6a 00                	push   $0x0
  801c10:	e8 9a f0 ff ff       	call   800caf <sys_page_alloc>
  801c15:	89 c3                	mov    %eax,%ebx
  801c17:	83 c4 10             	add    $0x10,%esp
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	79 10                	jns    801c2e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	56                   	push   %esi
  801c22:	e8 0e 02 00 00       	call   801e35 <nsipc_close>
		return r;
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	89 d8                	mov    %ebx,%eax
  801c2c:	eb 24                	jmp    801c52 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c43:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	50                   	push   %eax
  801c4a:	e8 9a f6 ff ff       	call   8012e9 <fd2num>
  801c4f:	83 c4 10             	add    $0x10,%esp
}
  801c52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	e8 50 ff ff ff       	call   801bb7 <fd2sockid>
		return r;
  801c67:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 1f                	js     801c8c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	ff 75 10             	pushl  0x10(%ebp)
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	50                   	push   %eax
  801c77:	e8 12 01 00 00       	call   801d8e <nsipc_accept>
  801c7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801c7f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 07                	js     801c8c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c85:	e8 5d ff ff ff       	call   801be7 <alloc_sockfd>
  801c8a:	89 c1                	mov    %eax,%ecx
}
  801c8c:	89 c8                	mov    %ecx,%eax
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c96:	8b 45 08             	mov    0x8(%ebp),%eax
  801c99:	e8 19 ff ff ff       	call   801bb7 <fd2sockid>
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 12                	js     801cb4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ca2:	83 ec 04             	sub    $0x4,%esp
  801ca5:	ff 75 10             	pushl  0x10(%ebp)
  801ca8:	ff 75 0c             	pushl  0xc(%ebp)
  801cab:	50                   	push   %eax
  801cac:	e8 2d 01 00 00       	call   801dde <nsipc_bind>
  801cb1:	83 c4 10             	add    $0x10,%esp
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <shutdown>:

int
shutdown(int s, int how)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	e8 f3 fe ff ff       	call   801bb7 <fd2sockid>
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 0f                	js     801cd7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	ff 75 0c             	pushl  0xc(%ebp)
  801cce:	50                   	push   %eax
  801ccf:	e8 3f 01 00 00       	call   801e13 <nsipc_shutdown>
  801cd4:	83 c4 10             	add    $0x10,%esp
}
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    

00801cd9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	e8 d0 fe ff ff       	call   801bb7 <fd2sockid>
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 12                	js     801cfd <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ceb:	83 ec 04             	sub    $0x4,%esp
  801cee:	ff 75 10             	pushl  0x10(%ebp)
  801cf1:	ff 75 0c             	pushl  0xc(%ebp)
  801cf4:	50                   	push   %eax
  801cf5:	e8 55 01 00 00       	call   801e4f <nsipc_connect>
  801cfa:	83 c4 10             	add    $0x10,%esp
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <listen>:

int
listen(int s, int backlog)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	e8 aa fe ff ff       	call   801bb7 <fd2sockid>
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	78 0f                	js     801d20 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d11:	83 ec 08             	sub    $0x8,%esp
  801d14:	ff 75 0c             	pushl  0xc(%ebp)
  801d17:	50                   	push   %eax
  801d18:	e8 67 01 00 00       	call   801e84 <nsipc_listen>
  801d1d:	83 c4 10             	add    $0x10,%esp
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d28:	ff 75 10             	pushl  0x10(%ebp)
  801d2b:	ff 75 0c             	pushl  0xc(%ebp)
  801d2e:	ff 75 08             	pushl  0x8(%ebp)
  801d31:	e8 3a 02 00 00       	call   801f70 <nsipc_socket>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 05                	js     801d42 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d3d:	e8 a5 fe ff ff       	call   801be7 <alloc_sockfd>
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	53                   	push   %ebx
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d4d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d54:	75 12                	jne    801d68 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d56:	83 ec 0c             	sub    $0xc,%esp
  801d59:	6a 02                	push   $0x2
  801d5b:	e8 50 f5 ff ff       	call   8012b0 <ipc_find_env>
  801d60:	a3 04 40 80 00       	mov    %eax,0x804004
  801d65:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d68:	6a 07                	push   $0x7
  801d6a:	68 00 60 80 00       	push   $0x806000
  801d6f:	53                   	push   %ebx
  801d70:	ff 35 04 40 80 00    	pushl  0x804004
  801d76:	e8 e1 f4 ff ff       	call   80125c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d7b:	83 c4 0c             	add    $0xc,%esp
  801d7e:	6a 00                	push   $0x0
  801d80:	6a 00                	push   $0x0
  801d82:	6a 00                	push   $0x0
  801d84:	e8 66 f4 ff ff       	call   8011ef <ipc_recv>
}
  801d89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	56                   	push   %esi
  801d92:	53                   	push   %ebx
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d9e:	8b 06                	mov    (%esi),%eax
  801da0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801da5:	b8 01 00 00 00       	mov    $0x1,%eax
  801daa:	e8 95 ff ff ff       	call   801d44 <nsipc>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	85 c0                	test   %eax,%eax
  801db3:	78 20                	js     801dd5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801db5:	83 ec 04             	sub    $0x4,%esp
  801db8:	ff 35 10 60 80 00    	pushl  0x806010
  801dbe:	68 00 60 80 00       	push   $0x806000
  801dc3:	ff 75 0c             	pushl  0xc(%ebp)
  801dc6:	e8 73 ec ff ff       	call   800a3e <memmove>
		*addrlen = ret->ret_addrlen;
  801dcb:	a1 10 60 80 00       	mov    0x806010,%eax
  801dd0:	89 06                	mov    %eax,(%esi)
  801dd2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801dd5:	89 d8                	mov    %ebx,%eax
  801dd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	53                   	push   %ebx
  801de2:	83 ec 08             	sub    $0x8,%esp
  801de5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801df0:	53                   	push   %ebx
  801df1:	ff 75 0c             	pushl  0xc(%ebp)
  801df4:	68 04 60 80 00       	push   $0x806004
  801df9:	e8 40 ec ff ff       	call   800a3e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dfe:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e04:	b8 02 00 00 00       	mov    $0x2,%eax
  801e09:	e8 36 ff ff ff       	call   801d44 <nsipc>
}
  801e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e19:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e24:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e29:	b8 03 00 00 00       	mov    $0x3,%eax
  801e2e:	e8 11 ff ff ff       	call   801d44 <nsipc>
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <nsipc_close>:

int
nsipc_close(int s)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e43:	b8 04 00 00 00       	mov    $0x4,%eax
  801e48:	e8 f7 fe ff ff       	call   801d44 <nsipc>
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	53                   	push   %ebx
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e61:	53                   	push   %ebx
  801e62:	ff 75 0c             	pushl  0xc(%ebp)
  801e65:	68 04 60 80 00       	push   $0x806004
  801e6a:	e8 cf eb ff ff       	call   800a3e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e6f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e75:	b8 05 00 00 00       	mov    $0x5,%eax
  801e7a:	e8 c5 fe ff ff       	call   801d44 <nsipc>
}
  801e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e9a:	b8 06 00 00 00       	mov    $0x6,%eax
  801e9f:	e8 a0 fe ff ff       	call   801d44 <nsipc>
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	56                   	push   %esi
  801eaa:	53                   	push   %ebx
  801eab:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eae:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801eb6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ebc:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebf:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ec4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ec9:	e8 76 fe ff ff       	call   801d44 <nsipc>
  801ece:	89 c3                	mov    %eax,%ebx
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 35                	js     801f09 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ed4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ed9:	7f 04                	jg     801edf <nsipc_recv+0x39>
  801edb:	39 c6                	cmp    %eax,%esi
  801edd:	7d 16                	jge    801ef5 <nsipc_recv+0x4f>
  801edf:	68 37 2e 80 00       	push   $0x802e37
  801ee4:	68 ff 2d 80 00       	push   $0x802dff
  801ee9:	6a 62                	push   $0x62
  801eeb:	68 4c 2e 80 00       	push   $0x802e4c
  801ef0:	e8 59 e3 ff ff       	call   80024e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	50                   	push   %eax
  801ef9:	68 00 60 80 00       	push   $0x806000
  801efe:	ff 75 0c             	pushl  0xc(%ebp)
  801f01:	e8 38 eb ff ff       	call   800a3e <memmove>
  801f06:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f09:	89 d8                	mov    %ebx,%eax
  801f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	53                   	push   %ebx
  801f16:	83 ec 04             	sub    $0x4,%esp
  801f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f24:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f2a:	7e 16                	jle    801f42 <nsipc_send+0x30>
  801f2c:	68 58 2e 80 00       	push   $0x802e58
  801f31:	68 ff 2d 80 00       	push   $0x802dff
  801f36:	6a 6d                	push   $0x6d
  801f38:	68 4c 2e 80 00       	push   $0x802e4c
  801f3d:	e8 0c e3 ff ff       	call   80024e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f42:	83 ec 04             	sub    $0x4,%esp
  801f45:	53                   	push   %ebx
  801f46:	ff 75 0c             	pushl  0xc(%ebp)
  801f49:	68 0c 60 80 00       	push   $0x80600c
  801f4e:	e8 eb ea ff ff       	call   800a3e <memmove>
	nsipcbuf.send.req_size = size;
  801f53:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f59:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f61:	b8 08 00 00 00       	mov    $0x8,%eax
  801f66:	e8 d9 fd ff ff       	call   801d44 <nsipc>
}
  801f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f76:	8b 45 08             	mov    0x8(%ebp),%eax
  801f79:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f81:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f86:	8b 45 10             	mov    0x10(%ebp),%eax
  801f89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f8e:	b8 09 00 00 00       	mov    $0x9,%eax
  801f93:	e8 ac fd ff ff       	call   801d44 <nsipc>
}
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	56                   	push   %esi
  801f9e:	53                   	push   %ebx
  801f9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fa2:	83 ec 0c             	sub    $0xc,%esp
  801fa5:	ff 75 08             	pushl  0x8(%ebp)
  801fa8:	e8 4c f3 ff ff       	call   8012f9 <fd2data>
  801fad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801faf:	83 c4 08             	add    $0x8,%esp
  801fb2:	68 64 2e 80 00       	push   $0x802e64
  801fb7:	53                   	push   %ebx
  801fb8:	e8 ef e8 ff ff       	call   8008ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fbd:	8b 46 04             	mov    0x4(%esi),%eax
  801fc0:	2b 06                	sub    (%esi),%eax
  801fc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fcf:	00 00 00 
	stat->st_dev = &devpipe;
  801fd2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801fd9:	30 80 00 
	return 0;
}
  801fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    

00801fe8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	53                   	push   %ebx
  801fec:	83 ec 0c             	sub    $0xc,%esp
  801fef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ff2:	53                   	push   %ebx
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 3a ed ff ff       	call   800d34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ffa:	89 1c 24             	mov    %ebx,(%esp)
  801ffd:	e8 f7 f2 ff ff       	call   8012f9 <fd2data>
  802002:	83 c4 08             	add    $0x8,%esp
  802005:	50                   	push   %eax
  802006:	6a 00                	push   $0x0
  802008:	e8 27 ed ff ff       	call   800d34 <sys_page_unmap>
}
  80200d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80201e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802020:	a1 08 40 80 00       	mov    0x804008,%eax
  802025:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802028:	83 ec 0c             	sub    $0xc,%esp
  80202b:	ff 75 e0             	pushl  -0x20(%ebp)
  80202e:	e8 c5 fa ff ff       	call   801af8 <pageref>
  802033:	89 c3                	mov    %eax,%ebx
  802035:	89 3c 24             	mov    %edi,(%esp)
  802038:	e8 bb fa ff ff       	call   801af8 <pageref>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	39 c3                	cmp    %eax,%ebx
  802042:	0f 94 c1             	sete   %cl
  802045:	0f b6 c9             	movzbl %cl,%ecx
  802048:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80204b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802051:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802054:	39 ce                	cmp    %ecx,%esi
  802056:	74 1b                	je     802073 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802058:	39 c3                	cmp    %eax,%ebx
  80205a:	75 c4                	jne    802020 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80205c:	8b 42 58             	mov    0x58(%edx),%eax
  80205f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802062:	50                   	push   %eax
  802063:	56                   	push   %esi
  802064:	68 6b 2e 80 00       	push   $0x802e6b
  802069:	e8 b9 e2 ff ff       	call   800327 <cprintf>
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	eb ad                	jmp    802020 <_pipeisclosed+0xe>
	}
}
  802073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802079:	5b                   	pop    %ebx
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 28             	sub    $0x28,%esp
  802087:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80208a:	56                   	push   %esi
  80208b:	e8 69 f2 ff ff       	call   8012f9 <fd2data>
  802090:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	bf 00 00 00 00       	mov    $0x0,%edi
  80209a:	eb 4b                	jmp    8020e7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80209c:	89 da                	mov    %ebx,%edx
  80209e:	89 f0                	mov    %esi,%eax
  8020a0:	e8 6d ff ff ff       	call   802012 <_pipeisclosed>
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	75 48                	jne    8020f1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020a9:	e8 e2 eb ff ff       	call   800c90 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8020b1:	8b 0b                	mov    (%ebx),%ecx
  8020b3:	8d 51 20             	lea    0x20(%ecx),%edx
  8020b6:	39 d0                	cmp    %edx,%eax
  8020b8:	73 e2                	jae    80209c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020bd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020c1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	c1 fa 1f             	sar    $0x1f,%edx
  8020c9:	89 d1                	mov    %edx,%ecx
  8020cb:	c1 e9 1b             	shr    $0x1b,%ecx
  8020ce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020d1:	83 e2 1f             	and    $0x1f,%edx
  8020d4:	29 ca                	sub    %ecx,%edx
  8020d6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020de:	83 c0 01             	add    $0x1,%eax
  8020e1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e4:	83 c7 01             	add    $0x1,%edi
  8020e7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020ea:	75 c2                	jne    8020ae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ef:	eb 05                	jmp    8020f6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f9:	5b                   	pop    %ebx
  8020fa:	5e                   	pop    %esi
  8020fb:	5f                   	pop    %edi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    

008020fe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 18             	sub    $0x18,%esp
  802107:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80210a:	57                   	push   %edi
  80210b:	e8 e9 f1 ff ff       	call   8012f9 <fd2data>
  802110:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	bb 00 00 00 00       	mov    $0x0,%ebx
  80211a:	eb 3d                	jmp    802159 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80211c:	85 db                	test   %ebx,%ebx
  80211e:	74 04                	je     802124 <devpipe_read+0x26>
				return i;
  802120:	89 d8                	mov    %ebx,%eax
  802122:	eb 44                	jmp    802168 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802124:	89 f2                	mov    %esi,%edx
  802126:	89 f8                	mov    %edi,%eax
  802128:	e8 e5 fe ff ff       	call   802012 <_pipeisclosed>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	75 32                	jne    802163 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802131:	e8 5a eb ff ff       	call   800c90 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802136:	8b 06                	mov    (%esi),%eax
  802138:	3b 46 04             	cmp    0x4(%esi),%eax
  80213b:	74 df                	je     80211c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80213d:	99                   	cltd   
  80213e:	c1 ea 1b             	shr    $0x1b,%edx
  802141:	01 d0                	add    %edx,%eax
  802143:	83 e0 1f             	and    $0x1f,%eax
  802146:	29 d0                	sub    %edx,%eax
  802148:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80214d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802150:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802153:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802156:	83 c3 01             	add    $0x1,%ebx
  802159:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80215c:	75 d8                	jne    802136 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80215e:	8b 45 10             	mov    0x10(%ebp),%eax
  802161:	eb 05                	jmp    802168 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5f                   	pop    %edi
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    

00802170 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	56                   	push   %esi
  802174:	53                   	push   %ebx
  802175:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217b:	50                   	push   %eax
  80217c:	e8 8f f1 ff ff       	call   801310 <fd_alloc>
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	89 c2                	mov    %eax,%edx
  802186:	85 c0                	test   %eax,%eax
  802188:	0f 88 2c 01 00 00    	js     8022ba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218e:	83 ec 04             	sub    $0x4,%esp
  802191:	68 07 04 00 00       	push   $0x407
  802196:	ff 75 f4             	pushl  -0xc(%ebp)
  802199:	6a 00                	push   $0x0
  80219b:	e8 0f eb ff ff       	call   800caf <sys_page_alloc>
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	89 c2                	mov    %eax,%edx
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	0f 88 0d 01 00 00    	js     8022ba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021ad:	83 ec 0c             	sub    $0xc,%esp
  8021b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021b3:	50                   	push   %eax
  8021b4:	e8 57 f1 ff ff       	call   801310 <fd_alloc>
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	83 c4 10             	add    $0x10,%esp
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	0f 88 e2 00 00 00    	js     8022a8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c6:	83 ec 04             	sub    $0x4,%esp
  8021c9:	68 07 04 00 00       	push   $0x407
  8021ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d1:	6a 00                	push   $0x0
  8021d3:	e8 d7 ea ff ff       	call   800caf <sys_page_alloc>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	0f 88 c3 00 00 00    	js     8022a8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021e5:	83 ec 0c             	sub    $0xc,%esp
  8021e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8021eb:	e8 09 f1 ff ff       	call   8012f9 <fd2data>
  8021f0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f2:	83 c4 0c             	add    $0xc,%esp
  8021f5:	68 07 04 00 00       	push   $0x407
  8021fa:	50                   	push   %eax
  8021fb:	6a 00                	push   $0x0
  8021fd:	e8 ad ea ff ff       	call   800caf <sys_page_alloc>
  802202:	89 c3                	mov    %eax,%ebx
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	85 c0                	test   %eax,%eax
  802209:	0f 88 89 00 00 00    	js     802298 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80220f:	83 ec 0c             	sub    $0xc,%esp
  802212:	ff 75 f0             	pushl  -0x10(%ebp)
  802215:	e8 df f0 ff ff       	call   8012f9 <fd2data>
  80221a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802221:	50                   	push   %eax
  802222:	6a 00                	push   $0x0
  802224:	56                   	push   %esi
  802225:	6a 00                	push   $0x0
  802227:	e8 c6 ea ff ff       	call   800cf2 <sys_page_map>
  80222c:	89 c3                	mov    %eax,%ebx
  80222e:	83 c4 20             	add    $0x20,%esp
  802231:	85 c0                	test   %eax,%eax
  802233:	78 55                	js     80228a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802235:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80223b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802243:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80224a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802253:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802255:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802258:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80225f:	83 ec 0c             	sub    $0xc,%esp
  802262:	ff 75 f4             	pushl  -0xc(%ebp)
  802265:	e8 7f f0 ff ff       	call   8012e9 <fd2num>
  80226a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80226d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80226f:	83 c4 04             	add    $0x4,%esp
  802272:	ff 75 f0             	pushl  -0x10(%ebp)
  802275:	e8 6f f0 ff ff       	call   8012e9 <fd2num>
  80227a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80227d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	ba 00 00 00 00       	mov    $0x0,%edx
  802288:	eb 30                	jmp    8022ba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80228a:	83 ec 08             	sub    $0x8,%esp
  80228d:	56                   	push   %esi
  80228e:	6a 00                	push   $0x0
  802290:	e8 9f ea ff ff       	call   800d34 <sys_page_unmap>
  802295:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802298:	83 ec 08             	sub    $0x8,%esp
  80229b:	ff 75 f0             	pushl  -0x10(%ebp)
  80229e:	6a 00                	push   $0x0
  8022a0:	e8 8f ea ff ff       	call   800d34 <sys_page_unmap>
  8022a5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022a8:	83 ec 08             	sub    $0x8,%esp
  8022ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ae:	6a 00                	push   $0x0
  8022b0:	e8 7f ea ff ff       	call   800d34 <sys_page_unmap>
  8022b5:	83 c4 10             	add    $0x10,%esp
  8022b8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022ba:	89 d0                	mov    %edx,%eax
  8022bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5e                   	pop    %esi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    

008022c3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cc:	50                   	push   %eax
  8022cd:	ff 75 08             	pushl  0x8(%ebp)
  8022d0:	e8 8a f0 ff ff       	call   80135f <fd_lookup>
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 18                	js     8022f4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022dc:	83 ec 0c             	sub    $0xc,%esp
  8022df:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e2:	e8 12 f0 ff ff       	call   8012f9 <fd2data>
	return _pipeisclosed(fd, p);
  8022e7:	89 c2                	mov    %eax,%edx
  8022e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ec:	e8 21 fd ff ff       	call   802012 <_pipeisclosed>
  8022f1:	83 c4 10             	add    $0x10,%esp
}
  8022f4:	c9                   	leave  
  8022f5:	c3                   	ret    

008022f6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fe:	5d                   	pop    %ebp
  8022ff:	c3                   	ret    

00802300 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802306:	68 83 2e 80 00       	push   $0x802e83
  80230b:	ff 75 0c             	pushl  0xc(%ebp)
  80230e:	e8 99 e5 ff ff       	call   8008ac <strcpy>
	return 0;
}
  802313:	b8 00 00 00 00       	mov    $0x0,%eax
  802318:	c9                   	leave  
  802319:	c3                   	ret    

0080231a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	57                   	push   %edi
  80231e:	56                   	push   %esi
  80231f:	53                   	push   %ebx
  802320:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802326:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80232b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802331:	eb 2d                	jmp    802360 <devcons_write+0x46>
		m = n - tot;
  802333:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802336:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802338:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80233b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802340:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802343:	83 ec 04             	sub    $0x4,%esp
  802346:	53                   	push   %ebx
  802347:	03 45 0c             	add    0xc(%ebp),%eax
  80234a:	50                   	push   %eax
  80234b:	57                   	push   %edi
  80234c:	e8 ed e6 ff ff       	call   800a3e <memmove>
		sys_cputs(buf, m);
  802351:	83 c4 08             	add    $0x8,%esp
  802354:	53                   	push   %ebx
  802355:	57                   	push   %edi
  802356:	e8 98 e8 ff ff       	call   800bf3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80235b:	01 de                	add    %ebx,%esi
  80235d:	83 c4 10             	add    $0x10,%esp
  802360:	89 f0                	mov    %esi,%eax
  802362:	3b 75 10             	cmp    0x10(%ebp),%esi
  802365:	72 cc                	jb     802333 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5f                   	pop    %edi
  80236d:	5d                   	pop    %ebp
  80236e:	c3                   	ret    

0080236f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	83 ec 08             	sub    $0x8,%esp
  802375:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80237a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80237e:	74 2a                	je     8023aa <devcons_read+0x3b>
  802380:	eb 05                	jmp    802387 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802382:	e8 09 e9 ff ff       	call   800c90 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802387:	e8 85 e8 ff ff       	call   800c11 <sys_cgetc>
  80238c:	85 c0                	test   %eax,%eax
  80238e:	74 f2                	je     802382 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802390:	85 c0                	test   %eax,%eax
  802392:	78 16                	js     8023aa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802394:	83 f8 04             	cmp    $0x4,%eax
  802397:	74 0c                	je     8023a5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802399:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239c:	88 02                	mov    %al,(%edx)
	return 1;
  80239e:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a3:	eb 05                	jmp    8023aa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023aa:	c9                   	leave  
  8023ab:	c3                   	ret    

008023ac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023ac:	55                   	push   %ebp
  8023ad:	89 e5                	mov    %esp,%ebp
  8023af:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023b8:	6a 01                	push   $0x1
  8023ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023bd:	50                   	push   %eax
  8023be:	e8 30 e8 ff ff       	call   800bf3 <sys_cputs>
}
  8023c3:	83 c4 10             	add    $0x10,%esp
  8023c6:	c9                   	leave  
  8023c7:	c3                   	ret    

008023c8 <getchar>:

int
getchar(void)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ce:	6a 01                	push   $0x1
  8023d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d3:	50                   	push   %eax
  8023d4:	6a 00                	push   $0x0
  8023d6:	e8 ea f1 ff ff       	call   8015c5 <read>
	if (r < 0)
  8023db:	83 c4 10             	add    $0x10,%esp
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 0f                	js     8023f1 <getchar+0x29>
		return r;
	if (r < 1)
  8023e2:	85 c0                	test   %eax,%eax
  8023e4:	7e 06                	jle    8023ec <getchar+0x24>
		return -E_EOF;
	return c;
  8023e6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023ea:	eb 05                	jmp    8023f1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023ec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023f1:	c9                   	leave  
  8023f2:	c3                   	ret    

008023f3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023fc:	50                   	push   %eax
  8023fd:	ff 75 08             	pushl  0x8(%ebp)
  802400:	e8 5a ef ff ff       	call   80135f <fd_lookup>
  802405:	83 c4 10             	add    $0x10,%esp
  802408:	85 c0                	test   %eax,%eax
  80240a:	78 11                	js     80241d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80240c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802415:	39 10                	cmp    %edx,(%eax)
  802417:	0f 94 c0             	sete   %al
  80241a:	0f b6 c0             	movzbl %al,%eax
}
  80241d:	c9                   	leave  
  80241e:	c3                   	ret    

0080241f <opencons>:

int
opencons(void)
{
  80241f:	55                   	push   %ebp
  802420:	89 e5                	mov    %esp,%ebp
  802422:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802428:	50                   	push   %eax
  802429:	e8 e2 ee ff ff       	call   801310 <fd_alloc>
  80242e:	83 c4 10             	add    $0x10,%esp
		return r;
  802431:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802433:	85 c0                	test   %eax,%eax
  802435:	78 3e                	js     802475 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802437:	83 ec 04             	sub    $0x4,%esp
  80243a:	68 07 04 00 00       	push   $0x407
  80243f:	ff 75 f4             	pushl  -0xc(%ebp)
  802442:	6a 00                	push   $0x0
  802444:	e8 66 e8 ff ff       	call   800caf <sys_page_alloc>
  802449:	83 c4 10             	add    $0x10,%esp
		return r;
  80244c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 23                	js     802475 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802452:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80245d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802460:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802467:	83 ec 0c             	sub    $0xc,%esp
  80246a:	50                   	push   %eax
  80246b:	e8 79 ee ff ff       	call   8012e9 <fd2num>
  802470:	89 c2                	mov    %eax,%edx
  802472:	83 c4 10             	add    $0x10,%esp
}
  802475:	89 d0                	mov    %edx,%eax
  802477:	c9                   	leave  
  802478:	c3                   	ret    

00802479 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802479:	55                   	push   %ebp
  80247a:	89 e5                	mov    %esp,%ebp
  80247c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80247f:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802486:	75 2c                	jne    8024b4 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802488:	83 ec 04             	sub    $0x4,%esp
  80248b:	6a 07                	push   $0x7
  80248d:	68 00 f0 bf ee       	push   $0xeebff000
  802492:	6a 00                	push   $0x0
  802494:	e8 16 e8 ff ff       	call   800caf <sys_page_alloc>
  802499:	83 c4 10             	add    $0x10,%esp
  80249c:	85 c0                	test   %eax,%eax
  80249e:	79 14                	jns    8024b4 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  8024a0:	83 ec 04             	sub    $0x4,%esp
  8024a3:	68 8f 2e 80 00       	push   $0x802e8f
  8024a8:	6a 22                	push   $0x22
  8024aa:	68 a6 2e 80 00       	push   $0x802ea6
  8024af:	e8 9a dd ff ff       	call   80024e <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  8024b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b7:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8024bc:	83 ec 08             	sub    $0x8,%esp
  8024bf:	68 e8 24 80 00       	push   $0x8024e8
  8024c4:	6a 00                	push   $0x0
  8024c6:	e8 2f e9 ff ff       	call   800dfa <sys_env_set_pgfault_upcall>
  8024cb:	83 c4 10             	add    $0x10,%esp
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	79 14                	jns    8024e6 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8024d2:	83 ec 04             	sub    $0x4,%esp
  8024d5:	68 b4 2e 80 00       	push   $0x802eb4
  8024da:	6a 27                	push   $0x27
  8024dc:	68 a6 2e 80 00       	push   $0x802ea6
  8024e1:	e8 68 dd ff ff       	call   80024e <_panic>
    
}
  8024e6:	c9                   	leave  
  8024e7:	c3                   	ret    

008024e8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024e8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024e9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024ee:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024f0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8024f3:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8024f7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8024fc:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802500:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802502:	83 c4 08             	add    $0x8,%esp
	popal
  802505:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  802506:	83 c4 04             	add    $0x4,%esp
	popfl
  802509:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80250a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80250b:	c3                   	ret    
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__udivdi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80251b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80251f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 f6                	test   %esi,%esi
  802529:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80252d:	89 ca                	mov    %ecx,%edx
  80252f:	89 f8                	mov    %edi,%eax
  802531:	75 3d                	jne    802570 <__udivdi3+0x60>
  802533:	39 cf                	cmp    %ecx,%edi
  802535:	0f 87 c5 00 00 00    	ja     802600 <__udivdi3+0xf0>
  80253b:	85 ff                	test   %edi,%edi
  80253d:	89 fd                	mov    %edi,%ebp
  80253f:	75 0b                	jne    80254c <__udivdi3+0x3c>
  802541:	b8 01 00 00 00       	mov    $0x1,%eax
  802546:	31 d2                	xor    %edx,%edx
  802548:	f7 f7                	div    %edi
  80254a:	89 c5                	mov    %eax,%ebp
  80254c:	89 c8                	mov    %ecx,%eax
  80254e:	31 d2                	xor    %edx,%edx
  802550:	f7 f5                	div    %ebp
  802552:	89 c1                	mov    %eax,%ecx
  802554:	89 d8                	mov    %ebx,%eax
  802556:	89 cf                	mov    %ecx,%edi
  802558:	f7 f5                	div    %ebp
  80255a:	89 c3                	mov    %eax,%ebx
  80255c:	89 d8                	mov    %ebx,%eax
  80255e:	89 fa                	mov    %edi,%edx
  802560:	83 c4 1c             	add    $0x1c,%esp
  802563:	5b                   	pop    %ebx
  802564:	5e                   	pop    %esi
  802565:	5f                   	pop    %edi
  802566:	5d                   	pop    %ebp
  802567:	c3                   	ret    
  802568:	90                   	nop
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	39 ce                	cmp    %ecx,%esi
  802572:	77 74                	ja     8025e8 <__udivdi3+0xd8>
  802574:	0f bd fe             	bsr    %esi,%edi
  802577:	83 f7 1f             	xor    $0x1f,%edi
  80257a:	0f 84 98 00 00 00    	je     802618 <__udivdi3+0x108>
  802580:	bb 20 00 00 00       	mov    $0x20,%ebx
  802585:	89 f9                	mov    %edi,%ecx
  802587:	89 c5                	mov    %eax,%ebp
  802589:	29 fb                	sub    %edi,%ebx
  80258b:	d3 e6                	shl    %cl,%esi
  80258d:	89 d9                	mov    %ebx,%ecx
  80258f:	d3 ed                	shr    %cl,%ebp
  802591:	89 f9                	mov    %edi,%ecx
  802593:	d3 e0                	shl    %cl,%eax
  802595:	09 ee                	or     %ebp,%esi
  802597:	89 d9                	mov    %ebx,%ecx
  802599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80259d:	89 d5                	mov    %edx,%ebp
  80259f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025a3:	d3 ed                	shr    %cl,%ebp
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	d3 e2                	shl    %cl,%edx
  8025a9:	89 d9                	mov    %ebx,%ecx
  8025ab:	d3 e8                	shr    %cl,%eax
  8025ad:	09 c2                	or     %eax,%edx
  8025af:	89 d0                	mov    %edx,%eax
  8025b1:	89 ea                	mov    %ebp,%edx
  8025b3:	f7 f6                	div    %esi
  8025b5:	89 d5                	mov    %edx,%ebp
  8025b7:	89 c3                	mov    %eax,%ebx
  8025b9:	f7 64 24 0c          	mull   0xc(%esp)
  8025bd:	39 d5                	cmp    %edx,%ebp
  8025bf:	72 10                	jb     8025d1 <__udivdi3+0xc1>
  8025c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	d3 e6                	shl    %cl,%esi
  8025c9:	39 c6                	cmp    %eax,%esi
  8025cb:	73 07                	jae    8025d4 <__udivdi3+0xc4>
  8025cd:	39 d5                	cmp    %edx,%ebp
  8025cf:	75 03                	jne    8025d4 <__udivdi3+0xc4>
  8025d1:	83 eb 01             	sub    $0x1,%ebx
  8025d4:	31 ff                	xor    %edi,%edi
  8025d6:	89 d8                	mov    %ebx,%eax
  8025d8:	89 fa                	mov    %edi,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	31 ff                	xor    %edi,%edi
  8025ea:	31 db                	xor    %ebx,%ebx
  8025ec:	89 d8                	mov    %ebx,%eax
  8025ee:	89 fa                	mov    %edi,%edx
  8025f0:	83 c4 1c             	add    $0x1c,%esp
  8025f3:	5b                   	pop    %ebx
  8025f4:	5e                   	pop    %esi
  8025f5:	5f                   	pop    %edi
  8025f6:	5d                   	pop    %ebp
  8025f7:	c3                   	ret    
  8025f8:	90                   	nop
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	89 d8                	mov    %ebx,%eax
  802602:	f7 f7                	div    %edi
  802604:	31 ff                	xor    %edi,%edi
  802606:	89 c3                	mov    %eax,%ebx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 fa                	mov    %edi,%edx
  80260c:	83 c4 1c             	add    $0x1c,%esp
  80260f:	5b                   	pop    %ebx
  802610:	5e                   	pop    %esi
  802611:	5f                   	pop    %edi
  802612:	5d                   	pop    %ebp
  802613:	c3                   	ret    
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	39 ce                	cmp    %ecx,%esi
  80261a:	72 0c                	jb     802628 <__udivdi3+0x118>
  80261c:	31 db                	xor    %ebx,%ebx
  80261e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802622:	0f 87 34 ff ff ff    	ja     80255c <__udivdi3+0x4c>
  802628:	bb 01 00 00 00       	mov    $0x1,%ebx
  80262d:	e9 2a ff ff ff       	jmp    80255c <__udivdi3+0x4c>
  802632:	66 90                	xchg   %ax,%ax
  802634:	66 90                	xchg   %ax,%ax
  802636:	66 90                	xchg   %ax,%ax
  802638:	66 90                	xchg   %ax,%ax
  80263a:	66 90                	xchg   %ax,%ax
  80263c:	66 90                	xchg   %ax,%ax
  80263e:	66 90                	xchg   %ax,%ax

00802640 <__umoddi3>:
  802640:	55                   	push   %ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	83 ec 1c             	sub    $0x1c,%esp
  802647:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80264b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80264f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802653:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802657:	85 d2                	test   %edx,%edx
  802659:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80265d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802661:	89 f3                	mov    %esi,%ebx
  802663:	89 3c 24             	mov    %edi,(%esp)
  802666:	89 74 24 04          	mov    %esi,0x4(%esp)
  80266a:	75 1c                	jne    802688 <__umoddi3+0x48>
  80266c:	39 f7                	cmp    %esi,%edi
  80266e:	76 50                	jbe    8026c0 <__umoddi3+0x80>
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 f2                	mov    %esi,%edx
  802674:	f7 f7                	div    %edi
  802676:	89 d0                	mov    %edx,%eax
  802678:	31 d2                	xor    %edx,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	39 f2                	cmp    %esi,%edx
  80268a:	89 d0                	mov    %edx,%eax
  80268c:	77 52                	ja     8026e0 <__umoddi3+0xa0>
  80268e:	0f bd ea             	bsr    %edx,%ebp
  802691:	83 f5 1f             	xor    $0x1f,%ebp
  802694:	75 5a                	jne    8026f0 <__umoddi3+0xb0>
  802696:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80269a:	0f 82 e0 00 00 00    	jb     802780 <__umoddi3+0x140>
  8026a0:	39 0c 24             	cmp    %ecx,(%esp)
  8026a3:	0f 86 d7 00 00 00    	jbe    802780 <__umoddi3+0x140>
  8026a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026b1:	83 c4 1c             	add    $0x1c,%esp
  8026b4:	5b                   	pop    %ebx
  8026b5:	5e                   	pop    %esi
  8026b6:	5f                   	pop    %edi
  8026b7:	5d                   	pop    %ebp
  8026b8:	c3                   	ret    
  8026b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	85 ff                	test   %edi,%edi
  8026c2:	89 fd                	mov    %edi,%ebp
  8026c4:	75 0b                	jne    8026d1 <__umoddi3+0x91>
  8026c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026cb:	31 d2                	xor    %edx,%edx
  8026cd:	f7 f7                	div    %edi
  8026cf:	89 c5                	mov    %eax,%ebp
  8026d1:	89 f0                	mov    %esi,%eax
  8026d3:	31 d2                	xor    %edx,%edx
  8026d5:	f7 f5                	div    %ebp
  8026d7:	89 c8                	mov    %ecx,%eax
  8026d9:	f7 f5                	div    %ebp
  8026db:	89 d0                	mov    %edx,%eax
  8026dd:	eb 99                	jmp    802678 <__umoddi3+0x38>
  8026df:	90                   	nop
  8026e0:	89 c8                	mov    %ecx,%eax
  8026e2:	89 f2                	mov    %esi,%edx
  8026e4:	83 c4 1c             	add    $0x1c,%esp
  8026e7:	5b                   	pop    %ebx
  8026e8:	5e                   	pop    %esi
  8026e9:	5f                   	pop    %edi
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    
  8026ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	8b 34 24             	mov    (%esp),%esi
  8026f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026f8:	89 e9                	mov    %ebp,%ecx
  8026fa:	29 ef                	sub    %ebp,%edi
  8026fc:	d3 e0                	shl    %cl,%eax
  8026fe:	89 f9                	mov    %edi,%ecx
  802700:	89 f2                	mov    %esi,%edx
  802702:	d3 ea                	shr    %cl,%edx
  802704:	89 e9                	mov    %ebp,%ecx
  802706:	09 c2                	or     %eax,%edx
  802708:	89 d8                	mov    %ebx,%eax
  80270a:	89 14 24             	mov    %edx,(%esp)
  80270d:	89 f2                	mov    %esi,%edx
  80270f:	d3 e2                	shl    %cl,%edx
  802711:	89 f9                	mov    %edi,%ecx
  802713:	89 54 24 04          	mov    %edx,0x4(%esp)
  802717:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80271b:	d3 e8                	shr    %cl,%eax
  80271d:	89 e9                	mov    %ebp,%ecx
  80271f:	89 c6                	mov    %eax,%esi
  802721:	d3 e3                	shl    %cl,%ebx
  802723:	89 f9                	mov    %edi,%ecx
  802725:	89 d0                	mov    %edx,%eax
  802727:	d3 e8                	shr    %cl,%eax
  802729:	89 e9                	mov    %ebp,%ecx
  80272b:	09 d8                	or     %ebx,%eax
  80272d:	89 d3                	mov    %edx,%ebx
  80272f:	89 f2                	mov    %esi,%edx
  802731:	f7 34 24             	divl   (%esp)
  802734:	89 d6                	mov    %edx,%esi
  802736:	d3 e3                	shl    %cl,%ebx
  802738:	f7 64 24 04          	mull   0x4(%esp)
  80273c:	39 d6                	cmp    %edx,%esi
  80273e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802742:	89 d1                	mov    %edx,%ecx
  802744:	89 c3                	mov    %eax,%ebx
  802746:	72 08                	jb     802750 <__umoddi3+0x110>
  802748:	75 11                	jne    80275b <__umoddi3+0x11b>
  80274a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80274e:	73 0b                	jae    80275b <__umoddi3+0x11b>
  802750:	2b 44 24 04          	sub    0x4(%esp),%eax
  802754:	1b 14 24             	sbb    (%esp),%edx
  802757:	89 d1                	mov    %edx,%ecx
  802759:	89 c3                	mov    %eax,%ebx
  80275b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80275f:	29 da                	sub    %ebx,%edx
  802761:	19 ce                	sbb    %ecx,%esi
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 f0                	mov    %esi,%eax
  802767:	d3 e0                	shl    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	d3 ea                	shr    %cl,%edx
  80276d:	89 e9                	mov    %ebp,%ecx
  80276f:	d3 ee                	shr    %cl,%esi
  802771:	09 d0                	or     %edx,%eax
  802773:	89 f2                	mov    %esi,%edx
  802775:	83 c4 1c             	add    $0x1c,%esp
  802778:	5b                   	pop    %ebx
  802779:	5e                   	pop    %esi
  80277a:	5f                   	pop    %edi
  80277b:	5d                   	pop    %ebp
  80277c:	c3                   	ret    
  80277d:	8d 76 00             	lea    0x0(%esi),%esi
  802780:	29 f9                	sub    %edi,%ecx
  802782:	19 d6                	sbb    %edx,%esi
  802784:	89 74 24 04          	mov    %esi,0x4(%esp)
  802788:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80278c:	e9 18 ff ff ff       	jmp    8026a9 <__umoddi3+0x69>
