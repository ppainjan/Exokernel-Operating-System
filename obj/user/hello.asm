
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 80 22 80 00       	push   $0x802280
  80003e:	e8 18 01 00 00       	call   80015b <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 22 80 00       	push   $0x80228e
  800054:	e8 02 01 00 00       	call   80015b <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800069:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800070:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800073:	e8 2d 0a 00 00       	call   800aa5 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x37>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0a 00 00 00       	call   8000ae <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b4:	e8 26 0e 00 00       	call   800edf <close_all>
	sys_env_destroy(0);
  8000b9:	83 ec 0c             	sub    $0xc,%esp
  8000bc:	6a 00                	push   $0x0
  8000be:	e8 a1 09 00 00       	call   800a64 <sys_env_destroy>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 13                	mov    (%ebx),%edx
  8000d4:	8d 42 01             	lea    0x1(%edx),%eax
  8000d7:	89 03                	mov    %eax,(%ebx)
  8000d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	75 1a                	jne    800101 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	68 ff 00 00 00       	push   $0xff
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 2f 09 00 00       	call   800a27 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fe:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800101:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800108:	c9                   	leave  
  800109:	c3                   	ret    

0080010a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800113:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011a:	00 00 00 
	b.cnt = 0;
  80011d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800124:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800127:	ff 75 0c             	pushl  0xc(%ebp)
  80012a:	ff 75 08             	pushl  0x8(%ebp)
  80012d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	68 c8 00 80 00       	push   $0x8000c8
  800139:	e8 54 01 00 00       	call   800292 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013e:	83 c4 08             	add    $0x8,%esp
  800141:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	e8 d4 08 00 00       	call   800a27 <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	50                   	push   %eax
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	e8 9d ff ff ff       	call   80010a <vcprintf>
	va_end(ap);

	return cnt;
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 1c             	sub    $0x1c,%esp
  800178:	89 c7                	mov    %eax,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800182:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800185:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800188:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80018b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800190:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800193:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800196:	39 d3                	cmp    %edx,%ebx
  800198:	72 05                	jb     80019f <printnum+0x30>
  80019a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019d:	77 45                	ja     8001e4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	ff 75 18             	pushl  0x18(%ebp)
  8001a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ab:	53                   	push   %ebx
  8001ac:	ff 75 10             	pushl  0x10(%ebp)
  8001af:	83 ec 08             	sub    $0x8,%esp
  8001b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001be:	e8 2d 1e 00 00       	call   801ff0 <__udivdi3>
  8001c3:	83 c4 18             	add    $0x18,%esp
  8001c6:	52                   	push   %edx
  8001c7:	50                   	push   %eax
  8001c8:	89 f2                	mov    %esi,%edx
  8001ca:	89 f8                	mov    %edi,%eax
  8001cc:	e8 9e ff ff ff       	call   80016f <printnum>
  8001d1:	83 c4 20             	add    $0x20,%esp
  8001d4:	eb 18                	jmp    8001ee <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	56                   	push   %esi
  8001da:	ff 75 18             	pushl  0x18(%ebp)
  8001dd:	ff d7                	call   *%edi
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	eb 03                	jmp    8001e7 <printnum+0x78>
  8001e4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e7:	83 eb 01             	sub    $0x1,%ebx
  8001ea:	85 db                	test   %ebx,%ebx
  8001ec:	7f e8                	jg     8001d6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	83 ec 04             	sub    $0x4,%esp
  8001f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800201:	e8 1a 1f 00 00       	call   802120 <__umoddi3>
  800206:	83 c4 14             	add    $0x14,%esp
  800209:	0f be 80 af 22 80 00 	movsbl 0x8022af(%eax),%eax
  800210:	50                   	push   %eax
  800211:	ff d7                	call   *%edi
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5f                   	pop    %edi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800221:	83 fa 01             	cmp    $0x1,%edx
  800224:	7e 0e                	jle    800234 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	8b 52 04             	mov    0x4(%edx),%edx
  800232:	eb 22                	jmp    800256 <getuint+0x38>
	else if (lflag)
  800234:	85 d2                	test   %edx,%edx
  800236:	74 10                	je     800248 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
  800246:	eb 0e                	jmp    800256 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    

00800258 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800262:	8b 10                	mov    (%eax),%edx
  800264:	3b 50 04             	cmp    0x4(%eax),%edx
  800267:	73 0a                	jae    800273 <sprintputch+0x1b>
		*b->buf++ = ch;
  800269:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	88 02                	mov    %al,(%edx)
}
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027e:	50                   	push   %eax
  80027f:	ff 75 10             	pushl  0x10(%ebp)
  800282:	ff 75 0c             	pushl  0xc(%ebp)
  800285:	ff 75 08             	pushl  0x8(%ebp)
  800288:	e8 05 00 00 00       	call   800292 <vprintfmt>
	va_end(ap);
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 2c             	sub    $0x2c,%esp
  80029b:	8b 75 08             	mov    0x8(%ebp),%esi
  80029e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a4:	eb 12                	jmp    8002b8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	0f 84 89 03 00 00    	je     800637 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	53                   	push   %ebx
  8002b2:	50                   	push   %eax
  8002b3:	ff d6                	call   *%esi
  8002b5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b8:	83 c7 01             	add    $0x1,%edi
  8002bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002bf:	83 f8 25             	cmp    $0x25,%eax
  8002c2:	75 e2                	jne    8002a6 <vprintfmt+0x14>
  8002c4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 07                	jmp    8002eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002eb:	8d 47 01             	lea    0x1(%edi),%eax
  8002ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f1:	0f b6 07             	movzbl (%edi),%eax
  8002f4:	0f b6 c8             	movzbl %al,%ecx
  8002f7:	83 e8 23             	sub    $0x23,%eax
  8002fa:	3c 55                	cmp    $0x55,%al
  8002fc:	0f 87 1a 03 00 00    	ja     80061c <vprintfmt+0x38a>
  800302:	0f b6 c0             	movzbl %al,%eax
  800305:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  80030c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800313:	eb d6                	jmp    8002eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800318:	b8 00 00 00 00       	mov    $0x0,%eax
  80031d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800320:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800323:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800327:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80032a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80032d:	83 fa 09             	cmp    $0x9,%edx
  800330:	77 39                	ja     80036b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800332:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800335:	eb e9                	jmp    800320 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 48 04             	lea    0x4(%eax),%ecx
  80033d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800340:	8b 00                	mov    (%eax),%eax
  800342:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800348:	eb 27                	jmp    800371 <vprintfmt+0xdf>
  80034a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034d:	85 c0                	test   %eax,%eax
  80034f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800354:	0f 49 c8             	cmovns %eax,%ecx
  800357:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	eb 8c                	jmp    8002eb <vprintfmt+0x59>
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800362:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800369:	eb 80                	jmp    8002eb <vprintfmt+0x59>
  80036b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80036e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800371:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800375:	0f 89 70 ff ff ff    	jns    8002eb <vprintfmt+0x59>
				width = precision, precision = -1;
  80037b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800381:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800388:	e9 5e ff ff ff       	jmp    8002eb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800393:	e9 53 ff ff ff       	jmp    8002eb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 50 04             	lea    0x4(%eax),%edx
  80039e:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	53                   	push   %ebx
  8003a5:	ff 30                	pushl  (%eax)
  8003a7:	ff d6                	call   *%esi
			break;
  8003a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003af:	e9 04 ff ff ff       	jmp    8002b8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	99                   	cltd   
  8003c0:	31 d0                	xor    %edx,%eax
  8003c2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c4:	83 f8 0f             	cmp    $0xf,%eax
  8003c7:	7f 0b                	jg     8003d4 <vprintfmt+0x142>
  8003c9:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8003d0:	85 d2                	test   %edx,%edx
  8003d2:	75 18                	jne    8003ec <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003d4:	50                   	push   %eax
  8003d5:	68 c7 22 80 00       	push   $0x8022c7
  8003da:	53                   	push   %ebx
  8003db:	56                   	push   %esi
  8003dc:	e8 94 fe ff ff       	call   800275 <printfmt>
  8003e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e7:	e9 cc fe ff ff       	jmp    8002b8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ec:	52                   	push   %edx
  8003ed:	68 95 26 80 00       	push   $0x802695
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 7c fe ff ff       	call   800275 <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ff:	e9 b4 fe ff ff       	jmp    8002b8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040f:	85 ff                	test   %edi,%edi
  800411:	b8 c0 22 80 00       	mov    $0x8022c0,%eax
  800416:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	0f 8e 94 00 00 00    	jle    8004b7 <vprintfmt+0x225>
  800423:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800427:	0f 84 98 00 00 00    	je     8004c5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	ff 75 d0             	pushl  -0x30(%ebp)
  800433:	57                   	push   %edi
  800434:	e8 86 02 00 00       	call   8006bf <strnlen>
  800439:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043c:	29 c1                	sub    %eax,%ecx
  80043e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800441:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800444:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800450:	eb 0f                	jmp    800461 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	53                   	push   %ebx
  800456:	ff 75 e0             	pushl  -0x20(%ebp)
  800459:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	83 ef 01             	sub    $0x1,%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	85 ff                	test   %edi,%edi
  800463:	7f ed                	jg     800452 <vprintfmt+0x1c0>
  800465:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800468:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046b:	85 c9                	test   %ecx,%ecx
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	0f 49 c1             	cmovns %ecx,%eax
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 75 08             	mov    %esi,0x8(%ebp)
  80047a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800480:	89 cb                	mov    %ecx,%ebx
  800482:	eb 4d                	jmp    8004d1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800484:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800488:	74 1b                	je     8004a5 <vprintfmt+0x213>
  80048a:	0f be c0             	movsbl %al,%eax
  80048d:	83 e8 20             	sub    $0x20,%eax
  800490:	83 f8 5e             	cmp    $0x5e,%eax
  800493:	76 10                	jbe    8004a5 <vprintfmt+0x213>
					putch('?', putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	6a 3f                	push   $0x3f
  80049d:	ff 55 08             	call   *0x8(%ebp)
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	eb 0d                	jmp    8004b2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	52                   	push   %edx
  8004ac:	ff 55 08             	call   *0x8(%ebp)
  8004af:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	83 eb 01             	sub    $0x1,%ebx
  8004b5:	eb 1a                	jmp    8004d1 <vprintfmt+0x23f>
  8004b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c3:	eb 0c                	jmp    8004d1 <vprintfmt+0x23f>
  8004c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d1:	83 c7 01             	add    $0x1,%edi
  8004d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d8:	0f be d0             	movsbl %al,%edx
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	74 23                	je     800502 <vprintfmt+0x270>
  8004df:	85 f6                	test   %esi,%esi
  8004e1:	78 a1                	js     800484 <vprintfmt+0x1f2>
  8004e3:	83 ee 01             	sub    $0x1,%esi
  8004e6:	79 9c                	jns    800484 <vprintfmt+0x1f2>
  8004e8:	89 df                	mov    %ebx,%edi
  8004ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f0:	eb 18                	jmp    80050a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	6a 20                	push   $0x20
  8004f8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fa:	83 ef 01             	sub    $0x1,%edi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb 08                	jmp    80050a <vprintfmt+0x278>
  800502:	89 df                	mov    %ebx,%edi
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	85 ff                	test   %edi,%edi
  80050c:	7f e4                	jg     8004f2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	e9 a2 fd ff ff       	jmp    8002b8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800516:	83 fa 01             	cmp    $0x1,%edx
  800519:	7e 16                	jle    800531 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 08             	lea    0x8(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 50 04             	mov    0x4(%eax),%edx
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052f:	eb 32                	jmp    800563 <vprintfmt+0x2d1>
	else if (lflag)
  800531:	85 d2                	test   %edx,%edx
  800533:	74 18                	je     80054d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054b:	eb 16                	jmp    800563 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800563:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800566:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800569:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800572:	79 74                	jns    8005e8 <vprintfmt+0x356>
				putch('-', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 2d                	push   $0x2d
  80057a:	ff d6                	call   *%esi
				num = -(long long) num;
  80057c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800582:	f7 d8                	neg    %eax
  800584:	83 d2 00             	adc    $0x0,%edx
  800587:	f7 da                	neg    %edx
  800589:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800591:	eb 55                	jmp    8005e8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	e8 83 fc ff ff       	call   80021e <getuint>
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005a0:	eb 46                	jmp    8005e8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a5:	e8 74 fc ff ff       	call   80021e <getuint>
		        base = 8;
  8005aa:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005af:	eb 37                	jmp    8005e8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 30                	push   $0x30
  8005b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b9:	83 c4 08             	add    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 78                	push   $0x78
  8005bf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d9:	eb 0d                	jmp    8005e8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 3b fc ff ff       	call   80021e <getuint>
			base = 16;
  8005e3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005ef:	57                   	push   %edi
  8005f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f3:	51                   	push   %ecx
  8005f4:	52                   	push   %edx
  8005f5:	50                   	push   %eax
  8005f6:	89 da                	mov    %ebx,%edx
  8005f8:	89 f0                	mov    %esi,%eax
  8005fa:	e8 70 fb ff ff       	call   80016f <printnum>
			break;
  8005ff:	83 c4 20             	add    $0x20,%esp
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800605:	e9 ae fc ff ff       	jmp    8002b8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	51                   	push   %ecx
  80060f:	ff d6                	call   *%esi
			break;
  800611:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800617:	e9 9c fc ff ff       	jmp    8002b8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 25                	push   $0x25
  800622:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	eb 03                	jmp    80062c <vprintfmt+0x39a>
  800629:	83 ef 01             	sub    $0x1,%edi
  80062c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800630:	75 f7                	jne    800629 <vprintfmt+0x397>
  800632:	e9 81 fc ff ff       	jmp    8002b8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063a:	5b                   	pop    %ebx
  80063b:	5e                   	pop    %esi
  80063c:	5f                   	pop    %edi
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	83 ec 18             	sub    $0x18,%esp
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80064e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800652:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80065c:	85 c0                	test   %eax,%eax
  80065e:	74 26                	je     800686 <vsnprintf+0x47>
  800660:	85 d2                	test   %edx,%edx
  800662:	7e 22                	jle    800686 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800664:	ff 75 14             	pushl  0x14(%ebp)
  800667:	ff 75 10             	pushl  0x10(%ebp)
  80066a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	68 58 02 80 00       	push   $0x800258
  800673:	e8 1a fc ff ff       	call   800292 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800678:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80067e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb 05                	jmp    80068b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800686:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800696:	50                   	push   %eax
  800697:	ff 75 10             	pushl  0x10(%ebp)
  80069a:	ff 75 0c             	pushl  0xc(%ebp)
  80069d:	ff 75 08             	pushl  0x8(%ebp)
  8006a0:	e8 9a ff ff ff       	call   80063f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b2:	eb 03                	jmp    8006b7 <strlen+0x10>
		n++;
  8006b4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006bb:	75 f7                	jne    8006b4 <strlen+0xd>
		n++;
	return n;
}
  8006bd:	5d                   	pop    %ebp
  8006be:	c3                   	ret    

008006bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006cd:	eb 03                	jmp    8006d2 <strnlen+0x13>
		n++;
  8006cf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d2:	39 c2                	cmp    %eax,%edx
  8006d4:	74 08                	je     8006de <strnlen+0x1f>
  8006d6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006da:	75 f3                	jne    8006cf <strnlen+0x10>
  8006dc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	53                   	push   %ebx
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ea:	89 c2                	mov    %eax,%edx
  8006ec:	83 c2 01             	add    $0x1,%edx
  8006ef:	83 c1 01             	add    $0x1,%ecx
  8006f2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006f6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006f9:	84 db                	test   %bl,%bl
  8006fb:	75 ef                	jne    8006ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006fd:	5b                   	pop    %ebx
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	53                   	push   %ebx
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800707:	53                   	push   %ebx
  800708:	e8 9a ff ff ff       	call   8006a7 <strlen>
  80070d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800710:	ff 75 0c             	pushl  0xc(%ebp)
  800713:	01 d8                	add    %ebx,%eax
  800715:	50                   	push   %eax
  800716:	e8 c5 ff ff ff       	call   8006e0 <strcpy>
	return dst;
}
  80071b:	89 d8                	mov    %ebx,%eax
  80071d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	56                   	push   %esi
  800726:	53                   	push   %ebx
  800727:	8b 75 08             	mov    0x8(%ebp),%esi
  80072a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072d:	89 f3                	mov    %esi,%ebx
  80072f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800732:	89 f2                	mov    %esi,%edx
  800734:	eb 0f                	jmp    800745 <strncpy+0x23>
		*dst++ = *src;
  800736:	83 c2 01             	add    $0x1,%edx
  800739:	0f b6 01             	movzbl (%ecx),%eax
  80073c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80073f:	80 39 01             	cmpb   $0x1,(%ecx)
  800742:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800745:	39 da                	cmp    %ebx,%edx
  800747:	75 ed                	jne    800736 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800749:	89 f0                	mov    %esi,%eax
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	56                   	push   %esi
  800753:	53                   	push   %ebx
  800754:	8b 75 08             	mov    0x8(%ebp),%esi
  800757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075a:	8b 55 10             	mov    0x10(%ebp),%edx
  80075d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80075f:	85 d2                	test   %edx,%edx
  800761:	74 21                	je     800784 <strlcpy+0x35>
  800763:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800767:	89 f2                	mov    %esi,%edx
  800769:	eb 09                	jmp    800774 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80076b:	83 c2 01             	add    $0x1,%edx
  80076e:	83 c1 01             	add    $0x1,%ecx
  800771:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800774:	39 c2                	cmp    %eax,%edx
  800776:	74 09                	je     800781 <strlcpy+0x32>
  800778:	0f b6 19             	movzbl (%ecx),%ebx
  80077b:	84 db                	test   %bl,%bl
  80077d:	75 ec                	jne    80076b <strlcpy+0x1c>
  80077f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800781:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800784:	29 f0                	sub    %esi,%eax
}
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800793:	eb 06                	jmp    80079b <strcmp+0x11>
		p++, q++;
  800795:	83 c1 01             	add    $0x1,%ecx
  800798:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80079b:	0f b6 01             	movzbl (%ecx),%eax
  80079e:	84 c0                	test   %al,%al
  8007a0:	74 04                	je     8007a6 <strcmp+0x1c>
  8007a2:	3a 02                	cmp    (%edx),%al
  8007a4:	74 ef                	je     800795 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a6:	0f b6 c0             	movzbl %al,%eax
  8007a9:	0f b6 12             	movzbl (%edx),%edx
  8007ac:	29 d0                	sub    %edx,%eax
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	89 c3                	mov    %eax,%ebx
  8007bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007bf:	eb 06                	jmp    8007c7 <strncmp+0x17>
		n--, p++, q++;
  8007c1:	83 c0 01             	add    $0x1,%eax
  8007c4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007c7:	39 d8                	cmp    %ebx,%eax
  8007c9:	74 15                	je     8007e0 <strncmp+0x30>
  8007cb:	0f b6 08             	movzbl (%eax),%ecx
  8007ce:	84 c9                	test   %cl,%cl
  8007d0:	74 04                	je     8007d6 <strncmp+0x26>
  8007d2:	3a 0a                	cmp    (%edx),%cl
  8007d4:	74 eb                	je     8007c1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d6:	0f b6 00             	movzbl (%eax),%eax
  8007d9:	0f b6 12             	movzbl (%edx),%edx
  8007dc:	29 d0                	sub    %edx,%eax
  8007de:	eb 05                	jmp    8007e5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007e5:	5b                   	pop    %ebx
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f2:	eb 07                	jmp    8007fb <strchr+0x13>
		if (*s == c)
  8007f4:	38 ca                	cmp    %cl,%dl
  8007f6:	74 0f                	je     800807 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	0f b6 10             	movzbl (%eax),%edx
  8007fe:	84 d2                	test   %dl,%dl
  800800:	75 f2                	jne    8007f4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800813:	eb 03                	jmp    800818 <strfind+0xf>
  800815:	83 c0 01             	add    $0x1,%eax
  800818:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80081b:	38 ca                	cmp    %cl,%dl
  80081d:	74 04                	je     800823 <strfind+0x1a>
  80081f:	84 d2                	test   %dl,%dl
  800821:	75 f2                	jne    800815 <strfind+0xc>
			break;
	return (char *) s;
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	57                   	push   %edi
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800831:	85 c9                	test   %ecx,%ecx
  800833:	74 36                	je     80086b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800835:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80083b:	75 28                	jne    800865 <memset+0x40>
  80083d:	f6 c1 03             	test   $0x3,%cl
  800840:	75 23                	jne    800865 <memset+0x40>
		c &= 0xFF;
  800842:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800846:	89 d3                	mov    %edx,%ebx
  800848:	c1 e3 08             	shl    $0x8,%ebx
  80084b:	89 d6                	mov    %edx,%esi
  80084d:	c1 e6 18             	shl    $0x18,%esi
  800850:	89 d0                	mov    %edx,%eax
  800852:	c1 e0 10             	shl    $0x10,%eax
  800855:	09 f0                	or     %esi,%eax
  800857:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800859:	89 d8                	mov    %ebx,%eax
  80085b:	09 d0                	or     %edx,%eax
  80085d:	c1 e9 02             	shr    $0x2,%ecx
  800860:	fc                   	cld    
  800861:	f3 ab                	rep stos %eax,%es:(%edi)
  800863:	eb 06                	jmp    80086b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800865:	8b 45 0c             	mov    0xc(%ebp),%eax
  800868:	fc                   	cld    
  800869:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80087d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800880:	39 c6                	cmp    %eax,%esi
  800882:	73 35                	jae    8008b9 <memmove+0x47>
  800884:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800887:	39 d0                	cmp    %edx,%eax
  800889:	73 2e                	jae    8008b9 <memmove+0x47>
		s += n;
		d += n;
  80088b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088e:	89 d6                	mov    %edx,%esi
  800890:	09 fe                	or     %edi,%esi
  800892:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800898:	75 13                	jne    8008ad <memmove+0x3b>
  80089a:	f6 c1 03             	test   $0x3,%cl
  80089d:	75 0e                	jne    8008ad <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80089f:	83 ef 04             	sub    $0x4,%edi
  8008a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008a5:	c1 e9 02             	shr    $0x2,%ecx
  8008a8:	fd                   	std    
  8008a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ab:	eb 09                	jmp    8008b6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ad:	83 ef 01             	sub    $0x1,%edi
  8008b0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b3:	fd                   	std    
  8008b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b6:	fc                   	cld    
  8008b7:	eb 1d                	jmp    8008d6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b9:	89 f2                	mov    %esi,%edx
  8008bb:	09 c2                	or     %eax,%edx
  8008bd:	f6 c2 03             	test   $0x3,%dl
  8008c0:	75 0f                	jne    8008d1 <memmove+0x5f>
  8008c2:	f6 c1 03             	test   $0x3,%cl
  8008c5:	75 0a                	jne    8008d1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008c7:	c1 e9 02             	shr    $0x2,%ecx
  8008ca:	89 c7                	mov    %eax,%edi
  8008cc:	fc                   	cld    
  8008cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cf:	eb 05                	jmp    8008d6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d1:	89 c7                	mov    %eax,%edi
  8008d3:	fc                   	cld    
  8008d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d6:	5e                   	pop    %esi
  8008d7:	5f                   	pop    %edi
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008dd:	ff 75 10             	pushl  0x10(%ebp)
  8008e0:	ff 75 0c             	pushl  0xc(%ebp)
  8008e3:	ff 75 08             	pushl  0x8(%ebp)
  8008e6:	e8 87 ff ff ff       	call   800872 <memmove>
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	89 c6                	mov    %eax,%esi
  8008fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008fd:	eb 1a                	jmp    800919 <memcmp+0x2c>
		if (*s1 != *s2)
  8008ff:	0f b6 08             	movzbl (%eax),%ecx
  800902:	0f b6 1a             	movzbl (%edx),%ebx
  800905:	38 d9                	cmp    %bl,%cl
  800907:	74 0a                	je     800913 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800909:	0f b6 c1             	movzbl %cl,%eax
  80090c:	0f b6 db             	movzbl %bl,%ebx
  80090f:	29 d8                	sub    %ebx,%eax
  800911:	eb 0f                	jmp    800922 <memcmp+0x35>
		s1++, s2++;
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800919:	39 f0                	cmp    %esi,%eax
  80091b:	75 e2                	jne    8008ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80092d:	89 c1                	mov    %eax,%ecx
  80092f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800932:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800936:	eb 0a                	jmp    800942 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800938:	0f b6 10             	movzbl (%eax),%edx
  80093b:	39 da                	cmp    %ebx,%edx
  80093d:	74 07                	je     800946 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	39 c8                	cmp    %ecx,%eax
  800944:	72 f2                	jb     800938 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800946:	5b                   	pop    %ebx
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800955:	eb 03                	jmp    80095a <strtol+0x11>
		s++;
  800957:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095a:	0f b6 01             	movzbl (%ecx),%eax
  80095d:	3c 20                	cmp    $0x20,%al
  80095f:	74 f6                	je     800957 <strtol+0xe>
  800961:	3c 09                	cmp    $0x9,%al
  800963:	74 f2                	je     800957 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800965:	3c 2b                	cmp    $0x2b,%al
  800967:	75 0a                	jne    800973 <strtol+0x2a>
		s++;
  800969:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80096c:	bf 00 00 00 00       	mov    $0x0,%edi
  800971:	eb 11                	jmp    800984 <strtol+0x3b>
  800973:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800978:	3c 2d                	cmp    $0x2d,%al
  80097a:	75 08                	jne    800984 <strtol+0x3b>
		s++, neg = 1;
  80097c:	83 c1 01             	add    $0x1,%ecx
  80097f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800984:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80098a:	75 15                	jne    8009a1 <strtol+0x58>
  80098c:	80 39 30             	cmpb   $0x30,(%ecx)
  80098f:	75 10                	jne    8009a1 <strtol+0x58>
  800991:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800995:	75 7c                	jne    800a13 <strtol+0xca>
		s += 2, base = 16;
  800997:	83 c1 02             	add    $0x2,%ecx
  80099a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80099f:	eb 16                	jmp    8009b7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a1:	85 db                	test   %ebx,%ebx
  8009a3:	75 12                	jne    8009b7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009a5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009aa:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ad:	75 08                	jne    8009b7 <strtol+0x6e>
		s++, base = 8;
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009bf:	0f b6 11             	movzbl (%ecx),%edx
  8009c2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009c5:	89 f3                	mov    %esi,%ebx
  8009c7:	80 fb 09             	cmp    $0x9,%bl
  8009ca:	77 08                	ja     8009d4 <strtol+0x8b>
			dig = *s - '0';
  8009cc:	0f be d2             	movsbl %dl,%edx
  8009cf:	83 ea 30             	sub    $0x30,%edx
  8009d2:	eb 22                	jmp    8009f6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009d4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d7:	89 f3                	mov    %esi,%ebx
  8009d9:	80 fb 19             	cmp    $0x19,%bl
  8009dc:	77 08                	ja     8009e6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009de:	0f be d2             	movsbl %dl,%edx
  8009e1:	83 ea 57             	sub    $0x57,%edx
  8009e4:	eb 10                	jmp    8009f6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009e6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009e9:	89 f3                	mov    %esi,%ebx
  8009eb:	80 fb 19             	cmp    $0x19,%bl
  8009ee:	77 16                	ja     800a06 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f0:	0f be d2             	movsbl %dl,%edx
  8009f3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009f6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f9:	7d 0b                	jge    800a06 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a02:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a04:	eb b9                	jmp    8009bf <strtol+0x76>

	if (endptr)
  800a06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0a:	74 0d                	je     800a19 <strtol+0xd0>
		*endptr = (char *) s;
  800a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0f:	89 0e                	mov    %ecx,(%esi)
  800a11:	eb 06                	jmp    800a19 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a13:	85 db                	test   %ebx,%ebx
  800a15:	74 98                	je     8009af <strtol+0x66>
  800a17:	eb 9e                	jmp    8009b7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a19:	89 c2                	mov    %eax,%edx
  800a1b:	f7 da                	neg    %edx
  800a1d:	85 ff                	test   %edi,%edi
  800a1f:	0f 45 c2             	cmovne %edx,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	8b 55 08             	mov    0x8(%ebp),%edx
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	89 c7                	mov    %eax,%edi
  800a3c:	89 c6                	mov    %eax,%esi
  800a3e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a50:	b8 01 00 00 00       	mov    $0x1,%eax
  800a55:	89 d1                	mov    %edx,%ecx
  800a57:	89 d3                	mov    %edx,%ebx
  800a59:	89 d7                	mov    %edx,%edi
  800a5b:	89 d6                	mov    %edx,%esi
  800a5d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a72:	b8 03 00 00 00       	mov    $0x3,%eax
  800a77:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7a:	89 cb                	mov    %ecx,%ebx
  800a7c:	89 cf                	mov    %ecx,%edi
  800a7e:	89 ce                	mov    %ecx,%esi
  800a80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a82:	85 c0                	test   %eax,%eax
  800a84:	7e 17                	jle    800a9d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a86:	83 ec 0c             	sub    $0xc,%esp
  800a89:	50                   	push   %eax
  800a8a:	6a 03                	push   $0x3
  800a8c:	68 bf 25 80 00       	push   $0x8025bf
  800a91:	6a 23                	push   $0x23
  800a93:	68 dc 25 80 00       	push   $0x8025dc
  800a98:	e8 cc 13 00 00       	call   801e69 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab5:	89 d1                	mov    %edx,%ecx
  800ab7:	89 d3                	mov    %edx,%ebx
  800ab9:	89 d7                	mov    %edx,%edi
  800abb:	89 d6                	mov    %edx,%esi
  800abd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_yield>:

void
sys_yield(void)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	ba 00 00 00 00       	mov    $0x0,%edx
  800acf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad4:	89 d1                	mov    %edx,%ecx
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	89 d7                	mov    %edx,%edi
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	be 00 00 00 00       	mov    $0x0,%esi
  800af1:	b8 04 00 00 00       	mov    $0x4,%eax
  800af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af9:	8b 55 08             	mov    0x8(%ebp),%edx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aff:	89 f7                	mov    %esi,%edi
  800b01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 17                	jle    800b1e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	6a 04                	push   $0x4
  800b0d:	68 bf 25 80 00       	push   $0x8025bf
  800b12:	6a 23                	push   $0x23
  800b14:	68 dc 25 80 00       	push   $0x8025dc
  800b19:	e8 4b 13 00 00       	call   801e69 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b40:	8b 75 18             	mov    0x18(%ebp),%esi
  800b43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 17                	jle    800b60 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	6a 05                	push   $0x5
  800b4f:	68 bf 25 80 00       	push   $0x8025bf
  800b54:	6a 23                	push   $0x23
  800b56:	68 dc 25 80 00       	push   $0x8025dc
  800b5b:	e8 09 13 00 00       	call   801e69 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b76:	b8 06 00 00 00       	mov    $0x6,%eax
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	89 df                	mov    %ebx,%edi
  800b83:	89 de                	mov    %ebx,%esi
  800b85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 06                	push   $0x6
  800b91:	68 bf 25 80 00       	push   $0x8025bf
  800b96:	6a 23                	push   $0x23
  800b98:	68 dc 25 80 00       	push   $0x8025dc
  800b9d:	e8 c7 12 00 00       	call   801e69 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc3:	89 df                	mov    %ebx,%edi
  800bc5:	89 de                	mov    %ebx,%esi
  800bc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 17                	jle    800be4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 08                	push   $0x8
  800bd3:	68 bf 25 80 00       	push   $0x8025bf
  800bd8:	6a 23                	push   $0x23
  800bda:	68 dc 25 80 00       	push   $0x8025dc
  800bdf:	e8 85 12 00 00       	call   801e69 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 df                	mov    %ebx,%edi
  800c07:	89 de                	mov    %ebx,%esi
  800c09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 09                	push   $0x9
  800c15:	68 bf 25 80 00       	push   $0x8025bf
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 dc 25 80 00       	push   $0x8025dc
  800c21:	e8 43 12 00 00       	call   801e69 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	89 de                	mov    %ebx,%esi
  800c4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 0a                	push   $0xa
  800c57:	68 bf 25 80 00       	push   $0x8025bf
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 dc 25 80 00       	push   $0x8025dc
  800c63:	e8 01 12 00 00       	call   801e69 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	be 00 00 00 00       	mov    $0x0,%esi
  800c7b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800c9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 cb                	mov    %ecx,%ebx
  800cab:	89 cf                	mov    %ecx,%edi
  800cad:	89 ce                	mov    %ecx,%esi
  800caf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	7e 17                	jle    800ccc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	6a 0d                	push   $0xd
  800cbb:	68 bf 25 80 00       	push   $0x8025bf
  800cc0:	6a 23                	push   $0x23
  800cc2:	68 dc 25 80 00       	push   $0x8025dc
  800cc7:	e8 9d 11 00 00       	call   801e69 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce4:	89 d1                	mov    %edx,%ecx
  800ce6:	89 d3                	mov    %edx,%ebx
  800ce8:	89 d7                	mov    %edx,%edi
  800cea:	89 d6                	mov    %edx,%esi
  800cec:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d34:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d41:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d46:	89 c2                	mov    %eax,%edx
  800d48:	c1 ea 16             	shr    $0x16,%edx
  800d4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d52:	f6 c2 01             	test   $0x1,%dl
  800d55:	74 11                	je     800d68 <fd_alloc+0x2d>
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	c1 ea 0c             	shr    $0xc,%edx
  800d5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d63:	f6 c2 01             	test   $0x1,%dl
  800d66:	75 09                	jne    800d71 <fd_alloc+0x36>
			*fd_store = fd;
  800d68:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	eb 17                	jmp    800d88 <fd_alloc+0x4d>
  800d71:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d76:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d7b:	75 c9                	jne    800d46 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d7d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d83:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d90:	83 f8 1f             	cmp    $0x1f,%eax
  800d93:	77 36                	ja     800dcb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d95:	c1 e0 0c             	shl    $0xc,%eax
  800d98:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	c1 ea 16             	shr    $0x16,%edx
  800da2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da9:	f6 c2 01             	test   $0x1,%dl
  800dac:	74 24                	je     800dd2 <fd_lookup+0x48>
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 0c             	shr    $0xc,%edx
  800db3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 1a                	je     800dd9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc2:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc9:	eb 13                	jmp    800dde <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd0:	eb 0c                	jmp    800dde <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd7:	eb 05                	jmp    800dde <fd_lookup+0x54>
  800dd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 08             	sub    $0x8,%esp
  800de6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de9:	ba 68 26 80 00       	mov    $0x802668,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dee:	eb 13                	jmp    800e03 <dev_lookup+0x23>
  800df0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800df3:	39 08                	cmp    %ecx,(%eax)
  800df5:	75 0c                	jne    800e03 <dev_lookup+0x23>
			*dev = devtab[i];
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	eb 2e                	jmp    800e31 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e03:	8b 02                	mov    (%edx),%eax
  800e05:	85 c0                	test   %eax,%eax
  800e07:	75 e7                	jne    800df0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e09:	a1 08 40 80 00       	mov    0x804008,%eax
  800e0e:	8b 40 48             	mov    0x48(%eax),%eax
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	51                   	push   %ecx
  800e15:	50                   	push   %eax
  800e16:	68 ec 25 80 00       	push   $0x8025ec
  800e1b:	e8 3b f3 ff ff       	call   80015b <cprintf>
	*dev = 0;
  800e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    

00800e33 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 10             	sub    $0x10,%esp
  800e3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e44:	50                   	push   %eax
  800e45:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e4b:	c1 e8 0c             	shr    $0xc,%eax
  800e4e:	50                   	push   %eax
  800e4f:	e8 36 ff ff ff       	call   800d8a <fd_lookup>
  800e54:	83 c4 08             	add    $0x8,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	78 05                	js     800e60 <fd_close+0x2d>
	    || fd != fd2)
  800e5b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e5e:	74 0c                	je     800e6c <fd_close+0x39>
		return (must_exist ? r : 0);
  800e60:	84 db                	test   %bl,%bl
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	0f 44 c2             	cmove  %edx,%eax
  800e6a:	eb 41                	jmp    800ead <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e72:	50                   	push   %eax
  800e73:	ff 36                	pushl  (%esi)
  800e75:	e8 66 ff ff ff       	call   800de0 <dev_lookup>
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 1a                	js     800e9d <fd_close+0x6a>
		if (dev->dev_close)
  800e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e86:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e89:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	74 0b                	je     800e9d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	56                   	push   %esi
  800e96:	ff d0                	call   *%eax
  800e98:	89 c3                	mov    %eax,%ebx
  800e9a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	56                   	push   %esi
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 c0 fc ff ff       	call   800b68 <sys_page_unmap>
	return r;
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	89 d8                	mov    %ebx,%eax
}
  800ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebd:	50                   	push   %eax
  800ebe:	ff 75 08             	pushl  0x8(%ebp)
  800ec1:	e8 c4 fe ff ff       	call   800d8a <fd_lookup>
  800ec6:	83 c4 08             	add    $0x8,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 10                	js     800edd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	6a 01                	push   $0x1
  800ed2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed5:	e8 59 ff ff ff       	call   800e33 <fd_close>
  800eda:	83 c4 10             	add    $0x10,%esp
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <close_all>:

void
close_all(void)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	53                   	push   %ebx
  800eef:	e8 c0 ff ff ff       	call   800eb4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef4:	83 c3 01             	add    $0x1,%ebx
  800ef7:	83 c4 10             	add    $0x10,%esp
  800efa:	83 fb 20             	cmp    $0x20,%ebx
  800efd:	75 ec                	jne    800eeb <close_all+0xc>
		close(i);
}
  800eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 2c             	sub    $0x2c,%esp
  800f0d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f13:	50                   	push   %eax
  800f14:	ff 75 08             	pushl  0x8(%ebp)
  800f17:	e8 6e fe ff ff       	call   800d8a <fd_lookup>
  800f1c:	83 c4 08             	add    $0x8,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	0f 88 c1 00 00 00    	js     800fe8 <dup+0xe4>
		return r;
	close(newfdnum);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	56                   	push   %esi
  800f2b:	e8 84 ff ff ff       	call   800eb4 <close>

	newfd = INDEX2FD(newfdnum);
  800f30:	89 f3                	mov    %esi,%ebx
  800f32:	c1 e3 0c             	shl    $0xc,%ebx
  800f35:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f3b:	83 c4 04             	add    $0x4,%esp
  800f3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f41:	e8 de fd ff ff       	call   800d24 <fd2data>
  800f46:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f48:	89 1c 24             	mov    %ebx,(%esp)
  800f4b:	e8 d4 fd ff ff       	call   800d24 <fd2data>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f56:	89 f8                	mov    %edi,%eax
  800f58:	c1 e8 16             	shr    $0x16,%eax
  800f5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f62:	a8 01                	test   $0x1,%al
  800f64:	74 37                	je     800f9d <dup+0x99>
  800f66:	89 f8                	mov    %edi,%eax
  800f68:	c1 e8 0c             	shr    $0xc,%eax
  800f6b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f72:	f6 c2 01             	test   $0x1,%dl
  800f75:	74 26                	je     800f9d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f77:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	25 07 0e 00 00       	and    $0xe07,%eax
  800f86:	50                   	push   %eax
  800f87:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f8a:	6a 00                	push   $0x0
  800f8c:	57                   	push   %edi
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 92 fb ff ff       	call   800b26 <sys_page_map>
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 2e                	js     800fcb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fa0:	89 d0                	mov    %edx,%eax
  800fa2:	c1 e8 0c             	shr    $0xc,%eax
  800fa5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb4:	50                   	push   %eax
  800fb5:	53                   	push   %ebx
  800fb6:	6a 00                	push   $0x0
  800fb8:	52                   	push   %edx
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 66 fb ff ff       	call   800b26 <sys_page_map>
  800fc0:	89 c7                	mov    %eax,%edi
  800fc2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc7:	85 ff                	test   %edi,%edi
  800fc9:	79 1d                	jns    800fe8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fcb:	83 ec 08             	sub    $0x8,%esp
  800fce:	53                   	push   %ebx
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 92 fb ff ff       	call   800b68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd6:	83 c4 08             	add    $0x8,%esp
  800fd9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 85 fb ff ff       	call   800b68 <sys_page_unmap>
	return r;
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	89 f8                	mov    %edi,%eax
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 14             	sub    $0x14,%esp
  800ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ffa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffd:	50                   	push   %eax
  800ffe:	53                   	push   %ebx
  800fff:	e8 86 fd ff ff       	call   800d8a <fd_lookup>
  801004:	83 c4 08             	add    $0x8,%esp
  801007:	89 c2                	mov    %eax,%edx
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 6d                	js     80107a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100d:	83 ec 08             	sub    $0x8,%esp
  801010:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801013:	50                   	push   %eax
  801014:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801017:	ff 30                	pushl  (%eax)
  801019:	e8 c2 fd ff ff       	call   800de0 <dev_lookup>
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 4c                	js     801071 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801025:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801028:	8b 42 08             	mov    0x8(%edx),%eax
  80102b:	83 e0 03             	and    $0x3,%eax
  80102e:	83 f8 01             	cmp    $0x1,%eax
  801031:	75 21                	jne    801054 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801033:	a1 08 40 80 00       	mov    0x804008,%eax
  801038:	8b 40 48             	mov    0x48(%eax),%eax
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	53                   	push   %ebx
  80103f:	50                   	push   %eax
  801040:	68 2d 26 80 00       	push   $0x80262d
  801045:	e8 11 f1 ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801052:	eb 26                	jmp    80107a <read+0x8a>
	}
	if (!dev->dev_read)
  801054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801057:	8b 40 08             	mov    0x8(%eax),%eax
  80105a:	85 c0                	test   %eax,%eax
  80105c:	74 17                	je     801075 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80105e:	83 ec 04             	sub    $0x4,%esp
  801061:	ff 75 10             	pushl  0x10(%ebp)
  801064:	ff 75 0c             	pushl  0xc(%ebp)
  801067:	52                   	push   %edx
  801068:	ff d0                	call   *%eax
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	eb 09                	jmp    80107a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801071:	89 c2                	mov    %eax,%edx
  801073:	eb 05                	jmp    80107a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801075:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801090:	bb 00 00 00 00       	mov    $0x0,%ebx
  801095:	eb 21                	jmp    8010b8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	89 f0                	mov    %esi,%eax
  80109c:	29 d8                	sub    %ebx,%eax
  80109e:	50                   	push   %eax
  80109f:	89 d8                	mov    %ebx,%eax
  8010a1:	03 45 0c             	add    0xc(%ebp),%eax
  8010a4:	50                   	push   %eax
  8010a5:	57                   	push   %edi
  8010a6:	e8 45 ff ff ff       	call   800ff0 <read>
		if (m < 0)
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 10                	js     8010c2 <readn+0x41>
			return m;
		if (m == 0)
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	74 0a                	je     8010c0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b6:	01 c3                	add    %eax,%ebx
  8010b8:	39 f3                	cmp    %esi,%ebx
  8010ba:	72 db                	jb     801097 <readn+0x16>
  8010bc:	89 d8                	mov    %ebx,%eax
  8010be:	eb 02                	jmp    8010c2 <readn+0x41>
  8010c0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 14             	sub    $0x14,%esp
  8010d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	53                   	push   %ebx
  8010d9:	e8 ac fc ff ff       	call   800d8a <fd_lookup>
  8010de:	83 c4 08             	add    $0x8,%esp
  8010e1:	89 c2                	mov    %eax,%edx
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 68                	js     80114f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f1:	ff 30                	pushl  (%eax)
  8010f3:	e8 e8 fc ff ff       	call   800de0 <dev_lookup>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 47                	js     801146 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801106:	75 21                	jne    801129 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801108:	a1 08 40 80 00       	mov    0x804008,%eax
  80110d:	8b 40 48             	mov    0x48(%eax),%eax
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	53                   	push   %ebx
  801114:	50                   	push   %eax
  801115:	68 49 26 80 00       	push   $0x802649
  80111a:	e8 3c f0 ff ff       	call   80015b <cprintf>
		return -E_INVAL;
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801127:	eb 26                	jmp    80114f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801129:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112c:	8b 52 0c             	mov    0xc(%edx),%edx
  80112f:	85 d2                	test   %edx,%edx
  801131:	74 17                	je     80114a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	ff 75 10             	pushl  0x10(%ebp)
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	50                   	push   %eax
  80113d:	ff d2                	call   *%edx
  80113f:	89 c2                	mov    %eax,%edx
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	eb 09                	jmp    80114f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801146:	89 c2                	mov    %eax,%edx
  801148:	eb 05                	jmp    80114f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80114a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80114f:	89 d0                	mov    %edx,%eax
  801151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <seek>:

int
seek(int fdnum, off_t offset)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	e8 22 fc ff ff       	call   800d8a <fd_lookup>
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 0e                	js     80117d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80116f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801172:	8b 55 0c             	mov    0xc(%ebp),%edx
  801175:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	53                   	push   %ebx
  801183:	83 ec 14             	sub    $0x14,%esp
  801186:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801189:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	53                   	push   %ebx
  80118e:	e8 f7 fb ff ff       	call   800d8a <fd_lookup>
  801193:	83 c4 08             	add    $0x8,%esp
  801196:	89 c2                	mov    %eax,%edx
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 65                	js     801201 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a6:	ff 30                	pushl  (%eax)
  8011a8:	e8 33 fc ff ff       	call   800de0 <dev_lookup>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 44                	js     8011f8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bb:	75 21                	jne    8011de <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011bd:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011c2:	8b 40 48             	mov    0x48(%eax),%eax
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	53                   	push   %ebx
  8011c9:	50                   	push   %eax
  8011ca:	68 0c 26 80 00       	push   $0x80260c
  8011cf:	e8 87 ef ff ff       	call   80015b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011dc:	eb 23                	jmp    801201 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e1:	8b 52 18             	mov    0x18(%edx),%edx
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	74 14                	je     8011fc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ee:	50                   	push   %eax
  8011ef:	ff d2                	call   *%edx
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	eb 09                	jmp    801201 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	eb 05                	jmp    801201 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801201:	89 d0                	mov    %edx,%eax
  801203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	53                   	push   %ebx
  80120c:	83 ec 14             	sub    $0x14,%esp
  80120f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801212:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 75 08             	pushl  0x8(%ebp)
  801219:	e8 6c fb ff ff       	call   800d8a <fd_lookup>
  80121e:	83 c4 08             	add    $0x8,%esp
  801221:	89 c2                	mov    %eax,%edx
  801223:	85 c0                	test   %eax,%eax
  801225:	78 58                	js     80127f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801231:	ff 30                	pushl  (%eax)
  801233:	e8 a8 fb ff ff       	call   800de0 <dev_lookup>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 37                	js     801276 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801246:	74 32                	je     80127a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801248:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80124b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801252:	00 00 00 
	stat->st_isdir = 0;
  801255:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80125c:	00 00 00 
	stat->st_dev = dev;
  80125f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	53                   	push   %ebx
  801269:	ff 75 f0             	pushl  -0x10(%ebp)
  80126c:	ff 50 14             	call   *0x14(%eax)
  80126f:	89 c2                	mov    %eax,%edx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	eb 09                	jmp    80127f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801276:	89 c2                	mov    %eax,%edx
  801278:	eb 05                	jmp    80127f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80127a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80127f:	89 d0                	mov    %edx,%eax
  801281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801284:	c9                   	leave  
  801285:	c3                   	ret    

00801286 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	56                   	push   %esi
  80128a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	6a 00                	push   $0x0
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 e7 01 00 00       	call   80147f <open>
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 1b                	js     8012bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	e8 5b ff ff ff       	call   801208 <fstat>
  8012ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8012af:	89 1c 24             	mov    %ebx,(%esp)
  8012b2:	e8 fd fb ff ff       	call   800eb4 <close>
	return r;
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	89 f0                	mov    %esi,%eax
}
  8012bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	89 c6                	mov    %eax,%esi
  8012ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d3:	75 12                	jne    8012e7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	6a 01                	push   $0x1
  8012da:	e8 91 0c 00 00       	call   801f70 <ipc_find_env>
  8012df:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e7:	6a 07                	push   $0x7
  8012e9:	68 00 50 80 00       	push   $0x805000
  8012ee:	56                   	push   %esi
  8012ef:	ff 35 00 40 80 00    	pushl  0x804000
  8012f5:	e8 22 0c 00 00       	call   801f1c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012fa:	83 c4 0c             	add    $0xc,%esp
  8012fd:	6a 00                	push   $0x0
  8012ff:	53                   	push   %ebx
  801300:	6a 00                	push   $0x0
  801302:	e8 a8 0b 00 00       	call   801eaf <ipc_recv>
}
  801307:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	8b 40 0c             	mov    0xc(%eax),%eax
  80131a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80131f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801322:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801327:	ba 00 00 00 00       	mov    $0x0,%edx
  80132c:	b8 02 00 00 00       	mov    $0x2,%eax
  801331:	e8 8d ff ff ff       	call   8012c3 <fsipc>
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	8b 40 0c             	mov    0xc(%eax),%eax
  801344:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801349:	ba 00 00 00 00       	mov    $0x0,%edx
  80134e:	b8 06 00 00 00       	mov    $0x6,%eax
  801353:	e8 6b ff ff ff       	call   8012c3 <fsipc>
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	8b 40 0c             	mov    0xc(%eax),%eax
  80136a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	b8 05 00 00 00       	mov    $0x5,%eax
  801379:	e8 45 ff ff ff       	call   8012c3 <fsipc>
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 2c                	js     8013ae <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	68 00 50 80 00       	push   $0x805000
  80138a:	53                   	push   %ebx
  80138b:	e8 50 f3 ff ff       	call   8006e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801390:	a1 80 50 80 00       	mov    0x805080,%eax
  801395:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80139b:	a1 84 50 80 00       	mov    0x805084,%eax
  8013a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8013bd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013c2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8013c7:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013ca:	53                   	push   %ebx
  8013cb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ce:	68 08 50 80 00       	push   $0x805008
  8013d3:	e8 9a f4 ff ff       	call   800872 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 40 0c             	mov    0xc(%eax),%eax
  8013de:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8013e3:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8013e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f3:	e8 cb fe ff ff       	call   8012c3 <fsipc>
	//panic("devfile_write not implemented");
}
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801410:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801416:	ba 00 00 00 00       	mov    $0x0,%edx
  80141b:	b8 03 00 00 00       	mov    $0x3,%eax
  801420:	e8 9e fe ff ff       	call   8012c3 <fsipc>
  801425:	89 c3                	mov    %eax,%ebx
  801427:	85 c0                	test   %eax,%eax
  801429:	78 4b                	js     801476 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80142b:	39 c6                	cmp    %eax,%esi
  80142d:	73 16                	jae    801445 <devfile_read+0x48>
  80142f:	68 7c 26 80 00       	push   $0x80267c
  801434:	68 83 26 80 00       	push   $0x802683
  801439:	6a 7c                	push   $0x7c
  80143b:	68 98 26 80 00       	push   $0x802698
  801440:	e8 24 0a 00 00       	call   801e69 <_panic>
	assert(r <= PGSIZE);
  801445:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80144a:	7e 16                	jle    801462 <devfile_read+0x65>
  80144c:	68 a3 26 80 00       	push   $0x8026a3
  801451:	68 83 26 80 00       	push   $0x802683
  801456:	6a 7d                	push   $0x7d
  801458:	68 98 26 80 00       	push   $0x802698
  80145d:	e8 07 0a 00 00       	call   801e69 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801462:	83 ec 04             	sub    $0x4,%esp
  801465:	50                   	push   %eax
  801466:	68 00 50 80 00       	push   $0x805000
  80146b:	ff 75 0c             	pushl  0xc(%ebp)
  80146e:	e8 ff f3 ff ff       	call   800872 <memmove>
	return r;
  801473:	83 c4 10             	add    $0x10,%esp
}
  801476:	89 d8                	mov    %ebx,%eax
  801478:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    

0080147f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	53                   	push   %ebx
  801483:	83 ec 20             	sub    $0x20,%esp
  801486:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801489:	53                   	push   %ebx
  80148a:	e8 18 f2 ff ff       	call   8006a7 <strlen>
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801497:	7f 67                	jg     801500 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	e8 96 f8 ff ff       	call   800d3b <fd_alloc>
  8014a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 57                	js     801505 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	68 00 50 80 00       	push   $0x805000
  8014b7:	e8 24 f2 ff ff       	call   8006e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cc:	e8 f2 fd ff ff       	call   8012c3 <fsipc>
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	79 14                	jns    8014ee <open+0x6f>
		fd_close(fd, 0);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	6a 00                	push   $0x0
  8014df:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e2:	e8 4c f9 ff ff       	call   800e33 <fd_close>
		return r;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	89 da                	mov    %ebx,%edx
  8014ec:	eb 17                	jmp    801505 <open+0x86>
	}

	return fd2num(fd);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f4:	e8 1b f8 ff ff       	call   800d14 <fd2num>
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	eb 05                	jmp    801505 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801500:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801505:	89 d0                	mov    %edx,%eax
  801507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	b8 08 00 00 00       	mov    $0x8,%eax
  80151c:	e8 a2 fd ff ff       	call   8012c3 <fsipc>
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801529:	68 af 26 80 00       	push   $0x8026af
  80152e:	ff 75 0c             	pushl  0xc(%ebp)
  801531:	e8 aa f1 ff ff       	call   8006e0 <strcpy>
	return 0;
}
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 10             	sub    $0x10,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801547:	53                   	push   %ebx
  801548:	e8 5c 0a 00 00       	call   801fa9 <pageref>
  80154d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801555:	83 f8 01             	cmp    $0x1,%eax
  801558:	75 10                	jne    80156a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	ff 73 0c             	pushl  0xc(%ebx)
  801560:	e8 c0 02 00 00       	call   801825 <nsipc_close>
  801565:	89 c2                	mov    %eax,%edx
  801567:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80156a:	89 d0                	mov    %edx,%eax
  80156c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801577:	6a 00                	push   $0x0
  801579:	ff 75 10             	pushl  0x10(%ebp)
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	8b 45 08             	mov    0x8(%ebp),%eax
  801582:	ff 70 0c             	pushl  0xc(%eax)
  801585:	e8 78 03 00 00       	call   801902 <nsipc_send>
}
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801592:	6a 00                	push   $0x0
  801594:	ff 75 10             	pushl  0x10(%ebp)
  801597:	ff 75 0c             	pushl  0xc(%ebp)
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	ff 70 0c             	pushl  0xc(%eax)
  8015a0:	e8 f1 02 00 00       	call   801896 <nsipc_recv>
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015ad:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015b0:	52                   	push   %edx
  8015b1:	50                   	push   %eax
  8015b2:	e8 d3 f7 ff ff       	call   800d8a <fd_lookup>
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 17                	js     8015d5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015c7:	39 08                	cmp    %ecx,(%eax)
  8015c9:	75 05                	jne    8015d0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8015cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ce:	eb 05                	jmp    8015d5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8015d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 1c             	sub    $0x1c,%esp
  8015df:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	e8 51 f7 ff ff       	call   800d3b <fd_alloc>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 1b                	js     80160e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	68 07 04 00 00       	push   $0x407
  8015fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fe:	6a 00                	push   $0x0
  801600:	e8 de f4 ff ff       	call   800ae3 <sys_page_alloc>
  801605:	89 c3                	mov    %eax,%ebx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	79 10                	jns    80161e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	56                   	push   %esi
  801612:	e8 0e 02 00 00       	call   801825 <nsipc_close>
		return r;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	89 d8                	mov    %ebx,%eax
  80161c:	eb 24                	jmp    801642 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80161e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801624:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801627:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801633:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	50                   	push   %eax
  80163a:	e8 d5 f6 ff ff       	call   800d14 <fd2num>
  80163f:	83 c4 10             	add    $0x10,%esp
}
  801642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	e8 50 ff ff ff       	call   8015a7 <fd2sockid>
		return r;
  801657:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 1f                	js     80167c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	50                   	push   %eax
  801667:	e8 12 01 00 00       	call   80177e <nsipc_accept>
  80166c:	83 c4 10             	add    $0x10,%esp
		return r;
  80166f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801671:	85 c0                	test   %eax,%eax
  801673:	78 07                	js     80167c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801675:	e8 5d ff ff ff       	call   8015d7 <alloc_sockfd>
  80167a:	89 c1                	mov    %eax,%ecx
}
  80167c:	89 c8                	mov    %ecx,%eax
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	e8 19 ff ff ff       	call   8015a7 <fd2sockid>
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 12                	js     8016a4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	ff 75 10             	pushl  0x10(%ebp)
  801698:	ff 75 0c             	pushl  0xc(%ebp)
  80169b:	50                   	push   %eax
  80169c:	e8 2d 01 00 00       	call   8017ce <nsipc_bind>
  8016a1:	83 c4 10             	add    $0x10,%esp
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <shutdown>:

int
shutdown(int s, int how)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8016af:	e8 f3 fe ff ff       	call   8015a7 <fd2sockid>
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 0f                	js     8016c7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	ff 75 0c             	pushl  0xc(%ebp)
  8016be:	50                   	push   %eax
  8016bf:	e8 3f 01 00 00       	call   801803 <nsipc_shutdown>
  8016c4:	83 c4 10             	add    $0x10,%esp
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d2:	e8 d0 fe ff ff       	call   8015a7 <fd2sockid>
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 12                	js     8016ed <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	ff 75 10             	pushl  0x10(%ebp)
  8016e1:	ff 75 0c             	pushl  0xc(%ebp)
  8016e4:	50                   	push   %eax
  8016e5:	e8 55 01 00 00       	call   80183f <nsipc_connect>
  8016ea:	83 c4 10             	add    $0x10,%esp
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <listen>:

int
listen(int s, int backlog)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f8:	e8 aa fe ff ff       	call   8015a7 <fd2sockid>
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 0f                	js     801710 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	50                   	push   %eax
  801708:	e8 67 01 00 00       	call   801874 <nsipc_listen>
  80170d:	83 c4 10             	add    $0x10,%esp
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801718:	ff 75 10             	pushl  0x10(%ebp)
  80171b:	ff 75 0c             	pushl  0xc(%ebp)
  80171e:	ff 75 08             	pushl  0x8(%ebp)
  801721:	e8 3a 02 00 00       	call   801960 <nsipc_socket>
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	85 c0                	test   %eax,%eax
  80172b:	78 05                	js     801732 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80172d:	e8 a5 fe ff ff       	call   8015d7 <alloc_sockfd>
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80173d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801744:	75 12                	jne    801758 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	6a 02                	push   $0x2
  80174b:	e8 20 08 00 00       	call   801f70 <ipc_find_env>
  801750:	a3 04 40 80 00       	mov    %eax,0x804004
  801755:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801758:	6a 07                	push   $0x7
  80175a:	68 00 60 80 00       	push   $0x806000
  80175f:	53                   	push   %ebx
  801760:	ff 35 04 40 80 00    	pushl  0x804004
  801766:	e8 b1 07 00 00       	call   801f1c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80176b:	83 c4 0c             	add    $0xc,%esp
  80176e:	6a 00                	push   $0x0
  801770:	6a 00                	push   $0x0
  801772:	6a 00                	push   $0x0
  801774:	e8 36 07 00 00       	call   801eaf <ipc_recv>
}
  801779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80178e:	8b 06                	mov    (%esi),%eax
  801790:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801795:	b8 01 00 00 00       	mov    $0x1,%eax
  80179a:	e8 95 ff ff ff       	call   801734 <nsipc>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 20                	js     8017c5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017a5:	83 ec 04             	sub    $0x4,%esp
  8017a8:	ff 35 10 60 80 00    	pushl  0x806010
  8017ae:	68 00 60 80 00       	push   $0x806000
  8017b3:	ff 75 0c             	pushl  0xc(%ebp)
  8017b6:	e8 b7 f0 ff ff       	call   800872 <memmove>
		*addrlen = ret->ret_addrlen;
  8017bb:	a1 10 60 80 00       	mov    0x806010,%eax
  8017c0:	89 06                	mov    %eax,(%esi)
  8017c2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017c5:	89 d8                	mov    %ebx,%eax
  8017c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8017e0:	53                   	push   %ebx
  8017e1:	ff 75 0c             	pushl  0xc(%ebp)
  8017e4:	68 04 60 80 00       	push   $0x806004
  8017e9:	e8 84 f0 ff ff       	call   800872 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8017ee:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8017f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f9:	e8 36 ff ff ff       	call   801734 <nsipc>
}
  8017fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801809:	8b 45 08             	mov    0x8(%ebp),%eax
  80180c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801811:	8b 45 0c             	mov    0xc(%ebp),%eax
  801814:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801819:	b8 03 00 00 00       	mov    $0x3,%eax
  80181e:	e8 11 ff ff ff       	call   801734 <nsipc>
}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <nsipc_close>:

int
nsipc_close(int s)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801833:	b8 04 00 00 00       	mov    $0x4,%eax
  801838:	e8 f7 fe ff ff       	call   801734 <nsipc>
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	53                   	push   %ebx
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801851:	53                   	push   %ebx
  801852:	ff 75 0c             	pushl  0xc(%ebp)
  801855:	68 04 60 80 00       	push   $0x806004
  80185a:	e8 13 f0 ff ff       	call   800872 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80185f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801865:	b8 05 00 00 00       	mov    $0x5,%eax
  80186a:	e8 c5 fe ff ff       	call   801734 <nsipc>
}
  80186f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801882:	8b 45 0c             	mov    0xc(%ebp),%eax
  801885:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80188a:	b8 06 00 00 00       	mov    $0x6,%eax
  80188f:	e8 a0 fe ff ff       	call   801734 <nsipc>
}
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018a6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8018af:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018b4:	b8 07 00 00 00       	mov    $0x7,%eax
  8018b9:	e8 76 fe ff ff       	call   801734 <nsipc>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 35                	js     8018f9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018c4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8018c9:	7f 04                	jg     8018cf <nsipc_recv+0x39>
  8018cb:	39 c6                	cmp    %eax,%esi
  8018cd:	7d 16                	jge    8018e5 <nsipc_recv+0x4f>
  8018cf:	68 bb 26 80 00       	push   $0x8026bb
  8018d4:	68 83 26 80 00       	push   $0x802683
  8018d9:	6a 62                	push   $0x62
  8018db:	68 d0 26 80 00       	push   $0x8026d0
  8018e0:	e8 84 05 00 00       	call   801e69 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8018e5:	83 ec 04             	sub    $0x4,%esp
  8018e8:	50                   	push   %eax
  8018e9:	68 00 60 80 00       	push   $0x806000
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	e8 7c ef ff ff       	call   800872 <memmove>
  8018f6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8018f9:	89 d8                	mov    %ebx,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 04             	sub    $0x4,%esp
  801909:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801914:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80191a:	7e 16                	jle    801932 <nsipc_send+0x30>
  80191c:	68 dc 26 80 00       	push   $0x8026dc
  801921:	68 83 26 80 00       	push   $0x802683
  801926:	6a 6d                	push   $0x6d
  801928:	68 d0 26 80 00       	push   $0x8026d0
  80192d:	e8 37 05 00 00       	call   801e69 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801932:	83 ec 04             	sub    $0x4,%esp
  801935:	53                   	push   %ebx
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	68 0c 60 80 00       	push   $0x80600c
  80193e:	e8 2f ef ff ff       	call   800872 <memmove>
	nsipcbuf.send.req_size = size;
  801943:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801949:	8b 45 14             	mov    0x14(%ebp),%eax
  80194c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801951:	b8 08 00 00 00       	mov    $0x8,%eax
  801956:	e8 d9 fd ff ff       	call   801734 <nsipc>
}
  80195b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80196e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801971:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801976:	8b 45 10             	mov    0x10(%ebp),%eax
  801979:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80197e:	b8 09 00 00 00       	mov    $0x9,%eax
  801983:	e8 ac fd ff ff       	call   801734 <nsipc>
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801992:	83 ec 0c             	sub    $0xc,%esp
  801995:	ff 75 08             	pushl  0x8(%ebp)
  801998:	e8 87 f3 ff ff       	call   800d24 <fd2data>
  80199d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80199f:	83 c4 08             	add    $0x8,%esp
  8019a2:	68 e8 26 80 00       	push   $0x8026e8
  8019a7:	53                   	push   %ebx
  8019a8:	e8 33 ed ff ff       	call   8006e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ad:	8b 46 04             	mov    0x4(%esi),%eax
  8019b0:	2b 06                	sub    (%esi),%eax
  8019b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bf:	00 00 00 
	stat->st_dev = &devpipe;
  8019c2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019c9:	30 80 00 
	return 0;
}
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	53                   	push   %ebx
  8019dc:	83 ec 0c             	sub    $0xc,%esp
  8019df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e2:	53                   	push   %ebx
  8019e3:	6a 00                	push   $0x0
  8019e5:	e8 7e f1 ff ff       	call   800b68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ea:	89 1c 24             	mov    %ebx,(%esp)
  8019ed:	e8 32 f3 ff ff       	call   800d24 <fd2data>
  8019f2:	83 c4 08             	add    $0x8,%esp
  8019f5:	50                   	push   %eax
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 6b f1 ff ff       	call   800b68 <sys_page_unmap>
}
  8019fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	57                   	push   %edi
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	83 ec 1c             	sub    $0x1c,%esp
  801a0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a10:	a1 08 40 80 00       	mov    0x804008,%eax
  801a15:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1e:	e8 86 05 00 00       	call   801fa9 <pageref>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	89 3c 24             	mov    %edi,(%esp)
  801a28:	e8 7c 05 00 00       	call   801fa9 <pageref>
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	39 c3                	cmp    %eax,%ebx
  801a32:	0f 94 c1             	sete   %cl
  801a35:	0f b6 c9             	movzbl %cl,%ecx
  801a38:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a3b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a41:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a44:	39 ce                	cmp    %ecx,%esi
  801a46:	74 1b                	je     801a63 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a48:	39 c3                	cmp    %eax,%ebx
  801a4a:	75 c4                	jne    801a10 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4c:	8b 42 58             	mov    0x58(%edx),%eax
  801a4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a52:	50                   	push   %eax
  801a53:	56                   	push   %esi
  801a54:	68 ef 26 80 00       	push   $0x8026ef
  801a59:	e8 fd e6 ff ff       	call   80015b <cprintf>
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	eb ad                	jmp    801a10 <_pipeisclosed+0xe>
	}
}
  801a63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	83 ec 28             	sub    $0x28,%esp
  801a77:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a7a:	56                   	push   %esi
  801a7b:	e8 a4 f2 ff ff       	call   800d24 <fd2data>
  801a80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	bf 00 00 00 00       	mov    $0x0,%edi
  801a8a:	eb 4b                	jmp    801ad7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a8c:	89 da                	mov    %ebx,%edx
  801a8e:	89 f0                	mov    %esi,%eax
  801a90:	e8 6d ff ff ff       	call   801a02 <_pipeisclosed>
  801a95:	85 c0                	test   %eax,%eax
  801a97:	75 48                	jne    801ae1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a99:	e8 26 f0 ff ff       	call   800ac4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9e:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa1:	8b 0b                	mov    (%ebx),%ecx
  801aa3:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa6:	39 d0                	cmp    %edx,%eax
  801aa8:	73 e2                	jae    801a8c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab4:	89 c2                	mov    %eax,%edx
  801ab6:	c1 fa 1f             	sar    $0x1f,%edx
  801ab9:	89 d1                	mov    %edx,%ecx
  801abb:	c1 e9 1b             	shr    $0x1b,%ecx
  801abe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac1:	83 e2 1f             	and    $0x1f,%edx
  801ac4:	29 ca                	sub    %ecx,%edx
  801ac6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ace:	83 c0 01             	add    $0x1,%eax
  801ad1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad4:	83 c7 01             	add    $0x1,%edi
  801ad7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ada:	75 c2                	jne    801a9e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801adc:	8b 45 10             	mov    0x10(%ebp),%eax
  801adf:	eb 05                	jmp    801ae6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 18             	sub    $0x18,%esp
  801af7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801afa:	57                   	push   %edi
  801afb:	e8 24 f2 ff ff       	call   800d24 <fd2data>
  801b00:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b0a:	eb 3d                	jmp    801b49 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b0c:	85 db                	test   %ebx,%ebx
  801b0e:	74 04                	je     801b14 <devpipe_read+0x26>
				return i;
  801b10:	89 d8                	mov    %ebx,%eax
  801b12:	eb 44                	jmp    801b58 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b14:	89 f2                	mov    %esi,%edx
  801b16:	89 f8                	mov    %edi,%eax
  801b18:	e8 e5 fe ff ff       	call   801a02 <_pipeisclosed>
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	75 32                	jne    801b53 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b21:	e8 9e ef ff ff       	call   800ac4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b26:	8b 06                	mov    (%esi),%eax
  801b28:	3b 46 04             	cmp    0x4(%esi),%eax
  801b2b:	74 df                	je     801b0c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b2d:	99                   	cltd   
  801b2e:	c1 ea 1b             	shr    $0x1b,%edx
  801b31:	01 d0                	add    %edx,%eax
  801b33:	83 e0 1f             	and    $0x1f,%eax
  801b36:	29 d0                	sub    %edx,%eax
  801b38:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b40:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b43:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c3 01             	add    $0x1,%ebx
  801b49:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b4c:	75 d8                	jne    801b26 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b51:	eb 05                	jmp    801b58 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6b:	50                   	push   %eax
  801b6c:	e8 ca f1 ff ff       	call   800d3b <fd_alloc>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	89 c2                	mov    %eax,%edx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 2c 01 00 00    	js     801caa <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7e:	83 ec 04             	sub    $0x4,%esp
  801b81:	68 07 04 00 00       	push   $0x407
  801b86:	ff 75 f4             	pushl  -0xc(%ebp)
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 53 ef ff ff       	call   800ae3 <sys_page_alloc>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	85 c0                	test   %eax,%eax
  801b97:	0f 88 0d 01 00 00    	js     801caa <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 92 f1 ff ff       	call   800d3b <fd_alloc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 e2 00 00 00    	js     801c98 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	68 07 04 00 00       	push   $0x407
  801bbe:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 1b ef ff ff       	call   800ae3 <sys_page_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	0f 88 c3 00 00 00    	js     801c98 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdb:	e8 44 f1 ff ff       	call   800d24 <fd2data>
  801be0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be2:	83 c4 0c             	add    $0xc,%esp
  801be5:	68 07 04 00 00       	push   $0x407
  801bea:	50                   	push   %eax
  801beb:	6a 00                	push   $0x0
  801bed:	e8 f1 ee ff ff       	call   800ae3 <sys_page_alloc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 89 00 00 00    	js     801c88 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	ff 75 f0             	pushl  -0x10(%ebp)
  801c05:	e8 1a f1 ff ff       	call   800d24 <fd2data>
  801c0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c11:	50                   	push   %eax
  801c12:	6a 00                	push   $0x0
  801c14:	56                   	push   %esi
  801c15:	6a 00                	push   $0x0
  801c17:	e8 0a ef ff ff       	call   800b26 <sys_page_map>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	83 c4 20             	add    $0x20,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 55                	js     801c7a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c3a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c43:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	ff 75 f4             	pushl  -0xc(%ebp)
  801c55:	e8 ba f0 ff ff       	call   800d14 <fd2num>
  801c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5f:	83 c4 04             	add    $0x4,%esp
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	e8 aa f0 ff ff       	call   800d14 <fd2num>
  801c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	ba 00 00 00 00       	mov    $0x0,%edx
  801c78:	eb 30                	jmp    801caa <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	56                   	push   %esi
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 e3 ee ff ff       	call   800b68 <sys_page_unmap>
  801c85:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 d3 ee ff ff       	call   800b68 <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 c3 ee ff ff       	call   800b68 <sys_page_unmap>
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	ff 75 08             	pushl  0x8(%ebp)
  801cc0:	e8 c5 f0 ff ff       	call   800d8a <fd_lookup>
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 18                	js     801ce4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ccc:	83 ec 0c             	sub    $0xc,%esp
  801ccf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd2:	e8 4d f0 ff ff       	call   800d24 <fd2data>
	return _pipeisclosed(fd, p);
  801cd7:	89 c2                	mov    %eax,%edx
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	e8 21 fd ff ff       	call   801a02 <_pipeisclosed>
  801ce1:	83 c4 10             	add    $0x10,%esp
}
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf6:	68 07 27 80 00       	push   $0x802707
  801cfb:	ff 75 0c             	pushl  0xc(%ebp)
  801cfe:	e8 dd e9 ff ff       	call   8006e0 <strcpy>
	return 0;
}
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	57                   	push   %edi
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d16:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d21:	eb 2d                	jmp    801d50 <devcons_write+0x46>
		m = n - tot;
  801d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d26:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d28:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d30:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	53                   	push   %ebx
  801d37:	03 45 0c             	add    0xc(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	57                   	push   %edi
  801d3c:	e8 31 eb ff ff       	call   800872 <memmove>
		sys_cputs(buf, m);
  801d41:	83 c4 08             	add    $0x8,%esp
  801d44:	53                   	push   %ebx
  801d45:	57                   	push   %edi
  801d46:	e8 dc ec ff ff       	call   800a27 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4b:	01 de                	add    %ebx,%esi
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	89 f0                	mov    %esi,%eax
  801d52:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d55:	72 cc                	jb     801d23 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6e:	74 2a                	je     801d9a <devcons_read+0x3b>
  801d70:	eb 05                	jmp    801d77 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d72:	e8 4d ed ff ff       	call   800ac4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d77:	e8 c9 ec ff ff       	call   800a45 <sys_cgetc>
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	74 f2                	je     801d72 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d80:	85 c0                	test   %eax,%eax
  801d82:	78 16                	js     801d9a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d84:	83 f8 04             	cmp    $0x4,%eax
  801d87:	74 0c                	je     801d95 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d89:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8c:	88 02                	mov    %al,(%edx)
	return 1;
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	eb 05                	jmp    801d9a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da8:	6a 01                	push   $0x1
  801daa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dad:	50                   	push   %eax
  801dae:	e8 74 ec ff ff       	call   800a27 <sys_cputs>
}
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <getchar>:

int
getchar(void)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbe:	6a 01                	push   $0x1
  801dc0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 25 f2 ff ff       	call   800ff0 <read>
	if (r < 0)
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 0f                	js     801de1 <getchar+0x29>
		return r;
	if (r < 1)
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	7e 06                	jle    801ddc <getchar+0x24>
		return -E_EOF;
	return c;
  801dd6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dda:	eb 05                	jmp    801de1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ddc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	ff 75 08             	pushl  0x8(%ebp)
  801df0:	e8 95 ef ff ff       	call   800d8a <fd_lookup>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 11                	js     801e0d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dff:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e05:	39 10                	cmp    %edx,(%eax)
  801e07:	0f 94 c0             	sete   %al
  801e0a:	0f b6 c0             	movzbl %al,%eax
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <opencons>:

int
opencons(void)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	e8 1d ef ff ff       	call   800d3b <fd_alloc>
  801e1e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e21:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 3e                	js     801e65 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	68 07 04 00 00       	push   $0x407
  801e2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e32:	6a 00                	push   $0x0
  801e34:	e8 aa ec ff ff       	call   800ae3 <sys_page_alloc>
  801e39:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 23                	js     801e65 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e42:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	50                   	push   %eax
  801e5b:	e8 b4 ee ff ff       	call   800d14 <fd2num>
  801e60:	89 c2                	mov    %eax,%edx
  801e62:	83 c4 10             	add    $0x10,%esp
}
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e71:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e77:	e8 29 ec ff ff       	call   800aa5 <sys_getenvid>
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 0c             	pushl  0xc(%ebp)
  801e82:	ff 75 08             	pushl  0x8(%ebp)
  801e85:	56                   	push   %esi
  801e86:	50                   	push   %eax
  801e87:	68 14 27 80 00       	push   $0x802714
  801e8c:	e8 ca e2 ff ff       	call   80015b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e91:	83 c4 18             	add    $0x18,%esp
  801e94:	53                   	push   %ebx
  801e95:	ff 75 10             	pushl  0x10(%ebp)
  801e98:	e8 6d e2 ff ff       	call   80010a <vcprintf>
	cprintf("\n");
  801e9d:	c7 04 24 00 27 80 00 	movl   $0x802700,(%esp)
  801ea4:	e8 b2 e2 ff ff       	call   80015b <cprintf>
  801ea9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eac:	cc                   	int3   
  801ead:	eb fd                	jmp    801eac <_panic+0x43>

00801eaf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	74 0e                	je     801ecf <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	50                   	push   %eax
  801ec5:	e8 c9 ed ff ff       	call   800c93 <sys_ipc_recv>
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	eb 10                	jmp    801edf <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	68 00 00 00 f0       	push   $0xf0000000
  801ed7:	e8 b7 ed ff ff       	call   800c93 <sys_ipc_recv>
  801edc:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	74 0e                	je     801ef1 <ipc_recv+0x42>
    	*from_env_store = 0;
  801ee3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ee9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801eef:	eb 24                	jmp    801f15 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ef1:	85 f6                	test   %esi,%esi
  801ef3:	74 0a                	je     801eff <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ef5:	a1 08 40 80 00       	mov    0x804008,%eax
  801efa:	8b 40 74             	mov    0x74(%eax),%eax
  801efd:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801eff:	85 db                	test   %ebx,%ebx
  801f01:	74 0a                	je     801f0d <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f03:	a1 08 40 80 00       	mov    0x804008,%eax
  801f08:	8b 40 78             	mov    0x78(%eax),%eax
  801f0b:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f0d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f12:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	57                   	push   %edi
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f28:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f2e:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f35:	0f 44 d8             	cmove  %eax,%ebx
  801f38:	eb 1c                	jmp    801f56 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3d:	74 12                	je     801f51 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f3f:	50                   	push   %eax
  801f40:	68 38 27 80 00       	push   $0x802738
  801f45:	6a 4b                	push   $0x4b
  801f47:	68 50 27 80 00       	push   $0x802750
  801f4c:	e8 18 ff ff ff       	call   801e69 <_panic>
        }	
        sys_yield();
  801f51:	e8 6e eb ff ff       	call   800ac4 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f56:	ff 75 14             	pushl  0x14(%ebp)
  801f59:	53                   	push   %ebx
  801f5a:	56                   	push   %esi
  801f5b:	57                   	push   %edi
  801f5c:	e8 0f ed ff ff       	call   800c70 <sys_ipc_try_send>
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	75 d2                	jne    801f3a <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f7e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f84:	8b 52 50             	mov    0x50(%edx),%edx
  801f87:	39 ca                	cmp    %ecx,%edx
  801f89:	75 0d                	jne    801f98 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f8b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f8e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f93:	8b 40 48             	mov    0x48(%eax),%eax
  801f96:	eb 0f                	jmp    801fa7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f98:	83 c0 01             	add    $0x1,%eax
  801f9b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa0:	75 d9                	jne    801f7b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	c1 e8 16             	shr    $0x16,%eax
  801fb4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc0:	f6 c1 01             	test   $0x1,%cl
  801fc3:	74 1d                	je     801fe2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc5:	c1 ea 0c             	shr    $0xc,%edx
  801fc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fcf:	f6 c2 01             	test   $0x1,%dl
  801fd2:	74 0e                	je     801fe2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd4:	c1 ea 0c             	shr    $0xc,%edx
  801fd7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fde:	ef 
  801fdf:	0f b7 c0             	movzwl %ax,%eax
}
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	66 90                	xchg   %ax,%ax
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
