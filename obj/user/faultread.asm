
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 80 22 80 00       	push   $0x802280
  800044:	e8 02 01 00 00       	call   80014b <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800060:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800063:	e8 2d 0a 00 00       	call   800a95 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x37>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0a 00 00 00       	call   80009e <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a4:	e8 26 0e 00 00       	call   800ecf <close_all>
	sys_env_destroy(0);
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 a1 09 00 00       	call   800a54 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 2f 09 00 00       	call   800a17 <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 54 01 00 00       	call   800282 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 d4 08 00 00       	call   800a17 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800178:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800180:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800183:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800186:	39 d3                	cmp    %edx,%ebx
  800188:	72 05                	jb     80018f <printnum+0x30>
  80018a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018d:	77 45                	ja     8001d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 18             	pushl  0x18(%ebp)
  800195:	8b 45 14             	mov    0x14(%ebp),%eax
  800198:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 2d 1e 00 00       	call   801fe0 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 18                	jmp    8001de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	eb 03                	jmp    8001d7 <printnum+0x78>
  8001d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7f e8                	jg     8001c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	56                   	push   %esi
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f1:	e8 1a 1f 00 00       	call   802110 <__umoddi3>
  8001f6:	83 c4 14             	add    $0x14,%esp
  8001f9:	0f be 80 a8 22 80 00 	movsbl 0x8022a8(%eax),%eax
  800200:	50                   	push   %eax
  800201:	ff d7                	call   *%edi
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7e 0e                	jle    800224 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	8b 52 04             	mov    0x4(%edx),%edx
  800222:	eb 22                	jmp    800246 <getuint+0x38>
	else if (lflag)
  800224:	85 d2                	test   %edx,%edx
  800226:	74 10                	je     800238 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	eb 0e                	jmp    800246 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800252:	8b 10                	mov    (%eax),%edx
  800254:	3b 50 04             	cmp    0x4(%eax),%edx
  800257:	73 0a                	jae    800263 <sprintputch+0x1b>
		*b->buf++ = ch;
  800259:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	88 02                	mov    %al,(%edx)
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 05 00 00 00       	call   800282 <vprintfmt>
	va_end(ap);
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	8b 75 08             	mov    0x8(%ebp),%esi
  80028e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800291:	8b 7d 10             	mov    0x10(%ebp),%edi
  800294:	eb 12                	jmp    8002a8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800296:	85 c0                	test   %eax,%eax
  800298:	0f 84 89 03 00 00    	je     800627 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	53                   	push   %ebx
  8002a2:	50                   	push   %eax
  8002a3:	ff d6                	call   *%esi
  8002a5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a8:	83 c7 01             	add    $0x1,%edi
  8002ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002af:	83 f8 25             	cmp    $0x25,%eax
  8002b2:	75 e2                	jne    800296 <vprintfmt+0x14>
  8002b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	eb 07                	jmp    8002db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8d 47 01             	lea    0x1(%edi),%eax
  8002de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e1:	0f b6 07             	movzbl (%edi),%eax
  8002e4:	0f b6 c8             	movzbl %al,%ecx
  8002e7:	83 e8 23             	sub    $0x23,%eax
  8002ea:	3c 55                	cmp    $0x55,%al
  8002ec:	0f 87 1a 03 00 00    	ja     80060c <vprintfmt+0x38a>
  8002f2:	0f b6 c0             	movzbl %al,%eax
  8002f5:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800303:	eb d6                	jmp    8002db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800308:	b8 00 00 00 00       	mov    $0x0,%eax
  80030d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800310:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800313:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800317:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031d:	83 fa 09             	cmp    $0x9,%edx
  800320:	77 39                	ja     80035b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800322:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800325:	eb e9                	jmp    800310 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8d 48 04             	lea    0x4(%eax),%ecx
  80032d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800330:	8b 00                	mov    (%eax),%eax
  800332:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800338:	eb 27                	jmp    800361 <vprintfmt+0xdf>
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	85 c0                	test   %eax,%eax
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	0f 49 c8             	cmovns %eax,%ecx
  800347:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	eb 8c                	jmp    8002db <vprintfmt+0x59>
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800352:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800359:	eb 80                	jmp    8002db <vprintfmt+0x59>
  80035b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800361:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800365:	0f 89 70 ff ff ff    	jns    8002db <vprintfmt+0x59>
				width = precision, precision = -1;
  80036b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800371:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800378:	e9 5e ff ff ff       	jmp    8002db <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800383:	e9 53 ff ff ff       	jmp    8002db <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 50 04             	lea    0x4(%eax),%edx
  80038e:	89 55 14             	mov    %edx,0x14(%ebp)
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	53                   	push   %ebx
  800395:	ff 30                	pushl  (%eax)
  800397:	ff d6                	call   *%esi
			break;
  800399:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039f:	e9 04 ff ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	99                   	cltd   
  8003b0:	31 d0                	xor    %edx,%eax
  8003b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b4:	83 f8 0f             	cmp    $0xf,%eax
  8003b7:	7f 0b                	jg     8003c4 <vprintfmt+0x142>
  8003b9:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	75 18                	jne    8003dc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c4:	50                   	push   %eax
  8003c5:	68 c0 22 80 00       	push   $0x8022c0
  8003ca:	53                   	push   %ebx
  8003cb:	56                   	push   %esi
  8003cc:	e8 94 fe ff ff       	call   800265 <printfmt>
  8003d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d7:	e9 cc fe ff ff       	jmp    8002a8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003dc:	52                   	push   %edx
  8003dd:	68 75 26 80 00       	push   $0x802675
  8003e2:	53                   	push   %ebx
  8003e3:	56                   	push   %esi
  8003e4:	e8 7c fe ff ff       	call   800265 <printfmt>
  8003e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	e9 b4 fe ff ff       	jmp    8002a8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ff:	85 ff                	test   %edi,%edi
  800401:	b8 b9 22 80 00       	mov    $0x8022b9,%eax
  800406:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040d:	0f 8e 94 00 00 00    	jle    8004a7 <vprintfmt+0x225>
  800413:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800417:	0f 84 98 00 00 00    	je     8004b5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	ff 75 d0             	pushl  -0x30(%ebp)
  800423:	57                   	push   %edi
  800424:	e8 86 02 00 00       	call   8006af <strnlen>
  800429:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042c:	29 c1                	sub    %eax,%ecx
  80042e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800431:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800434:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	eb 0f                	jmp    800451 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ef 01             	sub    $0x1,%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	85 ff                	test   %edi,%edi
  800453:	7f ed                	jg     800442 <vprintfmt+0x1c0>
  800455:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800458:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80045b:	85 c9                	test   %ecx,%ecx
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	0f 49 c1             	cmovns %ecx,%eax
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 75 08             	mov    %esi,0x8(%ebp)
  80046a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800470:	89 cb                	mov    %ecx,%ebx
  800472:	eb 4d                	jmp    8004c1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	74 1b                	je     800495 <vprintfmt+0x213>
  80047a:	0f be c0             	movsbl %al,%eax
  80047d:	83 e8 20             	sub    $0x20,%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 10                	jbe    800495 <vprintfmt+0x213>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	6a 3f                	push   $0x3f
  80048d:	ff 55 08             	call   *0x8(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb 0d                	jmp    8004a2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	52                   	push   %edx
  80049c:	ff 55 08             	call   *0x8(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	eb 1a                	jmp    8004c1 <vprintfmt+0x23f>
  8004a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b3:	eb 0c                	jmp    8004c1 <vprintfmt+0x23f>
  8004b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c1:	83 c7 01             	add    $0x1,%edi
  8004c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c8:	0f be d0             	movsbl %al,%edx
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 23                	je     8004f2 <vprintfmt+0x270>
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	78 a1                	js     800474 <vprintfmt+0x1f2>
  8004d3:	83 ee 01             	sub    $0x1,%esi
  8004d6:	79 9c                	jns    800474 <vprintfmt+0x1f2>
  8004d8:	89 df                	mov    %ebx,%edi
  8004da:	8b 75 08             	mov    0x8(%ebp),%esi
  8004dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e0:	eb 18                	jmp    8004fa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 20                	push   $0x20
  8004e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x278>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f e4                	jg     8004e2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 a2 fd ff ff       	jmp    8002a8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 fa 01             	cmp    $0x1,%edx
  800509:	7e 16                	jle    800521 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 08             	lea    0x8(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 50 04             	mov    0x4(%eax),%edx
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051f:	eb 32                	jmp    800553 <vprintfmt+0x2d1>
	else if (lflag)
  800521:	85 d2                	test   %edx,%edx
  800523:	74 18                	je     80053d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800533:	89 c1                	mov    %eax,%ecx
  800535:	c1 f9 1f             	sar    $0x1f,%ecx
  800538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053b:	eb 16                	jmp    800553 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800553:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800556:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800559:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800562:	79 74                	jns    8005d8 <vprintfmt+0x356>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 2d                	push   $0x2d
  80056a:	ff d6                	call   *%esi
				num = -(long long) num;
  80056c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800572:	f7 d8                	neg    %eax
  800574:	83 d2 00             	adc    $0x0,%edx
  800577:	f7 da                	neg    %edx
  800579:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800581:	eb 55                	jmp    8005d8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800583:	8d 45 14             	lea    0x14(%ebp),%eax
  800586:	e8 83 fc ff ff       	call   80020e <getuint>
			base = 10;
  80058b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800590:	eb 46                	jmp    8005d8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	e8 74 fc ff ff       	call   80020e <getuint>
		        base = 8;
  80059a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80059f:	eb 37                	jmp    8005d8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 30                	push   $0x30
  8005a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 78                	push   $0x78
  8005af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 3b fc ff ff       	call   80020e <getuint>
			base = 16;
  8005d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005df:	57                   	push   %edi
  8005e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e3:	51                   	push   %ecx
  8005e4:	52                   	push   %edx
  8005e5:	50                   	push   %eax
  8005e6:	89 da                	mov    %ebx,%edx
  8005e8:	89 f0                	mov    %esi,%eax
  8005ea:	e8 70 fb ff ff       	call   80015f <printnum>
			break;
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f5:	e9 ae fc ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	51                   	push   %ecx
  8005ff:	ff d6                	call   *%esi
			break;
  800601:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800607:	e9 9c fc ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 25                	push   $0x25
  800612:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	eb 03                	jmp    80061c <vprintfmt+0x39a>
  800619:	83 ef 01             	sub    $0x1,%edi
  80061c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800620:	75 f7                	jne    800619 <vprintfmt+0x397>
  800622:	e9 81 fc ff ff       	jmp    8002a8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 18             	sub    $0x18,%esp
  800635:	8b 45 08             	mov    0x8(%ebp),%eax
  800638:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800642:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	74 26                	je     800676 <vsnprintf+0x47>
  800650:	85 d2                	test   %edx,%edx
  800652:	7e 22                	jle    800676 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800654:	ff 75 14             	pushl  0x14(%ebp)
  800657:	ff 75 10             	pushl  0x10(%ebp)
  80065a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065d:	50                   	push   %eax
  80065e:	68 48 02 80 00       	push   $0x800248
  800663:	e8 1a fc ff ff       	call   800282 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800668:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 05                	jmp    80067b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067b:	c9                   	leave  
  80067c:	c3                   	ret    

0080067d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800686:	50                   	push   %eax
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	ff 75 08             	pushl  0x8(%ebp)
  800690:	e8 9a ff ff ff       	call   80062f <vsnprintf>
	va_end(ap);

	return rc;
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069d:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a2:	eb 03                	jmp    8006a7 <strlen+0x10>
		n++;
  8006a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ab:	75 f7                	jne    8006a4 <strlen+0xd>
		n++;
	return n;
}
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bd:	eb 03                	jmp    8006c2 <strnlen+0x13>
		n++;
  8006bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c2:	39 c2                	cmp    %eax,%edx
  8006c4:	74 08                	je     8006ce <strnlen+0x1f>
  8006c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ca:	75 f3                	jne    8006bf <strnlen+0x10>
  8006cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006da:	89 c2                	mov    %eax,%edx
  8006dc:	83 c2 01             	add    $0x1,%edx
  8006df:	83 c1 01             	add    $0x1,%ecx
  8006e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006e9:	84 db                	test   %bl,%bl
  8006eb:	75 ef                	jne    8006dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ed:	5b                   	pop    %ebx
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f7:	53                   	push   %ebx
  8006f8:	e8 9a ff ff ff       	call   800697 <strlen>
  8006fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	01 d8                	add    %ebx,%eax
  800705:	50                   	push   %eax
  800706:	e8 c5 ff ff ff       	call   8006d0 <strcpy>
	return dst;
}
  80070b:	89 d8                	mov    %ebx,%eax
  80070d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	56                   	push   %esi
  800716:	53                   	push   %ebx
  800717:	8b 75 08             	mov    0x8(%ebp),%esi
  80071a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071d:	89 f3                	mov    %esi,%ebx
  80071f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800722:	89 f2                	mov    %esi,%edx
  800724:	eb 0f                	jmp    800735 <strncpy+0x23>
		*dst++ = *src;
  800726:	83 c2 01             	add    $0x1,%edx
  800729:	0f b6 01             	movzbl (%ecx),%eax
  80072c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80072f:	80 39 01             	cmpb   $0x1,(%ecx)
  800732:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800735:	39 da                	cmp    %ebx,%edx
  800737:	75 ed                	jne    800726 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800739:	89 f0                	mov    %esi,%eax
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	56                   	push   %esi
  800743:	53                   	push   %ebx
  800744:	8b 75 08             	mov    0x8(%ebp),%esi
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074a:	8b 55 10             	mov    0x10(%ebp),%edx
  80074d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 21                	je     800774 <strlcpy+0x35>
  800753:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800757:	89 f2                	mov    %esi,%edx
  800759:	eb 09                	jmp    800764 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075b:	83 c2 01             	add    $0x1,%edx
  80075e:	83 c1 01             	add    $0x1,%ecx
  800761:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800764:	39 c2                	cmp    %eax,%edx
  800766:	74 09                	je     800771 <strlcpy+0x32>
  800768:	0f b6 19             	movzbl (%ecx),%ebx
  80076b:	84 db                	test   %bl,%bl
  80076d:	75 ec                	jne    80075b <strlcpy+0x1c>
  80076f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800771:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800774:	29 f0                	sub    %esi,%eax
}
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800783:	eb 06                	jmp    80078b <strcmp+0x11>
		p++, q++;
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078b:	0f b6 01             	movzbl (%ecx),%eax
  80078e:	84 c0                	test   %al,%al
  800790:	74 04                	je     800796 <strcmp+0x1c>
  800792:	3a 02                	cmp    (%edx),%al
  800794:	74 ef                	je     800785 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800796:	0f b6 c0             	movzbl %al,%eax
  800799:	0f b6 12             	movzbl (%edx),%edx
  80079c:	29 d0                	sub    %edx,%eax
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007af:	eb 06                	jmp    8007b7 <strncmp+0x17>
		n--, p++, q++;
  8007b1:	83 c0 01             	add    $0x1,%eax
  8007b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007b7:	39 d8                	cmp    %ebx,%eax
  8007b9:	74 15                	je     8007d0 <strncmp+0x30>
  8007bb:	0f b6 08             	movzbl (%eax),%ecx
  8007be:	84 c9                	test   %cl,%cl
  8007c0:	74 04                	je     8007c6 <strncmp+0x26>
  8007c2:	3a 0a                	cmp    (%edx),%cl
  8007c4:	74 eb                	je     8007b1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c6:	0f b6 00             	movzbl (%eax),%eax
  8007c9:	0f b6 12             	movzbl (%edx),%edx
  8007cc:	29 d0                	sub    %edx,%eax
  8007ce:	eb 05                	jmp    8007d5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e2:	eb 07                	jmp    8007eb <strchr+0x13>
		if (*s == c)
  8007e4:	38 ca                	cmp    %cl,%dl
  8007e6:	74 0f                	je     8007f7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	0f b6 10             	movzbl (%eax),%edx
  8007ee:	84 d2                	test   %dl,%dl
  8007f0:	75 f2                	jne    8007e4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800803:	eb 03                	jmp    800808 <strfind+0xf>
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080b:	38 ca                	cmp    %cl,%dl
  80080d:	74 04                	je     800813 <strfind+0x1a>
  80080f:	84 d2                	test   %dl,%dl
  800811:	75 f2                	jne    800805 <strfind+0xc>
			break;
	return (char *) s;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	57                   	push   %edi
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 36                	je     80085b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800825:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082b:	75 28                	jne    800855 <memset+0x40>
  80082d:	f6 c1 03             	test   $0x3,%cl
  800830:	75 23                	jne    800855 <memset+0x40>
		c &= 0xFF;
  800832:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800836:	89 d3                	mov    %edx,%ebx
  800838:	c1 e3 08             	shl    $0x8,%ebx
  80083b:	89 d6                	mov    %edx,%esi
  80083d:	c1 e6 18             	shl    $0x18,%esi
  800840:	89 d0                	mov    %edx,%eax
  800842:	c1 e0 10             	shl    $0x10,%eax
  800845:	09 f0                	or     %esi,%eax
  800847:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800849:	89 d8                	mov    %ebx,%eax
  80084b:	09 d0                	or     %edx,%eax
  80084d:	c1 e9 02             	shr    $0x2,%ecx
  800850:	fc                   	cld    
  800851:	f3 ab                	rep stos %eax,%es:(%edi)
  800853:	eb 06                	jmp    80085b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	fc                   	cld    
  800859:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5f                   	pop    %edi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800870:	39 c6                	cmp    %eax,%esi
  800872:	73 35                	jae    8008a9 <memmove+0x47>
  800874:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800877:	39 d0                	cmp    %edx,%eax
  800879:	73 2e                	jae    8008a9 <memmove+0x47>
		s += n;
		d += n;
  80087b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087e:	89 d6                	mov    %edx,%esi
  800880:	09 fe                	or     %edi,%esi
  800882:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800888:	75 13                	jne    80089d <memmove+0x3b>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 0e                	jne    80089d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80088f:	83 ef 04             	sub    $0x4,%edi
  800892:	8d 72 fc             	lea    -0x4(%edx),%esi
  800895:	c1 e9 02             	shr    $0x2,%ecx
  800898:	fd                   	std    
  800899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089b:	eb 09                	jmp    8008a6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80089d:	83 ef 01             	sub    $0x1,%edi
  8008a0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a3:	fd                   	std    
  8008a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a6:	fc                   	cld    
  8008a7:	eb 1d                	jmp    8008c6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a9:	89 f2                	mov    %esi,%edx
  8008ab:	09 c2                	or     %eax,%edx
  8008ad:	f6 c2 03             	test   $0x3,%dl
  8008b0:	75 0f                	jne    8008c1 <memmove+0x5f>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0a                	jne    8008c1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
  8008ba:	89 c7                	mov    %eax,%edi
  8008bc:	fc                   	cld    
  8008bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bf:	eb 05                	jmp    8008c6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c1:	89 c7                	mov    %eax,%edi
  8008c3:	fc                   	cld    
  8008c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008cd:	ff 75 10             	pushl  0x10(%ebp)
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 87 ff ff ff       	call   800862 <memmove>
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 c6                	mov    %eax,%esi
  8008ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ed:	eb 1a                	jmp    800909 <memcmp+0x2c>
		if (*s1 != *s2)
  8008ef:	0f b6 08             	movzbl (%eax),%ecx
  8008f2:	0f b6 1a             	movzbl (%edx),%ebx
  8008f5:	38 d9                	cmp    %bl,%cl
  8008f7:	74 0a                	je     800903 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008f9:	0f b6 c1             	movzbl %cl,%eax
  8008fc:	0f b6 db             	movzbl %bl,%ebx
  8008ff:	29 d8                	sub    %ebx,%eax
  800901:	eb 0f                	jmp    800912 <memcmp+0x35>
		s1++, s2++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800909:	39 f0                	cmp    %esi,%eax
  80090b:	75 e2                	jne    8008ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80091d:	89 c1                	mov    %eax,%ecx
  80091f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800922:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800926:	eb 0a                	jmp    800932 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	39 da                	cmp    %ebx,%edx
  80092d:	74 07                	je     800936 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	39 c8                	cmp    %ecx,%eax
  800934:	72 f2                	jb     800928 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800945:	eb 03                	jmp    80094a <strtol+0x11>
		s++;
  800947:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094a:	0f b6 01             	movzbl (%ecx),%eax
  80094d:	3c 20                	cmp    $0x20,%al
  80094f:	74 f6                	je     800947 <strtol+0xe>
  800951:	3c 09                	cmp    $0x9,%al
  800953:	74 f2                	je     800947 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800955:	3c 2b                	cmp    $0x2b,%al
  800957:	75 0a                	jne    800963 <strtol+0x2a>
		s++;
  800959:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095c:	bf 00 00 00 00       	mov    $0x0,%edi
  800961:	eb 11                	jmp    800974 <strtol+0x3b>
  800963:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800968:	3c 2d                	cmp    $0x2d,%al
  80096a:	75 08                	jne    800974 <strtol+0x3b>
		s++, neg = 1;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800974:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097a:	75 15                	jne    800991 <strtol+0x58>
  80097c:	80 39 30             	cmpb   $0x30,(%ecx)
  80097f:	75 10                	jne    800991 <strtol+0x58>
  800981:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800985:	75 7c                	jne    800a03 <strtol+0xca>
		s += 2, base = 16;
  800987:	83 c1 02             	add    $0x2,%ecx
  80098a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80098f:	eb 16                	jmp    8009a7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800991:	85 db                	test   %ebx,%ebx
  800993:	75 12                	jne    8009a7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800995:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099a:	80 39 30             	cmpb   $0x30,(%ecx)
  80099d:	75 08                	jne    8009a7 <strtol+0x6e>
		s++, base = 8;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009af:	0f b6 11             	movzbl (%ecx),%edx
  8009b2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b5:	89 f3                	mov    %esi,%ebx
  8009b7:	80 fb 09             	cmp    $0x9,%bl
  8009ba:	77 08                	ja     8009c4 <strtol+0x8b>
			dig = *s - '0';
  8009bc:	0f be d2             	movsbl %dl,%edx
  8009bf:	83 ea 30             	sub    $0x30,%edx
  8009c2:	eb 22                	jmp    8009e6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009c4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009c7:	89 f3                	mov    %esi,%ebx
  8009c9:	80 fb 19             	cmp    $0x19,%bl
  8009cc:	77 08                	ja     8009d6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009ce:	0f be d2             	movsbl %dl,%edx
  8009d1:	83 ea 57             	sub    $0x57,%edx
  8009d4:	eb 10                	jmp    8009e6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009d6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009d9:	89 f3                	mov    %esi,%ebx
  8009db:	80 fb 19             	cmp    $0x19,%bl
  8009de:	77 16                	ja     8009f6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e0:	0f be d2             	movsbl %dl,%edx
  8009e3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009e6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e9:	7d 0b                	jge    8009f6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f4:	eb b9                	jmp    8009af <strtol+0x76>

	if (endptr)
  8009f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fa:	74 0d                	je     800a09 <strtol+0xd0>
		*endptr = (char *) s;
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	89 0e                	mov    %ecx,(%esi)
  800a01:	eb 06                	jmp    800a09 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	85 db                	test   %ebx,%ebx
  800a05:	74 98                	je     80099f <strtol+0x66>
  800a07:	eb 9e                	jmp    8009a7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a09:	89 c2                	mov    %eax,%edx
  800a0b:	f7 da                	neg    %edx
  800a0d:	85 ff                	test   %edi,%edi
  800a0f:	0f 45 c2             	cmovne %edx,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	89 c6                	mov    %eax,%esi
  800a2e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	b8 01 00 00 00       	mov    $0x1,%eax
  800a45:	89 d1                	mov    %edx,%ecx
  800a47:	89 d3                	mov    %edx,%ebx
  800a49:	89 d7                	mov    %edx,%edi
  800a4b:	89 d6                	mov    %edx,%esi
  800a4d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a62:	b8 03 00 00 00       	mov    $0x3,%eax
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 cb                	mov    %ecx,%ebx
  800a6c:	89 cf                	mov    %ecx,%edi
  800a6e:	89 ce                	mov    %ecx,%esi
  800a70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a72:	85 c0                	test   %eax,%eax
  800a74:	7e 17                	jle    800a8d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a76:	83 ec 0c             	sub    $0xc,%esp
  800a79:	50                   	push   %eax
  800a7a:	6a 03                	push   $0x3
  800a7c:	68 9f 25 80 00       	push   $0x80259f
  800a81:	6a 23                	push   $0x23
  800a83:	68 bc 25 80 00       	push   $0x8025bc
  800a88:	e8 cc 13 00 00       	call   801e59 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa5:	89 d1                	mov    %edx,%ecx
  800aa7:	89 d3                	mov    %edx,%ebx
  800aa9:	89 d7                	mov    %edx,%edi
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <sys_yield>:

void
sys_yield(void)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	ba 00 00 00 00       	mov    $0x0,%edx
  800abf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ac4:	89 d1                	mov    %edx,%ecx
  800ac6:	89 d3                	mov    %edx,%ebx
  800ac8:	89 d7                	mov    %edx,%edi
  800aca:	89 d6                	mov    %edx,%esi
  800acc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	be 00 00 00 00       	mov    $0x0,%esi
  800ae1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aef:	89 f7                	mov    %esi,%edi
  800af1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 17                	jle    800b0e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	50                   	push   %eax
  800afb:	6a 04                	push   $0x4
  800afd:	68 9f 25 80 00       	push   $0x80259f
  800b02:	6a 23                	push   $0x23
  800b04:	68 bc 25 80 00       	push   $0x8025bc
  800b09:	e8 4b 13 00 00       	call   801e59 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b27:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b30:	8b 75 18             	mov    0x18(%ebp),%esi
  800b33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 05                	push   $0x5
  800b3f:	68 9f 25 80 00       	push   $0x80259f
  800b44:	6a 23                	push   $0x23
  800b46:	68 bc 25 80 00       	push   $0x8025bc
  800b4b:	e8 09 13 00 00       	call   801e59 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b66:	b8 06 00 00 00       	mov    $0x6,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 df                	mov    %ebx,%edi
  800b73:	89 de                	mov    %ebx,%esi
  800b75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 06                	push   $0x6
  800b81:	68 9f 25 80 00       	push   $0x80259f
  800b86:	6a 23                	push   $0x23
  800b88:	68 bc 25 80 00       	push   $0x8025bc
  800b8d:	e8 c7 12 00 00       	call   801e59 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 08                	push   $0x8
  800bc3:	68 9f 25 80 00       	push   $0x80259f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 bc 25 80 00       	push   $0x8025bc
  800bcf:	e8 85 12 00 00       	call   801e59 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 09 00 00 00       	mov    $0x9,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 09                	push   $0x9
  800c05:	68 9f 25 80 00       	push   $0x80259f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 bc 25 80 00       	push   $0x8025bc
  800c11:	e8 43 12 00 00       	call   801e59 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 0a                	push   $0xa
  800c47:	68 9f 25 80 00       	push   $0x80259f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 bc 25 80 00       	push   $0x8025bc
  800c53:	e8 01 12 00 00       	call   801e59 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
  800c6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800c8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 cb                	mov    %ecx,%ebx
  800c9b:	89 cf                	mov    %ecx,%edi
  800c9d:	89 ce                	mov    %ecx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 0d                	push   $0xd
  800cab:	68 9f 25 80 00       	push   $0x80259f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 bc 25 80 00       	push   $0x8025bc
  800cb7:	e8 9d 11 00 00       	call   801e59 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cd4:	89 d1                	mov    %edx,%ecx
  800cd6:	89 d3                	mov    %edx,%ebx
  800cd8:	89 d7                	mov    %edx,%edi
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d0f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d24:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d31:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	c1 ea 16             	shr    $0x16,%edx
  800d3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d42:	f6 c2 01             	test   $0x1,%dl
  800d45:	74 11                	je     800d58 <fd_alloc+0x2d>
  800d47:	89 c2                	mov    %eax,%edx
  800d49:	c1 ea 0c             	shr    $0xc,%edx
  800d4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d53:	f6 c2 01             	test   $0x1,%dl
  800d56:	75 09                	jne    800d61 <fd_alloc+0x36>
			*fd_store = fd;
  800d58:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5f:	eb 17                	jmp    800d78 <fd_alloc+0x4d>
  800d61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d6b:	75 c9                	jne    800d36 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d80:	83 f8 1f             	cmp    $0x1f,%eax
  800d83:	77 36                	ja     800dbb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d85:	c1 e0 0c             	shl    $0xc,%eax
  800d88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	c1 ea 16             	shr    $0x16,%edx
  800d92:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d99:	f6 c2 01             	test   $0x1,%dl
  800d9c:	74 24                	je     800dc2 <fd_lookup+0x48>
  800d9e:	89 c2                	mov    %eax,%edx
  800da0:	c1 ea 0c             	shr    $0xc,%edx
  800da3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800daa:	f6 c2 01             	test   $0x1,%dl
  800dad:	74 1a                	je     800dc9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800daf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db2:	89 02                	mov    %eax,(%edx)
	return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	eb 13                	jmp    800dce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc0:	eb 0c                	jmp    800dce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc7:	eb 05                	jmp    800dce <fd_lookup+0x54>
  800dc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	ba 48 26 80 00       	mov    $0x802648,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dde:	eb 13                	jmp    800df3 <dev_lookup+0x23>
  800de0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800de3:	39 08                	cmp    %ecx,(%eax)
  800de5:	75 0c                	jne    800df3 <dev_lookup+0x23>
			*dev = devtab[i];
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	eb 2e                	jmp    800e21 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df3:	8b 02                	mov    (%edx),%eax
  800df5:	85 c0                	test   %eax,%eax
  800df7:	75 e7                	jne    800de0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800df9:	a1 08 40 80 00       	mov    0x804008,%eax
  800dfe:	8b 40 48             	mov    0x48(%eax),%eax
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	51                   	push   %ecx
  800e05:	50                   	push   %eax
  800e06:	68 cc 25 80 00       	push   $0x8025cc
  800e0b:	e8 3b f3 ff ff       	call   80014b <cprintf>
	*dev = 0;
  800e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e21:	c9                   	leave  
  800e22:	c3                   	ret    

00800e23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 10             	sub    $0x10,%esp
  800e2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e34:	50                   	push   %eax
  800e35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
  800e3e:	50                   	push   %eax
  800e3f:	e8 36 ff ff ff       	call   800d7a <fd_lookup>
  800e44:	83 c4 08             	add    $0x8,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	78 05                	js     800e50 <fd_close+0x2d>
	    || fd != fd2)
  800e4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e4e:	74 0c                	je     800e5c <fd_close+0x39>
		return (must_exist ? r : 0);
  800e50:	84 db                	test   %bl,%bl
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	0f 44 c2             	cmove  %edx,%eax
  800e5a:	eb 41                	jmp    800e9d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e62:	50                   	push   %eax
  800e63:	ff 36                	pushl  (%esi)
  800e65:	e8 66 ff ff ff       	call   800dd0 <dev_lookup>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 1a                	js     800e8d <fd_close+0x6a>
		if (dev->dev_close)
  800e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e76:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	74 0b                	je     800e8d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	56                   	push   %esi
  800e86:	ff d0                	call   *%eax
  800e88:	89 c3                	mov    %eax,%ebx
  800e8a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	56                   	push   %esi
  800e91:	6a 00                	push   $0x0
  800e93:	e8 c0 fc ff ff       	call   800b58 <sys_page_unmap>
	return r;
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 d8                	mov    %ebx,%eax
}
  800e9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ead:	50                   	push   %eax
  800eae:	ff 75 08             	pushl  0x8(%ebp)
  800eb1:	e8 c4 fe ff ff       	call   800d7a <fd_lookup>
  800eb6:	83 c4 08             	add    $0x8,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 10                	js     800ecd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ebd:	83 ec 08             	sub    $0x8,%esp
  800ec0:	6a 01                	push   $0x1
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	e8 59 ff ff ff       	call   800e23 <fd_close>
  800eca:	83 c4 10             	add    $0x10,%esp
}
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <close_all>:

void
close_all(void)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	53                   	push   %ebx
  800edf:	e8 c0 ff ff ff       	call   800ea4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee4:	83 c3 01             	add    $0x1,%ebx
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	83 fb 20             	cmp    $0x20,%ebx
  800eed:	75 ec                	jne    800edb <close_all+0xc>
		close(i);
}
  800eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 2c             	sub    $0x2c,%esp
  800efd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f03:	50                   	push   %eax
  800f04:	ff 75 08             	pushl  0x8(%ebp)
  800f07:	e8 6e fe ff ff       	call   800d7a <fd_lookup>
  800f0c:	83 c4 08             	add    $0x8,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	0f 88 c1 00 00 00    	js     800fd8 <dup+0xe4>
		return r;
	close(newfdnum);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	56                   	push   %esi
  800f1b:	e8 84 ff ff ff       	call   800ea4 <close>

	newfd = INDEX2FD(newfdnum);
  800f20:	89 f3                	mov    %esi,%ebx
  800f22:	c1 e3 0c             	shl    $0xc,%ebx
  800f25:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f2b:	83 c4 04             	add    $0x4,%esp
  800f2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f31:	e8 de fd ff ff       	call   800d14 <fd2data>
  800f36:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f38:	89 1c 24             	mov    %ebx,(%esp)
  800f3b:	e8 d4 fd ff ff       	call   800d14 <fd2data>
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f46:	89 f8                	mov    %edi,%eax
  800f48:	c1 e8 16             	shr    $0x16,%eax
  800f4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f52:	a8 01                	test   $0x1,%al
  800f54:	74 37                	je     800f8d <dup+0x99>
  800f56:	89 f8                	mov    %edi,%eax
  800f58:	c1 e8 0c             	shr    $0xc,%eax
  800f5b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f62:	f6 c2 01             	test   $0x1,%dl
  800f65:	74 26                	je     800f8d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	25 07 0e 00 00       	and    $0xe07,%eax
  800f76:	50                   	push   %eax
  800f77:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f7a:	6a 00                	push   $0x0
  800f7c:	57                   	push   %edi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 92 fb ff ff       	call   800b16 <sys_page_map>
  800f84:	89 c7                	mov    %eax,%edi
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 2e                	js     800fbb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f90:	89 d0                	mov    %edx,%eax
  800f92:	c1 e8 0c             	shr    $0xc,%eax
  800f95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa4:	50                   	push   %eax
  800fa5:	53                   	push   %ebx
  800fa6:	6a 00                	push   $0x0
  800fa8:	52                   	push   %edx
  800fa9:	6a 00                	push   $0x0
  800fab:	e8 66 fb ff ff       	call   800b16 <sys_page_map>
  800fb0:	89 c7                	mov    %eax,%edi
  800fb2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fb5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb7:	85 ff                	test   %edi,%edi
  800fb9:	79 1d                	jns    800fd8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 92 fb ff ff       	call   800b58 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fc6:	83 c4 08             	add    $0x8,%esp
  800fc9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 85 fb ff ff       	call   800b58 <sys_page_unmap>
	return r;
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	89 f8                	mov    %edi,%eax
}
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 14             	sub    $0x14,%esp
  800fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	53                   	push   %ebx
  800fef:	e8 86 fd ff ff       	call   800d7a <fd_lookup>
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	89 c2                	mov    %eax,%edx
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 6d                	js     80106a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801007:	ff 30                	pushl  (%eax)
  801009:	e8 c2 fd ff ff       	call   800dd0 <dev_lookup>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	78 4c                	js     801061 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801015:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801018:	8b 42 08             	mov    0x8(%edx),%eax
  80101b:	83 e0 03             	and    $0x3,%eax
  80101e:	83 f8 01             	cmp    $0x1,%eax
  801021:	75 21                	jne    801044 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801023:	a1 08 40 80 00       	mov    0x804008,%eax
  801028:	8b 40 48             	mov    0x48(%eax),%eax
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	53                   	push   %ebx
  80102f:	50                   	push   %eax
  801030:	68 0d 26 80 00       	push   $0x80260d
  801035:	e8 11 f1 ff ff       	call   80014b <cprintf>
		return -E_INVAL;
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801042:	eb 26                	jmp    80106a <read+0x8a>
	}
	if (!dev->dev_read)
  801044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801047:	8b 40 08             	mov    0x8(%eax),%eax
  80104a:	85 c0                	test   %eax,%eax
  80104c:	74 17                	je     801065 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	ff 75 10             	pushl  0x10(%ebp)
  801054:	ff 75 0c             	pushl  0xc(%ebp)
  801057:	52                   	push   %edx
  801058:	ff d0                	call   *%eax
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	eb 09                	jmp    80106a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801061:	89 c2                	mov    %eax,%edx
  801063:	eb 05                	jmp    80106a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801065:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80107d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
  801085:	eb 21                	jmp    8010a8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	89 f0                	mov    %esi,%eax
  80108c:	29 d8                	sub    %ebx,%eax
  80108e:	50                   	push   %eax
  80108f:	89 d8                	mov    %ebx,%eax
  801091:	03 45 0c             	add    0xc(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	57                   	push   %edi
  801096:	e8 45 ff ff ff       	call   800fe0 <read>
		if (m < 0)
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 10                	js     8010b2 <readn+0x41>
			return m;
		if (m == 0)
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	74 0a                	je     8010b0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a6:	01 c3                	add    %eax,%ebx
  8010a8:	39 f3                	cmp    %esi,%ebx
  8010aa:	72 db                	jb     801087 <readn+0x16>
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	eb 02                	jmp    8010b2 <readn+0x41>
  8010b0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 14             	sub    $0x14,%esp
  8010c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	53                   	push   %ebx
  8010c9:	e8 ac fc ff ff       	call   800d7a <fd_lookup>
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	89 c2                	mov    %eax,%edx
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 68                	js     80113f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e1:	ff 30                	pushl  (%eax)
  8010e3:	e8 e8 fc ff ff       	call   800dd0 <dev_lookup>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 47                	js     801136 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010f6:	75 21                	jne    801119 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010fd:	8b 40 48             	mov    0x48(%eax),%eax
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	53                   	push   %ebx
  801104:	50                   	push   %eax
  801105:	68 29 26 80 00       	push   $0x802629
  80110a:	e8 3c f0 ff ff       	call   80014b <cprintf>
		return -E_INVAL;
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801117:	eb 26                	jmp    80113f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801119:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111c:	8b 52 0c             	mov    0xc(%edx),%edx
  80111f:	85 d2                	test   %edx,%edx
  801121:	74 17                	je     80113a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	ff 75 10             	pushl  0x10(%ebp)
  801129:	ff 75 0c             	pushl  0xc(%ebp)
  80112c:	50                   	push   %eax
  80112d:	ff d2                	call   *%edx
  80112f:	89 c2                	mov    %eax,%edx
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	eb 09                	jmp    80113f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801136:	89 c2                	mov    %eax,%edx
  801138:	eb 05                	jmp    80113f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80113a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80113f:	89 d0                	mov    %edx,%eax
  801141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <seek>:

int
seek(int fdnum, off_t offset)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	ff 75 08             	pushl  0x8(%ebp)
  801153:	e8 22 fc ff ff       	call   800d7a <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 0e                	js     80116d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80115f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801162:	8b 55 0c             	mov    0xc(%ebp),%edx
  801165:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	53                   	push   %ebx
  801173:	83 ec 14             	sub    $0x14,%esp
  801176:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801179:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	53                   	push   %ebx
  80117e:	e8 f7 fb ff ff       	call   800d7a <fd_lookup>
  801183:	83 c4 08             	add    $0x8,%esp
  801186:	89 c2                	mov    %eax,%edx
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 65                	js     8011f1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	50                   	push   %eax
  801193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801196:	ff 30                	pushl  (%eax)
  801198:	e8 33 fc ff ff       	call   800dd0 <dev_lookup>
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 44                	js     8011e8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ab:	75 21                	jne    8011ce <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ad:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b2:	8b 40 48             	mov    0x48(%eax),%eax
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	53                   	push   %ebx
  8011b9:	50                   	push   %eax
  8011ba:	68 ec 25 80 00       	push   $0x8025ec
  8011bf:	e8 87 ef ff ff       	call   80014b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011cc:	eb 23                	jmp    8011f1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d1:	8b 52 18             	mov    0x18(%edx),%edx
  8011d4:	85 d2                	test   %edx,%edx
  8011d6:	74 14                	je     8011ec <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	50                   	push   %eax
  8011df:	ff d2                	call   *%edx
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 09                	jmp    8011f1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	eb 05                	jmp    8011f1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011f1:	89 d0                	mov    %edx,%eax
  8011f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 14             	sub    $0x14,%esp
  8011ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	ff 75 08             	pushl  0x8(%ebp)
  801209:	e8 6c fb ff ff       	call   800d7a <fd_lookup>
  80120e:	83 c4 08             	add    $0x8,%esp
  801211:	89 c2                	mov    %eax,%edx
  801213:	85 c0                	test   %eax,%eax
  801215:	78 58                	js     80126f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801221:	ff 30                	pushl  (%eax)
  801223:	e8 a8 fb ff ff       	call   800dd0 <dev_lookup>
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 37                	js     801266 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80122f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801232:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801236:	74 32                	je     80126a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801238:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80123b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801242:	00 00 00 
	stat->st_isdir = 0;
  801245:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80124c:	00 00 00 
	stat->st_dev = dev;
  80124f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	53                   	push   %ebx
  801259:	ff 75 f0             	pushl  -0x10(%ebp)
  80125c:	ff 50 14             	call   *0x14(%eax)
  80125f:	89 c2                	mov    %eax,%edx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	eb 09                	jmp    80126f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801266:	89 c2                	mov    %eax,%edx
  801268:	eb 05                	jmp    80126f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80126a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80126f:	89 d0                	mov    %edx,%eax
  801271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801274:	c9                   	leave  
  801275:	c3                   	ret    

00801276 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	6a 00                	push   $0x0
  801280:	ff 75 08             	pushl  0x8(%ebp)
  801283:	e8 e7 01 00 00       	call   80146f <open>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 1b                	js     8012ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801291:	83 ec 08             	sub    $0x8,%esp
  801294:	ff 75 0c             	pushl  0xc(%ebp)
  801297:	50                   	push   %eax
  801298:	e8 5b ff ff ff       	call   8011f8 <fstat>
  80129d:	89 c6                	mov    %eax,%esi
	close(fd);
  80129f:	89 1c 24             	mov    %ebx,(%esp)
  8012a2:	e8 fd fb ff ff       	call   800ea4 <close>
	return r;
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	89 f0                	mov    %esi,%eax
}
  8012ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5e                   	pop    %esi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	89 c6                	mov    %eax,%esi
  8012ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012bc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012c3:	75 12                	jne    8012d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	6a 01                	push   $0x1
  8012ca:	e8 91 0c 00 00       	call   801f60 <ipc_find_env>
  8012cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012d7:	6a 07                	push   $0x7
  8012d9:	68 00 50 80 00       	push   $0x805000
  8012de:	56                   	push   %esi
  8012df:	ff 35 00 40 80 00    	pushl  0x804000
  8012e5:	e8 22 0c 00 00       	call   801f0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012ea:	83 c4 0c             	add    $0xc,%esp
  8012ed:	6a 00                	push   $0x0
  8012ef:	53                   	push   %ebx
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 a8 0b 00 00       	call   801e9f <ipc_recv>
}
  8012f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5e                   	pop    %esi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801304:	8b 45 08             	mov    0x8(%ebp),%eax
  801307:	8b 40 0c             	mov    0xc(%eax),%eax
  80130a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80130f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801312:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801317:	ba 00 00 00 00       	mov    $0x0,%edx
  80131c:	b8 02 00 00 00       	mov    $0x2,%eax
  801321:	e8 8d ff ff ff       	call   8012b3 <fsipc>
}
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	8b 40 0c             	mov    0xc(%eax),%eax
  801334:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801339:	ba 00 00 00 00       	mov    $0x0,%edx
  80133e:	b8 06 00 00 00       	mov    $0x6,%eax
  801343:	e8 6b ff ff ff       	call   8012b3 <fsipc>
}
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
  801357:	8b 40 0c             	mov    0xc(%eax),%eax
  80135a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 05 00 00 00       	mov    $0x5,%eax
  801369:	e8 45 ff ff ff       	call   8012b3 <fsipc>
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 2c                	js     80139e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	68 00 50 80 00       	push   $0x805000
  80137a:	53                   	push   %ebx
  80137b:	e8 50 f3 ff ff       	call   8006d0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801380:	a1 80 50 80 00       	mov    0x805080,%eax
  801385:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80138b:	a1 84 50 80 00       	mov    0x805084,%eax
  801390:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8013ad:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013b2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8013b7:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013ba:	53                   	push   %ebx
  8013bb:	ff 75 0c             	pushl  0xc(%ebp)
  8013be:	68 08 50 80 00       	push   $0x805008
  8013c3:	e8 9a f4 ff ff       	call   800862 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ce:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8013d3:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8013d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013de:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e3:	e8 cb fe ff ff       	call   8012b3 <fsipc>
	//panic("devfile_write not implemented");
}
  8013e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
  8013f2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801400:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801406:	ba 00 00 00 00       	mov    $0x0,%edx
  80140b:	b8 03 00 00 00       	mov    $0x3,%eax
  801410:	e8 9e fe ff ff       	call   8012b3 <fsipc>
  801415:	89 c3                	mov    %eax,%ebx
  801417:	85 c0                	test   %eax,%eax
  801419:	78 4b                	js     801466 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80141b:	39 c6                	cmp    %eax,%esi
  80141d:	73 16                	jae    801435 <devfile_read+0x48>
  80141f:	68 5c 26 80 00       	push   $0x80265c
  801424:	68 63 26 80 00       	push   $0x802663
  801429:	6a 7c                	push   $0x7c
  80142b:	68 78 26 80 00       	push   $0x802678
  801430:	e8 24 0a 00 00       	call   801e59 <_panic>
	assert(r <= PGSIZE);
  801435:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80143a:	7e 16                	jle    801452 <devfile_read+0x65>
  80143c:	68 83 26 80 00       	push   $0x802683
  801441:	68 63 26 80 00       	push   $0x802663
  801446:	6a 7d                	push   $0x7d
  801448:	68 78 26 80 00       	push   $0x802678
  80144d:	e8 07 0a 00 00       	call   801e59 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801452:	83 ec 04             	sub    $0x4,%esp
  801455:	50                   	push   %eax
  801456:	68 00 50 80 00       	push   $0x805000
  80145b:	ff 75 0c             	pushl  0xc(%ebp)
  80145e:	e8 ff f3 ff ff       	call   800862 <memmove>
	return r;
  801463:	83 c4 10             	add    $0x10,%esp
}
  801466:	89 d8                	mov    %ebx,%eax
  801468:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 20             	sub    $0x20,%esp
  801476:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801479:	53                   	push   %ebx
  80147a:	e8 18 f2 ff ff       	call   800697 <strlen>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801487:	7f 67                	jg     8014f0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801489:	83 ec 0c             	sub    $0xc,%esp
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	e8 96 f8 ff ff       	call   800d2b <fd_alloc>
  801495:	83 c4 10             	add    $0x10,%esp
		return r;
  801498:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 57                	js     8014f5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	68 00 50 80 00       	push   $0x805000
  8014a7:	e8 24 f2 ff ff       	call   8006d0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bc:	e8 f2 fd ff ff       	call   8012b3 <fsipc>
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	79 14                	jns    8014de <open+0x6f>
		fd_close(fd, 0);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	6a 00                	push   $0x0
  8014cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d2:	e8 4c f9 ff ff       	call   800e23 <fd_close>
		return r;
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	89 da                	mov    %ebx,%edx
  8014dc:	eb 17                	jmp    8014f5 <open+0x86>
	}

	return fd2num(fd);
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e4:	e8 1b f8 ff ff       	call   800d04 <fd2num>
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb 05                	jmp    8014f5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014f0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801502:	ba 00 00 00 00       	mov    $0x0,%edx
  801507:	b8 08 00 00 00       	mov    $0x8,%eax
  80150c:	e8 a2 fd ff ff       	call   8012b3 <fsipc>
}
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801519:	68 8f 26 80 00       	push   $0x80268f
  80151e:	ff 75 0c             	pushl  0xc(%ebp)
  801521:	e8 aa f1 ff ff       	call   8006d0 <strcpy>
	return 0;
}
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 10             	sub    $0x10,%esp
  801534:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801537:	53                   	push   %ebx
  801538:	e8 5c 0a 00 00       	call   801f99 <pageref>
  80153d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801545:	83 f8 01             	cmp    $0x1,%eax
  801548:	75 10                	jne    80155a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	ff 73 0c             	pushl  0xc(%ebx)
  801550:	e8 c0 02 00 00       	call   801815 <nsipc_close>
  801555:	89 c2                	mov    %eax,%edx
  801557:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80155a:	89 d0                	mov    %edx,%eax
  80155c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801567:	6a 00                	push   $0x0
  801569:	ff 75 10             	pushl  0x10(%ebp)
  80156c:	ff 75 0c             	pushl  0xc(%ebp)
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	ff 70 0c             	pushl  0xc(%eax)
  801575:	e8 78 03 00 00       	call   8018f2 <nsipc_send>
}
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801582:	6a 00                	push   $0x0
  801584:	ff 75 10             	pushl  0x10(%ebp)
  801587:	ff 75 0c             	pushl  0xc(%ebp)
  80158a:	8b 45 08             	mov    0x8(%ebp),%eax
  80158d:	ff 70 0c             	pushl  0xc(%eax)
  801590:	e8 f1 02 00 00       	call   801886 <nsipc_recv>
}
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80159d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015a0:	52                   	push   %edx
  8015a1:	50                   	push   %eax
  8015a2:	e8 d3 f7 ff ff       	call   800d7a <fd_lookup>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 17                	js     8015c5 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015b7:	39 08                	cmp    %ecx,(%eax)
  8015b9:	75 05                	jne    8015c0 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8015bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015be:	eb 05                	jmp    8015c5 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8015c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 1c             	sub    $0x1c,%esp
  8015cf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8015d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	e8 51 f7 ff ff       	call   800d2b <fd_alloc>
  8015da:	89 c3                	mov    %eax,%ebx
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 1b                	js     8015fe <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	68 07 04 00 00       	push   $0x407
  8015eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ee:	6a 00                	push   $0x0
  8015f0:	e8 de f4 ff ff       	call   800ad3 <sys_page_alloc>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	79 10                	jns    80160e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	56                   	push   %esi
  801602:	e8 0e 02 00 00       	call   801815 <nsipc_close>
		return r;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	89 d8                	mov    %ebx,%eax
  80160c:	eb 24                	jmp    801632 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80160e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801617:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801623:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	50                   	push   %eax
  80162a:	e8 d5 f6 ff ff       	call   800d04 <fd2num>
  80162f:	83 c4 10             	add    $0x10,%esp
}
  801632:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	e8 50 ff ff ff       	call   801597 <fd2sockid>
		return r;
  801647:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 1f                	js     80166c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80164d:	83 ec 04             	sub    $0x4,%esp
  801650:	ff 75 10             	pushl  0x10(%ebp)
  801653:	ff 75 0c             	pushl  0xc(%ebp)
  801656:	50                   	push   %eax
  801657:	e8 12 01 00 00       	call   80176e <nsipc_accept>
  80165c:	83 c4 10             	add    $0x10,%esp
		return r;
  80165f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801661:	85 c0                	test   %eax,%eax
  801663:	78 07                	js     80166c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801665:	e8 5d ff ff ff       	call   8015c7 <alloc_sockfd>
  80166a:	89 c1                	mov    %eax,%ecx
}
  80166c:	89 c8                	mov    %ecx,%eax
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	e8 19 ff ff ff       	call   801597 <fd2sockid>
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 12                	js     801694 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	ff 75 10             	pushl  0x10(%ebp)
  801688:	ff 75 0c             	pushl  0xc(%ebp)
  80168b:	50                   	push   %eax
  80168c:	e8 2d 01 00 00       	call   8017be <nsipc_bind>
  801691:	83 c4 10             	add    $0x10,%esp
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <shutdown>:

int
shutdown(int s, int how)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80169c:	8b 45 08             	mov    0x8(%ebp),%eax
  80169f:	e8 f3 fe ff ff       	call   801597 <fd2sockid>
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 0f                	js     8016b7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	e8 3f 01 00 00       	call   8017f3 <nsipc_shutdown>
  8016b4:	83 c4 10             	add    $0x10,%esp
}
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	e8 d0 fe ff ff       	call   801597 <fd2sockid>
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 12                	js     8016dd <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8016cb:	83 ec 04             	sub    $0x4,%esp
  8016ce:	ff 75 10             	pushl  0x10(%ebp)
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	e8 55 01 00 00       	call   80182f <nsipc_connect>
  8016da:	83 c4 10             	add    $0x10,%esp
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <listen>:

int
listen(int s, int backlog)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e8:	e8 aa fe ff ff       	call   801597 <fd2sockid>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 0f                	js     801700 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	50                   	push   %eax
  8016f8:	e8 67 01 00 00       	call   801864 <nsipc_listen>
  8016fd:	83 c4 10             	add    $0x10,%esp
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801708:	ff 75 10             	pushl  0x10(%ebp)
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 3a 02 00 00       	call   801950 <nsipc_socket>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 05                	js     801722 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80171d:	e8 a5 fe ff ff       	call   8015c7 <alloc_sockfd>
}
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 04             	sub    $0x4,%esp
  80172b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80172d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801734:	75 12                	jne    801748 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801736:	83 ec 0c             	sub    $0xc,%esp
  801739:	6a 02                	push   $0x2
  80173b:	e8 20 08 00 00       	call   801f60 <ipc_find_env>
  801740:	a3 04 40 80 00       	mov    %eax,0x804004
  801745:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801748:	6a 07                	push   $0x7
  80174a:	68 00 60 80 00       	push   $0x806000
  80174f:	53                   	push   %ebx
  801750:	ff 35 04 40 80 00    	pushl  0x804004
  801756:	e8 b1 07 00 00       	call   801f0c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80175b:	83 c4 0c             	add    $0xc,%esp
  80175e:	6a 00                	push   $0x0
  801760:	6a 00                	push   $0x0
  801762:	6a 00                	push   $0x0
  801764:	e8 36 07 00 00       	call   801e9f <ipc_recv>
}
  801769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80177e:	8b 06                	mov    (%esi),%eax
  801780:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801785:	b8 01 00 00 00       	mov    $0x1,%eax
  80178a:	e8 95 ff ff ff       	call   801724 <nsipc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	85 c0                	test   %eax,%eax
  801793:	78 20                	js     8017b5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801795:	83 ec 04             	sub    $0x4,%esp
  801798:	ff 35 10 60 80 00    	pushl  0x806010
  80179e:	68 00 60 80 00       	push   $0x806000
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	e8 b7 f0 ff ff       	call   800862 <memmove>
		*addrlen = ret->ret_addrlen;
  8017ab:	a1 10 60 80 00       	mov    0x806010,%eax
  8017b0:	89 06                	mov    %eax,(%esi)
  8017b2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017b5:	89 d8                	mov    %ebx,%eax
  8017b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8017d0:	53                   	push   %ebx
  8017d1:	ff 75 0c             	pushl  0xc(%ebp)
  8017d4:	68 04 60 80 00       	push   $0x806004
  8017d9:	e8 84 f0 ff ff       	call   800862 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8017de:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8017e4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e9:	e8 36 ff ff ff       	call   801724 <nsipc>
}
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801809:	b8 03 00 00 00       	mov    $0x3,%eax
  80180e:	e8 11 ff ff ff       	call   801724 <nsipc>
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <nsipc_close>:

int
nsipc_close(int s)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801823:	b8 04 00 00 00       	mov    $0x4,%eax
  801828:	e8 f7 fe ff ff       	call   801724 <nsipc>
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801841:	53                   	push   %ebx
  801842:	ff 75 0c             	pushl  0xc(%ebp)
  801845:	68 04 60 80 00       	push   $0x806004
  80184a:	e8 13 f0 ff ff       	call   800862 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80184f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801855:	b8 05 00 00 00       	mov    $0x5,%eax
  80185a:	e8 c5 fe ff ff       	call   801724 <nsipc>
}
  80185f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80187a:	b8 06 00 00 00       	mov    $0x6,%eax
  80187f:	e8 a0 fe ff ff       	call   801724 <nsipc>
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801896:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80189c:	8b 45 14             	mov    0x14(%ebp),%eax
  80189f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018a4:	b8 07 00 00 00       	mov    $0x7,%eax
  8018a9:	e8 76 fe ff ff       	call   801724 <nsipc>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 35                	js     8018e9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018b4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8018b9:	7f 04                	jg     8018bf <nsipc_recv+0x39>
  8018bb:	39 c6                	cmp    %eax,%esi
  8018bd:	7d 16                	jge    8018d5 <nsipc_recv+0x4f>
  8018bf:	68 9b 26 80 00       	push   $0x80269b
  8018c4:	68 63 26 80 00       	push   $0x802663
  8018c9:	6a 62                	push   $0x62
  8018cb:	68 b0 26 80 00       	push   $0x8026b0
  8018d0:	e8 84 05 00 00       	call   801e59 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	50                   	push   %eax
  8018d9:	68 00 60 80 00       	push   $0x806000
  8018de:	ff 75 0c             	pushl  0xc(%ebp)
  8018e1:	e8 7c ef ff ff       	call   800862 <memmove>
  8018e6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8018e9:	89 d8                	mov    %ebx,%eax
  8018eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801904:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80190a:	7e 16                	jle    801922 <nsipc_send+0x30>
  80190c:	68 bc 26 80 00       	push   $0x8026bc
  801911:	68 63 26 80 00       	push   $0x802663
  801916:	6a 6d                	push   $0x6d
  801918:	68 b0 26 80 00       	push   $0x8026b0
  80191d:	e8 37 05 00 00       	call   801e59 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	53                   	push   %ebx
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	68 0c 60 80 00       	push   $0x80600c
  80192e:	e8 2f ef ff ff       	call   800862 <memmove>
	nsipcbuf.send.req_size = size;
  801933:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801939:	8b 45 14             	mov    0x14(%ebp),%eax
  80193c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801941:	b8 08 00 00 00       	mov    $0x8,%eax
  801946:	e8 d9 fd ff ff       	call   801724 <nsipc>
}
  80194b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80195e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801961:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801966:	8b 45 10             	mov    0x10(%ebp),%eax
  801969:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80196e:	b8 09 00 00 00       	mov    $0x9,%eax
  801973:	e8 ac fd ff ff       	call   801724 <nsipc>
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
  80197f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	ff 75 08             	pushl  0x8(%ebp)
  801988:	e8 87 f3 ff ff       	call   800d14 <fd2data>
  80198d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80198f:	83 c4 08             	add    $0x8,%esp
  801992:	68 c8 26 80 00       	push   $0x8026c8
  801997:	53                   	push   %ebx
  801998:	e8 33 ed ff ff       	call   8006d0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80199d:	8b 46 04             	mov    0x4(%esi),%eax
  8019a0:	2b 06                	sub    (%esi),%eax
  8019a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019af:	00 00 00 
	stat->st_dev = &devpipe;
  8019b2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019b9:	30 80 00 
	return 0;
}
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	53                   	push   %ebx
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019d2:	53                   	push   %ebx
  8019d3:	6a 00                	push   $0x0
  8019d5:	e8 7e f1 ff ff       	call   800b58 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019da:	89 1c 24             	mov    %ebx,(%esp)
  8019dd:	e8 32 f3 ff ff       	call   800d14 <fd2data>
  8019e2:	83 c4 08             	add    $0x8,%esp
  8019e5:	50                   	push   %eax
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 6b f1 ff ff       	call   800b58 <sys_page_unmap>
}
  8019ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 1c             	sub    $0x1c,%esp
  8019fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019fe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a00:	a1 08 40 80 00       	mov    0x804008,%eax
  801a05:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0e:	e8 86 05 00 00       	call   801f99 <pageref>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	89 3c 24             	mov    %edi,(%esp)
  801a18:	e8 7c 05 00 00       	call   801f99 <pageref>
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	39 c3                	cmp    %eax,%ebx
  801a22:	0f 94 c1             	sete   %cl
  801a25:	0f b6 c9             	movzbl %cl,%ecx
  801a28:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a2b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a34:	39 ce                	cmp    %ecx,%esi
  801a36:	74 1b                	je     801a53 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a38:	39 c3                	cmp    %eax,%ebx
  801a3a:	75 c4                	jne    801a00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a3c:	8b 42 58             	mov    0x58(%edx),%eax
  801a3f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a42:	50                   	push   %eax
  801a43:	56                   	push   %esi
  801a44:	68 cf 26 80 00       	push   $0x8026cf
  801a49:	e8 fd e6 ff ff       	call   80014b <cprintf>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	eb ad                	jmp    801a00 <_pipeisclosed+0xe>
	}
}
  801a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5f                   	pop    %edi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 28             	sub    $0x28,%esp
  801a67:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a6a:	56                   	push   %esi
  801a6b:	e8 a4 f2 ff ff       	call   800d14 <fd2data>
  801a70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	bf 00 00 00 00       	mov    $0x0,%edi
  801a7a:	eb 4b                	jmp    801ac7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7c:	89 da                	mov    %ebx,%edx
  801a7e:	89 f0                	mov    %esi,%eax
  801a80:	e8 6d ff ff ff       	call   8019f2 <_pipeisclosed>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	75 48                	jne    801ad1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a89:	e8 26 f0 ff ff       	call   800ab4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8e:	8b 43 04             	mov    0x4(%ebx),%eax
  801a91:	8b 0b                	mov    (%ebx),%ecx
  801a93:	8d 51 20             	lea    0x20(%ecx),%edx
  801a96:	39 d0                	cmp    %edx,%eax
  801a98:	73 e2                	jae    801a7c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aa1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa4:	89 c2                	mov    %eax,%edx
  801aa6:	c1 fa 1f             	sar    $0x1f,%edx
  801aa9:	89 d1                	mov    %edx,%ecx
  801aab:	c1 e9 1b             	shr    $0x1b,%ecx
  801aae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ab1:	83 e2 1f             	and    $0x1f,%edx
  801ab4:	29 ca                	sub    %ecx,%edx
  801ab6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801abe:	83 c0 01             	add    $0x1,%eax
  801ac1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac4:	83 c7 01             	add    $0x1,%edi
  801ac7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aca:	75 c2                	jne    801a8e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acc:	8b 45 10             	mov    0x10(%ebp),%eax
  801acf:	eb 05                	jmp    801ad6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 18             	sub    $0x18,%esp
  801ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aea:	57                   	push   %edi
  801aeb:	e8 24 f2 ff ff       	call   800d14 <fd2data>
  801af0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afa:	eb 3d                	jmp    801b39 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801afc:	85 db                	test   %ebx,%ebx
  801afe:	74 04                	je     801b04 <devpipe_read+0x26>
				return i;
  801b00:	89 d8                	mov    %ebx,%eax
  801b02:	eb 44                	jmp    801b48 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b04:	89 f2                	mov    %esi,%edx
  801b06:	89 f8                	mov    %edi,%eax
  801b08:	e8 e5 fe ff ff       	call   8019f2 <_pipeisclosed>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	75 32                	jne    801b43 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b11:	e8 9e ef ff ff       	call   800ab4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b16:	8b 06                	mov    (%esi),%eax
  801b18:	3b 46 04             	cmp    0x4(%esi),%eax
  801b1b:	74 df                	je     801afc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b1d:	99                   	cltd   
  801b1e:	c1 ea 1b             	shr    $0x1b,%edx
  801b21:	01 d0                	add    %edx,%eax
  801b23:	83 e0 1f             	and    $0x1f,%eax
  801b26:	29 d0                	sub    %edx,%eax
  801b28:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b30:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b33:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b36:	83 c3 01             	add    $0x1,%ebx
  801b39:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b3c:	75 d8                	jne    801b16 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b41:	eb 05                	jmp    801b48 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5b:	50                   	push   %eax
  801b5c:	e8 ca f1 ff ff       	call   800d2b <fd_alloc>
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	89 c2                	mov    %eax,%edx
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 88 2c 01 00 00    	js     801c9a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	68 07 04 00 00       	push   $0x407
  801b76:	ff 75 f4             	pushl  -0xc(%ebp)
  801b79:	6a 00                	push   $0x0
  801b7b:	e8 53 ef ff ff       	call   800ad3 <sys_page_alloc>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	89 c2                	mov    %eax,%edx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	0f 88 0d 01 00 00    	js     801c9a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b93:	50                   	push   %eax
  801b94:	e8 92 f1 ff ff       	call   800d2b <fd_alloc>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 e2 00 00 00    	js     801c88 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	68 07 04 00 00       	push   $0x407
  801bae:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 1b ef ff ff       	call   800ad3 <sys_page_alloc>
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 c3 00 00 00    	js     801c88 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcb:	e8 44 f1 ff ff       	call   800d14 <fd2data>
  801bd0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd2:	83 c4 0c             	add    $0xc,%esp
  801bd5:	68 07 04 00 00       	push   $0x407
  801bda:	50                   	push   %eax
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 f1 ee ff ff       	call   800ad3 <sys_page_alloc>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	0f 88 89 00 00 00    	js     801c78 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf5:	e8 1a f1 ff ff       	call   800d14 <fd2data>
  801bfa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c01:	50                   	push   %eax
  801c02:	6a 00                	push   $0x0
  801c04:	56                   	push   %esi
  801c05:	6a 00                	push   $0x0
  801c07:	e8 0a ef ff ff       	call   800b16 <sys_page_map>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	83 c4 20             	add    $0x20,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 55                	js     801c6a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c23:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c2a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c33:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f4             	pushl  -0xc(%ebp)
  801c45:	e8 ba f0 ff ff       	call   800d04 <fd2num>
  801c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c4f:	83 c4 04             	add    $0x4,%esp
  801c52:	ff 75 f0             	pushl  -0x10(%ebp)
  801c55:	e8 aa f0 ff ff       	call   800d04 <fd2num>
  801c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	ba 00 00 00 00       	mov    $0x0,%edx
  801c68:	eb 30                	jmp    801c9a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c6a:	83 ec 08             	sub    $0x8,%esp
  801c6d:	56                   	push   %esi
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 e3 ee ff ff       	call   800b58 <sys_page_unmap>
  801c75:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 d3 ee ff ff       	call   800b58 <sys_page_unmap>
  801c85:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 c3 ee ff ff       	call   800b58 <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c9a:	89 d0                	mov    %edx,%eax
  801c9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cac:	50                   	push   %eax
  801cad:	ff 75 08             	pushl  0x8(%ebp)
  801cb0:	e8 c5 f0 ff ff       	call   800d7a <fd_lookup>
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 18                	js     801cd4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc2:	e8 4d f0 ff ff       	call   800d14 <fd2data>
	return _pipeisclosed(fd, p);
  801cc7:	89 c2                	mov    %eax,%edx
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	e8 21 fd ff ff       	call   8019f2 <_pipeisclosed>
  801cd1:	83 c4 10             	add    $0x10,%esp
}
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce6:	68 e7 26 80 00       	push   $0x8026e7
  801ceb:	ff 75 0c             	pushl  0xc(%ebp)
  801cee:	e8 dd e9 ff ff       	call   8006d0 <strcpy>
	return 0;
}
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	57                   	push   %edi
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d06:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d11:	eb 2d                	jmp    801d40 <devcons_write+0x46>
		m = n - tot;
  801d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d16:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d18:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d1b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d20:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	53                   	push   %ebx
  801d27:	03 45 0c             	add    0xc(%ebp),%eax
  801d2a:	50                   	push   %eax
  801d2b:	57                   	push   %edi
  801d2c:	e8 31 eb ff ff       	call   800862 <memmove>
		sys_cputs(buf, m);
  801d31:	83 c4 08             	add    $0x8,%esp
  801d34:	53                   	push   %ebx
  801d35:	57                   	push   %edi
  801d36:	e8 dc ec ff ff       	call   800a17 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d3b:	01 de                	add    %ebx,%esi
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	89 f0                	mov    %esi,%eax
  801d42:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d45:	72 cc                	jb     801d13 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 08             	sub    $0x8,%esp
  801d55:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d5e:	74 2a                	je     801d8a <devcons_read+0x3b>
  801d60:	eb 05                	jmp    801d67 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d62:	e8 4d ed ff ff       	call   800ab4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d67:	e8 c9 ec ff ff       	call   800a35 <sys_cgetc>
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	74 f2                	je     801d62 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 16                	js     801d8a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d74:	83 f8 04             	cmp    $0x4,%eax
  801d77:	74 0c                	je     801d85 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7c:	88 02                	mov    %al,(%edx)
	return 1;
  801d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d83:	eb 05                	jmp    801d8a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d98:	6a 01                	push   $0x1
  801d9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9d:	50                   	push   %eax
  801d9e:	e8 74 ec ff ff       	call   800a17 <sys_cputs>
}
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <getchar>:

int
getchar(void)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dae:	6a 01                	push   $0x1
  801db0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	6a 00                	push   $0x0
  801db6:	e8 25 f2 ff ff       	call   800fe0 <read>
	if (r < 0)
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	78 0f                	js     801dd1 <getchar+0x29>
		return r;
	if (r < 1)
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	7e 06                	jle    801dcc <getchar+0x24>
		return -E_EOF;
	return c;
  801dc6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dca:	eb 05                	jmp    801dd1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dcc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	ff 75 08             	pushl  0x8(%ebp)
  801de0:	e8 95 ef ff ff       	call   800d7a <fd_lookup>
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 11                	js     801dfd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801def:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801df5:	39 10                	cmp    %edx,(%eax)
  801df7:	0f 94 c0             	sete   %al
  801dfa:	0f b6 c0             	movzbl %al,%eax
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <opencons>:

int
opencons(void)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e08:	50                   	push   %eax
  801e09:	e8 1d ef ff ff       	call   800d2b <fd_alloc>
  801e0e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e11:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 3e                	js     801e55 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e17:	83 ec 04             	sub    $0x4,%esp
  801e1a:	68 07 04 00 00       	push   $0x407
  801e1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e22:	6a 00                	push   $0x0
  801e24:	e8 aa ec ff ff       	call   800ad3 <sys_page_alloc>
  801e29:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 23                	js     801e55 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e32:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	50                   	push   %eax
  801e4b:	e8 b4 ee ff ff       	call   800d04 <fd2num>
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	83 c4 10             	add    $0x10,%esp
}
  801e55:	89 d0                	mov    %edx,%eax
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e5e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e61:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e67:	e8 29 ec ff ff       	call   800a95 <sys_getenvid>
  801e6c:	83 ec 0c             	sub    $0xc,%esp
  801e6f:	ff 75 0c             	pushl  0xc(%ebp)
  801e72:	ff 75 08             	pushl  0x8(%ebp)
  801e75:	56                   	push   %esi
  801e76:	50                   	push   %eax
  801e77:	68 f4 26 80 00       	push   $0x8026f4
  801e7c:	e8 ca e2 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e81:	83 c4 18             	add    $0x18,%esp
  801e84:	53                   	push   %ebx
  801e85:	ff 75 10             	pushl  0x10(%ebp)
  801e88:	e8 6d e2 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  801e8d:	c7 04 24 9c 22 80 00 	movl   $0x80229c,(%esp)
  801e94:	e8 b2 e2 ff ff       	call   80014b <cprintf>
  801e99:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e9c:	cc                   	int3   
  801e9d:	eb fd                	jmp    801e9c <_panic+0x43>

00801e9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	74 0e                	je     801ebf <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	50                   	push   %eax
  801eb5:	e8 c9 ed ff ff       	call   800c83 <sys_ipc_recv>
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	eb 10                	jmp    801ecf <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	68 00 00 00 f0       	push   $0xf0000000
  801ec7:	e8 b7 ed ff ff       	call   800c83 <sys_ipc_recv>
  801ecc:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	74 0e                	je     801ee1 <ipc_recv+0x42>
    	*from_env_store = 0;
  801ed3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801ed9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801edf:	eb 24                	jmp    801f05 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ee1:	85 f6                	test   %esi,%esi
  801ee3:	74 0a                	je     801eef <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ee5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eea:	8b 40 74             	mov    0x74(%eax),%eax
  801eed:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801eef:	85 db                	test   %ebx,%ebx
  801ef1:	74 0a                	je     801efd <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801ef3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef8:	8b 40 78             	mov    0x78(%eax),%eax
  801efb:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801efd:	a1 08 40 80 00       	mov    0x804008,%eax
  801f02:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f1e:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f25:	0f 44 d8             	cmove  %eax,%ebx
  801f28:	eb 1c                	jmp    801f46 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f2a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2d:	74 12                	je     801f41 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f2f:	50                   	push   %eax
  801f30:	68 18 27 80 00       	push   $0x802718
  801f35:	6a 4b                	push   $0x4b
  801f37:	68 30 27 80 00       	push   $0x802730
  801f3c:	e8 18 ff ff ff       	call   801e59 <_panic>
        }	
        sys_yield();
  801f41:	e8 6e eb ff ff       	call   800ab4 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f46:	ff 75 14             	pushl  0x14(%ebp)
  801f49:	53                   	push   %ebx
  801f4a:	56                   	push   %esi
  801f4b:	57                   	push   %edi
  801f4c:	e8 0f ed ff ff       	call   800c60 <sys_ipc_try_send>
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	85 c0                	test   %eax,%eax
  801f56:	75 d2                	jne    801f2a <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f74:	8b 52 50             	mov    0x50(%edx),%edx
  801f77:	39 ca                	cmp    %ecx,%edx
  801f79:	75 0d                	jne    801f88 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f83:	8b 40 48             	mov    0x48(%eax),%eax
  801f86:	eb 0f                	jmp    801f97 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f88:	83 c0 01             	add    $0x1,%eax
  801f8b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f90:	75 d9                	jne    801f6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    

00801f99 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	c1 e8 16             	shr    $0x16,%eax
  801fa4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb0:	f6 c1 01             	test   $0x1,%cl
  801fb3:	74 1d                	je     801fd2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb5:	c1 ea 0c             	shr    $0xc,%edx
  801fb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbf:	f6 c2 01             	test   $0x1,%dl
  801fc2:	74 0e                	je     801fd2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc4:	c1 ea 0c             	shr    $0xc,%edx
  801fc7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fce:	ef 
  801fcf:	0f b7 c0             	movzwl %ax,%eax
}
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	66 90                	xchg   %ax,%ax
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
