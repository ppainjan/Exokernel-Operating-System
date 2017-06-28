
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 c0 24 80 00       	push   $0x8024c0
  800062:	e8 23 17 00 00       	call   80178a <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 b6 11 00 00       	call   801237 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 c5 24 80 00       	push   $0x8024c5
  800095:	6a 13                	push   $0x13
  800097:	68 e0 24 80 00       	push   $0x8024e0
  80009c:	e8 4e 01 00 00       	call   8001ef <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 a0 10 00 00       	call   80115d <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 eb 24 80 00       	push   $0x8024eb
  8000d8:	6a 18                	push   $0x18
  8000da:	68 e0 24 80 00       	push   $0x8024e0
  8000df:	e8 0b 01 00 00       	call   8001ef <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 00 	movl   $0x802500,0x803004
  8000fb:	25 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 04 25 80 00       	push   $0x802504
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 b8 14 00 00       	call   8015ec <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 0c 25 80 00       	push   $0x80250c
  80014b:	6a 27                	push   $0x27
  80014d:	68 e0 24 80 00       	push   $0x8024e0
  800152:	e8 98 00 00 00       	call   8001ef <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 b7 0e 00 00       	call   801021 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 58 00 00 00       	call   8001d5 <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800190:	c7 05 0c 40 80 00 00 	movl   $0x0,0x80400c
  800197:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80019a:	e8 73 0a 00 00       	call   800c12 <sys_getenvid>
  80019f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ac:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b1:	85 db                	test   %ebx,%ebx
  8001b3:	7e 07                	jle    8001bc <libmain+0x37>
		binaryname = argv[0];
  8001b5:	8b 06                	mov    (%esi),%eax
  8001b7:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	e8 25 ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001c6:	e8 0a 00 00 00       	call   8001d5 <exit>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001db:	e8 6c 0e 00 00       	call   80104c <close_all>
	sys_env_destroy(0);
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	e8 e7 09 00 00       	call   800bd1 <sys_env_destroy>
}
  8001ea:	83 c4 10             	add    $0x10,%esp
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f7:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001fd:	e8 10 0a 00 00       	call   800c12 <sys_getenvid>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	ff 75 0c             	pushl  0xc(%ebp)
  800208:	ff 75 08             	pushl  0x8(%ebp)
  80020b:	56                   	push   %esi
  80020c:	50                   	push   %eax
  80020d:	68 28 25 80 00       	push   $0x802528
  800212:	e8 b1 00 00 00       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800217:	83 c4 18             	add    $0x18,%esp
  80021a:	53                   	push   %ebx
  80021b:	ff 75 10             	pushl  0x10(%ebp)
  80021e:	e8 54 00 00 00       	call   800277 <vcprintf>
	cprintf("\n");
  800223:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  80022a:	e8 99 00 00 00       	call   8002c8 <cprintf>
  80022f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800232:	cc                   	int3   
  800233:	eb fd                	jmp    800232 <_panic+0x43>

00800235 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	53                   	push   %ebx
  800239:	83 ec 04             	sub    $0x4,%esp
  80023c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023f:	8b 13                	mov    (%ebx),%edx
  800241:	8d 42 01             	lea    0x1(%edx),%eax
  800244:	89 03                	mov    %eax,(%ebx)
  800246:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800249:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80024d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800252:	75 1a                	jne    80026e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	68 ff 00 00 00       	push   $0xff
  80025c:	8d 43 08             	lea    0x8(%ebx),%eax
  80025f:	50                   	push   %eax
  800260:	e8 2f 09 00 00       	call   800b94 <sys_cputs>
		b->idx = 0;
  800265:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80026b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80026e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800280:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800287:	00 00 00 
	b.cnt = 0;
  80028a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800291:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	ff 75 08             	pushl  0x8(%ebp)
  80029a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a0:	50                   	push   %eax
  8002a1:	68 35 02 80 00       	push   $0x800235
  8002a6:	e8 54 01 00 00       	call   8003ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ab:	83 c4 08             	add    $0x8,%esp
  8002ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ba:	50                   	push   %eax
  8002bb:	e8 d4 08 00 00       	call   800b94 <sys_cputs>

	return b.cnt;
}
  8002c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d1:	50                   	push   %eax
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 9d ff ff ff       	call   800277 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 1c             	sub    $0x1c,%esp
  8002e5:	89 c7                	mov    %eax,%edi
  8002e7:	89 d6                	mov    %edx,%esi
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800300:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800303:	39 d3                	cmp    %edx,%ebx
  800305:	72 05                	jb     80030c <printnum+0x30>
  800307:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030a:	77 45                	ja     800351 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	ff 75 18             	pushl  0x18(%ebp)
  800312:	8b 45 14             	mov    0x14(%ebp),%eax
  800315:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800318:	53                   	push   %ebx
  800319:	ff 75 10             	pushl  0x10(%ebp)
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800322:	ff 75 e0             	pushl  -0x20(%ebp)
  800325:	ff 75 dc             	pushl  -0x24(%ebp)
  800328:	ff 75 d8             	pushl  -0x28(%ebp)
  80032b:	e8 f0 1e 00 00       	call   802220 <__udivdi3>
  800330:	83 c4 18             	add    $0x18,%esp
  800333:	52                   	push   %edx
  800334:	50                   	push   %eax
  800335:	89 f2                	mov    %esi,%edx
  800337:	89 f8                	mov    %edi,%eax
  800339:	e8 9e ff ff ff       	call   8002dc <printnum>
  80033e:	83 c4 20             	add    $0x20,%esp
  800341:	eb 18                	jmp    80035b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	56                   	push   %esi
  800347:	ff 75 18             	pushl  0x18(%ebp)
  80034a:	ff d7                	call   *%edi
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	eb 03                	jmp    800354 <printnum+0x78>
  800351:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800354:	83 eb 01             	sub    $0x1,%ebx
  800357:	85 db                	test   %ebx,%ebx
  800359:	7f e8                	jg     800343 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	56                   	push   %esi
  80035f:	83 ec 04             	sub    $0x4,%esp
  800362:	ff 75 e4             	pushl  -0x1c(%ebp)
  800365:	ff 75 e0             	pushl  -0x20(%ebp)
  800368:	ff 75 dc             	pushl  -0x24(%ebp)
  80036b:	ff 75 d8             	pushl  -0x28(%ebp)
  80036e:	e8 dd 1f 00 00       	call   802350 <__umoddi3>
  800373:	83 c4 14             	add    $0x14,%esp
  800376:	0f be 80 4b 25 80 00 	movsbl 0x80254b(%eax),%eax
  80037d:	50                   	push   %eax
  80037e:	ff d7                	call   *%edi
}
  800380:	83 c4 10             	add    $0x10,%esp
  800383:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038e:	83 fa 01             	cmp    $0x1,%edx
  800391:	7e 0e                	jle    8003a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800393:	8b 10                	mov    (%eax),%edx
  800395:	8d 4a 08             	lea    0x8(%edx),%ecx
  800398:	89 08                	mov    %ecx,(%eax)
  80039a:	8b 02                	mov    (%edx),%eax
  80039c:	8b 52 04             	mov    0x4(%edx),%edx
  80039f:	eb 22                	jmp    8003c3 <getuint+0x38>
	else if (lflag)
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 10                	je     8003b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003aa:	89 08                	mov    %ecx,(%eax)
  8003ac:	8b 02                	mov    (%edx),%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 0e                	jmp    8003c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b5:	8b 10                	mov    (%eax),%edx
  8003b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ba:	89 08                	mov    %ecx,(%eax)
  8003bc:	8b 02                	mov    (%edx),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d4:	73 0a                	jae    8003e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d9:	89 08                	mov    %ecx,(%eax)
  8003db:	8b 45 08             	mov    0x8(%ebp),%eax
  8003de:	88 02                	mov    %al,(%edx)
}
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003eb:	50                   	push   %eax
  8003ec:	ff 75 10             	pushl  0x10(%ebp)
  8003ef:	ff 75 0c             	pushl  0xc(%ebp)
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	e8 05 00 00 00       	call   8003ff <vprintfmt>
	va_end(ap);
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 2c             	sub    $0x2c,%esp
  800408:	8b 75 08             	mov    0x8(%ebp),%esi
  80040b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800411:	eb 12                	jmp    800425 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800413:	85 c0                	test   %eax,%eax
  800415:	0f 84 89 03 00 00    	je     8007a4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	53                   	push   %ebx
  80041f:	50                   	push   %eax
  800420:	ff d6                	call   *%esi
  800422:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800425:	83 c7 01             	add    $0x1,%edi
  800428:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80042c:	83 f8 25             	cmp    $0x25,%eax
  80042f:	75 e2                	jne    800413 <vprintfmt+0x14>
  800431:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800435:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80043c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800443:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80044a:	ba 00 00 00 00       	mov    $0x0,%edx
  80044f:	eb 07                	jmp    800458 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800454:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8d 47 01             	lea    0x1(%edi),%eax
  80045b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045e:	0f b6 07             	movzbl (%edi),%eax
  800461:	0f b6 c8             	movzbl %al,%ecx
  800464:	83 e8 23             	sub    $0x23,%eax
  800467:	3c 55                	cmp    $0x55,%al
  800469:	0f 87 1a 03 00 00    	ja     800789 <vprintfmt+0x38a>
  80046f:	0f b6 c0             	movzbl %al,%eax
  800472:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800480:	eb d6                	jmp    800458 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800490:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800494:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800497:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80049a:	83 fa 09             	cmp    $0x9,%edx
  80049d:	77 39                	ja     8004d8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a2:	eb e9                	jmp    80048d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b5:	eb 27                	jmp    8004de <vprintfmt+0xdf>
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004c1:	0f 49 c8             	cmovns %eax,%ecx
  8004c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	eb 8c                	jmp    800458 <vprintfmt+0x59>
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d6:	eb 80                	jmp    800458 <vprintfmt+0x59>
  8004d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004db:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e2:	0f 89 70 ff ff ff    	jns    800458 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004f5:	e9 5e ff ff ff       	jmp    800458 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004fa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800500:	e9 53 ff ff ff       	jmp    800458 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 04             	lea    0x4(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	ff 30                	pushl  (%eax)
  800514:	ff d6                	call   *%esi
			break;
  800516:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80051c:	e9 04 ff ff ff       	jmp    800425 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	99                   	cltd   
  80052d:	31 d0                	xor    %edx,%eax
  80052f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800531:	83 f8 0f             	cmp    $0xf,%eax
  800534:	7f 0b                	jg     800541 <vprintfmt+0x142>
  800536:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  80053d:	85 d2                	test   %edx,%edx
  80053f:	75 18                	jne    800559 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800541:	50                   	push   %eax
  800542:	68 63 25 80 00       	push   $0x802563
  800547:	53                   	push   %ebx
  800548:	56                   	push   %esi
  800549:	e8 94 fe ff ff       	call   8003e2 <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800554:	e9 cc fe ff ff       	jmp    800425 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800559:	52                   	push   %edx
  80055a:	68 19 29 80 00       	push   $0x802919
  80055f:	53                   	push   %ebx
  800560:	56                   	push   %esi
  800561:	e8 7c fe ff ff       	call   8003e2 <printfmt>
  800566:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056c:	e9 b4 fe ff ff       	jmp    800425 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80057c:	85 ff                	test   %edi,%edi
  80057e:	b8 5c 25 80 00       	mov    $0x80255c,%eax
  800583:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800586:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058a:	0f 8e 94 00 00 00    	jle    800624 <vprintfmt+0x225>
  800590:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800594:	0f 84 98 00 00 00    	je     800632 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a0:	57                   	push   %edi
  8005a1:	e8 86 02 00 00       	call   80082c <strnlen>
  8005a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a9:	29 c1                	sub    %eax,%ecx
  8005ab:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ae:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005bb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bd:	eb 0f                	jmp    8005ce <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	7f ed                	jg     8005bf <vprintfmt+0x1c0>
  8005d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005d8:	85 c9                	test   %ecx,%ecx
  8005da:	b8 00 00 00 00       	mov    $0x0,%eax
  8005df:	0f 49 c1             	cmovns %ecx,%eax
  8005e2:	29 c1                	sub    %eax,%ecx
  8005e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ed:	89 cb                	mov    %ecx,%ebx
  8005ef:	eb 4d                	jmp    80063e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f5:	74 1b                	je     800612 <vprintfmt+0x213>
  8005f7:	0f be c0             	movsbl %al,%eax
  8005fa:	83 e8 20             	sub    $0x20,%eax
  8005fd:	83 f8 5e             	cmp    $0x5e,%eax
  800600:	76 10                	jbe    800612 <vprintfmt+0x213>
					putch('?', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	ff 75 0c             	pushl  0xc(%ebp)
  800608:	6a 3f                	push   $0x3f
  80060a:	ff 55 08             	call   *0x8(%ebp)
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	eb 0d                	jmp    80061f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	ff 75 0c             	pushl  0xc(%ebp)
  800618:	52                   	push   %edx
  800619:	ff 55 08             	call   *0x8(%ebp)
  80061c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061f:	83 eb 01             	sub    $0x1,%ebx
  800622:	eb 1a                	jmp    80063e <vprintfmt+0x23f>
  800624:	89 75 08             	mov    %esi,0x8(%ebp)
  800627:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800630:	eb 0c                	jmp    80063e <vprintfmt+0x23f>
  800632:	89 75 08             	mov    %esi,0x8(%ebp)
  800635:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800638:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063e:	83 c7 01             	add    $0x1,%edi
  800641:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800645:	0f be d0             	movsbl %al,%edx
  800648:	85 d2                	test   %edx,%edx
  80064a:	74 23                	je     80066f <vprintfmt+0x270>
  80064c:	85 f6                	test   %esi,%esi
  80064e:	78 a1                	js     8005f1 <vprintfmt+0x1f2>
  800650:	83 ee 01             	sub    $0x1,%esi
  800653:	79 9c                	jns    8005f1 <vprintfmt+0x1f2>
  800655:	89 df                	mov    %ebx,%edi
  800657:	8b 75 08             	mov    0x8(%ebp),%esi
  80065a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80065d:	eb 18                	jmp    800677 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 20                	push   $0x20
  800665:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800667:	83 ef 01             	sub    $0x1,%edi
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb 08                	jmp    800677 <vprintfmt+0x278>
  80066f:	89 df                	mov    %ebx,%edi
  800671:	8b 75 08             	mov    0x8(%ebp),%esi
  800674:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800677:	85 ff                	test   %edi,%edi
  800679:	7f e4                	jg     80065f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 a2 fd ff ff       	jmp    800425 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 16                	jle    80069e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 08             	lea    0x8(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 50 04             	mov    0x4(%eax),%edx
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069c:	eb 32                	jmp    8006d0 <vprintfmt+0x2d1>
	else if (lflag)
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	74 18                	je     8006ba <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b0:	89 c1                	mov    %eax,%ecx
  8006b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b8:	eb 16                	jmp    8006d0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c8:	89 c1                	mov    %eax,%ecx
  8006ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8006cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006db:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006df:	79 74                	jns    800755 <vprintfmt+0x356>
				putch('-', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 2d                	push   $0x2d
  8006e7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ef:	f7 d8                	neg    %eax
  8006f1:	83 d2 00             	adc    $0x0,%edx
  8006f4:	f7 da                	neg    %edx
  8006f6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006fe:	eb 55                	jmp    800755 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
  800703:	e8 83 fc ff ff       	call   80038b <getuint>
			base = 10;
  800708:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80070d:	eb 46                	jmp    800755 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 74 fc ff ff       	call   80038b <getuint>
		        base = 8;
  800717:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80071c:	eb 37                	jmp    800755 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 30                	push   $0x30
  800724:	ff d6                	call   *%esi
			putch('x', putdat);
  800726:	83 c4 08             	add    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 78                	push   $0x78
  80072c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800737:	8b 00                	mov    (%eax),%eax
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800741:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800746:	eb 0d                	jmp    800755 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800748:	8d 45 14             	lea    0x14(%ebp),%eax
  80074b:	e8 3b fc ff ff       	call   80038b <getuint>
			base = 16;
  800750:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800755:	83 ec 0c             	sub    $0xc,%esp
  800758:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80075c:	57                   	push   %edi
  80075d:	ff 75 e0             	pushl  -0x20(%ebp)
  800760:	51                   	push   %ecx
  800761:	52                   	push   %edx
  800762:	50                   	push   %eax
  800763:	89 da                	mov    %ebx,%edx
  800765:	89 f0                	mov    %esi,%eax
  800767:	e8 70 fb ff ff       	call   8002dc <printnum>
			break;
  80076c:	83 c4 20             	add    $0x20,%esp
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800772:	e9 ae fc ff ff       	jmp    800425 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	51                   	push   %ecx
  80077c:	ff d6                	call   *%esi
			break;
  80077e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800784:	e9 9c fc ff ff       	jmp    800425 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 25                	push   $0x25
  80078f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	eb 03                	jmp    800799 <vprintfmt+0x39a>
  800796:	83 ef 01             	sub    $0x1,%edi
  800799:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80079d:	75 f7                	jne    800796 <vprintfmt+0x397>
  80079f:	e9 81 fc ff ff       	jmp    800425 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5f                   	pop    %edi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 18             	sub    $0x18,%esp
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	74 26                	je     8007f3 <vsnprintf+0x47>
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	7e 22                	jle    8007f3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d1:	ff 75 14             	pushl  0x14(%ebp)
  8007d4:	ff 75 10             	pushl  0x10(%ebp)
  8007d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007da:	50                   	push   %eax
  8007db:	68 c5 03 80 00       	push   $0x8003c5
  8007e0:	e8 1a fc ff ff       	call   8003ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	eb 05                	jmp    8007f8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800803:	50                   	push   %eax
  800804:	ff 75 10             	pushl  0x10(%ebp)
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	ff 75 08             	pushl  0x8(%ebp)
  80080d:	e8 9a ff ff ff       	call   8007ac <vsnprintf>
	va_end(ap);

	return rc;
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
  80081f:	eb 03                	jmp    800824 <strlen+0x10>
		n++;
  800821:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800824:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800828:	75 f7                	jne    800821 <strlen+0xd>
		n++;
	return n;
}
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
  80083a:	eb 03                	jmp    80083f <strnlen+0x13>
		n++;
  80083c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 08                	je     80084b <strnlen+0x1f>
  800843:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800847:	75 f3                	jne    80083c <strnlen+0x10>
  800849:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800857:	89 c2                	mov    %eax,%edx
  800859:	83 c2 01             	add    $0x1,%edx
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800863:	88 5a ff             	mov    %bl,-0x1(%edx)
  800866:	84 db                	test   %bl,%bl
  800868:	75 ef                	jne    800859 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086a:	5b                   	pop    %ebx
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800874:	53                   	push   %ebx
  800875:	e8 9a ff ff ff       	call   800814 <strlen>
  80087a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80087d:	ff 75 0c             	pushl  0xc(%ebp)
  800880:	01 d8                	add    %ebx,%eax
  800882:	50                   	push   %eax
  800883:	e8 c5 ff ff ff       	call   80084d <strcpy>
	return dst;
}
  800888:	89 d8                	mov    %ebx,%eax
  80088a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 75 08             	mov    0x8(%ebp),%esi
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089a:	89 f3                	mov    %esi,%ebx
  80089c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089f:	89 f2                	mov    %esi,%edx
  8008a1:	eb 0f                	jmp    8008b2 <strncpy+0x23>
		*dst++ = *src;
  8008a3:	83 c2 01             	add    $0x1,%edx
  8008a6:	0f b6 01             	movzbl (%ecx),%eax
  8008a9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ac:	80 39 01             	cmpb   $0x1,(%ecx)
  8008af:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b2:	39 da                	cmp    %ebx,%edx
  8008b4:	75 ed                	jne    8008a3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b6:	89 f0                	mov    %esi,%eax
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c7:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ca:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cc:	85 d2                	test   %edx,%edx
  8008ce:	74 21                	je     8008f1 <strlcpy+0x35>
  8008d0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d4:	89 f2                	mov    %esi,%edx
  8008d6:	eb 09                	jmp    8008e1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d8:	83 c2 01             	add    $0x1,%edx
  8008db:	83 c1 01             	add    $0x1,%ecx
  8008de:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e1:	39 c2                	cmp    %eax,%edx
  8008e3:	74 09                	je     8008ee <strlcpy+0x32>
  8008e5:	0f b6 19             	movzbl (%ecx),%ebx
  8008e8:	84 db                	test   %bl,%bl
  8008ea:	75 ec                	jne    8008d8 <strlcpy+0x1c>
  8008ec:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f1:	29 f0                	sub    %esi,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	eb 06                	jmp    800908 <strcmp+0x11>
		p++, q++;
  800902:	83 c1 01             	add    $0x1,%ecx
  800905:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800908:	0f b6 01             	movzbl (%ecx),%eax
  80090b:	84 c0                	test   %al,%al
  80090d:	74 04                	je     800913 <strcmp+0x1c>
  80090f:	3a 02                	cmp    (%edx),%al
  800911:	74 ef                	je     800902 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 c0             	movzbl %al,%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
  800927:	89 c3                	mov    %eax,%ebx
  800929:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092c:	eb 06                	jmp    800934 <strncmp+0x17>
		n--, p++, q++;
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800934:	39 d8                	cmp    %ebx,%eax
  800936:	74 15                	je     80094d <strncmp+0x30>
  800938:	0f b6 08             	movzbl (%eax),%ecx
  80093b:	84 c9                	test   %cl,%cl
  80093d:	74 04                	je     800943 <strncmp+0x26>
  80093f:	3a 0a                	cmp    (%edx),%cl
  800941:	74 eb                	je     80092e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f b6 12             	movzbl (%edx),%edx
  800949:	29 d0                	sub    %edx,%eax
  80094b:	eb 05                	jmp    800952 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5b                   	pop    %ebx
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095f:	eb 07                	jmp    800968 <strchr+0x13>
		if (*s == c)
  800961:	38 ca                	cmp    %cl,%dl
  800963:	74 0f                	je     800974 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	0f b6 10             	movzbl (%eax),%edx
  80096b:	84 d2                	test   %dl,%dl
  80096d:	75 f2                	jne    800961 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	eb 03                	jmp    800985 <strfind+0xf>
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800988:	38 ca                	cmp    %cl,%dl
  80098a:	74 04                	je     800990 <strfind+0x1a>
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f2                	jne    800982 <strfind+0xc>
			break;
	return (char *) s;
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099e:	85 c9                	test   %ecx,%ecx
  8009a0:	74 36                	je     8009d8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a8:	75 28                	jne    8009d2 <memset+0x40>
  8009aa:	f6 c1 03             	test   $0x3,%cl
  8009ad:	75 23                	jne    8009d2 <memset+0x40>
		c &= 0xFF;
  8009af:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b3:	89 d3                	mov    %edx,%ebx
  8009b5:	c1 e3 08             	shl    $0x8,%ebx
  8009b8:	89 d6                	mov    %edx,%esi
  8009ba:	c1 e6 18             	shl    $0x18,%esi
  8009bd:	89 d0                	mov    %edx,%eax
  8009bf:	c1 e0 10             	shl    $0x10,%eax
  8009c2:	09 f0                	or     %esi,%eax
  8009c4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009c6:	89 d8                	mov    %ebx,%eax
  8009c8:	09 d0                	or     %edx,%eax
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
  8009cd:	fc                   	cld    
  8009ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d0:	eb 06                	jmp    8009d8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	fc                   	cld    
  8009d6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d8:	89 f8                	mov    %edi,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ed:	39 c6                	cmp    %eax,%esi
  8009ef:	73 35                	jae    800a26 <memmove+0x47>
  8009f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f4:	39 d0                	cmp    %edx,%eax
  8009f6:	73 2e                	jae    800a26 <memmove+0x47>
		s += n;
		d += n;
  8009f8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	09 fe                	or     %edi,%esi
  8009ff:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a05:	75 13                	jne    800a1a <memmove+0x3b>
  800a07:	f6 c1 03             	test   $0x3,%cl
  800a0a:	75 0e                	jne    800a1a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a0c:	83 ef 04             	sub    $0x4,%edi
  800a0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a12:	c1 e9 02             	shr    $0x2,%ecx
  800a15:	fd                   	std    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb 09                	jmp    800a23 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1a:	83 ef 01             	sub    $0x1,%edi
  800a1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a20:	fd                   	std    
  800a21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a23:	fc                   	cld    
  800a24:	eb 1d                	jmp    800a43 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	89 f2                	mov    %esi,%edx
  800a28:	09 c2                	or     %eax,%edx
  800a2a:	f6 c2 03             	test   $0x3,%dl
  800a2d:	75 0f                	jne    800a3e <memmove+0x5f>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 0a                	jne    800a3e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a34:	c1 e9 02             	shr    $0x2,%ecx
  800a37:	89 c7                	mov    %eax,%edi
  800a39:	fc                   	cld    
  800a3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3c:	eb 05                	jmp    800a43 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3e:	89 c7                	mov    %eax,%edi
  800a40:	fc                   	cld    
  800a41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4a:	ff 75 10             	pushl  0x10(%ebp)
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	ff 75 08             	pushl  0x8(%ebp)
  800a53:	e8 87 ff ff ff       	call   8009df <memmove>
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c6                	mov    %eax,%esi
  800a67:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	eb 1a                	jmp    800a86 <memcmp+0x2c>
		if (*s1 != *s2)
  800a6c:	0f b6 08             	movzbl (%eax),%ecx
  800a6f:	0f b6 1a             	movzbl (%edx),%ebx
  800a72:	38 d9                	cmp    %bl,%cl
  800a74:	74 0a                	je     800a80 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a76:	0f b6 c1             	movzbl %cl,%eax
  800a79:	0f b6 db             	movzbl %bl,%ebx
  800a7c:	29 d8                	sub    %ebx,%eax
  800a7e:	eb 0f                	jmp    800a8f <memcmp+0x35>
		s1++, s2++;
  800a80:	83 c0 01             	add    $0x1,%eax
  800a83:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a86:	39 f0                	cmp    %esi,%eax
  800a88:	75 e2                	jne    800a6c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	53                   	push   %ebx
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9a:	89 c1                	mov    %eax,%ecx
  800a9c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa3:	eb 0a                	jmp    800aaf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	39 da                	cmp    %ebx,%edx
  800aaa:	74 07                	je     800ab3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aac:	83 c0 01             	add    $0x1,%eax
  800aaf:	39 c8                	cmp    %ecx,%eax
  800ab1:	72 f2                	jb     800aa5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab3:	5b                   	pop    %ebx
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac2:	eb 03                	jmp    800ac7 <strtol+0x11>
		s++;
  800ac4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac7:	0f b6 01             	movzbl (%ecx),%eax
  800aca:	3c 20                	cmp    $0x20,%al
  800acc:	74 f6                	je     800ac4 <strtol+0xe>
  800ace:	3c 09                	cmp    $0x9,%al
  800ad0:	74 f2                	je     800ac4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad2:	3c 2b                	cmp    $0x2b,%al
  800ad4:	75 0a                	jne    800ae0 <strtol+0x2a>
		s++;
  800ad6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	eb 11                	jmp    800af1 <strtol+0x3b>
  800ae0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae5:	3c 2d                	cmp    $0x2d,%al
  800ae7:	75 08                	jne    800af1 <strtol+0x3b>
		s++, neg = 1;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af7:	75 15                	jne    800b0e <strtol+0x58>
  800af9:	80 39 30             	cmpb   $0x30,(%ecx)
  800afc:	75 10                	jne    800b0e <strtol+0x58>
  800afe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b02:	75 7c                	jne    800b80 <strtol+0xca>
		s += 2, base = 16;
  800b04:	83 c1 02             	add    $0x2,%ecx
  800b07:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0c:	eb 16                	jmp    800b24 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b0e:	85 db                	test   %ebx,%ebx
  800b10:	75 12                	jne    800b24 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b12:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b17:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1a:	75 08                	jne    800b24 <strtol+0x6e>
		s++, base = 8;
  800b1c:	83 c1 01             	add    $0x1,%ecx
  800b1f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
  800b29:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2c:	0f b6 11             	movzbl (%ecx),%edx
  800b2f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b32:	89 f3                	mov    %esi,%ebx
  800b34:	80 fb 09             	cmp    $0x9,%bl
  800b37:	77 08                	ja     800b41 <strtol+0x8b>
			dig = *s - '0';
  800b39:	0f be d2             	movsbl %dl,%edx
  800b3c:	83 ea 30             	sub    $0x30,%edx
  800b3f:	eb 22                	jmp    800b63 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b41:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b44:	89 f3                	mov    %esi,%ebx
  800b46:	80 fb 19             	cmp    $0x19,%bl
  800b49:	77 08                	ja     800b53 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b4b:	0f be d2             	movsbl %dl,%edx
  800b4e:	83 ea 57             	sub    $0x57,%edx
  800b51:	eb 10                	jmp    800b63 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b53:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b56:	89 f3                	mov    %esi,%ebx
  800b58:	80 fb 19             	cmp    $0x19,%bl
  800b5b:	77 16                	ja     800b73 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b63:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b66:	7d 0b                	jge    800b73 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b71:	eb b9                	jmp    800b2c <strtol+0x76>

	if (endptr)
  800b73:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b77:	74 0d                	je     800b86 <strtol+0xd0>
		*endptr = (char *) s;
  800b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7c:	89 0e                	mov    %ecx,(%esi)
  800b7e:	eb 06                	jmp    800b86 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	74 98                	je     800b1c <strtol+0x66>
  800b84:	eb 9e                	jmp    800b24 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	f7 da                	neg    %edx
  800b8a:	85 ff                	test   %edi,%edi
  800b8c:	0f 45 c2             	cmovne %edx,%eax
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 c3                	mov    %eax,%ebx
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 c6                	mov    %eax,%esi
  800bab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 cb                	mov    %ecx,%ebx
  800be9:	89 cf                	mov    %ecx,%edi
  800beb:	89 ce                	mov    %ecx,%esi
  800bed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 17                	jle    800c0a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 03                	push   $0x3
  800bf9:	68 3f 28 80 00       	push   $0x80283f
  800bfe:	6a 23                	push   $0x23
  800c00:	68 5c 28 80 00       	push   $0x80285c
  800c05:	e8 e5 f5 ff ff       	call   8001ef <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_yield>:

void
sys_yield(void)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c41:	89 d1                	mov    %edx,%ecx
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	89 d7                	mov    %edx,%edi
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	be 00 00 00 00       	mov    $0x0,%esi
  800c5e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	89 f7                	mov    %esi,%edi
  800c6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 04                	push   $0x4
  800c7a:	68 3f 28 80 00       	push   $0x80283f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 5c 28 80 00       	push   $0x80285c
  800c86:	e8 64 f5 ff ff       	call   8001ef <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cad:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 17                	jle    800ccd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 05                	push   $0x5
  800cbc:	68 3f 28 80 00       	push   $0x80283f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 5c 28 80 00       	push   $0x80285c
  800cc8:	e8 22 f5 ff ff       	call   8001ef <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 df                	mov    %ebx,%edi
  800cf0:	89 de                	mov    %ebx,%esi
  800cf2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 17                	jle    800d0f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 06                	push   $0x6
  800cfe:	68 3f 28 80 00       	push   $0x80283f
  800d03:	6a 23                	push   $0x23
  800d05:	68 5c 28 80 00       	push   $0x80285c
  800d0a:	e8 e0 f4 ff ff       	call   8001ef <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d25:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 df                	mov    %ebx,%edi
  800d32:	89 de                	mov    %ebx,%esi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 08                	push   $0x8
  800d40:	68 3f 28 80 00       	push   $0x80283f
  800d45:	6a 23                	push   $0x23
  800d47:	68 5c 28 80 00       	push   $0x80285c
  800d4c:	e8 9e f4 ff ff       	call   8001ef <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 17                	jle    800d93 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 09                	push   $0x9
  800d82:	68 3f 28 80 00       	push   $0x80283f
  800d87:	6a 23                	push   $0x23
  800d89:	68 5c 28 80 00       	push   $0x80285c
  800d8e:	e8 5c f4 ff ff       	call   8001ef <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 0a                	push   $0xa
  800dc4:	68 3f 28 80 00       	push   $0x80283f
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 5c 28 80 00       	push   $0x80285c
  800dd0:	e8 1a f4 ff ff       	call   8001ef <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	be 00 00 00 00       	mov    $0x0,%esi
  800de8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 cb                	mov    %ecx,%ebx
  800e18:	89 cf                	mov    %ecx,%edi
  800e1a:	89 ce                	mov    %ecx,%esi
  800e1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	7e 17                	jle    800e39 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 0d                	push   $0xd
  800e28:	68 3f 28 80 00       	push   $0x80283f
  800e2d:	6a 23                	push   $0x23
  800e2f:	68 5c 28 80 00       	push   $0x80285c
  800e34:	e8 b6 f3 ff ff       	call   8001ef <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 d3                	mov    %edx,%ebx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 df                	mov    %ebx,%edi
  800e78:	89 de                	mov    %ebx,%esi
  800e7a:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	c1 ea 16             	shr    $0x16,%edx
  800eb8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebf:	f6 c2 01             	test   $0x1,%dl
  800ec2:	74 11                	je     800ed5 <fd_alloc+0x2d>
  800ec4:	89 c2                	mov    %eax,%edx
  800ec6:	c1 ea 0c             	shr    $0xc,%edx
  800ec9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed0:	f6 c2 01             	test   $0x1,%dl
  800ed3:	75 09                	jne    800ede <fd_alloc+0x36>
			*fd_store = fd;
  800ed5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  800edc:	eb 17                	jmp    800ef5 <fd_alloc+0x4d>
  800ede:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee8:	75 c9                	jne    800eb3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eea:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efd:	83 f8 1f             	cmp    $0x1f,%eax
  800f00:	77 36                	ja     800f38 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f02:	c1 e0 0c             	shl    $0xc,%eax
  800f05:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0a:	89 c2                	mov    %eax,%edx
  800f0c:	c1 ea 16             	shr    $0x16,%edx
  800f0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f16:	f6 c2 01             	test   $0x1,%dl
  800f19:	74 24                	je     800f3f <fd_lookup+0x48>
  800f1b:	89 c2                	mov    %eax,%edx
  800f1d:	c1 ea 0c             	shr    $0xc,%edx
  800f20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f27:	f6 c2 01             	test   $0x1,%dl
  800f2a:	74 1a                	je     800f46 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	eb 13                	jmp    800f4b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3d:	eb 0c                	jmp    800f4b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f44:	eb 05                	jmp    800f4b <fd_lookup+0x54>
  800f46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f56:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f5b:	eb 13                	jmp    800f70 <dev_lookup+0x23>
  800f5d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f60:	39 08                	cmp    %ecx,(%eax)
  800f62:	75 0c                	jne    800f70 <dev_lookup+0x23>
			*dev = devtab[i];
  800f64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f67:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f69:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6e:	eb 2e                	jmp    800f9e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f70:	8b 02                	mov    (%edx),%eax
  800f72:	85 c0                	test   %eax,%eax
  800f74:	75 e7                	jne    800f5d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f76:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800f7b:	8b 40 48             	mov    0x48(%eax),%eax
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	51                   	push   %ecx
  800f82:	50                   	push   %eax
  800f83:	68 6c 28 80 00       	push   $0x80286c
  800f88:	e8 3b f3 ff ff       	call   8002c8 <cprintf>
	*dev = 0;
  800f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f90:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    

00800fa0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 10             	sub    $0x10,%esp
  800fa8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb1:	50                   	push   %eax
  800fb2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb8:	c1 e8 0c             	shr    $0xc,%eax
  800fbb:	50                   	push   %eax
  800fbc:	e8 36 ff ff ff       	call   800ef7 <fd_lookup>
  800fc1:	83 c4 08             	add    $0x8,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 05                	js     800fcd <fd_close+0x2d>
	    || fd != fd2)
  800fc8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fcb:	74 0c                	je     800fd9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fcd:	84 db                	test   %bl,%bl
  800fcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd4:	0f 44 c2             	cmove  %edx,%eax
  800fd7:	eb 41                	jmp    80101a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fd9:	83 ec 08             	sub    $0x8,%esp
  800fdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 36                	pushl  (%esi)
  800fe2:	e8 66 ff ff ff       	call   800f4d <dev_lookup>
  800fe7:	89 c3                	mov    %eax,%ebx
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 1a                	js     80100a <fd_close+0x6a>
		if (dev->dev_close)
  800ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	74 0b                	je     80100a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	56                   	push   %esi
  801003:	ff d0                	call   *%eax
  801005:	89 c3                	mov    %eax,%ebx
  801007:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	56                   	push   %esi
  80100e:	6a 00                	push   $0x0
  801010:	e8 c0 fc ff ff       	call   800cd5 <sys_page_unmap>
	return r;
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	89 d8                	mov    %ebx,%eax
}
  80101a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801027:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102a:	50                   	push   %eax
  80102b:	ff 75 08             	pushl  0x8(%ebp)
  80102e:	e8 c4 fe ff ff       	call   800ef7 <fd_lookup>
  801033:	83 c4 08             	add    $0x8,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	78 10                	js     80104a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80103a:	83 ec 08             	sub    $0x8,%esp
  80103d:	6a 01                	push   $0x1
  80103f:	ff 75 f4             	pushl  -0xc(%ebp)
  801042:	e8 59 ff ff ff       	call   800fa0 <fd_close>
  801047:	83 c4 10             	add    $0x10,%esp
}
  80104a:	c9                   	leave  
  80104b:	c3                   	ret    

0080104c <close_all>:

void
close_all(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	53                   	push   %ebx
  801050:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	53                   	push   %ebx
  80105c:	e8 c0 ff ff ff       	call   801021 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801061:	83 c3 01             	add    $0x1,%ebx
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	83 fb 20             	cmp    $0x20,%ebx
  80106a:	75 ec                	jne    801058 <close_all+0xc>
		close(i);
}
  80106c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 2c             	sub    $0x2c,%esp
  80107a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	ff 75 08             	pushl  0x8(%ebp)
  801084:	e8 6e fe ff ff       	call   800ef7 <fd_lookup>
  801089:	83 c4 08             	add    $0x8,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	0f 88 c1 00 00 00    	js     801155 <dup+0xe4>
		return r;
	close(newfdnum);
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	56                   	push   %esi
  801098:	e8 84 ff ff ff       	call   801021 <close>

	newfd = INDEX2FD(newfdnum);
  80109d:	89 f3                	mov    %esi,%ebx
  80109f:	c1 e3 0c             	shl    $0xc,%ebx
  8010a2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010a8:	83 c4 04             	add    $0x4,%esp
  8010ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ae:	e8 de fd ff ff       	call   800e91 <fd2data>
  8010b3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010b5:	89 1c 24             	mov    %ebx,(%esp)
  8010b8:	e8 d4 fd ff ff       	call   800e91 <fd2data>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c3:	89 f8                	mov    %edi,%eax
  8010c5:	c1 e8 16             	shr    $0x16,%eax
  8010c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cf:	a8 01                	test   $0x1,%al
  8010d1:	74 37                	je     80110a <dup+0x99>
  8010d3:	89 f8                	mov    %edi,%eax
  8010d5:	c1 e8 0c             	shr    $0xc,%eax
  8010d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010df:	f6 c2 01             	test   $0x1,%dl
  8010e2:	74 26                	je     80110a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f3:	50                   	push   %eax
  8010f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f7:	6a 00                	push   $0x0
  8010f9:	57                   	push   %edi
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 92 fb ff ff       	call   800c93 <sys_page_map>
  801101:	89 c7                	mov    %eax,%edi
  801103:	83 c4 20             	add    $0x20,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	78 2e                	js     801138 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80110a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80110d:	89 d0                	mov    %edx,%eax
  80110f:	c1 e8 0c             	shr    $0xc,%eax
  801112:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	25 07 0e 00 00       	and    $0xe07,%eax
  801121:	50                   	push   %eax
  801122:	53                   	push   %ebx
  801123:	6a 00                	push   $0x0
  801125:	52                   	push   %edx
  801126:	6a 00                	push   $0x0
  801128:	e8 66 fb ff ff       	call   800c93 <sys_page_map>
  80112d:	89 c7                	mov    %eax,%edi
  80112f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801132:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801134:	85 ff                	test   %edi,%edi
  801136:	79 1d                	jns    801155 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	53                   	push   %ebx
  80113c:	6a 00                	push   $0x0
  80113e:	e8 92 fb ff ff       	call   800cd5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	ff 75 d4             	pushl  -0x2c(%ebp)
  801149:	6a 00                	push   $0x0
  80114b:	e8 85 fb ff ff       	call   800cd5 <sys_page_unmap>
	return r;
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	89 f8                	mov    %edi,%eax
}
  801155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	53                   	push   %ebx
  801161:	83 ec 14             	sub    $0x14,%esp
  801164:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801167:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116a:	50                   	push   %eax
  80116b:	53                   	push   %ebx
  80116c:	e8 86 fd ff ff       	call   800ef7 <fd_lookup>
  801171:	83 c4 08             	add    $0x8,%esp
  801174:	89 c2                	mov    %eax,%edx
  801176:	85 c0                	test   %eax,%eax
  801178:	78 6d                	js     8011e7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	ff 30                	pushl  (%eax)
  801186:	e8 c2 fd ff ff       	call   800f4d <dev_lookup>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 4c                	js     8011de <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801192:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801195:	8b 42 08             	mov    0x8(%edx),%eax
  801198:	83 e0 03             	and    $0x3,%eax
  80119b:	83 f8 01             	cmp    $0x1,%eax
  80119e:	75 21                	jne    8011c1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	53                   	push   %ebx
  8011ac:	50                   	push   %eax
  8011ad:	68 b0 28 80 00       	push   $0x8028b0
  8011b2:	e8 11 f1 ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bf:	eb 26                	jmp    8011e7 <read+0x8a>
	}
	if (!dev->dev_read)
  8011c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c4:	8b 40 08             	mov    0x8(%eax),%eax
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	74 17                	je     8011e2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	ff 75 0c             	pushl  0xc(%ebp)
  8011d4:	52                   	push   %edx
  8011d5:	ff d0                	call   *%eax
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	eb 09                	jmp    8011e7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	eb 05                	jmp    8011e7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011e7:	89 d0                	mov    %edx,%eax
  8011e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801202:	eb 21                	jmp    801225 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801204:	83 ec 04             	sub    $0x4,%esp
  801207:	89 f0                	mov    %esi,%eax
  801209:	29 d8                	sub    %ebx,%eax
  80120b:	50                   	push   %eax
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	03 45 0c             	add    0xc(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	57                   	push   %edi
  801213:	e8 45 ff ff ff       	call   80115d <read>
		if (m < 0)
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 10                	js     80122f <readn+0x41>
			return m;
		if (m == 0)
  80121f:	85 c0                	test   %eax,%eax
  801221:	74 0a                	je     80122d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801223:	01 c3                	add    %eax,%ebx
  801225:	39 f3                	cmp    %esi,%ebx
  801227:	72 db                	jb     801204 <readn+0x16>
  801229:	89 d8                	mov    %ebx,%eax
  80122b:	eb 02                	jmp    80122f <readn+0x41>
  80122d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80122f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	53                   	push   %ebx
  80123b:	83 ec 14             	sub    $0x14,%esp
  80123e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801241:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	53                   	push   %ebx
  801246:	e8 ac fc ff ff       	call   800ef7 <fd_lookup>
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	89 c2                	mov    %eax,%edx
  801250:	85 c0                	test   %eax,%eax
  801252:	78 68                	js     8012bc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125e:	ff 30                	pushl  (%eax)
  801260:	e8 e8 fc ff ff       	call   800f4d <dev_lookup>
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 47                	js     8012b3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801273:	75 21                	jne    801296 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801275:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80127a:	8b 40 48             	mov    0x48(%eax),%eax
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	53                   	push   %ebx
  801281:	50                   	push   %eax
  801282:	68 cc 28 80 00       	push   $0x8028cc
  801287:	e8 3c f0 ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801294:	eb 26                	jmp    8012bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801296:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801299:	8b 52 0c             	mov    0xc(%edx),%edx
  80129c:	85 d2                	test   %edx,%edx
  80129e:	74 17                	je     8012b7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	ff 75 10             	pushl  0x10(%ebp)
  8012a6:	ff 75 0c             	pushl  0xc(%ebp)
  8012a9:	50                   	push   %eax
  8012aa:	ff d2                	call   *%edx
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	eb 09                	jmp    8012bc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	eb 05                	jmp    8012bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012bc:	89 d0                	mov    %edx,%eax
  8012be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 75 08             	pushl  0x8(%ebp)
  8012d0:	e8 22 fc ff ff       	call   800ef7 <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 0e                	js     8012ea <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ea:	c9                   	leave  
  8012eb:	c3                   	ret    

008012ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 14             	sub    $0x14,%esp
  8012f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	53                   	push   %ebx
  8012fb:	e8 f7 fb ff ff       	call   800ef7 <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	89 c2                	mov    %eax,%edx
  801305:	85 c0                	test   %eax,%eax
  801307:	78 65                	js     80136e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801313:	ff 30                	pushl  (%eax)
  801315:	e8 33 fc ff ff       	call   800f4d <dev_lookup>
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 44                	js     801365 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801321:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801324:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801328:	75 21                	jne    80134b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80132a:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80132f:	8b 40 48             	mov    0x48(%eax),%eax
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	53                   	push   %ebx
  801336:	50                   	push   %eax
  801337:	68 8c 28 80 00       	push   $0x80288c
  80133c:	e8 87 ef ff ff       	call   8002c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801349:	eb 23                	jmp    80136e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80134b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134e:	8b 52 18             	mov    0x18(%edx),%edx
  801351:	85 d2                	test   %edx,%edx
  801353:	74 14                	je     801369 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	ff 75 0c             	pushl  0xc(%ebp)
  80135b:	50                   	push   %eax
  80135c:	ff d2                	call   *%edx
  80135e:	89 c2                	mov    %eax,%edx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	eb 09                	jmp    80136e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801365:	89 c2                	mov    %eax,%edx
  801367:	eb 05                	jmp    80136e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801369:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80136e:	89 d0                	mov    %edx,%eax
  801370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	53                   	push   %ebx
  801379:	83 ec 14             	sub    $0x14,%esp
  80137c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	ff 75 08             	pushl  0x8(%ebp)
  801386:	e8 6c fb ff ff       	call   800ef7 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	78 58                	js     8013ec <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	e8 a8 fb ff ff       	call   800f4d <dev_lookup>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 37                	js     8013e3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b3:	74 32                	je     8013e7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013bf:	00 00 00 
	stat->st_isdir = 0;
  8013c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c9:	00 00 00 
	stat->st_dev = dev;
  8013cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d9:	ff 50 14             	call   *0x14(%eax)
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	eb 09                	jmp    8013ec <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e3:	89 c2                	mov    %eax,%edx
  8013e5:	eb 05                	jmp    8013ec <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ec:	89 d0                	mov    %edx,%eax
  8013ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	6a 00                	push   $0x0
  8013fd:	ff 75 08             	pushl  0x8(%ebp)
  801400:	e8 e7 01 00 00       	call   8015ec <open>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 1b                	js     801429 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	ff 75 0c             	pushl  0xc(%ebp)
  801414:	50                   	push   %eax
  801415:	e8 5b ff ff ff       	call   801375 <fstat>
  80141a:	89 c6                	mov    %eax,%esi
	close(fd);
  80141c:	89 1c 24             	mov    %ebx,(%esp)
  80141f:	e8 fd fb ff ff       	call   801021 <close>
	return r;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	89 f0                	mov    %esi,%eax
}
  801429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	89 c6                	mov    %eax,%esi
  801437:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801439:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801440:	75 12                	jne    801454 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801442:	83 ec 0c             	sub    $0xc,%esp
  801445:	6a 01                	push   $0x1
  801447:	e8 5b 0d 00 00       	call   8021a7 <ipc_find_env>
  80144c:	a3 04 40 80 00       	mov    %eax,0x804004
  801451:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801454:	6a 07                	push   $0x7
  801456:	68 00 50 80 00       	push   $0x805000
  80145b:	56                   	push   %esi
  80145c:	ff 35 04 40 80 00    	pushl  0x804004
  801462:	e8 ec 0c 00 00       	call   802153 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801467:	83 c4 0c             	add    $0xc,%esp
  80146a:	6a 00                	push   $0x0
  80146c:	53                   	push   %ebx
  80146d:	6a 00                	push   $0x0
  80146f:	e8 72 0c 00 00       	call   8020e6 <ipc_recv>
}
  801474:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	8b 40 0c             	mov    0xc(%eax),%eax
  801487:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 02 00 00 00       	mov    $0x2,%eax
  80149e:	e8 8d ff ff ff       	call   801430 <fsipc>
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bb:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c0:	e8 6b ff ff ff       	call   801430 <fsipc>
}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e6:	e8 45 ff ff ff       	call   801430 <fsipc>
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 2c                	js     80151b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	68 00 50 80 00       	push   $0x805000
  8014f7:	53                   	push   %ebx
  8014f8:	e8 50 f3 ff ff       	call   80084d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fd:	a1 80 50 80 00       	mov    0x805080,%eax
  801502:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801508:	a1 84 50 80 00       	mov    0x805084,%eax
  80150d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80152a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80152f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801534:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801537:	53                   	push   %ebx
  801538:	ff 75 0c             	pushl  0xc(%ebp)
  80153b:	68 08 50 80 00       	push   $0x805008
  801540:	e8 9a f4 ff ff       	call   8009df <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801545:	8b 45 08             	mov    0x8(%ebp),%eax
  801548:	8b 40 0c             	mov    0xc(%eax),%eax
  80154b:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801550:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
  80155b:	b8 04 00 00 00       	mov    $0x4,%eax
  801560:	e8 cb fe ff ff       	call   801430 <fsipc>
	//panic("devfile_write not implemented");
}
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	8b 40 0c             	mov    0xc(%eax),%eax
  801578:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80157d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801583:	ba 00 00 00 00       	mov    $0x0,%edx
  801588:	b8 03 00 00 00       	mov    $0x3,%eax
  80158d:	e8 9e fe ff ff       	call   801430 <fsipc>
  801592:	89 c3                	mov    %eax,%ebx
  801594:	85 c0                	test   %eax,%eax
  801596:	78 4b                	js     8015e3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801598:	39 c6                	cmp    %eax,%esi
  80159a:	73 16                	jae    8015b2 <devfile_read+0x48>
  80159c:	68 00 29 80 00       	push   $0x802900
  8015a1:	68 07 29 80 00       	push   $0x802907
  8015a6:	6a 7c                	push   $0x7c
  8015a8:	68 1c 29 80 00       	push   $0x80291c
  8015ad:	e8 3d ec ff ff       	call   8001ef <_panic>
	assert(r <= PGSIZE);
  8015b2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b7:	7e 16                	jle    8015cf <devfile_read+0x65>
  8015b9:	68 27 29 80 00       	push   $0x802927
  8015be:	68 07 29 80 00       	push   $0x802907
  8015c3:	6a 7d                	push   $0x7d
  8015c5:	68 1c 29 80 00       	push   $0x80291c
  8015ca:	e8 20 ec ff ff       	call   8001ef <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	50                   	push   %eax
  8015d3:	68 00 50 80 00       	push   $0x805000
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	e8 ff f3 ff ff       	call   8009df <memmove>
	return r;
  8015e0:	83 c4 10             	add    $0x10,%esp
}
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 20             	sub    $0x20,%esp
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015f6:	53                   	push   %ebx
  8015f7:	e8 18 f2 ff ff       	call   800814 <strlen>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801604:	7f 67                	jg     80166d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	e8 96 f8 ff ff       	call   800ea8 <fd_alloc>
  801612:	83 c4 10             	add    $0x10,%esp
		return r;
  801615:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801617:	85 c0                	test   %eax,%eax
  801619:	78 57                	js     801672 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	53                   	push   %ebx
  80161f:	68 00 50 80 00       	push   $0x805000
  801624:	e8 24 f2 ff ff       	call   80084d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801629:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801631:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801634:	b8 01 00 00 00       	mov    $0x1,%eax
  801639:	e8 f2 fd ff ff       	call   801430 <fsipc>
  80163e:	89 c3                	mov    %eax,%ebx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	79 14                	jns    80165b <open+0x6f>
		fd_close(fd, 0);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	6a 00                	push   $0x0
  80164c:	ff 75 f4             	pushl  -0xc(%ebp)
  80164f:	e8 4c f9 ff ff       	call   800fa0 <fd_close>
		return r;
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	89 da                	mov    %ebx,%edx
  801659:	eb 17                	jmp    801672 <open+0x86>
	}

	return fd2num(fd);
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	ff 75 f4             	pushl  -0xc(%ebp)
  801661:	e8 1b f8 ff ff       	call   800e81 <fd2num>
  801666:	89 c2                	mov    %eax,%edx
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	eb 05                	jmp    801672 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80166d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801672:	89 d0                	mov    %edx,%eax
  801674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801677:	c9                   	leave  
  801678:	c3                   	ret    

00801679 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80167f:	ba 00 00 00 00       	mov    $0x0,%edx
  801684:	b8 08 00 00 00       	mov    $0x8,%eax
  801689:	e8 a2 fd ff ff       	call   801430 <fsipc>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801690:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801694:	7e 37                	jle    8016cd <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80169f:	ff 70 04             	pushl  0x4(%eax)
  8016a2:	8d 40 10             	lea    0x10(%eax),%eax
  8016a5:	50                   	push   %eax
  8016a6:	ff 33                	pushl  (%ebx)
  8016a8:	e8 8a fb ff ff       	call   801237 <write>
		if (result > 0)
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	7e 03                	jle    8016b7 <writebuf+0x27>
			b->result += result;
  8016b4:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016b7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ba:	74 0d                	je     8016c9 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	0f 4f c2             	cmovg  %edx,%eax
  8016c6:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	f3 c3                	repz ret 

008016cf <putch>:

static void
putch(int ch, void *thunk)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016d9:	8b 53 04             	mov    0x4(%ebx),%edx
  8016dc:	8d 42 01             	lea    0x1(%edx),%eax
  8016df:	89 43 04             	mov    %eax,0x4(%ebx)
  8016e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e5:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016e9:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016ee:	75 0e                	jne    8016fe <putch+0x2f>
		writebuf(b);
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	e8 99 ff ff ff       	call   801690 <writebuf>
		b->idx = 0;
  8016f7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016fe:	83 c4 04             	add    $0x4,%esp
  801701:	5b                   	pop    %ebx
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801716:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80171d:	00 00 00 
	b.result = 0;
  801720:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801727:	00 00 00 
	b.error = 1;
  80172a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801731:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801734:	ff 75 10             	pushl  0x10(%ebp)
  801737:	ff 75 0c             	pushl  0xc(%ebp)
  80173a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	68 cf 16 80 00       	push   $0x8016cf
  801746:	e8 b4 ec ff ff       	call   8003ff <vprintfmt>
	if (b.idx > 0)
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801755:	7e 0b                	jle    801762 <vfprintf+0x5e>
		writebuf(&b);
  801757:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80175d:	e8 2e ff ff ff       	call   801690 <writebuf>

	return (b.result ? b.result : b.error);
  801762:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801768:	85 c0                	test   %eax,%eax
  80176a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801779:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80177c:	50                   	push   %eax
  80177d:	ff 75 0c             	pushl  0xc(%ebp)
  801780:	ff 75 08             	pushl  0x8(%ebp)
  801783:	e8 7c ff ff ff       	call   801704 <vfprintf>
	va_end(ap);

	return cnt;
}
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <printf>:

int
printf(const char *fmt, ...)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801790:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801793:	50                   	push   %eax
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	6a 01                	push   $0x1
  801799:	e8 66 ff ff ff       	call   801704 <vfprintf>
	va_end(ap);

	return cnt;
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8017a6:	68 33 29 80 00       	push   $0x802933
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	e8 9a f0 ff ff       	call   80084d <strcpy>
	return 0;
}
  8017b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	83 ec 10             	sub    $0x10,%esp
  8017c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017c4:	53                   	push   %ebx
  8017c5:	e8 16 0a 00 00       	call   8021e0 <pageref>
  8017ca:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8017d2:	83 f8 01             	cmp    $0x1,%eax
  8017d5:	75 10                	jne    8017e7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	ff 73 0c             	pushl  0xc(%ebx)
  8017dd:	e8 c0 02 00 00       	call   801aa2 <nsipc_close>
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8017e7:	89 d0                	mov    %edx,%eax
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017f4:	6a 00                	push   $0x0
  8017f6:	ff 75 10             	pushl  0x10(%ebp)
  8017f9:	ff 75 0c             	pushl  0xc(%ebp)
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	ff 70 0c             	pushl  0xc(%eax)
  801802:	e8 78 03 00 00       	call   801b7f <nsipc_send>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80180f:	6a 00                	push   $0x0
  801811:	ff 75 10             	pushl  0x10(%ebp)
  801814:	ff 75 0c             	pushl  0xc(%ebp)
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	ff 70 0c             	pushl  0xc(%eax)
  80181d:	e8 f1 02 00 00       	call   801b13 <nsipc_recv>
}
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80182a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80182d:	52                   	push   %edx
  80182e:	50                   	push   %eax
  80182f:	e8 c3 f6 ff ff       	call   800ef7 <fd_lookup>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	78 17                	js     801852 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183e:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801844:	39 08                	cmp    %ecx,(%eax)
  801846:	75 05                	jne    80184d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801848:	8b 40 0c             	mov    0xc(%eax),%eax
  80184b:	eb 05                	jmp    801852 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80184d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	83 ec 1c             	sub    $0x1c,%esp
  80185c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80185e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801861:	50                   	push   %eax
  801862:	e8 41 f6 ff ff       	call   800ea8 <fd_alloc>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 1b                	js     80188b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801870:	83 ec 04             	sub    $0x4,%esp
  801873:	68 07 04 00 00       	push   $0x407
  801878:	ff 75 f4             	pushl  -0xc(%ebp)
  80187b:	6a 00                	push   $0x0
  80187d:	e8 ce f3 ff ff       	call   800c50 <sys_page_alloc>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	85 c0                	test   %eax,%eax
  801889:	79 10                	jns    80189b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	56                   	push   %esi
  80188f:	e8 0e 02 00 00       	call   801aa2 <nsipc_close>
		return r;
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	89 d8                	mov    %ebx,%eax
  801899:	eb 24                	jmp    8018bf <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80189b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8018a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8018b0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	50                   	push   %eax
  8018b7:	e8 c5 f5 ff ff       	call   800e81 <fd2num>
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	e8 50 ff ff ff       	call   801824 <fd2sockid>
		return r;
  8018d4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 1f                	js     8018f9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	ff 75 10             	pushl  0x10(%ebp)
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	50                   	push   %eax
  8018e4:	e8 12 01 00 00       	call   8019fb <nsipc_accept>
  8018e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ec:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 07                	js     8018f9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8018f2:	e8 5d ff ff ff       	call   801854 <alloc_sockfd>
  8018f7:	89 c1                	mov    %eax,%ecx
}
  8018f9:	89 c8                	mov    %ecx,%eax
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801903:	8b 45 08             	mov    0x8(%ebp),%eax
  801906:	e8 19 ff ff ff       	call   801824 <fd2sockid>
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 12                	js     801921 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	ff 75 10             	pushl  0x10(%ebp)
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	50                   	push   %eax
  801919:	e8 2d 01 00 00       	call   801a4b <nsipc_bind>
  80191e:	83 c4 10             	add    $0x10,%esp
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <shutdown>:

int
shutdown(int s, int how)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	e8 f3 fe ff ff       	call   801824 <fd2sockid>
  801931:	85 c0                	test   %eax,%eax
  801933:	78 0f                	js     801944 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	ff 75 0c             	pushl  0xc(%ebp)
  80193b:	50                   	push   %eax
  80193c:	e8 3f 01 00 00       	call   801a80 <nsipc_shutdown>
  801941:	83 c4 10             	add    $0x10,%esp
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
  80194f:	e8 d0 fe ff ff       	call   801824 <fd2sockid>
  801954:	85 c0                	test   %eax,%eax
  801956:	78 12                	js     80196a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801958:	83 ec 04             	sub    $0x4,%esp
  80195b:	ff 75 10             	pushl  0x10(%ebp)
  80195e:	ff 75 0c             	pushl  0xc(%ebp)
  801961:	50                   	push   %eax
  801962:	e8 55 01 00 00       	call   801abc <nsipc_connect>
  801967:	83 c4 10             	add    $0x10,%esp
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <listen>:

int
listen(int s, int backlog)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	e8 aa fe ff ff       	call   801824 <fd2sockid>
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 0f                	js     80198d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	ff 75 0c             	pushl  0xc(%ebp)
  801984:	50                   	push   %eax
  801985:	e8 67 01 00 00       	call   801af1 <nsipc_listen>
  80198a:	83 c4 10             	add    $0x10,%esp
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801995:	ff 75 10             	pushl  0x10(%ebp)
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	ff 75 08             	pushl  0x8(%ebp)
  80199e:	e8 3a 02 00 00       	call   801bdd <nsipc_socket>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 05                	js     8019af <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8019aa:	e8 a5 fe ff ff       	call   801854 <alloc_sockfd>
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	53                   	push   %ebx
  8019b5:	83 ec 04             	sub    $0x4,%esp
  8019b8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019ba:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8019c1:	75 12                	jne    8019d5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	6a 02                	push   $0x2
  8019c8:	e8 da 07 00 00       	call   8021a7 <ipc_find_env>
  8019cd:	a3 08 40 80 00       	mov    %eax,0x804008
  8019d2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019d5:	6a 07                	push   $0x7
  8019d7:	68 00 60 80 00       	push   $0x806000
  8019dc:	53                   	push   %ebx
  8019dd:	ff 35 08 40 80 00    	pushl  0x804008
  8019e3:	e8 6b 07 00 00       	call   802153 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019e8:	83 c4 0c             	add    $0xc,%esp
  8019eb:	6a 00                	push   $0x0
  8019ed:	6a 00                	push   $0x0
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 f0 06 00 00       	call   8020e6 <ipc_recv>
}
  8019f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    

008019fb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a0b:	8b 06                	mov    (%esi),%eax
  801a0d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a12:	b8 01 00 00 00       	mov    $0x1,%eax
  801a17:	e8 95 ff ff ff       	call   8019b1 <nsipc>
  801a1c:	89 c3                	mov    %eax,%ebx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 20                	js     801a42 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a22:	83 ec 04             	sub    $0x4,%esp
  801a25:	ff 35 10 60 80 00    	pushl  0x806010
  801a2b:	68 00 60 80 00       	push   $0x806000
  801a30:	ff 75 0c             	pushl  0xc(%ebp)
  801a33:	e8 a7 ef ff ff       	call   8009df <memmove>
		*addrlen = ret->ret_addrlen;
  801a38:	a1 10 60 80 00       	mov    0x806010,%eax
  801a3d:	89 06                	mov    %eax,(%esi)
  801a3f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801a42:	89 d8                	mov    %ebx,%eax
  801a44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a47:	5b                   	pop    %ebx
  801a48:	5e                   	pop    %esi
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 08             	sub    $0x8,%esp
  801a52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a5d:	53                   	push   %ebx
  801a5e:	ff 75 0c             	pushl  0xc(%ebp)
  801a61:	68 04 60 80 00       	push   $0x806004
  801a66:	e8 74 ef ff ff       	call   8009df <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a6b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a71:	b8 02 00 00 00       	mov    $0x2,%eax
  801a76:	e8 36 ff ff ff       	call   8019b1 <nsipc>
}
  801a7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a91:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a96:	b8 03 00 00 00       	mov    $0x3,%eax
  801a9b:	e8 11 ff ff ff       	call   8019b1 <nsipc>
}
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <nsipc_close>:

int
nsipc_close(int s)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aab:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ab0:	b8 04 00 00 00       	mov    $0x4,%eax
  801ab5:	e8 f7 fe ff ff       	call   8019b1 <nsipc>
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	53                   	push   %ebx
  801ac0:	83 ec 08             	sub    $0x8,%esp
  801ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ace:	53                   	push   %ebx
  801acf:	ff 75 0c             	pushl  0xc(%ebp)
  801ad2:	68 04 60 80 00       	push   $0x806004
  801ad7:	e8 03 ef ff ff       	call   8009df <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801adc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ae2:	b8 05 00 00 00       	mov    $0x5,%eax
  801ae7:	e8 c5 fe ff ff       	call   8019b1 <nsipc>
}
  801aec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801af7:	8b 45 08             	mov    0x8(%ebp),%eax
  801afa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b02:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b07:	b8 06 00 00 00       	mov    $0x6,%eax
  801b0c:	e8 a0 fe ff ff       	call   8019b1 <nsipc>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b23:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b29:	8b 45 14             	mov    0x14(%ebp),%eax
  801b2c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b31:	b8 07 00 00 00       	mov    $0x7,%eax
  801b36:	e8 76 fe ff ff       	call   8019b1 <nsipc>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 35                	js     801b76 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801b41:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801b46:	7f 04                	jg     801b4c <nsipc_recv+0x39>
  801b48:	39 c6                	cmp    %eax,%esi
  801b4a:	7d 16                	jge    801b62 <nsipc_recv+0x4f>
  801b4c:	68 3f 29 80 00       	push   $0x80293f
  801b51:	68 07 29 80 00       	push   $0x802907
  801b56:	6a 62                	push   $0x62
  801b58:	68 54 29 80 00       	push   $0x802954
  801b5d:	e8 8d e6 ff ff       	call   8001ef <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b62:	83 ec 04             	sub    $0x4,%esp
  801b65:	50                   	push   %eax
  801b66:	68 00 60 80 00       	push   $0x806000
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	e8 6c ee ff ff       	call   8009df <memmove>
  801b73:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b76:	89 d8                	mov    %ebx,%eax
  801b78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	53                   	push   %ebx
  801b83:	83 ec 04             	sub    $0x4,%esp
  801b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b91:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b97:	7e 16                	jle    801baf <nsipc_send+0x30>
  801b99:	68 60 29 80 00       	push   $0x802960
  801b9e:	68 07 29 80 00       	push   $0x802907
  801ba3:	6a 6d                	push   $0x6d
  801ba5:	68 54 29 80 00       	push   $0x802954
  801baa:	e8 40 e6 ff ff       	call   8001ef <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	53                   	push   %ebx
  801bb3:	ff 75 0c             	pushl  0xc(%ebp)
  801bb6:	68 0c 60 80 00       	push   $0x80600c
  801bbb:	e8 1f ee ff ff       	call   8009df <memmove>
	nsipcbuf.send.req_size = size;
  801bc0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801bc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801bce:	b8 08 00 00 00       	mov    $0x8,%eax
  801bd3:	e8 d9 fd ff ff       	call   8019b1 <nsipc>
}
  801bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bee:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801bf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bfb:	b8 09 00 00 00       	mov    $0x9,%eax
  801c00:	e8 ac fd ff ff       	call   8019b1 <nsipc>
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	56                   	push   %esi
  801c0b:	53                   	push   %ebx
  801c0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 08             	pushl  0x8(%ebp)
  801c15:	e8 77 f2 ff ff       	call   800e91 <fd2data>
  801c1a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c1c:	83 c4 08             	add    $0x8,%esp
  801c1f:	68 6c 29 80 00       	push   $0x80296c
  801c24:	53                   	push   %ebx
  801c25:	e8 23 ec ff ff       	call   80084d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c2a:	8b 46 04             	mov    0x4(%esi),%eax
  801c2d:	2b 06                	sub    (%esi),%eax
  801c2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c35:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c3c:	00 00 00 
	stat->st_dev = &devpipe;
  801c3f:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801c46:	30 80 00 
	return 0;
}
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	53                   	push   %ebx
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c5f:	53                   	push   %ebx
  801c60:	6a 00                	push   $0x0
  801c62:	e8 6e f0 ff ff       	call   800cd5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c67:	89 1c 24             	mov    %ebx,(%esp)
  801c6a:	e8 22 f2 ff ff       	call   800e91 <fd2data>
  801c6f:	83 c4 08             	add    $0x8,%esp
  801c72:	50                   	push   %eax
  801c73:	6a 00                	push   $0x0
  801c75:	e8 5b f0 ff ff       	call   800cd5 <sys_page_unmap>
}
  801c7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	57                   	push   %edi
  801c83:	56                   	push   %esi
  801c84:	53                   	push   %ebx
  801c85:	83 ec 1c             	sub    $0x1c,%esp
  801c88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c8b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c8d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801c92:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	ff 75 e0             	pushl  -0x20(%ebp)
  801c9b:	e8 40 05 00 00       	call   8021e0 <pageref>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	89 3c 24             	mov    %edi,(%esp)
  801ca5:	e8 36 05 00 00       	call   8021e0 <pageref>
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	39 c3                	cmp    %eax,%ebx
  801caf:	0f 94 c1             	sete   %cl
  801cb2:	0f b6 c9             	movzbl %cl,%ecx
  801cb5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cb8:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801cbe:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cc1:	39 ce                	cmp    %ecx,%esi
  801cc3:	74 1b                	je     801ce0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cc5:	39 c3                	cmp    %eax,%ebx
  801cc7:	75 c4                	jne    801c8d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cc9:	8b 42 58             	mov    0x58(%edx),%eax
  801ccc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ccf:	50                   	push   %eax
  801cd0:	56                   	push   %esi
  801cd1:	68 73 29 80 00       	push   $0x802973
  801cd6:	e8 ed e5 ff ff       	call   8002c8 <cprintf>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	eb ad                	jmp    801c8d <_pipeisclosed+0xe>
	}
}
  801ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5f                   	pop    %edi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	57                   	push   %edi
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	83 ec 28             	sub    $0x28,%esp
  801cf4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cf7:	56                   	push   %esi
  801cf8:	e8 94 f1 ff ff       	call   800e91 <fd2data>
  801cfd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	bf 00 00 00 00       	mov    $0x0,%edi
  801d07:	eb 4b                	jmp    801d54 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d09:	89 da                	mov    %ebx,%edx
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	e8 6d ff ff ff       	call   801c7f <_pipeisclosed>
  801d12:	85 c0                	test   %eax,%eax
  801d14:	75 48                	jne    801d5e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d16:	e8 16 ef ff ff       	call   800c31 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d1b:	8b 43 04             	mov    0x4(%ebx),%eax
  801d1e:	8b 0b                	mov    (%ebx),%ecx
  801d20:	8d 51 20             	lea    0x20(%ecx),%edx
  801d23:	39 d0                	cmp    %edx,%eax
  801d25:	73 e2                	jae    801d09 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d2e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	c1 fa 1f             	sar    $0x1f,%edx
  801d36:	89 d1                	mov    %edx,%ecx
  801d38:	c1 e9 1b             	shr    $0x1b,%ecx
  801d3b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d3e:	83 e2 1f             	and    $0x1f,%edx
  801d41:	29 ca                	sub    %ecx,%edx
  801d43:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d47:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d4b:	83 c0 01             	add    $0x1,%eax
  801d4e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d51:	83 c7 01             	add    $0x1,%edi
  801d54:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d57:	75 c2                	jne    801d1b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d59:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5c:	eb 05                	jmp    801d63 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	57                   	push   %edi
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	83 ec 18             	sub    $0x18,%esp
  801d74:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d77:	57                   	push   %edi
  801d78:	e8 14 f1 ff ff       	call   800e91 <fd2data>
  801d7d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d87:	eb 3d                	jmp    801dc6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d89:	85 db                	test   %ebx,%ebx
  801d8b:	74 04                	je     801d91 <devpipe_read+0x26>
				return i;
  801d8d:	89 d8                	mov    %ebx,%eax
  801d8f:	eb 44                	jmp    801dd5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d91:	89 f2                	mov    %esi,%edx
  801d93:	89 f8                	mov    %edi,%eax
  801d95:	e8 e5 fe ff ff       	call   801c7f <_pipeisclosed>
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	75 32                	jne    801dd0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d9e:	e8 8e ee ff ff       	call   800c31 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801da3:	8b 06                	mov    (%esi),%eax
  801da5:	3b 46 04             	cmp    0x4(%esi),%eax
  801da8:	74 df                	je     801d89 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801daa:	99                   	cltd   
  801dab:	c1 ea 1b             	shr    $0x1b,%edx
  801dae:	01 d0                	add    %edx,%eax
  801db0:	83 e0 1f             	and    $0x1f,%eax
  801db3:	29 d0                	sub    %edx,%eax
  801db5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dbd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dc0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc3:	83 c3 01             	add    $0x1,%ebx
  801dc6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc9:	75 d8                	jne    801da3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dcb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dce:	eb 05                	jmp    801dd5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	56                   	push   %esi
  801de1:	53                   	push   %ebx
  801de2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de8:	50                   	push   %eax
  801de9:	e8 ba f0 ff ff       	call   800ea8 <fd_alloc>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 2c 01 00 00    	js     801f27 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfb:	83 ec 04             	sub    $0x4,%esp
  801dfe:	68 07 04 00 00       	push   $0x407
  801e03:	ff 75 f4             	pushl  -0xc(%ebp)
  801e06:	6a 00                	push   $0x0
  801e08:	e8 43 ee ff ff       	call   800c50 <sys_page_alloc>
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	0f 88 0d 01 00 00    	js     801f27 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	e8 82 f0 ff ff       	call   800ea8 <fd_alloc>
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	0f 88 e2 00 00 00    	js     801f15 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e33:	83 ec 04             	sub    $0x4,%esp
  801e36:	68 07 04 00 00       	push   $0x407
  801e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 0b ee ff ff       	call   800c50 <sys_page_alloc>
  801e45:	89 c3                	mov    %eax,%ebx
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	0f 88 c3 00 00 00    	js     801f15 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	ff 75 f4             	pushl  -0xc(%ebp)
  801e58:	e8 34 f0 ff ff       	call   800e91 <fd2data>
  801e5d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5f:	83 c4 0c             	add    $0xc,%esp
  801e62:	68 07 04 00 00       	push   $0x407
  801e67:	50                   	push   %eax
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 e1 ed ff ff       	call   800c50 <sys_page_alloc>
  801e6f:	89 c3                	mov    %eax,%ebx
  801e71:	83 c4 10             	add    $0x10,%esp
  801e74:	85 c0                	test   %eax,%eax
  801e76:	0f 88 89 00 00 00    	js     801f05 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e82:	e8 0a f0 ff ff       	call   800e91 <fd2data>
  801e87:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e8e:	50                   	push   %eax
  801e8f:	6a 00                	push   $0x0
  801e91:	56                   	push   %esi
  801e92:	6a 00                	push   $0x0
  801e94:	e8 fa ed ff ff       	call   800c93 <sys_page_map>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 20             	add    $0x20,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 55                	js     801ef7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ea2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed2:	e8 aa ef ff ff       	call   800e81 <fd2num>
  801ed7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eda:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801edc:	83 c4 04             	add    $0x4,%esp
  801edf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee2:	e8 9a ef ff ff       	call   800e81 <fd2num>
  801ee7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eea:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef5:	eb 30                	jmp    801f27 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ef7:	83 ec 08             	sub    $0x8,%esp
  801efa:	56                   	push   %esi
  801efb:	6a 00                	push   $0x0
  801efd:	e8 d3 ed ff ff       	call   800cd5 <sys_page_unmap>
  801f02:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f05:	83 ec 08             	sub    $0x8,%esp
  801f08:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0b:	6a 00                	push   $0x0
  801f0d:	e8 c3 ed ff ff       	call   800cd5 <sys_page_unmap>
  801f12:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f15:	83 ec 08             	sub    $0x8,%esp
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 b3 ed ff ff       	call   800cd5 <sys_page_unmap>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f27:	89 d0                	mov    %edx,%eax
  801f29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5d                   	pop    %ebp
  801f2f:	c3                   	ret    

00801f30 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f39:	50                   	push   %eax
  801f3a:	ff 75 08             	pushl  0x8(%ebp)
  801f3d:	e8 b5 ef ff ff       	call   800ef7 <fd_lookup>
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 18                	js     801f61 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f49:	83 ec 0c             	sub    $0xc,%esp
  801f4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4f:	e8 3d ef ff ff       	call   800e91 <fd2data>
	return _pipeisclosed(fd, p);
  801f54:	89 c2                	mov    %eax,%edx
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	e8 21 fd ff ff       	call   801c7f <_pipeisclosed>
  801f5e:	83 c4 10             	add    $0x10,%esp
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f73:	68 8b 29 80 00       	push   $0x80298b
  801f78:	ff 75 0c             	pushl  0xc(%ebp)
  801f7b:	e8 cd e8 ff ff       	call   80084d <strcpy>
	return 0;
}
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	57                   	push   %edi
  801f8b:	56                   	push   %esi
  801f8c:	53                   	push   %ebx
  801f8d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f93:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f98:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f9e:	eb 2d                	jmp    801fcd <devcons_write+0x46>
		m = n - tot;
  801fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fa5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fa8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fad:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fb0:	83 ec 04             	sub    $0x4,%esp
  801fb3:	53                   	push   %ebx
  801fb4:	03 45 0c             	add    0xc(%ebp),%eax
  801fb7:	50                   	push   %eax
  801fb8:	57                   	push   %edi
  801fb9:	e8 21 ea ff ff       	call   8009df <memmove>
		sys_cputs(buf, m);
  801fbe:	83 c4 08             	add    $0x8,%esp
  801fc1:	53                   	push   %ebx
  801fc2:	57                   	push   %edi
  801fc3:	e8 cc eb ff ff       	call   800b94 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc8:	01 de                	add    %ebx,%esi
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	89 f0                	mov    %esi,%eax
  801fcf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fd2:	72 cc                	jb     801fa0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5f                   	pop    %edi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	83 ec 08             	sub    $0x8,%esp
  801fe2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fe7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801feb:	74 2a                	je     802017 <devcons_read+0x3b>
  801fed:	eb 05                	jmp    801ff4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fef:	e8 3d ec ff ff       	call   800c31 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ff4:	e8 b9 eb ff ff       	call   800bb2 <sys_cgetc>
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	74 f2                	je     801fef <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 16                	js     802017 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802001:	83 f8 04             	cmp    $0x4,%eax
  802004:	74 0c                	je     802012 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802006:	8b 55 0c             	mov    0xc(%ebp),%edx
  802009:	88 02                	mov    %al,(%edx)
	return 1;
  80200b:	b8 01 00 00 00       	mov    $0x1,%eax
  802010:	eb 05                	jmp    802017 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802017:	c9                   	leave  
  802018:	c3                   	ret    

00802019 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802025:	6a 01                	push   $0x1
  802027:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80202a:	50                   	push   %eax
  80202b:	e8 64 eb ff ff       	call   800b94 <sys_cputs>
}
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <getchar>:

int
getchar(void)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80203b:	6a 01                	push   $0x1
  80203d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802040:	50                   	push   %eax
  802041:	6a 00                	push   $0x0
  802043:	e8 15 f1 ff ff       	call   80115d <read>
	if (r < 0)
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 0f                	js     80205e <getchar+0x29>
		return r;
	if (r < 1)
  80204f:	85 c0                	test   %eax,%eax
  802051:	7e 06                	jle    802059 <getchar+0x24>
		return -E_EOF;
	return c;
  802053:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802057:	eb 05                	jmp    80205e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802059:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802066:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	ff 75 08             	pushl  0x8(%ebp)
  80206d:	e8 85 ee ff ff       	call   800ef7 <fd_lookup>
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	78 11                	js     80208a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207c:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802082:	39 10                	cmp    %edx,(%eax)
  802084:	0f 94 c0             	sete   %al
  802087:	0f b6 c0             	movzbl %al,%eax
}
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <opencons>:

int
opencons(void)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802092:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802095:	50                   	push   %eax
  802096:	e8 0d ee ff ff       	call   800ea8 <fd_alloc>
  80209b:	83 c4 10             	add    $0x10,%esp
		return r;
  80209e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	78 3e                	js     8020e2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a4:	83 ec 04             	sub    $0x4,%esp
  8020a7:	68 07 04 00 00       	push   $0x407
  8020ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8020af:	6a 00                	push   $0x0
  8020b1:	e8 9a eb ff ff       	call   800c50 <sys_page_alloc>
  8020b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	78 23                	js     8020e2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020bf:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d4:	83 ec 0c             	sub    $0xc,%esp
  8020d7:	50                   	push   %eax
  8020d8:	e8 a4 ed ff ff       	call   800e81 <fd2num>
  8020dd:	89 c2                	mov    %eax,%edx
  8020df:	83 c4 10             	add    $0x10,%esp
}
  8020e2:	89 d0                	mov    %edx,%eax
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	56                   	push   %esi
  8020ea:	53                   	push   %ebx
  8020eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	74 0e                	je     802106 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8020f8:	83 ec 0c             	sub    $0xc,%esp
  8020fb:	50                   	push   %eax
  8020fc:	e8 ff ec ff ff       	call   800e00 <sys_ipc_recv>
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	eb 10                	jmp    802116 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802106:	83 ec 0c             	sub    $0xc,%esp
  802109:	68 00 00 00 f0       	push   $0xf0000000
  80210e:	e8 ed ec ff ff       	call   800e00 <sys_ipc_recv>
  802113:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802116:	85 c0                	test   %eax,%eax
  802118:	74 0e                	je     802128 <ipc_recv+0x42>
    	*from_env_store = 0;
  80211a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  802120:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802126:	eb 24                	jmp    80214c <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802128:	85 f6                	test   %esi,%esi
  80212a:	74 0a                	je     802136 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80212c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802131:	8b 40 74             	mov    0x74(%eax),%eax
  802134:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802136:	85 db                	test   %ebx,%ebx
  802138:	74 0a                	je     802144 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  80213a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80213f:	8b 40 78             	mov    0x78(%eax),%eax
  802142:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802144:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802149:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80214c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	57                   	push   %edi
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	83 ec 0c             	sub    $0xc,%esp
  80215c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80215f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802162:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802165:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80216c:	0f 44 d8             	cmove  %eax,%ebx
  80216f:	eb 1c                	jmp    80218d <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802171:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802174:	74 12                	je     802188 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802176:	50                   	push   %eax
  802177:	68 97 29 80 00       	push   $0x802997
  80217c:	6a 4b                	push   $0x4b
  80217e:	68 af 29 80 00       	push   $0x8029af
  802183:	e8 67 e0 ff ff       	call   8001ef <_panic>
        }	
        sys_yield();
  802188:	e8 a4 ea ff ff       	call   800c31 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80218d:	ff 75 14             	pushl  0x14(%ebp)
  802190:	53                   	push   %ebx
  802191:	56                   	push   %esi
  802192:	57                   	push   %edi
  802193:	e8 45 ec ff ff       	call   800ddd <sys_ipc_try_send>
  802198:	83 c4 10             	add    $0x10,%esp
  80219b:	85 c0                	test   %eax,%eax
  80219d:	75 d2                	jne    802171 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80219f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021b5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021bb:	8b 52 50             	mov    0x50(%edx),%edx
  8021be:	39 ca                	cmp    %ecx,%edx
  8021c0:	75 0d                	jne    8021cf <ipc_find_env+0x28>
			return envs[i].env_id;
  8021c2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ca:	8b 40 48             	mov    0x48(%eax),%eax
  8021cd:	eb 0f                	jmp    8021de <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021cf:	83 c0 01             	add    $0x1,%eax
  8021d2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d7:	75 d9                	jne    8021b2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	c1 e8 16             	shr    $0x16,%eax
  8021eb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f7:	f6 c1 01             	test   $0x1,%cl
  8021fa:	74 1d                	je     802219 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fc:	c1 ea 0c             	shr    $0xc,%edx
  8021ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802206:	f6 c2 01             	test   $0x1,%dl
  802209:	74 0e                	je     802219 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220b:	c1 ea 0c             	shr    $0xc,%edx
  80220e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802215:	ef 
  802216:	0f b7 c0             	movzwl %ax,%eax
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80222b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80222f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 f6                	test   %esi,%esi
  802239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223d:	89 ca                	mov    %ecx,%edx
  80223f:	89 f8                	mov    %edi,%eax
  802241:	75 3d                	jne    802280 <__udivdi3+0x60>
  802243:	39 cf                	cmp    %ecx,%edi
  802245:	0f 87 c5 00 00 00    	ja     802310 <__udivdi3+0xf0>
  80224b:	85 ff                	test   %edi,%edi
  80224d:	89 fd                	mov    %edi,%ebp
  80224f:	75 0b                	jne    80225c <__udivdi3+0x3c>
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	31 d2                	xor    %edx,%edx
  802258:	f7 f7                	div    %edi
  80225a:	89 c5                	mov    %eax,%ebp
  80225c:	89 c8                	mov    %ecx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	f7 f5                	div    %ebp
  802262:	89 c1                	mov    %eax,%ecx
  802264:	89 d8                	mov    %ebx,%eax
  802266:	89 cf                	mov    %ecx,%edi
  802268:	f7 f5                	div    %ebp
  80226a:	89 c3                	mov    %eax,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	39 ce                	cmp    %ecx,%esi
  802282:	77 74                	ja     8022f8 <__udivdi3+0xd8>
  802284:	0f bd fe             	bsr    %esi,%edi
  802287:	83 f7 1f             	xor    $0x1f,%edi
  80228a:	0f 84 98 00 00 00    	je     802328 <__udivdi3+0x108>
  802290:	bb 20 00 00 00       	mov    $0x20,%ebx
  802295:	89 f9                	mov    %edi,%ecx
  802297:	89 c5                	mov    %eax,%ebp
  802299:	29 fb                	sub    %edi,%ebx
  80229b:	d3 e6                	shl    %cl,%esi
  80229d:	89 d9                	mov    %ebx,%ecx
  80229f:	d3 ed                	shr    %cl,%ebp
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	09 ee                	or     %ebp,%esi
  8022a7:	89 d9                	mov    %ebx,%ecx
  8022a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ad:	89 d5                	mov    %edx,%ebp
  8022af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b3:	d3 ed                	shr    %cl,%ebp
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e2                	shl    %cl,%edx
  8022b9:	89 d9                	mov    %ebx,%ecx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	09 c2                	or     %eax,%edx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	89 ea                	mov    %ebp,%edx
  8022c3:	f7 f6                	div    %esi
  8022c5:	89 d5                	mov    %edx,%ebp
  8022c7:	89 c3                	mov    %eax,%ebx
  8022c9:	f7 64 24 0c          	mull   0xc(%esp)
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	72 10                	jb     8022e1 <__udivdi3+0xc1>
  8022d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e6                	shl    %cl,%esi
  8022d9:	39 c6                	cmp    %eax,%esi
  8022db:	73 07                	jae    8022e4 <__udivdi3+0xc4>
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	75 03                	jne    8022e4 <__udivdi3+0xc4>
  8022e1:	83 eb 01             	sub    $0x1,%ebx
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 d8                	mov    %ebx,%eax
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 ff                	xor    %edi,%edi
  8022fa:	31 db                	xor    %ebx,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d8                	mov    %ebx,%eax
  802312:	f7 f7                	div    %edi
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 c3                	mov    %eax,%ebx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 fa                	mov    %edi,%edx
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	39 ce                	cmp    %ecx,%esi
  80232a:	72 0c                	jb     802338 <__udivdi3+0x118>
  80232c:	31 db                	xor    %ebx,%ebx
  80232e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802332:	0f 87 34 ff ff ff    	ja     80226c <__udivdi3+0x4c>
  802338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80233d:	e9 2a ff ff ff       	jmp    80226c <__udivdi3+0x4c>
  802342:	66 90                	xchg   %ax,%ax
  802344:	66 90                	xchg   %ax,%ax
  802346:	66 90                	xchg   %ax,%ax
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__umoddi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80235f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 d2                	test   %edx,%edx
  802369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 f3                	mov    %esi,%ebx
  802373:	89 3c 24             	mov    %edi,(%esp)
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	75 1c                	jne    802398 <__umoddi3+0x48>
  80237c:	39 f7                	cmp    %esi,%edi
  80237e:	76 50                	jbe    8023d0 <__umoddi3+0x80>
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	f7 f7                	div    %edi
  802386:	89 d0                	mov    %edx,%eax
  802388:	31 d2                	xor    %edx,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	39 f2                	cmp    %esi,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	77 52                	ja     8023f0 <__umoddi3+0xa0>
  80239e:	0f bd ea             	bsr    %edx,%ebp
  8023a1:	83 f5 1f             	xor    $0x1f,%ebp
  8023a4:	75 5a                	jne    802400 <__umoddi3+0xb0>
  8023a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023aa:	0f 82 e0 00 00 00    	jb     802490 <__umoddi3+0x140>
  8023b0:	39 0c 24             	cmp    %ecx,(%esp)
  8023b3:	0f 86 d7 00 00 00    	jbe    802490 <__umoddi3+0x140>
  8023b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	85 ff                	test   %edi,%edi
  8023d2:	89 fd                	mov    %edi,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x91>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f7                	div    %edi
  8023df:	89 c5                	mov    %eax,%ebp
  8023e1:	89 f0                	mov    %esi,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f5                	div    %ebp
  8023e7:	89 c8                	mov    %ecx,%eax
  8023e9:	f7 f5                	div    %ebp
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	eb 99                	jmp    802388 <__umoddi3+0x38>
  8023ef:	90                   	nop
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	83 c4 1c             	add    $0x1c,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	8b 34 24             	mov    (%esp),%esi
  802403:	bf 20 00 00 00       	mov    $0x20,%edi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	29 ef                	sub    %ebp,%edi
  80240c:	d3 e0                	shl    %cl,%eax
  80240e:	89 f9                	mov    %edi,%ecx
  802410:	89 f2                	mov    %esi,%edx
  802412:	d3 ea                	shr    %cl,%edx
  802414:	89 e9                	mov    %ebp,%ecx
  802416:	09 c2                	or     %eax,%edx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 14 24             	mov    %edx,(%esp)
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	d3 e2                	shl    %cl,%edx
  802421:	89 f9                	mov    %edi,%ecx
  802423:	89 54 24 04          	mov    %edx,0x4(%esp)
  802427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	89 c6                	mov    %eax,%esi
  802431:	d3 e3                	shl    %cl,%ebx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 d0                	mov    %edx,%eax
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	09 d8                	or     %ebx,%eax
  80243d:	89 d3                	mov    %edx,%ebx
  80243f:	89 f2                	mov    %esi,%edx
  802441:	f7 34 24             	divl   (%esp)
  802444:	89 d6                	mov    %edx,%esi
  802446:	d3 e3                	shl    %cl,%ebx
  802448:	f7 64 24 04          	mull   0x4(%esp)
  80244c:	39 d6                	cmp    %edx,%esi
  80244e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802452:	89 d1                	mov    %edx,%ecx
  802454:	89 c3                	mov    %eax,%ebx
  802456:	72 08                	jb     802460 <__umoddi3+0x110>
  802458:	75 11                	jne    80246b <__umoddi3+0x11b>
  80245a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80245e:	73 0b                	jae    80246b <__umoddi3+0x11b>
  802460:	2b 44 24 04          	sub    0x4(%esp),%eax
  802464:	1b 14 24             	sbb    (%esp),%edx
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 c3                	mov    %eax,%ebx
  80246b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80246f:	29 da                	sub    %ebx,%edx
  802471:	19 ce                	sbb    %ecx,%esi
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e0                	shl    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	d3 ee                	shr    %cl,%esi
  802481:	09 d0                	or     %edx,%eax
  802483:	89 f2                	mov    %esi,%edx
  802485:	83 c4 1c             	add    $0x1c,%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	29 f9                	sub    %edi,%ecx
  802492:	19 d6                	sbb    %edx,%esi
  802494:	89 74 24 04          	mov    %esi,0x4(%esp)
  802498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80249c:	e9 18 ff ff ff       	jmp    8023b9 <__umoddi3+0x69>
