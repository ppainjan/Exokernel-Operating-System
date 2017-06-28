
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 22 80 00       	push   $0x802280
  800056:	e8 02 01 00 00       	call   80015d <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006b:	c7 05 0c 40 80 00 00 	movl   $0x0,0x80400c
  800072:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800075:	e8 2d 0a 00 00       	call   800aa7 <sys_getenvid>
  80007a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 db                	test   %ebx,%ebx
  80008e:	7e 07                	jle    800097 <libmain+0x37>
		binaryname = argv[0];
  800090:	8b 06                	mov    (%esi),%eax
  800092:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800097:	83 ec 08             	sub    $0x8,%esp
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ac:	5b                   	pop    %ebx
  8000ad:	5e                   	pop    %esi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b6:	e8 26 0e 00 00       	call   800ee1 <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 a1 09 00 00       	call   800a66 <sys_env_destroy>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	53                   	push   %ebx
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d4:	8b 13                	mov    (%ebx),%edx
  8000d6:	8d 42 01             	lea    0x1(%edx),%eax
  8000d9:	89 03                	mov    %eax,(%ebx)
  8000db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e7:	75 1a                	jne    800103 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e9:	83 ec 08             	sub    $0x8,%esp
  8000ec:	68 ff 00 00 00       	push   $0xff
  8000f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f4:	50                   	push   %eax
  8000f5:	e8 2f 09 00 00       	call   800a29 <sys_cputs>
		b->idx = 0;
  8000fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800100:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800103:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800115:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011c:	00 00 00 
	b.cnt = 0;
  80011f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800126:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800129:	ff 75 0c             	pushl  0xc(%ebp)
  80012c:	ff 75 08             	pushl  0x8(%ebp)
  80012f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800135:	50                   	push   %eax
  800136:	68 ca 00 80 00       	push   $0x8000ca
  80013b:	e8 54 01 00 00       	call   800294 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800140:	83 c4 08             	add    $0x8,%esp
  800143:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800149:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	e8 d4 08 00 00       	call   800a29 <sys_cputs>

	return b.cnt;
}
  800155:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800163:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800166:	50                   	push   %eax
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	e8 9d ff ff ff       	call   80010c <vcprintf>
	va_end(ap);

	return cnt;
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 1c             	sub    $0x1c,%esp
  80017a:	89 c7                	mov    %eax,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	8b 55 0c             	mov    0xc(%ebp),%edx
  800184:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800187:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80018d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800192:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800195:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800198:	39 d3                	cmp    %edx,%ebx
  80019a:	72 05                	jb     8001a1 <printnum+0x30>
  80019c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019f:	77 45                	ja     8001e6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a1:	83 ec 0c             	sub    $0xc,%esp
  8001a4:	ff 75 18             	pushl  0x18(%ebp)
  8001a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001aa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ad:	53                   	push   %ebx
  8001ae:	ff 75 10             	pushl  0x10(%ebp)
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c0:	e8 2b 1e 00 00       	call   801ff0 <__udivdi3>
  8001c5:	83 c4 18             	add    $0x18,%esp
  8001c8:	52                   	push   %edx
  8001c9:	50                   	push   %eax
  8001ca:	89 f2                	mov    %esi,%edx
  8001cc:	89 f8                	mov    %edi,%eax
  8001ce:	e8 9e ff ff ff       	call   800171 <printnum>
  8001d3:	83 c4 20             	add    $0x20,%esp
  8001d6:	eb 18                	jmp    8001f0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d8:	83 ec 08             	sub    $0x8,%esp
  8001db:	56                   	push   %esi
  8001dc:	ff 75 18             	pushl  0x18(%ebp)
  8001df:	ff d7                	call   *%edi
  8001e1:	83 c4 10             	add    $0x10,%esp
  8001e4:	eb 03                	jmp    8001e9 <printnum+0x78>
  8001e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e9:	83 eb 01             	sub    $0x1,%ebx
  8001ec:	85 db                	test   %ebx,%ebx
  8001ee:	7f e8                	jg     8001d8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	83 ec 04             	sub    $0x4,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 18 1f 00 00       	call   802120 <__umoddi3>
  800208:	83 c4 14             	add    $0x14,%esp
  80020b:	0f be 80 98 22 80 00 	movsbl 0x802298(%eax),%eax
  800212:	50                   	push   %eax
  800213:	ff d7                	call   *%edi
}
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800223:	83 fa 01             	cmp    $0x1,%edx
  800226:	7e 0e                	jle    800236 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	8b 52 04             	mov    0x4(%edx),%edx
  800234:	eb 22                	jmp    800258 <getuint+0x38>
	else if (lflag)
  800236:	85 d2                	test   %edx,%edx
  800238:	74 10                	je     80024a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80023a:	8b 10                	mov    (%eax),%edx
  80023c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023f:	89 08                	mov    %ecx,(%eax)
  800241:	8b 02                	mov    (%edx),%eax
  800243:	ba 00 00 00 00       	mov    $0x0,%edx
  800248:	eb 0e                	jmp    800258 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80024a:	8b 10                	mov    (%eax),%edx
  80024c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024f:	89 08                	mov    %ecx,(%eax)
  800251:	8b 02                	mov    (%edx),%eax
  800253:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800260:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800264:	8b 10                	mov    (%eax),%edx
  800266:	3b 50 04             	cmp    0x4(%eax),%edx
  800269:	73 0a                	jae    800275 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	88 02                	mov    %al,(%edx)
}
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800280:	50                   	push   %eax
  800281:	ff 75 10             	pushl  0x10(%ebp)
  800284:	ff 75 0c             	pushl  0xc(%ebp)
  800287:	ff 75 08             	pushl  0x8(%ebp)
  80028a:	e8 05 00 00 00       	call   800294 <vprintfmt>
	va_end(ap);
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 2c             	sub    $0x2c,%esp
  80029d:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a6:	eb 12                	jmp    8002ba <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	0f 84 89 03 00 00    	je     800639 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	50                   	push   %eax
  8002b5:	ff d6                	call   *%esi
  8002b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ba:	83 c7 01             	add    $0x1,%edi
  8002bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c1:	83 f8 25             	cmp    $0x25,%eax
  8002c4:	75 e2                	jne    8002a8 <vprintfmt+0x14>
  8002c6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e4:	eb 07                	jmp    8002ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8d 47 01             	lea    0x1(%edi),%eax
  8002f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f3:	0f b6 07             	movzbl (%edi),%eax
  8002f6:	0f b6 c8             	movzbl %al,%ecx
  8002f9:	83 e8 23             	sub    $0x23,%eax
  8002fc:	3c 55                	cmp    $0x55,%al
  8002fe:	0f 87 1a 03 00 00    	ja     80061e <vprintfmt+0x38a>
  800304:	0f b6 c0             	movzbl %al,%eax
  800307:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800311:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800315:	eb d6                	jmp    8002ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031a:	b8 00 00 00 00       	mov    $0x0,%eax
  80031f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800322:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800325:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800329:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80032c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80032f:	83 fa 09             	cmp    $0x9,%edx
  800332:	77 39                	ja     80036d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800334:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800337:	eb e9                	jmp    800322 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800339:	8b 45 14             	mov    0x14(%ebp),%eax
  80033c:	8d 48 04             	lea    0x4(%eax),%ecx
  80033f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800342:	8b 00                	mov    (%eax),%eax
  800344:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034a:	eb 27                	jmp    800373 <vprintfmt+0xdf>
  80034c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034f:	85 c0                	test   %eax,%eax
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
  800356:	0f 49 c8             	cmovns %eax,%ecx
  800359:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035f:	eb 8c                	jmp    8002ed <vprintfmt+0x59>
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800364:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036b:	eb 80                	jmp    8002ed <vprintfmt+0x59>
  80036d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800370:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800377:	0f 89 70 ff ff ff    	jns    8002ed <vprintfmt+0x59>
				width = precision, precision = -1;
  80037d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038a:	e9 5e ff ff ff       	jmp    8002ed <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800395:	e9 53 ff ff ff       	jmp    8002ed <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 50 04             	lea    0x4(%eax),%edx
  8003a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	53                   	push   %ebx
  8003a7:	ff 30                	pushl  (%eax)
  8003a9:	ff d6                	call   *%esi
			break;
  8003ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b1:	e9 04 ff ff ff       	jmp    8002ba <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 50 04             	lea    0x4(%eax),%edx
  8003bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 0b                	jg     8003d6 <vprintfmt+0x142>
  8003cb:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	75 18                	jne    8003ee <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003d6:	50                   	push   %eax
  8003d7:	68 b0 22 80 00       	push   $0x8022b0
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 94 fe ff ff       	call   800277 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e9:	e9 cc fe ff ff       	jmp    8002ba <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ee:	52                   	push   %edx
  8003ef:	68 75 26 80 00       	push   $0x802675
  8003f4:	53                   	push   %ebx
  8003f5:	56                   	push   %esi
  8003f6:	e8 7c fe ff ff       	call   800277 <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800401:	e9 b4 fe ff ff       	jmp    8002ba <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 50 04             	lea    0x4(%eax),%edx
  80040c:	89 55 14             	mov    %edx,0x14(%ebp)
  80040f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800411:	85 ff                	test   %edi,%edi
  800413:	b8 a9 22 80 00       	mov    $0x8022a9,%eax
  800418:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	0f 8e 94 00 00 00    	jle    8004b9 <vprintfmt+0x225>
  800425:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800429:	0f 84 98 00 00 00    	je     8004c7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	ff 75 d0             	pushl  -0x30(%ebp)
  800435:	57                   	push   %edi
  800436:	e8 86 02 00 00       	call   8006c1 <strnlen>
  80043b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043e:	29 c1                	sub    %eax,%ecx
  800440:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800443:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800446:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800450:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800452:	eb 0f                	jmp    800463 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	53                   	push   %ebx
  800458:	ff 75 e0             	pushl  -0x20(%ebp)
  80045b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	83 ef 01             	sub    $0x1,%edi
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	85 ff                	test   %edi,%edi
  800465:	7f ed                	jg     800454 <vprintfmt+0x1c0>
  800467:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046d:	85 c9                	test   %ecx,%ecx
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	0f 49 c1             	cmovns %ecx,%eax
  800477:	29 c1                	sub    %eax,%ecx
  800479:	89 75 08             	mov    %esi,0x8(%ebp)
  80047c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800482:	89 cb                	mov    %ecx,%ebx
  800484:	eb 4d                	jmp    8004d3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800486:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048a:	74 1b                	je     8004a7 <vprintfmt+0x213>
  80048c:	0f be c0             	movsbl %al,%eax
  80048f:	83 e8 20             	sub    $0x20,%eax
  800492:	83 f8 5e             	cmp    $0x5e,%eax
  800495:	76 10                	jbe    8004a7 <vprintfmt+0x213>
					putch('?', putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	ff 75 0c             	pushl  0xc(%ebp)
  80049d:	6a 3f                	push   $0x3f
  80049f:	ff 55 08             	call   *0x8(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	eb 0d                	jmp    8004b4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 0c             	pushl  0xc(%ebp)
  8004ad:	52                   	push   %edx
  8004ae:	ff 55 08             	call   *0x8(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b4:	83 eb 01             	sub    $0x1,%ebx
  8004b7:	eb 1a                	jmp    8004d3 <vprintfmt+0x23f>
  8004b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c5:	eb 0c                	jmp    8004d3 <vprintfmt+0x23f>
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d3:	83 c7 01             	add    $0x1,%edi
  8004d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004da:	0f be d0             	movsbl %al,%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	74 23                	je     800504 <vprintfmt+0x270>
  8004e1:	85 f6                	test   %esi,%esi
  8004e3:	78 a1                	js     800486 <vprintfmt+0x1f2>
  8004e5:	83 ee 01             	sub    $0x1,%esi
  8004e8:	79 9c                	jns    800486 <vprintfmt+0x1f2>
  8004ea:	89 df                	mov    %ebx,%edi
  8004ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	eb 18                	jmp    80050c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	6a 20                	push   $0x20
  8004fa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fc:	83 ef 01             	sub    $0x1,%edi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	eb 08                	jmp    80050c <vprintfmt+0x278>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	85 ff                	test   %edi,%edi
  80050e:	7f e4                	jg     8004f4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800513:	e9 a2 fd ff ff       	jmp    8002ba <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800518:	83 fa 01             	cmp    $0x1,%edx
  80051b:	7e 16                	jle    800533 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 08             	lea    0x8(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 50 04             	mov    0x4(%eax),%edx
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800531:	eb 32                	jmp    800565 <vprintfmt+0x2d1>
	else if (lflag)
  800533:	85 d2                	test   %edx,%edx
  800535:	74 18                	je     80054f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 00                	mov    (%eax),%eax
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800545:	89 c1                	mov    %eax,%ecx
  800547:	c1 f9 1f             	sar    $0x1f,%ecx
  80054a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054d:	eb 16                	jmp    800565 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 c1                	mov    %eax,%ecx
  80055f:	c1 f9 1f             	sar    $0x1f,%ecx
  800562:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800565:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800568:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800570:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800574:	79 74                	jns    8005ea <vprintfmt+0x356>
				putch('-', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	53                   	push   %ebx
  80057a:	6a 2d                	push   $0x2d
  80057c:	ff d6                	call   *%esi
				num = -(long long) num;
  80057e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800581:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800584:	f7 d8                	neg    %eax
  800586:	83 d2 00             	adc    $0x0,%edx
  800589:	f7 da                	neg    %edx
  80058b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800593:	eb 55                	jmp    8005ea <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800595:	8d 45 14             	lea    0x14(%ebp),%eax
  800598:	e8 83 fc ff ff       	call   800220 <getuint>
			base = 10;
  80059d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005a2:	eb 46                	jmp    8005ea <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a7:	e8 74 fc ff ff       	call   800220 <getuint>
		        base = 8;
  8005ac:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005b1:	eb 37                	jmp    8005ea <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	6a 30                	push   $0x30
  8005b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005bb:	83 c4 08             	add    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 78                	push   $0x78
  8005c1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005db:	eb 0d                	jmp    8005ea <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e0:	e8 3b fc ff ff       	call   800220 <getuint>
			base = 16;
  8005e5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f1:	57                   	push   %edi
  8005f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f5:	51                   	push   %ecx
  8005f6:	52                   	push   %edx
  8005f7:	50                   	push   %eax
  8005f8:	89 da                	mov    %ebx,%edx
  8005fa:	89 f0                	mov    %esi,%eax
  8005fc:	e8 70 fb ff ff       	call   800171 <printnum>
			break;
  800601:	83 c4 20             	add    $0x20,%esp
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800607:	e9 ae fc ff ff       	jmp    8002ba <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	51                   	push   %ecx
  800611:	ff d6                	call   *%esi
			break;
  800613:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800619:	e9 9c fc ff ff       	jmp    8002ba <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 25                	push   $0x25
  800624:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 03                	jmp    80062e <vprintfmt+0x39a>
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800632:	75 f7                	jne    80062b <vprintfmt+0x397>
  800634:	e9 81 fc ff ff       	jmp    8002ba <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	83 ec 18             	sub    $0x18,%esp
  800647:	8b 45 08             	mov    0x8(%ebp),%eax
  80064a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80064d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800650:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800654:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80065e:	85 c0                	test   %eax,%eax
  800660:	74 26                	je     800688 <vsnprintf+0x47>
  800662:	85 d2                	test   %edx,%edx
  800664:	7e 22                	jle    800688 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800666:	ff 75 14             	pushl  0x14(%ebp)
  800669:	ff 75 10             	pushl  0x10(%ebp)
  80066c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80066f:	50                   	push   %eax
  800670:	68 5a 02 80 00       	push   $0x80025a
  800675:	e8 1a fc ff ff       	call   800294 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb 05                	jmp    80068d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800688:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80068d:	c9                   	leave  
  80068e:	c3                   	ret    

0080068f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800698:	50                   	push   %eax
  800699:	ff 75 10             	pushl  0x10(%ebp)
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	e8 9a ff ff ff       	call   800641 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006af:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b4:	eb 03                	jmp    8006b9 <strlen+0x10>
		n++;
  8006b6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006bd:	75 f7                	jne    8006b6 <strlen+0xd>
		n++;
	return n;
}
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    

008006c1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8006cf:	eb 03                	jmp    8006d4 <strnlen+0x13>
		n++;
  8006d1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d4:	39 c2                	cmp    %eax,%edx
  8006d6:	74 08                	je     8006e0 <strnlen+0x1f>
  8006d8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006dc:	75 f3                	jne    8006d1 <strnlen+0x10>
  8006de:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	53                   	push   %ebx
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ec:	89 c2                	mov    %eax,%edx
  8006ee:	83 c2 01             	add    $0x1,%edx
  8006f1:	83 c1 01             	add    $0x1,%ecx
  8006f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006fb:	84 db                	test   %bl,%bl
  8006fd:	75 ef                	jne    8006ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ff:	5b                   	pop    %ebx
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	53                   	push   %ebx
  800706:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800709:	53                   	push   %ebx
  80070a:	e8 9a ff ff ff       	call   8006a9 <strlen>
  80070f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	01 d8                	add    %ebx,%eax
  800717:	50                   	push   %eax
  800718:	e8 c5 ff ff ff       	call   8006e2 <strcpy>
	return dst;
}
  80071d:	89 d8                	mov    %ebx,%eax
  80071f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	56                   	push   %esi
  800728:	53                   	push   %ebx
  800729:	8b 75 08             	mov    0x8(%ebp),%esi
  80072c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072f:	89 f3                	mov    %esi,%ebx
  800731:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800734:	89 f2                	mov    %esi,%edx
  800736:	eb 0f                	jmp    800747 <strncpy+0x23>
		*dst++ = *src;
  800738:	83 c2 01             	add    $0x1,%edx
  80073b:	0f b6 01             	movzbl (%ecx),%eax
  80073e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800741:	80 39 01             	cmpb   $0x1,(%ecx)
  800744:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800747:	39 da                	cmp    %ebx,%edx
  800749:	75 ed                	jne    800738 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80074b:	89 f0                	mov    %esi,%eax
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	56                   	push   %esi
  800755:	53                   	push   %ebx
  800756:	8b 75 08             	mov    0x8(%ebp),%esi
  800759:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075c:	8b 55 10             	mov    0x10(%ebp),%edx
  80075f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800761:	85 d2                	test   %edx,%edx
  800763:	74 21                	je     800786 <strlcpy+0x35>
  800765:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800769:	89 f2                	mov    %esi,%edx
  80076b:	eb 09                	jmp    800776 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80076d:	83 c2 01             	add    $0x1,%edx
  800770:	83 c1 01             	add    $0x1,%ecx
  800773:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800776:	39 c2                	cmp    %eax,%edx
  800778:	74 09                	je     800783 <strlcpy+0x32>
  80077a:	0f b6 19             	movzbl (%ecx),%ebx
  80077d:	84 db                	test   %bl,%bl
  80077f:	75 ec                	jne    80076d <strlcpy+0x1c>
  800781:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800783:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800786:	29 f0                	sub    %esi,%eax
}
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800795:	eb 06                	jmp    80079d <strcmp+0x11>
		p++, q++;
  800797:	83 c1 01             	add    $0x1,%ecx
  80079a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80079d:	0f b6 01             	movzbl (%ecx),%eax
  8007a0:	84 c0                	test   %al,%al
  8007a2:	74 04                	je     8007a8 <strcmp+0x1c>
  8007a4:	3a 02                	cmp    (%edx),%al
  8007a6:	74 ef                	je     800797 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a8:	0f b6 c0             	movzbl %al,%eax
  8007ab:	0f b6 12             	movzbl (%edx),%edx
  8007ae:	29 d0                	sub    %edx,%eax
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 c3                	mov    %eax,%ebx
  8007be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c1:	eb 06                	jmp    8007c9 <strncmp+0x17>
		n--, p++, q++;
  8007c3:	83 c0 01             	add    $0x1,%eax
  8007c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007c9:	39 d8                	cmp    %ebx,%eax
  8007cb:	74 15                	je     8007e2 <strncmp+0x30>
  8007cd:	0f b6 08             	movzbl (%eax),%ecx
  8007d0:	84 c9                	test   %cl,%cl
  8007d2:	74 04                	je     8007d8 <strncmp+0x26>
  8007d4:	3a 0a                	cmp    (%edx),%cl
  8007d6:	74 eb                	je     8007c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 00             	movzbl (%eax),%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
  8007e0:	eb 05                	jmp    8007e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f4:	eb 07                	jmp    8007fd <strchr+0x13>
		if (*s == c)
  8007f6:	38 ca                	cmp    %cl,%dl
  8007f8:	74 0f                	je     800809 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	0f b6 10             	movzbl (%eax),%edx
  800800:	84 d2                	test   %dl,%dl
  800802:	75 f2                	jne    8007f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800815:	eb 03                	jmp    80081a <strfind+0xf>
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80081d:	38 ca                	cmp    %cl,%dl
  80081f:	74 04                	je     800825 <strfind+0x1a>
  800821:	84 d2                	test   %dl,%dl
  800823:	75 f2                	jne    800817 <strfind+0xc>
			break;
	return (char *) s;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	57                   	push   %edi
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800830:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800833:	85 c9                	test   %ecx,%ecx
  800835:	74 36                	je     80086d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800837:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80083d:	75 28                	jne    800867 <memset+0x40>
  80083f:	f6 c1 03             	test   $0x3,%cl
  800842:	75 23                	jne    800867 <memset+0x40>
		c &= 0xFF;
  800844:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800848:	89 d3                	mov    %edx,%ebx
  80084a:	c1 e3 08             	shl    $0x8,%ebx
  80084d:	89 d6                	mov    %edx,%esi
  80084f:	c1 e6 18             	shl    $0x18,%esi
  800852:	89 d0                	mov    %edx,%eax
  800854:	c1 e0 10             	shl    $0x10,%eax
  800857:	09 f0                	or     %esi,%eax
  800859:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	09 d0                	or     %edx,%eax
  80085f:	c1 e9 02             	shr    $0x2,%ecx
  800862:	fc                   	cld    
  800863:	f3 ab                	rep stos %eax,%es:(%edi)
  800865:	eb 06                	jmp    80086d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086a:	fc                   	cld    
  80086b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80086d:	89 f8                	mov    %edi,%eax
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5f                   	pop    %edi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80087f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800882:	39 c6                	cmp    %eax,%esi
  800884:	73 35                	jae    8008bb <memmove+0x47>
  800886:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800889:	39 d0                	cmp    %edx,%eax
  80088b:	73 2e                	jae    8008bb <memmove+0x47>
		s += n;
		d += n;
  80088d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800890:	89 d6                	mov    %edx,%esi
  800892:	09 fe                	or     %edi,%esi
  800894:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089a:	75 13                	jne    8008af <memmove+0x3b>
  80089c:	f6 c1 03             	test   $0x3,%cl
  80089f:	75 0e                	jne    8008af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a1:	83 ef 04             	sub    $0x4,%edi
  8008a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008a7:	c1 e9 02             	shr    $0x2,%ecx
  8008aa:	fd                   	std    
  8008ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ad:	eb 09                	jmp    8008b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008af:	83 ef 01             	sub    $0x1,%edi
  8008b2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b5:	fd                   	std    
  8008b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008b8:	fc                   	cld    
  8008b9:	eb 1d                	jmp    8008d8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bb:	89 f2                	mov    %esi,%edx
  8008bd:	09 c2                	or     %eax,%edx
  8008bf:	f6 c2 03             	test   $0x3,%dl
  8008c2:	75 0f                	jne    8008d3 <memmove+0x5f>
  8008c4:	f6 c1 03             	test   $0x3,%cl
  8008c7:	75 0a                	jne    8008d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008c9:	c1 e9 02             	shr    $0x2,%ecx
  8008cc:	89 c7                	mov    %eax,%edi
  8008ce:	fc                   	cld    
  8008cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d1:	eb 05                	jmp    8008d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d3:	89 c7                	mov    %eax,%edi
  8008d5:	fc                   	cld    
  8008d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008d8:	5e                   	pop    %esi
  8008d9:	5f                   	pop    %edi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008df:	ff 75 10             	pushl  0x10(%ebp)
  8008e2:	ff 75 0c             	pushl  0xc(%ebp)
  8008e5:	ff 75 08             	pushl  0x8(%ebp)
  8008e8:	e8 87 ff ff ff       	call   800874 <memmove>
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ff:	eb 1a                	jmp    80091b <memcmp+0x2c>
		if (*s1 != *s2)
  800901:	0f b6 08             	movzbl (%eax),%ecx
  800904:	0f b6 1a             	movzbl (%edx),%ebx
  800907:	38 d9                	cmp    %bl,%cl
  800909:	74 0a                	je     800915 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80090b:	0f b6 c1             	movzbl %cl,%eax
  80090e:	0f b6 db             	movzbl %bl,%ebx
  800911:	29 d8                	sub    %ebx,%eax
  800913:	eb 0f                	jmp    800924 <memcmp+0x35>
		s1++, s2++;
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091b:	39 f0                	cmp    %esi,%eax
  80091d:	75 e2                	jne    800901 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	53                   	push   %ebx
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80092f:	89 c1                	mov    %eax,%ecx
  800931:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800934:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800938:	eb 0a                	jmp    800944 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80093a:	0f b6 10             	movzbl (%eax),%edx
  80093d:	39 da                	cmp    %ebx,%edx
  80093f:	74 07                	je     800948 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800941:	83 c0 01             	add    $0x1,%eax
  800944:	39 c8                	cmp    %ecx,%eax
  800946:	72 f2                	jb     80093a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800954:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800957:	eb 03                	jmp    80095c <strtol+0x11>
		s++;
  800959:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095c:	0f b6 01             	movzbl (%ecx),%eax
  80095f:	3c 20                	cmp    $0x20,%al
  800961:	74 f6                	je     800959 <strtol+0xe>
  800963:	3c 09                	cmp    $0x9,%al
  800965:	74 f2                	je     800959 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800967:	3c 2b                	cmp    $0x2b,%al
  800969:	75 0a                	jne    800975 <strtol+0x2a>
		s++;
  80096b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80096e:	bf 00 00 00 00       	mov    $0x0,%edi
  800973:	eb 11                	jmp    800986 <strtol+0x3b>
  800975:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097a:	3c 2d                	cmp    $0x2d,%al
  80097c:	75 08                	jne    800986 <strtol+0x3b>
		s++, neg = 1;
  80097e:	83 c1 01             	add    $0x1,%ecx
  800981:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800986:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80098c:	75 15                	jne    8009a3 <strtol+0x58>
  80098e:	80 39 30             	cmpb   $0x30,(%ecx)
  800991:	75 10                	jne    8009a3 <strtol+0x58>
  800993:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800997:	75 7c                	jne    800a15 <strtol+0xca>
		s += 2, base = 16;
  800999:	83 c1 02             	add    $0x2,%ecx
  80099c:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a1:	eb 16                	jmp    8009b9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a3:	85 db                	test   %ebx,%ebx
  8009a5:	75 12                	jne    8009b9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ac:	80 39 30             	cmpb   $0x30,(%ecx)
  8009af:	75 08                	jne    8009b9 <strtol+0x6e>
		s++, base = 8;
  8009b1:	83 c1 01             	add    $0x1,%ecx
  8009b4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009be:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c1:	0f b6 11             	movzbl (%ecx),%edx
  8009c4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009c7:	89 f3                	mov    %esi,%ebx
  8009c9:	80 fb 09             	cmp    $0x9,%bl
  8009cc:	77 08                	ja     8009d6 <strtol+0x8b>
			dig = *s - '0';
  8009ce:	0f be d2             	movsbl %dl,%edx
  8009d1:	83 ea 30             	sub    $0x30,%edx
  8009d4:	eb 22                	jmp    8009f8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009d6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009d9:	89 f3                	mov    %esi,%ebx
  8009db:	80 fb 19             	cmp    $0x19,%bl
  8009de:	77 08                	ja     8009e8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e0:	0f be d2             	movsbl %dl,%edx
  8009e3:	83 ea 57             	sub    $0x57,%edx
  8009e6:	eb 10                	jmp    8009f8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009e8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009eb:	89 f3                	mov    %esi,%ebx
  8009ed:	80 fb 19             	cmp    $0x19,%bl
  8009f0:	77 16                	ja     800a08 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f2:	0f be d2             	movsbl %dl,%edx
  8009f5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009f8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009fb:	7d 0b                	jge    800a08 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a04:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a06:	eb b9                	jmp    8009c1 <strtol+0x76>

	if (endptr)
  800a08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0c:	74 0d                	je     800a1b <strtol+0xd0>
		*endptr = (char *) s;
  800a0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a11:	89 0e                	mov    %ecx,(%esi)
  800a13:	eb 06                	jmp    800a1b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	74 98                	je     8009b1 <strtol+0x66>
  800a19:	eb 9e                	jmp    8009b9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a1b:	89 c2                	mov    %eax,%edx
  800a1d:	f7 da                	neg    %edx
  800a1f:	85 ff                	test   %edi,%edi
  800a21:	0f 45 c2             	cmovne %edx,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3a:	89 c3                	mov    %eax,%ebx
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	89 c6                	mov    %eax,%esi
  800a40:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 01 00 00 00       	mov    $0x1,%eax
  800a57:	89 d1                	mov    %edx,%ecx
  800a59:	89 d3                	mov    %edx,%ebx
  800a5b:	89 d7                	mov    %edx,%edi
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a74:	b8 03 00 00 00       	mov    $0x3,%eax
  800a79:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7c:	89 cb                	mov    %ecx,%ebx
  800a7e:	89 cf                	mov    %ecx,%edi
  800a80:	89 ce                	mov    %ecx,%esi
  800a82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a84:	85 c0                	test   %eax,%eax
  800a86:	7e 17                	jle    800a9f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	50                   	push   %eax
  800a8c:	6a 03                	push   $0x3
  800a8e:	68 9f 25 80 00       	push   $0x80259f
  800a93:	6a 23                	push   $0x23
  800a95:	68 bc 25 80 00       	push   $0x8025bc
  800a9a:	e8 cc 13 00 00       	call   801e6b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ab7:	89 d1                	mov    %edx,%ecx
  800ab9:	89 d3                	mov    %edx,%ebx
  800abb:	89 d7                	mov    %edx,%edi
  800abd:	89 d6                	mov    %edx,%esi
  800abf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_yield>:

void
sys_yield(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	be 00 00 00 00       	mov    $0x0,%esi
  800af3:	b8 04 00 00 00       	mov    $0x4,%eax
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b01:	89 f7                	mov    %esi,%edi
  800b03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b05:	85 c0                	test   %eax,%eax
  800b07:	7e 17                	jle    800b20 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	50                   	push   %eax
  800b0d:	6a 04                	push   $0x4
  800b0f:	68 9f 25 80 00       	push   $0x80259f
  800b14:	6a 23                	push   $0x23
  800b16:	68 bc 25 80 00       	push   $0x8025bc
  800b1b:	e8 4b 13 00 00       	call   801e6b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	b8 05 00 00 00       	mov    $0x5,%eax
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b42:	8b 75 18             	mov    0x18(%ebp),%esi
  800b45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7e 17                	jle    800b62 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	50                   	push   %eax
  800b4f:	6a 05                	push   $0x5
  800b51:	68 9f 25 80 00       	push   $0x80259f
  800b56:	6a 23                	push   $0x23
  800b58:	68 bc 25 80 00       	push   $0x8025bc
  800b5d:	e8 09 13 00 00       	call   801e6b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b78:	b8 06 00 00 00       	mov    $0x6,%eax
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	89 df                	mov    %ebx,%edi
  800b85:	89 de                	mov    %ebx,%esi
  800b87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	7e 17                	jle    800ba4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	50                   	push   %eax
  800b91:	6a 06                	push   $0x6
  800b93:	68 9f 25 80 00       	push   $0x80259f
  800b98:	6a 23                	push   $0x23
  800b9a:	68 bc 25 80 00       	push   $0x8025bc
  800b9f:	e8 c7 12 00 00       	call   801e6b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bba:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	89 df                	mov    %ebx,%edi
  800bc7:	89 de                	mov    %ebx,%esi
  800bc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 17                	jle    800be6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	50                   	push   %eax
  800bd3:	6a 08                	push   $0x8
  800bd5:	68 9f 25 80 00       	push   $0x80259f
  800bda:	6a 23                	push   $0x23
  800bdc:	68 bc 25 80 00       	push   $0x8025bc
  800be1:	e8 85 12 00 00       	call   801e6b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 df                	mov    %ebx,%edi
  800c09:	89 de                	mov    %ebx,%esi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 17                	jle    800c28 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 09                	push   $0x9
  800c17:	68 9f 25 80 00       	push   $0x80259f
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 bc 25 80 00       	push   $0x8025bc
  800c23:	e8 43 12 00 00       	call   801e6b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 df                	mov    %ebx,%edi
  800c4b:	89 de                	mov    %ebx,%esi
  800c4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 0a                	push   $0xa
  800c59:	68 9f 25 80 00       	push   $0x80259f
  800c5e:	6a 23                	push   $0x23
  800c60:	68 bc 25 80 00       	push   $0x8025bc
  800c65:	e8 01 12 00 00       	call   801e6b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	be 00 00 00 00       	mov    $0x0,%esi
  800c7d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	89 cb                	mov    %ecx,%ebx
  800cad:	89 cf                	mov    %ecx,%edi
  800caf:	89 ce                	mov    %ecx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 0d                	push   $0xd
  800cbd:	68 9f 25 80 00       	push   $0x80259f
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 bc 25 80 00       	push   $0x8025bc
  800cc9:	e8 9d 11 00 00       	call   801e6b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ce6:	89 d1                	mov    %edx,%ecx
  800ce8:	89 d3                	mov    %edx,%ebx
  800cea:	89 d7                	mov    %edx,%edi
  800cec:	89 d6                	mov    %edx,%esi
  800cee:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d21:	c1 e8 0c             	shr    $0xc,%eax
}
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d36:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d43:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d48:	89 c2                	mov    %eax,%edx
  800d4a:	c1 ea 16             	shr    $0x16,%edx
  800d4d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d54:	f6 c2 01             	test   $0x1,%dl
  800d57:	74 11                	je     800d6a <fd_alloc+0x2d>
  800d59:	89 c2                	mov    %eax,%edx
  800d5b:	c1 ea 0c             	shr    $0xc,%edx
  800d5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d65:	f6 c2 01             	test   $0x1,%dl
  800d68:	75 09                	jne    800d73 <fd_alloc+0x36>
			*fd_store = fd;
  800d6a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	eb 17                	jmp    800d8a <fd_alloc+0x4d>
  800d73:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d78:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d7d:	75 c9                	jne    800d48 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d7f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d85:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d92:	83 f8 1f             	cmp    $0x1f,%eax
  800d95:	77 36                	ja     800dcd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d97:	c1 e0 0c             	shl    $0xc,%eax
  800d9a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	c1 ea 16             	shr    $0x16,%edx
  800da4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dab:	f6 c2 01             	test   $0x1,%dl
  800dae:	74 24                	je     800dd4 <fd_lookup+0x48>
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	c1 ea 0c             	shr    $0xc,%edx
  800db5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbc:	f6 c2 01             	test   $0x1,%dl
  800dbf:	74 1a                	je     800ddb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc4:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	eb 13                	jmp    800de0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd2:	eb 0c                	jmp    800de0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd9:	eb 05                	jmp    800de0 <fd_lookup+0x54>
  800ddb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	ba 48 26 80 00       	mov    $0x802648,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800df0:	eb 13                	jmp    800e05 <dev_lookup+0x23>
  800df2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800df5:	39 08                	cmp    %ecx,(%eax)
  800df7:	75 0c                	jne    800e05 <dev_lookup+0x23>
			*dev = devtab[i];
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800e03:	eb 2e                	jmp    800e33 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e05:	8b 02                	mov    (%edx),%eax
  800e07:	85 c0                	test   %eax,%eax
  800e09:	75 e7                	jne    800df2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e0b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800e10:	8b 40 48             	mov    0x48(%eax),%eax
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	51                   	push   %ecx
  800e17:	50                   	push   %eax
  800e18:	68 cc 25 80 00       	push   $0x8025cc
  800e1d:	e8 3b f3 ff ff       	call   80015d <cprintf>
	*dev = 0;
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 10             	sub    $0x10,%esp
  800e3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e46:	50                   	push   %eax
  800e47:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e4d:	c1 e8 0c             	shr    $0xc,%eax
  800e50:	50                   	push   %eax
  800e51:	e8 36 ff ff ff       	call   800d8c <fd_lookup>
  800e56:	83 c4 08             	add    $0x8,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 05                	js     800e62 <fd_close+0x2d>
	    || fd != fd2)
  800e5d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e60:	74 0c                	je     800e6e <fd_close+0x39>
		return (must_exist ? r : 0);
  800e62:	84 db                	test   %bl,%bl
  800e64:	ba 00 00 00 00       	mov    $0x0,%edx
  800e69:	0f 44 c2             	cmove  %edx,%eax
  800e6c:	eb 41                	jmp    800eaf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e6e:	83 ec 08             	sub    $0x8,%esp
  800e71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e74:	50                   	push   %eax
  800e75:	ff 36                	pushl  (%esi)
  800e77:	e8 66 ff ff ff       	call   800de2 <dev_lookup>
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 1a                	js     800e9f <fd_close+0x6a>
		if (dev->dev_close)
  800e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e88:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	74 0b                	je     800e9f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	56                   	push   %esi
  800e98:	ff d0                	call   *%eax
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	56                   	push   %esi
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 c0 fc ff ff       	call   800b6a <sys_page_unmap>
	return r;
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	89 d8                	mov    %ebx,%eax
}
  800eaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebf:	50                   	push   %eax
  800ec0:	ff 75 08             	pushl  0x8(%ebp)
  800ec3:	e8 c4 fe ff ff       	call   800d8c <fd_lookup>
  800ec8:	83 c4 08             	add    $0x8,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	78 10                	js     800edf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	6a 01                	push   $0x1
  800ed4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed7:	e8 59 ff ff ff       	call   800e35 <fd_close>
  800edc:	83 c4 10             	add    $0x10,%esp
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <close_all>:

void
close_all(void)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	53                   	push   %ebx
  800ef1:	e8 c0 ff ff ff       	call   800eb6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef6:	83 c3 01             	add    $0x1,%ebx
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	83 fb 20             	cmp    $0x20,%ebx
  800eff:	75 ec                	jne    800eed <close_all+0xc>
		close(i);
}
  800f01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 2c             	sub    $0x2c,%esp
  800f0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f15:	50                   	push   %eax
  800f16:	ff 75 08             	pushl  0x8(%ebp)
  800f19:	e8 6e fe ff ff       	call   800d8c <fd_lookup>
  800f1e:	83 c4 08             	add    $0x8,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	0f 88 c1 00 00 00    	js     800fea <dup+0xe4>
		return r;
	close(newfdnum);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	56                   	push   %esi
  800f2d:	e8 84 ff ff ff       	call   800eb6 <close>

	newfd = INDEX2FD(newfdnum);
  800f32:	89 f3                	mov    %esi,%ebx
  800f34:	c1 e3 0c             	shl    $0xc,%ebx
  800f37:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f3d:	83 c4 04             	add    $0x4,%esp
  800f40:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f43:	e8 de fd ff ff       	call   800d26 <fd2data>
  800f48:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f4a:	89 1c 24             	mov    %ebx,(%esp)
  800f4d:	e8 d4 fd ff ff       	call   800d26 <fd2data>
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f58:	89 f8                	mov    %edi,%eax
  800f5a:	c1 e8 16             	shr    $0x16,%eax
  800f5d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f64:	a8 01                	test   $0x1,%al
  800f66:	74 37                	je     800f9f <dup+0x99>
  800f68:	89 f8                	mov    %edi,%eax
  800f6a:	c1 e8 0c             	shr    $0xc,%eax
  800f6d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f74:	f6 c2 01             	test   $0x1,%dl
  800f77:	74 26                	je     800f9f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	25 07 0e 00 00       	and    $0xe07,%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f8c:	6a 00                	push   $0x0
  800f8e:	57                   	push   %edi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 92 fb ff ff       	call   800b28 <sys_page_map>
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 2e                	js     800fcd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fa2:	89 d0                	mov    %edx,%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb6:	50                   	push   %eax
  800fb7:	53                   	push   %ebx
  800fb8:	6a 00                	push   $0x0
  800fba:	52                   	push   %edx
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 66 fb ff ff       	call   800b28 <sys_page_map>
  800fc2:	89 c7                	mov    %eax,%edi
  800fc4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc9:	85 ff                	test   %edi,%edi
  800fcb:	79 1d                	jns    800fea <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	53                   	push   %ebx
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 92 fb ff ff       	call   800b6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 85 fb ff ff       	call   800b6a <sys_page_unmap>
	return r;
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	89 f8                	mov    %edi,%eax
}
  800fea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 14             	sub    $0x14,%esp
  800ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	53                   	push   %ebx
  801001:	e8 86 fd ff ff       	call   800d8c <fd_lookup>
  801006:	83 c4 08             	add    $0x8,%esp
  801009:	89 c2                	mov    %eax,%edx
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 6d                	js     80107c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801015:	50                   	push   %eax
  801016:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801019:	ff 30                	pushl  (%eax)
  80101b:	e8 c2 fd ff ff       	call   800de2 <dev_lookup>
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	78 4c                	js     801073 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801027:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80102a:	8b 42 08             	mov    0x8(%edx),%eax
  80102d:	83 e0 03             	and    $0x3,%eax
  801030:	83 f8 01             	cmp    $0x1,%eax
  801033:	75 21                	jne    801056 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801035:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80103a:	8b 40 48             	mov    0x48(%eax),%eax
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	53                   	push   %ebx
  801041:	50                   	push   %eax
  801042:	68 0d 26 80 00       	push   $0x80260d
  801047:	e8 11 f1 ff ff       	call   80015d <cprintf>
		return -E_INVAL;
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801054:	eb 26                	jmp    80107c <read+0x8a>
	}
	if (!dev->dev_read)
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	8b 40 08             	mov    0x8(%eax),%eax
  80105c:	85 c0                	test   %eax,%eax
  80105e:	74 17                	je     801077 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	ff 75 10             	pushl  0x10(%ebp)
  801066:	ff 75 0c             	pushl  0xc(%ebp)
  801069:	52                   	push   %edx
  80106a:	ff d0                	call   *%eax
  80106c:	89 c2                	mov    %eax,%edx
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	eb 09                	jmp    80107c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801073:	89 c2                	mov    %eax,%edx
  801075:	eb 05                	jmp    80107c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801077:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80107c:	89 d0                	mov    %edx,%eax
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	eb 21                	jmp    8010ba <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	89 f0                	mov    %esi,%eax
  80109e:	29 d8                	sub    %ebx,%eax
  8010a0:	50                   	push   %eax
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	03 45 0c             	add    0xc(%ebp),%eax
  8010a6:	50                   	push   %eax
  8010a7:	57                   	push   %edi
  8010a8:	e8 45 ff ff ff       	call   800ff2 <read>
		if (m < 0)
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 10                	js     8010c4 <readn+0x41>
			return m;
		if (m == 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 0a                	je     8010c2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b8:	01 c3                	add    %eax,%ebx
  8010ba:	39 f3                	cmp    %esi,%ebx
  8010bc:	72 db                	jb     801099 <readn+0x16>
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	eb 02                	jmp    8010c4 <readn+0x41>
  8010c2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 14             	sub    $0x14,%esp
  8010d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	53                   	push   %ebx
  8010db:	e8 ac fc ff ff       	call   800d8c <fd_lookup>
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	89 c2                	mov    %eax,%edx
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 68                	js     801151 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f3:	ff 30                	pushl  (%eax)
  8010f5:	e8 e8 fc ff ff       	call   800de2 <dev_lookup>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 47                	js     801148 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801101:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801104:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801108:	75 21                	jne    80112b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80110a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80110f:	8b 40 48             	mov    0x48(%eax),%eax
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	53                   	push   %ebx
  801116:	50                   	push   %eax
  801117:	68 29 26 80 00       	push   $0x802629
  80111c:	e8 3c f0 ff ff       	call   80015d <cprintf>
		return -E_INVAL;
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801129:	eb 26                	jmp    801151 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80112b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112e:	8b 52 0c             	mov    0xc(%edx),%edx
  801131:	85 d2                	test   %edx,%edx
  801133:	74 17                	je     80114c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	ff 75 10             	pushl  0x10(%ebp)
  80113b:	ff 75 0c             	pushl  0xc(%ebp)
  80113e:	50                   	push   %eax
  80113f:	ff d2                	call   *%edx
  801141:	89 c2                	mov    %eax,%edx
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	eb 09                	jmp    801151 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801148:	89 c2                	mov    %eax,%edx
  80114a:	eb 05                	jmp    801151 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80114c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801151:	89 d0                	mov    %edx,%eax
  801153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <seek>:

int
seek(int fdnum, off_t offset)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	e8 22 fc ff ff       	call   800d8c <fd_lookup>
  80116a:	83 c4 08             	add    $0x8,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 0e                	js     80117f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801171:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	53                   	push   %ebx
  801185:	83 ec 14             	sub    $0x14,%esp
  801188:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	53                   	push   %ebx
  801190:	e8 f7 fb ff ff       	call   800d8c <fd_lookup>
  801195:	83 c4 08             	add    $0x8,%esp
  801198:	89 c2                	mov    %eax,%edx
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 65                	js     801203 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a8:	ff 30                	pushl  (%eax)
  8011aa:	e8 33 fc ff ff       	call   800de2 <dev_lookup>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 44                	js     8011fa <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bd:	75 21                	jne    8011e0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011bf:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	53                   	push   %ebx
  8011cb:	50                   	push   %eax
  8011cc:	68 ec 25 80 00       	push   $0x8025ec
  8011d1:	e8 87 ef ff ff       	call   80015d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011de:	eb 23                	jmp    801203 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e3:	8b 52 18             	mov    0x18(%edx),%edx
  8011e6:	85 d2                	test   %edx,%edx
  8011e8:	74 14                	je     8011fe <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	ff 75 0c             	pushl  0xc(%ebp)
  8011f0:	50                   	push   %eax
  8011f1:	ff d2                	call   *%edx
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	eb 09                	jmp    801203 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	eb 05                	jmp    801203 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801203:	89 d0                	mov    %edx,%eax
  801205:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 14             	sub    $0x14,%esp
  801211:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801214:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	ff 75 08             	pushl  0x8(%ebp)
  80121b:	e8 6c fb ff ff       	call   800d8c <fd_lookup>
  801220:	83 c4 08             	add    $0x8,%esp
  801223:	89 c2                	mov    %eax,%edx
  801225:	85 c0                	test   %eax,%eax
  801227:	78 58                	js     801281 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801233:	ff 30                	pushl  (%eax)
  801235:	e8 a8 fb ff ff       	call   800de2 <dev_lookup>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 37                	js     801278 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801244:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801248:	74 32                	je     80127c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80124a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80124d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801254:	00 00 00 
	stat->st_isdir = 0;
  801257:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80125e:	00 00 00 
	stat->st_dev = dev;
  801261:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	53                   	push   %ebx
  80126b:	ff 75 f0             	pushl  -0x10(%ebp)
  80126e:	ff 50 14             	call   *0x14(%eax)
  801271:	89 c2                	mov    %eax,%edx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	eb 09                	jmp    801281 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801278:	89 c2                	mov    %eax,%edx
  80127a:	eb 05                	jmp    801281 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80127c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801281:	89 d0                	mov    %edx,%eax
  801283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	6a 00                	push   $0x0
  801292:	ff 75 08             	pushl  0x8(%ebp)
  801295:	e8 e7 01 00 00       	call   801481 <open>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 1b                	js     8012be <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	ff 75 0c             	pushl  0xc(%ebp)
  8012a9:	50                   	push   %eax
  8012aa:	e8 5b ff ff ff       	call   80120a <fstat>
  8012af:	89 c6                	mov    %eax,%esi
	close(fd);
  8012b1:	89 1c 24             	mov    %ebx,(%esp)
  8012b4:	e8 fd fb ff ff       	call   800eb6 <close>
	return r;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	89 f0                	mov    %esi,%eax
}
  8012be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	89 c6                	mov    %eax,%esi
  8012cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012ce:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d5:	75 12                	jne    8012e9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	6a 01                	push   $0x1
  8012dc:	e8 91 0c 00 00       	call   801f72 <ipc_find_env>
  8012e1:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e9:	6a 07                	push   $0x7
  8012eb:	68 00 50 80 00       	push   $0x805000
  8012f0:	56                   	push   %esi
  8012f1:	ff 35 00 40 80 00    	pushl  0x804000
  8012f7:	e8 22 0c 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012fc:	83 c4 0c             	add    $0xc,%esp
  8012ff:	6a 00                	push   $0x0
  801301:	53                   	push   %ebx
  801302:	6a 00                	push   $0x0
  801304:	e8 a8 0b 00 00       	call   801eb1 <ipc_recv>
}
  801309:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801316:	8b 45 08             	mov    0x8(%ebp),%eax
  801319:	8b 40 0c             	mov    0xc(%eax),%eax
  80131c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801329:	ba 00 00 00 00       	mov    $0x0,%edx
  80132e:	b8 02 00 00 00       	mov    $0x2,%eax
  801333:	e8 8d ff ff ff       	call   8012c5 <fsipc>
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	8b 40 0c             	mov    0xc(%eax),%eax
  801346:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80134b:	ba 00 00 00 00       	mov    $0x0,%edx
  801350:	b8 06 00 00 00       	mov    $0x6,%eax
  801355:	e8 6b ff ff ff       	call   8012c5 <fsipc>
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	53                   	push   %ebx
  801360:	83 ec 04             	sub    $0x4,%esp
  801363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	8b 40 0c             	mov    0xc(%eax),%eax
  80136c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	b8 05 00 00 00       	mov    $0x5,%eax
  80137b:	e8 45 ff ff ff       	call   8012c5 <fsipc>
  801380:	85 c0                	test   %eax,%eax
  801382:	78 2c                	js     8013b0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	68 00 50 80 00       	push   $0x805000
  80138c:	53                   	push   %ebx
  80138d:	e8 50 f3 ff ff       	call   8006e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801392:	a1 80 50 80 00       	mov    0x805080,%eax
  801397:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80139d:	a1 84 50 80 00       	mov    0x805084,%eax
  8013a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8013bf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013c4:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8013c9:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013cc:	53                   	push   %ebx
  8013cd:	ff 75 0c             	pushl  0xc(%ebp)
  8013d0:	68 08 50 80 00       	push   $0x805008
  8013d5:	e8 9a f4 ff ff       	call   800874 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e0:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8013e5:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8013eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f5:	e8 cb fe ff ff       	call   8012c5 <fsipc>
	//panic("devfile_write not implemented");
}
  8013fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
  801404:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801407:	8b 45 08             	mov    0x8(%ebp),%eax
  80140a:	8b 40 0c             	mov    0xc(%eax),%eax
  80140d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801412:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801418:	ba 00 00 00 00       	mov    $0x0,%edx
  80141d:	b8 03 00 00 00       	mov    $0x3,%eax
  801422:	e8 9e fe ff ff       	call   8012c5 <fsipc>
  801427:	89 c3                	mov    %eax,%ebx
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 4b                	js     801478 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80142d:	39 c6                	cmp    %eax,%esi
  80142f:	73 16                	jae    801447 <devfile_read+0x48>
  801431:	68 5c 26 80 00       	push   $0x80265c
  801436:	68 63 26 80 00       	push   $0x802663
  80143b:	6a 7c                	push   $0x7c
  80143d:	68 78 26 80 00       	push   $0x802678
  801442:	e8 24 0a 00 00       	call   801e6b <_panic>
	assert(r <= PGSIZE);
  801447:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80144c:	7e 16                	jle    801464 <devfile_read+0x65>
  80144e:	68 83 26 80 00       	push   $0x802683
  801453:	68 63 26 80 00       	push   $0x802663
  801458:	6a 7d                	push   $0x7d
  80145a:	68 78 26 80 00       	push   $0x802678
  80145f:	e8 07 0a 00 00       	call   801e6b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801464:	83 ec 04             	sub    $0x4,%esp
  801467:	50                   	push   %eax
  801468:	68 00 50 80 00       	push   $0x805000
  80146d:	ff 75 0c             	pushl  0xc(%ebp)
  801470:	e8 ff f3 ff ff       	call   800874 <memmove>
	return r;
  801475:	83 c4 10             	add    $0x10,%esp
}
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	53                   	push   %ebx
  801485:	83 ec 20             	sub    $0x20,%esp
  801488:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80148b:	53                   	push   %ebx
  80148c:	e8 18 f2 ff ff       	call   8006a9 <strlen>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801499:	7f 67                	jg     801502 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	e8 96 f8 ff ff       	call   800d3d <fd_alloc>
  8014a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014aa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 57                	js     801507 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	53                   	push   %ebx
  8014b4:	68 00 50 80 00       	push   $0x805000
  8014b9:	e8 24 f2 ff ff       	call   8006e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ce:	e8 f2 fd ff ff       	call   8012c5 <fsipc>
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	79 14                	jns    8014f0 <open+0x6f>
		fd_close(fd, 0);
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	6a 00                	push   $0x0
  8014e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e4:	e8 4c f9 ff ff       	call   800e35 <fd_close>
		return r;
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	89 da                	mov    %ebx,%edx
  8014ee:	eb 17                	jmp    801507 <open+0x86>
	}

	return fd2num(fd);
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f6:	e8 1b f8 ff ff       	call   800d16 <fd2num>
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	eb 05                	jmp    801507 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801502:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801507:	89 d0                	mov    %edx,%eax
  801509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801514:	ba 00 00 00 00       	mov    $0x0,%edx
  801519:	b8 08 00 00 00       	mov    $0x8,%eax
  80151e:	e8 a2 fd ff ff       	call   8012c5 <fsipc>
}
  801523:	c9                   	leave  
  801524:	c3                   	ret    

00801525 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80152b:	68 8f 26 80 00       	push   $0x80268f
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	e8 aa f1 ff ff       	call   8006e2 <strcpy>
	return 0;
}
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	53                   	push   %ebx
  801543:	83 ec 10             	sub    $0x10,%esp
  801546:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801549:	53                   	push   %ebx
  80154a:	e8 5c 0a 00 00       	call   801fab <pageref>
  80154f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801557:	83 f8 01             	cmp    $0x1,%eax
  80155a:	75 10                	jne    80156c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	ff 73 0c             	pushl  0xc(%ebx)
  801562:	e8 c0 02 00 00       	call   801827 <nsipc_close>
  801567:	89 c2                	mov    %eax,%edx
  801569:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80156c:	89 d0                	mov    %edx,%eax
  80156e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801579:	6a 00                	push   $0x0
  80157b:	ff 75 10             	pushl  0x10(%ebp)
  80157e:	ff 75 0c             	pushl  0xc(%ebp)
  801581:	8b 45 08             	mov    0x8(%ebp),%eax
  801584:	ff 70 0c             	pushl  0xc(%eax)
  801587:	e8 78 03 00 00       	call   801904 <nsipc_send>
}
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801594:	6a 00                	push   $0x0
  801596:	ff 75 10             	pushl  0x10(%ebp)
  801599:	ff 75 0c             	pushl  0xc(%ebp)
  80159c:	8b 45 08             	mov    0x8(%ebp),%eax
  80159f:	ff 70 0c             	pushl  0xc(%eax)
  8015a2:	e8 f1 02 00 00       	call   801898 <nsipc_recv>
}
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015af:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015b2:	52                   	push   %edx
  8015b3:	50                   	push   %eax
  8015b4:	e8 d3 f7 ff ff       	call   800d8c <fd_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 17                	js     8015d7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c3:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8015c9:	39 08                	cmp    %ecx,(%eax)
  8015cb:	75 05                	jne    8015d2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8015cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d0:	eb 05                	jmp    8015d7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8015d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 1c             	sub    $0x1c,%esp
  8015e1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	e8 51 f7 ff ff       	call   800d3d <fd_alloc>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 1b                	js     801610 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8015f5:	83 ec 04             	sub    $0x4,%esp
  8015f8:	68 07 04 00 00       	push   $0x407
  8015fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801600:	6a 00                	push   $0x0
  801602:	e8 de f4 ff ff       	call   800ae5 <sys_page_alloc>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	79 10                	jns    801620 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	56                   	push   %esi
  801614:	e8 0e 02 00 00       	call   801827 <nsipc_close>
		return r;
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	eb 24                	jmp    801644 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801620:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80162b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801635:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	50                   	push   %eax
  80163c:	e8 d5 f6 ff ff       	call   800d16 <fd2num>
  801641:	83 c4 10             	add    $0x10,%esp
}
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801651:	8b 45 08             	mov    0x8(%ebp),%eax
  801654:	e8 50 ff ff ff       	call   8015a9 <fd2sockid>
		return r;
  801659:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1f                	js     80167e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	50                   	push   %eax
  801669:	e8 12 01 00 00       	call   801780 <nsipc_accept>
  80166e:	83 c4 10             	add    $0x10,%esp
		return r;
  801671:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801673:	85 c0                	test   %eax,%eax
  801675:	78 07                	js     80167e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801677:	e8 5d ff ff ff       	call   8015d9 <alloc_sockfd>
  80167c:	89 c1                	mov    %eax,%ecx
}
  80167e:	89 c8                	mov    %ecx,%eax
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801688:	8b 45 08             	mov    0x8(%ebp),%eax
  80168b:	e8 19 ff ff ff       	call   8015a9 <fd2sockid>
  801690:	85 c0                	test   %eax,%eax
  801692:	78 12                	js     8016a6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801694:	83 ec 04             	sub    $0x4,%esp
  801697:	ff 75 10             	pushl  0x10(%ebp)
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	e8 2d 01 00 00       	call   8017d0 <nsipc_bind>
  8016a3:	83 c4 10             	add    $0x10,%esp
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <shutdown>:

int
shutdown(int s, int how)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	e8 f3 fe ff ff       	call   8015a9 <fd2sockid>
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 0f                	js     8016c9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016ba:	83 ec 08             	sub    $0x8,%esp
  8016bd:	ff 75 0c             	pushl  0xc(%ebp)
  8016c0:	50                   	push   %eax
  8016c1:	e8 3f 01 00 00       	call   801805 <nsipc_shutdown>
  8016c6:	83 c4 10             	add    $0x10,%esp
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	e8 d0 fe ff ff       	call   8015a9 <fd2sockid>
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 12                	js     8016ef <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	ff 75 10             	pushl  0x10(%ebp)
  8016e3:	ff 75 0c             	pushl  0xc(%ebp)
  8016e6:	50                   	push   %eax
  8016e7:	e8 55 01 00 00       	call   801841 <nsipc_connect>
  8016ec:	83 c4 10             	add    $0x10,%esp
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <listen>:

int
listen(int s, int backlog)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	e8 aa fe ff ff       	call   8015a9 <fd2sockid>
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 0f                	js     801712 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	50                   	push   %eax
  80170a:	e8 67 01 00 00       	call   801876 <nsipc_listen>
  80170f:	83 c4 10             	add    $0x10,%esp
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80171a:	ff 75 10             	pushl  0x10(%ebp)
  80171d:	ff 75 0c             	pushl  0xc(%ebp)
  801720:	ff 75 08             	pushl  0x8(%ebp)
  801723:	e8 3a 02 00 00       	call   801962 <nsipc_socket>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 05                	js     801734 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80172f:	e8 a5 fe ff ff       	call   8015d9 <alloc_sockfd>
}
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	53                   	push   %ebx
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80173f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801746:	75 12                	jne    80175a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801748:	83 ec 0c             	sub    $0xc,%esp
  80174b:	6a 02                	push   $0x2
  80174d:	e8 20 08 00 00       	call   801f72 <ipc_find_env>
  801752:	a3 04 40 80 00       	mov    %eax,0x804004
  801757:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80175a:	6a 07                	push   $0x7
  80175c:	68 00 60 80 00       	push   $0x806000
  801761:	53                   	push   %ebx
  801762:	ff 35 04 40 80 00    	pushl  0x804004
  801768:	e8 b1 07 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80176d:	83 c4 0c             	add    $0xc,%esp
  801770:	6a 00                	push   $0x0
  801772:	6a 00                	push   $0x0
  801774:	6a 00                	push   $0x0
  801776:	e8 36 07 00 00       	call   801eb1 <ipc_recv>
}
  80177b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801790:	8b 06                	mov    (%esi),%eax
  801792:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801797:	b8 01 00 00 00       	mov    $0x1,%eax
  80179c:	e8 95 ff ff ff       	call   801736 <nsipc>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 20                	js     8017c7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	ff 35 10 60 80 00    	pushl  0x806010
  8017b0:	68 00 60 80 00       	push   $0x806000
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	e8 b7 f0 ff ff       	call   800874 <memmove>
		*addrlen = ret->ret_addrlen;
  8017bd:	a1 10 60 80 00       	mov    0x806010,%eax
  8017c2:	89 06                	mov    %eax,(%esi)
  8017c4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8017c7:	89 d8                	mov    %ebx,%eax
  8017c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8017e2:	53                   	push   %ebx
  8017e3:	ff 75 0c             	pushl  0xc(%ebp)
  8017e6:	68 04 60 80 00       	push   $0x806004
  8017eb:	e8 84 f0 ff ff       	call   800874 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8017f0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8017f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fb:	e8 36 ff ff ff       	call   801736 <nsipc>
}
  801800:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801813:	8b 45 0c             	mov    0xc(%ebp),%eax
  801816:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80181b:	b8 03 00 00 00       	mov    $0x3,%eax
  801820:	e8 11 ff ff ff       	call   801736 <nsipc>
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <nsipc_close>:

int
nsipc_close(int s)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801835:	b8 04 00 00 00       	mov    $0x4,%eax
  80183a:	e8 f7 fe ff ff       	call   801736 <nsipc>
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	53                   	push   %ebx
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801853:	53                   	push   %ebx
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	68 04 60 80 00       	push   $0x806004
  80185c:	e8 13 f0 ff ff       	call   800874 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801861:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801867:	b8 05 00 00 00       	mov    $0x5,%eax
  80186c:	e8 c5 fe ff ff       	call   801736 <nsipc>
}
  801871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801884:	8b 45 0c             	mov    0xc(%ebp),%eax
  801887:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80188c:	b8 06 00 00 00       	mov    $0x6,%eax
  801891:	e8 a0 fe ff ff       	call   801736 <nsipc>
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018a8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018b6:	b8 07 00 00 00       	mov    $0x7,%eax
  8018bb:	e8 76 fe ff ff       	call   801736 <nsipc>
  8018c0:	89 c3                	mov    %eax,%ebx
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 35                	js     8018fb <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8018c6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8018cb:	7f 04                	jg     8018d1 <nsipc_recv+0x39>
  8018cd:	39 c6                	cmp    %eax,%esi
  8018cf:	7d 16                	jge    8018e7 <nsipc_recv+0x4f>
  8018d1:	68 9b 26 80 00       	push   $0x80269b
  8018d6:	68 63 26 80 00       	push   $0x802663
  8018db:	6a 62                	push   $0x62
  8018dd:	68 b0 26 80 00       	push   $0x8026b0
  8018e2:	e8 84 05 00 00       	call   801e6b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	50                   	push   %eax
  8018eb:	68 00 60 80 00       	push   $0x806000
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	e8 7c ef ff ff       	call   800874 <memmove>
  8018f8:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8018fb:	89 d8                	mov    %ebx,%eax
  8018fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	53                   	push   %ebx
  801908:	83 ec 04             	sub    $0x4,%esp
  80190b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801916:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80191c:	7e 16                	jle    801934 <nsipc_send+0x30>
  80191e:	68 bc 26 80 00       	push   $0x8026bc
  801923:	68 63 26 80 00       	push   $0x802663
  801928:	6a 6d                	push   $0x6d
  80192a:	68 b0 26 80 00       	push   $0x8026b0
  80192f:	e8 37 05 00 00       	call   801e6b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801934:	83 ec 04             	sub    $0x4,%esp
  801937:	53                   	push   %ebx
  801938:	ff 75 0c             	pushl  0xc(%ebp)
  80193b:	68 0c 60 80 00       	push   $0x80600c
  801940:	e8 2f ef ff ff       	call   800874 <memmove>
	nsipcbuf.send.req_size = size;
  801945:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80194b:	8b 45 14             	mov    0x14(%ebp),%eax
  80194e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801953:	b8 08 00 00 00       	mov    $0x8,%eax
  801958:	e8 d9 fd ff ff       	call   801736 <nsipc>
}
  80195d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801970:	8b 45 0c             	mov    0xc(%ebp),%eax
  801973:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801978:	8b 45 10             	mov    0x10(%ebp),%eax
  80197b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801980:	b8 09 00 00 00       	mov    $0x9,%eax
  801985:	e8 ac fd ff ff       	call   801736 <nsipc>
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	ff 75 08             	pushl  0x8(%ebp)
  80199a:	e8 87 f3 ff ff       	call   800d26 <fd2data>
  80199f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019a1:	83 c4 08             	add    $0x8,%esp
  8019a4:	68 c8 26 80 00       	push   $0x8026c8
  8019a9:	53                   	push   %ebx
  8019aa:	e8 33 ed ff ff       	call   8006e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019af:	8b 46 04             	mov    0x4(%esi),%eax
  8019b2:	2b 06                	sub    (%esi),%eax
  8019b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c1:	00 00 00 
	stat->st_dev = &devpipe;
  8019c4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019cb:	30 80 00 
	return 0;
}
  8019ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	53                   	push   %ebx
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019e4:	53                   	push   %ebx
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 7e f1 ff ff       	call   800b6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ec:	89 1c 24             	mov    %ebx,(%esp)
  8019ef:	e8 32 f3 ff ff       	call   800d26 <fd2data>
  8019f4:	83 c4 08             	add    $0x8,%esp
  8019f7:	50                   	push   %eax
  8019f8:	6a 00                	push   $0x0
  8019fa:	e8 6b f1 ff ff       	call   800b6a <sys_page_unmap>
}
  8019ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	57                   	push   %edi
  801a08:	56                   	push   %esi
  801a09:	53                   	push   %ebx
  801a0a:	83 ec 1c             	sub    $0x1c,%esp
  801a0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a10:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a12:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801a17:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a20:	e8 86 05 00 00       	call   801fab <pageref>
  801a25:	89 c3                	mov    %eax,%ebx
  801a27:	89 3c 24             	mov    %edi,(%esp)
  801a2a:	e8 7c 05 00 00       	call   801fab <pageref>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	39 c3                	cmp    %eax,%ebx
  801a34:	0f 94 c1             	sete   %cl
  801a37:	0f b6 c9             	movzbl %cl,%ecx
  801a3a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a3d:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801a43:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a46:	39 ce                	cmp    %ecx,%esi
  801a48:	74 1b                	je     801a65 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a4a:	39 c3                	cmp    %eax,%ebx
  801a4c:	75 c4                	jne    801a12 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4e:	8b 42 58             	mov    0x58(%edx),%eax
  801a51:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a54:	50                   	push   %eax
  801a55:	56                   	push   %esi
  801a56:	68 cf 26 80 00       	push   $0x8026cf
  801a5b:	e8 fd e6 ff ff       	call   80015d <cprintf>
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	eb ad                	jmp    801a12 <_pipeisclosed+0xe>
	}
}
  801a65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5f                   	pop    %edi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 28             	sub    $0x28,%esp
  801a79:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a7c:	56                   	push   %esi
  801a7d:	e8 a4 f2 ff ff       	call   800d26 <fd2data>
  801a82:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	bf 00 00 00 00       	mov    $0x0,%edi
  801a8c:	eb 4b                	jmp    801ad9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a8e:	89 da                	mov    %ebx,%edx
  801a90:	89 f0                	mov    %esi,%eax
  801a92:	e8 6d ff ff ff       	call   801a04 <_pipeisclosed>
  801a97:	85 c0                	test   %eax,%eax
  801a99:	75 48                	jne    801ae3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a9b:	e8 26 f0 ff ff       	call   800ac6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa0:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa3:	8b 0b                	mov    (%ebx),%ecx
  801aa5:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa8:	39 d0                	cmp    %edx,%eax
  801aaa:	73 e2                	jae    801a8e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aaf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ab3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ab6:	89 c2                	mov    %eax,%edx
  801ab8:	c1 fa 1f             	sar    $0x1f,%edx
  801abb:	89 d1                	mov    %edx,%ecx
  801abd:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ac3:	83 e2 1f             	and    $0x1f,%edx
  801ac6:	29 ca                	sub    %ecx,%edx
  801ac8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801acc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad0:	83 c0 01             	add    $0x1,%eax
  801ad3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad6:	83 c7 01             	add    $0x1,%edi
  801ad9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801adc:	75 c2                	jne    801aa0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ade:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae1:	eb 05                	jmp    801ae8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5f                   	pop    %edi
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    

00801af0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	57                   	push   %edi
  801af4:	56                   	push   %esi
  801af5:	53                   	push   %ebx
  801af6:	83 ec 18             	sub    $0x18,%esp
  801af9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801afc:	57                   	push   %edi
  801afd:	e8 24 f2 ff ff       	call   800d26 <fd2data>
  801b02:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b0c:	eb 3d                	jmp    801b4b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b0e:	85 db                	test   %ebx,%ebx
  801b10:	74 04                	je     801b16 <devpipe_read+0x26>
				return i;
  801b12:	89 d8                	mov    %ebx,%eax
  801b14:	eb 44                	jmp    801b5a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b16:	89 f2                	mov    %esi,%edx
  801b18:	89 f8                	mov    %edi,%eax
  801b1a:	e8 e5 fe ff ff       	call   801a04 <_pipeisclosed>
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	75 32                	jne    801b55 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b23:	e8 9e ef ff ff       	call   800ac6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b28:	8b 06                	mov    (%esi),%eax
  801b2a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b2d:	74 df                	je     801b0e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b2f:	99                   	cltd   
  801b30:	c1 ea 1b             	shr    $0x1b,%edx
  801b33:	01 d0                	add    %edx,%eax
  801b35:	83 e0 1f             	and    $0x1f,%eax
  801b38:	29 d0                	sub    %edx,%eax
  801b3a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b42:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b45:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b48:	83 c3 01             	add    $0x1,%ebx
  801b4b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b4e:	75 d8                	jne    801b28 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b50:	8b 45 10             	mov    0x10(%ebp),%eax
  801b53:	eb 05                	jmp    801b5a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6d:	50                   	push   %eax
  801b6e:	e8 ca f1 ff ff       	call   800d3d <fd_alloc>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	89 c2                	mov    %eax,%edx
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	0f 88 2c 01 00 00    	js     801cac <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b80:	83 ec 04             	sub    $0x4,%esp
  801b83:	68 07 04 00 00       	push   $0x407
  801b88:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8b:	6a 00                	push   $0x0
  801b8d:	e8 53 ef ff ff       	call   800ae5 <sys_page_alloc>
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	89 c2                	mov    %eax,%edx
  801b97:	85 c0                	test   %eax,%eax
  801b99:	0f 88 0d 01 00 00    	js     801cac <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	e8 92 f1 ff ff       	call   800d3d <fd_alloc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	0f 88 e2 00 00 00    	js     801c9a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	68 07 04 00 00       	push   $0x407
  801bc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 1b ef ff ff       	call   800ae5 <sys_page_alloc>
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 88 c3 00 00 00    	js     801c9a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdd:	e8 44 f1 ff ff       	call   800d26 <fd2data>
  801be2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be4:	83 c4 0c             	add    $0xc,%esp
  801be7:	68 07 04 00 00       	push   $0x407
  801bec:	50                   	push   %eax
  801bed:	6a 00                	push   $0x0
  801bef:	e8 f1 ee ff ff       	call   800ae5 <sys_page_alloc>
  801bf4:	89 c3                	mov    %eax,%ebx
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	0f 88 89 00 00 00    	js     801c8a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	ff 75 f0             	pushl  -0x10(%ebp)
  801c07:	e8 1a f1 ff ff       	call   800d26 <fd2data>
  801c0c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c13:	50                   	push   %eax
  801c14:	6a 00                	push   $0x0
  801c16:	56                   	push   %esi
  801c17:	6a 00                	push   $0x0
  801c19:	e8 0a ef ff ff       	call   800b28 <sys_page_map>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	83 c4 20             	add    $0x20,%esp
  801c23:	85 c0                	test   %eax,%eax
  801c25:	78 55                	js     801c7c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c27:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c30:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c3c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c45:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff 75 f4             	pushl  -0xc(%ebp)
  801c57:	e8 ba f0 ff ff       	call   800d16 <fd2num>
  801c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c61:	83 c4 04             	add    $0x4,%esp
  801c64:	ff 75 f0             	pushl  -0x10(%ebp)
  801c67:	e8 aa f0 ff ff       	call   800d16 <fd2num>
  801c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7a:	eb 30                	jmp    801cac <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	56                   	push   %esi
  801c80:	6a 00                	push   $0x0
  801c82:	e8 e3 ee ff ff       	call   800b6a <sys_page_unmap>
  801c87:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c8a:	83 ec 08             	sub    $0x8,%esp
  801c8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c90:	6a 00                	push   $0x0
  801c92:	e8 d3 ee ff ff       	call   800b6a <sys_page_unmap>
  801c97:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 c3 ee ff ff       	call   800b6a <sys_page_unmap>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cac:	89 d0                	mov    %edx,%eax
  801cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	50                   	push   %eax
  801cbf:	ff 75 08             	pushl  0x8(%ebp)
  801cc2:	e8 c5 f0 ff ff       	call   800d8c <fd_lookup>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 18                	js     801ce6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd4:	e8 4d f0 ff ff       	call   800d26 <fd2data>
	return _pipeisclosed(fd, p);
  801cd9:	89 c2                	mov    %eax,%edx
  801cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cde:	e8 21 fd ff ff       	call   801a04 <_pipeisclosed>
  801ce3:	83 c4 10             	add    $0x10,%esp
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    

00801cf2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf8:	68 e7 26 80 00       	push   $0x8026e7
  801cfd:	ff 75 0c             	pushl  0xc(%ebp)
  801d00:	e8 dd e9 ff ff       	call   8006e2 <strcpy>
	return 0;
}
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0a:	c9                   	leave  
  801d0b:	c3                   	ret    

00801d0c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d18:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d23:	eb 2d                	jmp    801d52 <devcons_write+0x46>
		m = n - tot;
  801d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d28:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d2a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d32:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d35:	83 ec 04             	sub    $0x4,%esp
  801d38:	53                   	push   %ebx
  801d39:	03 45 0c             	add    0xc(%ebp),%eax
  801d3c:	50                   	push   %eax
  801d3d:	57                   	push   %edi
  801d3e:	e8 31 eb ff ff       	call   800874 <memmove>
		sys_cputs(buf, m);
  801d43:	83 c4 08             	add    $0x8,%esp
  801d46:	53                   	push   %ebx
  801d47:	57                   	push   %edi
  801d48:	e8 dc ec ff ff       	call   800a29 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4d:	01 de                	add    %ebx,%esi
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	89 f0                	mov    %esi,%eax
  801d54:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d57:	72 cc                	jb     801d25 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 08             	sub    $0x8,%esp
  801d67:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d70:	74 2a                	je     801d9c <devcons_read+0x3b>
  801d72:	eb 05                	jmp    801d79 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d74:	e8 4d ed ff ff       	call   800ac6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d79:	e8 c9 ec ff ff       	call   800a47 <sys_cgetc>
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	74 f2                	je     801d74 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d82:	85 c0                	test   %eax,%eax
  801d84:	78 16                	js     801d9c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d86:	83 f8 04             	cmp    $0x4,%eax
  801d89:	74 0c                	je     801d97 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8e:	88 02                	mov    %al,(%edx)
	return 1;
  801d90:	b8 01 00 00 00       	mov    $0x1,%eax
  801d95:	eb 05                	jmp    801d9c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801daa:	6a 01                	push   $0x1
  801dac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801daf:	50                   	push   %eax
  801db0:	e8 74 ec ff ff       	call   800a29 <sys_cputs>
}
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <getchar>:

int
getchar(void)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc0:	6a 01                	push   $0x1
  801dc2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	6a 00                	push   $0x0
  801dc8:	e8 25 f2 ff ff       	call   800ff2 <read>
	if (r < 0)
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 0f                	js     801de3 <getchar+0x29>
		return r;
	if (r < 1)
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	7e 06                	jle    801dde <getchar+0x24>
		return -E_EOF;
	return c;
  801dd8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ddc:	eb 05                	jmp    801de3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dde:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801deb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dee:	50                   	push   %eax
  801def:	ff 75 08             	pushl  0x8(%ebp)
  801df2:	e8 95 ef ff ff       	call   800d8c <fd_lookup>
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 11                	js     801e0f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e01:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e07:	39 10                	cmp    %edx,(%eax)
  801e09:	0f 94 c0             	sete   %al
  801e0c:	0f b6 c0             	movzbl %al,%eax
}
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    

00801e11 <opencons>:

int
opencons(void)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1a:	50                   	push   %eax
  801e1b:	e8 1d ef ff ff       	call   800d3d <fd_alloc>
  801e20:	83 c4 10             	add    $0x10,%esp
		return r;
  801e23:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 3e                	js     801e67 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e29:	83 ec 04             	sub    $0x4,%esp
  801e2c:	68 07 04 00 00       	push   $0x407
  801e31:	ff 75 f4             	pushl  -0xc(%ebp)
  801e34:	6a 00                	push   $0x0
  801e36:	e8 aa ec ff ff       	call   800ae5 <sys_page_alloc>
  801e3b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 23                	js     801e67 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e44:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e52:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e59:	83 ec 0c             	sub    $0xc,%esp
  801e5c:	50                   	push   %eax
  801e5d:	e8 b4 ee ff ff       	call   800d16 <fd2num>
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	83 c4 10             	add    $0x10,%esp
}
  801e67:	89 d0                	mov    %edx,%eax
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	56                   	push   %esi
  801e6f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e70:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e73:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e79:	e8 29 ec ff ff       	call   800aa7 <sys_getenvid>
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	ff 75 0c             	pushl  0xc(%ebp)
  801e84:	ff 75 08             	pushl  0x8(%ebp)
  801e87:	56                   	push   %esi
  801e88:	50                   	push   %eax
  801e89:	68 f4 26 80 00       	push   $0x8026f4
  801e8e:	e8 ca e2 ff ff       	call   80015d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e93:	83 c4 18             	add    $0x18,%esp
  801e96:	53                   	push   %ebx
  801e97:	ff 75 10             	pushl  0x10(%ebp)
  801e9a:	e8 6d e2 ff ff       	call   80010c <vcprintf>
	cprintf("\n");
  801e9f:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  801ea6:	e8 b2 e2 ff ff       	call   80015d <cprintf>
  801eab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eae:	cc                   	int3   
  801eaf:	eb fd                	jmp    801eae <_panic+0x43>

00801eb1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	74 0e                	je     801ed1 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	50                   	push   %eax
  801ec7:	e8 c9 ed ff ff       	call   800c95 <sys_ipc_recv>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	eb 10                	jmp    801ee1 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801ed1:	83 ec 0c             	sub    $0xc,%esp
  801ed4:	68 00 00 00 f0       	push   $0xf0000000
  801ed9:	e8 b7 ed ff ff       	call   800c95 <sys_ipc_recv>
  801ede:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	74 0e                	je     801ef3 <ipc_recv+0x42>
    	*from_env_store = 0;
  801ee5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801eeb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801ef1:	eb 24                	jmp    801f17 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ef3:	85 f6                	test   %esi,%esi
  801ef5:	74 0a                	je     801f01 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ef7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801efc:	8b 40 74             	mov    0x74(%eax),%eax
  801eff:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f01:	85 db                	test   %ebx,%ebx
  801f03:	74 0a                	je     801f0f <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f05:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f0a:	8b 40 78             	mov    0x78(%eax),%eax
  801f0d:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f0f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f14:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 0c             	sub    $0xc,%esp
  801f27:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f30:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f37:	0f 44 d8             	cmove  %eax,%ebx
  801f3a:	eb 1c                	jmp    801f58 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f3c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3f:	74 12                	je     801f53 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f41:	50                   	push   %eax
  801f42:	68 18 27 80 00       	push   $0x802718
  801f47:	6a 4b                	push   $0x4b
  801f49:	68 30 27 80 00       	push   $0x802730
  801f4e:	e8 18 ff ff ff       	call   801e6b <_panic>
        }	
        sys_yield();
  801f53:	e8 6e eb ff ff       	call   800ac6 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f58:	ff 75 14             	pushl  0x14(%ebp)
  801f5b:	53                   	push   %ebx
  801f5c:	56                   	push   %esi
  801f5d:	57                   	push   %edi
  801f5e:	e8 0f ed ff ff       	call   800c72 <sys_ipc_try_send>
  801f63:	83 c4 10             	add    $0x10,%esp
  801f66:	85 c0                	test   %eax,%eax
  801f68:	75 d2                	jne    801f3c <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f80:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f86:	8b 52 50             	mov    0x50(%edx),%edx
  801f89:	39 ca                	cmp    %ecx,%edx
  801f8b:	75 0d                	jne    801f9a <ipc_find_env+0x28>
			return envs[i].env_id;
  801f8d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f90:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f95:	8b 40 48             	mov    0x48(%eax),%eax
  801f98:	eb 0f                	jmp    801fa9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9a:	83 c0 01             	add    $0x1,%eax
  801f9d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa2:	75 d9                	jne    801f7d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb1:	89 d0                	mov    %edx,%eax
  801fb3:	c1 e8 16             	shr    $0x16,%eax
  801fb6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc2:	f6 c1 01             	test   $0x1,%cl
  801fc5:	74 1d                	je     801fe4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc7:	c1 ea 0c             	shr    $0xc,%edx
  801fca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd1:	f6 c2 01             	test   $0x1,%dl
  801fd4:	74 0e                	je     801fe4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd6:	c1 ea 0c             	shr    $0xc,%edx
  801fd9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe0:	ef 
  801fe1:	0f b7 c0             	movzwl %ax,%eax
}
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    
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
