
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 00 	movl   $0x802900,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 06 29 80 00       	push   $0x802906
  80004d:	e8 25 02 00 00       	call   800277 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 15 29 80 00 	movl   $0x802915,(%esp)
  800059:	e8 19 02 00 00       	call   800277 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 28 29 80 00       	push   $0x802928
  800068:	e8 2e 15 00 00       	call   80159b <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 2e 29 80 00       	push   $0x80292e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 44 29 80 00       	push   $0x802944
  800083:	e8 16 01 00 00       	call   80019e <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 51 29 80 00       	push   $0x802951
  800090:	e8 e2 01 00 00       	call   800277 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 99 0a 00 00       	call   800b43 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 50 10 00 00       	call   80110c <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 64 29 80 00       	push   $0x802964
  8000cb:	e8 a7 01 00 00       	call   800277 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 f8 0e 00 00       	call   800fd0 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 78 29 80 00 	movl   $0x802978,(%esp)
  8000df:	e8 93 01 00 00       	call   800277 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 8c 29 80 00       	push   $0x80298c
  8000f0:	68 95 29 80 00       	push   $0x802995
  8000f5:	68 9f 29 80 00       	push   $0x80299f
  8000fa:	68 9e 29 80 00       	push   $0x80299e
  8000ff:	e8 72 1a 00 00       	call   801b76 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 a4 29 80 00       	push   $0x8029a4
  800111:	6a 1a                	push   $0x1a
  800113:	68 44 29 80 00       	push   $0x802944
  800118:	e8 81 00 00 00       	call   80019e <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 bb 29 80 00       	push   $0x8029bb
  800125:	e8 4d 01 00 00       	call   800277 <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80013f:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800146:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800149:	e8 73 0a 00 00       	call   800bc1 <sys_getenvid>
  80014e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800153:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800156:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800160:	85 db                	test   %ebx,%ebx
  800162:	7e 07                	jle    80016b <libmain+0x37>
		binaryname = argv[0];
  800164:	8b 06                	mov    (%esi),%eax
  800166:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	e8 be fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800175:	e8 0a 00 00 00       	call   800184 <exit>
}
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018a:	e8 6c 0e 00 00       	call   800ffb <close_all>
	sys_env_destroy(0);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	6a 00                	push   $0x0
  800194:	e8 e7 09 00 00       	call   800b80 <sys_env_destroy>
}
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ac:	e8 10 0a 00 00       	call   800bc1 <sys_getenvid>
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	ff 75 0c             	pushl  0xc(%ebp)
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	56                   	push   %esi
  8001bb:	50                   	push   %eax
  8001bc:	68 d8 29 80 00       	push   $0x8029d8
  8001c1:	e8 b1 00 00 00       	call   800277 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c6:	83 c4 18             	add    $0x18,%esp
  8001c9:	53                   	push   %ebx
  8001ca:	ff 75 10             	pushl  0x10(%ebp)
  8001cd:	e8 54 00 00 00       	call   800226 <vcprintf>
	cprintf("\n");
  8001d2:	c7 04 24 dd 2e 80 00 	movl   $0x802edd,(%esp)
  8001d9:	e8 99 00 00 00       	call   800277 <cprintf>
  8001de:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e1:	cc                   	int3   
  8001e2:	eb fd                	jmp    8001e1 <_panic+0x43>

008001e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ee:	8b 13                	mov    (%ebx),%edx
  8001f0:	8d 42 01             	lea    0x1(%edx),%eax
  8001f3:	89 03                	mov    %eax,(%ebx)
  8001f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800201:	75 1a                	jne    80021d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	68 ff 00 00 00       	push   $0xff
  80020b:	8d 43 08             	lea    0x8(%ebx),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 2f 09 00 00       	call   800b43 <sys_cputs>
		b->idx = 0;
  800214:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80021a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	50                   	push   %eax
  800250:	68 e4 01 80 00       	push   $0x8001e4
  800255:	e8 54 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025a:	83 c4 08             	add    $0x8,%esp
  80025d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800263:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800269:	50                   	push   %eax
  80026a:	e8 d4 08 00 00       	call   800b43 <sys_cputs>

	return b.cnt;
}
  80026f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800280:	50                   	push   %eax
  800281:	ff 75 08             	pushl  0x8(%ebp)
  800284:	e8 9d ff ff ff       	call   800226 <vcprintf>
	va_end(ap);

	return cnt;
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 1c             	sub    $0x1c,%esp
  800294:	89 c7                	mov    %eax,%edi
  800296:	89 d6                	mov    %edx,%esi
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002b2:	39 d3                	cmp    %edx,%ebx
  8002b4:	72 05                	jb     8002bb <printnum+0x30>
  8002b6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b9:	77 45                	ja     800300 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	ff 75 18             	pushl  0x18(%ebp)
  8002c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c7:	53                   	push   %ebx
  8002c8:	ff 75 10             	pushl  0x10(%ebp)
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002da:	e8 91 23 00 00       	call   802670 <__udivdi3>
  8002df:	83 c4 18             	add    $0x18,%esp
  8002e2:	52                   	push   %edx
  8002e3:	50                   	push   %eax
  8002e4:	89 f2                	mov    %esi,%edx
  8002e6:	89 f8                	mov    %edi,%eax
  8002e8:	e8 9e ff ff ff       	call   80028b <printnum>
  8002ed:	83 c4 20             	add    $0x20,%esp
  8002f0:	eb 18                	jmp    80030a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	56                   	push   %esi
  8002f6:	ff 75 18             	pushl  0x18(%ebp)
  8002f9:	ff d7                	call   *%edi
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	eb 03                	jmp    800303 <printnum+0x78>
  800300:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800303:	83 eb 01             	sub    $0x1,%ebx
  800306:	85 db                	test   %ebx,%ebx
  800308:	7f e8                	jg     8002f2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	56                   	push   %esi
  80030e:	83 ec 04             	sub    $0x4,%esp
  800311:	ff 75 e4             	pushl  -0x1c(%ebp)
  800314:	ff 75 e0             	pushl  -0x20(%ebp)
  800317:	ff 75 dc             	pushl  -0x24(%ebp)
  80031a:	ff 75 d8             	pushl  -0x28(%ebp)
  80031d:	e8 7e 24 00 00       	call   8027a0 <__umoddi3>
  800322:	83 c4 14             	add    $0x14,%esp
  800325:	0f be 80 fb 29 80 00 	movsbl 0x8029fb(%eax),%eax
  80032c:	50                   	push   %eax
  80032d:	ff d7                	call   *%edi
}
  80032f:	83 c4 10             	add    $0x10,%esp
  800332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033d:	83 fa 01             	cmp    $0x1,%edx
  800340:	7e 0e                	jle    800350 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 08             	lea    0x8(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	8b 52 04             	mov    0x4(%edx),%edx
  80034e:	eb 22                	jmp    800372 <getuint+0x38>
	else if (lflag)
  800350:	85 d2                	test   %edx,%edx
  800352:	74 10                	je     800364 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 0e                	jmp    800372 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 04             	lea    0x4(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	3b 50 04             	cmp    0x4(%eax),%edx
  800383:	73 0a                	jae    80038f <sprintputch+0x1b>
		*b->buf++ = ch;
  800385:	8d 4a 01             	lea    0x1(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	88 02                	mov    %al,(%edx)
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039a:	50                   	push   %eax
  80039b:	ff 75 10             	pushl  0x10(%ebp)
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 05 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 2c             	sub    $0x2c,%esp
  8003b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c0:	eb 12                	jmp    8003d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	0f 84 89 03 00 00    	je     800753 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	50                   	push   %eax
  8003cf:	ff d6                	call   *%esi
  8003d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d4:	83 c7 01             	add    $0x1,%edi
  8003d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	75 e2                	jne    8003c2 <vprintfmt+0x14>
  8003e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	eb 07                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8d 47 01             	lea    0x1(%edi),%eax
  80040a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040d:	0f b6 07             	movzbl (%edi),%eax
  800410:	0f b6 c8             	movzbl %al,%ecx
  800413:	83 e8 23             	sub    $0x23,%eax
  800416:	3c 55                	cmp    $0x55,%al
  800418:	0f 87 1a 03 00 00    	ja     800738 <vprintfmt+0x38a>
  80041e:	0f b6 c0             	movzbl %al,%eax
  800421:	ff 24 85 40 2b 80 00 	jmp    *0x802b40(,%eax,4)
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042f:	eb d6                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800443:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800446:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800449:	83 fa 09             	cmp    $0x9,%edx
  80044c:	77 39                	ja     800487 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800451:	eb e9                	jmp    80043c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 48 04             	lea    0x4(%eax),%ecx
  800459:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800464:	eb 27                	jmp    80048d <vprintfmt+0xdf>
  800466:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800470:	0f 49 c8             	cmovns %eax,%ecx
  800473:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800479:	eb 8c                	jmp    800407 <vprintfmt+0x59>
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800485:	eb 80                	jmp    800407 <vprintfmt+0x59>
  800487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80048d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800491:	0f 89 70 ff ff ff    	jns    800407 <vprintfmt+0x59>
				width = precision, precision = -1;
  800497:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a4:	e9 5e ff ff ff       	jmp    800407 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004af:	e9 53 ff ff ff       	jmp    800407 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	53                   	push   %ebx
  8004c1:	ff 30                	pushl  (%eax)
  8004c3:	ff d6                	call   *%esi
			break;
  8004c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cb:	e9 04 ff ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	8b 00                	mov    (%eax),%eax
  8004db:	99                   	cltd   
  8004dc:	31 d0                	xor    %edx,%eax
  8004de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e0:	83 f8 0f             	cmp    $0xf,%eax
  8004e3:	7f 0b                	jg     8004f0 <vprintfmt+0x142>
  8004e5:	8b 14 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%edx
  8004ec:	85 d2                	test   %edx,%edx
  8004ee:	75 18                	jne    800508 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004f0:	50                   	push   %eax
  8004f1:	68 13 2a 80 00       	push   $0x802a13
  8004f6:	53                   	push   %ebx
  8004f7:	56                   	push   %esi
  8004f8:	e8 94 fe ff ff       	call   800391 <printfmt>
  8004fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 cc fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800508:	52                   	push   %edx
  800509:	68 d5 2d 80 00       	push   $0x802dd5
  80050e:	53                   	push   %ebx
  80050f:	56                   	push   %esi
  800510:	e8 7c fe ff ff       	call   800391 <printfmt>
  800515:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051b:	e9 b4 fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052b:	85 ff                	test   %edi,%edi
  80052d:	b8 0c 2a 80 00       	mov    $0x802a0c,%eax
  800532:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800535:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800539:	0f 8e 94 00 00 00    	jle    8005d3 <vprintfmt+0x225>
  80053f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800543:	0f 84 98 00 00 00    	je     8005e1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 d0             	pushl  -0x30(%ebp)
  80054f:	57                   	push   %edi
  800550:	e8 86 02 00 00       	call   8007db <strnlen>
  800555:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800558:	29 c1                	sub    %eax,%ecx
  80055a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800560:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800564:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800567:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80056a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	eb 0f                	jmp    80057d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	ff 75 e0             	pushl  -0x20(%ebp)
  800575:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	83 ef 01             	sub    $0x1,%edi
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	85 ff                	test   %edi,%edi
  80057f:	7f ed                	jg     80056e <vprintfmt+0x1c0>
  800581:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800584:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800587:	85 c9                	test   %ecx,%ecx
  800589:	b8 00 00 00 00       	mov    $0x0,%eax
  80058e:	0f 49 c1             	cmovns %ecx,%eax
  800591:	29 c1                	sub    %eax,%ecx
  800593:	89 75 08             	mov    %esi,0x8(%ebp)
  800596:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800599:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059c:	89 cb                	mov    %ecx,%ebx
  80059e:	eb 4d                	jmp    8005ed <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a4:	74 1b                	je     8005c1 <vprintfmt+0x213>
  8005a6:	0f be c0             	movsbl %al,%eax
  8005a9:	83 e8 20             	sub    $0x20,%eax
  8005ac:	83 f8 5e             	cmp    $0x5e,%eax
  8005af:	76 10                	jbe    8005c1 <vprintfmt+0x213>
					putch('?', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	6a 3f                	push   $0x3f
  8005b9:	ff 55 08             	call   *0x8(%ebp)
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	eb 0d                	jmp    8005ce <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	ff 75 0c             	pushl  0xc(%ebp)
  8005c7:	52                   	push   %edx
  8005c8:	ff 55 08             	call   *0x8(%ebp)
  8005cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	83 eb 01             	sub    $0x1,%ebx
  8005d1:	eb 1a                	jmp    8005ed <vprintfmt+0x23f>
  8005d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005df:	eb 0c                	jmp    8005ed <vprintfmt+0x23f>
  8005e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ed:	83 c7 01             	add    $0x1,%edi
  8005f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f4:	0f be d0             	movsbl %al,%edx
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	74 23                	je     80061e <vprintfmt+0x270>
  8005fb:	85 f6                	test   %esi,%esi
  8005fd:	78 a1                	js     8005a0 <vprintfmt+0x1f2>
  8005ff:	83 ee 01             	sub    $0x1,%esi
  800602:	79 9c                	jns    8005a0 <vprintfmt+0x1f2>
  800604:	89 df                	mov    %ebx,%edi
  800606:	8b 75 08             	mov    0x8(%ebp),%esi
  800609:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060c:	eb 18                	jmp    800626 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 20                	push   $0x20
  800614:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	eb 08                	jmp    800626 <vprintfmt+0x278>
  80061e:	89 df                	mov    %ebx,%edi
  800620:	8b 75 08             	mov    0x8(%ebp),%esi
  800623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800626:	85 ff                	test   %edi,%edi
  800628:	7f e4                	jg     80060e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062d:	e9 a2 fd ff ff       	jmp    8003d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800632:	83 fa 01             	cmp    $0x1,%edx
  800635:	7e 16                	jle    80064d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 08             	lea    0x8(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
  800640:	8b 50 04             	mov    0x4(%eax),%edx
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064b:	eb 32                	jmp    80067f <vprintfmt+0x2d1>
	else if (lflag)
  80064d:	85 d2                	test   %edx,%edx
  80064f:	74 18                	je     800669 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065f:	89 c1                	mov    %eax,%ecx
  800661:	c1 f9 1f             	sar    $0x1f,%ecx
  800664:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800667:	eb 16                	jmp    80067f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	8b 00                	mov    (%eax),%eax
  800674:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800677:	89 c1                	mov    %eax,%ecx
  800679:	c1 f9 1f             	sar    $0x1f,%ecx
  80067c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800682:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800685:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80068a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068e:	79 74                	jns    800704 <vprintfmt+0x356>
				putch('-', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 2d                	push   $0x2d
  800696:	ff d6                	call   *%esi
				num = -(long long) num;
  800698:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069e:	f7 d8                	neg    %eax
  8006a0:	83 d2 00             	adc    $0x0,%edx
  8006a3:	f7 da                	neg    %edx
  8006a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ad:	eb 55                	jmp    800704 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 83 fc ff ff       	call   80033a <getuint>
			base = 10;
  8006b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bc:	eb 46                	jmp    800704 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006be:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c1:	e8 74 fc ff ff       	call   80033a <getuint>
		        base = 8;
  8006c6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006cb:	eb 37                	jmp    800704 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 30                	push   $0x30
  8006d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d5:	83 c4 08             	add    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 78                	push   $0x78
  8006db:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e6:	8b 00                	mov    (%eax),%eax
  8006e8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ed:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f5:	eb 0d                	jmp    800704 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 3b fc ff ff       	call   80033a <getuint>
			base = 16;
  8006ff:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80070b:	57                   	push   %edi
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	51                   	push   %ecx
  800710:	52                   	push   %edx
  800711:	50                   	push   %eax
  800712:	89 da                	mov    %ebx,%edx
  800714:	89 f0                	mov    %esi,%eax
  800716:	e8 70 fb ff ff       	call   80028b <printnum>
			break;
  80071b:	83 c4 20             	add    $0x20,%esp
  80071e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800721:	e9 ae fc ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	51                   	push   %ecx
  80072b:	ff d6                	call   *%esi
			break;
  80072d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800733:	e9 9c fc ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 25                	push   $0x25
  80073e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 03                	jmp    800748 <vprintfmt+0x39a>
  800745:	83 ef 01             	sub    $0x1,%edi
  800748:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074c:	75 f7                	jne    800745 <vprintfmt+0x397>
  80074e:	e9 81 fc ff ff       	jmp    8003d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800753:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5f                   	pop    %edi
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	83 ec 18             	sub    $0x18,%esp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800767:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 26                	je     8007a2 <vsnprintf+0x47>
  80077c:	85 d2                	test   %edx,%edx
  80077e:	7e 22                	jle    8007a2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800780:	ff 75 14             	pushl  0x14(%ebp)
  800783:	ff 75 10             	pushl  0x10(%ebp)
  800786:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	68 74 03 80 00       	push   $0x800374
  80078f:	e8 1a fc ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 05                	jmp    8007a7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	ff 75 0c             	pushl  0xc(%ebp)
  8007b9:	ff 75 08             	pushl  0x8(%ebp)
  8007bc:	e8 9a ff ff ff       	call   80075b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ce:	eb 03                	jmp    8007d3 <strlen+0x10>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0xd>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e9:	eb 03                	jmp    8007ee <strnlen+0x13>
		n++;
  8007eb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ee:	39 c2                	cmp    %eax,%edx
  8007f0:	74 08                	je     8007fa <strnlen+0x1f>
  8007f2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f6:	75 f3                	jne    8007eb <strnlen+0x10>
  8007f8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800806:	89 c2                	mov    %eax,%edx
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800812:	88 5a ff             	mov    %bl,-0x1(%edx)
  800815:	84 db                	test   %bl,%bl
  800817:	75 ef                	jne    800808 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800819:	5b                   	pop    %ebx
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800823:	53                   	push   %ebx
  800824:	e8 9a ff ff ff       	call   8007c3 <strlen>
  800829:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082c:	ff 75 0c             	pushl  0xc(%ebp)
  80082f:	01 d8                	add    %ebx,%eax
  800831:	50                   	push   %eax
  800832:	e8 c5 ff ff ff       	call   8007fc <strcpy>
	return dst;
}
  800837:	89 d8                	mov    %ebx,%eax
  800839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	89 f3                	mov    %esi,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084e:	89 f2                	mov    %esi,%edx
  800850:	eb 0f                	jmp    800861 <strncpy+0x23>
		*dst++ = *src;
  800852:	83 c2 01             	add    $0x1,%edx
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085b:	80 39 01             	cmpb   $0x1,(%ecx)
  80085e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	39 da                	cmp    %ebx,%edx
  800863:	75 ed                	jne    800852 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800865:	89 f0                	mov    %esi,%eax
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 75 08             	mov    0x8(%ebp),%esi
  800873:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800876:	8b 55 10             	mov    0x10(%ebp),%edx
  800879:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087b:	85 d2                	test   %edx,%edx
  80087d:	74 21                	je     8008a0 <strlcpy+0x35>
  80087f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800883:	89 f2                	mov    %esi,%edx
  800885:	eb 09                	jmp    800890 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800887:	83 c2 01             	add    $0x1,%edx
  80088a:	83 c1 01             	add    $0x1,%ecx
  80088d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800890:	39 c2                	cmp    %eax,%edx
  800892:	74 09                	je     80089d <strlcpy+0x32>
  800894:	0f b6 19             	movzbl (%ecx),%ebx
  800897:	84 db                	test   %bl,%bl
  800899:	75 ec                	jne    800887 <strlcpy+0x1c>
  80089b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a0:	29 f0                	sub    %esi,%eax
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008af:	eb 06                	jmp    8008b7 <strcmp+0x11>
		p++, q++;
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b7:	0f b6 01             	movzbl (%ecx),%eax
  8008ba:	84 c0                	test   %al,%al
  8008bc:	74 04                	je     8008c2 <strcmp+0x1c>
  8008be:	3a 02                	cmp    (%edx),%al
  8008c0:	74 ef                	je     8008b1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c2:	0f b6 c0             	movzbl %al,%eax
  8008c5:	0f b6 12             	movzbl (%edx),%edx
  8008c8:	29 d0                	sub    %edx,%eax
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d6:	89 c3                	mov    %eax,%ebx
  8008d8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008db:	eb 06                	jmp    8008e3 <strncmp+0x17>
		n--, p++, q++;
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e3:	39 d8                	cmp    %ebx,%eax
  8008e5:	74 15                	je     8008fc <strncmp+0x30>
  8008e7:	0f b6 08             	movzbl (%eax),%ecx
  8008ea:	84 c9                	test   %cl,%cl
  8008ec:	74 04                	je     8008f2 <strncmp+0x26>
  8008ee:	3a 0a                	cmp    (%edx),%cl
  8008f0:	74 eb                	je     8008dd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f2:	0f b6 00             	movzbl (%eax),%eax
  8008f5:	0f b6 12             	movzbl (%edx),%edx
  8008f8:	29 d0                	sub    %edx,%eax
  8008fa:	eb 05                	jmp    800901 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090e:	eb 07                	jmp    800917 <strchr+0x13>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	74 0f                	je     800923 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800914:	83 c0 01             	add    $0x1,%eax
  800917:	0f b6 10             	movzbl (%eax),%edx
  80091a:	84 d2                	test   %dl,%dl
  80091c:	75 f2                	jne    800910 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092f:	eb 03                	jmp    800934 <strfind+0xf>
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800937:	38 ca                	cmp    %cl,%dl
  800939:	74 04                	je     80093f <strfind+0x1a>
  80093b:	84 d2                	test   %dl,%dl
  80093d:	75 f2                	jne    800931 <strfind+0xc>
			break;
	return (char *) s;
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	74 36                	je     800987 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 28                	jne    800981 <memset+0x40>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 23                	jne    800981 <memset+0x40>
		c &= 0xFF;
  80095e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800962:	89 d3                	mov    %edx,%ebx
  800964:	c1 e3 08             	shl    $0x8,%ebx
  800967:	89 d6                	mov    %edx,%esi
  800969:	c1 e6 18             	shl    $0x18,%esi
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	c1 e0 10             	shl    $0x10,%eax
  800971:	09 f0                	or     %esi,%eax
  800973:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800975:	89 d8                	mov    %ebx,%eax
  800977:	09 d0                	or     %edx,%eax
  800979:	c1 e9 02             	shr    $0x2,%ecx
  80097c:	fc                   	cld    
  80097d:	f3 ab                	rep stos %eax,%es:(%edi)
  80097f:	eb 06                	jmp    800987 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	fc                   	cld    
  800985:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800987:	89 f8                	mov    %edi,%eax
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 75 0c             	mov    0xc(%ebp),%esi
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099c:	39 c6                	cmp    %eax,%esi
  80099e:	73 35                	jae    8009d5 <memmove+0x47>
  8009a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a3:	39 d0                	cmp    %edx,%eax
  8009a5:	73 2e                	jae    8009d5 <memmove+0x47>
		s += n;
		d += n;
  8009a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	09 fe                	or     %edi,%esi
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	75 13                	jne    8009c9 <memmove+0x3b>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 0e                	jne    8009c9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009bb:	83 ef 04             	sub    $0x4,%edi
  8009be:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
  8009c4:	fd                   	std    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 09                	jmp    8009d2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c9:	83 ef 01             	sub    $0x1,%edi
  8009cc:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cf:	fd                   	std    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d2:	fc                   	cld    
  8009d3:	eb 1d                	jmp    8009f2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	89 f2                	mov    %esi,%edx
  8009d7:	09 c2                	or     %eax,%edx
  8009d9:	f6 c2 03             	test   $0x3,%dl
  8009dc:	75 0f                	jne    8009ed <memmove+0x5f>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0a                	jne    8009ed <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 05                	jmp    8009f2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f9:	ff 75 10             	pushl  0x10(%ebp)
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	ff 75 08             	pushl  0x8(%ebp)
  800a02:	e8 87 ff ff ff       	call   80098e <memmove>
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a14:	89 c6                	mov    %eax,%esi
  800a16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	eb 1a                	jmp    800a35 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1b:	0f b6 08             	movzbl (%eax),%ecx
  800a1e:	0f b6 1a             	movzbl (%edx),%ebx
  800a21:	38 d9                	cmp    %bl,%cl
  800a23:	74 0a                	je     800a2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a25:	0f b6 c1             	movzbl %cl,%eax
  800a28:	0f b6 db             	movzbl %bl,%ebx
  800a2b:	29 d8                	sub    %ebx,%eax
  800a2d:	eb 0f                	jmp    800a3e <memcmp+0x35>
		s1++, s2++;
  800a2f:	83 c0 01             	add    $0x1,%eax
  800a32:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a35:	39 f0                	cmp    %esi,%eax
  800a37:	75 e2                	jne    800a1b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a49:	89 c1                	mov    %eax,%ecx
  800a4b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a52:	eb 0a                	jmp    800a5e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a54:	0f b6 10             	movzbl (%eax),%edx
  800a57:	39 da                	cmp    %ebx,%edx
  800a59:	74 07                	je     800a62 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	39 c8                	cmp    %ecx,%eax
  800a60:	72 f2                	jb     800a54 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a62:	5b                   	pop    %ebx
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	eb 03                	jmp    800a76 <strtol+0x11>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f6                	je     800a73 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f2                	je     800a73 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	75 0a                	jne    800a8f <strtol+0x2a>
		s++;
  800a85:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8d:	eb 11                	jmp    800aa0 <strtol+0x3b>
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a94:	3c 2d                	cmp    $0x2d,%al
  800a96:	75 08                	jne    800aa0 <strtol+0x3b>
		s++, neg = 1;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa6:	75 15                	jne    800abd <strtol+0x58>
  800aa8:	80 39 30             	cmpb   $0x30,(%ecx)
  800aab:	75 10                	jne    800abd <strtol+0x58>
  800aad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab1:	75 7c                	jne    800b2f <strtol+0xca>
		s += 2, base = 16;
  800ab3:	83 c1 02             	add    $0x2,%ecx
  800ab6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abb:	eb 16                	jmp    800ad3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abd:	85 db                	test   %ebx,%ebx
  800abf:	75 12                	jne    800ad3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac9:	75 08                	jne    800ad3 <strtol+0x6e>
		s++, base = 8;
  800acb:	83 c1 01             	add    $0x1,%ecx
  800ace:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adb:	0f b6 11             	movzbl (%ecx),%edx
  800ade:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 09             	cmp    $0x9,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x8b>
			dig = *s - '0';
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 30             	sub    $0x30,%edx
  800aee:	eb 22                	jmp    800b12 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 57             	sub    $0x57,%edx
  800b00:	eb 10                	jmp    800b12 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 16                	ja     800b22 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b15:	7d 0b                	jge    800b22 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b17:	83 c1 01             	add    $0x1,%ecx
  800b1a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b20:	eb b9                	jmp    800adb <strtol+0x76>

	if (endptr)
  800b22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b26:	74 0d                	je     800b35 <strtol+0xd0>
		*endptr = (char *) s;
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	89 0e                	mov    %ecx,(%esi)
  800b2d:	eb 06                	jmp    800b35 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2f:	85 db                	test   %ebx,%ebx
  800b31:	74 98                	je     800acb <strtol+0x66>
  800b33:	eb 9e                	jmp    800ad3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	f7 da                	neg    %edx
  800b39:	85 ff                	test   %edi,%edi
  800b3b:	0f 45 c2             	cmovne %edx,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	89 c7                	mov    %eax,%edi
  800b58:	89 c6                	mov    %eax,%esi
  800b5a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	89 cb                	mov    %ecx,%ebx
  800b98:	89 cf                	mov    %ecx,%edi
  800b9a:	89 ce                	mov    %ecx,%esi
  800b9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 03                	push   $0x3
  800ba8:	68 ff 2c 80 00       	push   $0x802cff
  800bad:	6a 23                	push   $0x23
  800baf:	68 1c 2d 80 00       	push   $0x802d1c
  800bb4:	e8 e5 f5 ff ff       	call   80019e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_yield>:

void
sys_yield(void)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	89 d7                	mov    %edx,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	be 00 00 00 00       	mov    $0x0,%esi
  800c0d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	89 f7                	mov    %esi,%edi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 04                	push   $0x4
  800c29:	68 ff 2c 80 00       	push   $0x802cff
  800c2e:	6a 23                	push   $0x23
  800c30:	68 1c 2d 80 00       	push   $0x802d1c
  800c35:	e8 64 f5 ff ff       	call   80019e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 05                	push   $0x5
  800c6b:	68 ff 2c 80 00       	push   $0x802cff
  800c70:	6a 23                	push   $0x23
  800c72:	68 1c 2d 80 00       	push   $0x802d1c
  800c77:	e8 22 f5 ff ff       	call   80019e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 06 00 00 00       	mov    $0x6,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 06                	push   $0x6
  800cad:	68 ff 2c 80 00       	push   $0x802cff
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 1c 2d 80 00       	push   $0x802d1c
  800cb9:	e8 e0 f4 ff ff       	call   80019e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 08                	push   $0x8
  800cef:	68 ff 2c 80 00       	push   $0x802cff
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 1c 2d 80 00       	push   $0x802d1c
  800cfb:	e8 9e f4 ff ff       	call   80019e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d16:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d29:	7e 17                	jle    800d42 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 09                	push   $0x9
  800d31:	68 ff 2c 80 00       	push   $0x802cff
  800d36:	6a 23                	push   $0x23
  800d38:	68 1c 2d 80 00       	push   $0x802d1c
  800d3d:	e8 5c f4 ff ff       	call   80019e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d58:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d6b:	7e 17                	jle    800d84 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0a                	push   $0xa
  800d73:	68 ff 2c 80 00       	push   $0x802cff
  800d78:	6a 23                	push   $0x23
  800d7a:	68 1c 2d 80 00       	push   $0x802d1c
  800d7f:	e8 1a f4 ff ff       	call   80019e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 cb                	mov    %ecx,%ebx
  800dc7:	89 cf                	mov    %ecx,%edi
  800dc9:	89 ce                	mov    %ecx,%esi
  800dcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 0d                	push   $0xd
  800dd7:	68 ff 2c 80 00       	push   $0x802cff
  800ddc:	6a 23                	push   $0x23
  800dde:	68 1c 2d 80 00       	push   $0x802d1c
  800de3:	e8 b6 f3 ff ff       	call   80019e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e00:	89 d1                	mov    %edx,%ecx
  800e02:	89 d3                	mov    %edx,%ebx
  800e04:	89 d7                	mov    %edx,%edi
  800e06:	89 d6                	mov    %edx,%esi
  800e08:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e50:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 16             	shr    $0x16,%edx
  800e67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 11                	je     800e84 <fd_alloc+0x2d>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 0c             	shr    $0xc,%edx
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	75 09                	jne    800e8d <fd_alloc+0x36>
			*fd_store = fd;
  800e84:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 17                	jmp    800ea4 <fd_alloc+0x4d>
  800e8d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e97:	75 c9                	jne    800e62 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eac:	83 f8 1f             	cmp    $0x1f,%eax
  800eaf:	77 36                	ja     800ee7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb1:	c1 e0 0c             	shl    $0xc,%eax
  800eb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb9:	89 c2                	mov    %eax,%edx
  800ebb:	c1 ea 16             	shr    $0x16,%edx
  800ebe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec5:	f6 c2 01             	test   $0x1,%dl
  800ec8:	74 24                	je     800eee <fd_lookup+0x48>
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	c1 ea 0c             	shr    $0xc,%edx
  800ecf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed6:	f6 c2 01             	test   $0x1,%dl
  800ed9:	74 1a                	je     800ef5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ede:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	eb 13                	jmp    800efa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eec:	eb 0c                	jmp    800efa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb 05                	jmp    800efa <fd_lookup+0x54>
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f05:	ba a8 2d 80 00       	mov    $0x802da8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0a:	eb 13                	jmp    800f1f <dev_lookup+0x23>
  800f0c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0f:	39 08                	cmp    %ecx,(%eax)
  800f11:	75 0c                	jne    800f1f <dev_lookup+0x23>
			*dev = devtab[i];
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1d:	eb 2e                	jmp    800f4d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1f:	8b 02                	mov    (%edx),%eax
  800f21:	85 c0                	test   %eax,%eax
  800f23:	75 e7                	jne    800f0c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f25:	a1 08 40 80 00       	mov    0x804008,%eax
  800f2a:	8b 40 48             	mov    0x48(%eax),%eax
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	51                   	push   %ecx
  800f31:	50                   	push   %eax
  800f32:	68 2c 2d 80 00       	push   $0x802d2c
  800f37:	e8 3b f3 ff ff       	call   800277 <cprintf>
	*dev = 0;
  800f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 10             	sub    $0x10,%esp
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
  800f6a:	50                   	push   %eax
  800f6b:	e8 36 ff ff ff       	call   800ea6 <fd_lookup>
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 05                	js     800f7c <fd_close+0x2d>
	    || fd != fd2)
  800f77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7a:	74 0c                	je     800f88 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7c:	84 db                	test   %bl,%bl
  800f7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f83:	0f 44 c2             	cmove  %edx,%eax
  800f86:	eb 41                	jmp    800fc9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 36                	pushl  (%esi)
  800f91:	e8 66 ff ff ff       	call   800efc <dev_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 1a                	js     800fb9 <fd_close+0x6a>
		if (dev->dev_close)
  800f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	74 0b                	je     800fb9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	56                   	push   %esi
  800fb2:	ff d0                	call   *%eax
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	56                   	push   %esi
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 c0 fc ff ff       	call   800c84 <sys_page_unmap>
	return r;
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	89 d8                	mov    %ebx,%eax
}
  800fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd9:	50                   	push   %eax
  800fda:	ff 75 08             	pushl  0x8(%ebp)
  800fdd:	e8 c4 fe ff ff       	call   800ea6 <fd_lookup>
  800fe2:	83 c4 08             	add    $0x8,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 10                	js     800ff9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	6a 01                	push   $0x1
  800fee:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff1:	e8 59 ff ff ff       	call   800f4f <fd_close>
  800ff6:	83 c4 10             	add    $0x10,%esp
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <close_all>:

void
close_all(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	53                   	push   %ebx
  80100b:	e8 c0 ff ff ff       	call   800fd0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801010:	83 c3 01             	add    $0x1,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	83 fb 20             	cmp    $0x20,%ebx
  801019:	75 ec                	jne    801007 <close_all+0xc>
		close(i);
}
  80101b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	83 ec 2c             	sub    $0x2c,%esp
  801029:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102f:	50                   	push   %eax
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 6e fe ff ff       	call   800ea6 <fd_lookup>
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 88 c1 00 00 00    	js     801104 <dup+0xe4>
		return r;
	close(newfdnum);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	56                   	push   %esi
  801047:	e8 84 ff ff ff       	call   800fd0 <close>

	newfd = INDEX2FD(newfdnum);
  80104c:	89 f3                	mov    %esi,%ebx
  80104e:	c1 e3 0c             	shl    $0xc,%ebx
  801051:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801057:	83 c4 04             	add    $0x4,%esp
  80105a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105d:	e8 de fd ff ff       	call   800e40 <fd2data>
  801062:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801064:	89 1c 24             	mov    %ebx,(%esp)
  801067:	e8 d4 fd ff ff       	call   800e40 <fd2data>
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801072:	89 f8                	mov    %edi,%eax
  801074:	c1 e8 16             	shr    $0x16,%eax
  801077:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107e:	a8 01                	test   $0x1,%al
  801080:	74 37                	je     8010b9 <dup+0x99>
  801082:	89 f8                	mov    %edi,%eax
  801084:	c1 e8 0c             	shr    $0xc,%eax
  801087:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 26                	je     8010b9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801093:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a2:	50                   	push   %eax
  8010a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a6:	6a 00                	push   $0x0
  8010a8:	57                   	push   %edi
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 92 fb ff ff       	call   800c42 <sys_page_map>
  8010b0:	89 c7                	mov    %eax,%edi
  8010b2:	83 c4 20             	add    $0x20,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 2e                	js     8010e7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bc:	89 d0                	mov    %edx,%eax
  8010be:	c1 e8 0c             	shr    $0xc,%eax
  8010c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d0:	50                   	push   %eax
  8010d1:	53                   	push   %ebx
  8010d2:	6a 00                	push   $0x0
  8010d4:	52                   	push   %edx
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 66 fb ff ff       	call   800c42 <sys_page_map>
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e3:	85 ff                	test   %edi,%edi
  8010e5:	79 1d                	jns    801104 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	53                   	push   %ebx
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 92 fb ff ff       	call   800c84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 85 fb ff ff       	call   800c84 <sys_page_unmap>
	return r;
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	89 f8                	mov    %edi,%eax
}
  801104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	53                   	push   %ebx
  801110:	83 ec 14             	sub    $0x14,%esp
  801113:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801116:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	53                   	push   %ebx
  80111b:	e8 86 fd ff ff       	call   800ea6 <fd_lookup>
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	89 c2                	mov    %eax,%edx
  801125:	85 c0                	test   %eax,%eax
  801127:	78 6d                	js     801196 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801133:	ff 30                	pushl  (%eax)
  801135:	e8 c2 fd ff ff       	call   800efc <dev_lookup>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 4c                	js     80118d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801141:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801144:	8b 42 08             	mov    0x8(%edx),%eax
  801147:	83 e0 03             	and    $0x3,%eax
  80114a:	83 f8 01             	cmp    $0x1,%eax
  80114d:	75 21                	jne    801170 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114f:	a1 08 40 80 00       	mov    0x804008,%eax
  801154:	8b 40 48             	mov    0x48(%eax),%eax
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	53                   	push   %ebx
  80115b:	50                   	push   %eax
  80115c:	68 6d 2d 80 00       	push   $0x802d6d
  801161:	e8 11 f1 ff ff       	call   800277 <cprintf>
		return -E_INVAL;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116e:	eb 26                	jmp    801196 <read+0x8a>
	}
	if (!dev->dev_read)
  801170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801173:	8b 40 08             	mov    0x8(%eax),%eax
  801176:	85 c0                	test   %eax,%eax
  801178:	74 17                	je     801191 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	ff 75 10             	pushl  0x10(%ebp)
  801180:	ff 75 0c             	pushl  0xc(%ebp)
  801183:	52                   	push   %edx
  801184:	ff d0                	call   *%eax
  801186:	89 c2                	mov    %eax,%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	eb 09                	jmp    801196 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	eb 05                	jmp    801196 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801191:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801196:	89 d0                	mov    %edx,%eax
  801198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	eb 21                	jmp    8011d4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	89 f0                	mov    %esi,%eax
  8011b8:	29 d8                	sub    %ebx,%eax
  8011ba:	50                   	push   %eax
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	03 45 0c             	add    0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	57                   	push   %edi
  8011c2:	e8 45 ff ff ff       	call   80110c <read>
		if (m < 0)
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 10                	js     8011de <readn+0x41>
			return m;
		if (m == 0)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 0a                	je     8011dc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d2:	01 c3                	add    %eax,%ebx
  8011d4:	39 f3                	cmp    %esi,%ebx
  8011d6:	72 db                	jb     8011b3 <readn+0x16>
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	eb 02                	jmp    8011de <readn+0x41>
  8011dc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 14             	sub    $0x14,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	53                   	push   %ebx
  8011f5:	e8 ac fc ff ff       	call   800ea6 <fd_lookup>
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 68                	js     80126b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	ff 30                	pushl  (%eax)
  80120f:	e8 e8 fc ff ff       	call   800efc <dev_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 47                	js     801262 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801222:	75 21                	jne    801245 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801224:	a1 08 40 80 00       	mov    0x804008,%eax
  801229:	8b 40 48             	mov    0x48(%eax),%eax
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	53                   	push   %ebx
  801230:	50                   	push   %eax
  801231:	68 89 2d 80 00       	push   $0x802d89
  801236:	e8 3c f0 ff ff       	call   800277 <cprintf>
		return -E_INVAL;
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801243:	eb 26                	jmp    80126b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801245:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801248:	8b 52 0c             	mov    0xc(%edx),%edx
  80124b:	85 d2                	test   %edx,%edx
  80124d:	74 17                	je     801266 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	ff 75 10             	pushl  0x10(%ebp)
  801255:	ff 75 0c             	pushl  0xc(%ebp)
  801258:	50                   	push   %eax
  801259:	ff d2                	call   *%edx
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	eb 09                	jmp    80126b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801262:	89 c2                	mov    %eax,%edx
  801264:	eb 05                	jmp    80126b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801266:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126b:	89 d0                	mov    %edx,%eax
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <seek>:

int
seek(int fdnum, off_t offset)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 22 fc ff ff       	call   800ea6 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 0e                	js     801299 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801291:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 14             	sub    $0x14,%esp
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	53                   	push   %ebx
  8012aa:	e8 f7 fb ff ff       	call   800ea6 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 65                	js     80131d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	ff 30                	pushl  (%eax)
  8012c4:	e8 33 fc ff ff       	call   800efc <dev_lookup>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 44                	js     801314 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d7:	75 21                	jne    8012fa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012de:	8b 40 48             	mov    0x48(%eax),%eax
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	50                   	push   %eax
  8012e6:	68 4c 2d 80 00       	push   $0x802d4c
  8012eb:	e8 87 ef ff ff       	call   800277 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f8:	eb 23                	jmp    80131d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fd:	8b 52 18             	mov    0x18(%edx),%edx
  801300:	85 d2                	test   %edx,%edx
  801302:	74 14                	je     801318 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 0c             	pushl  0xc(%ebp)
  80130a:	50                   	push   %eax
  80130b:	ff d2                	call   *%edx
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 09                	jmp    80131d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	89 c2                	mov    %eax,%edx
  801316:	eb 05                	jmp    80131d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801318:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
  80132b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 6c fb ff ff       	call   800ea6 <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 58                	js     80139b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	ff 30                	pushl  (%eax)
  80134f:	e8 a8 fb ff ff       	call   800efc <dev_lookup>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 37                	js     801392 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801362:	74 32                	je     801396 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801364:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801367:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136e:	00 00 00 
	stat->st_isdir = 0;
  801371:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801378:	00 00 00 
	stat->st_dev = dev;
  80137b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	ff 75 f0             	pushl  -0x10(%ebp)
  801388:	ff 50 14             	call   *0x14(%eax)
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	eb 09                	jmp    80139b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801392:	89 c2                	mov    %eax,%edx
  801394:	eb 05                	jmp    80139b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801396:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	6a 00                	push   $0x0
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 e7 01 00 00       	call   80159b <open>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 1b                	js     8013d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	50                   	push   %eax
  8013c4:	e8 5b ff ff ff       	call   801324 <fstat>
  8013c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cb:	89 1c 24             	mov    %ebx,(%esp)
  8013ce:	e8 fd fb ff ff       	call   800fd0 <close>
	return r;
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	89 f0                	mov    %esi,%eax
}
  8013d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	89 c6                	mov    %eax,%esi
  8013e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ef:	75 12                	jne    801403 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	6a 01                	push   $0x1
  8013f6:	e8 f5 11 00 00       	call   8025f0 <ipc_find_env>
  8013fb:	a3 00 40 80 00       	mov    %eax,0x804000
  801400:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801403:	6a 07                	push   $0x7
  801405:	68 00 50 80 00       	push   $0x805000
  80140a:	56                   	push   %esi
  80140b:	ff 35 00 40 80 00    	pushl  0x804000
  801411:	e8 86 11 00 00       	call   80259c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801416:	83 c4 0c             	add    $0xc,%esp
  801419:	6a 00                	push   $0x0
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 0c 11 00 00       	call   80252f <ipc_recv>
}
  801423:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 02 00 00 00       	mov    $0x2,%eax
  80144d:	e8 8d ff ff ff       	call   8013df <fsipc>
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	b8 06 00 00 00       	mov    $0x6,%eax
  80146f:	e8 6b ff ff ff       	call   8013df <fsipc>
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148b:	ba 00 00 00 00       	mov    $0x0,%edx
  801490:	b8 05 00 00 00       	mov    $0x5,%eax
  801495:	e8 45 ff ff ff       	call   8013df <fsipc>
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 2c                	js     8014ca <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	68 00 50 80 00       	push   $0x805000
  8014a6:	53                   	push   %ebx
  8014a7:	e8 50 f3 ff ff       	call   8007fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8014bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8014d9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014de:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014e3:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e6:	53                   	push   %ebx
  8014e7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ea:	68 08 50 80 00       	push   $0x805008
  8014ef:	e8 9a f4 ff ff       	call   80098e <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fa:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8014ff:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801505:	ba 00 00 00 00       	mov    $0x0,%edx
  80150a:	b8 04 00 00 00       	mov    $0x4,%eax
  80150f:	e8 cb fe ff ff       	call   8013df <fsipc>
	//panic("devfile_write not implemented");
}
  801514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801517:	c9                   	leave  
  801518:	c3                   	ret    

00801519 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801521:	8b 45 08             	mov    0x8(%ebp),%eax
  801524:	8b 40 0c             	mov    0xc(%eax),%eax
  801527:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80152c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801532:	ba 00 00 00 00       	mov    $0x0,%edx
  801537:	b8 03 00 00 00       	mov    $0x3,%eax
  80153c:	e8 9e fe ff ff       	call   8013df <fsipc>
  801541:	89 c3                	mov    %eax,%ebx
  801543:	85 c0                	test   %eax,%eax
  801545:	78 4b                	js     801592 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801547:	39 c6                	cmp    %eax,%esi
  801549:	73 16                	jae    801561 <devfile_read+0x48>
  80154b:	68 bc 2d 80 00       	push   $0x802dbc
  801550:	68 c3 2d 80 00       	push   $0x802dc3
  801555:	6a 7c                	push   $0x7c
  801557:	68 d8 2d 80 00       	push   $0x802dd8
  80155c:	e8 3d ec ff ff       	call   80019e <_panic>
	assert(r <= PGSIZE);
  801561:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801566:	7e 16                	jle    80157e <devfile_read+0x65>
  801568:	68 e3 2d 80 00       	push   $0x802de3
  80156d:	68 c3 2d 80 00       	push   $0x802dc3
  801572:	6a 7d                	push   $0x7d
  801574:	68 d8 2d 80 00       	push   $0x802dd8
  801579:	e8 20 ec ff ff       	call   80019e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157e:	83 ec 04             	sub    $0x4,%esp
  801581:	50                   	push   %eax
  801582:	68 00 50 80 00       	push   $0x805000
  801587:	ff 75 0c             	pushl  0xc(%ebp)
  80158a:	e8 ff f3 ff ff       	call   80098e <memmove>
	return r;
  80158f:	83 c4 10             	add    $0x10,%esp
}
  801592:	89 d8                	mov    %ebx,%eax
  801594:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    

0080159b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	53                   	push   %ebx
  80159f:	83 ec 20             	sub    $0x20,%esp
  8015a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a5:	53                   	push   %ebx
  8015a6:	e8 18 f2 ff ff       	call   8007c3 <strlen>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b3:	7f 67                	jg     80161c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	e8 96 f8 ff ff       	call   800e57 <fd_alloc>
  8015c1:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 57                	js     801621 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	68 00 50 80 00       	push   $0x805000
  8015d3:	e8 24 f2 ff ff       	call   8007fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015db:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e8:	e8 f2 fd ff ff       	call   8013df <fsipc>
  8015ed:	89 c3                	mov    %eax,%ebx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	79 14                	jns    80160a <open+0x6f>
		fd_close(fd, 0);
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	6a 00                	push   $0x0
  8015fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fe:	e8 4c f9 ff ff       	call   800f4f <fd_close>
		return r;
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	89 da                	mov    %ebx,%edx
  801608:	eb 17                	jmp    801621 <open+0x86>
	}

	return fd2num(fd);
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	ff 75 f4             	pushl  -0xc(%ebp)
  801610:	e8 1b f8 ff ff       	call   800e30 <fd2num>
  801615:	89 c2                	mov    %eax,%edx
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb 05                	jmp    801621 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80161c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801621:	89 d0                	mov    %edx,%eax
  801623:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162e:	ba 00 00 00 00       	mov    $0x0,%edx
  801633:	b8 08 00 00 00       	mov    $0x8,%eax
  801638:	e8 a2 fd ff ff       	call   8013df <fsipc>
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	57                   	push   %edi
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
  801645:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80164b:	6a 00                	push   $0x0
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 46 ff ff ff       	call   80159b <open>
  801655:	89 c7                	mov    %eax,%edi
  801657:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	85 c0                	test   %eax,%eax
  801662:	0f 88 a4 04 00 00    	js     801b0c <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801668:	83 ec 04             	sub    $0x4,%esp
  80166b:	68 00 02 00 00       	push   $0x200
  801670:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801676:	50                   	push   %eax
  801677:	57                   	push   %edi
  801678:	e8 20 fb ff ff       	call   80119d <readn>
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	3d 00 02 00 00       	cmp    $0x200,%eax
  801685:	75 0c                	jne    801693 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801687:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80168e:	45 4c 46 
  801691:	74 33                	je     8016c6 <spawn+0x87>
		close(fd);
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80169c:	e8 2f f9 ff ff       	call   800fd0 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016a1:	83 c4 0c             	add    $0xc,%esp
  8016a4:	68 7f 45 4c 46       	push   $0x464c457f
  8016a9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016af:	68 ef 2d 80 00       	push   $0x802def
  8016b4:	e8 be eb ff ff       	call   800277 <cprintf>
		return -E_NOT_EXEC;
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016c1:	e9 a6 04 00 00       	jmp    801b6c <spawn+0x52d>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016c6:	b8 07 00 00 00       	mov    $0x7,%eax
  8016cb:	cd 30                	int    $0x30
  8016cd:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016d3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	0f 88 33 04 00 00    	js     801b14 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016e1:	89 c6                	mov    %eax,%esi
  8016e3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016e9:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016ec:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016f2:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016f8:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016ff:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801705:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80170b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801710:	be 00 00 00 00       	mov    $0x0,%esi
  801715:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801718:	eb 13                	jmp    80172d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	50                   	push   %eax
  80171e:	e8 a0 f0 ff ff       	call   8007c3 <strlen>
  801723:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801727:	83 c3 01             	add    $0x1,%ebx
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801734:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801737:	85 c0                	test   %eax,%eax
  801739:	75 df                	jne    80171a <spawn+0xdb>
  80173b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801741:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801747:	bf 00 10 40 00       	mov    $0x401000,%edi
  80174c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80174e:	89 fa                	mov    %edi,%edx
  801750:	83 e2 fc             	and    $0xfffffffc,%edx
  801753:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80175a:	29 c2                	sub    %eax,%edx
  80175c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801762:	8d 42 f8             	lea    -0x8(%edx),%eax
  801765:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80176a:	0f 86 b4 03 00 00    	jbe    801b24 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801770:	83 ec 04             	sub    $0x4,%esp
  801773:	6a 07                	push   $0x7
  801775:	68 00 00 40 00       	push   $0x400000
  80177a:	6a 00                	push   $0x0
  80177c:	e8 7e f4 ff ff       	call   800bff <sys_page_alloc>
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	0f 88 9f 03 00 00    	js     801b2b <spawn+0x4ec>
  80178c:	be 00 00 00 00       	mov    $0x0,%esi
  801791:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80179a:	eb 30                	jmp    8017cc <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80179c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017a2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017a8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b1:	57                   	push   %edi
  8017b2:	e8 45 f0 ff ff       	call   8007fc <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017b7:	83 c4 04             	add    $0x4,%esp
  8017ba:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017bd:	e8 01 f0 ff ff       	call   8007c3 <strlen>
  8017c2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017c6:	83 c6 01             	add    $0x1,%esi
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017d2:	7f c8                	jg     80179c <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017d4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017da:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017e0:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017e7:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017ed:	74 19                	je     801808 <spawn+0x1c9>
  8017ef:	68 64 2e 80 00       	push   $0x802e64
  8017f4:	68 c3 2d 80 00       	push   $0x802dc3
  8017f9:	68 f1 00 00 00       	push   $0xf1
  8017fe:	68 09 2e 80 00       	push   $0x802e09
  801803:	e8 96 e9 ff ff       	call   80019e <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801808:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80180e:	89 f8                	mov    %edi,%eax
  801810:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801815:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801818:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80181e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801821:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801827:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	6a 07                	push   $0x7
  801832:	68 00 d0 bf ee       	push   $0xeebfd000
  801837:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80183d:	68 00 00 40 00       	push   $0x400000
  801842:	6a 00                	push   $0x0
  801844:	e8 f9 f3 ff ff       	call   800c42 <sys_page_map>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 20             	add    $0x20,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 04 03 00 00    	js     801b5a <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	68 00 00 40 00       	push   $0x400000
  80185e:	6a 00                	push   $0x0
  801860:	e8 1f f4 ff ff       	call   800c84 <sys_page_unmap>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	0f 88 e8 02 00 00    	js     801b5a <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801872:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801878:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80187f:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801885:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80188c:	00 00 00 
  80188f:	e9 88 01 00 00       	jmp    801a1c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801894:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80189a:	83 38 01             	cmpl   $0x1,(%eax)
  80189d:	0f 85 6b 01 00 00    	jne    801a0e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018a3:	89 c7                	mov    %eax,%edi
  8018a5:	8b 40 18             	mov    0x18(%eax),%eax
  8018a8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018ae:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018b1:	83 f8 01             	cmp    $0x1,%eax
  8018b4:	19 c0                	sbb    %eax,%eax
  8018b6:	83 e0 fe             	and    $0xfffffffe,%eax
  8018b9:	83 c0 07             	add    $0x7,%eax
  8018bc:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018c2:	89 f8                	mov    %edi,%eax
  8018c4:	8b 7f 04             	mov    0x4(%edi),%edi
  8018c7:	89 f9                	mov    %edi,%ecx
  8018c9:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018cf:	8b 78 10             	mov    0x10(%eax),%edi
  8018d2:	8b 50 14             	mov    0x14(%eax),%edx
  8018d5:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8018db:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018de:	89 f0                	mov    %esi,%eax
  8018e0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018e5:	74 14                	je     8018fb <spawn+0x2bc>
		va -= i;
  8018e7:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018e9:	01 c2                	add    %eax,%edx
  8018eb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018f1:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018f3:	29 c1                	sub    %eax,%ecx
  8018f5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801900:	e9 f7 00 00 00       	jmp    8019fc <spawn+0x3bd>
		if (i >= filesz) {
  801905:	39 df                	cmp    %ebx,%edi
  801907:	77 27                	ja     801930 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801909:	83 ec 04             	sub    $0x4,%esp
  80190c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801912:	56                   	push   %esi
  801913:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801919:	e8 e1 f2 ff ff       	call   800bff <sys_page_alloc>
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	0f 89 c7 00 00 00    	jns    8019f0 <spawn+0x3b1>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	e9 09 02 00 00       	jmp    801b39 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801930:	83 ec 04             	sub    $0x4,%esp
  801933:	6a 07                	push   $0x7
  801935:	68 00 00 40 00       	push   $0x400000
  80193a:	6a 00                	push   $0x0
  80193c:	e8 be f2 ff ff       	call   800bff <sys_page_alloc>
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	0f 88 e3 01 00 00    	js     801b2f <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801955:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80195b:	50                   	push   %eax
  80195c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801962:	e8 0b f9 ff ff       	call   801272 <seek>
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	85 c0                	test   %eax,%eax
  80196c:	0f 88 c1 01 00 00    	js     801b33 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801972:	83 ec 04             	sub    $0x4,%esp
  801975:	89 f8                	mov    %edi,%eax
  801977:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80197d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801982:	ba 00 10 00 00       	mov    $0x1000,%edx
  801987:	0f 47 c2             	cmova  %edx,%eax
  80198a:	50                   	push   %eax
  80198b:	68 00 00 40 00       	push   $0x400000
  801990:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801996:	e8 02 f8 ff ff       	call   80119d <readn>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	0f 88 91 01 00 00    	js     801b37 <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019af:	56                   	push   %esi
  8019b0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019b6:	68 00 00 40 00       	push   $0x400000
  8019bb:	6a 00                	push   $0x0
  8019bd:	e8 80 f2 ff ff       	call   800c42 <sys_page_map>
  8019c2:	83 c4 20             	add    $0x20,%esp
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	79 15                	jns    8019de <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019c9:	50                   	push   %eax
  8019ca:	68 15 2e 80 00       	push   $0x802e15
  8019cf:	68 24 01 00 00       	push   $0x124
  8019d4:	68 09 2e 80 00       	push   $0x802e09
  8019d9:	e8 c0 e7 ff ff       	call   80019e <_panic>
			sys_page_unmap(0, UTEMP);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	68 00 00 40 00       	push   $0x400000
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 97 f2 ff ff       	call   800c84 <sys_page_unmap>
  8019ed:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f6:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019fc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a02:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a08:	0f 87 f7 fe ff ff    	ja     801905 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a0e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a15:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a1c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a23:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a29:	0f 8c 65 fe ff ff    	jl     801894 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a38:	e8 93 f5 ff ff       	call   800fd0 <close>
  801a3d:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801a40:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a45:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
 	{
    	if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)) {
  801a4b:	89 d8                	mov    %ebx,%eax
  801a4d:	c1 e8 16             	shr    $0x16,%eax
  801a50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a57:	a8 01                	test   $0x1,%al
  801a59:	74 46                	je     801aa1 <spawn+0x462>
  801a5b:	89 d8                	mov    %ebx,%eax
  801a5d:	c1 e8 0c             	shr    $0xc,%eax
  801a60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a67:	f6 c2 01             	test   $0x1,%dl
  801a6a:	74 35                	je     801aa1 <spawn+0x462>
  801a6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a73:	f6 c2 04             	test   $0x4,%dl
  801a76:	74 29                	je     801aa1 <spawn+0x462>
  801a78:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a7f:	f6 c6 04             	test   $0x4,%dh
  801a82:	74 1d                	je     801aa1 <spawn+0x462>
        	sys_page_map(0, (void*)i, child, (void*)i, (uvpt[PGNUM(i)] & PTE_SYSCALL));
  801a84:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	25 07 0e 00 00       	and    $0xe07,%eax
  801a93:	50                   	push   %eax
  801a94:	53                   	push   %ebx
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	6a 00                	push   $0x0
  801a99:	e8 a4 f1 ff ff       	call   800c42 <sys_page_map>
  801a9e:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801aa1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aa7:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801aad:	75 9c                	jne    801a4b <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801abf:	e8 44 f2 ff ff       	call   800d08 <sys_env_set_trapframe>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	79 15                	jns    801ae0 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  801acb:	50                   	push   %eax
  801acc:	68 32 2e 80 00       	push   $0x802e32
  801ad1:	68 85 00 00 00       	push   $0x85
  801ad6:	68 09 2e 80 00       	push   $0x802e09
  801adb:	e8 be e6 ff ff       	call   80019e <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	6a 02                	push   $0x2
  801ae5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aeb:	e8 d6 f1 ff ff       	call   800cc6 <sys_env_set_status>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	79 25                	jns    801b1c <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801af7:	50                   	push   %eax
  801af8:	68 4c 2e 80 00       	push   $0x802e4c
  801afd:	68 88 00 00 00       	push   $0x88
  801b02:	68 09 2e 80 00       	push   $0x802e09
  801b07:	e8 92 e6 ff ff       	call   80019e <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b0c:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b12:	eb 58                	jmp    801b6c <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b14:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b1a:	eb 50                	jmp    801b6c <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b1c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b22:	eb 48                	jmp    801b6c <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b24:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b29:	eb 41                	jmp    801b6c <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	eb 3d                	jmp    801b6c <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	eb 06                	jmp    801b39 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	eb 02                	jmp    801b39 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b37:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b39:	83 ec 0c             	sub    $0xc,%esp
  801b3c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b42:	e8 39 f0 ff ff       	call   800b80 <sys_env_destroy>
	close(fd);
  801b47:	83 c4 04             	add    $0x4,%esp
  801b4a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b50:	e8 7b f4 ff ff       	call   800fd0 <close>
	return r;
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	eb 12                	jmp    801b6c <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b5a:	83 ec 08             	sub    $0x8,%esp
  801b5d:	68 00 00 40 00       	push   $0x400000
  801b62:	6a 00                	push   $0x0
  801b64:	e8 1b f1 ff ff       	call   800c84 <sys_page_unmap>
  801b69:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b6c:	89 d8                	mov    %ebx,%eax
  801b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	56                   	push   %esi
  801b7a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b7b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b7e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b83:	eb 03                	jmp    801b88 <spawnl+0x12>
		argc++;
  801b85:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b88:	83 c2 04             	add    $0x4,%edx
  801b8b:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b8f:	75 f4                	jne    801b85 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b91:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b98:	83 e2 f0             	and    $0xfffffff0,%edx
  801b9b:	29 d4                	sub    %edx,%esp
  801b9d:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ba1:	c1 ea 02             	shr    $0x2,%edx
  801ba4:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801bab:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bb7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bbe:	00 
  801bbf:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	eb 0a                	jmp    801bd2 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bc8:	83 c0 01             	add    $0x1,%eax
  801bcb:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bcf:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bd2:	39 d0                	cmp    %edx,%eax
  801bd4:	75 f2                	jne    801bc8 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bd6:	83 ec 08             	sub    $0x8,%esp
  801bd9:	56                   	push   %esi
  801bda:	ff 75 08             	pushl  0x8(%ebp)
  801bdd:	e8 5d fa ff ff       	call   80163f <spawn>
}
  801be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bef:	68 8c 2e 80 00       	push   $0x802e8c
  801bf4:	ff 75 0c             	pushl  0xc(%ebp)
  801bf7:	e8 00 ec ff ff       	call   8007fc <strcpy>
	return 0;
}
  801bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	53                   	push   %ebx
  801c07:	83 ec 10             	sub    $0x10,%esp
  801c0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c0d:	53                   	push   %ebx
  801c0e:	e8 16 0a 00 00       	call   802629 <pageref>
  801c13:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c16:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c1b:	83 f8 01             	cmp    $0x1,%eax
  801c1e:	75 10                	jne    801c30 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c20:	83 ec 0c             	sub    $0xc,%esp
  801c23:	ff 73 0c             	pushl  0xc(%ebx)
  801c26:	e8 c0 02 00 00       	call   801eeb <nsipc_close>
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c30:	89 d0                	mov    %edx,%eax
  801c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c3d:	6a 00                	push   $0x0
  801c3f:	ff 75 10             	pushl  0x10(%ebp)
  801c42:	ff 75 0c             	pushl  0xc(%ebp)
  801c45:	8b 45 08             	mov    0x8(%ebp),%eax
  801c48:	ff 70 0c             	pushl  0xc(%eax)
  801c4b:	e8 78 03 00 00       	call   801fc8 <nsipc_send>
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c58:	6a 00                	push   $0x0
  801c5a:	ff 75 10             	pushl  0x10(%ebp)
  801c5d:	ff 75 0c             	pushl  0xc(%ebp)
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	ff 70 0c             	pushl  0xc(%eax)
  801c66:	e8 f1 02 00 00       	call   801f5c <nsipc_recv>
}
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c73:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c76:	52                   	push   %edx
  801c77:	50                   	push   %eax
  801c78:	e8 29 f2 ff ff       	call   800ea6 <fd_lookup>
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 17                	js     801c9b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c87:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c8d:	39 08                	cmp    %ecx,(%eax)
  801c8f:	75 05                	jne    801c96 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c91:	8b 40 0c             	mov    0xc(%eax),%eax
  801c94:	eb 05                	jmp    801c9b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c96:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 1c             	sub    $0x1c,%esp
  801ca5:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ca7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801caa:	50                   	push   %eax
  801cab:	e8 a7 f1 ff ff       	call   800e57 <fd_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 1b                	js     801cd4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	68 07 04 00 00       	push   $0x407
  801cc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 34 ef ff ff       	call   800bff <sys_page_alloc>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	79 10                	jns    801ce4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	56                   	push   %esi
  801cd8:	e8 0e 02 00 00       	call   801eeb <nsipc_close>
		return r;
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	eb 24                	jmp    801d08 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ce4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ced:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cf9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	50                   	push   %eax
  801d00:	e8 2b f1 ff ff       	call   800e30 <fd2num>
  801d05:	83 c4 10             	add    $0x10,%esp
}
  801d08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0b:	5b                   	pop    %ebx
  801d0c:	5e                   	pop    %esi
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	e8 50 ff ff ff       	call   801c6d <fd2sockid>
		return r;
  801d1d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 1f                	js     801d42 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	ff 75 10             	pushl  0x10(%ebp)
  801d29:	ff 75 0c             	pushl  0xc(%ebp)
  801d2c:	50                   	push   %eax
  801d2d:	e8 12 01 00 00       	call   801e44 <nsipc_accept>
  801d32:	83 c4 10             	add    $0x10,%esp
		return r;
  801d35:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 07                	js     801d42 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d3b:	e8 5d ff ff ff       	call   801c9d <alloc_sockfd>
  801d40:	89 c1                	mov    %eax,%ecx
}
  801d42:	89 c8                	mov    %ecx,%eax
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	e8 19 ff ff ff       	call   801c6d <fd2sockid>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	78 12                	js     801d6a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d58:	83 ec 04             	sub    $0x4,%esp
  801d5b:	ff 75 10             	pushl  0x10(%ebp)
  801d5e:	ff 75 0c             	pushl  0xc(%ebp)
  801d61:	50                   	push   %eax
  801d62:	e8 2d 01 00 00       	call   801e94 <nsipc_bind>
  801d67:	83 c4 10             	add    $0x10,%esp
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <shutdown>:

int
shutdown(int s, int how)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	e8 f3 fe ff ff       	call   801c6d <fd2sockid>
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 0f                	js     801d8d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d7e:	83 ec 08             	sub    $0x8,%esp
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	50                   	push   %eax
  801d85:	e8 3f 01 00 00       	call   801ec9 <nsipc_shutdown>
  801d8a:	83 c4 10             	add    $0x10,%esp
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	e8 d0 fe ff ff       	call   801c6d <fd2sockid>
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 12                	js     801db3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	ff 75 10             	pushl  0x10(%ebp)
  801da7:	ff 75 0c             	pushl  0xc(%ebp)
  801daa:	50                   	push   %eax
  801dab:	e8 55 01 00 00       	call   801f05 <nsipc_connect>
  801db0:	83 c4 10             	add    $0x10,%esp
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <listen>:

int
listen(int s, int backlog)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	e8 aa fe ff ff       	call   801c6d <fd2sockid>
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	78 0f                	js     801dd6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801dc7:	83 ec 08             	sub    $0x8,%esp
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	50                   	push   %eax
  801dce:	e8 67 01 00 00       	call   801f3a <nsipc_listen>
  801dd3:	83 c4 10             	add    $0x10,%esp
}
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dde:	ff 75 10             	pushl  0x10(%ebp)
  801de1:	ff 75 0c             	pushl  0xc(%ebp)
  801de4:	ff 75 08             	pushl  0x8(%ebp)
  801de7:	e8 3a 02 00 00       	call   802026 <nsipc_socket>
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	85 c0                	test   %eax,%eax
  801df1:	78 05                	js     801df8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801df3:	e8 a5 fe ff ff       	call   801c9d <alloc_sockfd>
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	53                   	push   %ebx
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e03:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e0a:	75 12                	jne    801e1e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	6a 02                	push   $0x2
  801e11:	e8 da 07 00 00       	call   8025f0 <ipc_find_env>
  801e16:	a3 04 40 80 00       	mov    %eax,0x804004
  801e1b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e1e:	6a 07                	push   $0x7
  801e20:	68 00 60 80 00       	push   $0x806000
  801e25:	53                   	push   %ebx
  801e26:	ff 35 04 40 80 00    	pushl  0x804004
  801e2c:	e8 6b 07 00 00       	call   80259c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e31:	83 c4 0c             	add    $0xc,%esp
  801e34:	6a 00                	push   $0x0
  801e36:	6a 00                	push   $0x0
  801e38:	6a 00                	push   $0x0
  801e3a:	e8 f0 06 00 00       	call   80252f <ipc_recv>
}
  801e3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e42:	c9                   	leave  
  801e43:	c3                   	ret    

00801e44 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e54:	8b 06                	mov    (%esi),%eax
  801e56:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e60:	e8 95 ff ff ff       	call   801dfa <nsipc>
  801e65:	89 c3                	mov    %eax,%ebx
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 20                	js     801e8b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e6b:	83 ec 04             	sub    $0x4,%esp
  801e6e:	ff 35 10 60 80 00    	pushl  0x806010
  801e74:	68 00 60 80 00       	push   $0x806000
  801e79:	ff 75 0c             	pushl  0xc(%ebp)
  801e7c:	e8 0d eb ff ff       	call   80098e <memmove>
		*addrlen = ret->ret_addrlen;
  801e81:	a1 10 60 80 00       	mov    0x806010,%eax
  801e86:	89 06                	mov    %eax,(%esi)
  801e88:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e8b:	89 d8                	mov    %ebx,%eax
  801e8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	53                   	push   %ebx
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ea6:	53                   	push   %ebx
  801ea7:	ff 75 0c             	pushl  0xc(%ebp)
  801eaa:	68 04 60 80 00       	push   $0x806004
  801eaf:	e8 da ea ff ff       	call   80098e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801eb4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801eba:	b8 02 00 00 00       	mov    $0x2,%eax
  801ebf:	e8 36 ff ff ff       	call   801dfa <nsipc>
}
  801ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eda:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801edf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ee4:	e8 11 ff ff ff       	call   801dfa <nsipc>
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <nsipc_close>:

int
nsipc_close(int s)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ef9:	b8 04 00 00 00       	mov    $0x4,%eax
  801efe:	e8 f7 fe ff ff       	call   801dfa <nsipc>
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	53                   	push   %ebx
  801f09:	83 ec 08             	sub    $0x8,%esp
  801f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f17:	53                   	push   %ebx
  801f18:	ff 75 0c             	pushl  0xc(%ebp)
  801f1b:	68 04 60 80 00       	push   $0x806004
  801f20:	e8 69 ea ff ff       	call   80098e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f25:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f2b:	b8 05 00 00 00       	mov    $0x5,%eax
  801f30:	e8 c5 fe ff ff       	call   801dfa <nsipc>
}
  801f35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f50:	b8 06 00 00 00       	mov    $0x6,%eax
  801f55:	e8 a0 fe ff ff       	call   801dfa <nsipc>
}
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    

00801f5c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	56                   	push   %esi
  801f60:	53                   	push   %ebx
  801f61:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f64:	8b 45 08             	mov    0x8(%ebp),%eax
  801f67:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f6c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f72:	8b 45 14             	mov    0x14(%ebp),%eax
  801f75:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f7a:	b8 07 00 00 00       	mov    $0x7,%eax
  801f7f:	e8 76 fe ff ff       	call   801dfa <nsipc>
  801f84:	89 c3                	mov    %eax,%ebx
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 35                	js     801fbf <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f8a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f8f:	7f 04                	jg     801f95 <nsipc_recv+0x39>
  801f91:	39 c6                	cmp    %eax,%esi
  801f93:	7d 16                	jge    801fab <nsipc_recv+0x4f>
  801f95:	68 98 2e 80 00       	push   $0x802e98
  801f9a:	68 c3 2d 80 00       	push   $0x802dc3
  801f9f:	6a 62                	push   $0x62
  801fa1:	68 ad 2e 80 00       	push   $0x802ead
  801fa6:	e8 f3 e1 ff ff       	call   80019e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fab:	83 ec 04             	sub    $0x4,%esp
  801fae:	50                   	push   %eax
  801faf:	68 00 60 80 00       	push   $0x806000
  801fb4:	ff 75 0c             	pushl  0xc(%ebp)
  801fb7:	e8 d2 e9 ff ff       	call   80098e <memmove>
  801fbc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801fbf:	89 d8                	mov    %ebx,%eax
  801fc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 04             	sub    $0x4,%esp
  801fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fda:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fe0:	7e 16                	jle    801ff8 <nsipc_send+0x30>
  801fe2:	68 b9 2e 80 00       	push   $0x802eb9
  801fe7:	68 c3 2d 80 00       	push   $0x802dc3
  801fec:	6a 6d                	push   $0x6d
  801fee:	68 ad 2e 80 00       	push   $0x802ead
  801ff3:	e8 a6 e1 ff ff       	call   80019e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ff8:	83 ec 04             	sub    $0x4,%esp
  801ffb:	53                   	push   %ebx
  801ffc:	ff 75 0c             	pushl  0xc(%ebp)
  801fff:	68 0c 60 80 00       	push   $0x80600c
  802004:	e8 85 e9 ff ff       	call   80098e <memmove>
	nsipcbuf.send.req_size = size;
  802009:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80200f:	8b 45 14             	mov    0x14(%ebp),%eax
  802012:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802017:	b8 08 00 00 00       	mov    $0x8,%eax
  80201c:	e8 d9 fd ff ff       	call   801dfa <nsipc>
}
  802021:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802034:	8b 45 0c             	mov    0xc(%ebp),%eax
  802037:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80203c:	8b 45 10             	mov    0x10(%ebp),%eax
  80203f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802044:	b8 09 00 00 00       	mov    $0x9,%eax
  802049:	e8 ac fd ff ff       	call   801dfa <nsipc>
}
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	ff 75 08             	pushl  0x8(%ebp)
  80205e:	e8 dd ed ff ff       	call   800e40 <fd2data>
  802063:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802065:	83 c4 08             	add    $0x8,%esp
  802068:	68 c5 2e 80 00       	push   $0x802ec5
  80206d:	53                   	push   %ebx
  80206e:	e8 89 e7 ff ff       	call   8007fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802073:	8b 46 04             	mov    0x4(%esi),%eax
  802076:	2b 06                	sub    (%esi),%eax
  802078:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80207e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802085:	00 00 00 
	stat->st_dev = &devpipe;
  802088:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80208f:	30 80 00 
	return 0;
}
  802092:	b8 00 00 00 00       	mov    $0x0,%eax
  802097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209a:	5b                   	pop    %ebx
  80209b:	5e                   	pop    %esi
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    

0080209e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	53                   	push   %ebx
  8020a2:	83 ec 0c             	sub    $0xc,%esp
  8020a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020a8:	53                   	push   %ebx
  8020a9:	6a 00                	push   $0x0
  8020ab:	e8 d4 eb ff ff       	call   800c84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020b0:	89 1c 24             	mov    %ebx,(%esp)
  8020b3:	e8 88 ed ff ff       	call   800e40 <fd2data>
  8020b8:	83 c4 08             	add    $0x8,%esp
  8020bb:	50                   	push   %eax
  8020bc:	6a 00                	push   $0x0
  8020be:	e8 c1 eb ff ff       	call   800c84 <sys_page_unmap>
}
  8020c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    

008020c8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	57                   	push   %edi
  8020cc:	56                   	push   %esi
  8020cd:	53                   	push   %ebx
  8020ce:	83 ec 1c             	sub    $0x1c,%esp
  8020d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020d4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8020db:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020de:	83 ec 0c             	sub    $0xc,%esp
  8020e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8020e4:	e8 40 05 00 00       	call   802629 <pageref>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	89 3c 24             	mov    %edi,(%esp)
  8020ee:	e8 36 05 00 00       	call   802629 <pageref>
  8020f3:	83 c4 10             	add    $0x10,%esp
  8020f6:	39 c3                	cmp    %eax,%ebx
  8020f8:	0f 94 c1             	sete   %cl
  8020fb:	0f b6 c9             	movzbl %cl,%ecx
  8020fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802101:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802107:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80210a:	39 ce                	cmp    %ecx,%esi
  80210c:	74 1b                	je     802129 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80210e:	39 c3                	cmp    %eax,%ebx
  802110:	75 c4                	jne    8020d6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802112:	8b 42 58             	mov    0x58(%edx),%eax
  802115:	ff 75 e4             	pushl  -0x1c(%ebp)
  802118:	50                   	push   %eax
  802119:	56                   	push   %esi
  80211a:	68 cc 2e 80 00       	push   $0x802ecc
  80211f:	e8 53 e1 ff ff       	call   800277 <cprintf>
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	eb ad                	jmp    8020d6 <_pipeisclosed+0xe>
	}
}
  802129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	57                   	push   %edi
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	83 ec 28             	sub    $0x28,%esp
  80213d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802140:	56                   	push   %esi
  802141:	e8 fa ec ff ff       	call   800e40 <fd2data>
  802146:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802148:	83 c4 10             	add    $0x10,%esp
  80214b:	bf 00 00 00 00       	mov    $0x0,%edi
  802150:	eb 4b                	jmp    80219d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802152:	89 da                	mov    %ebx,%edx
  802154:	89 f0                	mov    %esi,%eax
  802156:	e8 6d ff ff ff       	call   8020c8 <_pipeisclosed>
  80215b:	85 c0                	test   %eax,%eax
  80215d:	75 48                	jne    8021a7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80215f:	e8 7c ea ff ff       	call   800be0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802164:	8b 43 04             	mov    0x4(%ebx),%eax
  802167:	8b 0b                	mov    (%ebx),%ecx
  802169:	8d 51 20             	lea    0x20(%ecx),%edx
  80216c:	39 d0                	cmp    %edx,%eax
  80216e:	73 e2                	jae    802152 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802170:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802173:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802177:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80217a:	89 c2                	mov    %eax,%edx
  80217c:	c1 fa 1f             	sar    $0x1f,%edx
  80217f:	89 d1                	mov    %edx,%ecx
  802181:	c1 e9 1b             	shr    $0x1b,%ecx
  802184:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802187:	83 e2 1f             	and    $0x1f,%edx
  80218a:	29 ca                	sub    %ecx,%edx
  80218c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802190:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802194:	83 c0 01             	add    $0x1,%eax
  802197:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219a:	83 c7 01             	add    $0x1,%edi
  80219d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021a0:	75 c2                	jne    802164 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a5:	eb 05                	jmp    8021ac <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021a7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	57                   	push   %edi
  8021b8:	56                   	push   %esi
  8021b9:	53                   	push   %ebx
  8021ba:	83 ec 18             	sub    $0x18,%esp
  8021bd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021c0:	57                   	push   %edi
  8021c1:	e8 7a ec ff ff       	call   800e40 <fd2data>
  8021c6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d0:	eb 3d                	jmp    80220f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021d2:	85 db                	test   %ebx,%ebx
  8021d4:	74 04                	je     8021da <devpipe_read+0x26>
				return i;
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	eb 44                	jmp    80221e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021da:	89 f2                	mov    %esi,%edx
  8021dc:	89 f8                	mov    %edi,%eax
  8021de:	e8 e5 fe ff ff       	call   8020c8 <_pipeisclosed>
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	75 32                	jne    802219 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021e7:	e8 f4 e9 ff ff       	call   800be0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021ec:	8b 06                	mov    (%esi),%eax
  8021ee:	3b 46 04             	cmp    0x4(%esi),%eax
  8021f1:	74 df                	je     8021d2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021f3:	99                   	cltd   
  8021f4:	c1 ea 1b             	shr    $0x1b,%edx
  8021f7:	01 d0                	add    %edx,%eax
  8021f9:	83 e0 1f             	and    $0x1f,%eax
  8021fc:	29 d0                	sub    %edx,%eax
  8021fe:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802206:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802209:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80220c:	83 c3 01             	add    $0x1,%ebx
  80220f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802212:	75 d8                	jne    8021ec <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802214:	8b 45 10             	mov    0x10(%ebp),%eax
  802217:	eb 05                	jmp    80221e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80221e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5f                   	pop    %edi
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    

00802226 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	56                   	push   %esi
  80222a:	53                   	push   %ebx
  80222b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80222e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802231:	50                   	push   %eax
  802232:	e8 20 ec ff ff       	call   800e57 <fd_alloc>
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	89 c2                	mov    %eax,%edx
  80223c:	85 c0                	test   %eax,%eax
  80223e:	0f 88 2c 01 00 00    	js     802370 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802244:	83 ec 04             	sub    $0x4,%esp
  802247:	68 07 04 00 00       	push   $0x407
  80224c:	ff 75 f4             	pushl  -0xc(%ebp)
  80224f:	6a 00                	push   $0x0
  802251:	e8 a9 e9 ff ff       	call   800bff <sys_page_alloc>
  802256:	83 c4 10             	add    $0x10,%esp
  802259:	89 c2                	mov    %eax,%edx
  80225b:	85 c0                	test   %eax,%eax
  80225d:	0f 88 0d 01 00 00    	js     802370 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802263:	83 ec 0c             	sub    $0xc,%esp
  802266:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802269:	50                   	push   %eax
  80226a:	e8 e8 eb ff ff       	call   800e57 <fd_alloc>
  80226f:	89 c3                	mov    %eax,%ebx
  802271:	83 c4 10             	add    $0x10,%esp
  802274:	85 c0                	test   %eax,%eax
  802276:	0f 88 e2 00 00 00    	js     80235e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227c:	83 ec 04             	sub    $0x4,%esp
  80227f:	68 07 04 00 00       	push   $0x407
  802284:	ff 75 f0             	pushl  -0x10(%ebp)
  802287:	6a 00                	push   $0x0
  802289:	e8 71 e9 ff ff       	call   800bff <sys_page_alloc>
  80228e:	89 c3                	mov    %eax,%ebx
  802290:	83 c4 10             	add    $0x10,%esp
  802293:	85 c0                	test   %eax,%eax
  802295:	0f 88 c3 00 00 00    	js     80235e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80229b:	83 ec 0c             	sub    $0xc,%esp
  80229e:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a1:	e8 9a eb ff ff       	call   800e40 <fd2data>
  8022a6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a8:	83 c4 0c             	add    $0xc,%esp
  8022ab:	68 07 04 00 00       	push   $0x407
  8022b0:	50                   	push   %eax
  8022b1:	6a 00                	push   $0x0
  8022b3:	e8 47 e9 ff ff       	call   800bff <sys_page_alloc>
  8022b8:	89 c3                	mov    %eax,%ebx
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	0f 88 89 00 00 00    	js     80234e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c5:	83 ec 0c             	sub    $0xc,%esp
  8022c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8022cb:	e8 70 eb ff ff       	call   800e40 <fd2data>
  8022d0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022d7:	50                   	push   %eax
  8022d8:	6a 00                	push   $0x0
  8022da:	56                   	push   %esi
  8022db:	6a 00                	push   $0x0
  8022dd:	e8 60 e9 ff ff       	call   800c42 <sys_page_map>
  8022e2:	89 c3                	mov    %eax,%ebx
  8022e4:	83 c4 20             	add    $0x20,%esp
  8022e7:	85 c0                	test   %eax,%eax
  8022e9:	78 55                	js     802340 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022eb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802300:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802309:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80230b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80230e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802315:	83 ec 0c             	sub    $0xc,%esp
  802318:	ff 75 f4             	pushl  -0xc(%ebp)
  80231b:	e8 10 eb ff ff       	call   800e30 <fd2num>
  802320:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802323:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802325:	83 c4 04             	add    $0x4,%esp
  802328:	ff 75 f0             	pushl  -0x10(%ebp)
  80232b:	e8 00 eb ff ff       	call   800e30 <fd2num>
  802330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802333:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	ba 00 00 00 00       	mov    $0x0,%edx
  80233e:	eb 30                	jmp    802370 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802340:	83 ec 08             	sub    $0x8,%esp
  802343:	56                   	push   %esi
  802344:	6a 00                	push   $0x0
  802346:	e8 39 e9 ff ff       	call   800c84 <sys_page_unmap>
  80234b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80234e:	83 ec 08             	sub    $0x8,%esp
  802351:	ff 75 f0             	pushl  -0x10(%ebp)
  802354:	6a 00                	push   $0x0
  802356:	e8 29 e9 ff ff       	call   800c84 <sys_page_unmap>
  80235b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80235e:	83 ec 08             	sub    $0x8,%esp
  802361:	ff 75 f4             	pushl  -0xc(%ebp)
  802364:	6a 00                	push   $0x0
  802366:	e8 19 e9 ff ff       	call   800c84 <sys_page_unmap>
  80236b:	83 c4 10             	add    $0x10,%esp
  80236e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802370:	89 d0                	mov    %edx,%eax
  802372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802375:	5b                   	pop    %ebx
  802376:	5e                   	pop    %esi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    

00802379 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80237f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802382:	50                   	push   %eax
  802383:	ff 75 08             	pushl  0x8(%ebp)
  802386:	e8 1b eb ff ff       	call   800ea6 <fd_lookup>
  80238b:	83 c4 10             	add    $0x10,%esp
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 18                	js     8023aa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802392:	83 ec 0c             	sub    $0xc,%esp
  802395:	ff 75 f4             	pushl  -0xc(%ebp)
  802398:	e8 a3 ea ff ff       	call   800e40 <fd2data>
	return _pipeisclosed(fd, p);
  80239d:	89 c2                	mov    %eax,%edx
  80239f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a2:	e8 21 fd ff ff       	call   8020c8 <_pipeisclosed>
  8023a7:	83 c4 10             	add    $0x10,%esp
}
  8023aa:	c9                   	leave  
  8023ab:	c3                   	ret    

008023ac <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023ac:	55                   	push   %ebp
  8023ad:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023af:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b4:	5d                   	pop    %ebp
  8023b5:	c3                   	ret    

008023b6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023bc:	68 e4 2e 80 00       	push   $0x802ee4
  8023c1:	ff 75 0c             	pushl  0xc(%ebp)
  8023c4:	e8 33 e4 ff ff       	call   8007fc <strcpy>
	return 0;
}
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	57                   	push   %edi
  8023d4:	56                   	push   %esi
  8023d5:	53                   	push   %ebx
  8023d6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023dc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023e1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e7:	eb 2d                	jmp    802416 <devcons_write+0x46>
		m = n - tot;
  8023e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023ec:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023ee:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023f1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023f6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023f9:	83 ec 04             	sub    $0x4,%esp
  8023fc:	53                   	push   %ebx
  8023fd:	03 45 0c             	add    0xc(%ebp),%eax
  802400:	50                   	push   %eax
  802401:	57                   	push   %edi
  802402:	e8 87 e5 ff ff       	call   80098e <memmove>
		sys_cputs(buf, m);
  802407:	83 c4 08             	add    $0x8,%esp
  80240a:	53                   	push   %ebx
  80240b:	57                   	push   %edi
  80240c:	e8 32 e7 ff ff       	call   800b43 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802411:	01 de                	add    %ebx,%esi
  802413:	83 c4 10             	add    $0x10,%esp
  802416:	89 f0                	mov    %esi,%eax
  802418:	3b 75 10             	cmp    0x10(%ebp),%esi
  80241b:	72 cc                	jb     8023e9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80241d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802420:	5b                   	pop    %ebx
  802421:	5e                   	pop    %esi
  802422:	5f                   	pop    %edi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	83 ec 08             	sub    $0x8,%esp
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802430:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802434:	74 2a                	je     802460 <devcons_read+0x3b>
  802436:	eb 05                	jmp    80243d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802438:	e8 a3 e7 ff ff       	call   800be0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80243d:	e8 1f e7 ff ff       	call   800b61 <sys_cgetc>
  802442:	85 c0                	test   %eax,%eax
  802444:	74 f2                	je     802438 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802446:	85 c0                	test   %eax,%eax
  802448:	78 16                	js     802460 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80244a:	83 f8 04             	cmp    $0x4,%eax
  80244d:	74 0c                	je     80245b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80244f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802452:	88 02                	mov    %al,(%edx)
	return 1;
  802454:	b8 01 00 00 00       	mov    $0x1,%eax
  802459:	eb 05                	jmp    802460 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80245b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802460:	c9                   	leave  
  802461:	c3                   	ret    

00802462 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802468:	8b 45 08             	mov    0x8(%ebp),%eax
  80246b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80246e:	6a 01                	push   $0x1
  802470:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802473:	50                   	push   %eax
  802474:	e8 ca e6 ff ff       	call   800b43 <sys_cputs>
}
  802479:	83 c4 10             	add    $0x10,%esp
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <getchar>:

int
getchar(void)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802484:	6a 01                	push   $0x1
  802486:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802489:	50                   	push   %eax
  80248a:	6a 00                	push   $0x0
  80248c:	e8 7b ec ff ff       	call   80110c <read>
	if (r < 0)
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	85 c0                	test   %eax,%eax
  802496:	78 0f                	js     8024a7 <getchar+0x29>
		return r;
	if (r < 1)
  802498:	85 c0                	test   %eax,%eax
  80249a:	7e 06                	jle    8024a2 <getchar+0x24>
		return -E_EOF;
	return c;
  80249c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024a0:	eb 05                	jmp    8024a7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024a2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024a7:	c9                   	leave  
  8024a8:	c3                   	ret    

008024a9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024a9:	55                   	push   %ebp
  8024aa:	89 e5                	mov    %esp,%ebp
  8024ac:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024b2:	50                   	push   %eax
  8024b3:	ff 75 08             	pushl  0x8(%ebp)
  8024b6:	e8 eb e9 ff ff       	call   800ea6 <fd_lookup>
  8024bb:	83 c4 10             	add    $0x10,%esp
  8024be:	85 c0                	test   %eax,%eax
  8024c0:	78 11                	js     8024d3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024cb:	39 10                	cmp    %edx,(%eax)
  8024cd:	0f 94 c0             	sete   %al
  8024d0:	0f b6 c0             	movzbl %al,%eax
}
  8024d3:	c9                   	leave  
  8024d4:	c3                   	ret    

008024d5 <opencons>:

int
opencons(void)
{
  8024d5:	55                   	push   %ebp
  8024d6:	89 e5                	mov    %esp,%ebp
  8024d8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024de:	50                   	push   %eax
  8024df:	e8 73 e9 ff ff       	call   800e57 <fd_alloc>
  8024e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8024e7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	78 3e                	js     80252b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024ed:	83 ec 04             	sub    $0x4,%esp
  8024f0:	68 07 04 00 00       	push   $0x407
  8024f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f8:	6a 00                	push   $0x0
  8024fa:	e8 00 e7 ff ff       	call   800bff <sys_page_alloc>
  8024ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802502:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802504:	85 c0                	test   %eax,%eax
  802506:	78 23                	js     80252b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802508:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802511:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802513:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802516:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80251d:	83 ec 0c             	sub    $0xc,%esp
  802520:	50                   	push   %eax
  802521:	e8 0a e9 ff ff       	call   800e30 <fd2num>
  802526:	89 c2                	mov    %eax,%edx
  802528:	83 c4 10             	add    $0x10,%esp
}
  80252b:	89 d0                	mov    %edx,%eax
  80252d:	c9                   	leave  
  80252e:	c3                   	ret    

0080252f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80252f:	55                   	push   %ebp
  802530:	89 e5                	mov    %esp,%ebp
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	8b 75 08             	mov    0x8(%ebp),%esi
  802537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  80253d:	85 c0                	test   %eax,%eax
  80253f:	74 0e                	je     80254f <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802541:	83 ec 0c             	sub    $0xc,%esp
  802544:	50                   	push   %eax
  802545:	e8 65 e8 ff ff       	call   800daf <sys_ipc_recv>
  80254a:	83 c4 10             	add    $0x10,%esp
  80254d:	eb 10                	jmp    80255f <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  80254f:	83 ec 0c             	sub    $0xc,%esp
  802552:	68 00 00 00 f0       	push   $0xf0000000
  802557:	e8 53 e8 ff ff       	call   800daf <sys_ipc_recv>
  80255c:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  80255f:	85 c0                	test   %eax,%eax
  802561:	74 0e                	je     802571 <ipc_recv+0x42>
    	*from_env_store = 0;
  802563:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802569:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  80256f:	eb 24                	jmp    802595 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802571:	85 f6                	test   %esi,%esi
  802573:	74 0a                	je     80257f <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  802575:	a1 08 40 80 00       	mov    0x804008,%eax
  80257a:	8b 40 74             	mov    0x74(%eax),%eax
  80257d:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  80257f:	85 db                	test   %ebx,%ebx
  802581:	74 0a                	je     80258d <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802583:	a1 08 40 80 00       	mov    0x804008,%eax
  802588:	8b 40 78             	mov    0x78(%eax),%eax
  80258b:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  80258d:	a1 08 40 80 00       	mov    0x804008,%eax
  802592:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802595:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802598:	5b                   	pop    %ebx
  802599:	5e                   	pop    %esi
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    

0080259c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80259c:	55                   	push   %ebp
  80259d:	89 e5                	mov    %esp,%ebp
  80259f:	57                   	push   %edi
  8025a0:	56                   	push   %esi
  8025a1:	53                   	push   %ebx
  8025a2:	83 ec 0c             	sub    $0xc,%esp
  8025a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8025ae:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8025b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8025b5:	0f 44 d8             	cmove  %eax,%ebx
  8025b8:	eb 1c                	jmp    8025d6 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8025ba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025bd:	74 12                	je     8025d1 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8025bf:	50                   	push   %eax
  8025c0:	68 f0 2e 80 00       	push   $0x802ef0
  8025c5:	6a 4b                	push   $0x4b
  8025c7:	68 08 2f 80 00       	push   $0x802f08
  8025cc:	e8 cd db ff ff       	call   80019e <_panic>
        }	
        sys_yield();
  8025d1:	e8 0a e6 ff ff       	call   800be0 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8025d6:	ff 75 14             	pushl  0x14(%ebp)
  8025d9:	53                   	push   %ebx
  8025da:	56                   	push   %esi
  8025db:	57                   	push   %edi
  8025dc:	e8 ab e7 ff ff       	call   800d8c <sys_ipc_try_send>
  8025e1:	83 c4 10             	add    $0x10,%esp
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	75 d2                	jne    8025ba <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  8025e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025eb:	5b                   	pop    %ebx
  8025ec:	5e                   	pop    %esi
  8025ed:	5f                   	pop    %edi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025f6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025fb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025fe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802604:	8b 52 50             	mov    0x50(%edx),%edx
  802607:	39 ca                	cmp    %ecx,%edx
  802609:	75 0d                	jne    802618 <ipc_find_env+0x28>
			return envs[i].env_id;
  80260b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80260e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802613:	8b 40 48             	mov    0x48(%eax),%eax
  802616:	eb 0f                	jmp    802627 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802618:	83 c0 01             	add    $0x1,%eax
  80261b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802620:	75 d9                	jne    8025fb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802622:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    

00802629 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80262f:	89 d0                	mov    %edx,%eax
  802631:	c1 e8 16             	shr    $0x16,%eax
  802634:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80263b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802640:	f6 c1 01             	test   $0x1,%cl
  802643:	74 1d                	je     802662 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802645:	c1 ea 0c             	shr    $0xc,%edx
  802648:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80264f:	f6 c2 01             	test   $0x1,%dl
  802652:	74 0e                	je     802662 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802654:	c1 ea 0c             	shr    $0xc,%edx
  802657:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80265e:	ef 
  80265f:	0f b7 c0             	movzwl %ax,%eax
}
  802662:	5d                   	pop    %ebp
  802663:	c3                   	ret    
  802664:	66 90                	xchg   %ax,%ax
  802666:	66 90                	xchg   %ax,%ax
  802668:	66 90                	xchg   %ax,%ax
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <__udivdi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	53                   	push   %ebx
  802674:	83 ec 1c             	sub    $0x1c,%esp
  802677:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80267b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80267f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802687:	85 f6                	test   %esi,%esi
  802689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80268d:	89 ca                	mov    %ecx,%edx
  80268f:	89 f8                	mov    %edi,%eax
  802691:	75 3d                	jne    8026d0 <__udivdi3+0x60>
  802693:	39 cf                	cmp    %ecx,%edi
  802695:	0f 87 c5 00 00 00    	ja     802760 <__udivdi3+0xf0>
  80269b:	85 ff                	test   %edi,%edi
  80269d:	89 fd                	mov    %edi,%ebp
  80269f:	75 0b                	jne    8026ac <__udivdi3+0x3c>
  8026a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a6:	31 d2                	xor    %edx,%edx
  8026a8:	f7 f7                	div    %edi
  8026aa:	89 c5                	mov    %eax,%ebp
  8026ac:	89 c8                	mov    %ecx,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	f7 f5                	div    %ebp
  8026b2:	89 c1                	mov    %eax,%ecx
  8026b4:	89 d8                	mov    %ebx,%eax
  8026b6:	89 cf                	mov    %ecx,%edi
  8026b8:	f7 f5                	div    %ebp
  8026ba:	89 c3                	mov    %eax,%ebx
  8026bc:	89 d8                	mov    %ebx,%eax
  8026be:	89 fa                	mov    %edi,%edx
  8026c0:	83 c4 1c             	add    $0x1c,%esp
  8026c3:	5b                   	pop    %ebx
  8026c4:	5e                   	pop    %esi
  8026c5:	5f                   	pop    %edi
  8026c6:	5d                   	pop    %ebp
  8026c7:	c3                   	ret    
  8026c8:	90                   	nop
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	39 ce                	cmp    %ecx,%esi
  8026d2:	77 74                	ja     802748 <__udivdi3+0xd8>
  8026d4:	0f bd fe             	bsr    %esi,%edi
  8026d7:	83 f7 1f             	xor    $0x1f,%edi
  8026da:	0f 84 98 00 00 00    	je     802778 <__udivdi3+0x108>
  8026e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	89 c5                	mov    %eax,%ebp
  8026e9:	29 fb                	sub    %edi,%ebx
  8026eb:	d3 e6                	shl    %cl,%esi
  8026ed:	89 d9                	mov    %ebx,%ecx
  8026ef:	d3 ed                	shr    %cl,%ebp
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e0                	shl    %cl,%eax
  8026f5:	09 ee                	or     %ebp,%esi
  8026f7:	89 d9                	mov    %ebx,%ecx
  8026f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026fd:	89 d5                	mov    %edx,%ebp
  8026ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802703:	d3 ed                	shr    %cl,%ebp
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e2                	shl    %cl,%edx
  802709:	89 d9                	mov    %ebx,%ecx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	09 c2                	or     %eax,%edx
  80270f:	89 d0                	mov    %edx,%eax
  802711:	89 ea                	mov    %ebp,%edx
  802713:	f7 f6                	div    %esi
  802715:	89 d5                	mov    %edx,%ebp
  802717:	89 c3                	mov    %eax,%ebx
  802719:	f7 64 24 0c          	mull   0xc(%esp)
  80271d:	39 d5                	cmp    %edx,%ebp
  80271f:	72 10                	jb     802731 <__udivdi3+0xc1>
  802721:	8b 74 24 08          	mov    0x8(%esp),%esi
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e6                	shl    %cl,%esi
  802729:	39 c6                	cmp    %eax,%esi
  80272b:	73 07                	jae    802734 <__udivdi3+0xc4>
  80272d:	39 d5                	cmp    %edx,%ebp
  80272f:	75 03                	jne    802734 <__udivdi3+0xc4>
  802731:	83 eb 01             	sub    $0x1,%ebx
  802734:	31 ff                	xor    %edi,%edi
  802736:	89 d8                	mov    %ebx,%eax
  802738:	89 fa                	mov    %edi,%edx
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5e                   	pop    %esi
  80273f:	5f                   	pop    %edi
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    
  802742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802748:	31 ff                	xor    %edi,%edi
  80274a:	31 db                	xor    %ebx,%ebx
  80274c:	89 d8                	mov    %ebx,%eax
  80274e:	89 fa                	mov    %edi,%edx
  802750:	83 c4 1c             	add    $0x1c,%esp
  802753:	5b                   	pop    %ebx
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	90                   	nop
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 d8                	mov    %ebx,%eax
  802762:	f7 f7                	div    %edi
  802764:	31 ff                	xor    %edi,%edi
  802766:	89 c3                	mov    %eax,%ebx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 fa                	mov    %edi,%edx
  80276c:	83 c4 1c             	add    $0x1c,%esp
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    
  802774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802778:	39 ce                	cmp    %ecx,%esi
  80277a:	72 0c                	jb     802788 <__udivdi3+0x118>
  80277c:	31 db                	xor    %ebx,%ebx
  80277e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802782:	0f 87 34 ff ff ff    	ja     8026bc <__udivdi3+0x4c>
  802788:	bb 01 00 00 00       	mov    $0x1,%ebx
  80278d:	e9 2a ff ff ff       	jmp    8026bc <__udivdi3+0x4c>
  802792:	66 90                	xchg   %ax,%ax
  802794:	66 90                	xchg   %ax,%ax
  802796:	66 90                	xchg   %ax,%ax
  802798:	66 90                	xchg   %ax,%ax
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <__umoddi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 d2                	test   %edx,%edx
  8027b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027c1:	89 f3                	mov    %esi,%ebx
  8027c3:	89 3c 24             	mov    %edi,(%esp)
  8027c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ca:	75 1c                	jne    8027e8 <__umoddi3+0x48>
  8027cc:	39 f7                	cmp    %esi,%edi
  8027ce:	76 50                	jbe    802820 <__umoddi3+0x80>
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	f7 f7                	div    %edi
  8027d6:	89 d0                	mov    %edx,%eax
  8027d8:	31 d2                	xor    %edx,%edx
  8027da:	83 c4 1c             	add    $0x1c,%esp
  8027dd:	5b                   	pop    %ebx
  8027de:	5e                   	pop    %esi
  8027df:	5f                   	pop    %edi
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    
  8027e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027e8:	39 f2                	cmp    %esi,%edx
  8027ea:	89 d0                	mov    %edx,%eax
  8027ec:	77 52                	ja     802840 <__umoddi3+0xa0>
  8027ee:	0f bd ea             	bsr    %edx,%ebp
  8027f1:	83 f5 1f             	xor    $0x1f,%ebp
  8027f4:	75 5a                	jne    802850 <__umoddi3+0xb0>
  8027f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027fa:	0f 82 e0 00 00 00    	jb     8028e0 <__umoddi3+0x140>
  802800:	39 0c 24             	cmp    %ecx,(%esp)
  802803:	0f 86 d7 00 00 00    	jbe    8028e0 <__umoddi3+0x140>
  802809:	8b 44 24 08          	mov    0x8(%esp),%eax
  80280d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802811:	83 c4 1c             	add    $0x1c,%esp
  802814:	5b                   	pop    %ebx
  802815:	5e                   	pop    %esi
  802816:	5f                   	pop    %edi
  802817:	5d                   	pop    %ebp
  802818:	c3                   	ret    
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	85 ff                	test   %edi,%edi
  802822:	89 fd                	mov    %edi,%ebp
  802824:	75 0b                	jne    802831 <__umoddi3+0x91>
  802826:	b8 01 00 00 00       	mov    $0x1,%eax
  80282b:	31 d2                	xor    %edx,%edx
  80282d:	f7 f7                	div    %edi
  80282f:	89 c5                	mov    %eax,%ebp
  802831:	89 f0                	mov    %esi,%eax
  802833:	31 d2                	xor    %edx,%edx
  802835:	f7 f5                	div    %ebp
  802837:	89 c8                	mov    %ecx,%eax
  802839:	f7 f5                	div    %ebp
  80283b:	89 d0                	mov    %edx,%eax
  80283d:	eb 99                	jmp    8027d8 <__umoddi3+0x38>
  80283f:	90                   	nop
  802840:	89 c8                	mov    %ecx,%eax
  802842:	89 f2                	mov    %esi,%edx
  802844:	83 c4 1c             	add    $0x1c,%esp
  802847:	5b                   	pop    %ebx
  802848:	5e                   	pop    %esi
  802849:	5f                   	pop    %edi
  80284a:	5d                   	pop    %ebp
  80284b:	c3                   	ret    
  80284c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802850:	8b 34 24             	mov    (%esp),%esi
  802853:	bf 20 00 00 00       	mov    $0x20,%edi
  802858:	89 e9                	mov    %ebp,%ecx
  80285a:	29 ef                	sub    %ebp,%edi
  80285c:	d3 e0                	shl    %cl,%eax
  80285e:	89 f9                	mov    %edi,%ecx
  802860:	89 f2                	mov    %esi,%edx
  802862:	d3 ea                	shr    %cl,%edx
  802864:	89 e9                	mov    %ebp,%ecx
  802866:	09 c2                	or     %eax,%edx
  802868:	89 d8                	mov    %ebx,%eax
  80286a:	89 14 24             	mov    %edx,(%esp)
  80286d:	89 f2                	mov    %esi,%edx
  80286f:	d3 e2                	shl    %cl,%edx
  802871:	89 f9                	mov    %edi,%ecx
  802873:	89 54 24 04          	mov    %edx,0x4(%esp)
  802877:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80287b:	d3 e8                	shr    %cl,%eax
  80287d:	89 e9                	mov    %ebp,%ecx
  80287f:	89 c6                	mov    %eax,%esi
  802881:	d3 e3                	shl    %cl,%ebx
  802883:	89 f9                	mov    %edi,%ecx
  802885:	89 d0                	mov    %edx,%eax
  802887:	d3 e8                	shr    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	09 d8                	or     %ebx,%eax
  80288d:	89 d3                	mov    %edx,%ebx
  80288f:	89 f2                	mov    %esi,%edx
  802891:	f7 34 24             	divl   (%esp)
  802894:	89 d6                	mov    %edx,%esi
  802896:	d3 e3                	shl    %cl,%ebx
  802898:	f7 64 24 04          	mull   0x4(%esp)
  80289c:	39 d6                	cmp    %edx,%esi
  80289e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028a2:	89 d1                	mov    %edx,%ecx
  8028a4:	89 c3                	mov    %eax,%ebx
  8028a6:	72 08                	jb     8028b0 <__umoddi3+0x110>
  8028a8:	75 11                	jne    8028bb <__umoddi3+0x11b>
  8028aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ae:	73 0b                	jae    8028bb <__umoddi3+0x11b>
  8028b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028b4:	1b 14 24             	sbb    (%esp),%edx
  8028b7:	89 d1                	mov    %edx,%ecx
  8028b9:	89 c3                	mov    %eax,%ebx
  8028bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028bf:	29 da                	sub    %ebx,%edx
  8028c1:	19 ce                	sbb    %ecx,%esi
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 f0                	mov    %esi,%eax
  8028c7:	d3 e0                	shl    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	d3 ea                	shr    %cl,%edx
  8028cd:	89 e9                	mov    %ebp,%ecx
  8028cf:	d3 ee                	shr    %cl,%esi
  8028d1:	09 d0                	or     %edx,%eax
  8028d3:	89 f2                	mov    %esi,%edx
  8028d5:	83 c4 1c             	add    $0x1c,%esp
  8028d8:	5b                   	pop    %ebx
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
  8028e0:	29 f9                	sub    %edi,%ecx
  8028e2:	19 d6                	sbb    %edx,%esi
  8028e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028ec:	e9 18 ff ff ff       	jmp    802809 <__umoddi3+0x69>
