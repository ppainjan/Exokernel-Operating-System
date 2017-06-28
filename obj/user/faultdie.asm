
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 40 23 80 00       	push   $0x802340
  80004a:	e8 2e 01 00 00       	call   80017d <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 73 0a 00 00       	call   800ac7 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 2a 0a 00 00       	call   800a86 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 c5 0c 00 00       	call   800d36 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008b:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800092:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800095:	e8 2d 0a 00 00       	call   800ac7 <sys_getenvid>
  80009a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a7:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 db                	test   %ebx,%ebx
  8000ae:	7e 07                	jle    8000b7 <libmain+0x37>
		binaryname = argv[0];
  8000b0:	8b 06                	mov    (%esi),%eax
  8000b2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
  8000bc:	e8 a0 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000c1:	e8 0a 00 00 00       	call   8000d0 <exit>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d6:	e8 b9 0e 00 00       	call   800f94 <close_all>
	sys_env_destroy(0);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	6a 00                	push   $0x0
  8000e0:	e8 a1 09 00 00       	call   800a86 <sys_env_destroy>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 04             	sub    $0x4,%esp
  8000f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f4:	8b 13                	mov    (%ebx),%edx
  8000f6:	8d 42 01             	lea    0x1(%edx),%eax
  8000f9:	89 03                	mov    %eax,(%ebx)
  8000fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800102:	3d ff 00 00 00       	cmp    $0xff,%eax
  800107:	75 1a                	jne    800123 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	68 ff 00 00 00       	push   $0xff
  800111:	8d 43 08             	lea    0x8(%ebx),%eax
  800114:	50                   	push   %eax
  800115:	e8 2f 09 00 00       	call   800a49 <sys_cputs>
		b->idx = 0;
  80011a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800120:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800123:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013c:	00 00 00 
	b.cnt = 0;
  80013f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800155:	50                   	push   %eax
  800156:	68 ea 00 80 00       	push   $0x8000ea
  80015b:	e8 54 01 00 00       	call   8002b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800160:	83 c4 08             	add    $0x8,%esp
  800163:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800169:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	e8 d4 08 00 00       	call   800a49 <sys_cputs>

	return b.cnt;
}
  800175:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800183:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800186:	50                   	push   %eax
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	e8 9d ff ff ff       	call   80012c <vcprintf>
	va_end(ap);

	return cnt;
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 1c             	sub    $0x1c,%esp
  80019a:	89 c7                	mov    %eax,%edi
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b8:	39 d3                	cmp    %edx,%ebx
  8001ba:	72 05                	jb     8001c1 <printnum+0x30>
  8001bc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001bf:	77 45                	ja     800206 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	ff 75 18             	pushl  0x18(%ebp)
  8001c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001cd:	53                   	push   %ebx
  8001ce:	ff 75 10             	pushl  0x10(%ebp)
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001da:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e0:	e8 bb 1e 00 00       	call   8020a0 <__udivdi3>
  8001e5:	83 c4 18             	add    $0x18,%esp
  8001e8:	52                   	push   %edx
  8001e9:	50                   	push   %eax
  8001ea:	89 f2                	mov    %esi,%edx
  8001ec:	89 f8                	mov    %edi,%eax
  8001ee:	e8 9e ff ff ff       	call   800191 <printnum>
  8001f3:	83 c4 20             	add    $0x20,%esp
  8001f6:	eb 18                	jmp    800210 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	56                   	push   %esi
  8001fc:	ff 75 18             	pushl  0x18(%ebp)
  8001ff:	ff d7                	call   *%edi
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	eb 03                	jmp    800209 <printnum+0x78>
  800206:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800209:	83 eb 01             	sub    $0x1,%ebx
  80020c:	85 db                	test   %ebx,%ebx
  80020e:	7f e8                	jg     8001f8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	56                   	push   %esi
  800214:	83 ec 04             	sub    $0x4,%esp
  800217:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021a:	ff 75 e0             	pushl  -0x20(%ebp)
  80021d:	ff 75 dc             	pushl  -0x24(%ebp)
  800220:	ff 75 d8             	pushl  -0x28(%ebp)
  800223:	e8 a8 1f 00 00       	call   8021d0 <__umoddi3>
  800228:	83 c4 14             	add    $0x14,%esp
  80022b:	0f be 80 66 23 80 00 	movsbl 0x802366(%eax),%eax
  800232:	50                   	push   %eax
  800233:	ff d7                	call   *%edi
}
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800243:	83 fa 01             	cmp    $0x1,%edx
  800246:	7e 0e                	jle    800256 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	8b 52 04             	mov    0x4(%edx),%edx
  800254:	eb 22                	jmp    800278 <getuint+0x38>
	else if (lflag)
  800256:	85 d2                	test   %edx,%edx
  800258:	74 10                	je     80026a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	ba 00 00 00 00       	mov    $0x0,%edx
  800268:	eb 0e                	jmp    800278 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800280:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800284:	8b 10                	mov    (%eax),%edx
  800286:	3b 50 04             	cmp    0x4(%eax),%edx
  800289:	73 0a                	jae    800295 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	88 02                	mov    %al,(%edx)
}
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a0:	50                   	push   %eax
  8002a1:	ff 75 10             	pushl  0x10(%ebp)
  8002a4:	ff 75 0c             	pushl  0xc(%ebp)
  8002a7:	ff 75 08             	pushl  0x8(%ebp)
  8002aa:	e8 05 00 00 00       	call   8002b4 <vprintfmt>
	va_end(ap);
}
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 2c             	sub    $0x2c,%esp
  8002bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c6:	eb 12                	jmp    8002da <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	0f 84 89 03 00 00    	je     800659 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	53                   	push   %ebx
  8002d4:	50                   	push   %eax
  8002d5:	ff d6                	call   *%esi
  8002d7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002da:	83 c7 01             	add    $0x1,%edi
  8002dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e1:	83 f8 25             	cmp    $0x25,%eax
  8002e4:	75 e2                	jne    8002c8 <vprintfmt+0x14>
  8002e6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ea:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800304:	eb 07                	jmp    80030d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800309:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8d 47 01             	lea    0x1(%edi),%eax
  800310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800313:	0f b6 07             	movzbl (%edi),%eax
  800316:	0f b6 c8             	movzbl %al,%ecx
  800319:	83 e8 23             	sub    $0x23,%eax
  80031c:	3c 55                	cmp    $0x55,%al
  80031e:	0f 87 1a 03 00 00    	ja     80063e <vprintfmt+0x38a>
  800324:	0f b6 c0             	movzbl %al,%eax
  800327:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800331:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800335:	eb d6                	jmp    80030d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033a:	b8 00 00 00 00       	mov    $0x0,%eax
  80033f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800342:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800345:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800349:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80034c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80034f:	83 fa 09             	cmp    $0x9,%edx
  800352:	77 39                	ja     80038d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800354:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800357:	eb e9                	jmp    800342 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 48 04             	lea    0x4(%eax),%ecx
  80035f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800362:	8b 00                	mov    (%eax),%eax
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036a:	eb 27                	jmp    800393 <vprintfmt+0xdf>
  80036c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036f:	85 c0                	test   %eax,%eax
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	0f 49 c8             	cmovns %eax,%ecx
  800379:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037f:	eb 8c                	jmp    80030d <vprintfmt+0x59>
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038b:	eb 80                	jmp    80030d <vprintfmt+0x59>
  80038d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	0f 89 70 ff ff ff    	jns    80030d <vprintfmt+0x59>
				width = precision, precision = -1;
  80039d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	e9 5e ff ff ff       	jmp    80030d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b5:	e9 53 ff ff ff       	jmp    80030d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 50 04             	lea    0x4(%eax),%edx
  8003c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	53                   	push   %ebx
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d6                	call   *%esi
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 04 ff ff ff       	jmp    8002da <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 50 04             	lea    0x4(%eax),%edx
  8003dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	99                   	cltd   
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x142>
  8003eb:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 18                	jne    80040e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 7e 23 80 00       	push   $0x80237e
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 94 fe ff ff       	call   800297 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800409:	e9 cc fe ff ff       	jmp    8002da <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	52                   	push   %edx
  80040f:	68 7d 27 80 00       	push   $0x80277d
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 7c fe ff ff       	call   800297 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800421:	e9 b4 fe ff ff       	jmp    8002da <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800431:	85 ff                	test   %edi,%edi
  800433:	b8 77 23 80 00       	mov    $0x802377,%eax
  800438:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043f:	0f 8e 94 00 00 00    	jle    8004d9 <vprintfmt+0x225>
  800445:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800449:	0f 84 98 00 00 00    	je     8004e7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044f:	83 ec 08             	sub    $0x8,%esp
  800452:	ff 75 d0             	pushl  -0x30(%ebp)
  800455:	57                   	push   %edi
  800456:	e8 86 02 00 00       	call   8006e1 <strnlen>
  80045b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045e:	29 c1                	sub    %eax,%ecx
  800460:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800463:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800466:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80046a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800470:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	eb 0f                	jmp    800483 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	53                   	push   %ebx
  800478:	ff 75 e0             	pushl  -0x20(%ebp)
  80047b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	83 ef 01             	sub    $0x1,%edi
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	85 ff                	test   %edi,%edi
  800485:	7f ed                	jg     800474 <vprintfmt+0x1c0>
  800487:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80048a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80048d:	85 c9                	test   %ecx,%ecx
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	0f 49 c1             	cmovns %ecx,%eax
  800497:	29 c1                	sub    %eax,%ecx
  800499:	89 75 08             	mov    %esi,0x8(%ebp)
  80049c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a2:	89 cb                	mov    %ecx,%ebx
  8004a4:	eb 4d                	jmp    8004f3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004aa:	74 1b                	je     8004c7 <vprintfmt+0x213>
  8004ac:	0f be c0             	movsbl %al,%eax
  8004af:	83 e8 20             	sub    $0x20,%eax
  8004b2:	83 f8 5e             	cmp    $0x5e,%eax
  8004b5:	76 10                	jbe    8004c7 <vprintfmt+0x213>
					putch('?', putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	ff 75 0c             	pushl  0xc(%ebp)
  8004bd:	6a 3f                	push   $0x3f
  8004bf:	ff 55 08             	call   *0x8(%ebp)
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	eb 0d                	jmp    8004d4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	52                   	push   %edx
  8004ce:	ff 55 08             	call   *0x8(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d4:	83 eb 01             	sub    $0x1,%ebx
  8004d7:	eb 1a                	jmp    8004f3 <vprintfmt+0x23f>
  8004d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e5:	eb 0c                	jmp    8004f3 <vprintfmt+0x23f>
  8004e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f3:	83 c7 01             	add    $0x1,%edi
  8004f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fa:	0f be d0             	movsbl %al,%edx
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	74 23                	je     800524 <vprintfmt+0x270>
  800501:	85 f6                	test   %esi,%esi
  800503:	78 a1                	js     8004a6 <vprintfmt+0x1f2>
  800505:	83 ee 01             	sub    $0x1,%esi
  800508:	79 9c                	jns    8004a6 <vprintfmt+0x1f2>
  80050a:	89 df                	mov    %ebx,%edi
  80050c:	8b 75 08             	mov    0x8(%ebp),%esi
  80050f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800512:	eb 18                	jmp    80052c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	6a 20                	push   $0x20
  80051a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051c:	83 ef 01             	sub    $0x1,%edi
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	eb 08                	jmp    80052c <vprintfmt+0x278>
  800524:	89 df                	mov    %ebx,%edi
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f e4                	jg     800514 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	e9 a2 fd ff ff       	jmp    8002da <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800538:	83 fa 01             	cmp    $0x1,%edx
  80053b:	7e 16                	jle    800553 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 08             	lea    0x8(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 50 04             	mov    0x4(%eax),%edx
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800551:	eb 32                	jmp    800585 <vprintfmt+0x2d1>
	else if (lflag)
  800553:	85 d2                	test   %edx,%edx
  800555:	74 18                	je     80056f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 04             	lea    0x4(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	eb 16                	jmp    800585 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	89 c1                	mov    %eax,%ecx
  80057f:	c1 f9 1f             	sar    $0x1f,%ecx
  800582:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800585:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800588:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800590:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800594:	79 74                	jns    80060a <vprintfmt+0x356>
				putch('-', putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	6a 2d                	push   $0x2d
  80059c:	ff d6                	call   *%esi
				num = -(long long) num;
  80059e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005a4:	f7 d8                	neg    %eax
  8005a6:	83 d2 00             	adc    $0x0,%edx
  8005a9:	f7 da                	neg    %edx
  8005ab:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005b3:	eb 55                	jmp    80060a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b8:	e8 83 fc ff ff       	call   800240 <getuint>
			base = 10;
  8005bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005c2:	eb 46                	jmp    80060a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 74 fc ff ff       	call   800240 <getuint>
		        base = 8;
  8005cc:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005d1:	eb 37                	jmp    80060a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 30                	push   $0x30
  8005d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 78                	push   $0x78
  8005e1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005fb:	eb 0d                	jmp    80060a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800600:	e8 3b fc ff ff       	call   800240 <getuint>
			base = 16;
  800605:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800611:	57                   	push   %edi
  800612:	ff 75 e0             	pushl  -0x20(%ebp)
  800615:	51                   	push   %ecx
  800616:	52                   	push   %edx
  800617:	50                   	push   %eax
  800618:	89 da                	mov    %ebx,%edx
  80061a:	89 f0                	mov    %esi,%eax
  80061c:	e8 70 fb ff ff       	call   800191 <printnum>
			break;
  800621:	83 c4 20             	add    $0x20,%esp
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800627:	e9 ae fc ff ff       	jmp    8002da <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	51                   	push   %ecx
  800631:	ff d6                	call   *%esi
			break;
  800633:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800639:	e9 9c fc ff ff       	jmp    8002da <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 25                	push   $0x25
  800644:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	eb 03                	jmp    80064e <vprintfmt+0x39a>
  80064b:	83 ef 01             	sub    $0x1,%edi
  80064e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800652:	75 f7                	jne    80064b <vprintfmt+0x397>
  800654:	e9 81 fc ff ff       	jmp    8002da <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	83 ec 18             	sub    $0x18,%esp
  800667:	8b 45 08             	mov    0x8(%ebp),%eax
  80066a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800670:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800674:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067e:	85 c0                	test   %eax,%eax
  800680:	74 26                	je     8006a8 <vsnprintf+0x47>
  800682:	85 d2                	test   %edx,%edx
  800684:	7e 22                	jle    8006a8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800686:	ff 75 14             	pushl  0x14(%ebp)
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068f:	50                   	push   %eax
  800690:	68 7a 02 80 00       	push   $0x80027a
  800695:	e8 1a fc ff ff       	call   8002b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 05                	jmp    8006ad <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    

008006af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b8:	50                   	push   %eax
  8006b9:	ff 75 10             	pushl  0x10(%ebp)
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	ff 75 08             	pushl  0x8(%ebp)
  8006c2:	e8 9a ff ff ff       	call   800661 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	eb 03                	jmp    8006d9 <strlen+0x10>
		n++;
  8006d6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006dd:	75 f7                	jne    8006d6 <strlen+0xd>
		n++;
	return n;
}
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ef:	eb 03                	jmp    8006f4 <strnlen+0x13>
		n++;
  8006f1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f4:	39 c2                	cmp    %eax,%edx
  8006f6:	74 08                	je     800700 <strnlen+0x1f>
  8006f8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006fc:	75 f3                	jne    8006f1 <strnlen+0x10>
  8006fe:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	53                   	push   %ebx
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070c:	89 c2                	mov    %eax,%edx
  80070e:	83 c2 01             	add    $0x1,%edx
  800711:	83 c1 01             	add    $0x1,%ecx
  800714:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800718:	88 5a ff             	mov    %bl,-0x1(%edx)
  80071b:	84 db                	test   %bl,%bl
  80071d:	75 ef                	jne    80070e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80071f:	5b                   	pop    %ebx
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	53                   	push   %ebx
  800726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800729:	53                   	push   %ebx
  80072a:	e8 9a ff ff ff       	call   8006c9 <strlen>
  80072f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	01 d8                	add    %ebx,%eax
  800737:	50                   	push   %eax
  800738:	e8 c5 ff ff ff       	call   800702 <strcpy>
	return dst;
}
  80073d:	89 d8                	mov    %ebx,%eax
  80073f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074f:	89 f3                	mov    %esi,%ebx
  800751:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800754:	89 f2                	mov    %esi,%edx
  800756:	eb 0f                	jmp    800767 <strncpy+0x23>
		*dst++ = *src;
  800758:	83 c2 01             	add    $0x1,%edx
  80075b:	0f b6 01             	movzbl (%ecx),%eax
  80075e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800761:	80 39 01             	cmpb   $0x1,(%ecx)
  800764:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800767:	39 da                	cmp    %ebx,%edx
  800769:	75 ed                	jne    800758 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	56                   	push   %esi
  800775:	53                   	push   %ebx
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	8b 55 10             	mov    0x10(%ebp),%edx
  80077f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800781:	85 d2                	test   %edx,%edx
  800783:	74 21                	je     8007a6 <strlcpy+0x35>
  800785:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800789:	89 f2                	mov    %esi,%edx
  80078b:	eb 09                	jmp    800796 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078d:	83 c2 01             	add    $0x1,%edx
  800790:	83 c1 01             	add    $0x1,%ecx
  800793:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800796:	39 c2                	cmp    %eax,%edx
  800798:	74 09                	je     8007a3 <strlcpy+0x32>
  80079a:	0f b6 19             	movzbl (%ecx),%ebx
  80079d:	84 db                	test   %bl,%bl
  80079f:	75 ec                	jne    80078d <strlcpy+0x1c>
  8007a1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007a6:	29 f0                	sub    %esi,%eax
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b5:	eb 06                	jmp    8007bd <strcmp+0x11>
		p++, q++;
  8007b7:	83 c1 01             	add    $0x1,%ecx
  8007ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bd:	0f b6 01             	movzbl (%ecx),%eax
  8007c0:	84 c0                	test   %al,%al
  8007c2:	74 04                	je     8007c8 <strcmp+0x1c>
  8007c4:	3a 02                	cmp    (%edx),%al
  8007c6:	74 ef                	je     8007b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c8:	0f b6 c0             	movzbl %al,%eax
  8007cb:	0f b6 12             	movzbl (%edx),%edx
  8007ce:	29 d0                	sub    %edx,%eax
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	89 c3                	mov    %eax,%ebx
  8007de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e1:	eb 06                	jmp    8007e9 <strncmp+0x17>
		n--, p++, q++;
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e9:	39 d8                	cmp    %ebx,%eax
  8007eb:	74 15                	je     800802 <strncmp+0x30>
  8007ed:	0f b6 08             	movzbl (%eax),%ecx
  8007f0:	84 c9                	test   %cl,%cl
  8007f2:	74 04                	je     8007f8 <strncmp+0x26>
  8007f4:	3a 0a                	cmp    (%edx),%cl
  8007f6:	74 eb                	je     8007e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f8:	0f b6 00             	movzbl (%eax),%eax
  8007fb:	0f b6 12             	movzbl (%edx),%edx
  8007fe:	29 d0                	sub    %edx,%eax
  800800:	eb 05                	jmp    800807 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800814:	eb 07                	jmp    80081d <strchr+0x13>
		if (*s == c)
  800816:	38 ca                	cmp    %cl,%dl
  800818:	74 0f                	je     800829 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	0f b6 10             	movzbl (%eax),%edx
  800820:	84 d2                	test   %dl,%dl
  800822:	75 f2                	jne    800816 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800835:	eb 03                	jmp    80083a <strfind+0xf>
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80083d:	38 ca                	cmp    %cl,%dl
  80083f:	74 04                	je     800845 <strfind+0x1a>
  800841:	84 d2                	test   %dl,%dl
  800843:	75 f2                	jne    800837 <strfind+0xc>
			break;
	return (char *) s;
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	57                   	push   %edi
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800850:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800853:	85 c9                	test   %ecx,%ecx
  800855:	74 36                	je     80088d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800857:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085d:	75 28                	jne    800887 <memset+0x40>
  80085f:	f6 c1 03             	test   $0x3,%cl
  800862:	75 23                	jne    800887 <memset+0x40>
		c &= 0xFF;
  800864:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800868:	89 d3                	mov    %edx,%ebx
  80086a:	c1 e3 08             	shl    $0x8,%ebx
  80086d:	89 d6                	mov    %edx,%esi
  80086f:	c1 e6 18             	shl    $0x18,%esi
  800872:	89 d0                	mov    %edx,%eax
  800874:	c1 e0 10             	shl    $0x10,%eax
  800877:	09 f0                	or     %esi,%eax
  800879:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80087b:	89 d8                	mov    %ebx,%eax
  80087d:	09 d0                	or     %edx,%eax
  80087f:	c1 e9 02             	shr    $0x2,%ecx
  800882:	fc                   	cld    
  800883:	f3 ab                	rep stos %eax,%es:(%edi)
  800885:	eb 06                	jmp    80088d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088a:	fc                   	cld    
  80088b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088d:	89 f8                	mov    %edi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5f                   	pop    %edi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	57                   	push   %edi
  800898:	56                   	push   %esi
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a2:	39 c6                	cmp    %eax,%esi
  8008a4:	73 35                	jae    8008db <memmove+0x47>
  8008a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a9:	39 d0                	cmp    %edx,%eax
  8008ab:	73 2e                	jae    8008db <memmove+0x47>
		s += n;
		d += n;
  8008ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	09 fe                	or     %edi,%esi
  8008b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ba:	75 13                	jne    8008cf <memmove+0x3b>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	75 0e                	jne    8008cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c1:	83 ef 04             	sub    $0x4,%edi
  8008c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c7:	c1 e9 02             	shr    $0x2,%ecx
  8008ca:	fd                   	std    
  8008cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cd:	eb 09                	jmp    8008d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cf:	83 ef 01             	sub    $0x1,%edi
  8008d2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008d5:	fd                   	std    
  8008d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d8:	fc                   	cld    
  8008d9:	eb 1d                	jmp    8008f8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	89 f2                	mov    %esi,%edx
  8008dd:	09 c2                	or     %eax,%edx
  8008df:	f6 c2 03             	test   $0x3,%dl
  8008e2:	75 0f                	jne    8008f3 <memmove+0x5f>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 0a                	jne    8008f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e9:	c1 e9 02             	shr    $0x2,%ecx
  8008ec:	89 c7                	mov    %eax,%edi
  8008ee:	fc                   	cld    
  8008ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f1:	eb 05                	jmp    8008f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f3:	89 c7                	mov    %eax,%edi
  8008f5:	fc                   	cld    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ff:	ff 75 10             	pushl  0x10(%ebp)
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	ff 75 08             	pushl  0x8(%ebp)
  800908:	e8 87 ff ff ff       	call   800894 <memmove>
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	89 c6                	mov    %eax,%esi
  80091c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091f:	eb 1a                	jmp    80093b <memcmp+0x2c>
		if (*s1 != *s2)
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	0f b6 1a             	movzbl (%edx),%ebx
  800927:	38 d9                	cmp    %bl,%cl
  800929:	74 0a                	je     800935 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80092b:	0f b6 c1             	movzbl %cl,%eax
  80092e:	0f b6 db             	movzbl %bl,%ebx
  800931:	29 d8                	sub    %ebx,%eax
  800933:	eb 0f                	jmp    800944 <memcmp+0x35>
		s1++, s2++;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093b:	39 f0                	cmp    %esi,%eax
  80093d:	75 e2                	jne    800921 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80094f:	89 c1                	mov    %eax,%ecx
  800951:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800954:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800958:	eb 0a                	jmp    800964 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095a:	0f b6 10             	movzbl (%eax),%edx
  80095d:	39 da                	cmp    %ebx,%edx
  80095f:	74 07                	je     800968 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	39 c8                	cmp    %ecx,%eax
  800966:	72 f2                	jb     80095a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800974:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800977:	eb 03                	jmp    80097c <strtol+0x11>
		s++;
  800979:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	0f b6 01             	movzbl (%ecx),%eax
  80097f:	3c 20                	cmp    $0x20,%al
  800981:	74 f6                	je     800979 <strtol+0xe>
  800983:	3c 09                	cmp    $0x9,%al
  800985:	74 f2                	je     800979 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800987:	3c 2b                	cmp    $0x2b,%al
  800989:	75 0a                	jne    800995 <strtol+0x2a>
		s++;
  80098b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098e:	bf 00 00 00 00       	mov    $0x0,%edi
  800993:	eb 11                	jmp    8009a6 <strtol+0x3b>
  800995:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099a:	3c 2d                	cmp    $0x2d,%al
  80099c:	75 08                	jne    8009a6 <strtol+0x3b>
		s++, neg = 1;
  80099e:	83 c1 01             	add    $0x1,%ecx
  8009a1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ac:	75 15                	jne    8009c3 <strtol+0x58>
  8009ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b1:	75 10                	jne    8009c3 <strtol+0x58>
  8009b3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b7:	75 7c                	jne    800a35 <strtol+0xca>
		s += 2, base = 16;
  8009b9:	83 c1 02             	add    $0x2,%ecx
  8009bc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c1:	eb 16                	jmp    8009d9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	75 12                	jne    8009d9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cf:	75 08                	jne    8009d9 <strtol+0x6e>
		s++, base = 8;
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009de:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e1:	0f b6 11             	movzbl (%ecx),%edx
  8009e4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e7:	89 f3                	mov    %esi,%ebx
  8009e9:	80 fb 09             	cmp    $0x9,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x8b>
			dig = *s - '0';
  8009ee:	0f be d2             	movsbl %dl,%edx
  8009f1:	83 ea 30             	sub    $0x30,%edx
  8009f4:	eb 22                	jmp    800a18 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009f6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	80 fb 19             	cmp    $0x19,%bl
  8009fe:	77 08                	ja     800a08 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a00:	0f be d2             	movsbl %dl,%edx
  800a03:	83 ea 57             	sub    $0x57,%edx
  800a06:	eb 10                	jmp    800a18 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a08:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a0b:	89 f3                	mov    %esi,%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 16                	ja     800a28 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a12:	0f be d2             	movsbl %dl,%edx
  800a15:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a18:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a1b:	7d 0b                	jge    800a28 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a1d:	83 c1 01             	add    $0x1,%ecx
  800a20:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a26:	eb b9                	jmp    8009e1 <strtol+0x76>

	if (endptr)
  800a28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2c:	74 0d                	je     800a3b <strtol+0xd0>
		*endptr = (char *) s;
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	89 0e                	mov    %ecx,(%esi)
  800a33:	eb 06                	jmp    800a3b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	74 98                	je     8009d1 <strtol+0x66>
  800a39:	eb 9e                	jmp    8009d9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	f7 da                	neg    %edx
  800a3f:	85 ff                	test   %edi,%edi
  800a41:	0f 45 c2             	cmovne %edx,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5a:	89 c3                	mov    %eax,%ebx
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	89 c6                	mov    %eax,%esi
  800a60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	b8 01 00 00 00       	mov    $0x1,%eax
  800a77:	89 d1                	mov    %edx,%ecx
  800a79:	89 d3                	mov    %edx,%ebx
  800a7b:	89 d7                	mov    %edx,%edi
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a94:	b8 03 00 00 00       	mov    $0x3,%eax
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	89 cb                	mov    %ecx,%ebx
  800a9e:	89 cf                	mov    %ecx,%edi
  800aa0:	89 ce                	mov    %ecx,%esi
  800aa2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	7e 17                	jle    800abf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa8:	83 ec 0c             	sub    $0xc,%esp
  800aab:	50                   	push   %eax
  800aac:	6a 03                	push   $0x3
  800aae:	68 5f 26 80 00       	push   $0x80265f
  800ab3:	6a 23                	push   $0x23
  800ab5:	68 7c 26 80 00       	push   $0x80267c
  800aba:	e8 5f 14 00 00       	call   801f1e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_yield>:

void
sys_yield(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	be 00 00 00 00       	mov    $0x0,%esi
  800b13:	b8 04 00 00 00       	mov    $0x4,%eax
  800b18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b21:	89 f7                	mov    %esi,%edi
  800b23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 17                	jle    800b40 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	50                   	push   %eax
  800b2d:	6a 04                	push   $0x4
  800b2f:	68 5f 26 80 00       	push   $0x80265f
  800b34:	6a 23                	push   $0x23
  800b36:	68 7c 26 80 00       	push   $0x80267c
  800b3b:	e8 de 13 00 00       	call   801f1e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	b8 05 00 00 00       	mov    $0x5,%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b62:	8b 75 18             	mov    0x18(%ebp),%esi
  800b65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b67:	85 c0                	test   %eax,%eax
  800b69:	7e 17                	jle    800b82 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	50                   	push   %eax
  800b6f:	6a 05                	push   $0x5
  800b71:	68 5f 26 80 00       	push   $0x80265f
  800b76:	6a 23                	push   $0x23
  800b78:	68 7c 26 80 00       	push   $0x80267c
  800b7d:	e8 9c 13 00 00       	call   801f1e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b98:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	89 df                	mov    %ebx,%edi
  800ba5:	89 de                	mov    %ebx,%esi
  800ba7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 17                	jle    800bc4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 06                	push   $0x6
  800bb3:	68 5f 26 80 00       	push   $0x80265f
  800bb8:	6a 23                	push   $0x23
  800bba:	68 7c 26 80 00       	push   $0x80267c
  800bbf:	e8 5a 13 00 00       	call   801f1e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bda:	b8 08 00 00 00       	mov    $0x8,%eax
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	89 df                	mov    %ebx,%edi
  800be7:	89 de                	mov    %ebx,%esi
  800be9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7e 17                	jle    800c06 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 08                	push   $0x8
  800bf5:	68 5f 26 80 00       	push   $0x80265f
  800bfa:	6a 23                	push   $0x23
  800bfc:	68 7c 26 80 00       	push   $0x80267c
  800c01:	e8 18 13 00 00       	call   801f1e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	89 df                	mov    %ebx,%edi
  800c29:	89 de                	mov    %ebx,%esi
  800c2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 17                	jle    800c48 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	50                   	push   %eax
  800c35:	6a 09                	push   $0x9
  800c37:	68 5f 26 80 00       	push   $0x80265f
  800c3c:	6a 23                	push   $0x23
  800c3e:	68 7c 26 80 00       	push   $0x80267c
  800c43:	e8 d6 12 00 00       	call   801f1e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 df                	mov    %ebx,%edi
  800c6b:	89 de                	mov    %ebx,%esi
  800c6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 17                	jle    800c8a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 0a                	push   $0xa
  800c79:	68 5f 26 80 00       	push   $0x80265f
  800c7e:	6a 23                	push   $0x23
  800c80:	68 7c 26 80 00       	push   $0x80267c
  800c85:	e8 94 12 00 00       	call   801f1e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	be 00 00 00 00       	mov    $0x0,%esi
  800c9d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cae:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 cb                	mov    %ecx,%ebx
  800ccd:	89 cf                	mov    %ecx,%edi
  800ccf:	89 ce                	mov    %ecx,%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 0d                	push   $0xd
  800cdd:	68 5f 26 80 00       	push   $0x80265f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 7c 26 80 00       	push   $0x80267c
  800ce9:	e8 30 12 00 00       	call   801f1e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800d01:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d06:	89 d1                	mov    %edx,%ecx
  800d08:	89 d3                	mov    %edx,%ebx
  800d0a:	89 d7                	mov    %edx,%edi
  800d0c:	89 d6                	mov    %edx,%esi
  800d0e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d3c:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d43:	75 2c                	jne    800d71 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	6a 07                	push   $0x7
  800d4a:	68 00 f0 bf ee       	push   $0xeebff000
  800d4f:	6a 00                	push   $0x0
  800d51:	e8 af fd ff ff       	call   800b05 <sys_page_alloc>
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	79 14                	jns    800d71 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  800d5d:	83 ec 04             	sub    $0x4,%esp
  800d60:	68 8a 26 80 00       	push   $0x80268a
  800d65:	6a 22                	push   $0x22
  800d67:	68 a1 26 80 00       	push   $0x8026a1
  800d6c:	e8 ad 11 00 00       	call   801f1e <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	a3 0c 40 80 00       	mov    %eax,0x80400c
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d79:	83 ec 08             	sub    $0x8,%esp
  800d7c:	68 a5 0d 80 00       	push   $0x800da5
  800d81:	6a 00                	push   $0x0
  800d83:	e8 c8 fe ff ff       	call   800c50 <sys_env_set_pgfault_upcall>
  800d88:	83 c4 10             	add    $0x10,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	79 14                	jns    800da3 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	68 b0 26 80 00       	push   $0x8026b0
  800d97:	6a 27                	push   $0x27
  800d99:	68 a1 26 80 00       	push   $0x8026a1
  800d9e:	e8 7b 11 00 00       	call   801f1e <_panic>
    
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800da5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800da6:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800dab:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dad:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  800db0:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  800db4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  800db9:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  800dbd:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800dbf:	83 c4 08             	add    $0x8,%esp
	popal
  800dc2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  800dc3:	83 c4 04             	add    $0x4,%esp
	popfl
  800dc6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dc7:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dc8:	c3                   	ret    

00800dc9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd4:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	05 00 00 00 30       	add    $0x30000000,%eax
  800de4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	c1 ea 16             	shr    $0x16,%edx
  800e00:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e07:	f6 c2 01             	test   $0x1,%dl
  800e0a:	74 11                	je     800e1d <fd_alloc+0x2d>
  800e0c:	89 c2                	mov    %eax,%edx
  800e0e:	c1 ea 0c             	shr    $0xc,%edx
  800e11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e18:	f6 c2 01             	test   $0x1,%dl
  800e1b:	75 09                	jne    800e26 <fd_alloc+0x36>
			*fd_store = fd;
  800e1d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e24:	eb 17                	jmp    800e3d <fd_alloc+0x4d>
  800e26:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e2b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e30:	75 c9                	jne    800dfb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e32:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e38:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e45:	83 f8 1f             	cmp    $0x1f,%eax
  800e48:	77 36                	ja     800e80 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e4a:	c1 e0 0c             	shl    $0xc,%eax
  800e4d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e52:	89 c2                	mov    %eax,%edx
  800e54:	c1 ea 16             	shr    $0x16,%edx
  800e57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5e:	f6 c2 01             	test   $0x1,%dl
  800e61:	74 24                	je     800e87 <fd_lookup+0x48>
  800e63:	89 c2                	mov    %eax,%edx
  800e65:	c1 ea 0c             	shr    $0xc,%edx
  800e68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6f:	f6 c2 01             	test   $0x1,%dl
  800e72:	74 1a                	je     800e8e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e77:	89 02                	mov    %eax,(%edx)
	return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	eb 13                	jmp    800e93 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e85:	eb 0c                	jmp    800e93 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8c:	eb 05                	jmp    800e93 <fd_lookup+0x54>
  800e8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9e:	ba 50 27 80 00       	mov    $0x802750,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea3:	eb 13                	jmp    800eb8 <dev_lookup+0x23>
  800ea5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ea8:	39 08                	cmp    %ecx,(%eax)
  800eaa:	75 0c                	jne    800eb8 <dev_lookup+0x23>
			*dev = devtab[i];
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	eb 2e                	jmp    800ee6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb8:	8b 02                	mov    (%edx),%eax
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	75 e7                	jne    800ea5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ebe:	a1 08 40 80 00       	mov    0x804008,%eax
  800ec3:	8b 40 48             	mov    0x48(%eax),%eax
  800ec6:	83 ec 04             	sub    $0x4,%esp
  800ec9:	51                   	push   %ecx
  800eca:	50                   	push   %eax
  800ecb:	68 d4 26 80 00       	push   $0x8026d4
  800ed0:	e8 a8 f2 ff ff       	call   80017d <cprintf>
	*dev = 0;
  800ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee6:	c9                   	leave  
  800ee7:	c3                   	ret    

00800ee8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 10             	sub    $0x10,%esp
  800ef0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef9:	50                   	push   %eax
  800efa:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f00:	c1 e8 0c             	shr    $0xc,%eax
  800f03:	50                   	push   %eax
  800f04:	e8 36 ff ff ff       	call   800e3f <fd_lookup>
  800f09:	83 c4 08             	add    $0x8,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	78 05                	js     800f15 <fd_close+0x2d>
	    || fd != fd2)
  800f10:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f13:	74 0c                	je     800f21 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f15:	84 db                	test   %bl,%bl
  800f17:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1c:	0f 44 c2             	cmove  %edx,%eax
  800f1f:	eb 41                	jmp    800f62 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f21:	83 ec 08             	sub    $0x8,%esp
  800f24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f27:	50                   	push   %eax
  800f28:	ff 36                	pushl  (%esi)
  800f2a:	e8 66 ff ff ff       	call   800e95 <dev_lookup>
  800f2f:	89 c3                	mov    %eax,%ebx
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 1a                	js     800f52 <fd_close+0x6a>
		if (dev->dev_close)
  800f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 0b                	je     800f52 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	56                   	push   %esi
  800f4b:	ff d0                	call   *%eax
  800f4d:	89 c3                	mov    %eax,%ebx
  800f4f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	56                   	push   %esi
  800f56:	6a 00                	push   $0x0
  800f58:	e8 2d fc ff ff       	call   800b8a <sys_page_unmap>
	return r;
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	89 d8                	mov    %ebx,%eax
}
  800f62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	ff 75 08             	pushl  0x8(%ebp)
  800f76:	e8 c4 fe ff ff       	call   800e3f <fd_lookup>
  800f7b:	83 c4 08             	add    $0x8,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 10                	js     800f92 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f82:	83 ec 08             	sub    $0x8,%esp
  800f85:	6a 01                	push   $0x1
  800f87:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8a:	e8 59 ff ff ff       	call   800ee8 <fd_close>
  800f8f:	83 c4 10             	add    $0x10,%esp
}
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <close_all>:

void
close_all(void)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	53                   	push   %ebx
  800f98:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	53                   	push   %ebx
  800fa4:	e8 c0 ff ff ff       	call   800f69 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa9:	83 c3 01             	add    $0x1,%ebx
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	83 fb 20             	cmp    $0x20,%ebx
  800fb2:	75 ec                	jne    800fa0 <close_all+0xc>
		close(i);
}
  800fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 2c             	sub    $0x2c,%esp
  800fc2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 6e fe ff ff       	call   800e3f <fd_lookup>
  800fd1:	83 c4 08             	add    $0x8,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	0f 88 c1 00 00 00    	js     80109d <dup+0xe4>
		return r;
	close(newfdnum);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	56                   	push   %esi
  800fe0:	e8 84 ff ff ff       	call   800f69 <close>

	newfd = INDEX2FD(newfdnum);
  800fe5:	89 f3                	mov    %esi,%ebx
  800fe7:	c1 e3 0c             	shl    $0xc,%ebx
  800fea:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff0:	83 c4 04             	add    $0x4,%esp
  800ff3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff6:	e8 de fd ff ff       	call   800dd9 <fd2data>
  800ffb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ffd:	89 1c 24             	mov    %ebx,(%esp)
  801000:	e8 d4 fd ff ff       	call   800dd9 <fd2data>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100b:	89 f8                	mov    %edi,%eax
  80100d:	c1 e8 16             	shr    $0x16,%eax
  801010:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801017:	a8 01                	test   $0x1,%al
  801019:	74 37                	je     801052 <dup+0x99>
  80101b:	89 f8                	mov    %edi,%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
  801020:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801027:	f6 c2 01             	test   $0x1,%dl
  80102a:	74 26                	je     801052 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	25 07 0e 00 00       	and    $0xe07,%eax
  80103b:	50                   	push   %eax
  80103c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	57                   	push   %edi
  801042:	6a 00                	push   $0x0
  801044:	e8 ff fa ff ff       	call   800b48 <sys_page_map>
  801049:	89 c7                	mov    %eax,%edi
  80104b:	83 c4 20             	add    $0x20,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 2e                	js     801080 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801052:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801055:	89 d0                	mov    %edx,%eax
  801057:	c1 e8 0c             	shr    $0xc,%eax
  80105a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	25 07 0e 00 00       	and    $0xe07,%eax
  801069:	50                   	push   %eax
  80106a:	53                   	push   %ebx
  80106b:	6a 00                	push   $0x0
  80106d:	52                   	push   %edx
  80106e:	6a 00                	push   $0x0
  801070:	e8 d3 fa ff ff       	call   800b48 <sys_page_map>
  801075:	89 c7                	mov    %eax,%edi
  801077:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80107a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107c:	85 ff                	test   %edi,%edi
  80107e:	79 1d                	jns    80109d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	53                   	push   %ebx
  801084:	6a 00                	push   $0x0
  801086:	e8 ff fa ff ff       	call   800b8a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801091:	6a 00                	push   $0x0
  801093:	e8 f2 fa ff ff       	call   800b8a <sys_page_unmap>
	return r;
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	89 f8                	mov    %edi,%eax
}
  80109d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 14             	sub    $0x14,%esp
  8010ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b2:	50                   	push   %eax
  8010b3:	53                   	push   %ebx
  8010b4:	e8 86 fd ff ff       	call   800e3f <fd_lookup>
  8010b9:	83 c4 08             	add    $0x8,%esp
  8010bc:	89 c2                	mov    %eax,%edx
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 6d                	js     80112f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c8:	50                   	push   %eax
  8010c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cc:	ff 30                	pushl  (%eax)
  8010ce:	e8 c2 fd ff ff       	call   800e95 <dev_lookup>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 4c                	js     801126 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010dd:	8b 42 08             	mov    0x8(%edx),%eax
  8010e0:	83 e0 03             	and    $0x3,%eax
  8010e3:	83 f8 01             	cmp    $0x1,%eax
  8010e6:	75 21                	jne    801109 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ed:	8b 40 48             	mov    0x48(%eax),%eax
  8010f0:	83 ec 04             	sub    $0x4,%esp
  8010f3:	53                   	push   %ebx
  8010f4:	50                   	push   %eax
  8010f5:	68 15 27 80 00       	push   $0x802715
  8010fa:	e8 7e f0 ff ff       	call   80017d <cprintf>
		return -E_INVAL;
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801107:	eb 26                	jmp    80112f <read+0x8a>
	}
	if (!dev->dev_read)
  801109:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110c:	8b 40 08             	mov    0x8(%eax),%eax
  80110f:	85 c0                	test   %eax,%eax
  801111:	74 17                	je     80112a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	ff 75 10             	pushl  0x10(%ebp)
  801119:	ff 75 0c             	pushl  0xc(%ebp)
  80111c:	52                   	push   %edx
  80111d:	ff d0                	call   *%eax
  80111f:	89 c2                	mov    %eax,%edx
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	eb 09                	jmp    80112f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801126:	89 c2                	mov    %eax,%edx
  801128:	eb 05                	jmp    80112f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80112a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80112f:	89 d0                	mov    %edx,%eax
  801131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801142:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801145:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114a:	eb 21                	jmp    80116d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	89 f0                	mov    %esi,%eax
  801151:	29 d8                	sub    %ebx,%eax
  801153:	50                   	push   %eax
  801154:	89 d8                	mov    %ebx,%eax
  801156:	03 45 0c             	add    0xc(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	57                   	push   %edi
  80115b:	e8 45 ff ff ff       	call   8010a5 <read>
		if (m < 0)
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 10                	js     801177 <readn+0x41>
			return m;
		if (m == 0)
  801167:	85 c0                	test   %eax,%eax
  801169:	74 0a                	je     801175 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116b:	01 c3                	add    %eax,%ebx
  80116d:	39 f3                	cmp    %esi,%ebx
  80116f:	72 db                	jb     80114c <readn+0x16>
  801171:	89 d8                	mov    %ebx,%eax
  801173:	eb 02                	jmp    801177 <readn+0x41>
  801175:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  80118e:	e8 ac fc ff ff       	call   800e3f <fd_lookup>
  801193:	83 c4 08             	add    $0x8,%esp
  801196:	89 c2                	mov    %eax,%edx
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 68                	js     801204 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a6:	ff 30                	pushl  (%eax)
  8011a8:	e8 e8 fc ff ff       	call   800e95 <dev_lookup>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 47                	js     8011fb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bb:	75 21                	jne    8011de <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bd:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c2:	8b 40 48             	mov    0x48(%eax),%eax
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	53                   	push   %ebx
  8011c9:	50                   	push   %eax
  8011ca:	68 31 27 80 00       	push   $0x802731
  8011cf:	e8 a9 ef ff ff       	call   80017d <cprintf>
		return -E_INVAL;
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011dc:	eb 26                	jmp    801204 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	74 17                	je     8011ff <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	ff 75 10             	pushl  0x10(%ebp)
  8011ee:	ff 75 0c             	pushl  0xc(%ebp)
  8011f1:	50                   	push   %eax
  8011f2:	ff d2                	call   *%edx
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	eb 09                	jmp    801204 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	eb 05                	jmp    801204 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801204:	89 d0                	mov    %edx,%eax
  801206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <seek>:

int
seek(int fdnum, off_t offset)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801211:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	ff 75 08             	pushl  0x8(%ebp)
  801218:	e8 22 fc ff ff       	call   800e3f <fd_lookup>
  80121d:	83 c4 08             	add    $0x8,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 0e                	js     801232 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801224:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	53                   	push   %ebx
  801238:	83 ec 14             	sub    $0x14,%esp
  80123b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	53                   	push   %ebx
  801243:	e8 f7 fb ff ff       	call   800e3f <fd_lookup>
  801248:	83 c4 08             	add    $0x8,%esp
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 65                	js     8012b6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	ff 30                	pushl  (%eax)
  80125d:	e8 33 fc ff ff       	call   800e95 <dev_lookup>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 44                	js     8012ad <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801270:	75 21                	jne    801293 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801272:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	53                   	push   %ebx
  80127e:	50                   	push   %eax
  80127f:	68 f4 26 80 00       	push   $0x8026f4
  801284:	e8 f4 ee ff ff       	call   80017d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801291:	eb 23                	jmp    8012b6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801296:	8b 52 18             	mov    0x18(%edx),%edx
  801299:	85 d2                	test   %edx,%edx
  80129b:	74 14                	je     8012b1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	ff 75 0c             	pushl  0xc(%ebp)
  8012a3:	50                   	push   %eax
  8012a4:	ff d2                	call   *%edx
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	eb 09                	jmp    8012b6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	eb 05                	jmp    8012b6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b6:	89 d0                	mov    %edx,%eax
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 14             	sub    $0x14,%esp
  8012c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	ff 75 08             	pushl  0x8(%ebp)
  8012ce:	e8 6c fb ff ff       	call   800e3f <fd_lookup>
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 58                	js     801334 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e6:	ff 30                	pushl  (%eax)
  8012e8:	e8 a8 fb ff ff       	call   800e95 <dev_lookup>
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 37                	js     80132b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fb:	74 32                	je     80132f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801300:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801307:	00 00 00 
	stat->st_isdir = 0;
  80130a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801311:	00 00 00 
	stat->st_dev = dev;
  801314:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	53                   	push   %ebx
  80131e:	ff 75 f0             	pushl  -0x10(%ebp)
  801321:	ff 50 14             	call   *0x14(%eax)
  801324:	89 c2                	mov    %eax,%edx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	eb 09                	jmp    801334 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	eb 05                	jmp    801334 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80132f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801334:	89 d0                	mov    %edx,%eax
  801336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	6a 00                	push   $0x0
  801345:	ff 75 08             	pushl  0x8(%ebp)
  801348:	e8 e7 01 00 00       	call   801534 <open>
  80134d:	89 c3                	mov    %eax,%ebx
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 1b                	js     801371 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	50                   	push   %eax
  80135d:	e8 5b ff ff ff       	call   8012bd <fstat>
  801362:	89 c6                	mov    %eax,%esi
	close(fd);
  801364:	89 1c 24             	mov    %ebx,(%esp)
  801367:	e8 fd fb ff ff       	call   800f69 <close>
	return r;
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	89 f0                	mov    %esi,%eax
}
  801371:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	89 c6                	mov    %eax,%esi
  80137f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801381:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801388:	75 12                	jne    80139c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	6a 01                	push   $0x1
  80138f:	e8 91 0c 00 00       	call   802025 <ipc_find_env>
  801394:	a3 00 40 80 00       	mov    %eax,0x804000
  801399:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139c:	6a 07                	push   $0x7
  80139e:	68 00 50 80 00       	push   $0x805000
  8013a3:	56                   	push   %esi
  8013a4:	ff 35 00 40 80 00    	pushl  0x804000
  8013aa:	e8 22 0c 00 00       	call   801fd1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013af:	83 c4 0c             	add    $0xc,%esp
  8013b2:	6a 00                	push   $0x0
  8013b4:	53                   	push   %ebx
  8013b5:	6a 00                	push   $0x0
  8013b7:	e8 a8 0b 00 00       	call   801f64 <ipc_recv>
}
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e1:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e6:	e8 8d ff ff ff       	call   801378 <fsipc>
}
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801403:	b8 06 00 00 00       	mov    $0x6,%eax
  801408:	e8 6b ff ff ff       	call   801378 <fsipc>
}
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 04             	sub    $0x4,%esp
  801416:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
  80141c:	8b 40 0c             	mov    0xc(%eax),%eax
  80141f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 05 00 00 00       	mov    $0x5,%eax
  80142e:	e8 45 ff ff ff       	call   801378 <fsipc>
  801433:	85 c0                	test   %eax,%eax
  801435:	78 2c                	js     801463 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	68 00 50 80 00       	push   $0x805000
  80143f:	53                   	push   %ebx
  801440:	e8 bd f2 ff ff       	call   800702 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801445:	a1 80 50 80 00       	mov    0x805080,%eax
  80144a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801450:	a1 84 50 80 00       	mov    0x805084,%eax
  801455:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801472:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801477:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80147c:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80147f:	53                   	push   %ebx
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	68 08 50 80 00       	push   $0x805008
  801488:	e8 07 f4 ff ff       	call   800894 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	8b 40 0c             	mov    0xc(%eax),%eax
  801493:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801498:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80149e:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a8:	e8 cb fe ff ff       	call   801378 <fsipc>
	//panic("devfile_write not implemented");
}
  8014ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	56                   	push   %esi
  8014b6:	53                   	push   %ebx
  8014b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014d5:	e8 9e fe ff ff       	call   801378 <fsipc>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 4b                	js     80152b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014e0:	39 c6                	cmp    %eax,%esi
  8014e2:	73 16                	jae    8014fa <devfile_read+0x48>
  8014e4:	68 64 27 80 00       	push   $0x802764
  8014e9:	68 6b 27 80 00       	push   $0x80276b
  8014ee:	6a 7c                	push   $0x7c
  8014f0:	68 80 27 80 00       	push   $0x802780
  8014f5:	e8 24 0a 00 00       	call   801f1e <_panic>
	assert(r <= PGSIZE);
  8014fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ff:	7e 16                	jle    801517 <devfile_read+0x65>
  801501:	68 8b 27 80 00       	push   $0x80278b
  801506:	68 6b 27 80 00       	push   $0x80276b
  80150b:	6a 7d                	push   $0x7d
  80150d:	68 80 27 80 00       	push   $0x802780
  801512:	e8 07 0a 00 00       	call   801f1e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	50                   	push   %eax
  80151b:	68 00 50 80 00       	push   $0x805000
  801520:	ff 75 0c             	pushl  0xc(%ebp)
  801523:	e8 6c f3 ff ff       	call   800894 <memmove>
	return r;
  801528:	83 c4 10             	add    $0x10,%esp
}
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 20             	sub    $0x20,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80153e:	53                   	push   %ebx
  80153f:	e8 85 f1 ff ff       	call   8006c9 <strlen>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80154c:	7f 67                	jg     8015b5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	e8 96 f8 ff ff       	call   800df0 <fd_alloc>
  80155a:	83 c4 10             	add    $0x10,%esp
		return r;
  80155d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 57                	js     8015ba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	53                   	push   %ebx
  801567:	68 00 50 80 00       	push   $0x805000
  80156c:	e8 91 f1 ff ff       	call   800702 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801571:	8b 45 0c             	mov    0xc(%ebp),%eax
  801574:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801579:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157c:	b8 01 00 00 00       	mov    $0x1,%eax
  801581:	e8 f2 fd ff ff       	call   801378 <fsipc>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 14                	jns    8015a3 <open+0x6f>
		fd_close(fd, 0);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	6a 00                	push   $0x0
  801594:	ff 75 f4             	pushl  -0xc(%ebp)
  801597:	e8 4c f9 ff ff       	call   800ee8 <fd_close>
		return r;
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	89 da                	mov    %ebx,%edx
  8015a1:	eb 17                	jmp    8015ba <open+0x86>
	}

	return fd2num(fd);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a9:	e8 1b f8 ff ff       	call   800dc9 <fd2num>
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 05                	jmp    8015ba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d1:	e8 a2 fd ff ff       	call   801378 <fsipc>
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015de:	68 97 27 80 00       	push   $0x802797
  8015e3:	ff 75 0c             	pushl  0xc(%ebp)
  8015e6:	e8 17 f1 ff ff       	call   800702 <strcpy>
	return 0;
}
  8015eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 10             	sub    $0x10,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015fc:	53                   	push   %ebx
  8015fd:	e8 5c 0a 00 00       	call   80205e <pageref>
  801602:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80160a:	83 f8 01             	cmp    $0x1,%eax
  80160d:	75 10                	jne    80161f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80160f:	83 ec 0c             	sub    $0xc,%esp
  801612:	ff 73 0c             	pushl  0xc(%ebx)
  801615:	e8 c0 02 00 00       	call   8018da <nsipc_close>
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80161f:	89 d0                	mov    %edx,%eax
  801621:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80162c:	6a 00                	push   $0x0
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	ff 75 0c             	pushl  0xc(%ebp)
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	ff 70 0c             	pushl  0xc(%eax)
  80163a:	e8 78 03 00 00       	call   8019b7 <nsipc_send>
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801647:	6a 00                	push   $0x0
  801649:	ff 75 10             	pushl  0x10(%ebp)
  80164c:	ff 75 0c             	pushl  0xc(%ebp)
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	ff 70 0c             	pushl  0xc(%eax)
  801655:	e8 f1 02 00 00       	call   80194b <nsipc_recv>
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801662:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801665:	52                   	push   %edx
  801666:	50                   	push   %eax
  801667:	e8 d3 f7 ff ff       	call   800e3f <fd_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 17                	js     80168a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801676:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80167c:	39 08                	cmp    %ecx,(%eax)
  80167e:	75 05                	jne    801685 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801680:	8b 40 0c             	mov    0xc(%eax),%eax
  801683:	eb 05                	jmp    80168a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 1c             	sub    $0x1c,%esp
  801694:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	e8 51 f7 ff ff       	call   800df0 <fd_alloc>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 1b                	js     8016c3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	68 07 04 00 00       	push   $0x407
  8016b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b3:	6a 00                	push   $0x0
  8016b5:	e8 4b f4 ff ff       	call   800b05 <sys_page_alloc>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	79 10                	jns    8016d3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	56                   	push   %esi
  8016c7:	e8 0e 02 00 00       	call   8018da <nsipc_close>
		return r;
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	89 d8                	mov    %ebx,%eax
  8016d1:	eb 24                	jmp    8016f7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016d3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016dc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016e8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	50                   	push   %eax
  8016ef:	e8 d5 f6 ff ff       	call   800dc9 <fd2num>
  8016f4:	83 c4 10             	add    $0x10,%esp
}
  8016f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	e8 50 ff ff ff       	call   80165c <fd2sockid>
		return r;
  80170c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 1f                	js     801731 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	ff 75 10             	pushl  0x10(%ebp)
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	e8 12 01 00 00       	call   801833 <nsipc_accept>
  801721:	83 c4 10             	add    $0x10,%esp
		return r;
  801724:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801726:	85 c0                	test   %eax,%eax
  801728:	78 07                	js     801731 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80172a:	e8 5d ff ff ff       	call   80168c <alloc_sockfd>
  80172f:	89 c1                	mov    %eax,%ecx
}
  801731:	89 c8                	mov    %ecx,%eax
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	e8 19 ff ff ff       	call   80165c <fd2sockid>
  801743:	85 c0                	test   %eax,%eax
  801745:	78 12                	js     801759 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	ff 75 10             	pushl  0x10(%ebp)
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	50                   	push   %eax
  801751:	e8 2d 01 00 00       	call   801883 <nsipc_bind>
  801756:	83 c4 10             	add    $0x10,%esp
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <shutdown>:

int
shutdown(int s, int how)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801761:	8b 45 08             	mov    0x8(%ebp),%eax
  801764:	e8 f3 fe ff ff       	call   80165c <fd2sockid>
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 0f                	js     80177c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	50                   	push   %eax
  801774:	e8 3f 01 00 00       	call   8018b8 <nsipc_shutdown>
  801779:	83 c4 10             	add    $0x10,%esp
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	e8 d0 fe ff ff       	call   80165c <fd2sockid>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 12                	js     8017a2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	ff 75 10             	pushl  0x10(%ebp)
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	e8 55 01 00 00       	call   8018f4 <nsipc_connect>
  80179f:	83 c4 10             	add    $0x10,%esp
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <listen>:

int
listen(int s, int backlog)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	e8 aa fe ff ff       	call   80165c <fd2sockid>
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 0f                	js     8017c5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	ff 75 0c             	pushl  0xc(%ebp)
  8017bc:	50                   	push   %eax
  8017bd:	e8 67 01 00 00       	call   801929 <nsipc_listen>
  8017c2:	83 c4 10             	add    $0x10,%esp
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017cd:	ff 75 10             	pushl  0x10(%ebp)
  8017d0:	ff 75 0c             	pushl  0xc(%ebp)
  8017d3:	ff 75 08             	pushl  0x8(%ebp)
  8017d6:	e8 3a 02 00 00       	call   801a15 <nsipc_socket>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 05                	js     8017e7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017e2:	e8 a5 fe ff ff       	call   80168c <alloc_sockfd>
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017f2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017f9:	75 12                	jne    80180d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	6a 02                	push   $0x2
  801800:	e8 20 08 00 00       	call   802025 <ipc_find_env>
  801805:	a3 04 40 80 00       	mov    %eax,0x804004
  80180a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80180d:	6a 07                	push   $0x7
  80180f:	68 00 60 80 00       	push   $0x806000
  801814:	53                   	push   %ebx
  801815:	ff 35 04 40 80 00    	pushl  0x804004
  80181b:	e8 b1 07 00 00       	call   801fd1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801820:	83 c4 0c             	add    $0xc,%esp
  801823:	6a 00                	push   $0x0
  801825:	6a 00                	push   $0x0
  801827:	6a 00                	push   $0x0
  801829:	e8 36 07 00 00       	call   801f64 <ipc_recv>
}
  80182e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801843:	8b 06                	mov    (%esi),%eax
  801845:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80184a:	b8 01 00 00 00       	mov    $0x1,%eax
  80184f:	e8 95 ff ff ff       	call   8017e9 <nsipc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	85 c0                	test   %eax,%eax
  801858:	78 20                	js     80187a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80185a:	83 ec 04             	sub    $0x4,%esp
  80185d:	ff 35 10 60 80 00    	pushl  0x806010
  801863:	68 00 60 80 00       	push   $0x806000
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	e8 24 f0 ff ff       	call   800894 <memmove>
		*addrlen = ret->ret_addrlen;
  801870:	a1 10 60 80 00       	mov    0x806010,%eax
  801875:	89 06                	mov    %eax,(%esi)
  801877:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	53                   	push   %ebx
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801895:	53                   	push   %ebx
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	68 04 60 80 00       	push   $0x806004
  80189e:	e8 f1 ef ff ff       	call   800894 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018a3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ae:	e8 36 ff ff ff       	call   8017e9 <nsipc>
}
  8018b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d3:	e8 11 ff ff ff       	call   8017e9 <nsipc>
}
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <nsipc_close>:

int
nsipc_close(int s)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ed:	e8 f7 fe ff ff       	call   8017e9 <nsipc>
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801906:	53                   	push   %ebx
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	68 04 60 80 00       	push   $0x806004
  80190f:	e8 80 ef ff ff       	call   800894 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801914:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80191a:	b8 05 00 00 00       	mov    $0x5,%eax
  80191f:	e8 c5 fe ff ff       	call   8017e9 <nsipc>
}
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80193f:	b8 06 00 00 00       	mov    $0x6,%eax
  801944:	e8 a0 fe ff ff       	call   8017e9 <nsipc>
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
  801950:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801953:	8b 45 08             	mov    0x8(%ebp),%eax
  801956:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80195b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801961:	8b 45 14             	mov    0x14(%ebp),%eax
  801964:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801969:	b8 07 00 00 00       	mov    $0x7,%eax
  80196e:	e8 76 fe ff ff       	call   8017e9 <nsipc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	85 c0                	test   %eax,%eax
  801977:	78 35                	js     8019ae <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801979:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80197e:	7f 04                	jg     801984 <nsipc_recv+0x39>
  801980:	39 c6                	cmp    %eax,%esi
  801982:	7d 16                	jge    80199a <nsipc_recv+0x4f>
  801984:	68 a3 27 80 00       	push   $0x8027a3
  801989:	68 6b 27 80 00       	push   $0x80276b
  80198e:	6a 62                	push   $0x62
  801990:	68 b8 27 80 00       	push   $0x8027b8
  801995:	e8 84 05 00 00       	call   801f1e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80199a:	83 ec 04             	sub    $0x4,%esp
  80199d:	50                   	push   %eax
  80199e:	68 00 60 80 00       	push   $0x806000
  8019a3:	ff 75 0c             	pushl  0xc(%ebp)
  8019a6:	e8 e9 ee ff ff       	call   800894 <memmove>
  8019ab:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019ae:	89 d8                	mov    %ebx,%eax
  8019b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b3:	5b                   	pop    %ebx
  8019b4:	5e                   	pop    %esi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 04             	sub    $0x4,%esp
  8019be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019c9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019cf:	7e 16                	jle    8019e7 <nsipc_send+0x30>
  8019d1:	68 c4 27 80 00       	push   $0x8027c4
  8019d6:	68 6b 27 80 00       	push   $0x80276b
  8019db:	6a 6d                	push   $0x6d
  8019dd:	68 b8 27 80 00       	push   $0x8027b8
  8019e2:	e8 37 05 00 00       	call   801f1e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	53                   	push   %ebx
  8019eb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ee:	68 0c 60 80 00       	push   $0x80600c
  8019f3:	e8 9c ee ff ff       	call   800894 <memmove>
	nsipcbuf.send.req_size = size;
  8019f8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801a01:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a06:	b8 08 00 00 00       	mov    $0x8,%eax
  801a0b:	e8 d9 fd ff ff       	call   8017e9 <nsipc>
}
  801a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a26:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a33:	b8 09 00 00 00       	mov    $0x9,%eax
  801a38:	e8 ac fd ff ff       	call   8017e9 <nsipc>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	ff 75 08             	pushl  0x8(%ebp)
  801a4d:	e8 87 f3 ff ff       	call   800dd9 <fd2data>
  801a52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a54:	83 c4 08             	add    $0x8,%esp
  801a57:	68 d0 27 80 00       	push   $0x8027d0
  801a5c:	53                   	push   %ebx
  801a5d:	e8 a0 ec ff ff       	call   800702 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a62:	8b 46 04             	mov    0x4(%esi),%eax
  801a65:	2b 06                	sub    (%esi),%eax
  801a67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a74:	00 00 00 
	stat->st_dev = &devpipe;
  801a77:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a7e:	30 80 00 
	return 0;
}
  801a81:	b8 00 00 00 00       	mov    $0x0,%eax
  801a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    

00801a8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	53                   	push   %ebx
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a97:	53                   	push   %ebx
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 eb f0 ff ff       	call   800b8a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a9f:	89 1c 24             	mov    %ebx,(%esp)
  801aa2:	e8 32 f3 ff ff       	call   800dd9 <fd2data>
  801aa7:	83 c4 08             	add    $0x8,%esp
  801aaa:	50                   	push   %eax
  801aab:	6a 00                	push   $0x0
  801aad:	e8 d8 f0 ff ff       	call   800b8a <sys_page_unmap>
}
  801ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	83 ec 1c             	sub    $0x1c,%esp
  801ac0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac5:	a1 08 40 80 00       	mov    0x804008,%eax
  801aca:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad3:	e8 86 05 00 00       	call   80205e <pageref>
  801ad8:	89 c3                	mov    %eax,%ebx
  801ada:	89 3c 24             	mov    %edi,(%esp)
  801add:	e8 7c 05 00 00       	call   80205e <pageref>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	39 c3                	cmp    %eax,%ebx
  801ae7:	0f 94 c1             	sete   %cl
  801aea:	0f b6 c9             	movzbl %cl,%ecx
  801aed:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801af6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801af9:	39 ce                	cmp    %ecx,%esi
  801afb:	74 1b                	je     801b18 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801afd:	39 c3                	cmp    %eax,%ebx
  801aff:	75 c4                	jne    801ac5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b01:	8b 42 58             	mov    0x58(%edx),%eax
  801b04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b07:	50                   	push   %eax
  801b08:	56                   	push   %esi
  801b09:	68 d7 27 80 00       	push   $0x8027d7
  801b0e:	e8 6a e6 ff ff       	call   80017d <cprintf>
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	eb ad                	jmp    801ac5 <_pipeisclosed+0xe>
	}
}
  801b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	57                   	push   %edi
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	83 ec 28             	sub    $0x28,%esp
  801b2c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b2f:	56                   	push   %esi
  801b30:	e8 a4 f2 ff ff       	call   800dd9 <fd2data>
  801b35:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b3f:	eb 4b                	jmp    801b8c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b41:	89 da                	mov    %ebx,%edx
  801b43:	89 f0                	mov    %esi,%eax
  801b45:	e8 6d ff ff ff       	call   801ab7 <_pipeisclosed>
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	75 48                	jne    801b96 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b4e:	e8 93 ef ff ff       	call   800ae6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b53:	8b 43 04             	mov    0x4(%ebx),%eax
  801b56:	8b 0b                	mov    (%ebx),%ecx
  801b58:	8d 51 20             	lea    0x20(%ecx),%edx
  801b5b:	39 d0                	cmp    %edx,%eax
  801b5d:	73 e2                	jae    801b41 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b62:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b66:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	c1 fa 1f             	sar    $0x1f,%edx
  801b6e:	89 d1                	mov    %edx,%ecx
  801b70:	c1 e9 1b             	shr    $0x1b,%ecx
  801b73:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b76:	83 e2 1f             	and    $0x1f,%edx
  801b79:	29 ca                	sub    %ecx,%edx
  801b7b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b7f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b83:	83 c0 01             	add    $0x1,%eax
  801b86:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b89:	83 c7 01             	add    $0x1,%edi
  801b8c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8f:	75 c2                	jne    801b53 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b91:	8b 45 10             	mov    0x10(%ebp),%eax
  801b94:	eb 05                	jmp    801b9b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5f                   	pop    %edi
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	57                   	push   %edi
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 18             	sub    $0x18,%esp
  801bac:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801baf:	57                   	push   %edi
  801bb0:	e8 24 f2 ff ff       	call   800dd9 <fd2data>
  801bb5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbf:	eb 3d                	jmp    801bfe <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc1:	85 db                	test   %ebx,%ebx
  801bc3:	74 04                	je     801bc9 <devpipe_read+0x26>
				return i;
  801bc5:	89 d8                	mov    %ebx,%eax
  801bc7:	eb 44                	jmp    801c0d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc9:	89 f2                	mov    %esi,%edx
  801bcb:	89 f8                	mov    %edi,%eax
  801bcd:	e8 e5 fe ff ff       	call   801ab7 <_pipeisclosed>
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	75 32                	jne    801c08 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd6:	e8 0b ef ff ff       	call   800ae6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bdb:	8b 06                	mov    (%esi),%eax
  801bdd:	3b 46 04             	cmp    0x4(%esi),%eax
  801be0:	74 df                	je     801bc1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be2:	99                   	cltd   
  801be3:	c1 ea 1b             	shr    $0x1b,%edx
  801be6:	01 d0                	add    %edx,%eax
  801be8:	83 e0 1f             	and    $0x1f,%eax
  801beb:	29 d0                	sub    %edx,%eax
  801bed:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bf8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfb:	83 c3 01             	add    $0x1,%ebx
  801bfe:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c01:	75 d8                	jne    801bdb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c03:	8b 45 10             	mov    0x10(%ebp),%eax
  801c06:	eb 05                	jmp    801c0d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c10:	5b                   	pop    %ebx
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	56                   	push   %esi
  801c19:	53                   	push   %ebx
  801c1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c20:	50                   	push   %eax
  801c21:	e8 ca f1 ff ff       	call   800df0 <fd_alloc>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 c2                	mov    %eax,%edx
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	0f 88 2c 01 00 00    	js     801d5f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c33:	83 ec 04             	sub    $0x4,%esp
  801c36:	68 07 04 00 00       	push   $0x407
  801c3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 c0 ee ff ff       	call   800b05 <sys_page_alloc>
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	89 c2                	mov    %eax,%edx
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	0f 88 0d 01 00 00    	js     801d5f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c52:	83 ec 0c             	sub    $0xc,%esp
  801c55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c58:	50                   	push   %eax
  801c59:	e8 92 f1 ff ff       	call   800df0 <fd_alloc>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	0f 88 e2 00 00 00    	js     801d4d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6b:	83 ec 04             	sub    $0x4,%esp
  801c6e:	68 07 04 00 00       	push   $0x407
  801c73:	ff 75 f0             	pushl  -0x10(%ebp)
  801c76:	6a 00                	push   $0x0
  801c78:	e8 88 ee ff ff       	call   800b05 <sys_page_alloc>
  801c7d:	89 c3                	mov    %eax,%ebx
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	85 c0                	test   %eax,%eax
  801c84:	0f 88 c3 00 00 00    	js     801d4d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c8a:	83 ec 0c             	sub    $0xc,%esp
  801c8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c90:	e8 44 f1 ff ff       	call   800dd9 <fd2data>
  801c95:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c97:	83 c4 0c             	add    $0xc,%esp
  801c9a:	68 07 04 00 00       	push   $0x407
  801c9f:	50                   	push   %eax
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 5e ee ff ff       	call   800b05 <sys_page_alloc>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	0f 88 89 00 00 00    	js     801d3d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cba:	e8 1a f1 ff ff       	call   800dd9 <fd2data>
  801cbf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc6:	50                   	push   %eax
  801cc7:	6a 00                	push   $0x0
  801cc9:	56                   	push   %esi
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 77 ee ff ff       	call   800b48 <sys_page_map>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	83 c4 20             	add    $0x20,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 55                	js     801d2f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cda:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cef:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0a:	e8 ba f0 ff ff       	call   800dc9 <fd2num>
  801d0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d12:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d14:	83 c4 04             	add    $0x4,%esp
  801d17:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1a:	e8 aa f0 ff ff       	call   800dc9 <fd2num>
  801d1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d22:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2d:	eb 30                	jmp    801d5f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d2f:	83 ec 08             	sub    $0x8,%esp
  801d32:	56                   	push   %esi
  801d33:	6a 00                	push   $0x0
  801d35:	e8 50 ee ff ff       	call   800b8a <sys_page_unmap>
  801d3a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	ff 75 f0             	pushl  -0x10(%ebp)
  801d43:	6a 00                	push   $0x0
  801d45:	e8 40 ee ff ff       	call   800b8a <sys_page_unmap>
  801d4a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4d:	83 ec 08             	sub    $0x8,%esp
  801d50:	ff 75 f4             	pushl  -0xc(%ebp)
  801d53:	6a 00                	push   $0x0
  801d55:	e8 30 ee ff ff       	call   800b8a <sys_page_unmap>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d5f:	89 d0                	mov    %edx,%eax
  801d61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d71:	50                   	push   %eax
  801d72:	ff 75 08             	pushl  0x8(%ebp)
  801d75:	e8 c5 f0 ff ff       	call   800e3f <fd_lookup>
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	78 18                	js     801d99 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d81:	83 ec 0c             	sub    $0xc,%esp
  801d84:	ff 75 f4             	pushl  -0xc(%ebp)
  801d87:	e8 4d f0 ff ff       	call   800dd9 <fd2data>
	return _pipeisclosed(fd, p);
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d91:	e8 21 fd ff ff       	call   801ab7 <_pipeisclosed>
  801d96:	83 c4 10             	add    $0x10,%esp
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dab:	68 ef 27 80 00       	push   $0x8027ef
  801db0:	ff 75 0c             	pushl  0xc(%ebp)
  801db3:	e8 4a e9 ff ff       	call   800702 <strcpy>
	return 0;
}
  801db8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	57                   	push   %edi
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd6:	eb 2d                	jmp    801e05 <devcons_write+0x46>
		m = n - tot;
  801dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ddd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801de0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	53                   	push   %ebx
  801dec:	03 45 0c             	add    0xc(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	57                   	push   %edi
  801df1:	e8 9e ea ff ff       	call   800894 <memmove>
		sys_cputs(buf, m);
  801df6:	83 c4 08             	add    $0x8,%esp
  801df9:	53                   	push   %ebx
  801dfa:	57                   	push   %edi
  801dfb:	e8 49 ec ff ff       	call   800a49 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e00:	01 de                	add    %ebx,%esi
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0a:	72 cc                	jb     801dd8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e23:	74 2a                	je     801e4f <devcons_read+0x3b>
  801e25:	eb 05                	jmp    801e2c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e27:	e8 ba ec ff ff       	call   800ae6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2c:	e8 36 ec ff ff       	call   800a67 <sys_cgetc>
  801e31:	85 c0                	test   %eax,%eax
  801e33:	74 f2                	je     801e27 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 16                	js     801e4f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e39:	83 f8 04             	cmp    $0x4,%eax
  801e3c:	74 0c                	je     801e4a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e41:	88 02                	mov    %al,(%edx)
	return 1;
  801e43:	b8 01 00 00 00       	mov    $0x1,%eax
  801e48:	eb 05                	jmp    801e4f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5d:	6a 01                	push   $0x1
  801e5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e62:	50                   	push   %eax
  801e63:	e8 e1 eb ff ff       	call   800a49 <sys_cputs>
}
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <getchar>:

int
getchar(void)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e73:	6a 01                	push   $0x1
  801e75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	6a 00                	push   $0x0
  801e7b:	e8 25 f2 ff ff       	call   8010a5 <read>
	if (r < 0)
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 0f                	js     801e96 <getchar+0x29>
		return r;
	if (r < 1)
  801e87:	85 c0                	test   %eax,%eax
  801e89:	7e 06                	jle    801e91 <getchar+0x24>
		return -E_EOF;
	return c;
  801e8b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e8f:	eb 05                	jmp    801e96 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e91:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea1:	50                   	push   %eax
  801ea2:	ff 75 08             	pushl  0x8(%ebp)
  801ea5:	e8 95 ef ff ff       	call   800e3f <fd_lookup>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 11                	js     801ec2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eba:	39 10                	cmp    %edx,(%eax)
  801ebc:	0f 94 c0             	sete   %al
  801ebf:	0f b6 c0             	movzbl %al,%eax
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <opencons>:

int
opencons(void)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecd:	50                   	push   %eax
  801ece:	e8 1d ef ff ff       	call   800df0 <fd_alloc>
  801ed3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 3e                	js     801f1a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	68 07 04 00 00       	push   $0x407
  801ee4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee7:	6a 00                	push   $0x0
  801ee9:	e8 17 ec ff ff       	call   800b05 <sys_page_alloc>
  801eee:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	78 23                	js     801f1a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ef7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f00:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	50                   	push   %eax
  801f10:	e8 b4 ee ff ff       	call   800dc9 <fd2num>
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	83 c4 10             	add    $0x10,%esp
}
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	56                   	push   %esi
  801f22:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f23:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f26:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f2c:	e8 96 eb ff ff       	call   800ac7 <sys_getenvid>
  801f31:	83 ec 0c             	sub    $0xc,%esp
  801f34:	ff 75 0c             	pushl  0xc(%ebp)
  801f37:	ff 75 08             	pushl  0x8(%ebp)
  801f3a:	56                   	push   %esi
  801f3b:	50                   	push   %eax
  801f3c:	68 fc 27 80 00       	push   $0x8027fc
  801f41:	e8 37 e2 ff ff       	call   80017d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f46:	83 c4 18             	add    $0x18,%esp
  801f49:	53                   	push   %ebx
  801f4a:	ff 75 10             	pushl  0x10(%ebp)
  801f4d:	e8 da e1 ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  801f52:	c7 04 24 e8 27 80 00 	movl   $0x8027e8,(%esp)
  801f59:	e8 1f e2 ff ff       	call   80017d <cprintf>
  801f5e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f61:	cc                   	int3   
  801f62:	eb fd                	jmp    801f61 <_panic+0x43>

00801f64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	56                   	push   %esi
  801f68:	53                   	push   %ebx
  801f69:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	74 0e                	je     801f84 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	50                   	push   %eax
  801f7a:	e8 36 ed ff ff       	call   800cb5 <sys_ipc_recv>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	eb 10                	jmp    801f94 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	68 00 00 00 f0       	push   $0xf0000000
  801f8c:	e8 24 ed ff ff       	call   800cb5 <sys_ipc_recv>
  801f91:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801f94:	85 c0                	test   %eax,%eax
  801f96:	74 0e                	je     801fa6 <ipc_recv+0x42>
    	*from_env_store = 0;
  801f98:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801f9e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801fa4:	eb 24                	jmp    801fca <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801fa6:	85 f6                	test   %esi,%esi
  801fa8:	74 0a                	je     801fb4 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801faa:	a1 08 40 80 00       	mov    0x804008,%eax
  801faf:	8b 40 74             	mov    0x74(%eax),%eax
  801fb2:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801fb4:	85 db                	test   %ebx,%ebx
  801fb6:	74 0a                	je     801fc2 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801fb8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fbd:	8b 40 78             	mov    0x78(%eax),%eax
  801fc0:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801fc2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801fca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	57                   	push   %edi
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
  801fd7:	83 ec 0c             	sub    $0xc,%esp
  801fda:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801fe3:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801fe5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fea:	0f 44 d8             	cmove  %eax,%ebx
  801fed:	eb 1c                	jmp    80200b <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801fef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff2:	74 12                	je     802006 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801ff4:	50                   	push   %eax
  801ff5:	68 20 28 80 00       	push   $0x802820
  801ffa:	6a 4b                	push   $0x4b
  801ffc:	68 38 28 80 00       	push   $0x802838
  802001:	e8 18 ff ff ff       	call   801f1e <_panic>
        }	
        sys_yield();
  802006:	e8 db ea ff ff       	call   800ae6 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80200b:	ff 75 14             	pushl  0x14(%ebp)
  80200e:	53                   	push   %ebx
  80200f:	56                   	push   %esi
  802010:	57                   	push   %edi
  802011:	e8 7c ec ff ff       	call   800c92 <sys_ipc_try_send>
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	85 c0                	test   %eax,%eax
  80201b:	75 d2                	jne    801fef <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80201d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    

00802025 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802030:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802033:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802039:	8b 52 50             	mov    0x50(%edx),%edx
  80203c:	39 ca                	cmp    %ecx,%edx
  80203e:	75 0d                	jne    80204d <ipc_find_env+0x28>
			return envs[i].env_id;
  802040:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802043:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802048:	8b 40 48             	mov    0x48(%eax),%eax
  80204b:	eb 0f                	jmp    80205c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80204d:	83 c0 01             	add    $0x1,%eax
  802050:	3d 00 04 00 00       	cmp    $0x400,%eax
  802055:	75 d9                	jne    802030 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802057:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802064:	89 d0                	mov    %edx,%eax
  802066:	c1 e8 16             	shr    $0x16,%eax
  802069:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802070:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802075:	f6 c1 01             	test   $0x1,%cl
  802078:	74 1d                	je     802097 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80207a:	c1 ea 0c             	shr    $0xc,%edx
  80207d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802084:	f6 c2 01             	test   $0x1,%dl
  802087:	74 0e                	je     802097 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802089:	c1 ea 0c             	shr    $0xc,%edx
  80208c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802093:	ef 
  802094:	0f b7 c0             	movzwl %ax,%eax
}
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
