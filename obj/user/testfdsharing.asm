
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 c0 27 80 00       	push   $0x8027c0
  800043:	e8 e6 18 00 00       	call   80192e <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 c5 27 80 00       	push   $0x8027c5
  800057:	6a 0c                	push   $0xc
  800059:	68 d3 27 80 00       	push   $0x8027d3
  80005e:	e8 bf 01 00 00       	call   800222 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 97 15 00 00       	call   801605 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 af 14 00 00       	call   801530 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 e8 27 80 00       	push   $0x8027e8
  800090:	6a 0f                	push   $0xf
  800092:	68 d3 27 80 00       	push   $0x8027d3
  800097:	e8 86 01 00 00       	call   800222 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 0d 0f 00 00       	call   800fae <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 f2 27 80 00       	push   $0x8027f2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 d3 27 80 00       	push   $0x8027d3
  8000b4:	e8 69 01 00 00       	call   800222 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 39 15 00 00       	call   801605 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  8000d3:	e8 23 02 00 00       	call   8002fb <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 45 14 00 00       	call   801530 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 74 28 80 00       	push   $0x802874
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 d3 27 80 00       	push   $0x8027d3
  800103:	e8 1a 01 00 00       	call   800222 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 72 09 00 00       	call   800a8d <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 a0 28 80 00       	push   $0x8028a0
  80012a:	6a 19                	push   $0x19
  80012c:	68 d3 27 80 00       	push   $0x8027d3
  800131:	e8 ec 00 00 00       	call   800222 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 fb 27 80 00       	push   $0x8027fb
  80013e:	e8 b8 01 00 00       	call   8002fb <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 b7 14 00 00       	call   801605 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 0d 12 00 00       	call   801363 <close>
		exit();
  800156:	e8 ad 00 00 00       	call   800208 <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 2e 20 00 00       	call   802195 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 b6 13 00 00       	call   801530 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 d8 28 80 00       	push   $0x8028d8
  80018b:	6a 21                	push   $0x21
  80018d:	68 d3 27 80 00       	push   $0x8027d3
  800192:	e8 8b 00 00 00       	call   800222 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 14 28 80 00       	push   $0x802814
  80019f:	e8 57 01 00 00       	call   8002fb <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 b7 11 00 00       	call   801363 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001c3:	c7 05 20 44 80 00 00 	movl   $0x0,0x804420
  8001ca:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8001cd:	e8 73 0a 00 00       	call   800c45 <sys_getenvid>
  8001d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001df:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e4:	85 db                	test   %ebx,%ebx
  8001e6:	7e 07                	jle    8001ef <libmain+0x37>
		binaryname = argv[0];
  8001e8:	8b 06                	mov    (%esi),%eax
  8001ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	e8 3a fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001f9:	e8 0a 00 00 00       	call   800208 <exit>
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    

00800208 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020e:	e8 7b 11 00 00       	call   80138e <close_all>
	sys_env_destroy(0);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	6a 00                	push   $0x0
  800218:	e8 e7 09 00 00       	call   800c04 <sys_env_destroy>
}
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800227:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800230:	e8 10 0a 00 00       	call   800c45 <sys_getenvid>
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	56                   	push   %esi
  80023f:	50                   	push   %eax
  800240:	68 08 29 80 00       	push   $0x802908
  800245:	e8 b1 00 00 00       	call   8002fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024a:	83 c4 18             	add    $0x18,%esp
  80024d:	53                   	push   %ebx
  80024e:	ff 75 10             	pushl  0x10(%ebp)
  800251:	e8 54 00 00 00       	call   8002aa <vcprintf>
	cprintf("\n");
  800256:	c7 04 24 7a 2c 80 00 	movl   $0x802c7a,(%esp)
  80025d:	e8 99 00 00 00       	call   8002fb <cprintf>
  800262:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800265:	cc                   	int3   
  800266:	eb fd                	jmp    800265 <_panic+0x43>

00800268 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	53                   	push   %ebx
  80026c:	83 ec 04             	sub    $0x4,%esp
  80026f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800272:	8b 13                	mov    (%ebx),%edx
  800274:	8d 42 01             	lea    0x1(%edx),%eax
  800277:	89 03                	mov    %eax,(%ebx)
  800279:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800280:	3d ff 00 00 00       	cmp    $0xff,%eax
  800285:	75 1a                	jne    8002a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	68 ff 00 00 00       	push   $0xff
  80028f:	8d 43 08             	lea    0x8(%ebx),%eax
  800292:	50                   	push   %eax
  800293:	e8 2f 09 00 00       	call   800bc7 <sys_cputs>
		b->idx = 0;
  800298:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80029e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ba:	00 00 00 
	b.cnt = 0;
  8002bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	68 68 02 80 00       	push   $0x800268
  8002d9:	e8 54 01 00 00       	call   800432 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002de:	83 c4 08             	add    $0x8,%esp
  8002e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ed:	50                   	push   %eax
  8002ee:	e8 d4 08 00 00       	call   800bc7 <sys_cputs>

	return b.cnt;
}
  8002f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800301:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800304:	50                   	push   %eax
  800305:	ff 75 08             	pushl  0x8(%ebp)
  800308:	e8 9d ff ff ff       	call   8002aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 1c             	sub    $0x1c,%esp
  800318:	89 c7                	mov    %eax,%edi
  80031a:	89 d6                	mov    %edx,%esi
  80031c:	8b 45 08             	mov    0x8(%ebp),%eax
  80031f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800322:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800325:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800328:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80032b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800330:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800333:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800336:	39 d3                	cmp    %edx,%ebx
  800338:	72 05                	jb     80033f <printnum+0x30>
  80033a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80033d:	77 45                	ja     800384 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033f:	83 ec 0c             	sub    $0xc,%esp
  800342:	ff 75 18             	pushl  0x18(%ebp)
  800345:	8b 45 14             	mov    0x14(%ebp),%eax
  800348:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80034b:	53                   	push   %ebx
  80034c:	ff 75 10             	pushl  0x10(%ebp)
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	ff 75 e4             	pushl  -0x1c(%ebp)
  800355:	ff 75 e0             	pushl  -0x20(%ebp)
  800358:	ff 75 dc             	pushl  -0x24(%ebp)
  80035b:	ff 75 d8             	pushl  -0x28(%ebp)
  80035e:	e8 cd 21 00 00       	call   802530 <__udivdi3>
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	52                   	push   %edx
  800367:	50                   	push   %eax
  800368:	89 f2                	mov    %esi,%edx
  80036a:	89 f8                	mov    %edi,%eax
  80036c:	e8 9e ff ff ff       	call   80030f <printnum>
  800371:	83 c4 20             	add    $0x20,%esp
  800374:	eb 18                	jmp    80038e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	56                   	push   %esi
  80037a:	ff 75 18             	pushl  0x18(%ebp)
  80037d:	ff d7                	call   *%edi
  80037f:	83 c4 10             	add    $0x10,%esp
  800382:	eb 03                	jmp    800387 <printnum+0x78>
  800384:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	83 eb 01             	sub    $0x1,%ebx
  80038a:	85 db                	test   %ebx,%ebx
  80038c:	7f e8                	jg     800376 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	56                   	push   %esi
  800392:	83 ec 04             	sub    $0x4,%esp
  800395:	ff 75 e4             	pushl  -0x1c(%ebp)
  800398:	ff 75 e0             	pushl  -0x20(%ebp)
  80039b:	ff 75 dc             	pushl  -0x24(%ebp)
  80039e:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a1:	e8 ba 22 00 00       	call   802660 <__umoddi3>
  8003a6:	83 c4 14             	add    $0x14,%esp
  8003a9:	0f be 80 2b 29 80 00 	movsbl 0x80292b(%eax),%eax
  8003b0:	50                   	push   %eax
  8003b1:	ff d7                	call   *%edi
}
  8003b3:	83 c4 10             	add    $0x10,%esp
  8003b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5f                   	pop    %edi
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    

008003be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c1:	83 fa 01             	cmp    $0x1,%edx
  8003c4:	7e 0e                	jle    8003d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cb:	89 08                	mov    %ecx,(%eax)
  8003cd:	8b 02                	mov    (%edx),%eax
  8003cf:	8b 52 04             	mov    0x4(%edx),%edx
  8003d2:	eb 22                	jmp    8003f6 <getuint+0x38>
	else if (lflag)
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	74 10                	je     8003e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 02                	mov    (%edx),%eax
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e6:	eb 0e                	jmp    8003f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800402:	8b 10                	mov    (%eax),%edx
  800404:	3b 50 04             	cmp    0x4(%eax),%edx
  800407:	73 0a                	jae    800413 <sprintputch+0x1b>
		*b->buf++ = ch;
  800409:	8d 4a 01             	lea    0x1(%edx),%ecx
  80040c:	89 08                	mov    %ecx,(%eax)
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	88 02                	mov    %al,(%edx)
}
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80041b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041e:	50                   	push   %eax
  80041f:	ff 75 10             	pushl  0x10(%ebp)
  800422:	ff 75 0c             	pushl  0xc(%ebp)
  800425:	ff 75 08             	pushl  0x8(%ebp)
  800428:	e8 05 00 00 00       	call   800432 <vprintfmt>
	va_end(ap);
}
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	c9                   	leave  
  800431:	c3                   	ret    

00800432 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 2c             	sub    $0x2c,%esp
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi
  80043e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800441:	8b 7d 10             	mov    0x10(%ebp),%edi
  800444:	eb 12                	jmp    800458 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800446:	85 c0                	test   %eax,%eax
  800448:	0f 84 89 03 00 00    	je     8007d7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	50                   	push   %eax
  800453:	ff d6                	call   *%esi
  800455:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800458:	83 c7 01             	add    $0x1,%edi
  80045b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80045f:	83 f8 25             	cmp    $0x25,%eax
  800462:	75 e2                	jne    800446 <vprintfmt+0x14>
  800464:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800468:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80046f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800476:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
  800482:	eb 07                	jmp    80048b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800487:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8d 47 01             	lea    0x1(%edi),%eax
  80048e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800491:	0f b6 07             	movzbl (%edi),%eax
  800494:	0f b6 c8             	movzbl %al,%ecx
  800497:	83 e8 23             	sub    $0x23,%eax
  80049a:	3c 55                	cmp    $0x55,%al
  80049c:	0f 87 1a 03 00 00    	ja     8007bc <vprintfmt+0x38a>
  8004a2:	0f b6 c0             	movzbl %al,%eax
  8004a5:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b3:	eb d6                	jmp    80048b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004cd:	83 fa 09             	cmp    $0x9,%edx
  8004d0:	77 39                	ja     80050b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d5:	eb e9                	jmp    8004c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 48 04             	lea    0x4(%eax),%ecx
  8004dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e8:	eb 27                	jmp    800511 <vprintfmt+0xdf>
  8004ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f4:	0f 49 c8             	cmovns %eax,%ecx
  8004f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fd:	eb 8c                	jmp    80048b <vprintfmt+0x59>
  8004ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800502:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800509:	eb 80                	jmp    80048b <vprintfmt+0x59>
  80050b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800511:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800515:	0f 89 70 ff ff ff    	jns    80048b <vprintfmt+0x59>
				width = precision, precision = -1;
  80051b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800528:	e9 5e ff ff ff       	jmp    80048b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800533:	e9 53 ff ff ff       	jmp    80048b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	ff 30                	pushl  (%eax)
  800547:	ff d6                	call   *%esi
			break;
  800549:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80054f:	e9 04 ff ff ff       	jmp    800458 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	99                   	cltd   
  800560:	31 d0                	xor    %edx,%eax
  800562:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800564:	83 f8 0f             	cmp    $0xf,%eax
  800567:	7f 0b                	jg     800574 <vprintfmt+0x142>
  800569:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	75 18                	jne    80058c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800574:	50                   	push   %eax
  800575:	68 43 29 80 00       	push   $0x802943
  80057a:	53                   	push   %ebx
  80057b:	56                   	push   %esi
  80057c:	e8 94 fe ff ff       	call   800415 <printfmt>
  800581:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800587:	e9 cc fe ff ff       	jmp    800458 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80058c:	52                   	push   %edx
  80058d:	68 4d 2e 80 00       	push   $0x802e4d
  800592:	53                   	push   %ebx
  800593:	56                   	push   %esi
  800594:	e8 7c fe ff ff       	call   800415 <printfmt>
  800599:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059f:	e9 b4 fe ff ff       	jmp    800458 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005af:	85 ff                	test   %edi,%edi
  8005b1:	b8 3c 29 80 00       	mov    $0x80293c,%eax
  8005b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bd:	0f 8e 94 00 00 00    	jle    800657 <vprintfmt+0x225>
  8005c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005c7:	0f 84 98 00 00 00    	je     800665 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	ff 75 d0             	pushl  -0x30(%ebp)
  8005d3:	57                   	push   %edi
  8005d4:	e8 86 02 00 00       	call   80085f <strnlen>
  8005d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005dc:	29 c1                	sub    %eax,%ecx
  8005de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f0:	eb 0f                	jmp    800601 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fb:	83 ef 01             	sub    $0x1,%edi
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	85 ff                	test   %edi,%edi
  800603:	7f ed                	jg     8005f2 <vprintfmt+0x1c0>
  800605:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800608:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80060b:	85 c9                	test   %ecx,%ecx
  80060d:	b8 00 00 00 00       	mov    $0x0,%eax
  800612:	0f 49 c1             	cmovns %ecx,%eax
  800615:	29 c1                	sub    %eax,%ecx
  800617:	89 75 08             	mov    %esi,0x8(%ebp)
  80061a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800620:	89 cb                	mov    %ecx,%ebx
  800622:	eb 4d                	jmp    800671 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800628:	74 1b                	je     800645 <vprintfmt+0x213>
  80062a:	0f be c0             	movsbl %al,%eax
  80062d:	83 e8 20             	sub    $0x20,%eax
  800630:	83 f8 5e             	cmp    $0x5e,%eax
  800633:	76 10                	jbe    800645 <vprintfmt+0x213>
					putch('?', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	ff 75 0c             	pushl  0xc(%ebp)
  80063b:	6a 3f                	push   $0x3f
  80063d:	ff 55 08             	call   *0x8(%ebp)
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	eb 0d                	jmp    800652 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	ff 75 0c             	pushl  0xc(%ebp)
  80064b:	52                   	push   %edx
  80064c:	ff 55 08             	call   *0x8(%ebp)
  80064f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800652:	83 eb 01             	sub    $0x1,%ebx
  800655:	eb 1a                	jmp    800671 <vprintfmt+0x23f>
  800657:	89 75 08             	mov    %esi,0x8(%ebp)
  80065a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800660:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800663:	eb 0c                	jmp    800671 <vprintfmt+0x23f>
  800665:	89 75 08             	mov    %esi,0x8(%ebp)
  800668:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800671:	83 c7 01             	add    $0x1,%edi
  800674:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800678:	0f be d0             	movsbl %al,%edx
  80067b:	85 d2                	test   %edx,%edx
  80067d:	74 23                	je     8006a2 <vprintfmt+0x270>
  80067f:	85 f6                	test   %esi,%esi
  800681:	78 a1                	js     800624 <vprintfmt+0x1f2>
  800683:	83 ee 01             	sub    $0x1,%esi
  800686:	79 9c                	jns    800624 <vprintfmt+0x1f2>
  800688:	89 df                	mov    %ebx,%edi
  80068a:	8b 75 08             	mov    0x8(%ebp),%esi
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800690:	eb 18                	jmp    8006aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 20                	push   $0x20
  800698:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069a:	83 ef 01             	sub    $0x1,%edi
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 08                	jmp    8006aa <vprintfmt+0x278>
  8006a2:	89 df                	mov    %ebx,%edi
  8006a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006aa:	85 ff                	test   %edi,%edi
  8006ac:	7f e4                	jg     800692 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b1:	e9 a2 fd ff ff       	jmp    800458 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b6:	83 fa 01             	cmp    $0x1,%edx
  8006b9:	7e 16                	jle    8006d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 08             	lea    0x8(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 50 04             	mov    0x4(%eax),%edx
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006cf:	eb 32                	jmp    800703 <vprintfmt+0x2d1>
	else if (lflag)
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	74 18                	je     8006ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e3:	89 c1                	mov    %eax,%ecx
  8006e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006eb:	eb 16                	jmp    800703 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 50 04             	lea    0x4(%eax),%edx
  8006f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fb:	89 c1                	mov    %eax,%ecx
  8006fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800700:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800703:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800706:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800709:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800712:	79 74                	jns    800788 <vprintfmt+0x356>
				putch('-', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 2d                	push   $0x2d
  80071a:	ff d6                	call   *%esi
				num = -(long long) num;
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800722:	f7 d8                	neg    %eax
  800724:	83 d2 00             	adc    $0x0,%edx
  800727:	f7 da                	neg    %edx
  800729:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800731:	eb 55                	jmp    800788 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 83 fc ff ff       	call   8003be <getuint>
			base = 10;
  80073b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800740:	eb 46                	jmp    800788 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
  800745:	e8 74 fc ff ff       	call   8003be <getuint>
		        base = 8;
  80074a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80074f:	eb 37                	jmp    800788 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 30                	push   $0x30
  800757:	ff d6                	call   *%esi
			putch('x', putdat);
  800759:	83 c4 08             	add    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 78                	push   $0x78
  80075f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8d 50 04             	lea    0x4(%eax),%edx
  800767:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800771:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800774:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800779:	eb 0d                	jmp    800788 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 3b fc ff ff       	call   8003be <getuint>
			base = 16;
  800783:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	83 ec 0c             	sub    $0xc,%esp
  80078b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80078f:	57                   	push   %edi
  800790:	ff 75 e0             	pushl  -0x20(%ebp)
  800793:	51                   	push   %ecx
  800794:	52                   	push   %edx
  800795:	50                   	push   %eax
  800796:	89 da                	mov    %ebx,%edx
  800798:	89 f0                	mov    %esi,%eax
  80079a:	e8 70 fb ff ff       	call   80030f <printnum>
			break;
  80079f:	83 c4 20             	add    $0x20,%esp
  8007a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a5:	e9 ae fc ff ff       	jmp    800458 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	53                   	push   %ebx
  8007ae:	51                   	push   %ecx
  8007af:	ff d6                	call   *%esi
			break;
  8007b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b7:	e9 9c fc ff ff       	jmp    800458 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	53                   	push   %ebx
  8007c0:	6a 25                	push   $0x25
  8007c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	eb 03                	jmp    8007cc <vprintfmt+0x39a>
  8007c9:	83 ef 01             	sub    $0x1,%edi
  8007cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d0:	75 f7                	jne    8007c9 <vprintfmt+0x397>
  8007d2:	e9 81 fc ff ff       	jmp    800458 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5f                   	pop    %edi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 18             	sub    $0x18,%esp
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	74 26                	je     800826 <vsnprintf+0x47>
  800800:	85 d2                	test   %edx,%edx
  800802:	7e 22                	jle    800826 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800804:	ff 75 14             	pushl  0x14(%ebp)
  800807:	ff 75 10             	pushl  0x10(%ebp)
  80080a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	68 f8 03 80 00       	push   $0x8003f8
  800813:	e8 1a fc ff ff       	call   800432 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	eb 05                	jmp    80082b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800836:	50                   	push   %eax
  800837:	ff 75 10             	pushl  0x10(%ebp)
  80083a:	ff 75 0c             	pushl  0xc(%ebp)
  80083d:	ff 75 08             	pushl  0x8(%ebp)
  800840:	e8 9a ff ff ff       	call   8007df <vsnprintf>
	va_end(ap);

	return rc;
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	eb 03                	jmp    800857 <strlen+0x10>
		n++;
  800854:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800857:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085b:	75 f7                	jne    800854 <strlen+0xd>
		n++;
	return n;
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	ba 00 00 00 00       	mov    $0x0,%edx
  80086d:	eb 03                	jmp    800872 <strnlen+0x13>
		n++;
  80086f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800872:	39 c2                	cmp    %eax,%edx
  800874:	74 08                	je     80087e <strnlen+0x1f>
  800876:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80087a:	75 f3                	jne    80086f <strnlen+0x10>
  80087c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80088a:	89 c2                	mov    %eax,%edx
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	83 c1 01             	add    $0x1,%ecx
  800892:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800896:	88 5a ff             	mov    %bl,-0x1(%edx)
  800899:	84 db                	test   %bl,%bl
  80089b:	75 ef                	jne    80088c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a7:	53                   	push   %ebx
  8008a8:	e8 9a ff ff ff       	call   800847 <strlen>
  8008ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	01 d8                	add    %ebx,%eax
  8008b5:	50                   	push   %eax
  8008b6:	e8 c5 ff ff ff       	call   800880 <strcpy>
	return dst;
}
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	eb 0f                	jmp    8008e5 <strncpy+0x23>
		*dst++ = *src;
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008df:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	39 da                	cmp    %ebx,%edx
  8008e7:	75 ed                	jne    8008d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8008fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ff:	85 d2                	test   %edx,%edx
  800901:	74 21                	je     800924 <strlcpy+0x35>
  800903:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800907:	89 f2                	mov    %esi,%edx
  800909:	eb 09                	jmp    800914 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	83 c1 01             	add    $0x1,%ecx
  800911:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800914:	39 c2                	cmp    %eax,%edx
  800916:	74 09                	je     800921 <strlcpy+0x32>
  800918:	0f b6 19             	movzbl (%ecx),%ebx
  80091b:	84 db                	test   %bl,%bl
  80091d:	75 ec                	jne    80090b <strlcpy+0x1c>
  80091f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800921:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800924:	29 f0                	sub    %esi,%eax
}
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800933:	eb 06                	jmp    80093b <strcmp+0x11>
		p++, q++;
  800935:	83 c1 01             	add    $0x1,%ecx
  800938:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093b:	0f b6 01             	movzbl (%ecx),%eax
  80093e:	84 c0                	test   %al,%al
  800940:	74 04                	je     800946 <strcmp+0x1c>
  800942:	3a 02                	cmp    (%edx),%al
  800944:	74 ef                	je     800935 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800946:	0f b6 c0             	movzbl %al,%eax
  800949:	0f b6 12             	movzbl (%edx),%edx
  80094c:	29 d0                	sub    %edx,%eax
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	89 c3                	mov    %eax,%ebx
  80095c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095f:	eb 06                	jmp    800967 <strncmp+0x17>
		n--, p++, q++;
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800967:	39 d8                	cmp    %ebx,%eax
  800969:	74 15                	je     800980 <strncmp+0x30>
  80096b:	0f b6 08             	movzbl (%eax),%ecx
  80096e:	84 c9                	test   %cl,%cl
  800970:	74 04                	je     800976 <strncmp+0x26>
  800972:	3a 0a                	cmp    (%edx),%cl
  800974:	74 eb                	je     800961 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 00             	movzbl (%eax),%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
  80097e:	eb 05                	jmp    800985 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800985:	5b                   	pop    %ebx
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800992:	eb 07                	jmp    80099b <strchr+0x13>
		if (*s == c)
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 0f                	je     8009a7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	84 d2                	test   %dl,%dl
  8009a0:	75 f2                	jne    800994 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b3:	eb 03                	jmp    8009b8 <strfind+0xf>
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009bb:	38 ca                	cmp    %cl,%dl
  8009bd:	74 04                	je     8009c3 <strfind+0x1a>
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	75 f2                	jne    8009b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d1:	85 c9                	test   %ecx,%ecx
  8009d3:	74 36                	je     800a0b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009db:	75 28                	jne    800a05 <memset+0x40>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 23                	jne    800a05 <memset+0x40>
		c &= 0xFF;
  8009e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e6:	89 d3                	mov    %edx,%ebx
  8009e8:	c1 e3 08             	shl    $0x8,%ebx
  8009eb:	89 d6                	mov    %edx,%esi
  8009ed:	c1 e6 18             	shl    $0x18,%esi
  8009f0:	89 d0                	mov    %edx,%eax
  8009f2:	c1 e0 10             	shl    $0x10,%eax
  8009f5:	09 f0                	or     %esi,%eax
  8009f7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009f9:	89 d8                	mov    %ebx,%eax
  8009fb:	09 d0                	or     %edx,%eax
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
  800a00:	fc                   	cld    
  800a01:	f3 ab                	rep stos %eax,%es:(%edi)
  800a03:	eb 06                	jmp    800a0b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	fc                   	cld    
  800a09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0b:	89 f8                	mov    %edi,%eax
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a20:	39 c6                	cmp    %eax,%esi
  800a22:	73 35                	jae    800a59 <memmove+0x47>
  800a24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	73 2e                	jae    800a59 <memmove+0x47>
		s += n;
		d += n;
  800a2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	89 d6                	mov    %edx,%esi
  800a30:	09 fe                	or     %edi,%esi
  800a32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a38:	75 13                	jne    800a4d <memmove+0x3b>
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 0e                	jne    800a4d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a3f:	83 ef 04             	sub    $0x4,%edi
  800a42:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a45:	c1 e9 02             	shr    $0x2,%ecx
  800a48:	fd                   	std    
  800a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4b:	eb 09                	jmp    800a56 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4d:	83 ef 01             	sub    $0x1,%edi
  800a50:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a53:	fd                   	std    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a56:	fc                   	cld    
  800a57:	eb 1d                	jmp    800a76 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a59:	89 f2                	mov    %esi,%edx
  800a5b:	09 c2                	or     %eax,%edx
  800a5d:	f6 c2 03             	test   $0x3,%dl
  800a60:	75 0f                	jne    800a71 <memmove+0x5f>
  800a62:	f6 c1 03             	test   $0x3,%cl
  800a65:	75 0a                	jne    800a71 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	89 c7                	mov    %eax,%edi
  800a6c:	fc                   	cld    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 05                	jmp    800a76 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	fc                   	cld    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a7d:	ff 75 10             	pushl  0x10(%ebp)
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	ff 75 08             	pushl  0x8(%ebp)
  800a86:	e8 87 ff ff ff       	call   800a12 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9f:	0f b6 08             	movzbl (%eax),%ecx
  800aa2:	0f b6 1a             	movzbl (%edx),%ebx
  800aa5:	38 d9                	cmp    %bl,%cl
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c1             	movzbl %cl,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
		s1++, s2++;
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab9:	39 f0                	cmp    %esi,%eax
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	53                   	push   %ebx
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acd:	89 c1                	mov    %eax,%ecx
  800acf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad6:	eb 0a                	jmp    800ae2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad8:	0f b6 10             	movzbl (%eax),%edx
  800adb:	39 da                	cmp    %ebx,%edx
  800add:	74 07                	je     800ae6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adf:	83 c0 01             	add    $0x1,%eax
  800ae2:	39 c8                	cmp    %ecx,%eax
  800ae4:	72 f2                	jb     800ad8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af5:	eb 03                	jmp    800afa <strtol+0x11>
		s++;
  800af7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	0f b6 01             	movzbl (%ecx),%eax
  800afd:	3c 20                	cmp    $0x20,%al
  800aff:	74 f6                	je     800af7 <strtol+0xe>
  800b01:	3c 09                	cmp    $0x9,%al
  800b03:	74 f2                	je     800af7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b05:	3c 2b                	cmp    $0x2b,%al
  800b07:	75 0a                	jne    800b13 <strtol+0x2a>
		s++;
  800b09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b11:	eb 11                	jmp    800b24 <strtol+0x3b>
  800b13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b18:	3c 2d                	cmp    $0x2d,%al
  800b1a:	75 08                	jne    800b24 <strtol+0x3b>
		s++, neg = 1;
  800b1c:	83 c1 01             	add    $0x1,%ecx
  800b1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2a:	75 15                	jne    800b41 <strtol+0x58>
  800b2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2f:	75 10                	jne    800b41 <strtol+0x58>
  800b31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b35:	75 7c                	jne    800bb3 <strtol+0xca>
		s += 2, base = 16;
  800b37:	83 c1 02             	add    $0x2,%ecx
  800b3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3f:	eb 16                	jmp    800b57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	75 12                	jne    800b57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4d:	75 08                	jne    800b57 <strtol+0x6e>
		s++, base = 8;
  800b4f:	83 c1 01             	add    $0x1,%ecx
  800b52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5f:	0f b6 11             	movzbl (%ecx),%edx
  800b62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 09             	cmp    $0x9,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0x8b>
			dig = *s - '0';
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	83 ea 30             	sub    $0x30,%edx
  800b72:	eb 22                	jmp    800b96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 19             	cmp    $0x19,%bl
  800b7c:	77 08                	ja     800b86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b7e:	0f be d2             	movsbl %dl,%edx
  800b81:	83 ea 57             	sub    $0x57,%edx
  800b84:	eb 10                	jmp    800b96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 16                	ja     800ba6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b90:	0f be d2             	movsbl %dl,%edx
  800b93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b99:	7d 0b                	jge    800ba6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ba4:	eb b9                	jmp    800b5f <strtol+0x76>

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 0d                	je     800bb9 <strtol+0xd0>
		*endptr = (char *) s;
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	89 0e                	mov    %ecx,(%esi)
  800bb1:	eb 06                	jmp    800bb9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb3:	85 db                	test   %ebx,%ebx
  800bb5:	74 98                	je     800b4f <strtol+0x66>
  800bb7:	eb 9e                	jmp    800b57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	f7 da                	neg    %edx
  800bbd:	85 ff                	test   %edi,%edi
  800bbf:	0f 45 c2             	cmovne %edx,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	89 c3                	mov    %eax,%ebx
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	89 c6                	mov    %eax,%esi
  800bde:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_cgetc>:

int
sys_cgetc(void)
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
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf5:	89 d1                	mov    %edx,%ecx
  800bf7:	89 d3                	mov    %edx,%ebx
  800bf9:	89 d7                	mov    %edx,%edi
  800bfb:	89 d6                	mov    %edx,%esi
  800bfd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c12:	b8 03 00 00 00       	mov    $0x3,%eax
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 cb                	mov    %ecx,%ebx
  800c1c:	89 cf                	mov    %ecx,%edi
  800c1e:	89 ce                	mov    %ecx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 03                	push   $0x3
  800c2c:	68 1f 2c 80 00       	push   $0x802c1f
  800c31:	6a 23                	push   $0x23
  800c33:	68 3c 2c 80 00       	push   $0x802c3c
  800c38:	e8 e5 f5 ff ff       	call   800222 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 04                	push   $0x4
  800cad:	68 1f 2c 80 00       	push   $0x802c1f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 3c 2c 80 00       	push   $0x802c3c
  800cb9:	e8 64 f5 ff ff       	call   800222 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 05                	push   $0x5
  800cef:	68 1f 2c 80 00       	push   $0x802c1f
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 3c 2c 80 00       	push   $0x802c3c
  800cfb:	e8 22 f5 ff ff       	call   800222 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 06                	push   $0x6
  800d31:	68 1f 2c 80 00       	push   $0x802c1f
  800d36:	6a 23                	push   $0x23
  800d38:	68 3c 2c 80 00       	push   $0x802c3c
  800d3d:	e8 e0 f4 ff ff       	call   800222 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 08                	push   $0x8
  800d73:	68 1f 2c 80 00       	push   $0x802c1f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 3c 2c 80 00       	push   $0x802c3c
  800d7f:	e8 9e f4 ff ff       	call   800222 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 17                	jle    800dc6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 09                	push   $0x9
  800db5:	68 1f 2c 80 00       	push   $0x802c1f
  800dba:	6a 23                	push   $0x23
  800dbc:	68 3c 2c 80 00       	push   $0x802c3c
  800dc1:	e8 5c f4 ff ff       	call   800222 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	89 de                	mov    %ebx,%esi
  800deb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 17                	jle    800e08 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 0a                	push   $0xa
  800df7:	68 1f 2c 80 00       	push   $0x802c1f
  800dfc:	6a 23                	push   $0x23
  800dfe:	68 3c 2c 80 00       	push   $0x802c3c
  800e03:	e8 1a f4 ff ff       	call   800222 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	be 00 00 00 00       	mov    $0x0,%esi
  800e1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 cb                	mov    %ecx,%ebx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	89 ce                	mov    %ecx,%esi
  800e4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 17                	jle    800e6c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	50                   	push   %eax
  800e59:	6a 0d                	push   $0xd
  800e5b:	68 1f 2c 80 00       	push   $0x802c1f
  800e60:	6a 23                	push   $0x23
  800e62:	68 3c 2c 80 00       	push   $0x802c3c
  800e67:	e8 b6 f3 ff ff       	call   800222 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e84:	89 d1                	mov    %edx,%ecx
  800e86:	89 d3                	mov    %edx,%ebx
  800e88:	89 d7                	mov    %edx,%edi
  800e8a:	89 d6                	mov    %edx,%esi
  800e8c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	89 df                	mov    %ebx,%edi
  800eab:	89 de                	mov    %ebx,%esi
  800ead:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ebe:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ec0:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ec4:	74 2e                	je     800ef4 <pgfault+0x40>
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	c1 ea 16             	shr    $0x16,%edx
  800ecb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed2:	f6 c2 01             	test   $0x1,%dl
  800ed5:	74 1d                	je     800ef4 <pgfault+0x40>
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	c1 ea 0c             	shr    $0xc,%edx
  800edc:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ee3:	f6 c1 01             	test   $0x1,%cl
  800ee6:	74 0c                	je     800ef4 <pgfault+0x40>
  800ee8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eef:	f6 c6 08             	test   $0x8,%dh
  800ef2:	75 14                	jne    800f08 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	68 4a 2c 80 00       	push   $0x802c4a
  800efc:	6a 1d                	push   $0x1d
  800efe:	68 5d 2c 80 00       	push   $0x802c5d
  800f03:	e8 1a f3 ff ff       	call   800222 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f0d:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	6a 07                	push   $0x7
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 63 fd ff ff       	call   800c83 <sys_page_alloc>
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 14                	jns    800f3b <pgfault+0x87>
		panic("page alloc failed \n");
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	68 68 2c 80 00       	push   $0x802c68
  800f2f:	6a 28                	push   $0x28
  800f31:	68 5d 2c 80 00       	push   $0x802c5d
  800f36:	e8 e7 f2 ff ff       	call   800222 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	68 00 10 00 00       	push   $0x1000
  800f43:	53                   	push   %ebx
  800f44:	68 00 f0 7f 00       	push   $0x7ff000
  800f49:	e8 2c fb ff ff       	call   800a7a <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800f4e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f55:	53                   	push   %ebx
  800f56:	6a 00                	push   $0x0
  800f58:	68 00 f0 7f 00       	push   $0x7ff000
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 62 fd ff ff       	call   800cc6 <sys_page_map>
  800f64:	83 c4 20             	add    $0x20,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 14                	jns    800f7f <pgfault+0xcb>
        panic("page map failed \n");
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	68 7c 2c 80 00       	push   $0x802c7c
  800f73:	6a 2b                	push   $0x2b
  800f75:	68 5d 2c 80 00       	push   $0x802c5d
  800f7a:	e8 a3 f2 ff ff       	call   800222 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800f7f:	83 ec 08             	sub    $0x8,%esp
  800f82:	68 00 f0 7f 00       	push   $0x7ff000
  800f87:	6a 00                	push   $0x0
  800f89:	e8 7a fd ff ff       	call   800d08 <sys_page_unmap>
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	79 14                	jns    800fa9 <pgfault+0xf5>
        panic("page unmap failed\n");
  800f95:	83 ec 04             	sub    $0x4,%esp
  800f98:	68 8e 2c 80 00       	push   $0x802c8e
  800f9d:	6a 2d                	push   $0x2d
  800f9f:	68 5d 2c 80 00       	push   $0x802c5d
  800fa4:	e8 79 f2 ff ff       	call   800222 <_panic>
	
	//panic("pgfault not implemented");
}
  800fa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fac:	c9                   	leave  
  800fad:	c3                   	ret    

00800fae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800fb7:	68 b4 0e 80 00       	push   $0x800eb4
  800fbc:	e8 a6 13 00 00       	call   802367 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc6:	cd 30                	int    $0x30
  800fc8:	89 c7                	mov    %eax,%edi
  800fca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 12                	jns    800fe6 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800fd4:	50                   	push   %eax
  800fd5:	68 a1 2c 80 00       	push   $0x802ca1
  800fda:	6a 7a                	push   $0x7a
  800fdc:	68 5d 2c 80 00       	push   $0x802c5d
  800fe1:	e8 3c f2 ff ff       	call   800222 <_panic>
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800feb:	85 c0                	test   %eax,%eax
  800fed:	75 21                	jne    801010 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fef:	e8 51 fc ff ff       	call   800c45 <sys_getenvid>
  800ff4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ffc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801001:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
  80100b:	e9 91 01 00 00       	jmp    8011a1 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  801010:	89 d8                	mov    %ebx,%eax
  801012:	c1 e8 16             	shr    $0x16,%eax
  801015:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101c:	a8 01                	test   $0x1,%al
  80101e:	0f 84 06 01 00 00    	je     80112a <fork+0x17c>
  801024:	89 d8                	mov    %ebx,%eax
  801026:	c1 e8 0c             	shr    $0xc,%eax
  801029:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801030:	f6 c2 01             	test   $0x1,%dl
  801033:	0f 84 f1 00 00 00    	je     80112a <fork+0x17c>
  801039:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801040:	f6 c2 04             	test   $0x4,%dl
  801043:	0f 84 e1 00 00 00    	je     80112a <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801049:	89 c6                	mov    %eax,%esi
  80104b:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  80104e:	89 f2                	mov    %esi,%edx
  801050:	c1 ea 16             	shr    $0x16,%edx
  801053:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  80105a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  801061:	f6 c6 04             	test   $0x4,%dh
  801064:	74 39                	je     80109f <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801066:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	25 07 0e 00 00       	and    $0xe07,%eax
  801075:	50                   	push   %eax
  801076:	56                   	push   %esi
  801077:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107a:	56                   	push   %esi
  80107b:	6a 00                	push   $0x0
  80107d:	e8 44 fc ff ff       	call   800cc6 <sys_page_map>
  801082:	83 c4 20             	add    $0x20,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	0f 89 9d 00 00 00    	jns    80112a <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  80108d:	50                   	push   %eax
  80108e:	68 f8 2c 80 00       	push   $0x802cf8
  801093:	6a 4b                	push   $0x4b
  801095:	68 5d 2c 80 00       	push   $0x802c5d
  80109a:	e8 83 f1 ff ff       	call   800222 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  80109f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8010a5:	74 59                	je     801100 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	68 05 08 00 00       	push   $0x805
  8010af:	56                   	push   %esi
  8010b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b3:	56                   	push   %esi
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 0b fc ff ff       	call   800cc6 <sys_page_map>
  8010bb:	83 c4 20             	add    $0x20,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	79 12                	jns    8010d4 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  8010c2:	50                   	push   %eax
  8010c3:	68 28 2d 80 00       	push   $0x802d28
  8010c8:	6a 50                	push   $0x50
  8010ca:	68 5d 2c 80 00       	push   $0x802c5d
  8010cf:	e8 4e f1 ff ff       	call   800222 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	68 05 08 00 00       	push   $0x805
  8010dc:	56                   	push   %esi
  8010dd:	6a 00                	push   $0x0
  8010df:	56                   	push   %esi
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 df fb ff ff       	call   800cc6 <sys_page_map>
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 3c                	jns    80112a <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  8010ee:	50                   	push   %eax
  8010ef:	68 50 2d 80 00       	push   $0x802d50
  8010f4:	6a 53                	push   $0x53
  8010f6:	68 5d 2c 80 00       	push   $0x802c5d
  8010fb:	e8 22 f1 ff ff       	call   800222 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	6a 05                	push   $0x5
  801105:	56                   	push   %esi
  801106:	ff 75 e4             	pushl  -0x1c(%ebp)
  801109:	56                   	push   %esi
  80110a:	6a 00                	push   $0x0
  80110c:	e8 b5 fb ff ff       	call   800cc6 <sys_page_map>
  801111:	83 c4 20             	add    $0x20,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	79 12                	jns    80112a <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  801118:	50                   	push   %eax
  801119:	68 78 2d 80 00       	push   $0x802d78
  80111e:	6a 58                	push   $0x58
  801120:	68 5d 2c 80 00       	push   $0x802c5d
  801125:	e8 f8 f0 ff ff       	call   800222 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80112a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801130:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801136:	0f 85 d4 fe ff ff    	jne    801010 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	6a 07                	push   $0x7
  801141:	68 00 f0 bf ee       	push   $0xeebff000
  801146:	57                   	push   %edi
  801147:	e8 37 fb ff ff       	call   800c83 <sys_page_alloc>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 17                	jns    80116a <fork+0x1bc>
        panic("page alloc failed\n");
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	68 b3 2c 80 00       	push   $0x802cb3
  80115b:	68 87 00 00 00       	push   $0x87
  801160:	68 5d 2c 80 00       	push   $0x802c5d
  801165:	e8 b8 f0 ff ff       	call   800222 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	68 d6 23 80 00       	push   $0x8023d6
  801172:	57                   	push   %edi
  801173:	e8 56 fc ff ff       	call   800dce <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	6a 02                	push   $0x2
  80117d:	57                   	push   %edi
  80117e:	e8 c7 fb ff ff       	call   800d4a <sys_env_set_status>
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	85 c0                	test   %eax,%eax
  801188:	79 15                	jns    80119f <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80118a:	50                   	push   %eax
  80118b:	68 c6 2c 80 00       	push   $0x802cc6
  801190:	68 8c 00 00 00       	push   $0x8c
  801195:	68 5d 2c 80 00       	push   $0x802c5d
  80119a:	e8 83 f0 ff ff       	call   800222 <_panic>

	return envid;
  80119f:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011af:	68 df 2c 80 00       	push   $0x802cdf
  8011b4:	68 98 00 00 00       	push   $0x98
  8011b9:	68 5d 2c 80 00       	push   $0x802c5d
  8011be:	e8 5f f0 ff ff       	call   800222 <_panic>

008011c3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ce:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	c1 ea 16             	shr    $0x16,%edx
  8011fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801201:	f6 c2 01             	test   $0x1,%dl
  801204:	74 11                	je     801217 <fd_alloc+0x2d>
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 0c             	shr    $0xc,%edx
  80120b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	75 09                	jne    801220 <fd_alloc+0x36>
			*fd_store = fd;
  801217:	89 01                	mov    %eax,(%ecx)
			return 0;
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	eb 17                	jmp    801237 <fd_alloc+0x4d>
  801220:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801225:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122a:	75 c9                	jne    8011f5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80122c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801232:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123f:	83 f8 1f             	cmp    $0x1f,%eax
  801242:	77 36                	ja     80127a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801244:	c1 e0 0c             	shl    $0xc,%eax
  801247:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 ea 16             	shr    $0x16,%edx
  801251:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801258:	f6 c2 01             	test   $0x1,%dl
  80125b:	74 24                	je     801281 <fd_lookup+0x48>
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 0c             	shr    $0xc,%edx
  801262:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 1a                	je     801288 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801271:	89 02                	mov    %eax,(%edx)
	return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	eb 13                	jmp    80128d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127f:	eb 0c                	jmp    80128d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801286:	eb 05                	jmp    80128d <fd_lookup+0x54>
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801298:	ba 20 2e 80 00       	mov    $0x802e20,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80129d:	eb 13                	jmp    8012b2 <dev_lookup+0x23>
  80129f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012a2:	39 08                	cmp    %ecx,(%eax)
  8012a4:	75 0c                	jne    8012b2 <dev_lookup+0x23>
			*dev = devtab[i];
  8012a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b0:	eb 2e                	jmp    8012e0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b2:	8b 02                	mov    (%edx),%eax
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	75 e7                	jne    80129f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b8:	a1 20 44 80 00       	mov    0x804420,%eax
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	51                   	push   %ecx
  8012c4:	50                   	push   %eax
  8012c5:	68 a4 2d 80 00       	push   $0x802da4
  8012ca:	e8 2c f0 ff ff       	call   8002fb <cprintf>
	*dev = 0;
  8012cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 10             	sub    $0x10,%esp
  8012ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012fa:	c1 e8 0c             	shr    $0xc,%eax
  8012fd:	50                   	push   %eax
  8012fe:	e8 36 ff ff ff       	call   801239 <fd_lookup>
  801303:	83 c4 08             	add    $0x8,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 05                	js     80130f <fd_close+0x2d>
	    || fd != fd2)
  80130a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80130d:	74 0c                	je     80131b <fd_close+0x39>
		return (must_exist ? r : 0);
  80130f:	84 db                	test   %bl,%bl
  801311:	ba 00 00 00 00       	mov    $0x0,%edx
  801316:	0f 44 c2             	cmove  %edx,%eax
  801319:	eb 41                	jmp    80135c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 36                	pushl  (%esi)
  801324:	e8 66 ff ff ff       	call   80128f <dev_lookup>
  801329:	89 c3                	mov    %eax,%ebx
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 1a                	js     80134c <fd_close+0x6a>
		if (dev->dev_close)
  801332:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801335:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801338:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80133d:	85 c0                	test   %eax,%eax
  80133f:	74 0b                	je     80134c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	56                   	push   %esi
  801345:	ff d0                	call   *%eax
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	56                   	push   %esi
  801350:	6a 00                	push   $0x0
  801352:	e8 b1 f9 ff ff       	call   800d08 <sys_page_unmap>
	return r;
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	89 d8                	mov    %ebx,%eax
}
  80135c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 c4 fe ff ff       	call   801239 <fd_lookup>
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 10                	js     80138c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	6a 01                	push   $0x1
  801381:	ff 75 f4             	pushl  -0xc(%ebp)
  801384:	e8 59 ff ff ff       	call   8012e2 <fd_close>
  801389:	83 c4 10             	add    $0x10,%esp
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <close_all>:

void
close_all(void)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801395:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	53                   	push   %ebx
  80139e:	e8 c0 ff ff ff       	call   801363 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a3:	83 c3 01             	add    $0x1,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	83 fb 20             	cmp    $0x20,%ebx
  8013ac:	75 ec                	jne    80139a <close_all+0xc>
		close(i);
}
  8013ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 2c             	sub    $0x2c,%esp
  8013bc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 6e fe ff ff       	call   801239 <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	0f 88 c1 00 00 00    	js     801497 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	56                   	push   %esi
  8013da:	e8 84 ff ff ff       	call   801363 <close>

	newfd = INDEX2FD(newfdnum);
  8013df:	89 f3                	mov    %esi,%ebx
  8013e1:	c1 e3 0c             	shl    $0xc,%ebx
  8013e4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013ea:	83 c4 04             	add    $0x4,%esp
  8013ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f0:	e8 de fd ff ff       	call   8011d3 <fd2data>
  8013f5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f7:	89 1c 24             	mov    %ebx,(%esp)
  8013fa:	e8 d4 fd ff ff       	call   8011d3 <fd2data>
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801405:	89 f8                	mov    %edi,%eax
  801407:	c1 e8 16             	shr    $0x16,%eax
  80140a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801411:	a8 01                	test   $0x1,%al
  801413:	74 37                	je     80144c <dup+0x99>
  801415:	89 f8                	mov    %edi,%eax
  801417:	c1 e8 0c             	shr    $0xc,%eax
  80141a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801421:	f6 c2 01             	test   $0x1,%dl
  801424:	74 26                	je     80144c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801426:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	25 07 0e 00 00       	and    $0xe07,%eax
  801435:	50                   	push   %eax
  801436:	ff 75 d4             	pushl  -0x2c(%ebp)
  801439:	6a 00                	push   $0x0
  80143b:	57                   	push   %edi
  80143c:	6a 00                	push   $0x0
  80143e:	e8 83 f8 ff ff       	call   800cc6 <sys_page_map>
  801443:	89 c7                	mov    %eax,%edi
  801445:	83 c4 20             	add    $0x20,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 2e                	js     80147a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144f:	89 d0                	mov    %edx,%eax
  801451:	c1 e8 0c             	shr    $0xc,%eax
  801454:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	25 07 0e 00 00       	and    $0xe07,%eax
  801463:	50                   	push   %eax
  801464:	53                   	push   %ebx
  801465:	6a 00                	push   $0x0
  801467:	52                   	push   %edx
  801468:	6a 00                	push   $0x0
  80146a:	e8 57 f8 ff ff       	call   800cc6 <sys_page_map>
  80146f:	89 c7                	mov    %eax,%edi
  801471:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801474:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801476:	85 ff                	test   %edi,%edi
  801478:	79 1d                	jns    801497 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	53                   	push   %ebx
  80147e:	6a 00                	push   $0x0
  801480:	e8 83 f8 ff ff       	call   800d08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148b:	6a 00                	push   $0x0
  80148d:	e8 76 f8 ff ff       	call   800d08 <sys_page_unmap>
	return r;
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	89 f8                	mov    %edi,%eax
}
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 14             	sub    $0x14,%esp
  8014a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	53                   	push   %ebx
  8014ae:	e8 86 fd ff ff       	call   801239 <fd_lookup>
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 6d                	js     801529 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c6:	ff 30                	pushl  (%eax)
  8014c8:	e8 c2 fd ff ff       	call   80128f <dev_lookup>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 4c                	js     801520 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d7:	8b 42 08             	mov    0x8(%edx),%eax
  8014da:	83 e0 03             	and    $0x3,%eax
  8014dd:	83 f8 01             	cmp    $0x1,%eax
  8014e0:	75 21                	jne    801503 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e2:	a1 20 44 80 00       	mov    0x804420,%eax
  8014e7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	50                   	push   %eax
  8014ef:	68 e5 2d 80 00       	push   $0x802de5
  8014f4:	e8 02 ee ff ff       	call   8002fb <cprintf>
		return -E_INVAL;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801501:	eb 26                	jmp    801529 <read+0x8a>
	}
	if (!dev->dev_read)
  801503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801506:	8b 40 08             	mov    0x8(%eax),%eax
  801509:	85 c0                	test   %eax,%eax
  80150b:	74 17                	je     801524 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	ff 75 10             	pushl  0x10(%ebp)
  801513:	ff 75 0c             	pushl  0xc(%ebp)
  801516:	52                   	push   %edx
  801517:	ff d0                	call   *%eax
  801519:	89 c2                	mov    %eax,%edx
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	eb 09                	jmp    801529 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	89 c2                	mov    %eax,%edx
  801522:	eb 05                	jmp    801529 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801524:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801529:	89 d0                	mov    %edx,%eax
  80152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	8b 7d 08             	mov    0x8(%ebp),%edi
  80153c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801544:	eb 21                	jmp    801567 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	89 f0                	mov    %esi,%eax
  80154b:	29 d8                	sub    %ebx,%eax
  80154d:	50                   	push   %eax
  80154e:	89 d8                	mov    %ebx,%eax
  801550:	03 45 0c             	add    0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	57                   	push   %edi
  801555:	e8 45 ff ff ff       	call   80149f <read>
		if (m < 0)
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 10                	js     801571 <readn+0x41>
			return m;
		if (m == 0)
  801561:	85 c0                	test   %eax,%eax
  801563:	74 0a                	je     80156f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801565:	01 c3                	add    %eax,%ebx
  801567:	39 f3                	cmp    %esi,%ebx
  801569:	72 db                	jb     801546 <readn+0x16>
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	eb 02                	jmp    801571 <readn+0x41>
  80156f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	53                   	push   %ebx
  80157d:	83 ec 14             	sub    $0x14,%esp
  801580:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801583:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	53                   	push   %ebx
  801588:	e8 ac fc ff ff       	call   801239 <fd_lookup>
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	89 c2                	mov    %eax,%edx
  801592:	85 c0                	test   %eax,%eax
  801594:	78 68                	js     8015fe <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a0:	ff 30                	pushl  (%eax)
  8015a2:	e8 e8 fc ff ff       	call   80128f <dev_lookup>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 47                	js     8015f5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b5:	75 21                	jne    8015d8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b7:	a1 20 44 80 00       	mov    0x804420,%eax
  8015bc:	8b 40 48             	mov    0x48(%eax),%eax
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	50                   	push   %eax
  8015c4:	68 01 2e 80 00       	push   $0x802e01
  8015c9:	e8 2d ed ff ff       	call   8002fb <cprintf>
		return -E_INVAL;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d6:	eb 26                	jmp    8015fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015db:	8b 52 0c             	mov    0xc(%edx),%edx
  8015de:	85 d2                	test   %edx,%edx
  8015e0:	74 17                	je     8015f9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e2:	83 ec 04             	sub    $0x4,%esp
  8015e5:	ff 75 10             	pushl  0x10(%ebp)
  8015e8:	ff 75 0c             	pushl  0xc(%ebp)
  8015eb:	50                   	push   %eax
  8015ec:	ff d2                	call   *%edx
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 09                	jmp    8015fe <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	eb 05                	jmp    8015fe <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015fe:	89 d0                	mov    %edx,%eax
  801600:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <seek>:

int
seek(int fdnum, off_t offset)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	ff 75 08             	pushl  0x8(%ebp)
  801612:	e8 22 fc ff ff       	call   801239 <fd_lookup>
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 0e                	js     80162c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80161e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801621:	8b 55 0c             	mov    0xc(%ebp),%edx
  801624:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801627:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	83 ec 14             	sub    $0x14,%esp
  801635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	53                   	push   %ebx
  80163d:	e8 f7 fb ff ff       	call   801239 <fd_lookup>
  801642:	83 c4 08             	add    $0x8,%esp
  801645:	89 c2                	mov    %eax,%edx
  801647:	85 c0                	test   %eax,%eax
  801649:	78 65                	js     8016b0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	ff 30                	pushl  (%eax)
  801657:	e8 33 fc ff ff       	call   80128f <dev_lookup>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 44                	js     8016a7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166a:	75 21                	jne    80168d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80166c:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801671:	8b 40 48             	mov    0x48(%eax),%eax
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	53                   	push   %ebx
  801678:	50                   	push   %eax
  801679:	68 c4 2d 80 00       	push   $0x802dc4
  80167e:	e8 78 ec ff ff       	call   8002fb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80168b:	eb 23                	jmp    8016b0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80168d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801690:	8b 52 18             	mov    0x18(%edx),%edx
  801693:	85 d2                	test   %edx,%edx
  801695:	74 14                	je     8016ab <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	ff d2                	call   *%edx
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb 09                	jmp    8016b0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	eb 05                	jmp    8016b0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016b0:	89 d0                	mov    %edx,%eax
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 14             	sub    $0x14,%esp
  8016be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 08             	pushl  0x8(%ebp)
  8016c8:	e8 6c fb ff ff       	call   801239 <fd_lookup>
  8016cd:	83 c4 08             	add    $0x8,%esp
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 58                	js     80172e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	ff 30                	pushl  (%eax)
  8016e2:	e8 a8 fb ff ff       	call   80128f <dev_lookup>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 37                	js     801725 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f5:	74 32                	je     801729 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801701:	00 00 00 
	stat->st_isdir = 0;
  801704:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80170b:	00 00 00 
	stat->st_dev = dev;
  80170e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	53                   	push   %ebx
  801718:	ff 75 f0             	pushl  -0x10(%ebp)
  80171b:	ff 50 14             	call   *0x14(%eax)
  80171e:	89 c2                	mov    %eax,%edx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 09                	jmp    80172e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	89 c2                	mov    %eax,%edx
  801727:	eb 05                	jmp    80172e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801729:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80172e:	89 d0                	mov    %edx,%eax
  801730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	6a 00                	push   $0x0
  80173f:	ff 75 08             	pushl  0x8(%ebp)
  801742:	e8 e7 01 00 00       	call   80192e <open>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 1b                	js     80176b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	ff 75 0c             	pushl  0xc(%ebp)
  801756:	50                   	push   %eax
  801757:	e8 5b ff ff ff       	call   8016b7 <fstat>
  80175c:	89 c6                	mov    %eax,%esi
	close(fd);
  80175e:	89 1c 24             	mov    %ebx,(%esp)
  801761:	e8 fd fb ff ff       	call   801363 <close>
	return r;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	89 f0                	mov    %esi,%eax
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	89 c6                	mov    %eax,%esi
  801779:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80177b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801782:	75 12                	jne    801796 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801784:	83 ec 0c             	sub    $0xc,%esp
  801787:	6a 01                	push   $0x1
  801789:	e8 2d 0d 00 00       	call   8024bb <ipc_find_env>
  80178e:	a3 00 40 80 00       	mov    %eax,0x804000
  801793:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801796:	6a 07                	push   $0x7
  801798:	68 00 50 80 00       	push   $0x805000
  80179d:	56                   	push   %esi
  80179e:	ff 35 00 40 80 00    	pushl  0x804000
  8017a4:	e8 be 0c 00 00       	call   802467 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a9:	83 c4 0c             	add    $0xc,%esp
  8017ac:	6a 00                	push   $0x0
  8017ae:	53                   	push   %ebx
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 44 0c 00 00       	call   8023fa <ipc_recv>
}
  8017b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e0:	e8 8d ff ff ff       	call   801772 <fsipc>
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801802:	e8 6b ff ff ff       	call   801772 <fsipc>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 40 0c             	mov    0xc(%eax),%eax
  801819:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	b8 05 00 00 00       	mov    $0x5,%eax
  801828:	e8 45 ff ff ff       	call   801772 <fsipc>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 2c                	js     80185d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	68 00 50 80 00       	push   $0x805000
  801839:	53                   	push   %ebx
  80183a:	e8 41 f0 ff ff       	call   800880 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183f:	a1 80 50 80 00       	mov    0x805080,%eax
  801844:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184a:	a1 84 50 80 00       	mov    0x805084,%eax
  80184f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	53                   	push   %ebx
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80186c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801871:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801876:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801879:	53                   	push   %ebx
  80187a:	ff 75 0c             	pushl  0xc(%ebp)
  80187d:	68 08 50 80 00       	push   $0x805008
  801882:	e8 8b f1 ff ff       	call   800a12 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
  80188d:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801892:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a2:	e8 cb fe ff ff       	call   801772 <fsipc>
	//panic("devfile_write not implemented");
}
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018bf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8018cf:	e8 9e fe ff ff       	call   801772 <fsipc>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 4b                	js     801925 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018da:	39 c6                	cmp    %eax,%esi
  8018dc:	73 16                	jae    8018f4 <devfile_read+0x48>
  8018de:	68 34 2e 80 00       	push   $0x802e34
  8018e3:	68 3b 2e 80 00       	push   $0x802e3b
  8018e8:	6a 7c                	push   $0x7c
  8018ea:	68 50 2e 80 00       	push   $0x802e50
  8018ef:	e8 2e e9 ff ff       	call   800222 <_panic>
	assert(r <= PGSIZE);
  8018f4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f9:	7e 16                	jle    801911 <devfile_read+0x65>
  8018fb:	68 5b 2e 80 00       	push   $0x802e5b
  801900:	68 3b 2e 80 00       	push   $0x802e3b
  801905:	6a 7d                	push   $0x7d
  801907:	68 50 2e 80 00       	push   $0x802e50
  80190c:	e8 11 e9 ff ff       	call   800222 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	50                   	push   %eax
  801915:	68 00 50 80 00       	push   $0x805000
  80191a:	ff 75 0c             	pushl  0xc(%ebp)
  80191d:	e8 f0 f0 ff ff       	call   800a12 <memmove>
	return r;
  801922:	83 c4 10             	add    $0x10,%esp
}
  801925:	89 d8                	mov    %ebx,%eax
  801927:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 20             	sub    $0x20,%esp
  801935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801938:	53                   	push   %ebx
  801939:	e8 09 ef ff ff       	call   800847 <strlen>
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801946:	7f 67                	jg     8019af <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194e:	50                   	push   %eax
  80194f:	e8 96 f8 ff ff       	call   8011ea <fd_alloc>
  801954:	83 c4 10             	add    $0x10,%esp
		return r;
  801957:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 57                	js     8019b4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	53                   	push   %ebx
  801961:	68 00 50 80 00       	push   $0x805000
  801966:	e8 15 ef ff ff       	call   800880 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801973:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801976:	b8 01 00 00 00       	mov    $0x1,%eax
  80197b:	e8 f2 fd ff ff       	call   801772 <fsipc>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	79 14                	jns    80199d <open+0x6f>
		fd_close(fd, 0);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	6a 00                	push   $0x0
  80198e:	ff 75 f4             	pushl  -0xc(%ebp)
  801991:	e8 4c f9 ff ff       	call   8012e2 <fd_close>
		return r;
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	89 da                	mov    %ebx,%edx
  80199b:	eb 17                	jmp    8019b4 <open+0x86>
	}

	return fd2num(fd);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a3:	e8 1b f8 ff ff       	call   8011c3 <fd2num>
  8019a8:	89 c2                	mov    %eax,%edx
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	eb 05                	jmp    8019b4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019af:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b4:	89 d0                	mov    %edx,%eax
  8019b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019cb:	e8 a2 fd ff ff       	call   801772 <fsipc>
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019d8:	68 67 2e 80 00       	push   $0x802e67
  8019dd:	ff 75 0c             	pushl  0xc(%ebp)
  8019e0:	e8 9b ee ff ff       	call   800880 <strcpy>
	return 0;
}
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 10             	sub    $0x10,%esp
  8019f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f6:	53                   	push   %ebx
  8019f7:	e8 f8 0a 00 00       	call   8024f4 <pageref>
  8019fc:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a04:	83 f8 01             	cmp    $0x1,%eax
  801a07:	75 10                	jne    801a19 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 73 0c             	pushl  0xc(%ebx)
  801a0f:	e8 c0 02 00 00       	call   801cd4 <nsipc_close>
  801a14:	89 c2                	mov    %eax,%edx
  801a16:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a19:	89 d0                	mov    %edx,%eax
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a26:	6a 00                	push   $0x0
  801a28:	ff 75 10             	pushl  0x10(%ebp)
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	ff 70 0c             	pushl  0xc(%eax)
  801a34:	e8 78 03 00 00       	call   801db1 <nsipc_send>
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a41:	6a 00                	push   $0x0
  801a43:	ff 75 10             	pushl  0x10(%ebp)
  801a46:	ff 75 0c             	pushl  0xc(%ebp)
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	ff 70 0c             	pushl  0xc(%eax)
  801a4f:	e8 f1 02 00 00       	call   801d45 <nsipc_recv>
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a5c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a5f:	52                   	push   %edx
  801a60:	50                   	push   %eax
  801a61:	e8 d3 f7 ff ff       	call   801239 <fd_lookup>
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 17                	js     801a84 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a70:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a76:	39 08                	cmp    %ecx,(%eax)
  801a78:	75 05                	jne    801a7f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7d:	eb 05                	jmp    801a84 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 1c             	sub    $0x1c,%esp
  801a8e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a93:	50                   	push   %eax
  801a94:	e8 51 f7 ff ff       	call   8011ea <fd_alloc>
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 1b                	js     801abd <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	68 07 04 00 00       	push   $0x407
  801aaa:	ff 75 f4             	pushl  -0xc(%ebp)
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 cf f1 ff ff       	call   800c83 <sys_page_alloc>
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	79 10                	jns    801acd <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	56                   	push   %esi
  801ac1:	e8 0e 02 00 00       	call   801cd4 <nsipc_close>
		return r;
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	89 d8                	mov    %ebx,%eax
  801acb:	eb 24                	jmp    801af1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801acd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ae2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	50                   	push   %eax
  801ae9:	e8 d5 f6 ff ff       	call   8011c3 <fd2num>
  801aee:	83 c4 10             	add    $0x10,%esp
}
  801af1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	e8 50 ff ff ff       	call   801a56 <fd2sockid>
		return r;
  801b06:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	78 1f                	js     801b2b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b0c:	83 ec 04             	sub    $0x4,%esp
  801b0f:	ff 75 10             	pushl  0x10(%ebp)
  801b12:	ff 75 0c             	pushl  0xc(%ebp)
  801b15:	50                   	push   %eax
  801b16:	e8 12 01 00 00       	call   801c2d <nsipc_accept>
  801b1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b1e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 07                	js     801b2b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b24:	e8 5d ff ff ff       	call   801a86 <alloc_sockfd>
  801b29:	89 c1                	mov    %eax,%ecx
}
  801b2b:	89 c8                	mov    %ecx,%eax
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	e8 19 ff ff ff       	call   801a56 <fd2sockid>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 12                	js     801b53 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b41:	83 ec 04             	sub    $0x4,%esp
  801b44:	ff 75 10             	pushl  0x10(%ebp)
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	50                   	push   %eax
  801b4b:	e8 2d 01 00 00       	call   801c7d <nsipc_bind>
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <shutdown>:

int
shutdown(int s, int how)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	e8 f3 fe ff ff       	call   801a56 <fd2sockid>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 0f                	js     801b76 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	ff 75 0c             	pushl  0xc(%ebp)
  801b6d:	50                   	push   %eax
  801b6e:	e8 3f 01 00 00       	call   801cb2 <nsipc_shutdown>
  801b73:	83 c4 10             	add    $0x10,%esp
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	e8 d0 fe ff ff       	call   801a56 <fd2sockid>
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 12                	js     801b9c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b8a:	83 ec 04             	sub    $0x4,%esp
  801b8d:	ff 75 10             	pushl  0x10(%ebp)
  801b90:	ff 75 0c             	pushl  0xc(%ebp)
  801b93:	50                   	push   %eax
  801b94:	e8 55 01 00 00       	call   801cee <nsipc_connect>
  801b99:	83 c4 10             	add    $0x10,%esp
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <listen>:

int
listen(int s, int backlog)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	e8 aa fe ff ff       	call   801a56 <fd2sockid>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 0f                	js     801bbf <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	ff 75 0c             	pushl  0xc(%ebp)
  801bb6:	50                   	push   %eax
  801bb7:	e8 67 01 00 00       	call   801d23 <nsipc_listen>
  801bbc:	83 c4 10             	add    $0x10,%esp
}
  801bbf:	c9                   	leave  
  801bc0:	c3                   	ret    

00801bc1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bc7:	ff 75 10             	pushl  0x10(%ebp)
  801bca:	ff 75 0c             	pushl  0xc(%ebp)
  801bcd:	ff 75 08             	pushl  0x8(%ebp)
  801bd0:	e8 3a 02 00 00       	call   801e0f <nsipc_socket>
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 05                	js     801be1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bdc:	e8 a5 fe ff ff       	call   801a86 <alloc_sockfd>
}
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	53                   	push   %ebx
  801be7:	83 ec 04             	sub    $0x4,%esp
  801bea:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bec:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bf3:	75 12                	jne    801c07 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bf5:	83 ec 0c             	sub    $0xc,%esp
  801bf8:	6a 02                	push   $0x2
  801bfa:	e8 bc 08 00 00       	call   8024bb <ipc_find_env>
  801bff:	a3 04 40 80 00       	mov    %eax,0x804004
  801c04:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c07:	6a 07                	push   $0x7
  801c09:	68 00 60 80 00       	push   $0x806000
  801c0e:	53                   	push   %ebx
  801c0f:	ff 35 04 40 80 00    	pushl  0x804004
  801c15:	e8 4d 08 00 00       	call   802467 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c1a:	83 c4 0c             	add    $0xc,%esp
  801c1d:	6a 00                	push   $0x0
  801c1f:	6a 00                	push   $0x0
  801c21:	6a 00                	push   $0x0
  801c23:	e8 d2 07 00 00       	call   8023fa <ipc_recv>
}
  801c28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	56                   	push   %esi
  801c31:	53                   	push   %ebx
  801c32:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c3d:	8b 06                	mov    (%esi),%eax
  801c3f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c44:	b8 01 00 00 00       	mov    $0x1,%eax
  801c49:	e8 95 ff ff ff       	call   801be3 <nsipc>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 20                	js     801c74 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	ff 35 10 60 80 00    	pushl  0x806010
  801c5d:	68 00 60 80 00       	push   $0x806000
  801c62:	ff 75 0c             	pushl  0xc(%ebp)
  801c65:	e8 a8 ed ff ff       	call   800a12 <memmove>
		*addrlen = ret->ret_addrlen;
  801c6a:	a1 10 60 80 00       	mov    0x806010,%eax
  801c6f:	89 06                	mov    %eax,(%esi)
  801c71:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5d                   	pop    %ebp
  801c7c:	c3                   	ret    

00801c7d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	53                   	push   %ebx
  801c81:	83 ec 08             	sub    $0x8,%esp
  801c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c8f:	53                   	push   %ebx
  801c90:	ff 75 0c             	pushl  0xc(%ebp)
  801c93:	68 04 60 80 00       	push   $0x806004
  801c98:	e8 75 ed ff ff       	call   800a12 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c9d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ca3:	b8 02 00 00 00       	mov    $0x2,%eax
  801ca8:	e8 36 ff ff ff       	call   801be3 <nsipc>
}
  801cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cc8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ccd:	e8 11 ff ff ff       	call   801be3 <nsipc>
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <nsipc_close>:

int
nsipc_close(int s)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ce2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce7:	e8 f7 fe ff ff       	call   801be3 <nsipc>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d00:	53                   	push   %ebx
  801d01:	ff 75 0c             	pushl  0xc(%ebp)
  801d04:	68 04 60 80 00       	push   $0x806004
  801d09:	e8 04 ed ff ff       	call   800a12 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d0e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d14:	b8 05 00 00 00       	mov    $0x5,%eax
  801d19:	e8 c5 fe ff ff       	call   801be3 <nsipc>
}
  801d1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d34:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d39:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3e:	e8 a0 fe ff ff       	call   801be3 <nsipc>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d55:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d63:	b8 07 00 00 00       	mov    $0x7,%eax
  801d68:	e8 76 fe ff ff       	call   801be3 <nsipc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	78 35                	js     801da8 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d73:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d78:	7f 04                	jg     801d7e <nsipc_recv+0x39>
  801d7a:	39 c6                	cmp    %eax,%esi
  801d7c:	7d 16                	jge    801d94 <nsipc_recv+0x4f>
  801d7e:	68 73 2e 80 00       	push   $0x802e73
  801d83:	68 3b 2e 80 00       	push   $0x802e3b
  801d88:	6a 62                	push   $0x62
  801d8a:	68 88 2e 80 00       	push   $0x802e88
  801d8f:	e8 8e e4 ff ff       	call   800222 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	50                   	push   %eax
  801d98:	68 00 60 80 00       	push   $0x806000
  801d9d:	ff 75 0c             	pushl  0xc(%ebp)
  801da0:	e8 6d ec ff ff       	call   800a12 <memmove>
  801da5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	53                   	push   %ebx
  801db5:	83 ec 04             	sub    $0x4,%esp
  801db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dc3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dc9:	7e 16                	jle    801de1 <nsipc_send+0x30>
  801dcb:	68 94 2e 80 00       	push   $0x802e94
  801dd0:	68 3b 2e 80 00       	push   $0x802e3b
  801dd5:	6a 6d                	push   $0x6d
  801dd7:	68 88 2e 80 00       	push   $0x802e88
  801ddc:	e8 41 e4 ff ff       	call   800222 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801de1:	83 ec 04             	sub    $0x4,%esp
  801de4:	53                   	push   %ebx
  801de5:	ff 75 0c             	pushl  0xc(%ebp)
  801de8:	68 0c 60 80 00       	push   $0x80600c
  801ded:	e8 20 ec ff ff       	call   800a12 <memmove>
	nsipcbuf.send.req_size = size;
  801df2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801df8:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e00:	b8 08 00 00 00       	mov    $0x8,%eax
  801e05:	e8 d9 fd ff ff       	call   801be3 <nsipc>
}
  801e0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
  801e18:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e20:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e25:	8b 45 10             	mov    0x10(%ebp),%eax
  801e28:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  801e32:	e8 ac fd ff ff       	call   801be3 <nsipc>
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 08             	pushl  0x8(%ebp)
  801e47:	e8 87 f3 ff ff       	call   8011d3 <fd2data>
  801e4c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	68 a0 2e 80 00       	push   $0x802ea0
  801e56:	53                   	push   %ebx
  801e57:	e8 24 ea ff ff       	call   800880 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e5c:	8b 46 04             	mov    0x4(%esi),%eax
  801e5f:	2b 06                	sub    (%esi),%eax
  801e61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e6e:	00 00 00 
	stat->st_dev = &devpipe;
  801e71:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e78:	30 80 00 
	return 0;
}
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e91:	53                   	push   %ebx
  801e92:	6a 00                	push   $0x0
  801e94:	e8 6f ee ff ff       	call   800d08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e99:	89 1c 24             	mov    %ebx,(%esp)
  801e9c:	e8 32 f3 ff ff       	call   8011d3 <fd2data>
  801ea1:	83 c4 08             	add    $0x8,%esp
  801ea4:	50                   	push   %eax
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 5c ee ff ff       	call   800d08 <sys_page_unmap>
}
  801eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	57                   	push   %edi
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 1c             	sub    $0x1c,%esp
  801eba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ebd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ebf:	a1 20 44 80 00       	mov    0x804420,%eax
  801ec4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	ff 75 e0             	pushl  -0x20(%ebp)
  801ecd:	e8 22 06 00 00       	call   8024f4 <pageref>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	89 3c 24             	mov    %edi,(%esp)
  801ed7:	e8 18 06 00 00       	call   8024f4 <pageref>
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	39 c3                	cmp    %eax,%ebx
  801ee1:	0f 94 c1             	sete   %cl
  801ee4:	0f b6 c9             	movzbl %cl,%ecx
  801ee7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eea:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ef0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ef3:	39 ce                	cmp    %ecx,%esi
  801ef5:	74 1b                	je     801f12 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ef7:	39 c3                	cmp    %eax,%ebx
  801ef9:	75 c4                	jne    801ebf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801efb:	8b 42 58             	mov    0x58(%edx),%eax
  801efe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f01:	50                   	push   %eax
  801f02:	56                   	push   %esi
  801f03:	68 a7 2e 80 00       	push   $0x802ea7
  801f08:	e8 ee e3 ff ff       	call   8002fb <cprintf>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	eb ad                	jmp    801ebf <_pipeisclosed+0xe>
	}
}
  801f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	57                   	push   %edi
  801f21:	56                   	push   %esi
  801f22:	53                   	push   %ebx
  801f23:	83 ec 28             	sub    $0x28,%esp
  801f26:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f29:	56                   	push   %esi
  801f2a:	e8 a4 f2 ff ff       	call   8011d3 <fd2data>
  801f2f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	bf 00 00 00 00       	mov    $0x0,%edi
  801f39:	eb 4b                	jmp    801f86 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f3b:	89 da                	mov    %ebx,%edx
  801f3d:	89 f0                	mov    %esi,%eax
  801f3f:	e8 6d ff ff ff       	call   801eb1 <_pipeisclosed>
  801f44:	85 c0                	test   %eax,%eax
  801f46:	75 48                	jne    801f90 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f48:	e8 17 ed ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f4d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f50:	8b 0b                	mov    (%ebx),%ecx
  801f52:	8d 51 20             	lea    0x20(%ecx),%edx
  801f55:	39 d0                	cmp    %edx,%eax
  801f57:	73 e2                	jae    801f3b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f5c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f60:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f63:	89 c2                	mov    %eax,%edx
  801f65:	c1 fa 1f             	sar    $0x1f,%edx
  801f68:	89 d1                	mov    %edx,%ecx
  801f6a:	c1 e9 1b             	shr    $0x1b,%ecx
  801f6d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f70:	83 e2 1f             	and    $0x1f,%edx
  801f73:	29 ca                	sub    %ecx,%edx
  801f75:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f79:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f7d:	83 c0 01             	add    $0x1,%eax
  801f80:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f83:	83 c7 01             	add    $0x1,%edi
  801f86:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f89:	75 c2                	jne    801f4d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8e:	eb 05                	jmp    801f95 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 18             	sub    $0x18,%esp
  801fa6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fa9:	57                   	push   %edi
  801faa:	e8 24 f2 ff ff       	call   8011d3 <fd2data>
  801faf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb9:	eb 3d                	jmp    801ff8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fbb:	85 db                	test   %ebx,%ebx
  801fbd:	74 04                	je     801fc3 <devpipe_read+0x26>
				return i;
  801fbf:	89 d8                	mov    %ebx,%eax
  801fc1:	eb 44                	jmp    802007 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fc3:	89 f2                	mov    %esi,%edx
  801fc5:	89 f8                	mov    %edi,%eax
  801fc7:	e8 e5 fe ff ff       	call   801eb1 <_pipeisclosed>
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	75 32                	jne    802002 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fd0:	e8 8f ec ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fd5:	8b 06                	mov    (%esi),%eax
  801fd7:	3b 46 04             	cmp    0x4(%esi),%eax
  801fda:	74 df                	je     801fbb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fdc:	99                   	cltd   
  801fdd:	c1 ea 1b             	shr    $0x1b,%edx
  801fe0:	01 d0                	add    %edx,%eax
  801fe2:	83 e0 1f             	and    $0x1f,%eax
  801fe5:	29 d0                	sub    %edx,%eax
  801fe7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fef:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ff2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff5:	83 c3 01             	add    $0x1,%ebx
  801ff8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ffb:	75 d8                	jne    801fd5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ffd:	8b 45 10             	mov    0x10(%ebp),%eax
  802000:	eb 05                	jmp    802007 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802002:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802017:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201a:	50                   	push   %eax
  80201b:	e8 ca f1 ff ff       	call   8011ea <fd_alloc>
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	89 c2                	mov    %eax,%edx
  802025:	85 c0                	test   %eax,%eax
  802027:	0f 88 2c 01 00 00    	js     802159 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202d:	83 ec 04             	sub    $0x4,%esp
  802030:	68 07 04 00 00       	push   $0x407
  802035:	ff 75 f4             	pushl  -0xc(%ebp)
  802038:	6a 00                	push   $0x0
  80203a:	e8 44 ec ff ff       	call   800c83 <sys_page_alloc>
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	89 c2                	mov    %eax,%edx
  802044:	85 c0                	test   %eax,%eax
  802046:	0f 88 0d 01 00 00    	js     802159 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80204c:	83 ec 0c             	sub    $0xc,%esp
  80204f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802052:	50                   	push   %eax
  802053:	e8 92 f1 ff ff       	call   8011ea <fd_alloc>
  802058:	89 c3                	mov    %eax,%ebx
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	85 c0                	test   %eax,%eax
  80205f:	0f 88 e2 00 00 00    	js     802147 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802065:	83 ec 04             	sub    $0x4,%esp
  802068:	68 07 04 00 00       	push   $0x407
  80206d:	ff 75 f0             	pushl  -0x10(%ebp)
  802070:	6a 00                	push   $0x0
  802072:	e8 0c ec ff ff       	call   800c83 <sys_page_alloc>
  802077:	89 c3                	mov    %eax,%ebx
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	85 c0                	test   %eax,%eax
  80207e:	0f 88 c3 00 00 00    	js     802147 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	ff 75 f4             	pushl  -0xc(%ebp)
  80208a:	e8 44 f1 ff ff       	call   8011d3 <fd2data>
  80208f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802091:	83 c4 0c             	add    $0xc,%esp
  802094:	68 07 04 00 00       	push   $0x407
  802099:	50                   	push   %eax
  80209a:	6a 00                	push   $0x0
  80209c:	e8 e2 eb ff ff       	call   800c83 <sys_page_alloc>
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	0f 88 89 00 00 00    	js     802137 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b4:	e8 1a f1 ff ff       	call   8011d3 <fd2data>
  8020b9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020c0:	50                   	push   %eax
  8020c1:	6a 00                	push   $0x0
  8020c3:	56                   	push   %esi
  8020c4:	6a 00                	push   $0x0
  8020c6:	e8 fb eb ff ff       	call   800cc6 <sys_page_map>
  8020cb:	89 c3                	mov    %eax,%ebx
  8020cd:	83 c4 20             	add    $0x20,%esp
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 55                	js     802129 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020d4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020e9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020fe:	83 ec 0c             	sub    $0xc,%esp
  802101:	ff 75 f4             	pushl  -0xc(%ebp)
  802104:	e8 ba f0 ff ff       	call   8011c3 <fd2num>
  802109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80210e:	83 c4 04             	add    $0x4,%esp
  802111:	ff 75 f0             	pushl  -0x10(%ebp)
  802114:	e8 aa f0 ff ff       	call   8011c3 <fd2num>
  802119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80211c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	ba 00 00 00 00       	mov    $0x0,%edx
  802127:	eb 30                	jmp    802159 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802129:	83 ec 08             	sub    $0x8,%esp
  80212c:	56                   	push   %esi
  80212d:	6a 00                	push   $0x0
  80212f:	e8 d4 eb ff ff       	call   800d08 <sys_page_unmap>
  802134:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802137:	83 ec 08             	sub    $0x8,%esp
  80213a:	ff 75 f0             	pushl  -0x10(%ebp)
  80213d:	6a 00                	push   $0x0
  80213f:	e8 c4 eb ff ff       	call   800d08 <sys_page_unmap>
  802144:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802147:	83 ec 08             	sub    $0x8,%esp
  80214a:	ff 75 f4             	pushl  -0xc(%ebp)
  80214d:	6a 00                	push   $0x0
  80214f:	e8 b4 eb ff ff       	call   800d08 <sys_page_unmap>
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802159:	89 d0                	mov    %edx,%eax
  80215b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5e                   	pop    %esi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802168:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216b:	50                   	push   %eax
  80216c:	ff 75 08             	pushl  0x8(%ebp)
  80216f:	e8 c5 f0 ff ff       	call   801239 <fd_lookup>
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	78 18                	js     802193 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80217b:	83 ec 0c             	sub    $0xc,%esp
  80217e:	ff 75 f4             	pushl  -0xc(%ebp)
  802181:	e8 4d f0 ff ff       	call   8011d3 <fd2data>
	return _pipeisclosed(fd, p);
  802186:	89 c2                	mov    %eax,%edx
  802188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218b:	e8 21 fd ff ff       	call   801eb1 <_pipeisclosed>
  802190:	83 c4 10             	add    $0x10,%esp
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    

00802195 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	56                   	push   %esi
  802199:	53                   	push   %ebx
  80219a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80219d:	85 f6                	test   %esi,%esi
  80219f:	75 16                	jne    8021b7 <wait+0x22>
  8021a1:	68 bf 2e 80 00       	push   $0x802ebf
  8021a6:	68 3b 2e 80 00       	push   $0x802e3b
  8021ab:	6a 09                	push   $0x9
  8021ad:	68 ca 2e 80 00       	push   $0x802eca
  8021b2:	e8 6b e0 ff ff       	call   800222 <_panic>
	e = &envs[ENVX(envid)];
  8021b7:	89 f3                	mov    %esi,%ebx
  8021b9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021bf:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021c2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021c8:	eb 05                	jmp    8021cf <wait+0x3a>
		sys_yield();
  8021ca:	e8 95 ea ff ff       	call   800c64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021cf:	8b 43 48             	mov    0x48(%ebx),%eax
  8021d2:	39 c6                	cmp    %eax,%esi
  8021d4:	75 07                	jne    8021dd <wait+0x48>
  8021d6:	8b 43 54             	mov    0x54(%ebx),%eax
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	75 ed                	jne    8021ca <wait+0x35>
		sys_yield();
}
  8021dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ec:	5d                   	pop    %ebp
  8021ed:	c3                   	ret    

008021ee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021ee:	55                   	push   %ebp
  8021ef:	89 e5                	mov    %esp,%ebp
  8021f1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021f4:	68 d5 2e 80 00       	push   $0x802ed5
  8021f9:	ff 75 0c             	pushl  0xc(%ebp)
  8021fc:	e8 7f e6 ff ff       	call   800880 <strcpy>
	return 0;
}
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
  802206:	c9                   	leave  
  802207:	c3                   	ret    

00802208 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	57                   	push   %edi
  80220c:	56                   	push   %esi
  80220d:	53                   	push   %ebx
  80220e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802214:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802219:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221f:	eb 2d                	jmp    80224e <devcons_write+0x46>
		m = n - tot;
  802221:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802224:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802226:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802229:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80222e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802231:	83 ec 04             	sub    $0x4,%esp
  802234:	53                   	push   %ebx
  802235:	03 45 0c             	add    0xc(%ebp),%eax
  802238:	50                   	push   %eax
  802239:	57                   	push   %edi
  80223a:	e8 d3 e7 ff ff       	call   800a12 <memmove>
		sys_cputs(buf, m);
  80223f:	83 c4 08             	add    $0x8,%esp
  802242:	53                   	push   %ebx
  802243:	57                   	push   %edi
  802244:	e8 7e e9 ff ff       	call   800bc7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802249:	01 de                	add    %ebx,%esi
  80224b:	83 c4 10             	add    $0x10,%esp
  80224e:	89 f0                	mov    %esi,%eax
  802250:	3b 75 10             	cmp    0x10(%ebp),%esi
  802253:	72 cc                	jb     802221 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802255:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    

0080225d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80225d:	55                   	push   %ebp
  80225e:	89 e5                	mov    %esp,%ebp
  802260:	83 ec 08             	sub    $0x8,%esp
  802263:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802268:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80226c:	74 2a                	je     802298 <devcons_read+0x3b>
  80226e:	eb 05                	jmp    802275 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802270:	e8 ef e9 ff ff       	call   800c64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802275:	e8 6b e9 ff ff       	call   800be5 <sys_cgetc>
  80227a:	85 c0                	test   %eax,%eax
  80227c:	74 f2                	je     802270 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80227e:	85 c0                	test   %eax,%eax
  802280:	78 16                	js     802298 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802282:	83 f8 04             	cmp    $0x4,%eax
  802285:	74 0c                	je     802293 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802287:	8b 55 0c             	mov    0xc(%ebp),%edx
  80228a:	88 02                	mov    %al,(%edx)
	return 1;
  80228c:	b8 01 00 00 00       	mov    $0x1,%eax
  802291:	eb 05                	jmp    802298 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802293:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022a6:	6a 01                	push   $0x1
  8022a8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ab:	50                   	push   %eax
  8022ac:	e8 16 e9 ff ff       	call   800bc7 <sys_cputs>
}
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	c9                   	leave  
  8022b5:	c3                   	ret    

008022b6 <getchar>:

int
getchar(void)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022bc:	6a 01                	push   $0x1
  8022be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c1:	50                   	push   %eax
  8022c2:	6a 00                	push   $0x0
  8022c4:	e8 d6 f1 ff ff       	call   80149f <read>
	if (r < 0)
  8022c9:	83 c4 10             	add    $0x10,%esp
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	78 0f                	js     8022df <getchar+0x29>
		return r;
	if (r < 1)
  8022d0:	85 c0                	test   %eax,%eax
  8022d2:	7e 06                	jle    8022da <getchar+0x24>
		return -E_EOF;
	return c;
  8022d4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022d8:	eb 05                	jmp    8022df <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022da:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022df:	c9                   	leave  
  8022e0:	c3                   	ret    

008022e1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ea:	50                   	push   %eax
  8022eb:	ff 75 08             	pushl  0x8(%ebp)
  8022ee:	e8 46 ef ff ff       	call   801239 <fd_lookup>
  8022f3:	83 c4 10             	add    $0x10,%esp
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	78 11                	js     80230b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802303:	39 10                	cmp    %edx,(%eax)
  802305:	0f 94 c0             	sete   %al
  802308:	0f b6 c0             	movzbl %al,%eax
}
  80230b:	c9                   	leave  
  80230c:	c3                   	ret    

0080230d <opencons>:

int
opencons(void)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802316:	50                   	push   %eax
  802317:	e8 ce ee ff ff       	call   8011ea <fd_alloc>
  80231c:	83 c4 10             	add    $0x10,%esp
		return r;
  80231f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802321:	85 c0                	test   %eax,%eax
  802323:	78 3e                	js     802363 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802325:	83 ec 04             	sub    $0x4,%esp
  802328:	68 07 04 00 00       	push   $0x407
  80232d:	ff 75 f4             	pushl  -0xc(%ebp)
  802330:	6a 00                	push   $0x0
  802332:	e8 4c e9 ff ff       	call   800c83 <sys_page_alloc>
  802337:	83 c4 10             	add    $0x10,%esp
		return r;
  80233a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80233c:	85 c0                	test   %eax,%eax
  80233e:	78 23                	js     802363 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802340:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802349:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80234b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802355:	83 ec 0c             	sub    $0xc,%esp
  802358:	50                   	push   %eax
  802359:	e8 65 ee ff ff       	call   8011c3 <fd2num>
  80235e:	89 c2                	mov    %eax,%edx
  802360:	83 c4 10             	add    $0x10,%esp
}
  802363:	89 d0                	mov    %edx,%eax
  802365:	c9                   	leave  
  802366:	c3                   	ret    

00802367 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
  80236a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80236d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802374:	75 2c                	jne    8023a2 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802376:	83 ec 04             	sub    $0x4,%esp
  802379:	6a 07                	push   $0x7
  80237b:	68 00 f0 bf ee       	push   $0xeebff000
  802380:	6a 00                	push   $0x0
  802382:	e8 fc e8 ff ff       	call   800c83 <sys_page_alloc>
  802387:	83 c4 10             	add    $0x10,%esp
  80238a:	85 c0                	test   %eax,%eax
  80238c:	79 14                	jns    8023a2 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80238e:	83 ec 04             	sub    $0x4,%esp
  802391:	68 e1 2e 80 00       	push   $0x802ee1
  802396:	6a 22                	push   $0x22
  802398:	68 f8 2e 80 00       	push   $0x802ef8
  80239d:	e8 80 de ff ff       	call   800222 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  8023a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a5:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8023aa:	83 ec 08             	sub    $0x8,%esp
  8023ad:	68 d6 23 80 00       	push   $0x8023d6
  8023b2:	6a 00                	push   $0x0
  8023b4:	e8 15 ea ff ff       	call   800dce <sys_env_set_pgfault_upcall>
  8023b9:	83 c4 10             	add    $0x10,%esp
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	79 14                	jns    8023d4 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  8023c0:	83 ec 04             	sub    $0x4,%esp
  8023c3:	68 08 2f 80 00       	push   $0x802f08
  8023c8:	6a 27                	push   $0x27
  8023ca:	68 f8 2e 80 00       	push   $0x802ef8
  8023cf:	e8 4e de ff ff       	call   800222 <_panic>
    
}
  8023d4:	c9                   	leave  
  8023d5:	c3                   	ret    

008023d6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023d6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023d7:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023dc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023de:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8023e1:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8023e5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8023ea:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8023ee:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8023f0:	83 c4 08             	add    $0x8,%esp
	popal
  8023f3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8023f4:	83 c4 04             	add    $0x4,%esp
	popfl
  8023f7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023f8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023f9:	c3                   	ret    

008023fa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	56                   	push   %esi
  8023fe:	53                   	push   %ebx
  8023ff:	8b 75 08             	mov    0x8(%ebp),%esi
  802402:	8b 45 0c             	mov    0xc(%ebp),%eax
  802405:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802408:	85 c0                	test   %eax,%eax
  80240a:	74 0e                	je     80241a <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  80240c:	83 ec 0c             	sub    $0xc,%esp
  80240f:	50                   	push   %eax
  802410:	e8 1e ea ff ff       	call   800e33 <sys_ipc_recv>
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	eb 10                	jmp    80242a <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80241a:	83 ec 0c             	sub    $0xc,%esp
  80241d:	68 00 00 00 f0       	push   $0xf0000000
  802422:	e8 0c ea ff ff       	call   800e33 <sys_ipc_recv>
  802427:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80242a:	85 c0                	test   %eax,%eax
  80242c:	74 0e                	je     80243c <ipc_recv+0x42>
    	*from_env_store = 0;
  80242e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802434:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80243a:	eb 24                	jmp    802460 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  80243c:	85 f6                	test   %esi,%esi
  80243e:	74 0a                	je     80244a <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802440:	a1 20 44 80 00       	mov    0x804420,%eax
  802445:	8b 40 74             	mov    0x74(%eax),%eax
  802448:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80244a:	85 db                	test   %ebx,%ebx
  80244c:	74 0a                	je     802458 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80244e:	a1 20 44 80 00       	mov    0x804420,%eax
  802453:	8b 40 78             	mov    0x78(%eax),%eax
  802456:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802458:	a1 20 44 80 00       	mov    0x804420,%eax
  80245d:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802460:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	57                   	push   %edi
  80246b:	56                   	push   %esi
  80246c:	53                   	push   %ebx
  80246d:	83 ec 0c             	sub    $0xc,%esp
  802470:	8b 7d 08             	mov    0x8(%ebp),%edi
  802473:	8b 75 0c             	mov    0xc(%ebp),%esi
  802476:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802479:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  80247b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802480:	0f 44 d8             	cmove  %eax,%ebx
  802483:	eb 1c                	jmp    8024a1 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802485:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802488:	74 12                	je     80249c <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  80248a:	50                   	push   %eax
  80248b:	68 2c 2f 80 00       	push   $0x802f2c
  802490:	6a 4b                	push   $0x4b
  802492:	68 44 2f 80 00       	push   $0x802f44
  802497:	e8 86 dd ff ff       	call   800222 <_panic>
        }	
        sys_yield();
  80249c:	e8 c3 e7 ff ff       	call   800c64 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8024a1:	ff 75 14             	pushl  0x14(%ebp)
  8024a4:	53                   	push   %ebx
  8024a5:	56                   	push   %esi
  8024a6:	57                   	push   %edi
  8024a7:	e8 64 e9 ff ff       	call   800e10 <sys_ipc_try_send>
  8024ac:	83 c4 10             	add    $0x10,%esp
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	75 d2                	jne    802485 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8024b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b6:	5b                   	pop    %ebx
  8024b7:	5e                   	pop    %esi
  8024b8:	5f                   	pop    %edi
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    

008024bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024bb:	55                   	push   %ebp
  8024bc:	89 e5                	mov    %esp,%ebp
  8024be:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024c1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024c6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024c9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024cf:	8b 52 50             	mov    0x50(%edx),%edx
  8024d2:	39 ca                	cmp    %ecx,%edx
  8024d4:	75 0d                	jne    8024e3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024de:	8b 40 48             	mov    0x48(%eax),%eax
  8024e1:	eb 0f                	jmp    8024f2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024e3:	83 c0 01             	add    $0x1,%eax
  8024e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024eb:	75 d9                	jne    8024c6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024f2:	5d                   	pop    %ebp
  8024f3:	c3                   	ret    

008024f4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024f4:	55                   	push   %ebp
  8024f5:	89 e5                	mov    %esp,%ebp
  8024f7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	c1 e8 16             	shr    $0x16,%eax
  8024ff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802506:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80250b:	f6 c1 01             	test   $0x1,%cl
  80250e:	74 1d                	je     80252d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802510:	c1 ea 0c             	shr    $0xc,%edx
  802513:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80251a:	f6 c2 01             	test   $0x1,%dl
  80251d:	74 0e                	je     80252d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80251f:	c1 ea 0c             	shr    $0xc,%edx
  802522:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802529:	ef 
  80252a:	0f b7 c0             	movzwl %ax,%eax
}
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    
  80252f:	90                   	nop

00802530 <__udivdi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80253b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80253f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 f6                	test   %esi,%esi
  802549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80254d:	89 ca                	mov    %ecx,%edx
  80254f:	89 f8                	mov    %edi,%eax
  802551:	75 3d                	jne    802590 <__udivdi3+0x60>
  802553:	39 cf                	cmp    %ecx,%edi
  802555:	0f 87 c5 00 00 00    	ja     802620 <__udivdi3+0xf0>
  80255b:	85 ff                	test   %edi,%edi
  80255d:	89 fd                	mov    %edi,%ebp
  80255f:	75 0b                	jne    80256c <__udivdi3+0x3c>
  802561:	b8 01 00 00 00       	mov    $0x1,%eax
  802566:	31 d2                	xor    %edx,%edx
  802568:	f7 f7                	div    %edi
  80256a:	89 c5                	mov    %eax,%ebp
  80256c:	89 c8                	mov    %ecx,%eax
  80256e:	31 d2                	xor    %edx,%edx
  802570:	f7 f5                	div    %ebp
  802572:	89 c1                	mov    %eax,%ecx
  802574:	89 d8                	mov    %ebx,%eax
  802576:	89 cf                	mov    %ecx,%edi
  802578:	f7 f5                	div    %ebp
  80257a:	89 c3                	mov    %eax,%ebx
  80257c:	89 d8                	mov    %ebx,%eax
  80257e:	89 fa                	mov    %edi,%edx
  802580:	83 c4 1c             	add    $0x1c,%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	90                   	nop
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	39 ce                	cmp    %ecx,%esi
  802592:	77 74                	ja     802608 <__udivdi3+0xd8>
  802594:	0f bd fe             	bsr    %esi,%edi
  802597:	83 f7 1f             	xor    $0x1f,%edi
  80259a:	0f 84 98 00 00 00    	je     802638 <__udivdi3+0x108>
  8025a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	89 c5                	mov    %eax,%ebp
  8025a9:	29 fb                	sub    %edi,%ebx
  8025ab:	d3 e6                	shl    %cl,%esi
  8025ad:	89 d9                	mov    %ebx,%ecx
  8025af:	d3 ed                	shr    %cl,%ebp
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	d3 e0                	shl    %cl,%eax
  8025b5:	09 ee                	or     %ebp,%esi
  8025b7:	89 d9                	mov    %ebx,%ecx
  8025b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025bd:	89 d5                	mov    %edx,%ebp
  8025bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025c3:	d3 ed                	shr    %cl,%ebp
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	d3 e2                	shl    %cl,%edx
  8025c9:	89 d9                	mov    %ebx,%ecx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	09 c2                	or     %eax,%edx
  8025cf:	89 d0                	mov    %edx,%eax
  8025d1:	89 ea                	mov    %ebp,%edx
  8025d3:	f7 f6                	div    %esi
  8025d5:	89 d5                	mov    %edx,%ebp
  8025d7:	89 c3                	mov    %eax,%ebx
  8025d9:	f7 64 24 0c          	mull   0xc(%esp)
  8025dd:	39 d5                	cmp    %edx,%ebp
  8025df:	72 10                	jb     8025f1 <__udivdi3+0xc1>
  8025e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e6                	shl    %cl,%esi
  8025e9:	39 c6                	cmp    %eax,%esi
  8025eb:	73 07                	jae    8025f4 <__udivdi3+0xc4>
  8025ed:	39 d5                	cmp    %edx,%ebp
  8025ef:	75 03                	jne    8025f4 <__udivdi3+0xc4>
  8025f1:	83 eb 01             	sub    $0x1,%ebx
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 d8                	mov    %ebx,%eax
  8025f8:	89 fa                	mov    %edi,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	31 ff                	xor    %edi,%edi
  80260a:	31 db                	xor    %ebx,%ebx
  80260c:	89 d8                	mov    %ebx,%eax
  80260e:	89 fa                	mov    %edi,%edx
  802610:	83 c4 1c             	add    $0x1c,%esp
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
  802618:	90                   	nop
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	89 d8                	mov    %ebx,%eax
  802622:	f7 f7                	div    %edi
  802624:	31 ff                	xor    %edi,%edi
  802626:	89 c3                	mov    %eax,%ebx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 fa                	mov    %edi,%edx
  80262c:	83 c4 1c             	add    $0x1c,%esp
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5f                   	pop    %edi
  802632:	5d                   	pop    %ebp
  802633:	c3                   	ret    
  802634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802638:	39 ce                	cmp    %ecx,%esi
  80263a:	72 0c                	jb     802648 <__udivdi3+0x118>
  80263c:	31 db                	xor    %ebx,%ebx
  80263e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802642:	0f 87 34 ff ff ff    	ja     80257c <__udivdi3+0x4c>
  802648:	bb 01 00 00 00       	mov    $0x1,%ebx
  80264d:	e9 2a ff ff ff       	jmp    80257c <__udivdi3+0x4c>
  802652:	66 90                	xchg   %ax,%ax
  802654:	66 90                	xchg   %ax,%ax
  802656:	66 90                	xchg   %ax,%ax
  802658:	66 90                	xchg   %ax,%ax
  80265a:	66 90                	xchg   %ax,%ax
  80265c:	66 90                	xchg   %ax,%ax
  80265e:	66 90                	xchg   %ax,%ax

00802660 <__umoddi3>:
  802660:	55                   	push   %ebp
  802661:	57                   	push   %edi
  802662:	56                   	push   %esi
  802663:	53                   	push   %ebx
  802664:	83 ec 1c             	sub    $0x1c,%esp
  802667:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80266b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80266f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802673:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802677:	85 d2                	test   %edx,%edx
  802679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80267d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802681:	89 f3                	mov    %esi,%ebx
  802683:	89 3c 24             	mov    %edi,(%esp)
  802686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80268a:	75 1c                	jne    8026a8 <__umoddi3+0x48>
  80268c:	39 f7                	cmp    %esi,%edi
  80268e:	76 50                	jbe    8026e0 <__umoddi3+0x80>
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	f7 f7                	div    %edi
  802696:	89 d0                	mov    %edx,%eax
  802698:	31 d2                	xor    %edx,%edx
  80269a:	83 c4 1c             	add    $0x1c,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a8:	39 f2                	cmp    %esi,%edx
  8026aa:	89 d0                	mov    %edx,%eax
  8026ac:	77 52                	ja     802700 <__umoddi3+0xa0>
  8026ae:	0f bd ea             	bsr    %edx,%ebp
  8026b1:	83 f5 1f             	xor    $0x1f,%ebp
  8026b4:	75 5a                	jne    802710 <__umoddi3+0xb0>
  8026b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ba:	0f 82 e0 00 00 00    	jb     8027a0 <__umoddi3+0x140>
  8026c0:	39 0c 24             	cmp    %ecx,(%esp)
  8026c3:	0f 86 d7 00 00 00    	jbe    8027a0 <__umoddi3+0x140>
  8026c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026d1:	83 c4 1c             	add    $0x1c,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	85 ff                	test   %edi,%edi
  8026e2:	89 fd                	mov    %edi,%ebp
  8026e4:	75 0b                	jne    8026f1 <__umoddi3+0x91>
  8026e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	f7 f7                	div    %edi
  8026ef:	89 c5                	mov    %eax,%ebp
  8026f1:	89 f0                	mov    %esi,%eax
  8026f3:	31 d2                	xor    %edx,%edx
  8026f5:	f7 f5                	div    %ebp
  8026f7:	89 c8                	mov    %ecx,%eax
  8026f9:	f7 f5                	div    %ebp
  8026fb:	89 d0                	mov    %edx,%eax
  8026fd:	eb 99                	jmp    802698 <__umoddi3+0x38>
  8026ff:	90                   	nop
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	83 c4 1c             	add    $0x1c,%esp
  802707:	5b                   	pop    %ebx
  802708:	5e                   	pop    %esi
  802709:	5f                   	pop    %edi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	8b 34 24             	mov    (%esp),%esi
  802713:	bf 20 00 00 00       	mov    $0x20,%edi
  802718:	89 e9                	mov    %ebp,%ecx
  80271a:	29 ef                	sub    %ebp,%edi
  80271c:	d3 e0                	shl    %cl,%eax
  80271e:	89 f9                	mov    %edi,%ecx
  802720:	89 f2                	mov    %esi,%edx
  802722:	d3 ea                	shr    %cl,%edx
  802724:	89 e9                	mov    %ebp,%ecx
  802726:	09 c2                	or     %eax,%edx
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	89 14 24             	mov    %edx,(%esp)
  80272d:	89 f2                	mov    %esi,%edx
  80272f:	d3 e2                	shl    %cl,%edx
  802731:	89 f9                	mov    %edi,%ecx
  802733:	89 54 24 04          	mov    %edx,0x4(%esp)
  802737:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80273b:	d3 e8                	shr    %cl,%eax
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	89 c6                	mov    %eax,%esi
  802741:	d3 e3                	shl    %cl,%ebx
  802743:	89 f9                	mov    %edi,%ecx
  802745:	89 d0                	mov    %edx,%eax
  802747:	d3 e8                	shr    %cl,%eax
  802749:	89 e9                	mov    %ebp,%ecx
  80274b:	09 d8                	or     %ebx,%eax
  80274d:	89 d3                	mov    %edx,%ebx
  80274f:	89 f2                	mov    %esi,%edx
  802751:	f7 34 24             	divl   (%esp)
  802754:	89 d6                	mov    %edx,%esi
  802756:	d3 e3                	shl    %cl,%ebx
  802758:	f7 64 24 04          	mull   0x4(%esp)
  80275c:	39 d6                	cmp    %edx,%esi
  80275e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802762:	89 d1                	mov    %edx,%ecx
  802764:	89 c3                	mov    %eax,%ebx
  802766:	72 08                	jb     802770 <__umoddi3+0x110>
  802768:	75 11                	jne    80277b <__umoddi3+0x11b>
  80276a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80276e:	73 0b                	jae    80277b <__umoddi3+0x11b>
  802770:	2b 44 24 04          	sub    0x4(%esp),%eax
  802774:	1b 14 24             	sbb    (%esp),%edx
  802777:	89 d1                	mov    %edx,%ecx
  802779:	89 c3                	mov    %eax,%ebx
  80277b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80277f:	29 da                	sub    %ebx,%edx
  802781:	19 ce                	sbb    %ecx,%esi
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 f0                	mov    %esi,%eax
  802787:	d3 e0                	shl    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	d3 ea                	shr    %cl,%edx
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	d3 ee                	shr    %cl,%esi
  802791:	09 d0                	or     %edx,%eax
  802793:	89 f2                	mov    %esi,%edx
  802795:	83 c4 1c             	add    $0x1c,%esp
  802798:	5b                   	pop    %ebx
  802799:	5e                   	pop    %esi
  80279a:	5f                   	pop    %edi
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    
  80279d:	8d 76 00             	lea    0x0(%esi),%esi
  8027a0:	29 f9                	sub    %edi,%ecx
  8027a2:	19 d6                	sbb    %edx,%esi
  8027a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ac:	e9 18 ff ff ff       	jmp    8026c9 <__umoddi3+0x69>
