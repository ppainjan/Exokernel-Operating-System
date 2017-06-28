
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 a0 27 80 00       	push   $0x8027a0
  800041:	e8 d3 02 00 00       	call   800319 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 dc 1f 00 00       	call   80202d <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ee 27 80 00       	push   $0x8027ee
  80005e:	6a 0d                	push   $0xd
  800060:	68 f7 27 80 00       	push   $0x8027f7
  800065:	e8 d6 01 00 00       	call   800240 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 5d 0f 00 00       	call   800fcc <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 0c 28 80 00       	push   $0x80280c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 f7 27 80 00       	push   $0x8027f7
  800082:	e8 b9 01 00 00       	call   800240 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 eb 12 00 00       	call   801381 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 15 28 80 00       	push   $0x802815
  8000c3:	e8 51 02 00 00       	call   800319 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 f9 12 00 00       	call   8013d1 <dup>
			sys_yield();
  8000d8:	e8 a5 0b 00 00       	call   800c82 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 98 12 00 00       	call   801381 <close>
			sys_yield();
  8000e9:	e8 94 0b 00 00       	call   800c82 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 25 01 00 00       	call   800226 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 5e 20 00 00       	call   802180 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 19 28 80 00       	push   $0x802819
  800131:	e8 e3 01 00 00       	call   800319 <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 e4 0a 00 00       	call   800c22 <sys_env_destroy>
			exit();
  80013e:	e8 e3 00 00 00       	call   800226 <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 35 28 80 00       	push   $0x802835
  800161:	e8 b3 01 00 00       	call   800319 <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 0f 20 00 00       	call   802180 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 c4 27 80 00       	push   $0x8027c4
  800180:	6a 40                	push   $0x40
  800182:	68 f7 27 80 00       	push   $0x8027f7
  800187:	e8 b4 00 00 00       	call   800240 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 bc 10 00 00       	call   801257 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 4b 28 80 00       	push   $0x80284b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 f7 27 80 00       	push   $0x8027f7
  8001af:	e8 8c 00 00 00       	call   800240 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 32 10 00 00       	call   8011f1 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 63 28 80 00 	movl   $0x802863,(%esp)
  8001c6:	e8 4e 01 00 00       	call   800319 <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001e1:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8001e8:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8001eb:	e8 73 0a 00 00       	call   800c63 <sys_getenvid>
  8001f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001fd:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800202:	85 db                	test   %ebx,%ebx
  800204:	7e 07                	jle    80020d <libmain+0x37>
		binaryname = argv[0];
  800206:	8b 06                	mov    (%esi),%eax
  800208:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	e8 1c fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800217:	e8 0a 00 00 00       	call   800226 <exit>
}
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80022c:	e8 7b 11 00 00       	call   8013ac <close_all>
	sys_env_destroy(0);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	6a 00                	push   $0x0
  800236:	e8 e7 09 00 00       	call   800c22 <sys_env_destroy>
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800245:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800248:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80024e:	e8 10 0a 00 00       	call   800c63 <sys_getenvid>
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 0c             	pushl  0xc(%ebp)
  800259:	ff 75 08             	pushl  0x8(%ebp)
  80025c:	56                   	push   %esi
  80025d:	50                   	push   %eax
  80025e:	68 84 28 80 00       	push   $0x802884
  800263:	e8 b1 00 00 00       	call   800319 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	53                   	push   %ebx
  80026c:	ff 75 10             	pushl  0x10(%ebp)
  80026f:	e8 54 00 00 00       	call   8002c8 <vcprintf>
	cprintf("\n");
  800274:	c7 04 24 fa 2b 80 00 	movl   $0x802bfa,(%esp)
  80027b:	e8 99 00 00 00       	call   800319 <cprintf>
  800280:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x43>

00800286 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	53                   	push   %ebx
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800290:	8b 13                	mov    (%ebx),%edx
  800292:	8d 42 01             	lea    0x1(%edx),%eax
  800295:	89 03                	mov    %eax,(%ebx)
  800297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 1a                	jne    8002bf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	68 ff 00 00 00       	push   $0xff
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 2f 09 00 00       	call   800be5 <sys_cputs>
		b->idx = 0;
  8002b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d8:	00 00 00 
	b.cnt = 0;
  8002db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e5:	ff 75 0c             	pushl  0xc(%ebp)
  8002e8:	ff 75 08             	pushl  0x8(%ebp)
  8002eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f1:	50                   	push   %eax
  8002f2:	68 86 02 80 00       	push   $0x800286
  8002f7:	e8 54 01 00 00       	call   800450 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002fc:	83 c4 08             	add    $0x8,%esp
  8002ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800305:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030b:	50                   	push   %eax
  80030c:	e8 d4 08 00 00       	call   800be5 <sys_cputs>

	return b.cnt;
}
  800311:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 9d ff ff ff       	call   8002c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 1c             	sub    $0x1c,%esp
  800336:	89 c7                	mov    %eax,%edi
  800338:	89 d6                	mov    %edx,%esi
  80033a:	8b 45 08             	mov    0x8(%ebp),%eax
  80033d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800340:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800343:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800346:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800349:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800351:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800354:	39 d3                	cmp    %edx,%ebx
  800356:	72 05                	jb     80035d <printnum+0x30>
  800358:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035b:	77 45                	ja     8003a2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035d:	83 ec 0c             	sub    $0xc,%esp
  800360:	ff 75 18             	pushl  0x18(%ebp)
  800363:	8b 45 14             	mov    0x14(%ebp),%eax
  800366:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800369:	53                   	push   %ebx
  80036a:	ff 75 10             	pushl  0x10(%ebp)
  80036d:	83 ec 08             	sub    $0x8,%esp
  800370:	ff 75 e4             	pushl  -0x1c(%ebp)
  800373:	ff 75 e0             	pushl  -0x20(%ebp)
  800376:	ff 75 dc             	pushl  -0x24(%ebp)
  800379:	ff 75 d8             	pushl  -0x28(%ebp)
  80037c:	e8 7f 21 00 00       	call   802500 <__udivdi3>
  800381:	83 c4 18             	add    $0x18,%esp
  800384:	52                   	push   %edx
  800385:	50                   	push   %eax
  800386:	89 f2                	mov    %esi,%edx
  800388:	89 f8                	mov    %edi,%eax
  80038a:	e8 9e ff ff ff       	call   80032d <printnum>
  80038f:	83 c4 20             	add    $0x20,%esp
  800392:	eb 18                	jmp    8003ac <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800394:	83 ec 08             	sub    $0x8,%esp
  800397:	56                   	push   %esi
  800398:	ff 75 18             	pushl  0x18(%ebp)
  80039b:	ff d7                	call   *%edi
  80039d:	83 c4 10             	add    $0x10,%esp
  8003a0:	eb 03                	jmp    8003a5 <printnum+0x78>
  8003a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a5:	83 eb 01             	sub    $0x1,%ebx
  8003a8:	85 db                	test   %ebx,%ebx
  8003aa:	7f e8                	jg     800394 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	56                   	push   %esi
  8003b0:	83 ec 04             	sub    $0x4,%esp
  8003b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bf:	e8 6c 22 00 00       	call   802630 <__umoddi3>
  8003c4:	83 c4 14             	add    $0x14,%esp
  8003c7:	0f be 80 a7 28 80 00 	movsbl 0x8028a7(%eax),%eax
  8003ce:	50                   	push   %eax
  8003cf:	ff d7                	call   *%edi
}
  8003d1:	83 c4 10             	add    $0x10,%esp
  8003d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d7:	5b                   	pop    %ebx
  8003d8:	5e                   	pop    %esi
  8003d9:	5f                   	pop    %edi
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003df:	83 fa 01             	cmp    $0x1,%edx
  8003e2:	7e 0e                	jle    8003f2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e9:	89 08                	mov    %ecx,(%eax)
  8003eb:	8b 02                	mov    (%edx),%eax
  8003ed:	8b 52 04             	mov    0x4(%edx),%edx
  8003f0:	eb 22                	jmp    800414 <getuint+0x38>
	else if (lflag)
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	74 10                	je     800406 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f6:	8b 10                	mov    (%eax),%edx
  8003f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fb:	89 08                	mov    %ecx,(%eax)
  8003fd:	8b 02                	mov    (%edx),%eax
  8003ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800404:	eb 0e                	jmp    800414 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800406:	8b 10                	mov    (%eax),%edx
  800408:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040b:	89 08                	mov    %ecx,(%eax)
  80040d:	8b 02                	mov    (%edx),%eax
  80040f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800414:	5d                   	pop    %ebp
  800415:	c3                   	ret    

00800416 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80041c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800420:	8b 10                	mov    (%eax),%edx
  800422:	3b 50 04             	cmp    0x4(%eax),%edx
  800425:	73 0a                	jae    800431 <sprintputch+0x1b>
		*b->buf++ = ch;
  800427:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042a:	89 08                	mov    %ecx,(%eax)
  80042c:	8b 45 08             	mov    0x8(%ebp),%eax
  80042f:	88 02                	mov    %al,(%edx)
}
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800439:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80043c:	50                   	push   %eax
  80043d:	ff 75 10             	pushl  0x10(%ebp)
  800440:	ff 75 0c             	pushl  0xc(%ebp)
  800443:	ff 75 08             	pushl  0x8(%ebp)
  800446:	e8 05 00 00 00       	call   800450 <vprintfmt>
	va_end(ap);
}
  80044b:	83 c4 10             	add    $0x10,%esp
  80044e:	c9                   	leave  
  80044f:	c3                   	ret    

00800450 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	83 ec 2c             	sub    $0x2c,%esp
  800459:	8b 75 08             	mov    0x8(%ebp),%esi
  80045c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800462:	eb 12                	jmp    800476 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800464:	85 c0                	test   %eax,%eax
  800466:	0f 84 89 03 00 00    	je     8007f5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	50                   	push   %eax
  800471:	ff d6                	call   *%esi
  800473:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800476:	83 c7 01             	add    $0x1,%edi
  800479:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047d:	83 f8 25             	cmp    $0x25,%eax
  800480:	75 e2                	jne    800464 <vprintfmt+0x14>
  800482:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800486:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80048d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800494:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a0:	eb 07                	jmp    8004a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8d 47 01             	lea    0x1(%edi),%eax
  8004ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004af:	0f b6 07             	movzbl (%edi),%eax
  8004b2:	0f b6 c8             	movzbl %al,%ecx
  8004b5:	83 e8 23             	sub    $0x23,%eax
  8004b8:	3c 55                	cmp    $0x55,%al
  8004ba:	0f 87 1a 03 00 00    	ja     8007da <vprintfmt+0x38a>
  8004c0:	0f b6 c0             	movzbl %al,%eax
  8004c3:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d1:	eb d6                	jmp    8004a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004eb:	83 fa 09             	cmp    $0x9,%edx
  8004ee:	77 39                	ja     800529 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f3:	eb e9                	jmp    8004de <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800506:	eb 27                	jmp    80052f <vprintfmt+0xdf>
  800508:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800512:	0f 49 c8             	cmovns %eax,%ecx
  800515:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051b:	eb 8c                	jmp    8004a9 <vprintfmt+0x59>
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800520:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800527:	eb 80                	jmp    8004a9 <vprintfmt+0x59>
  800529:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800533:	0f 89 70 ff ff ff    	jns    8004a9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800539:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80053c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800546:	e9 5e ff ff ff       	jmp    8004a9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800551:	e9 53 ff ff ff       	jmp    8004a9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	53                   	push   %ebx
  800563:	ff 30                	pushl  (%eax)
  800565:	ff d6                	call   *%esi
			break;
  800567:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056d:	e9 04 ff ff ff       	jmp    800476 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	99                   	cltd   
  80057e:	31 d0                	xor    %edx,%eax
  800580:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800582:	83 f8 0f             	cmp    $0xf,%eax
  800585:	7f 0b                	jg     800592 <vprintfmt+0x142>
  800587:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  80058e:	85 d2                	test   %edx,%edx
  800590:	75 18                	jne    8005aa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800592:	50                   	push   %eax
  800593:	68 bf 28 80 00       	push   $0x8028bf
  800598:	53                   	push   %ebx
  800599:	56                   	push   %esi
  80059a:	e8 94 fe ff ff       	call   800433 <printfmt>
  80059f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a5:	e9 cc fe ff ff       	jmp    800476 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005aa:	52                   	push   %edx
  8005ab:	68 cd 2d 80 00       	push   $0x802dcd
  8005b0:	53                   	push   %ebx
  8005b1:	56                   	push   %esi
  8005b2:	e8 7c fe ff ff       	call   800433 <printfmt>
  8005b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bd:	e9 b4 fe ff ff       	jmp    800476 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	b8 b8 28 80 00       	mov    $0x8028b8,%eax
  8005d4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005db:	0f 8e 94 00 00 00    	jle    800675 <vprintfmt+0x225>
  8005e1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e5:	0f 84 98 00 00 00    	je     800683 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f1:	57                   	push   %edi
  8005f2:	e8 86 02 00 00       	call   80087d <strnlen>
  8005f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fa:	29 c1                	sub    %eax,%ecx
  8005fc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ff:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800602:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800606:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800609:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80060c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060e:	eb 0f                	jmp    80061f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	ff 75 e0             	pushl  -0x20(%ebp)
  800617:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	83 ef 01             	sub    $0x1,%edi
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	85 ff                	test   %edi,%edi
  800621:	7f ed                	jg     800610 <vprintfmt+0x1c0>
  800623:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800626:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800629:	85 c9                	test   %ecx,%ecx
  80062b:	b8 00 00 00 00       	mov    $0x0,%eax
  800630:	0f 49 c1             	cmovns %ecx,%eax
  800633:	29 c1                	sub    %eax,%ecx
  800635:	89 75 08             	mov    %esi,0x8(%ebp)
  800638:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063e:	89 cb                	mov    %ecx,%ebx
  800640:	eb 4d                	jmp    80068f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800642:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800646:	74 1b                	je     800663 <vprintfmt+0x213>
  800648:	0f be c0             	movsbl %al,%eax
  80064b:	83 e8 20             	sub    $0x20,%eax
  80064e:	83 f8 5e             	cmp    $0x5e,%eax
  800651:	76 10                	jbe    800663 <vprintfmt+0x213>
					putch('?', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	ff 75 0c             	pushl  0xc(%ebp)
  800659:	6a 3f                	push   $0x3f
  80065b:	ff 55 08             	call   *0x8(%ebp)
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	eb 0d                	jmp    800670 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	ff 75 0c             	pushl  0xc(%ebp)
  800669:	52                   	push   %edx
  80066a:	ff 55 08             	call   *0x8(%ebp)
  80066d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	83 eb 01             	sub    $0x1,%ebx
  800673:	eb 1a                	jmp    80068f <vprintfmt+0x23f>
  800675:	89 75 08             	mov    %esi,0x8(%ebp)
  800678:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800681:	eb 0c                	jmp    80068f <vprintfmt+0x23f>
  800683:	89 75 08             	mov    %esi,0x8(%ebp)
  800686:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800689:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068f:	83 c7 01             	add    $0x1,%edi
  800692:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800696:	0f be d0             	movsbl %al,%edx
  800699:	85 d2                	test   %edx,%edx
  80069b:	74 23                	je     8006c0 <vprintfmt+0x270>
  80069d:	85 f6                	test   %esi,%esi
  80069f:	78 a1                	js     800642 <vprintfmt+0x1f2>
  8006a1:	83 ee 01             	sub    $0x1,%esi
  8006a4:	79 9c                	jns    800642 <vprintfmt+0x1f2>
  8006a6:	89 df                	mov    %ebx,%edi
  8006a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ae:	eb 18                	jmp    8006c8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 20                	push   $0x20
  8006b6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b8:	83 ef 01             	sub    $0x1,%edi
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 08                	jmp    8006c8 <vprintfmt+0x278>
  8006c0:	89 df                	mov    %ebx,%edi
  8006c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c8:	85 ff                	test   %edi,%edi
  8006ca:	7f e4                	jg     8006b0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cf:	e9 a2 fd ff ff       	jmp    800476 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d4:	83 fa 01             	cmp    $0x1,%edx
  8006d7:	7e 16                	jle    8006ef <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 50 08             	lea    0x8(%eax),%edx
  8006df:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e2:	8b 50 04             	mov    0x4(%eax),%edx
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ed:	eb 32                	jmp    800721 <vprintfmt+0x2d1>
	else if (lflag)
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	74 18                	je     80070b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 50 04             	lea    0x4(%eax),%edx
  8006f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fc:	8b 00                	mov    (%eax),%eax
  8006fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800701:	89 c1                	mov    %eax,%ecx
  800703:	c1 f9 1f             	sar    $0x1f,%ecx
  800706:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800709:	eb 16                	jmp    800721 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8d 50 04             	lea    0x4(%eax),%edx
  800711:	89 55 14             	mov    %edx,0x14(%ebp)
  800714:	8b 00                	mov    (%eax),%eax
  800716:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800719:	89 c1                	mov    %eax,%ecx
  80071b:	c1 f9 1f             	sar    $0x1f,%ecx
  80071e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800721:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800724:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800727:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80072c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800730:	79 74                	jns    8007a6 <vprintfmt+0x356>
				putch('-', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 2d                	push   $0x2d
  800738:	ff d6                	call   *%esi
				num = -(long long) num;
  80073a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80073d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800740:	f7 d8                	neg    %eax
  800742:	83 d2 00             	adc    $0x0,%edx
  800745:	f7 da                	neg    %edx
  800747:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074f:	eb 55                	jmp    8007a6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 83 fc ff ff       	call   8003dc <getuint>
			base = 10;
  800759:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80075e:	eb 46                	jmp    8007a6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
  800763:	e8 74 fc ff ff       	call   8003dc <getuint>
		        base = 8;
  800768:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80076d:	eb 37                	jmp    8007a6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 30                	push   $0x30
  800775:	ff d6                	call   *%esi
			putch('x', putdat);
  800777:	83 c4 08             	add    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 78                	push   $0x78
  80077d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800792:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800797:	eb 0d                	jmp    8007a6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800799:	8d 45 14             	lea    0x14(%ebp),%eax
  80079c:	e8 3b fc ff ff       	call   8003dc <getuint>
			base = 16;
  8007a1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a6:	83 ec 0c             	sub    $0xc,%esp
  8007a9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ad:	57                   	push   %edi
  8007ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b1:	51                   	push   %ecx
  8007b2:	52                   	push   %edx
  8007b3:	50                   	push   %eax
  8007b4:	89 da                	mov    %ebx,%edx
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	e8 70 fb ff ff       	call   80032d <printnum>
			break;
  8007bd:	83 c4 20             	add    $0x20,%esp
  8007c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c3:	e9 ae fc ff ff       	jmp    800476 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	51                   	push   %ecx
  8007cd:	ff d6                	call   *%esi
			break;
  8007cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d5:	e9 9c fc ff ff       	jmp    800476 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	53                   	push   %ebx
  8007de:	6a 25                	push   $0x25
  8007e0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	eb 03                	jmp    8007ea <vprintfmt+0x39a>
  8007e7:	83 ef 01             	sub    $0x1,%edi
  8007ea:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ee:	75 f7                	jne    8007e7 <vprintfmt+0x397>
  8007f0:	e9 81 fc ff ff       	jmp    800476 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5f                   	pop    %edi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 18             	sub    $0x18,%esp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800809:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800810:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800813:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081a:	85 c0                	test   %eax,%eax
  80081c:	74 26                	je     800844 <vsnprintf+0x47>
  80081e:	85 d2                	test   %edx,%edx
  800820:	7e 22                	jle    800844 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800822:	ff 75 14             	pushl  0x14(%ebp)
  800825:	ff 75 10             	pushl  0x10(%ebp)
  800828:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082b:	50                   	push   %eax
  80082c:	68 16 04 80 00       	push   $0x800416
  800831:	e8 1a fc ff ff       	call   800450 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800836:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800839:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083f:	83 c4 10             	add    $0x10,%esp
  800842:	eb 05                	jmp    800849 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800844:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800851:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800854:	50                   	push   %eax
  800855:	ff 75 10             	pushl  0x10(%ebp)
  800858:	ff 75 0c             	pushl  0xc(%ebp)
  80085b:	ff 75 08             	pushl  0x8(%ebp)
  80085e:	e8 9a ff ff ff       	call   8007fd <vsnprintf>
	va_end(ap);

	return rc;
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
  800870:	eb 03                	jmp    800875 <strlen+0x10>
		n++;
  800872:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800875:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800879:	75 f7                	jne    800872 <strlen+0xd>
		n++;
	return n;
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800883:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	ba 00 00 00 00       	mov    $0x0,%edx
  80088b:	eb 03                	jmp    800890 <strnlen+0x13>
		n++;
  80088d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800890:	39 c2                	cmp    %eax,%edx
  800892:	74 08                	je     80089c <strnlen+0x1f>
  800894:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800898:	75 f3                	jne    80088d <strnlen+0x10>
  80089a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	53                   	push   %ebx
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	83 c2 01             	add    $0x1,%edx
  8008ad:	83 c1 01             	add    $0x1,%ecx
  8008b0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	75 ef                	jne    8008aa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	53                   	push   %ebx
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	53                   	push   %ebx
  8008c6:	e8 9a ff ff ff       	call   800865 <strlen>
  8008cb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	50                   	push   %eax
  8008d4:	e8 c5 ff ff ff       	call   80089e <strcpy>
	return dst;
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	89 f3                	mov    %esi,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f0:	89 f2                	mov    %esi,%edx
  8008f2:	eb 0f                	jmp    800903 <strncpy+0x23>
		*dst++ = *src;
  8008f4:	83 c2 01             	add    $0x1,%edx
  8008f7:	0f b6 01             	movzbl (%ecx),%eax
  8008fa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fd:	80 39 01             	cmpb   $0x1,(%ecx)
  800900:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800903:	39 da                	cmp    %ebx,%edx
  800905:	75 ed                	jne    8008f4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800907:	89 f0                	mov    %esi,%eax
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	56                   	push   %esi
  800911:	53                   	push   %ebx
  800912:	8b 75 08             	mov    0x8(%ebp),%esi
  800915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800918:	8b 55 10             	mov    0x10(%ebp),%edx
  80091b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091d:	85 d2                	test   %edx,%edx
  80091f:	74 21                	je     800942 <strlcpy+0x35>
  800921:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800925:	89 f2                	mov    %esi,%edx
  800927:	eb 09                	jmp    800932 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800929:	83 c2 01             	add    $0x1,%edx
  80092c:	83 c1 01             	add    $0x1,%ecx
  80092f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800932:	39 c2                	cmp    %eax,%edx
  800934:	74 09                	je     80093f <strlcpy+0x32>
  800936:	0f b6 19             	movzbl (%ecx),%ebx
  800939:	84 db                	test   %bl,%bl
  80093b:	75 ec                	jne    800929 <strlcpy+0x1c>
  80093d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80093f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800942:	29 f0                	sub    %esi,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800951:	eb 06                	jmp    800959 <strcmp+0x11>
		p++, q++;
  800953:	83 c1 01             	add    $0x1,%ecx
  800956:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	84 c0                	test   %al,%al
  80095e:	74 04                	je     800964 <strcmp+0x1c>
  800960:	3a 02                	cmp    (%edx),%al
  800962:	74 ef                	je     800953 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800964:	0f b6 c0             	movzbl %al,%eax
  800967:	0f b6 12             	movzbl (%edx),%edx
  80096a:	29 d0                	sub    %edx,%eax
}
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	53                   	push   %ebx
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
  800978:	89 c3                	mov    %eax,%ebx
  80097a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097d:	eb 06                	jmp    800985 <strncmp+0x17>
		n--, p++, q++;
  80097f:	83 c0 01             	add    $0x1,%eax
  800982:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800985:	39 d8                	cmp    %ebx,%eax
  800987:	74 15                	je     80099e <strncmp+0x30>
  800989:	0f b6 08             	movzbl (%eax),%ecx
  80098c:	84 c9                	test   %cl,%cl
  80098e:	74 04                	je     800994 <strncmp+0x26>
  800990:	3a 0a                	cmp    (%edx),%cl
  800992:	74 eb                	je     80097f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800994:	0f b6 00             	movzbl (%eax),%eax
  800997:	0f b6 12             	movzbl (%edx),%edx
  80099a:	29 d0                	sub    %edx,%eax
  80099c:	eb 05                	jmp    8009a3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b0:	eb 07                	jmp    8009b9 <strchr+0x13>
		if (*s == c)
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	74 0f                	je     8009c5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	0f b6 10             	movzbl (%eax),%edx
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	75 f2                	jne    8009b2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d1:	eb 03                	jmp    8009d6 <strfind+0xf>
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d9:	38 ca                	cmp    %cl,%dl
  8009db:	74 04                	je     8009e1 <strfind+0x1a>
  8009dd:	84 d2                	test   %dl,%dl
  8009df:	75 f2                	jne    8009d3 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ef:	85 c9                	test   %ecx,%ecx
  8009f1:	74 36                	je     800a29 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f9:	75 28                	jne    800a23 <memset+0x40>
  8009fb:	f6 c1 03             	test   $0x3,%cl
  8009fe:	75 23                	jne    800a23 <memset+0x40>
		c &= 0xFF;
  800a00:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a04:	89 d3                	mov    %edx,%ebx
  800a06:	c1 e3 08             	shl    $0x8,%ebx
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	c1 e6 18             	shl    $0x18,%esi
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	c1 e0 10             	shl    $0x10,%eax
  800a13:	09 f0                	or     %esi,%eax
  800a15:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a17:	89 d8                	mov    %ebx,%eax
  800a19:	09 d0                	or     %edx,%eax
  800a1b:	c1 e9 02             	shr    $0x2,%ecx
  800a1e:	fc                   	cld    
  800a1f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a21:	eb 06                	jmp    800a29 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	fc                   	cld    
  800a27:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a29:	89 f8                	mov    %edi,%eax
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3e:	39 c6                	cmp    %eax,%esi
  800a40:	73 35                	jae    800a77 <memmove+0x47>
  800a42:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a45:	39 d0                	cmp    %edx,%eax
  800a47:	73 2e                	jae    800a77 <memmove+0x47>
		s += n;
		d += n;
  800a49:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4c:	89 d6                	mov    %edx,%esi
  800a4e:	09 fe                	or     %edi,%esi
  800a50:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a56:	75 13                	jne    800a6b <memmove+0x3b>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0e                	jne    800a6b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a5d:	83 ef 04             	sub    $0x4,%edi
  800a60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a63:	c1 e9 02             	shr    $0x2,%ecx
  800a66:	fd                   	std    
  800a67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a69:	eb 09                	jmp    800a74 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6b:	83 ef 01             	sub    $0x1,%edi
  800a6e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a71:	fd                   	std    
  800a72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a74:	fc                   	cld    
  800a75:	eb 1d                	jmp    800a94 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a77:	89 f2                	mov    %esi,%edx
  800a79:	09 c2                	or     %eax,%edx
  800a7b:	f6 c2 03             	test   $0x3,%dl
  800a7e:	75 0f                	jne    800a8f <memmove+0x5f>
  800a80:	f6 c1 03             	test   $0x3,%cl
  800a83:	75 0a                	jne    800a8f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a85:	c1 e9 02             	shr    $0x2,%ecx
  800a88:	89 c7                	mov    %eax,%edi
  800a8a:	fc                   	cld    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 05                	jmp    800a94 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8f:	89 c7                	mov    %eax,%edi
  800a91:	fc                   	cld    
  800a92:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9b:	ff 75 10             	pushl  0x10(%ebp)
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	ff 75 08             	pushl  0x8(%ebp)
  800aa4:	e8 87 ff ff ff       	call   800a30 <memmove>
}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	89 c6                	mov    %eax,%esi
  800ab8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abb:	eb 1a                	jmp    800ad7 <memcmp+0x2c>
		if (*s1 != *s2)
  800abd:	0f b6 08             	movzbl (%eax),%ecx
  800ac0:	0f b6 1a             	movzbl (%edx),%ebx
  800ac3:	38 d9                	cmp    %bl,%cl
  800ac5:	74 0a                	je     800ad1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac7:	0f b6 c1             	movzbl %cl,%eax
  800aca:	0f b6 db             	movzbl %bl,%ebx
  800acd:	29 d8                	sub    %ebx,%eax
  800acf:	eb 0f                	jmp    800ae0 <memcmp+0x35>
		s1++, s2++;
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad7:	39 f0                	cmp    %esi,%eax
  800ad9:	75 e2                	jne    800abd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aeb:	89 c1                	mov    %eax,%ecx
  800aed:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af4:	eb 0a                	jmp    800b00 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	0f b6 10             	movzbl (%eax),%edx
  800af9:	39 da                	cmp    %ebx,%edx
  800afb:	74 07                	je     800b04 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	39 c8                	cmp    %ecx,%eax
  800b02:	72 f2                	jb     800af6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b04:	5b                   	pop    %ebx
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	eb 03                	jmp    800b18 <strtol+0x11>
		s++;
  800b15:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	3c 20                	cmp    $0x20,%al
  800b1d:	74 f6                	je     800b15 <strtol+0xe>
  800b1f:	3c 09                	cmp    $0x9,%al
  800b21:	74 f2                	je     800b15 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b23:	3c 2b                	cmp    $0x2b,%al
  800b25:	75 0a                	jne    800b31 <strtol+0x2a>
		s++;
  800b27:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2f:	eb 11                	jmp    800b42 <strtol+0x3b>
  800b31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b36:	3c 2d                	cmp    $0x2d,%al
  800b38:	75 08                	jne    800b42 <strtol+0x3b>
		s++, neg = 1;
  800b3a:	83 c1 01             	add    $0x1,%ecx
  800b3d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b48:	75 15                	jne    800b5f <strtol+0x58>
  800b4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4d:	75 10                	jne    800b5f <strtol+0x58>
  800b4f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b53:	75 7c                	jne    800bd1 <strtol+0xca>
		s += 2, base = 16;
  800b55:	83 c1 02             	add    $0x2,%ecx
  800b58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5d:	eb 16                	jmp    800b75 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5f:	85 db                	test   %ebx,%ebx
  800b61:	75 12                	jne    800b75 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b63:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b68:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6b:	75 08                	jne    800b75 <strtol+0x6e>
		s++, base = 8;
  800b6d:	83 c1 01             	add    $0x1,%ecx
  800b70:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b7d:	0f b6 11             	movzbl (%ecx),%edx
  800b80:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b83:	89 f3                	mov    %esi,%ebx
  800b85:	80 fb 09             	cmp    $0x9,%bl
  800b88:	77 08                	ja     800b92 <strtol+0x8b>
			dig = *s - '0';
  800b8a:	0f be d2             	movsbl %dl,%edx
  800b8d:	83 ea 30             	sub    $0x30,%edx
  800b90:	eb 22                	jmp    800bb4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 08                	ja     800ba4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 57             	sub    $0x57,%edx
  800ba2:	eb 10                	jmp    800bb4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 16                	ja     800bc4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb7:	7d 0b                	jge    800bc4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc2:	eb b9                	jmp    800b7d <strtol+0x76>

	if (endptr)
  800bc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc8:	74 0d                	je     800bd7 <strtol+0xd0>
		*endptr = (char *) s;
  800bca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcd:	89 0e                	mov    %ecx,(%esi)
  800bcf:	eb 06                	jmp    800bd7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd1:	85 db                	test   %ebx,%ebx
  800bd3:	74 98                	je     800b6d <strtol+0x66>
  800bd5:	eb 9e                	jmp    800b75 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd7:	89 c2                	mov    %eax,%edx
  800bd9:	f7 da                	neg    %edx
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	0f 45 c2             	cmovne %edx,%eax
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	89 c7                	mov    %eax,%edi
  800bfa:	89 c6                	mov    %eax,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c13:	89 d1                	mov    %edx,%ecx
  800c15:	89 d3                	mov    %edx,%ebx
  800c17:	89 d7                	mov    %edx,%edi
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c30:	b8 03 00 00 00       	mov    $0x3,%eax
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 cb                	mov    %ecx,%ebx
  800c3a:	89 cf                	mov    %ecx,%edi
  800c3c:	89 ce                	mov    %ecx,%esi
  800c3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 03                	push   $0x3
  800c4a:	68 9f 2b 80 00       	push   $0x802b9f
  800c4f:	6a 23                	push   $0x23
  800c51:	68 bc 2b 80 00       	push   $0x802bbc
  800c56:	e8 e5 f5 ff ff       	call   800240 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	89 d7                	mov    %edx,%edi
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_yield>:

void
sys_yield(void)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	89 d3                	mov    %edx,%ebx
  800c96:	89 d7                	mov    %edx,%edi
  800c98:	89 d6                	mov    %edx,%esi
  800c9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	be 00 00 00 00       	mov    $0x0,%esi
  800caf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbd:	89 f7                	mov    %esi,%edi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 04                	push   $0x4
  800ccb:	68 9f 2b 80 00       	push   $0x802b9f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 bc 2b 80 00       	push   $0x802bbc
  800cd7:	e8 64 f5 ff ff       	call   800240 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfe:	8b 75 18             	mov    0x18(%ebp),%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 05                	push   $0x5
  800d0d:	68 9f 2b 80 00       	push   $0x802b9f
  800d12:	6a 23                	push   $0x23
  800d14:	68 bc 2b 80 00       	push   $0x802bbc
  800d19:	e8 22 f5 ff ff       	call   800240 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 06 00 00 00       	mov    $0x6,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 06                	push   $0x6
  800d4f:	68 9f 2b 80 00       	push   $0x802b9f
  800d54:	6a 23                	push   $0x23
  800d56:	68 bc 2b 80 00       	push   $0x802bbc
  800d5b:	e8 e0 f4 ff ff       	call   800240 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 08                	push   $0x8
  800d91:	68 9f 2b 80 00       	push   $0x802b9f
  800d96:	6a 23                	push   $0x23
  800d98:	68 bc 2b 80 00       	push   $0x802bbc
  800d9d:	e8 9e f4 ff ff       	call   800240 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 17                	jle    800de4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	50                   	push   %eax
  800dd1:	6a 09                	push   $0x9
  800dd3:	68 9f 2b 80 00       	push   $0x802b9f
  800dd8:	6a 23                	push   $0x23
  800dda:	68 bc 2b 80 00       	push   $0x802bbc
  800ddf:	e8 5c f4 ff ff       	call   800240 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7e 17                	jle    800e26 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	50                   	push   %eax
  800e13:	6a 0a                	push   $0xa
  800e15:	68 9f 2b 80 00       	push   $0x802b9f
  800e1a:	6a 23                	push   $0x23
  800e1c:	68 bc 2b 80 00       	push   $0x802bbc
  800e21:	e8 1a f4 ff ff       	call   800240 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e34:	be 00 00 00 00       	mov    $0x0,%esi
  800e39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	89 cb                	mov    %ecx,%ebx
  800e69:	89 cf                	mov    %ecx,%edi
  800e6b:	89 ce                	mov    %ecx,%esi
  800e6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7e 17                	jle    800e8a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	50                   	push   %eax
  800e77:	6a 0d                	push   $0xd
  800e79:	68 9f 2b 80 00       	push   $0x802b9f
  800e7e:	6a 23                	push   $0x23
  800e80:	68 bc 2b 80 00       	push   $0x802bbc
  800e85:	e8 b6 f3 ff ff       	call   800240 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea2:	89 d1                	mov    %edx,%ecx
  800ea4:	89 d3                	mov    %edx,%ebx
  800ea6:	89 d7                	mov    %edx,%edi
  800ea8:	89 d6                	mov    %edx,%esi
  800eaa:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eac:	5b                   	pop    %ebx
  800ead:	5e                   	pop    %esi
  800eae:	5f                   	pop    %edi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800edc:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ede:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ee2:	74 2e                	je     800f12 <pgfault+0x40>
  800ee4:	89 c2                	mov    %eax,%edx
  800ee6:	c1 ea 16             	shr    $0x16,%edx
  800ee9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef0:	f6 c2 01             	test   $0x1,%dl
  800ef3:	74 1d                	je     800f12 <pgfault+0x40>
  800ef5:	89 c2                	mov    %eax,%edx
  800ef7:	c1 ea 0c             	shr    $0xc,%edx
  800efa:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f01:	f6 c1 01             	test   $0x1,%cl
  800f04:	74 0c                	je     800f12 <pgfault+0x40>
  800f06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0d:	f6 c6 08             	test   $0x8,%dh
  800f10:	75 14                	jne    800f26 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800f12:	83 ec 04             	sub    $0x4,%esp
  800f15:	68 ca 2b 80 00       	push   $0x802bca
  800f1a:	6a 1d                	push   $0x1d
  800f1c:	68 dd 2b 80 00       	push   $0x802bdd
  800f21:	e8 1a f3 ff ff       	call   800240 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2b:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	6a 07                	push   $0x7
  800f32:	68 00 f0 7f 00       	push   $0x7ff000
  800f37:	6a 00                	push   $0x0
  800f39:	e8 63 fd ff ff       	call   800ca1 <sys_page_alloc>
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 14                	jns    800f59 <pgfault+0x87>
		panic("page alloc failed \n");
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	68 e8 2b 80 00       	push   $0x802be8
  800f4d:	6a 28                	push   $0x28
  800f4f:	68 dd 2b 80 00       	push   $0x802bdd
  800f54:	e8 e7 f2 ff ff       	call   800240 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	68 00 10 00 00       	push   $0x1000
  800f61:	53                   	push   %ebx
  800f62:	68 00 f0 7f 00       	push   $0x7ff000
  800f67:	e8 2c fb ff ff       	call   800a98 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800f6c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f73:	53                   	push   %ebx
  800f74:	6a 00                	push   $0x0
  800f76:	68 00 f0 7f 00       	push   $0x7ff000
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 62 fd ff ff       	call   800ce4 <sys_page_map>
  800f82:	83 c4 20             	add    $0x20,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	79 14                	jns    800f9d <pgfault+0xcb>
        panic("page map failed \n");
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	68 fc 2b 80 00       	push   $0x802bfc
  800f91:	6a 2b                	push   $0x2b
  800f93:	68 dd 2b 80 00       	push   $0x802bdd
  800f98:	e8 a3 f2 ff ff       	call   800240 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	68 00 f0 7f 00       	push   $0x7ff000
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 7a fd ff ff       	call   800d26 <sys_page_unmap>
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 14                	jns    800fc7 <pgfault+0xf5>
        panic("page unmap failed\n");
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	68 0e 2c 80 00       	push   $0x802c0e
  800fbb:	6a 2d                	push   $0x2d
  800fbd:	68 dd 2b 80 00       	push   $0x802bdd
  800fc2:	e8 79 f2 ff ff       	call   800240 <_panic>
	
	//panic("pgfault not implemented");
}
  800fc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800fd5:	68 d2 0e 80 00       	push   $0x800ed2
  800fda:	e8 57 13 00 00       	call   802336 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fdf:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe4:	cd 30                	int    $0x30
  800fe6:	89 c7                	mov    %eax,%edi
  800fe8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 12                	jns    801004 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800ff2:	50                   	push   %eax
  800ff3:	68 21 2c 80 00       	push   $0x802c21
  800ff8:	6a 7a                	push   $0x7a
  800ffa:	68 dd 2b 80 00       	push   $0x802bdd
  800fff:	e8 3c f2 ff ff       	call   800240 <_panic>
  801004:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  801009:	85 c0                	test   %eax,%eax
  80100b:	75 21                	jne    80102e <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  80100d:	e8 51 fc ff ff       	call   800c63 <sys_getenvid>
  801012:	25 ff 03 00 00       	and    $0x3ff,%eax
  801017:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80101a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80101f:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801024:	b8 00 00 00 00       	mov    $0x0,%eax
  801029:	e9 91 01 00 00       	jmp    8011bf <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	c1 e8 16             	shr    $0x16,%eax
  801033:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103a:	a8 01                	test   $0x1,%al
  80103c:	0f 84 06 01 00 00    	je     801148 <fork+0x17c>
  801042:	89 d8                	mov    %ebx,%eax
  801044:	c1 e8 0c             	shr    $0xc,%eax
  801047:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104e:	f6 c2 01             	test   $0x1,%dl
  801051:	0f 84 f1 00 00 00    	je     801148 <fork+0x17c>
  801057:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105e:	f6 c2 04             	test   $0x4,%dl
  801061:	0f 84 e1 00 00 00    	je     801148 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801067:	89 c6                	mov    %eax,%esi
  801069:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  80106c:	89 f2                	mov    %esi,%edx
  80106e:	c1 ea 16             	shr    $0x16,%edx
  801071:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  801078:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  80107f:	f6 c6 04             	test   $0x4,%dh
  801082:	74 39                	je     8010bd <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801084:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	25 07 0e 00 00       	and    $0xe07,%eax
  801093:	50                   	push   %eax
  801094:	56                   	push   %esi
  801095:	ff 75 e4             	pushl  -0x1c(%ebp)
  801098:	56                   	push   %esi
  801099:	6a 00                	push   $0x0
  80109b:	e8 44 fc ff ff       	call   800ce4 <sys_page_map>
  8010a0:	83 c4 20             	add    $0x20,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	0f 89 9d 00 00 00    	jns    801148 <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  8010ab:	50                   	push   %eax
  8010ac:	68 78 2c 80 00       	push   $0x802c78
  8010b1:	6a 4b                	push   $0x4b
  8010b3:	68 dd 2b 80 00       	push   $0x802bdd
  8010b8:	e8 83 f1 ff ff       	call   800240 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  8010bd:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8010c3:	74 59                	je     80111e <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	68 05 08 00 00       	push   $0x805
  8010cd:	56                   	push   %esi
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	56                   	push   %esi
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 0b fc ff ff       	call   800ce4 <sys_page_map>
  8010d9:	83 c4 20             	add    $0x20,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 12                	jns    8010f2 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  8010e0:	50                   	push   %eax
  8010e1:	68 a8 2c 80 00       	push   $0x802ca8
  8010e6:	6a 50                	push   $0x50
  8010e8:	68 dd 2b 80 00       	push   $0x802bdd
  8010ed:	e8 4e f1 ff ff       	call   800240 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	68 05 08 00 00       	push   $0x805
  8010fa:	56                   	push   %esi
  8010fb:	6a 00                	push   $0x0
  8010fd:	56                   	push   %esi
  8010fe:	6a 00                	push   $0x0
  801100:	e8 df fb ff ff       	call   800ce4 <sys_page_map>
  801105:	83 c4 20             	add    $0x20,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	79 3c                	jns    801148 <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  80110c:	50                   	push   %eax
  80110d:	68 d0 2c 80 00       	push   $0x802cd0
  801112:	6a 53                	push   $0x53
  801114:	68 dd 2b 80 00       	push   $0x802bdd
  801119:	e8 22 f1 ff ff       	call   800240 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	6a 05                	push   $0x5
  801123:	56                   	push   %esi
  801124:	ff 75 e4             	pushl  -0x1c(%ebp)
  801127:	56                   	push   %esi
  801128:	6a 00                	push   $0x0
  80112a:	e8 b5 fb ff ff       	call   800ce4 <sys_page_map>
  80112f:	83 c4 20             	add    $0x20,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	79 12                	jns    801148 <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801136:	50                   	push   %eax
  801137:	68 f8 2c 80 00       	push   $0x802cf8
  80113c:	6a 58                	push   $0x58
  80113e:	68 dd 2b 80 00       	push   $0x802bdd
  801143:	e8 f8 f0 ff ff       	call   800240 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  801148:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80114e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801154:	0f 85 d4 fe ff ff    	jne    80102e <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	6a 07                	push   $0x7
  80115f:	68 00 f0 bf ee       	push   $0xeebff000
  801164:	57                   	push   %edi
  801165:	e8 37 fb ff ff       	call   800ca1 <sys_page_alloc>
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	79 17                	jns    801188 <fork+0x1bc>
        panic("page alloc failed\n");
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	68 33 2c 80 00       	push   $0x802c33
  801179:	68 87 00 00 00       	push   $0x87
  80117e:	68 dd 2b 80 00       	push   $0x802bdd
  801183:	e8 b8 f0 ff ff       	call   800240 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	68 a5 23 80 00       	push   $0x8023a5
  801190:	57                   	push   %edi
  801191:	e8 56 fc ff ff       	call   800dec <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801196:	83 c4 08             	add    $0x8,%esp
  801199:	6a 02                	push   $0x2
  80119b:	57                   	push   %edi
  80119c:	e8 c7 fb ff ff       	call   800d68 <sys_env_set_status>
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	79 15                	jns    8011bd <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  8011a8:	50                   	push   %eax
  8011a9:	68 46 2c 80 00       	push   $0x802c46
  8011ae:	68 8c 00 00 00       	push   $0x8c
  8011b3:	68 dd 2b 80 00       	push   $0x802bdd
  8011b8:	e8 83 f0 ff ff       	call   800240 <_panic>

	return envid;
  8011bd:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011cd:	68 5f 2c 80 00       	push   $0x802c5f
  8011d2:	68 98 00 00 00       	push   $0x98
  8011d7:	68 dd 2b 80 00       	push   $0x802bdd
  8011dc:	e8 5f f0 ff ff       	call   800240 <_panic>

008011e1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ec:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801201:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801213:	89 c2                	mov    %eax,%edx
  801215:	c1 ea 16             	shr    $0x16,%edx
  801218:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121f:	f6 c2 01             	test   $0x1,%dl
  801222:	74 11                	je     801235 <fd_alloc+0x2d>
  801224:	89 c2                	mov    %eax,%edx
  801226:	c1 ea 0c             	shr    $0xc,%edx
  801229:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801230:	f6 c2 01             	test   $0x1,%dl
  801233:	75 09                	jne    80123e <fd_alloc+0x36>
			*fd_store = fd;
  801235:	89 01                	mov    %eax,(%ecx)
			return 0;
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
  80123c:	eb 17                	jmp    801255 <fd_alloc+0x4d>
  80123e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801243:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801248:	75 c9                	jne    801213 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80124a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801250:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80125d:	83 f8 1f             	cmp    $0x1f,%eax
  801260:	77 36                	ja     801298 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801262:	c1 e0 0c             	shl    $0xc,%eax
  801265:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	c1 ea 16             	shr    $0x16,%edx
  80126f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801276:	f6 c2 01             	test   $0x1,%dl
  801279:	74 24                	je     80129f <fd_lookup+0x48>
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	c1 ea 0c             	shr    $0xc,%edx
  801280:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801287:	f6 c2 01             	test   $0x1,%dl
  80128a:	74 1a                	je     8012a6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80128c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128f:	89 02                	mov    %eax,(%edx)
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 13                	jmp    8012ab <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb 0c                	jmp    8012ab <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a4:	eb 05                	jmp    8012ab <fd_lookup+0x54>
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b6:	ba a0 2d 80 00       	mov    $0x802da0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012bb:	eb 13                	jmp    8012d0 <dev_lookup+0x23>
  8012bd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012c0:	39 08                	cmp    %ecx,(%eax)
  8012c2:	75 0c                	jne    8012d0 <dev_lookup+0x23>
			*dev = devtab[i];
  8012c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ce:	eb 2e                	jmp    8012fe <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d0:	8b 02                	mov    (%edx),%eax
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	75 e7                	jne    8012bd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8012db:	8b 40 48             	mov    0x48(%eax),%eax
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	51                   	push   %ecx
  8012e2:	50                   	push   %eax
  8012e3:	68 24 2d 80 00       	push   $0x802d24
  8012e8:	e8 2c f0 ff ff       	call   800319 <cprintf>
	*dev = 0;
  8012ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	56                   	push   %esi
  801304:	53                   	push   %ebx
  801305:	83 ec 10             	sub    $0x10,%esp
  801308:	8b 75 08             	mov    0x8(%ebp),%esi
  80130b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
  80131b:	50                   	push   %eax
  80131c:	e8 36 ff ff ff       	call   801257 <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 05                	js     80132d <fd_close+0x2d>
	    || fd != fd2)
  801328:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80132b:	74 0c                	je     801339 <fd_close+0x39>
		return (must_exist ? r : 0);
  80132d:	84 db                	test   %bl,%bl
  80132f:	ba 00 00 00 00       	mov    $0x0,%edx
  801334:	0f 44 c2             	cmove  %edx,%eax
  801337:	eb 41                	jmp    80137a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 36                	pushl  (%esi)
  801342:	e8 66 ff ff ff       	call   8012ad <dev_lookup>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 1a                	js     80136a <fd_close+0x6a>
		if (dev->dev_close)
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801356:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80135b:	85 c0                	test   %eax,%eax
  80135d:	74 0b                	je     80136a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	56                   	push   %esi
  801363:	ff d0                	call   *%eax
  801365:	89 c3                	mov    %eax,%ebx
  801367:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	56                   	push   %esi
  80136e:	6a 00                	push   $0x0
  801370:	e8 b1 f9 ff ff       	call   800d26 <sys_page_unmap>
	return r;
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	89 d8                	mov    %ebx,%eax
}
  80137a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801387:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	ff 75 08             	pushl  0x8(%ebp)
  80138e:	e8 c4 fe ff ff       	call   801257 <fd_lookup>
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 10                	js     8013aa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	6a 01                	push   $0x1
  80139f:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a2:	e8 59 ff ff ff       	call   801300 <fd_close>
  8013a7:	83 c4 10             	add    $0x10,%esp
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <close_all>:

void
close_all(void)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	e8 c0 ff ff ff       	call   801381 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c1:	83 c3 01             	add    $0x1,%ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	83 fb 20             	cmp    $0x20,%ebx
  8013ca:	75 ec                	jne    8013b8 <close_all+0xc>
		close(i);
}
  8013cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	57                   	push   %edi
  8013d5:	56                   	push   %esi
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 2c             	sub    $0x2c,%esp
  8013da:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 6e fe ff ff       	call   801257 <fd_lookup>
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	0f 88 c1 00 00 00    	js     8014b5 <dup+0xe4>
		return r;
	close(newfdnum);
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	56                   	push   %esi
  8013f8:	e8 84 ff ff ff       	call   801381 <close>

	newfd = INDEX2FD(newfdnum);
  8013fd:	89 f3                	mov    %esi,%ebx
  8013ff:	c1 e3 0c             	shl    $0xc,%ebx
  801402:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801408:	83 c4 04             	add    $0x4,%esp
  80140b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140e:	e8 de fd ff ff       	call   8011f1 <fd2data>
  801413:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801415:	89 1c 24             	mov    %ebx,(%esp)
  801418:	e8 d4 fd ff ff       	call   8011f1 <fd2data>
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801423:	89 f8                	mov    %edi,%eax
  801425:	c1 e8 16             	shr    $0x16,%eax
  801428:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142f:	a8 01                	test   $0x1,%al
  801431:	74 37                	je     80146a <dup+0x99>
  801433:	89 f8                	mov    %edi,%eax
  801435:	c1 e8 0c             	shr    $0xc,%eax
  801438:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	74 26                	je     80146a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801444:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	25 07 0e 00 00       	and    $0xe07,%eax
  801453:	50                   	push   %eax
  801454:	ff 75 d4             	pushl  -0x2c(%ebp)
  801457:	6a 00                	push   $0x0
  801459:	57                   	push   %edi
  80145a:	6a 00                	push   $0x0
  80145c:	e8 83 f8 ff ff       	call   800ce4 <sys_page_map>
  801461:	89 c7                	mov    %eax,%edi
  801463:	83 c4 20             	add    $0x20,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 2e                	js     801498 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80146d:	89 d0                	mov    %edx,%eax
  80146f:	c1 e8 0c             	shr    $0xc,%eax
  801472:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	25 07 0e 00 00       	and    $0xe07,%eax
  801481:	50                   	push   %eax
  801482:	53                   	push   %ebx
  801483:	6a 00                	push   $0x0
  801485:	52                   	push   %edx
  801486:	6a 00                	push   $0x0
  801488:	e8 57 f8 ff ff       	call   800ce4 <sys_page_map>
  80148d:	89 c7                	mov    %eax,%edi
  80148f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801492:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801494:	85 ff                	test   %edi,%edi
  801496:	79 1d                	jns    8014b5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 83 f8 ff ff       	call   800d26 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 76 f8 ff ff       	call   800d26 <sys_page_unmap>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	89 f8                	mov    %edi,%eax
}
  8014b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5f                   	pop    %edi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 14             	sub    $0x14,%esp
  8014c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	53                   	push   %ebx
  8014cc:	e8 86 fd ff ff       	call   801257 <fd_lookup>
  8014d1:	83 c4 08             	add    $0x8,%esp
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 6d                	js     801547 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e4:	ff 30                	pushl  (%eax)
  8014e6:	e8 c2 fd ff ff       	call   8012ad <dev_lookup>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 4c                	js     80153e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f5:	8b 42 08             	mov    0x8(%edx),%eax
  8014f8:	83 e0 03             	and    $0x3,%eax
  8014fb:	83 f8 01             	cmp    $0x1,%eax
  8014fe:	75 21                	jne    801521 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801500:	a1 08 40 80 00       	mov    0x804008,%eax
  801505:	8b 40 48             	mov    0x48(%eax),%eax
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	53                   	push   %ebx
  80150c:	50                   	push   %eax
  80150d:	68 65 2d 80 00       	push   $0x802d65
  801512:	e8 02 ee ff ff       	call   800319 <cprintf>
		return -E_INVAL;
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151f:	eb 26                	jmp    801547 <read+0x8a>
	}
	if (!dev->dev_read)
  801521:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801524:	8b 40 08             	mov    0x8(%eax),%eax
  801527:	85 c0                	test   %eax,%eax
  801529:	74 17                	je     801542 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	ff 75 10             	pushl  0x10(%ebp)
  801531:	ff 75 0c             	pushl  0xc(%ebp)
  801534:	52                   	push   %edx
  801535:	ff d0                	call   *%eax
  801537:	89 c2                	mov    %eax,%edx
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	eb 09                	jmp    801547 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153e:	89 c2                	mov    %eax,%edx
  801540:	eb 05                	jmp    801547 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801542:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801547:	89 d0                	mov    %edx,%eax
  801549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801562:	eb 21                	jmp    801585 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	89 f0                	mov    %esi,%eax
  801569:	29 d8                	sub    %ebx,%eax
  80156b:	50                   	push   %eax
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	03 45 0c             	add    0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	57                   	push   %edi
  801573:	e8 45 ff ff ff       	call   8014bd <read>
		if (m < 0)
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 10                	js     80158f <readn+0x41>
			return m;
		if (m == 0)
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 0a                	je     80158d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801583:	01 c3                	add    %eax,%ebx
  801585:	39 f3                	cmp    %esi,%ebx
  801587:	72 db                	jb     801564 <readn+0x16>
  801589:	89 d8                	mov    %ebx,%eax
  80158b:	eb 02                	jmp    80158f <readn+0x41>
  80158d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 14             	sub    $0x14,%esp
  80159e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	53                   	push   %ebx
  8015a6:	e8 ac fc ff ff       	call   801257 <fd_lookup>
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 68                	js     80161c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	ff 30                	pushl  (%eax)
  8015c0:	e8 e8 fc ff ff       	call   8012ad <dev_lookup>
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 47                	js     801613 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d3:	75 21                	jne    8015f6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d5:	a1 08 40 80 00       	mov    0x804008,%eax
  8015da:	8b 40 48             	mov    0x48(%eax),%eax
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	50                   	push   %eax
  8015e2:	68 81 2d 80 00       	push   $0x802d81
  8015e7:	e8 2d ed ff ff       	call   800319 <cprintf>
		return -E_INVAL;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f4:	eb 26                	jmp    80161c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015fc:	85 d2                	test   %edx,%edx
  8015fe:	74 17                	je     801617 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	ff 75 10             	pushl  0x10(%ebp)
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	50                   	push   %eax
  80160a:	ff d2                	call   *%edx
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb 09                	jmp    80161c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	89 c2                	mov    %eax,%edx
  801615:	eb 05                	jmp    80161c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801617:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <seek>:

int
seek(int fdnum, off_t offset)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801629:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 22 fc ff ff       	call   801257 <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 0e                	js     80164a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80163c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801642:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801645:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	53                   	push   %ebx
  801650:	83 ec 14             	sub    $0x14,%esp
  801653:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801656:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801659:	50                   	push   %eax
  80165a:	53                   	push   %ebx
  80165b:	e8 f7 fb ff ff       	call   801257 <fd_lookup>
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	89 c2                	mov    %eax,%edx
  801665:	85 c0                	test   %eax,%eax
  801667:	78 65                	js     8016ce <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801673:	ff 30                	pushl  (%eax)
  801675:	e8 33 fc ff ff       	call   8012ad <dev_lookup>
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 44                	js     8016c5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801688:	75 21                	jne    8016ab <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80168a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168f:	8b 40 48             	mov    0x48(%eax),%eax
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	53                   	push   %ebx
  801696:	50                   	push   %eax
  801697:	68 44 2d 80 00       	push   $0x802d44
  80169c:	e8 78 ec ff ff       	call   800319 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a9:	eb 23                	jmp    8016ce <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ae:	8b 52 18             	mov    0x18(%edx),%edx
  8016b1:	85 d2                	test   %edx,%edx
  8016b3:	74 14                	je     8016c9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	50                   	push   %eax
  8016bc:	ff d2                	call   *%edx
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	eb 09                	jmp    8016ce <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	eb 05                	jmp    8016ce <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ce:	89 d0                	mov    %edx,%eax
  8016d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 14             	sub    $0x14,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 6c fb ff ff       	call   801257 <fd_lookup>
  8016eb:	83 c4 08             	add    $0x8,%esp
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 58                	js     80174c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fe:	ff 30                	pushl  (%eax)
  801700:	e8 a8 fb ff ff       	call   8012ad <dev_lookup>
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 37                	js     801743 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80170c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801713:	74 32                	je     801747 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801715:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801718:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171f:	00 00 00 
	stat->st_isdir = 0;
  801722:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801729:	00 00 00 
	stat->st_dev = dev;
  80172c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	53                   	push   %ebx
  801736:	ff 75 f0             	pushl  -0x10(%ebp)
  801739:	ff 50 14             	call   *0x14(%eax)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	eb 09                	jmp    80174c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801743:	89 c2                	mov    %eax,%edx
  801745:	eb 05                	jmp    80174c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801747:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80174c:	89 d0                	mov    %edx,%eax
  80174e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	6a 00                	push   $0x0
  80175d:	ff 75 08             	pushl  0x8(%ebp)
  801760:	e8 e7 01 00 00       	call   80194c <open>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 1b                	js     801789 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	ff 75 0c             	pushl  0xc(%ebp)
  801774:	50                   	push   %eax
  801775:	e8 5b ff ff ff       	call   8016d5 <fstat>
  80177a:	89 c6                	mov    %eax,%esi
	close(fd);
  80177c:	89 1c 24             	mov    %ebx,(%esp)
  80177f:	e8 fd fb ff ff       	call   801381 <close>
	return r;
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	89 f0                	mov    %esi,%eax
}
  801789:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	89 c6                	mov    %eax,%esi
  801797:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801799:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a0:	75 12                	jne    8017b4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	6a 01                	push   $0x1
  8017a7:	e8 de 0c 00 00       	call   80248a <ipc_find_env>
  8017ac:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b4:	6a 07                	push   $0x7
  8017b6:	68 00 50 80 00       	push   $0x805000
  8017bb:	56                   	push   %esi
  8017bc:	ff 35 00 40 80 00    	pushl  0x804000
  8017c2:	e8 6f 0c 00 00       	call   802436 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c7:	83 c4 0c             	add    $0xc,%esp
  8017ca:	6a 00                	push   $0x0
  8017cc:	53                   	push   %ebx
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 f5 0b 00 00       	call   8023c9 <ipc_recv>
}
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ef:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fe:	e8 8d ff ff ff       	call   801790 <fsipc>
}
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 40 0c             	mov    0xc(%eax),%eax
  801811:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 06 00 00 00       	mov    $0x6,%eax
  801820:	e8 6b ff ff ff       	call   801790 <fsipc>
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	8b 40 0c             	mov    0xc(%eax),%eax
  801837:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 05 00 00 00       	mov    $0x5,%eax
  801846:	e8 45 ff ff ff       	call   801790 <fsipc>
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 2c                	js     80187b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	68 00 50 80 00       	push   $0x805000
  801857:	53                   	push   %ebx
  801858:	e8 41 f0 ff ff       	call   80089e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185d:	a1 80 50 80 00       	mov    0x805080,%eax
  801862:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801868:	a1 84 50 80 00       	mov    0x805084,%eax
  80186d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80188a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80188f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801894:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801897:	53                   	push   %ebx
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	68 08 50 80 00       	push   $0x805008
  8018a0:	e8 8b f1 ff ff       	call   800a30 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8018b0:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c0:	e8 cb fe ff ff       	call   801790 <fsipc>
	//panic("devfile_write not implemented");
}
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
  8018cf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018dd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ed:	e8 9e fe ff ff       	call   801790 <fsipc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 4b                	js     801943 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f8:	39 c6                	cmp    %eax,%esi
  8018fa:	73 16                	jae    801912 <devfile_read+0x48>
  8018fc:	68 b4 2d 80 00       	push   $0x802db4
  801901:	68 bb 2d 80 00       	push   $0x802dbb
  801906:	6a 7c                	push   $0x7c
  801908:	68 d0 2d 80 00       	push   $0x802dd0
  80190d:	e8 2e e9 ff ff       	call   800240 <_panic>
	assert(r <= PGSIZE);
  801912:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801917:	7e 16                	jle    80192f <devfile_read+0x65>
  801919:	68 db 2d 80 00       	push   $0x802ddb
  80191e:	68 bb 2d 80 00       	push   $0x802dbb
  801923:	6a 7d                	push   $0x7d
  801925:	68 d0 2d 80 00       	push   $0x802dd0
  80192a:	e8 11 e9 ff ff       	call   800240 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80192f:	83 ec 04             	sub    $0x4,%esp
  801932:	50                   	push   %eax
  801933:	68 00 50 80 00       	push   $0x805000
  801938:	ff 75 0c             	pushl  0xc(%ebp)
  80193b:	e8 f0 f0 ff ff       	call   800a30 <memmove>
	return r;
  801940:	83 c4 10             	add    $0x10,%esp
}
  801943:	89 d8                	mov    %ebx,%eax
  801945:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 20             	sub    $0x20,%esp
  801953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801956:	53                   	push   %ebx
  801957:	e8 09 ef ff ff       	call   800865 <strlen>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801964:	7f 67                	jg     8019cd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801966:	83 ec 0c             	sub    $0xc,%esp
  801969:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196c:	50                   	push   %eax
  80196d:	e8 96 f8 ff ff       	call   801208 <fd_alloc>
  801972:	83 c4 10             	add    $0x10,%esp
		return r;
  801975:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801977:	85 c0                	test   %eax,%eax
  801979:	78 57                	js     8019d2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	68 00 50 80 00       	push   $0x805000
  801984:	e8 15 ef ff ff       	call   80089e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801991:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801994:	b8 01 00 00 00       	mov    $0x1,%eax
  801999:	e8 f2 fd ff ff       	call   801790 <fsipc>
  80199e:	89 c3                	mov    %eax,%ebx
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	79 14                	jns    8019bb <open+0x6f>
		fd_close(fd, 0);
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	6a 00                	push   $0x0
  8019ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8019af:	e8 4c f9 ff ff       	call   801300 <fd_close>
		return r;
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	89 da                	mov    %ebx,%edx
  8019b9:	eb 17                	jmp    8019d2 <open+0x86>
	}

	return fd2num(fd);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c1:	e8 1b f8 ff ff       	call   8011e1 <fd2num>
  8019c6:	89 c2                	mov    %eax,%edx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	eb 05                	jmp    8019d2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019cd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019d2:	89 d0                	mov    %edx,%eax
  8019d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019df:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e9:	e8 a2 fd ff ff       	call   801790 <fsipc>
}
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019f6:	68 e7 2d 80 00       	push   $0x802de7
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	e8 9b ee ff ff       	call   80089e <strcpy>
	return 0;
}
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 10             	sub    $0x10,%esp
  801a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a14:	53                   	push   %ebx
  801a15:	e8 a9 0a 00 00       	call   8024c3 <pageref>
  801a1a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a22:	83 f8 01             	cmp    $0x1,%eax
  801a25:	75 10                	jne    801a37 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	ff 73 0c             	pushl  0xc(%ebx)
  801a2d:	e8 c0 02 00 00       	call   801cf2 <nsipc_close>
  801a32:	89 c2                	mov    %eax,%edx
  801a34:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a37:	89 d0                	mov    %edx,%eax
  801a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a44:	6a 00                	push   $0x0
  801a46:	ff 75 10             	pushl  0x10(%ebp)
  801a49:	ff 75 0c             	pushl  0xc(%ebp)
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	ff 70 0c             	pushl  0xc(%eax)
  801a52:	e8 78 03 00 00       	call   801dcf <nsipc_send>
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a5f:	6a 00                	push   $0x0
  801a61:	ff 75 10             	pushl  0x10(%ebp)
  801a64:	ff 75 0c             	pushl  0xc(%ebp)
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	ff 70 0c             	pushl  0xc(%eax)
  801a6d:	e8 f1 02 00 00       	call   801d63 <nsipc_recv>
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a7a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a7d:	52                   	push   %edx
  801a7e:	50                   	push   %eax
  801a7f:	e8 d3 f7 ff ff       	call   801257 <fd_lookup>
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 17                	js     801aa2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a94:	39 08                	cmp    %ecx,(%eax)
  801a96:	75 05                	jne    801a9d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a98:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9b:	eb 05                	jmp    801aa2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a9d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 1c             	sub    $0x1c,%esp
  801aac:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab1:	50                   	push   %eax
  801ab2:	e8 51 f7 ff ff       	call   801208 <fd_alloc>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 1b                	js     801adb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ac0:	83 ec 04             	sub    $0x4,%esp
  801ac3:	68 07 04 00 00       	push   $0x407
  801ac8:	ff 75 f4             	pushl  -0xc(%ebp)
  801acb:	6a 00                	push   $0x0
  801acd:	e8 cf f1 ff ff       	call   800ca1 <sys_page_alloc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 10                	jns    801aeb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	56                   	push   %esi
  801adf:	e8 0e 02 00 00       	call   801cf2 <nsipc_close>
		return r;
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	89 d8                	mov    %ebx,%eax
  801ae9:	eb 24                	jmp    801b0f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801aeb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b00:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	50                   	push   %eax
  801b07:	e8 d5 f6 ff ff       	call   8011e1 <fd2num>
  801b0c:	83 c4 10             	add    $0x10,%esp
}
  801b0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	e8 50 ff ff ff       	call   801a74 <fd2sockid>
		return r;
  801b24:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 1f                	js     801b49 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b2a:	83 ec 04             	sub    $0x4,%esp
  801b2d:	ff 75 10             	pushl  0x10(%ebp)
  801b30:	ff 75 0c             	pushl  0xc(%ebp)
  801b33:	50                   	push   %eax
  801b34:	e8 12 01 00 00       	call   801c4b <nsipc_accept>
  801b39:	83 c4 10             	add    $0x10,%esp
		return r;
  801b3c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 07                	js     801b49 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b42:	e8 5d ff ff ff       	call   801aa4 <alloc_sockfd>
  801b47:	89 c1                	mov    %eax,%ecx
}
  801b49:	89 c8                	mov    %ecx,%eax
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
  801b56:	e8 19 ff ff ff       	call   801a74 <fd2sockid>
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	78 12                	js     801b71 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b5f:	83 ec 04             	sub    $0x4,%esp
  801b62:	ff 75 10             	pushl  0x10(%ebp)
  801b65:	ff 75 0c             	pushl  0xc(%ebp)
  801b68:	50                   	push   %eax
  801b69:	e8 2d 01 00 00       	call   801c9b <nsipc_bind>
  801b6e:	83 c4 10             	add    $0x10,%esp
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <shutdown>:

int
shutdown(int s, int how)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	e8 f3 fe ff ff       	call   801a74 <fd2sockid>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 0f                	js     801b94 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b85:	83 ec 08             	sub    $0x8,%esp
  801b88:	ff 75 0c             	pushl  0xc(%ebp)
  801b8b:	50                   	push   %eax
  801b8c:	e8 3f 01 00 00       	call   801cd0 <nsipc_shutdown>
  801b91:	83 c4 10             	add    $0x10,%esp
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	e8 d0 fe ff ff       	call   801a74 <fd2sockid>
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 12                	js     801bba <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ba8:	83 ec 04             	sub    $0x4,%esp
  801bab:	ff 75 10             	pushl  0x10(%ebp)
  801bae:	ff 75 0c             	pushl  0xc(%ebp)
  801bb1:	50                   	push   %eax
  801bb2:	e8 55 01 00 00       	call   801d0c <nsipc_connect>
  801bb7:	83 c4 10             	add    $0x10,%esp
}
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <listen>:

int
listen(int s, int backlog)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	e8 aa fe ff ff       	call   801a74 <fd2sockid>
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 0f                	js     801bdd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	50                   	push   %eax
  801bd5:	e8 67 01 00 00       	call   801d41 <nsipc_listen>
  801bda:	83 c4 10             	add    $0x10,%esp
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801be5:	ff 75 10             	pushl  0x10(%ebp)
  801be8:	ff 75 0c             	pushl  0xc(%ebp)
  801beb:	ff 75 08             	pushl  0x8(%ebp)
  801bee:	e8 3a 02 00 00       	call   801e2d <nsipc_socket>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 05                	js     801bff <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bfa:	e8 a5 fe ff ff       	call   801aa4 <alloc_sockfd>
}
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	53                   	push   %ebx
  801c05:	83 ec 04             	sub    $0x4,%esp
  801c08:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c0a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c11:	75 12                	jne    801c25 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	6a 02                	push   $0x2
  801c18:	e8 6d 08 00 00       	call   80248a <ipc_find_env>
  801c1d:	a3 04 40 80 00       	mov    %eax,0x804004
  801c22:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c25:	6a 07                	push   $0x7
  801c27:	68 00 60 80 00       	push   $0x806000
  801c2c:	53                   	push   %ebx
  801c2d:	ff 35 04 40 80 00    	pushl  0x804004
  801c33:	e8 fe 07 00 00       	call   802436 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c38:	83 c4 0c             	add    $0xc,%esp
  801c3b:	6a 00                	push   $0x0
  801c3d:	6a 00                	push   $0x0
  801c3f:	6a 00                	push   $0x0
  801c41:	e8 83 07 00 00       	call   8023c9 <ipc_recv>
}
  801c46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c5b:	8b 06                	mov    (%esi),%eax
  801c5d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	e8 95 ff ff ff       	call   801c01 <nsipc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	78 20                	js     801c92 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	ff 35 10 60 80 00    	pushl  0x806010
  801c7b:	68 00 60 80 00       	push   $0x806000
  801c80:	ff 75 0c             	pushl  0xc(%ebp)
  801c83:	e8 a8 ed ff ff       	call   800a30 <memmove>
		*addrlen = ret->ret_addrlen;
  801c88:	a1 10 60 80 00       	mov    0x806010,%eax
  801c8d:	89 06                	mov    %eax,(%esi)
  801c8f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c92:	89 d8                	mov    %ebx,%eax
  801c94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	53                   	push   %ebx
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cad:	53                   	push   %ebx
  801cae:	ff 75 0c             	pushl  0xc(%ebp)
  801cb1:	68 04 60 80 00       	push   $0x806004
  801cb6:	e8 75 ed ff ff       	call   800a30 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cbb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cc1:	b8 02 00 00 00       	mov    $0x2,%eax
  801cc6:	e8 36 ff ff ff       	call   801c01 <nsipc>
}
  801ccb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ce6:	b8 03 00 00 00       	mov    $0x3,%eax
  801ceb:	e8 11 ff ff ff       	call   801c01 <nsipc>
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <nsipc_close>:

int
nsipc_close(int s)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d00:	b8 04 00 00 00       	mov    $0x4,%eax
  801d05:	e8 f7 fe ff ff       	call   801c01 <nsipc>
}
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 08             	sub    $0x8,%esp
  801d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d1e:	53                   	push   %ebx
  801d1f:	ff 75 0c             	pushl  0xc(%ebp)
  801d22:	68 04 60 80 00       	push   $0x806004
  801d27:	e8 04 ed ff ff       	call   800a30 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d2c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d32:	b8 05 00 00 00       	mov    $0x5,%eax
  801d37:	e8 c5 fe ff ff       	call   801c01 <nsipc>
}
  801d3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d52:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d57:	b8 06 00 00 00       	mov    $0x6,%eax
  801d5c:	e8 a0 fe ff ff       	call   801c01 <nsipc>
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d73:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d79:	8b 45 14             	mov    0x14(%ebp),%eax
  801d7c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d81:	b8 07 00 00 00       	mov    $0x7,%eax
  801d86:	e8 76 fe ff ff       	call   801c01 <nsipc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 35                	js     801dc6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d91:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d96:	7f 04                	jg     801d9c <nsipc_recv+0x39>
  801d98:	39 c6                	cmp    %eax,%esi
  801d9a:	7d 16                	jge    801db2 <nsipc_recv+0x4f>
  801d9c:	68 f3 2d 80 00       	push   $0x802df3
  801da1:	68 bb 2d 80 00       	push   $0x802dbb
  801da6:	6a 62                	push   $0x62
  801da8:	68 08 2e 80 00       	push   $0x802e08
  801dad:	e8 8e e4 ff ff       	call   800240 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	50                   	push   %eax
  801db6:	68 00 60 80 00       	push   $0x806000
  801dbb:	ff 75 0c             	pushl  0xc(%ebp)
  801dbe:	e8 6d ec ff ff       	call   800a30 <memmove>
  801dc3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dc6:	89 d8                	mov    %ebx,%eax
  801dc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5e                   	pop    %esi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801de1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801de7:	7e 16                	jle    801dff <nsipc_send+0x30>
  801de9:	68 14 2e 80 00       	push   $0x802e14
  801dee:	68 bb 2d 80 00       	push   $0x802dbb
  801df3:	6a 6d                	push   $0x6d
  801df5:	68 08 2e 80 00       	push   $0x802e08
  801dfa:	e8 41 e4 ff ff       	call   800240 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dff:	83 ec 04             	sub    $0x4,%esp
  801e02:	53                   	push   %ebx
  801e03:	ff 75 0c             	pushl  0xc(%ebp)
  801e06:	68 0c 60 80 00       	push   $0x80600c
  801e0b:	e8 20 ec ff ff       	call   800a30 <memmove>
	nsipcbuf.send.req_size = size;
  801e10:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e16:	8b 45 14             	mov    0x14(%ebp),%eax
  801e19:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e1e:	b8 08 00 00 00       	mov    $0x8,%eax
  801e23:	e8 d9 fd ff ff       	call   801c01 <nsipc>
}
  801e28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e43:	8b 45 10             	mov    0x10(%ebp),%eax
  801e46:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e4b:	b8 09 00 00 00       	mov    $0x9,%eax
  801e50:	e8 ac fd ff ff       	call   801c01 <nsipc>
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	56                   	push   %esi
  801e5b:	53                   	push   %ebx
  801e5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 87 f3 ff ff       	call   8011f1 <fd2data>
  801e6a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e6c:	83 c4 08             	add    $0x8,%esp
  801e6f:	68 20 2e 80 00       	push   $0x802e20
  801e74:	53                   	push   %ebx
  801e75:	e8 24 ea ff ff       	call   80089e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e7a:	8b 46 04             	mov    0x4(%esi),%eax
  801e7d:	2b 06                	sub    (%esi),%eax
  801e7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e85:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e8c:	00 00 00 
	stat->st_dev = &devpipe;
  801e8f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e96:	30 80 00 
	return 0;
}
  801e99:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	53                   	push   %ebx
  801ea9:	83 ec 0c             	sub    $0xc,%esp
  801eac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eaf:	53                   	push   %ebx
  801eb0:	6a 00                	push   $0x0
  801eb2:	e8 6f ee ff ff       	call   800d26 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eb7:	89 1c 24             	mov    %ebx,(%esp)
  801eba:	e8 32 f3 ff ff       	call   8011f1 <fd2data>
  801ebf:	83 c4 08             	add    $0x8,%esp
  801ec2:	50                   	push   %eax
  801ec3:	6a 00                	push   $0x0
  801ec5:	e8 5c ee ff ff       	call   800d26 <sys_page_unmap>
}
  801eca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ecd:	c9                   	leave  
  801ece:	c3                   	ret    

00801ecf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	57                   	push   %edi
  801ed3:	56                   	push   %esi
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 1c             	sub    $0x1c,%esp
  801ed8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801edb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801edd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ee5:	83 ec 0c             	sub    $0xc,%esp
  801ee8:	ff 75 e0             	pushl  -0x20(%ebp)
  801eeb:	e8 d3 05 00 00       	call   8024c3 <pageref>
  801ef0:	89 c3                	mov    %eax,%ebx
  801ef2:	89 3c 24             	mov    %edi,(%esp)
  801ef5:	e8 c9 05 00 00       	call   8024c3 <pageref>
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	39 c3                	cmp    %eax,%ebx
  801eff:	0f 94 c1             	sete   %cl
  801f02:	0f b6 c9             	movzbl %cl,%ecx
  801f05:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f08:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f0e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f11:	39 ce                	cmp    %ecx,%esi
  801f13:	74 1b                	je     801f30 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f15:	39 c3                	cmp    %eax,%ebx
  801f17:	75 c4                	jne    801edd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f19:	8b 42 58             	mov    0x58(%edx),%eax
  801f1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f1f:	50                   	push   %eax
  801f20:	56                   	push   %esi
  801f21:	68 27 2e 80 00       	push   $0x802e27
  801f26:	e8 ee e3 ff ff       	call   800319 <cprintf>
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	eb ad                	jmp    801edd <_pipeisclosed+0xe>
	}
}
  801f30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f36:	5b                   	pop    %ebx
  801f37:	5e                   	pop    %esi
  801f38:	5f                   	pop    %edi
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    

00801f3b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	57                   	push   %edi
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 28             	sub    $0x28,%esp
  801f44:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f47:	56                   	push   %esi
  801f48:	e8 a4 f2 ff ff       	call   8011f1 <fd2data>
  801f4d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	bf 00 00 00 00       	mov    $0x0,%edi
  801f57:	eb 4b                	jmp    801fa4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f59:	89 da                	mov    %ebx,%edx
  801f5b:	89 f0                	mov    %esi,%eax
  801f5d:	e8 6d ff ff ff       	call   801ecf <_pipeisclosed>
  801f62:	85 c0                	test   %eax,%eax
  801f64:	75 48                	jne    801fae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f66:	e8 17 ed ff ff       	call   800c82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801f6e:	8b 0b                	mov    (%ebx),%ecx
  801f70:	8d 51 20             	lea    0x20(%ecx),%edx
  801f73:	39 d0                	cmp    %edx,%eax
  801f75:	73 e2                	jae    801f59 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f81:	89 c2                	mov    %eax,%edx
  801f83:	c1 fa 1f             	sar    $0x1f,%edx
  801f86:	89 d1                	mov    %edx,%ecx
  801f88:	c1 e9 1b             	shr    $0x1b,%ecx
  801f8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f8e:	83 e2 1f             	and    $0x1f,%edx
  801f91:	29 ca                	sub    %ecx,%edx
  801f93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f9b:	83 c0 01             	add    $0x1,%eax
  801f9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa1:	83 c7 01             	add    $0x1,%edi
  801fa4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fa7:	75 c2                	jne    801f6b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fa9:	8b 45 10             	mov    0x10(%ebp),%eax
  801fac:	eb 05                	jmp    801fb3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	57                   	push   %edi
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 18             	sub    $0x18,%esp
  801fc4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fc7:	57                   	push   %edi
  801fc8:	e8 24 f2 ff ff       	call   8011f1 <fd2data>
  801fcd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fd7:	eb 3d                	jmp    802016 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fd9:	85 db                	test   %ebx,%ebx
  801fdb:	74 04                	je     801fe1 <devpipe_read+0x26>
				return i;
  801fdd:	89 d8                	mov    %ebx,%eax
  801fdf:	eb 44                	jmp    802025 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe1:	89 f2                	mov    %esi,%edx
  801fe3:	89 f8                	mov    %edi,%eax
  801fe5:	e8 e5 fe ff ff       	call   801ecf <_pipeisclosed>
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 32                	jne    802020 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fee:	e8 8f ec ff ff       	call   800c82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ff3:	8b 06                	mov    (%esi),%eax
  801ff5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ff8:	74 df                	je     801fd9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ffa:	99                   	cltd   
  801ffb:	c1 ea 1b             	shr    $0x1b,%edx
  801ffe:	01 d0                	add    %edx,%eax
  802000:	83 e0 1f             	and    $0x1f,%eax
  802003:	29 d0                	sub    %edx,%eax
  802005:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80200a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80200d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802010:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802013:	83 c3 01             	add    $0x1,%ebx
  802016:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802019:	75 d8                	jne    801ff3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80201b:	8b 45 10             	mov    0x10(%ebp),%eax
  80201e:	eb 05                	jmp    802025 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802025:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802028:	5b                   	pop    %ebx
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	56                   	push   %esi
  802031:	53                   	push   %ebx
  802032:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802035:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802038:	50                   	push   %eax
  802039:	e8 ca f1 ff ff       	call   801208 <fd_alloc>
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	89 c2                	mov    %eax,%edx
  802043:	85 c0                	test   %eax,%eax
  802045:	0f 88 2c 01 00 00    	js     802177 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204b:	83 ec 04             	sub    $0x4,%esp
  80204e:	68 07 04 00 00       	push   $0x407
  802053:	ff 75 f4             	pushl  -0xc(%ebp)
  802056:	6a 00                	push   $0x0
  802058:	e8 44 ec ff ff       	call   800ca1 <sys_page_alloc>
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	89 c2                	mov    %eax,%edx
  802062:	85 c0                	test   %eax,%eax
  802064:	0f 88 0d 01 00 00    	js     802177 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80206a:	83 ec 0c             	sub    $0xc,%esp
  80206d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802070:	50                   	push   %eax
  802071:	e8 92 f1 ff ff       	call   801208 <fd_alloc>
  802076:	89 c3                	mov    %eax,%ebx
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	0f 88 e2 00 00 00    	js     802165 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802083:	83 ec 04             	sub    $0x4,%esp
  802086:	68 07 04 00 00       	push   $0x407
  80208b:	ff 75 f0             	pushl  -0x10(%ebp)
  80208e:	6a 00                	push   $0x0
  802090:	e8 0c ec ff ff       	call   800ca1 <sys_page_alloc>
  802095:	89 c3                	mov    %eax,%ebx
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	0f 88 c3 00 00 00    	js     802165 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a2:	83 ec 0c             	sub    $0xc,%esp
  8020a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a8:	e8 44 f1 ff ff       	call   8011f1 <fd2data>
  8020ad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020af:	83 c4 0c             	add    $0xc,%esp
  8020b2:	68 07 04 00 00       	push   $0x407
  8020b7:	50                   	push   %eax
  8020b8:	6a 00                	push   $0x0
  8020ba:	e8 e2 eb ff ff       	call   800ca1 <sys_page_alloc>
  8020bf:	89 c3                	mov    %eax,%ebx
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	0f 88 89 00 00 00    	js     802155 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cc:	83 ec 0c             	sub    $0xc,%esp
  8020cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d2:	e8 1a f1 ff ff       	call   8011f1 <fd2data>
  8020d7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020de:	50                   	push   %eax
  8020df:	6a 00                	push   $0x0
  8020e1:	56                   	push   %esi
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 fb eb ff ff       	call   800ce4 <sys_page_map>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	83 c4 20             	add    $0x20,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 55                	js     802147 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020f2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802100:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802107:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802110:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802112:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802115:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80211c:	83 ec 0c             	sub    $0xc,%esp
  80211f:	ff 75 f4             	pushl  -0xc(%ebp)
  802122:	e8 ba f0 ff ff       	call   8011e1 <fd2num>
  802127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80212a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80212c:	83 c4 04             	add    $0x4,%esp
  80212f:	ff 75 f0             	pushl  -0x10(%ebp)
  802132:	e8 aa f0 ff ff       	call   8011e1 <fd2num>
  802137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80213a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	ba 00 00 00 00       	mov    $0x0,%edx
  802145:	eb 30                	jmp    802177 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802147:	83 ec 08             	sub    $0x8,%esp
  80214a:	56                   	push   %esi
  80214b:	6a 00                	push   $0x0
  80214d:	e8 d4 eb ff ff       	call   800d26 <sys_page_unmap>
  802152:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802155:	83 ec 08             	sub    $0x8,%esp
  802158:	ff 75 f0             	pushl  -0x10(%ebp)
  80215b:	6a 00                	push   $0x0
  80215d:	e8 c4 eb ff ff       	call   800d26 <sys_page_unmap>
  802162:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802165:	83 ec 08             	sub    $0x8,%esp
  802168:	ff 75 f4             	pushl  -0xc(%ebp)
  80216b:	6a 00                	push   $0x0
  80216d:	e8 b4 eb ff ff       	call   800d26 <sys_page_unmap>
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802177:	89 d0                	mov    %edx,%eax
  802179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    

00802180 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802189:	50                   	push   %eax
  80218a:	ff 75 08             	pushl  0x8(%ebp)
  80218d:	e8 c5 f0 ff ff       	call   801257 <fd_lookup>
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	85 c0                	test   %eax,%eax
  802197:	78 18                	js     8021b1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802199:	83 ec 0c             	sub    $0xc,%esp
  80219c:	ff 75 f4             	pushl  -0xc(%ebp)
  80219f:	e8 4d f0 ff ff       	call   8011f1 <fd2data>
	return _pipeisclosed(fd, p);
  8021a4:	89 c2                	mov    %eax,%edx
  8021a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a9:	e8 21 fd ff ff       	call   801ecf <_pipeisclosed>
  8021ae:	83 c4 10             	add    $0x10,%esp
}
  8021b1:	c9                   	leave  
  8021b2:	c3                   	ret    

008021b3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    

008021bd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021c3:	68 3f 2e 80 00       	push   $0x802e3f
  8021c8:	ff 75 0c             	pushl  0xc(%ebp)
  8021cb:	e8 ce e6 ff ff       	call   80089e <strcpy>
	return 0;
}
  8021d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d5:	c9                   	leave  
  8021d6:	c3                   	ret    

008021d7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	57                   	push   %edi
  8021db:	56                   	push   %esi
  8021dc:	53                   	push   %ebx
  8021dd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ee:	eb 2d                	jmp    80221d <devcons_write+0x46>
		m = n - tot;
  8021f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021f3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021f5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021f8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021fd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802200:	83 ec 04             	sub    $0x4,%esp
  802203:	53                   	push   %ebx
  802204:	03 45 0c             	add    0xc(%ebp),%eax
  802207:	50                   	push   %eax
  802208:	57                   	push   %edi
  802209:	e8 22 e8 ff ff       	call   800a30 <memmove>
		sys_cputs(buf, m);
  80220e:	83 c4 08             	add    $0x8,%esp
  802211:	53                   	push   %ebx
  802212:	57                   	push   %edi
  802213:	e8 cd e9 ff ff       	call   800be5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802218:	01 de                	add    %ebx,%esi
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	89 f0                	mov    %esi,%eax
  80221f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802222:	72 cc                	jb     8021f0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    

0080222c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 08             	sub    $0x8,%esp
  802232:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802237:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80223b:	74 2a                	je     802267 <devcons_read+0x3b>
  80223d:	eb 05                	jmp    802244 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80223f:	e8 3e ea ff ff       	call   800c82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802244:	e8 ba e9 ff ff       	call   800c03 <sys_cgetc>
  802249:	85 c0                	test   %eax,%eax
  80224b:	74 f2                	je     80223f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80224d:	85 c0                	test   %eax,%eax
  80224f:	78 16                	js     802267 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802251:	83 f8 04             	cmp    $0x4,%eax
  802254:	74 0c                	je     802262 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802256:	8b 55 0c             	mov    0xc(%ebp),%edx
  802259:	88 02                	mov    %al,(%edx)
	return 1;
  80225b:	b8 01 00 00 00       	mov    $0x1,%eax
  802260:	eb 05                	jmp    802267 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802262:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802267:	c9                   	leave  
  802268:	c3                   	ret    

00802269 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80226f:	8b 45 08             	mov    0x8(%ebp),%eax
  802272:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802275:	6a 01                	push   $0x1
  802277:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80227a:	50                   	push   %eax
  80227b:	e8 65 e9 ff ff       	call   800be5 <sys_cputs>
}
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	c9                   	leave  
  802284:	c3                   	ret    

00802285 <getchar>:

int
getchar(void)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80228b:	6a 01                	push   $0x1
  80228d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802290:	50                   	push   %eax
  802291:	6a 00                	push   $0x0
  802293:	e8 25 f2 ff ff       	call   8014bd <read>
	if (r < 0)
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 c0                	test   %eax,%eax
  80229d:	78 0f                	js     8022ae <getchar+0x29>
		return r;
	if (r < 1)
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	7e 06                	jle    8022a9 <getchar+0x24>
		return -E_EOF;
	return c;
  8022a3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022a7:	eb 05                	jmp    8022ae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022a9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b9:	50                   	push   %eax
  8022ba:	ff 75 08             	pushl  0x8(%ebp)
  8022bd:	e8 95 ef ff ff       	call   801257 <fd_lookup>
  8022c2:	83 c4 10             	add    $0x10,%esp
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	78 11                	js     8022da <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022d2:	39 10                	cmp    %edx,(%eax)
  8022d4:	0f 94 c0             	sete   %al
  8022d7:	0f b6 c0             	movzbl %al,%eax
}
  8022da:	c9                   	leave  
  8022db:	c3                   	ret    

008022dc <opencons>:

int
opencons(void)
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e5:	50                   	push   %eax
  8022e6:	e8 1d ef ff ff       	call   801208 <fd_alloc>
  8022eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8022ee:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022f0:	85 c0                	test   %eax,%eax
  8022f2:	78 3e                	js     802332 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022f4:	83 ec 04             	sub    $0x4,%esp
  8022f7:	68 07 04 00 00       	push   $0x407
  8022fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ff:	6a 00                	push   $0x0
  802301:	e8 9b e9 ff ff       	call   800ca1 <sys_page_alloc>
  802306:	83 c4 10             	add    $0x10,%esp
		return r;
  802309:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 23                	js     802332 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80230f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802318:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80231a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802324:	83 ec 0c             	sub    $0xc,%esp
  802327:	50                   	push   %eax
  802328:	e8 b4 ee ff ff       	call   8011e1 <fd2num>
  80232d:	89 c2                	mov    %eax,%edx
  80232f:	83 c4 10             	add    $0x10,%esp
}
  802332:	89 d0                	mov    %edx,%eax
  802334:	c9                   	leave  
  802335:	c3                   	ret    

00802336 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80233c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802343:	75 2c                	jne    802371 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802345:	83 ec 04             	sub    $0x4,%esp
  802348:	6a 07                	push   $0x7
  80234a:	68 00 f0 bf ee       	push   $0xeebff000
  80234f:	6a 00                	push   $0x0
  802351:	e8 4b e9 ff ff       	call   800ca1 <sys_page_alloc>
  802356:	83 c4 10             	add    $0x10,%esp
  802359:	85 c0                	test   %eax,%eax
  80235b:	79 14                	jns    802371 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80235d:	83 ec 04             	sub    $0x4,%esp
  802360:	68 4b 2e 80 00       	push   $0x802e4b
  802365:	6a 22                	push   $0x22
  802367:	68 62 2e 80 00       	push   $0x802e62
  80236c:	e8 cf de ff ff       	call   800240 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802371:	8b 45 08             	mov    0x8(%ebp),%eax
  802374:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802379:	83 ec 08             	sub    $0x8,%esp
  80237c:	68 a5 23 80 00       	push   $0x8023a5
  802381:	6a 00                	push   $0x0
  802383:	e8 64 ea ff ff       	call   800dec <sys_env_set_pgfault_upcall>
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	85 c0                	test   %eax,%eax
  80238d:	79 14                	jns    8023a3 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80238f:	83 ec 04             	sub    $0x4,%esp
  802392:	68 70 2e 80 00       	push   $0x802e70
  802397:	6a 27                	push   $0x27
  802399:	68 62 2e 80 00       	push   $0x802e62
  80239e:	e8 9d de ff ff       	call   800240 <_panic>
    
}
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023a5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023a6:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023ab:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023ad:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8023b0:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8023b4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8023b9:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8023bd:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8023bf:	83 c4 08             	add    $0x8,%esp
	popal
  8023c2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8023c3:	83 c4 04             	add    $0x4,%esp
	popfl
  8023c6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023c7:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023c8:	c3                   	ret    

008023c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023c9:	55                   	push   %ebp
  8023ca:	89 e5                	mov    %esp,%ebp
  8023cc:	56                   	push   %esi
  8023cd:	53                   	push   %ebx
  8023ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8023d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8023d7:	85 c0                	test   %eax,%eax
  8023d9:	74 0e                	je     8023e9 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8023db:	83 ec 0c             	sub    $0xc,%esp
  8023de:	50                   	push   %eax
  8023df:	e8 6d ea ff ff       	call   800e51 <sys_ipc_recv>
  8023e4:	83 c4 10             	add    $0x10,%esp
  8023e7:	eb 10                	jmp    8023f9 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8023e9:	83 ec 0c             	sub    $0xc,%esp
  8023ec:	68 00 00 00 f0       	push   $0xf0000000
  8023f1:	e8 5b ea ff ff       	call   800e51 <sys_ipc_recv>
  8023f6:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	74 0e                	je     80240b <ipc_recv+0x42>
    	*from_env_store = 0;
  8023fd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802403:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802409:	eb 24                	jmp    80242f <ipc_recv+0x66>
    }	
    if (from_env_store) {
  80240b:	85 f6                	test   %esi,%esi
  80240d:	74 0a                	je     802419 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80240f:	a1 08 40 80 00       	mov    0x804008,%eax
  802414:	8b 40 74             	mov    0x74(%eax),%eax
  802417:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802419:	85 db                	test   %ebx,%ebx
  80241b:	74 0a                	je     802427 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80241d:	a1 08 40 80 00       	mov    0x804008,%eax
  802422:	8b 40 78             	mov    0x78(%eax),%eax
  802425:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802427:	a1 08 40 80 00       	mov    0x804008,%eax
  80242c:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80242f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802432:	5b                   	pop    %ebx
  802433:	5e                   	pop    %esi
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    

00802436 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	57                   	push   %edi
  80243a:	56                   	push   %esi
  80243b:	53                   	push   %ebx
  80243c:	83 ec 0c             	sub    $0xc,%esp
  80243f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802442:	8b 75 0c             	mov    0xc(%ebp),%esi
  802445:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802448:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  80244a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80244f:	0f 44 d8             	cmove  %eax,%ebx
  802452:	eb 1c                	jmp    802470 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802454:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802457:	74 12                	je     80246b <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802459:	50                   	push   %eax
  80245a:	68 94 2e 80 00       	push   $0x802e94
  80245f:	6a 4b                	push   $0x4b
  802461:	68 ac 2e 80 00       	push   $0x802eac
  802466:	e8 d5 dd ff ff       	call   800240 <_panic>
        }	
        sys_yield();
  80246b:	e8 12 e8 ff ff       	call   800c82 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802470:	ff 75 14             	pushl  0x14(%ebp)
  802473:	53                   	push   %ebx
  802474:	56                   	push   %esi
  802475:	57                   	push   %edi
  802476:	e8 b3 e9 ff ff       	call   800e2e <sys_ipc_try_send>
  80247b:	83 c4 10             	add    $0x10,%esp
  80247e:	85 c0                	test   %eax,%eax
  802480:	75 d2                	jne    802454 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802482:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802485:	5b                   	pop    %ebx
  802486:	5e                   	pop    %esi
  802487:	5f                   	pop    %edi
  802488:	5d                   	pop    %ebp
  802489:	c3                   	ret    

0080248a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80248a:	55                   	push   %ebp
  80248b:	89 e5                	mov    %esp,%ebp
  80248d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802490:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802495:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802498:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80249e:	8b 52 50             	mov    0x50(%edx),%edx
  8024a1:	39 ca                	cmp    %ecx,%edx
  8024a3:	75 0d                	jne    8024b2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ad:	8b 40 48             	mov    0x48(%eax),%eax
  8024b0:	eb 0f                	jmp    8024c1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024b2:	83 c0 01             	add    $0x1,%eax
  8024b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024ba:	75 d9                	jne    802495 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    

008024c3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024c3:	55                   	push   %ebp
  8024c4:	89 e5                	mov    %esp,%ebp
  8024c6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024c9:	89 d0                	mov    %edx,%eax
  8024cb:	c1 e8 16             	shr    $0x16,%eax
  8024ce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024d5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024da:	f6 c1 01             	test   $0x1,%cl
  8024dd:	74 1d                	je     8024fc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024df:	c1 ea 0c             	shr    $0xc,%edx
  8024e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024e9:	f6 c2 01             	test   $0x1,%dl
  8024ec:	74 0e                	je     8024fc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024ee:	c1 ea 0c             	shr    $0xc,%edx
  8024f1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024f8:	ef 
  8024f9:	0f b7 c0             	movzwl %ax,%eax
}
  8024fc:	5d                   	pop    %ebp
  8024fd:	c3                   	ret    
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
