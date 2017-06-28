
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 c0 22 80 00       	push   $0x8022c0
  800048:	e8 4a 01 00 00       	call   800197 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 a6 0a 00 00       	call   800b00 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 e0 22 80 00       	push   $0x8022e0
  80006c:	e8 26 01 00 00       	call   800197 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 0c 23 80 00       	push   $0x80230c
  80008d:	e8 05 01 00 00       	call   800197 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a5:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000ac:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000af:	e8 2d 0a 00 00       	call   800ae1 <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c6:	85 db                	test   %ebx,%ebx
  8000c8:	7e 07                	jle    8000d1 <libmain+0x37>
		binaryname = argv[0];
  8000ca:	8b 06                	mov    (%esi),%eax
  8000cc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	e8 58 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000db:	e8 0a 00 00 00       	call   8000ea <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f0:	e8 26 0e 00 00       	call   800f1b <close_all>
	sys_env_destroy(0);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	6a 00                	push   $0x0
  8000fa:	e8 a1 09 00 00       	call   800aa0 <sys_env_destroy>
}
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 13                	mov    (%ebx),%edx
  800110:	8d 42 01             	lea    0x1(%edx),%eax
  800113:	89 03                	mov    %eax,(%ebx)
  800115:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800118:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 1a                	jne    80013d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800123:	83 ec 08             	sub    $0x8,%esp
  800126:	68 ff 00 00 00       	push   $0xff
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 2f 09 00 00       	call   800a63 <sys_cputs>
		b->idx = 0;
  800134:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	68 04 01 80 00       	push   $0x800104
  800175:	e8 54 01 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017a:	83 c4 08             	add    $0x8,%esp
  80017d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800183:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	e8 d4 08 00 00       	call   800a63 <sys_cputs>

	return b.cnt;
}
  80018f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a0:	50                   	push   %eax
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	e8 9d ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 1c             	sub    $0x1c,%esp
  8001b4:	89 c7                	mov    %eax,%edi
  8001b6:	89 d6                	mov    %edx,%esi
  8001b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d2:	39 d3                	cmp    %edx,%ebx
  8001d4:	72 05                	jb     8001db <printnum+0x30>
  8001d6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d9:	77 45                	ja     800220 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e7:	53                   	push   %ebx
  8001e8:	ff 75 10             	pushl  0x10(%ebp)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fa:	e8 21 1e 00 00       	call   802020 <__udivdi3>
  8001ff:	83 c4 18             	add    $0x18,%esp
  800202:	52                   	push   %edx
  800203:	50                   	push   %eax
  800204:	89 f2                	mov    %esi,%edx
  800206:	89 f8                	mov    %edi,%eax
  800208:	e8 9e ff ff ff       	call   8001ab <printnum>
  80020d:	83 c4 20             	add    $0x20,%esp
  800210:	eb 18                	jmp    80022a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	56                   	push   %esi
  800216:	ff 75 18             	pushl  0x18(%ebp)
  800219:	ff d7                	call   *%edi
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	eb 03                	jmp    800223 <printnum+0x78>
  800220:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800223:	83 eb 01             	sub    $0x1,%ebx
  800226:	85 db                	test   %ebx,%ebx
  800228:	7f e8                	jg     800212 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	56                   	push   %esi
  80022e:	83 ec 04             	sub    $0x4,%esp
  800231:	ff 75 e4             	pushl  -0x1c(%ebp)
  800234:	ff 75 e0             	pushl  -0x20(%ebp)
  800237:	ff 75 dc             	pushl  -0x24(%ebp)
  80023a:	ff 75 d8             	pushl  -0x28(%ebp)
  80023d:	e8 0e 1f 00 00       	call   802150 <__umoddi3>
  800242:	83 c4 14             	add    $0x14,%esp
  800245:	0f be 80 35 23 80 00 	movsbl 0x802335(%eax),%eax
  80024c:	50                   	push   %eax
  80024d:	ff d7                	call   *%edi
}
  80024f:	83 c4 10             	add    $0x10,%esp
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7e 0e                	jle    800270 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 08             	lea    0x8(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x38>
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 10                	je     800284 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a3:	73 0a                	jae    8002af <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	88 02                	mov    %al,(%edx)
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	ff 75 08             	pushl  0x8(%ebp)
  8002c4:	e8 05 00 00 00       	call   8002ce <vprintfmt>
	va_end(ap);
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
  8002d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e0:	eb 12                	jmp    8002f4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	0f 84 89 03 00 00    	je     800673 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	53                   	push   %ebx
  8002ee:	50                   	push   %eax
  8002ef:	ff d6                	call   *%esi
  8002f1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f4:	83 c7 01             	add    $0x1,%edi
  8002f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fb:	83 f8 25             	cmp    $0x25,%eax
  8002fe:	75 e2                	jne    8002e2 <vprintfmt+0x14>
  800300:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800304:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800312:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 07                	jmp    800327 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8d 47 01             	lea    0x1(%edi),%eax
  80032a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032d:	0f b6 07             	movzbl (%edi),%eax
  800330:	0f b6 c8             	movzbl %al,%ecx
  800333:	83 e8 23             	sub    $0x23,%eax
  800336:	3c 55                	cmp    $0x55,%al
  800338:	0f 87 1a 03 00 00    	ja     800658 <vprintfmt+0x38a>
  80033e:	0f b6 c0             	movzbl %al,%eax
  800341:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034f:	eb d6                	jmp    800327 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800354:	b8 00 00 00 00       	mov    $0x0,%eax
  800359:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800363:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800366:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800369:	83 fa 09             	cmp    $0x9,%edx
  80036c:	77 39                	ja     8003a7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800371:	eb e9                	jmp    80035c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 48 04             	lea    0x4(%eax),%ecx
  800379:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800384:	eb 27                	jmp    8003ad <vprintfmt+0xdf>
  800386:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800389:	85 c0                	test   %eax,%eax
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800390:	0f 49 c8             	cmovns %eax,%ecx
  800393:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	eb 8c                	jmp    800327 <vprintfmt+0x59>
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a5:	eb 80                	jmp    800327 <vprintfmt+0x59>
  8003a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b1:	0f 89 70 ff ff ff    	jns    800327 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c4:	e9 5e ff ff ff       	jmp    800327 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cf:	e9 53 ff ff ff       	jmp    800327 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	ff 30                	pushl  (%eax)
  8003e3:	ff d6                	call   *%esi
			break;
  8003e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003eb:	e9 04 ff ff ff       	jmp    8002f4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	31 d0                	xor    %edx,%eax
  8003fe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800400:	83 f8 0f             	cmp    $0xf,%eax
  800403:	7f 0b                	jg     800410 <vprintfmt+0x142>
  800405:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	75 18                	jne    800428 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 4d 23 80 00       	push   $0x80234d
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 94 fe ff ff       	call   8002b1 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 cc fe ff ff       	jmp    8002f4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800428:	52                   	push   %edx
  800429:	68 15 27 80 00       	push   $0x802715
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 7c fe ff ff       	call   8002b1 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043b:	e9 b4 fe ff ff       	jmp    8002f4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044b:	85 ff                	test   %edi,%edi
  80044d:	b8 46 23 80 00       	mov    $0x802346,%eax
  800452:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	0f 8e 94 00 00 00    	jle    8004f3 <vprintfmt+0x225>
  80045f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800463:	0f 84 98 00 00 00    	je     800501 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	ff 75 d0             	pushl  -0x30(%ebp)
  80046f:	57                   	push   %edi
  800470:	e8 86 02 00 00       	call   8006fb <strnlen>
  800475:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800480:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800484:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800487:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	eb 0f                	jmp    80049d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	ff 75 e0             	pushl  -0x20(%ebp)
  800495:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	83 ef 01             	sub    $0x1,%edi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	85 ff                	test   %edi,%edi
  80049f:	7f ed                	jg     80048e <vprintfmt+0x1c0>
  8004a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a7:	85 c9                	test   %ecx,%ecx
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	0f 49 c1             	cmovns %ecx,%eax
  8004b1:	29 c1                	sub    %eax,%ecx
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	89 cb                	mov    %ecx,%ebx
  8004be:	eb 4d                	jmp    80050d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c4:	74 1b                	je     8004e1 <vprintfmt+0x213>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 10                	jbe    8004e1 <vprintfmt+0x213>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	6a 3f                	push   $0x3f
  8004d9:	ff 55 08             	call   *0x8(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb 0d                	jmp    8004ee <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	52                   	push   %edx
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	83 eb 01             	sub    $0x1,%ebx
  8004f1:	eb 1a                	jmp    80050d <vprintfmt+0x23f>
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ff:	eb 0c                	jmp    80050d <vprintfmt+0x23f>
  800501:	89 75 08             	mov    %esi,0x8(%ebp)
  800504:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800507:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050d:	83 c7 01             	add    $0x1,%edi
  800510:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800514:	0f be d0             	movsbl %al,%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	74 23                	je     80053e <vprintfmt+0x270>
  80051b:	85 f6                	test   %esi,%esi
  80051d:	78 a1                	js     8004c0 <vprintfmt+0x1f2>
  80051f:	83 ee 01             	sub    $0x1,%esi
  800522:	79 9c                	jns    8004c0 <vprintfmt+0x1f2>
  800524:	89 df                	mov    %ebx,%edi
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	eb 18                	jmp    800546 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	6a 20                	push   $0x20
  800534:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800536:	83 ef 01             	sub    $0x1,%edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 08                	jmp    800546 <vprintfmt+0x278>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	85 ff                	test   %edi,%edi
  800548:	7f e4                	jg     80052e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	e9 a2 fd ff ff       	jmp    8002f4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800552:	83 fa 01             	cmp    $0x1,%edx
  800555:	7e 16                	jle    80056d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 08             	lea    0x8(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 50 04             	mov    0x4(%eax),%edx
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056b:	eb 32                	jmp    80059f <vprintfmt+0x2d1>
	else if (lflag)
  80056d:	85 d2                	test   %edx,%edx
  80056f:	74 18                	je     800589 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 c1                	mov    %eax,%ecx
  800581:	c1 f9 1f             	sar    $0x1f,%ecx
  800584:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800587:	eb 16                	jmp    80059f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 c1                	mov    %eax,%ecx
  800599:	c1 f9 1f             	sar    $0x1f,%ecx
  80059c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	79 74                	jns    800624 <vprintfmt+0x356>
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005be:	f7 d8                	neg    %eax
  8005c0:	83 d2 00             	adc    $0x0,%edx
  8005c3:	f7 da                	neg    %edx
  8005c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cd:	eb 55                	jmp    800624 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 83 fc ff ff       	call   80025a <getuint>
			base = 10;
  8005d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005dc:	eb 46                	jmp    800624 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 74 fc ff ff       	call   80025a <getuint>
		        base = 8;
  8005e6:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005eb:	eb 37                	jmp    800624 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 30                	push   $0x30
  8005f3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f5:	83 c4 08             	add    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 78                	push   $0x78
  8005fb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800610:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800615:	eb 0d                	jmp    800624 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 3b fc ff ff       	call   80025a <getuint>
			base = 16;
  80061f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062b:	57                   	push   %edi
  80062c:	ff 75 e0             	pushl  -0x20(%ebp)
  80062f:	51                   	push   %ecx
  800630:	52                   	push   %edx
  800631:	50                   	push   %eax
  800632:	89 da                	mov    %ebx,%edx
  800634:	89 f0                	mov    %esi,%eax
  800636:	e8 70 fb ff ff       	call   8001ab <printnum>
			break;
  80063b:	83 c4 20             	add    $0x20,%esp
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	e9 ae fc ff ff       	jmp    8002f4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	51                   	push   %ecx
  80064b:	ff d6                	call   *%esi
			break;
  80064d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800653:	e9 9c fc ff ff       	jmp    8002f4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 25                	push   $0x25
  80065e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 03                	jmp    800668 <vprintfmt+0x39a>
  800665:	83 ef 01             	sub    $0x1,%edi
  800668:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066c:	75 f7                	jne    800665 <vprintfmt+0x397>
  80066e:	e9 81 fc ff ff       	jmp    8002f4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	83 ec 18             	sub    $0x18,%esp
  800681:	8b 45 08             	mov    0x8(%ebp),%eax
  800684:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800687:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800698:	85 c0                	test   %eax,%eax
  80069a:	74 26                	je     8006c2 <vsnprintf+0x47>
  80069c:	85 d2                	test   %edx,%edx
  80069e:	7e 22                	jle    8006c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a0:	ff 75 14             	pushl  0x14(%ebp)
  8006a3:	ff 75 10             	pushl  0x10(%ebp)
  8006a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	68 94 02 80 00       	push   $0x800294
  8006af:	e8 1a fc ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 05                	jmp    8006c7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d2:	50                   	push   %eax
  8006d3:	ff 75 10             	pushl  0x10(%ebp)
  8006d6:	ff 75 0c             	pushl  0xc(%ebp)
  8006d9:	ff 75 08             	pushl  0x8(%ebp)
  8006dc:	e8 9a ff ff ff       	call   80067b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ee:	eb 03                	jmp    8006f3 <strlen+0x10>
		n++;
  8006f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f7:	75 f7                	jne    8006f0 <strlen+0xd>
		n++;
	return n;
}
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800701:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
  800709:	eb 03                	jmp    80070e <strnlen+0x13>
		n++;
  80070b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070e:	39 c2                	cmp    %eax,%edx
  800710:	74 08                	je     80071a <strnlen+0x1f>
  800712:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800716:	75 f3                	jne    80070b <strnlen+0x10>
  800718:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800726:	89 c2                	mov    %eax,%edx
  800728:	83 c2 01             	add    $0x1,%edx
  80072b:	83 c1 01             	add    $0x1,%ecx
  80072e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800732:	88 5a ff             	mov    %bl,-0x1(%edx)
  800735:	84 db                	test   %bl,%bl
  800737:	75 ef                	jne    800728 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800739:	5b                   	pop    %ebx
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800743:	53                   	push   %ebx
  800744:	e8 9a ff ff ff       	call   8006e3 <strlen>
  800749:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	01 d8                	add    %ebx,%eax
  800751:	50                   	push   %eax
  800752:	e8 c5 ff ff ff       	call   80071c <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	8b 75 08             	mov    0x8(%ebp),%esi
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800769:	89 f3                	mov    %esi,%ebx
  80076b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076e:	89 f2                	mov    %esi,%edx
  800770:	eb 0f                	jmp    800781 <strncpy+0x23>
		*dst++ = *src;
  800772:	83 c2 01             	add    $0x1,%edx
  800775:	0f b6 01             	movzbl (%ecx),%eax
  800778:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077b:	80 39 01             	cmpb   $0x1,(%ecx)
  80077e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	39 da                	cmp    %ebx,%edx
  800783:	75 ed                	jne    800772 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800785:	89 f0                	mov    %esi,%eax
  800787:	5b                   	pop    %ebx
  800788:	5e                   	pop    %esi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800796:	8b 55 10             	mov    0x10(%ebp),%edx
  800799:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 21                	je     8007c0 <strlcpy+0x35>
  80079f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 09                	jmp    8007b0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	83 c1 01             	add    $0x1,%ecx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 09                	je     8007bd <strlcpy+0x32>
  8007b4:	0f b6 19             	movzbl (%ecx),%ebx
  8007b7:	84 db                	test   %bl,%bl
  8007b9:	75 ec                	jne    8007a7 <strlcpy+0x1c>
  8007bb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c0:	29 f0                	sub    %esi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cf:	eb 06                	jmp    8007d7 <strcmp+0x11>
		p++, q++;
  8007d1:	83 c1 01             	add    $0x1,%ecx
  8007d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d7:	0f b6 01             	movzbl (%ecx),%eax
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 04                	je     8007e2 <strcmp+0x1c>
  8007de:	3a 02                	cmp    (%edx),%al
  8007e0:	74 ef                	je     8007d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e2:	0f b6 c0             	movzbl %al,%eax
  8007e5:	0f b6 12             	movzbl (%edx),%edx
  8007e8:	29 d0                	sub    %edx,%eax
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 c3                	mov    %eax,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fb:	eb 06                	jmp    800803 <strncmp+0x17>
		n--, p++, q++;
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800803:	39 d8                	cmp    %ebx,%eax
  800805:	74 15                	je     80081c <strncmp+0x30>
  800807:	0f b6 08             	movzbl (%eax),%ecx
  80080a:	84 c9                	test   %cl,%cl
  80080c:	74 04                	je     800812 <strncmp+0x26>
  80080e:	3a 0a                	cmp    (%edx),%cl
  800810:	74 eb                	je     8007fd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800812:	0f b6 00             	movzbl (%eax),%eax
  800815:	0f b6 12             	movzbl (%edx),%edx
  800818:	29 d0                	sub    %edx,%eax
  80081a:	eb 05                	jmp    800821 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082e:	eb 07                	jmp    800837 <strchr+0x13>
		if (*s == c)
  800830:	38 ca                	cmp    %cl,%dl
  800832:	74 0f                	je     800843 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	0f b6 10             	movzbl (%eax),%edx
  80083a:	84 d2                	test   %dl,%dl
  80083c:	75 f2                	jne    800830 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084f:	eb 03                	jmp    800854 <strfind+0xf>
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	74 04                	je     80085f <strfind+0x1a>
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strfind+0xc>
			break;
	return (char *) s;
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	57                   	push   %edi
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 36                	je     8008a7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800871:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800877:	75 28                	jne    8008a1 <memset+0x40>
  800879:	f6 c1 03             	test   $0x3,%cl
  80087c:	75 23                	jne    8008a1 <memset+0x40>
		c &= 0xFF;
  80087e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800882:	89 d3                	mov    %edx,%ebx
  800884:	c1 e3 08             	shl    $0x8,%ebx
  800887:	89 d6                	mov    %edx,%esi
  800889:	c1 e6 18             	shl    $0x18,%esi
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	c1 e0 10             	shl    $0x10,%eax
  800891:	09 f0                	or     %esi,%eax
  800893:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800895:	89 d8                	mov    %ebx,%eax
  800897:	09 d0                	or     %edx,%eax
  800899:	c1 e9 02             	shr    $0x2,%ecx
  80089c:	fc                   	cld    
  80089d:	f3 ab                	rep stos %eax,%es:(%edi)
  80089f:	eb 06                	jmp    8008a7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	fc                   	cld    
  8008a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a7:	89 f8                	mov    %edi,%eax
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	5f                   	pop    %edi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bc:	39 c6                	cmp    %eax,%esi
  8008be:	73 35                	jae    8008f5 <memmove+0x47>
  8008c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c3:	39 d0                	cmp    %edx,%eax
  8008c5:	73 2e                	jae    8008f5 <memmove+0x47>
		s += n;
		d += n;
  8008c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	09 fe                	or     %edi,%esi
  8008ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d4:	75 13                	jne    8008e9 <memmove+0x3b>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 0e                	jne    8008e9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008db:	83 ef 04             	sub    $0x4,%edi
  8008de:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
  8008e4:	fd                   	std    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 09                	jmp    8008f2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e9:	83 ef 01             	sub    $0x1,%edi
  8008ec:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ef:	fd                   	std    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f2:	fc                   	cld    
  8008f3:	eb 1d                	jmp    800912 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f5:	89 f2                	mov    %esi,%edx
  8008f7:	09 c2                	or     %eax,%edx
  8008f9:	f6 c2 03             	test   $0x3,%dl
  8008fc:	75 0f                	jne    80090d <memmove+0x5f>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 0a                	jne    80090d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800903:	c1 e9 02             	shr    $0x2,%ecx
  800906:	89 c7                	mov    %eax,%edi
  800908:	fc                   	cld    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 05                	jmp    800912 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800919:	ff 75 10             	pushl  0x10(%ebp)
  80091c:	ff 75 0c             	pushl  0xc(%ebp)
  80091f:	ff 75 08             	pushl  0x8(%ebp)
  800922:	e8 87 ff ff ff       	call   8008ae <memmove>
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	89 c6                	mov    %eax,%esi
  800936:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800939:	eb 1a                	jmp    800955 <memcmp+0x2c>
		if (*s1 != *s2)
  80093b:	0f b6 08             	movzbl (%eax),%ecx
  80093e:	0f b6 1a             	movzbl (%edx),%ebx
  800941:	38 d9                	cmp    %bl,%cl
  800943:	74 0a                	je     80094f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800945:	0f b6 c1             	movzbl %cl,%eax
  800948:	0f b6 db             	movzbl %bl,%ebx
  80094b:	29 d8                	sub    %ebx,%eax
  80094d:	eb 0f                	jmp    80095e <memcmp+0x35>
		s1++, s2++;
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800955:	39 f0                	cmp    %esi,%eax
  800957:	75 e2                	jne    80093b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800969:	89 c1                	mov    %eax,%ecx
  80096b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800972:	eb 0a                	jmp    80097e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	39 da                	cmp    %ebx,%edx
  800979:	74 07                	je     800982 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	39 c8                	cmp    %ecx,%eax
  800980:	72 f2                	jb     800974 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800982:	5b                   	pop    %ebx
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800991:	eb 03                	jmp    800996 <strtol+0x11>
		s++;
  800993:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800996:	0f b6 01             	movzbl (%ecx),%eax
  800999:	3c 20                	cmp    $0x20,%al
  80099b:	74 f6                	je     800993 <strtol+0xe>
  80099d:	3c 09                	cmp    $0x9,%al
  80099f:	74 f2                	je     800993 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a1:	3c 2b                	cmp    $0x2b,%al
  8009a3:	75 0a                	jne    8009af <strtol+0x2a>
		s++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ad:	eb 11                	jmp    8009c0 <strtol+0x3b>
  8009af:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b4:	3c 2d                	cmp    $0x2d,%al
  8009b6:	75 08                	jne    8009c0 <strtol+0x3b>
		s++, neg = 1;
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c6:	75 15                	jne    8009dd <strtol+0x58>
  8009c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cb:	75 10                	jne    8009dd <strtol+0x58>
  8009cd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d1:	75 7c                	jne    800a4f <strtol+0xca>
		s += 2, base = 16;
  8009d3:	83 c1 02             	add    $0x2,%ecx
  8009d6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009db:	eb 16                	jmp    8009f3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009dd:	85 db                	test   %ebx,%ebx
  8009df:	75 12                	jne    8009f3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e9:	75 08                	jne    8009f3 <strtol+0x6e>
		s++, base = 8;
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fb:	0f b6 11             	movzbl (%ecx),%edx
  8009fe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 09             	cmp    $0x9,%bl
  800a06:	77 08                	ja     800a10 <strtol+0x8b>
			dig = *s - '0';
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 30             	sub    $0x30,%edx
  800a0e:	eb 22                	jmp    800a32 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a10:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 57             	sub    $0x57,%edx
  800a20:	eb 10                	jmp    800a32 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a22:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 16                	ja     800a42 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a35:	7d 0b                	jge    800a42 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a40:	eb b9                	jmp    8009fb <strtol+0x76>

	if (endptr)
  800a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a46:	74 0d                	je     800a55 <strtol+0xd0>
		*endptr = (char *) s;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	89 0e                	mov    %ecx,(%esi)
  800a4d:	eb 06                	jmp    800a55 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	74 98                	je     8009eb <strtol+0x66>
  800a53:	eb 9e                	jmp    8009f3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	f7 da                	neg    %edx
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	0f 45 c2             	cmovne %edx,%eax
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	8b 55 08             	mov    0x8(%ebp),%edx
  800a74:	89 c3                	mov    %eax,%ebx
  800a76:	89 c7                	mov    %eax,%edi
  800a78:	89 c6                	mov    %eax,%esi
  800a7a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a87:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a91:	89 d1                	mov    %edx,%ecx
  800a93:	89 d3                	mov    %edx,%ebx
  800a95:	89 d7                	mov    %edx,%edi
  800a97:	89 d6                	mov    %edx,%esi
  800a99:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	89 cb                	mov    %ecx,%ebx
  800ab8:	89 cf                	mov    %ecx,%edi
  800aba:	89 ce                	mov    %ecx,%esi
  800abc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	7e 17                	jle    800ad9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac2:	83 ec 0c             	sub    $0xc,%esp
  800ac5:	50                   	push   %eax
  800ac6:	6a 03                	push   $0x3
  800ac8:	68 3f 26 80 00       	push   $0x80263f
  800acd:	6a 23                	push   $0x23
  800acf:	68 5c 26 80 00       	push   $0x80265c
  800ad4:	e8 cc 13 00 00       	call   801ea5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aec:	b8 02 00 00 00       	mov    $0x2,%eax
  800af1:	89 d1                	mov    %edx,%ecx
  800af3:	89 d3                	mov    %edx,%ebx
  800af5:	89 d7                	mov    %edx,%edi
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_yield>:

void
sys_yield(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b10:	89 d1                	mov    %edx,%ecx
  800b12:	89 d3                	mov    %edx,%ebx
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	be 00 00 00 00       	mov    $0x0,%esi
  800b2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3b:	89 f7                	mov    %esi,%edi
  800b3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 17                	jle    800b5a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	50                   	push   %eax
  800b47:	6a 04                	push   $0x4
  800b49:	68 3f 26 80 00       	push   $0x80263f
  800b4e:	6a 23                	push   $0x23
  800b50:	68 5c 26 80 00       	push   $0x80265c
  800b55:	e8 4b 13 00 00       	call   801ea5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	7e 17                	jle    800b9c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	50                   	push   %eax
  800b89:	6a 05                	push   $0x5
  800b8b:	68 3f 26 80 00       	push   $0x80263f
  800b90:	6a 23                	push   $0x23
  800b92:	68 5c 26 80 00       	push   $0x80265c
  800b97:	e8 09 13 00 00       	call   801ea5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 df                	mov    %ebx,%edi
  800bbf:	89 de                	mov    %ebx,%esi
  800bc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 17                	jle    800bde <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 06                	push   $0x6
  800bcd:	68 3f 26 80 00       	push   $0x80263f
  800bd2:	6a 23                	push   $0x23
  800bd4:	68 5c 26 80 00       	push   $0x80265c
  800bd9:	e8 c7 12 00 00       	call   801ea5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	89 df                	mov    %ebx,%edi
  800c01:	89 de                	mov    %ebx,%esi
  800c03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 17                	jle    800c20 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 08                	push   $0x8
  800c0f:	68 3f 26 80 00       	push   $0x80263f
  800c14:	6a 23                	push   $0x23
  800c16:	68 5c 26 80 00       	push   $0x80265c
  800c1b:	e8 85 12 00 00       	call   801ea5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c36:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 df                	mov    %ebx,%edi
  800c43:	89 de                	mov    %ebx,%esi
  800c45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 17                	jle    800c62 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 09                	push   $0x9
  800c51:	68 3f 26 80 00       	push   $0x80263f
  800c56:	6a 23                	push   $0x23
  800c58:	68 5c 26 80 00       	push   $0x80265c
  800c5d:	e8 43 12 00 00       	call   801ea5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 17                	jle    800ca4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 0a                	push   $0xa
  800c93:	68 3f 26 80 00       	push   $0x80263f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 5c 26 80 00       	push   $0x80265c
  800c9f:	e8 01 12 00 00       	call   801ea5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	be 00 00 00 00       	mov    $0x0,%esi
  800cb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 cb                	mov    %ecx,%ebx
  800ce7:	89 cf                	mov    %ecx,%edi
  800ce9:	89 ce                	mov    %ecx,%esi
  800ceb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 17                	jle    800d08 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 0d                	push   $0xd
  800cf7:	68 3f 26 80 00       	push   $0x80263f
  800cfc:	6a 23                	push   $0x23
  800cfe:	68 5c 26 80 00       	push   $0x80265c
  800d03:	e8 9d 11 00 00       	call   801ea5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d20:	89 d1                	mov    %edx,%ecx
  800d22:	89 d3                	mov    %edx,%ebx
  800d24:	89 d7                	mov    %edx,%edi
  800d26:	89 d6                	mov    %edx,%esi
  800d28:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	05 00 00 00 30       	add    $0x30000000,%eax
  800d5b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d70:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	c1 ea 16             	shr    $0x16,%edx
  800d87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8e:	f6 c2 01             	test   $0x1,%dl
  800d91:	74 11                	je     800da4 <fd_alloc+0x2d>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 0c             	shr    $0xc,%edx
  800d98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9f:	f6 c2 01             	test   $0x1,%dl
  800da2:	75 09                	jne    800dad <fd_alloc+0x36>
			*fd_store = fd;
  800da4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dab:	eb 17                	jmp    800dc4 <fd_alloc+0x4d>
  800dad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db7:	75 c9                	jne    800d82 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dbf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dcc:	83 f8 1f             	cmp    $0x1f,%eax
  800dcf:	77 36                	ja     800e07 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd1:	c1 e0 0c             	shl    $0xc,%eax
  800dd4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	c1 ea 16             	shr    $0x16,%edx
  800dde:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de5:	f6 c2 01             	test   $0x1,%dl
  800de8:	74 24                	je     800e0e <fd_lookup+0x48>
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	c1 ea 0c             	shr    $0xc,%edx
  800def:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df6:	f6 c2 01             	test   $0x1,%dl
  800df9:	74 1a                	je     800e15 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfe:	89 02                	mov    %eax,(%edx)
	return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	eb 13                	jmp    800e1a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0c:	eb 0c                	jmp    800e1a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e13:	eb 05                	jmp    800e1a <fd_lookup+0x54>
  800e15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 08             	sub    $0x8,%esp
  800e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e25:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e2a:	eb 13                	jmp    800e3f <dev_lookup+0x23>
  800e2c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2f:	39 08                	cmp    %ecx,(%eax)
  800e31:	75 0c                	jne    800e3f <dev_lookup+0x23>
			*dev = devtab[i];
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3d:	eb 2e                	jmp    800e6d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3f:	8b 02                	mov    (%edx),%eax
  800e41:	85 c0                	test   %eax,%eax
  800e43:	75 e7                	jne    800e2c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e45:	a1 08 40 80 00       	mov    0x804008,%eax
  800e4a:	8b 40 48             	mov    0x48(%eax),%eax
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	51                   	push   %ecx
  800e51:	50                   	push   %eax
  800e52:	68 6c 26 80 00       	push   $0x80266c
  800e57:	e8 3b f3 ff ff       	call   800197 <cprintf>
	*dev = 0;
  800e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 10             	sub    $0x10,%esp
  800e77:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e80:	50                   	push   %eax
  800e81:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e87:	c1 e8 0c             	shr    $0xc,%eax
  800e8a:	50                   	push   %eax
  800e8b:	e8 36 ff ff ff       	call   800dc6 <fd_lookup>
  800e90:	83 c4 08             	add    $0x8,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	78 05                	js     800e9c <fd_close+0x2d>
	    || fd != fd2)
  800e97:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e9a:	74 0c                	je     800ea8 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e9c:	84 db                	test   %bl,%bl
  800e9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea3:	0f 44 c2             	cmove  %edx,%eax
  800ea6:	eb 41                	jmp    800ee9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eae:	50                   	push   %eax
  800eaf:	ff 36                	pushl  (%esi)
  800eb1:	e8 66 ff ff ff       	call   800e1c <dev_lookup>
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 1a                	js     800ed9 <fd_close+0x6a>
		if (dev->dev_close)
  800ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	74 0b                	je     800ed9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	56                   	push   %esi
  800ed2:	ff d0                	call   *%eax
  800ed4:	89 c3                	mov    %eax,%ebx
  800ed6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	56                   	push   %esi
  800edd:	6a 00                	push   $0x0
  800edf:	e8 c0 fc ff ff       	call   800ba4 <sys_page_unmap>
	return r;
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	89 d8                	mov    %ebx,%eax
}
  800ee9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef9:	50                   	push   %eax
  800efa:	ff 75 08             	pushl  0x8(%ebp)
  800efd:	e8 c4 fe ff ff       	call   800dc6 <fd_lookup>
  800f02:	83 c4 08             	add    $0x8,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 10                	js     800f19 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f09:	83 ec 08             	sub    $0x8,%esp
  800f0c:	6a 01                	push   $0x1
  800f0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f11:	e8 59 ff ff ff       	call   800e6f <fd_close>
  800f16:	83 c4 10             	add    $0x10,%esp
}
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <close_all>:

void
close_all(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	e8 c0 ff ff ff       	call   800ef0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f30:	83 c3 01             	add    $0x1,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	83 fb 20             	cmp    $0x20,%ebx
  800f39:	75 ec                	jne    800f27 <close_all+0xc>
		close(i);
}
  800f3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    

00800f40 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
  800f49:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f4c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	ff 75 08             	pushl  0x8(%ebp)
  800f53:	e8 6e fe ff ff       	call   800dc6 <fd_lookup>
  800f58:	83 c4 08             	add    $0x8,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	0f 88 c1 00 00 00    	js     801024 <dup+0xe4>
		return r;
	close(newfdnum);
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	56                   	push   %esi
  800f67:	e8 84 ff ff ff       	call   800ef0 <close>

	newfd = INDEX2FD(newfdnum);
  800f6c:	89 f3                	mov    %esi,%ebx
  800f6e:	c1 e3 0c             	shl    $0xc,%ebx
  800f71:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f77:	83 c4 04             	add    $0x4,%esp
  800f7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7d:	e8 de fd ff ff       	call   800d60 <fd2data>
  800f82:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f84:	89 1c 24             	mov    %ebx,(%esp)
  800f87:	e8 d4 fd ff ff       	call   800d60 <fd2data>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f92:	89 f8                	mov    %edi,%eax
  800f94:	c1 e8 16             	shr    $0x16,%eax
  800f97:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9e:	a8 01                	test   $0x1,%al
  800fa0:	74 37                	je     800fd9 <dup+0x99>
  800fa2:	89 f8                	mov    %edi,%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fae:	f6 c2 01             	test   $0x1,%dl
  800fb1:	74 26                	je     800fd9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc2:	50                   	push   %eax
  800fc3:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc6:	6a 00                	push   $0x0
  800fc8:	57                   	push   %edi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 92 fb ff ff       	call   800b62 <sys_page_map>
  800fd0:	89 c7                	mov    %eax,%edi
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 2e                	js     801007 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fdc:	89 d0                	mov    %edx,%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
  800fe1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff0:	50                   	push   %eax
  800ff1:	53                   	push   %ebx
  800ff2:	6a 00                	push   $0x0
  800ff4:	52                   	push   %edx
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 66 fb ff ff       	call   800b62 <sys_page_map>
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801001:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801003:	85 ff                	test   %edi,%edi
  801005:	79 1d                	jns    801024 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	53                   	push   %ebx
  80100b:	6a 00                	push   $0x0
  80100d:	e8 92 fb ff ff       	call   800ba4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801012:	83 c4 08             	add    $0x8,%esp
  801015:	ff 75 d4             	pushl  -0x2c(%ebp)
  801018:	6a 00                	push   $0x0
  80101a:	e8 85 fb ff ff       	call   800ba4 <sys_page_unmap>
	return r;
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	89 f8                	mov    %edi,%eax
}
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	53                   	push   %ebx
  801030:	83 ec 14             	sub    $0x14,%esp
  801033:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801036:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	53                   	push   %ebx
  80103b:	e8 86 fd ff ff       	call   800dc6 <fd_lookup>
  801040:	83 c4 08             	add    $0x8,%esp
  801043:	89 c2                	mov    %eax,%edx
  801045:	85 c0                	test   %eax,%eax
  801047:	78 6d                	js     8010b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801049:	83 ec 08             	sub    $0x8,%esp
  80104c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104f:	50                   	push   %eax
  801050:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801053:	ff 30                	pushl  (%eax)
  801055:	e8 c2 fd ff ff       	call   800e1c <dev_lookup>
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 4c                	js     8010ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801061:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801064:	8b 42 08             	mov    0x8(%edx),%eax
  801067:	83 e0 03             	and    $0x3,%eax
  80106a:	83 f8 01             	cmp    $0x1,%eax
  80106d:	75 21                	jne    801090 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106f:	a1 08 40 80 00       	mov    0x804008,%eax
  801074:	8b 40 48             	mov    0x48(%eax),%eax
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	53                   	push   %ebx
  80107b:	50                   	push   %eax
  80107c:	68 ad 26 80 00       	push   $0x8026ad
  801081:	e8 11 f1 ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80108e:	eb 26                	jmp    8010b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801093:	8b 40 08             	mov    0x8(%eax),%eax
  801096:	85 c0                	test   %eax,%eax
  801098:	74 17                	je     8010b1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	ff 75 10             	pushl  0x10(%ebp)
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	52                   	push   %edx
  8010a4:	ff d0                	call   *%eax
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	eb 09                	jmp    8010b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	eb 05                	jmp    8010b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010b6:	89 d0                	mov    %edx,%eax
  8010b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d1:	eb 21                	jmp    8010f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	89 f0                	mov    %esi,%eax
  8010d8:	29 d8                	sub    %ebx,%eax
  8010da:	50                   	push   %eax
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	03 45 0c             	add    0xc(%ebp),%eax
  8010e0:	50                   	push   %eax
  8010e1:	57                   	push   %edi
  8010e2:	e8 45 ff ff ff       	call   80102c <read>
		if (m < 0)
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 10                	js     8010fe <readn+0x41>
			return m;
		if (m == 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	74 0a                	je     8010fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f2:	01 c3                	add    %eax,%ebx
  8010f4:	39 f3                	cmp    %esi,%ebx
  8010f6:	72 db                	jb     8010d3 <readn+0x16>
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	eb 02                	jmp    8010fe <readn+0x41>
  8010fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	53                   	push   %ebx
  80110a:	83 ec 14             	sub    $0x14,%esp
  80110d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801110:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	53                   	push   %ebx
  801115:	e8 ac fc ff ff       	call   800dc6 <fd_lookup>
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 68                	js     80118b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112d:	ff 30                	pushl  (%eax)
  80112f:	e8 e8 fc ff ff       	call   800e1c <dev_lookup>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	85 c0                	test   %eax,%eax
  801139:	78 47                	js     801182 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801142:	75 21                	jne    801165 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801144:	a1 08 40 80 00       	mov    0x804008,%eax
  801149:	8b 40 48             	mov    0x48(%eax),%eax
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	53                   	push   %ebx
  801150:	50                   	push   %eax
  801151:	68 c9 26 80 00       	push   $0x8026c9
  801156:	e8 3c f0 ff ff       	call   800197 <cprintf>
		return -E_INVAL;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801163:	eb 26                	jmp    80118b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801165:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801168:	8b 52 0c             	mov    0xc(%edx),%edx
  80116b:	85 d2                	test   %edx,%edx
  80116d:	74 17                	je     801186 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 10             	pushl  0x10(%ebp)
  801175:	ff 75 0c             	pushl  0xc(%ebp)
  801178:	50                   	push   %eax
  801179:	ff d2                	call   *%edx
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	eb 09                	jmp    80118b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801182:	89 c2                	mov    %eax,%edx
  801184:	eb 05                	jmp    80118b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801186:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80118b:	89 d0                	mov    %edx,%eax
  80118d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <seek>:

int
seek(int fdnum, off_t offset)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801198:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	e8 22 fc ff ff       	call   800dc6 <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 0e                	js     8011b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    

008011bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 14             	sub    $0x14,%esp
  8011c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	53                   	push   %ebx
  8011ca:	e8 f7 fb ff ff       	call   800dc6 <fd_lookup>
  8011cf:	83 c4 08             	add    $0x8,%esp
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 65                	js     80123d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	ff 30                	pushl  (%eax)
  8011e4:	e8 33 fc ff ff       	call   800e1c <dev_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 44                	js     801234 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f7:	75 21                	jne    80121a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f9:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	53                   	push   %ebx
  801205:	50                   	push   %eax
  801206:	68 8c 26 80 00       	push   $0x80268c
  80120b:	e8 87 ef ff ff       	call   800197 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801218:	eb 23                	jmp    80123d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80121a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121d:	8b 52 18             	mov    0x18(%edx),%edx
  801220:	85 d2                	test   %edx,%edx
  801222:	74 14                	je     801238 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	50                   	push   %eax
  80122b:	ff d2                	call   *%edx
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 09                	jmp    80123d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	89 c2                	mov    %eax,%edx
  801236:	eb 05                	jmp    80123d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801238:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80123d:	89 d0                	mov    %edx,%eax
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 14             	sub    $0x14,%esp
  80124b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 6c fb ff ff       	call   800dc6 <fd_lookup>
  80125a:	83 c4 08             	add    $0x8,%esp
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 58                	js     8012bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	ff 30                	pushl  (%eax)
  80126f:	e8 a8 fb ff ff       	call   800e1c <dev_lookup>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 37                	js     8012b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80127b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801282:	74 32                	je     8012b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801284:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801287:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128e:	00 00 00 
	stat->st_isdir = 0;
  801291:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801298:	00 00 00 
	stat->st_dev = dev;
  80129b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	53                   	push   %ebx
  8012a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a8:	ff 50 14             	call   *0x14(%eax)
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	eb 09                	jmp    8012bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	eb 05                	jmp    8012bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012bb:	89 d0                	mov    %edx,%eax
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	6a 00                	push   $0x0
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 e7 01 00 00       	call   8014bb <open>
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 1b                	js     8012f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	ff 75 0c             	pushl  0xc(%ebp)
  8012e3:	50                   	push   %eax
  8012e4:	e8 5b ff ff ff       	call   801244 <fstat>
  8012e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8012eb:	89 1c 24             	mov    %ebx,(%esp)
  8012ee:	e8 fd fb ff ff       	call   800ef0 <close>
	return r;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	89 f0                	mov    %esi,%eax
}
  8012f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	89 c6                	mov    %eax,%esi
  801306:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801308:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130f:	75 12                	jne    801323 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	6a 01                	push   $0x1
  801316:	e8 91 0c 00 00       	call   801fac <ipc_find_env>
  80131b:	a3 00 40 80 00       	mov    %eax,0x804000
  801320:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801323:	6a 07                	push   $0x7
  801325:	68 00 50 80 00       	push   $0x805000
  80132a:	56                   	push   %esi
  80132b:	ff 35 00 40 80 00    	pushl  0x804000
  801331:	e8 22 0c 00 00       	call   801f58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801336:	83 c4 0c             	add    $0xc,%esp
  801339:	6a 00                	push   $0x0
  80133b:	53                   	push   %ebx
  80133c:	6a 00                	push   $0x0
  80133e:	e8 a8 0b 00 00       	call   801eeb <ipc_recv>
}
  801343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	8b 40 0c             	mov    0xc(%eax),%eax
  801356:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80135b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801363:	ba 00 00 00 00       	mov    $0x0,%edx
  801368:	b8 02 00 00 00       	mov    $0x2,%eax
  80136d:	e8 8d ff ff ff       	call   8012ff <fsipc>
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	8b 40 0c             	mov    0xc(%eax),%eax
  801380:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801385:	ba 00 00 00 00       	mov    $0x0,%edx
  80138a:	b8 06 00 00 00       	mov    $0x6,%eax
  80138f:	e8 6b ff ff ff       	call   8012ff <fsipc>
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	53                   	push   %ebx
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b5:	e8 45 ff ff ff       	call   8012ff <fsipc>
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 2c                	js     8013ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	68 00 50 80 00       	push   $0x805000
  8013c6:	53                   	push   %ebx
  8013c7:	e8 50 f3 ff ff       	call   80071c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8013dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8013f9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013fe:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801403:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801406:	53                   	push   %ebx
  801407:	ff 75 0c             	pushl  0xc(%ebp)
  80140a:	68 08 50 80 00       	push   $0x805008
  80140f:	e8 9a f4 ff ff       	call   8008ae <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	8b 40 0c             	mov    0xc(%eax),%eax
  80141a:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  80141f:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	b8 04 00 00 00       	mov    $0x4,%eax
  80142f:	e8 cb fe ff ff       	call   8012ff <fsipc>
	//panic("devfile_write not implemented");
}
  801434:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	8b 40 0c             	mov    0xc(%eax),%eax
  801447:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801452:	ba 00 00 00 00       	mov    $0x0,%edx
  801457:	b8 03 00 00 00       	mov    $0x3,%eax
  80145c:	e8 9e fe ff ff       	call   8012ff <fsipc>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	85 c0                	test   %eax,%eax
  801465:	78 4b                	js     8014b2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801467:	39 c6                	cmp    %eax,%esi
  801469:	73 16                	jae    801481 <devfile_read+0x48>
  80146b:	68 fc 26 80 00       	push   $0x8026fc
  801470:	68 03 27 80 00       	push   $0x802703
  801475:	6a 7c                	push   $0x7c
  801477:	68 18 27 80 00       	push   $0x802718
  80147c:	e8 24 0a 00 00       	call   801ea5 <_panic>
	assert(r <= PGSIZE);
  801481:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801486:	7e 16                	jle    80149e <devfile_read+0x65>
  801488:	68 23 27 80 00       	push   $0x802723
  80148d:	68 03 27 80 00       	push   $0x802703
  801492:	6a 7d                	push   $0x7d
  801494:	68 18 27 80 00       	push   $0x802718
  801499:	e8 07 0a 00 00       	call   801ea5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	50                   	push   %eax
  8014a2:	68 00 50 80 00       	push   $0x805000
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	e8 ff f3 ff ff       	call   8008ae <memmove>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
}
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 20             	sub    $0x20,%esp
  8014c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c5:	53                   	push   %ebx
  8014c6:	e8 18 f2 ff ff       	call   8006e3 <strlen>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d3:	7f 67                	jg     80153c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	e8 96 f8 ff ff       	call   800d77 <fd_alloc>
  8014e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 57                	js     801541 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	68 00 50 80 00       	push   $0x805000
  8014f3:	e8 24 f2 ff ff       	call   80071c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801500:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801503:	b8 01 00 00 00       	mov    $0x1,%eax
  801508:	e8 f2 fd ff ff       	call   8012ff <fsipc>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	79 14                	jns    80152a <open+0x6f>
		fd_close(fd, 0);
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	6a 00                	push   $0x0
  80151b:	ff 75 f4             	pushl  -0xc(%ebp)
  80151e:	e8 4c f9 ff ff       	call   800e6f <fd_close>
		return r;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	89 da                	mov    %ebx,%edx
  801528:	eb 17                	jmp    801541 <open+0x86>
	}

	return fd2num(fd);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	ff 75 f4             	pushl  -0xc(%ebp)
  801530:	e8 1b f8 ff ff       	call   800d50 <fd2num>
  801535:	89 c2                	mov    %eax,%edx
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	eb 05                	jmp    801541 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80153c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801541:	89 d0                	mov    %edx,%eax
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154e:	ba 00 00 00 00       	mov    $0x0,%edx
  801553:	b8 08 00 00 00       	mov    $0x8,%eax
  801558:	e8 a2 fd ff ff       	call   8012ff <fsipc>
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801565:	68 2f 27 80 00       	push   $0x80272f
  80156a:	ff 75 0c             	pushl  0xc(%ebp)
  80156d:	e8 aa f1 ff ff       	call   80071c <strcpy>
	return 0;
}
  801572:	b8 00 00 00 00       	mov    $0x0,%eax
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	53                   	push   %ebx
  80157d:	83 ec 10             	sub    $0x10,%esp
  801580:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801583:	53                   	push   %ebx
  801584:	e8 5c 0a 00 00       	call   801fe5 <pageref>
  801589:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80158c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801591:	83 f8 01             	cmp    $0x1,%eax
  801594:	75 10                	jne    8015a6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	ff 73 0c             	pushl  0xc(%ebx)
  80159c:	e8 c0 02 00 00       	call   801861 <nsipc_close>
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015a6:	89 d0                	mov    %edx,%eax
  8015a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015b3:	6a 00                	push   $0x0
  8015b5:	ff 75 10             	pushl  0x10(%ebp)
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	ff 70 0c             	pushl  0xc(%eax)
  8015c1:	e8 78 03 00 00       	call   80193e <nsipc_send>
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 10             	pushl  0x10(%ebp)
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	ff 70 0c             	pushl  0xc(%eax)
  8015dc:	e8 f1 02 00 00       	call   8018d2 <nsipc_recv>
}
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8015e9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ec:	52                   	push   %edx
  8015ed:	50                   	push   %eax
  8015ee:	e8 d3 f7 ff ff       	call   800dc6 <fd_lookup>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 17                	js     801611 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fd:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801603:	39 08                	cmp    %ecx,(%eax)
  801605:	75 05                	jne    80160c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801607:	8b 40 0c             	mov    0xc(%eax),%eax
  80160a:	eb 05                	jmp    801611 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80160c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 1c             	sub    $0x1c,%esp
  80161b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	e8 51 f7 ff ff       	call   800d77 <fd_alloc>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 1b                	js     80164a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	68 07 04 00 00       	push   $0x407
  801637:	ff 75 f4             	pushl  -0xc(%ebp)
  80163a:	6a 00                	push   $0x0
  80163c:	e8 de f4 ff ff       	call   800b1f <sys_page_alloc>
  801641:	89 c3                	mov    %eax,%ebx
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	79 10                	jns    80165a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	56                   	push   %esi
  80164e:	e8 0e 02 00 00       	call   801861 <nsipc_close>
		return r;
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	89 d8                	mov    %ebx,%eax
  801658:	eb 24                	jmp    80167e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80165a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801668:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80166f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	50                   	push   %eax
  801676:	e8 d5 f6 ff ff       	call   800d50 <fd2num>
  80167b:	83 c4 10             	add    $0x10,%esp
}
  80167e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	e8 50 ff ff ff       	call   8015e3 <fd2sockid>
		return r;
  801693:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801695:	85 c0                	test   %eax,%eax
  801697:	78 1f                	js     8016b8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801699:	83 ec 04             	sub    $0x4,%esp
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	50                   	push   %eax
  8016a3:	e8 12 01 00 00       	call   8017ba <nsipc_accept>
  8016a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8016ab:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 07                	js     8016b8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016b1:	e8 5d ff ff ff       	call   801613 <alloc_sockfd>
  8016b6:	89 c1                	mov    %eax,%ecx
}
  8016b8:	89 c8                	mov    %ecx,%eax
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	e8 19 ff ff ff       	call   8015e3 <fd2sockid>
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 12                	js     8016e0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	50                   	push   %eax
  8016d8:	e8 2d 01 00 00       	call   80180a <nsipc_bind>
  8016dd:	83 c4 10             	add    $0x10,%esp
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <shutdown>:

int
shutdown(int s, int how)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	e8 f3 fe ff ff       	call   8015e3 <fd2sockid>
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 0f                	js     801703 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	50                   	push   %eax
  8016fb:	e8 3f 01 00 00       	call   80183f <nsipc_shutdown>
  801700:	83 c4 10             	add    $0x10,%esp
}
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	e8 d0 fe ff ff       	call   8015e3 <fd2sockid>
  801713:	85 c0                	test   %eax,%eax
  801715:	78 12                	js     801729 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801717:	83 ec 04             	sub    $0x4,%esp
  80171a:	ff 75 10             	pushl  0x10(%ebp)
  80171d:	ff 75 0c             	pushl  0xc(%ebp)
  801720:	50                   	push   %eax
  801721:	e8 55 01 00 00       	call   80187b <nsipc_connect>
  801726:	83 c4 10             	add    $0x10,%esp
}
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <listen>:

int
listen(int s, int backlog)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	e8 aa fe ff ff       	call   8015e3 <fd2sockid>
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 0f                	js     80174c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	50                   	push   %eax
  801744:	e8 67 01 00 00       	call   8018b0 <nsipc_listen>
  801749:	83 c4 10             	add    $0x10,%esp
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801754:	ff 75 10             	pushl  0x10(%ebp)
  801757:	ff 75 0c             	pushl  0xc(%ebp)
  80175a:	ff 75 08             	pushl  0x8(%ebp)
  80175d:	e8 3a 02 00 00       	call   80199c <nsipc_socket>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 05                	js     80176e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801769:	e8 a5 fe ff ff       	call   801613 <alloc_sockfd>
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801779:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801780:	75 12                	jne    801794 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	6a 02                	push   $0x2
  801787:	e8 20 08 00 00       	call   801fac <ipc_find_env>
  80178c:	a3 04 40 80 00       	mov    %eax,0x804004
  801791:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801794:	6a 07                	push   $0x7
  801796:	68 00 60 80 00       	push   $0x806000
  80179b:	53                   	push   %ebx
  80179c:	ff 35 04 40 80 00    	pushl  0x804004
  8017a2:	e8 b1 07 00 00       	call   801f58 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017a7:	83 c4 0c             	add    $0xc,%esp
  8017aa:	6a 00                	push   $0x0
  8017ac:	6a 00                	push   $0x0
  8017ae:	6a 00                	push   $0x0
  8017b0:	e8 36 07 00 00       	call   801eeb <ipc_recv>
}
  8017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017ca:	8b 06                	mov    (%esi),%eax
  8017cc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d6:	e8 95 ff ff ff       	call   801770 <nsipc>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 20                	js     801801 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8017e1:	83 ec 04             	sub    $0x4,%esp
  8017e4:	ff 35 10 60 80 00    	pushl  0x806010
  8017ea:	68 00 60 80 00       	push   $0x806000
  8017ef:	ff 75 0c             	pushl  0xc(%ebp)
  8017f2:	e8 b7 f0 ff ff       	call   8008ae <memmove>
		*addrlen = ret->ret_addrlen;
  8017f7:	a1 10 60 80 00       	mov    0x806010,%eax
  8017fc:	89 06                	mov    %eax,(%esi)
  8017fe:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801801:	89 d8                	mov    %ebx,%eax
  801803:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80181c:	53                   	push   %ebx
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	68 04 60 80 00       	push   $0x806004
  801825:	e8 84 f0 ff ff       	call   8008ae <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80182a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801830:	b8 02 00 00 00       	mov    $0x2,%eax
  801835:	e8 36 ff ff ff       	call   801770 <nsipc>
}
  80183a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801855:	b8 03 00 00 00       	mov    $0x3,%eax
  80185a:	e8 11 ff ff ff       	call   801770 <nsipc>
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <nsipc_close>:

int
nsipc_close(int s)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80186f:	b8 04 00 00 00       	mov    $0x4,%eax
  801874:	e8 f7 fe ff ff       	call   801770 <nsipc>
}
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80188d:	53                   	push   %ebx
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	68 04 60 80 00       	push   $0x806004
  801896:	e8 13 f0 ff ff       	call   8008ae <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80189b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a6:	e8 c5 fe ff ff       	call   801770 <nsipc>
}
  8018ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018cb:	e8 a0 fe ff ff       	call   801770 <nsipc>
}
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8018e2:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8018e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018eb:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8018f0:	b8 07 00 00 00       	mov    $0x7,%eax
  8018f5:	e8 76 fe ff ff       	call   801770 <nsipc>
  8018fa:	89 c3                	mov    %eax,%ebx
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 35                	js     801935 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801900:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801905:	7f 04                	jg     80190b <nsipc_recv+0x39>
  801907:	39 c6                	cmp    %eax,%esi
  801909:	7d 16                	jge    801921 <nsipc_recv+0x4f>
  80190b:	68 3b 27 80 00       	push   $0x80273b
  801910:	68 03 27 80 00       	push   $0x802703
  801915:	6a 62                	push   $0x62
  801917:	68 50 27 80 00       	push   $0x802750
  80191c:	e8 84 05 00 00       	call   801ea5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	50                   	push   %eax
  801925:	68 00 60 80 00       	push   $0x806000
  80192a:	ff 75 0c             	pushl  0xc(%ebp)
  80192d:	e8 7c ef ff ff       	call   8008ae <memmove>
  801932:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801935:	89 d8                	mov    %ebx,%eax
  801937:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 04             	sub    $0x4,%esp
  801945:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801950:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801956:	7e 16                	jle    80196e <nsipc_send+0x30>
  801958:	68 5c 27 80 00       	push   $0x80275c
  80195d:	68 03 27 80 00       	push   $0x802703
  801962:	6a 6d                	push   $0x6d
  801964:	68 50 27 80 00       	push   $0x802750
  801969:	e8 37 05 00 00       	call   801ea5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80196e:	83 ec 04             	sub    $0x4,%esp
  801971:	53                   	push   %ebx
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	68 0c 60 80 00       	push   $0x80600c
  80197a:	e8 2f ef ff ff       	call   8008ae <memmove>
	nsipcbuf.send.req_size = size;
  80197f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801985:	8b 45 14             	mov    0x14(%ebp),%eax
  801988:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80198d:	b8 08 00 00 00       	mov    $0x8,%eax
  801992:	e8 d9 fd ff ff       	call   801770 <nsipc>
}
  801997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ad:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019ba:	b8 09 00 00 00       	mov    $0x9,%eax
  8019bf:	e8 ac fd ff ff       	call   801770 <nsipc>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	ff 75 08             	pushl  0x8(%ebp)
  8019d4:	e8 87 f3 ff ff       	call   800d60 <fd2data>
  8019d9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019db:	83 c4 08             	add    $0x8,%esp
  8019de:	68 68 27 80 00       	push   $0x802768
  8019e3:	53                   	push   %ebx
  8019e4:	e8 33 ed ff ff       	call   80071c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e9:	8b 46 04             	mov    0x4(%esi),%eax
  8019ec:	2b 06                	sub    (%esi),%eax
  8019ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fb:	00 00 00 
	stat->st_dev = &devpipe;
  8019fe:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a05:	30 80 00 
	return 0;
}
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	53                   	push   %ebx
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1e:	53                   	push   %ebx
  801a1f:	6a 00                	push   $0x0
  801a21:	e8 7e f1 ff ff       	call   800ba4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 32 f3 ff ff       	call   800d60 <fd2data>
  801a2e:	83 c4 08             	add    $0x8,%esp
  801a31:	50                   	push   %eax
  801a32:	6a 00                	push   $0x0
  801a34:	e8 6b f1 ff ff       	call   800ba4 <sys_page_unmap>
}
  801a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	57                   	push   %edi
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	83 ec 1c             	sub    $0x1c,%esp
  801a47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a4a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a4c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a51:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5a:	e8 86 05 00 00       	call   801fe5 <pageref>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	89 3c 24             	mov    %edi,(%esp)
  801a64:	e8 7c 05 00 00       	call   801fe5 <pageref>
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	39 c3                	cmp    %eax,%ebx
  801a6e:	0f 94 c1             	sete   %cl
  801a71:	0f b6 c9             	movzbl %cl,%ecx
  801a74:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a77:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a7d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a80:	39 ce                	cmp    %ecx,%esi
  801a82:	74 1b                	je     801a9f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a84:	39 c3                	cmp    %eax,%ebx
  801a86:	75 c4                	jne    801a4c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a88:	8b 42 58             	mov    0x58(%edx),%eax
  801a8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8e:	50                   	push   %eax
  801a8f:	56                   	push   %esi
  801a90:	68 6f 27 80 00       	push   $0x80276f
  801a95:	e8 fd e6 ff ff       	call   800197 <cprintf>
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	eb ad                	jmp    801a4c <_pipeisclosed+0xe>
	}
}
  801a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	57                   	push   %edi
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 28             	sub    $0x28,%esp
  801ab3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab6:	56                   	push   %esi
  801ab7:	e8 a4 f2 ff ff       	call   800d60 <fd2data>
  801abc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac6:	eb 4b                	jmp    801b13 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac8:	89 da                	mov    %ebx,%edx
  801aca:	89 f0                	mov    %esi,%eax
  801acc:	e8 6d ff ff ff       	call   801a3e <_pipeisclosed>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	75 48                	jne    801b1d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad5:	e8 26 f0 ff ff       	call   800b00 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ada:	8b 43 04             	mov    0x4(%ebx),%eax
  801add:	8b 0b                	mov    (%ebx),%ecx
  801adf:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae2:	39 d0                	cmp    %edx,%eax
  801ae4:	73 e2                	jae    801ac8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aed:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af0:	89 c2                	mov    %eax,%edx
  801af2:	c1 fa 1f             	sar    $0x1f,%edx
  801af5:	89 d1                	mov    %edx,%ecx
  801af7:	c1 e9 1b             	shr    $0x1b,%ecx
  801afa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801afd:	83 e2 1f             	and    $0x1f,%edx
  801b00:	29 ca                	sub    %ecx,%edx
  801b02:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b10:	83 c7 01             	add    $0x1,%edi
  801b13:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b16:	75 c2                	jne    801ada <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b18:	8b 45 10             	mov    0x10(%ebp),%eax
  801b1b:	eb 05                	jmp    801b22 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5f                   	pop    %edi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	57                   	push   %edi
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 18             	sub    $0x18,%esp
  801b33:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b36:	57                   	push   %edi
  801b37:	e8 24 f2 ff ff       	call   800d60 <fd2data>
  801b3c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b46:	eb 3d                	jmp    801b85 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b48:	85 db                	test   %ebx,%ebx
  801b4a:	74 04                	je     801b50 <devpipe_read+0x26>
				return i;
  801b4c:	89 d8                	mov    %ebx,%eax
  801b4e:	eb 44                	jmp    801b94 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b50:	89 f2                	mov    %esi,%edx
  801b52:	89 f8                	mov    %edi,%eax
  801b54:	e8 e5 fe ff ff       	call   801a3e <_pipeisclosed>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	75 32                	jne    801b8f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b5d:	e8 9e ef ff ff       	call   800b00 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b62:	8b 06                	mov    (%esi),%eax
  801b64:	3b 46 04             	cmp    0x4(%esi),%eax
  801b67:	74 df                	je     801b48 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b69:	99                   	cltd   
  801b6a:	c1 ea 1b             	shr    $0x1b,%edx
  801b6d:	01 d0                	add    %edx,%eax
  801b6f:	83 e0 1f             	and    $0x1f,%eax
  801b72:	29 d0                	sub    %edx,%eax
  801b74:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b7f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b82:	83 c3 01             	add    $0x1,%ebx
  801b85:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b88:	75 d8                	jne    801b62 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8d:	eb 05                	jmp    801b94 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5f                   	pop    %edi
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba7:	50                   	push   %eax
  801ba8:	e8 ca f1 ff ff       	call   800d77 <fd_alloc>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	89 c2                	mov    %eax,%edx
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 2c 01 00 00    	js     801ce6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bba:	83 ec 04             	sub    $0x4,%esp
  801bbd:	68 07 04 00 00       	push   $0x407
  801bc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 53 ef ff ff       	call   800b1f <sys_page_alloc>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	89 c2                	mov    %eax,%edx
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 0d 01 00 00    	js     801ce6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	e8 92 f1 ff ff       	call   800d77 <fd_alloc>
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	85 c0                	test   %eax,%eax
  801bec:	0f 88 e2 00 00 00    	js     801cd4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf2:	83 ec 04             	sub    $0x4,%esp
  801bf5:	68 07 04 00 00       	push   $0x407
  801bfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 1b ef ff ff       	call   800b1f <sys_page_alloc>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 c3 00 00 00    	js     801cd4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	e8 44 f1 ff ff       	call   800d60 <fd2data>
  801c1c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1e:	83 c4 0c             	add    $0xc,%esp
  801c21:	68 07 04 00 00       	push   $0x407
  801c26:	50                   	push   %eax
  801c27:	6a 00                	push   $0x0
  801c29:	e8 f1 ee ff ff       	call   800b1f <sys_page_alloc>
  801c2e:	89 c3                	mov    %eax,%ebx
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	85 c0                	test   %eax,%eax
  801c35:	0f 88 89 00 00 00    	js     801cc4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3b:	83 ec 0c             	sub    $0xc,%esp
  801c3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c41:	e8 1a f1 ff ff       	call   800d60 <fd2data>
  801c46:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4d:	50                   	push   %eax
  801c4e:	6a 00                	push   $0x0
  801c50:	56                   	push   %esi
  801c51:	6a 00                	push   $0x0
  801c53:	e8 0a ef ff ff       	call   800b62 <sys_page_map>
  801c58:	89 c3                	mov    %eax,%ebx
  801c5a:	83 c4 20             	add    $0x20,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 55                	js     801cb6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c84:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c91:	e8 ba f0 ff ff       	call   800d50 <fd2num>
  801c96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c99:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9b:	83 c4 04             	add    $0x4,%esp
  801c9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca1:	e8 aa f0 ff ff       	call   800d50 <fd2num>
  801ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb4:	eb 30                	jmp    801ce6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb6:	83 ec 08             	sub    $0x8,%esp
  801cb9:	56                   	push   %esi
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 e3 ee ff ff       	call   800ba4 <sys_page_unmap>
  801cc1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc4:	83 ec 08             	sub    $0x8,%esp
  801cc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 d3 ee ff ff       	call   800ba4 <sys_page_unmap>
  801cd1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd4:	83 ec 08             	sub    $0x8,%esp
  801cd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 c3 ee ff ff       	call   800ba4 <sys_page_unmap>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ceb:	5b                   	pop    %ebx
  801cec:	5e                   	pop    %esi
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf8:	50                   	push   %eax
  801cf9:	ff 75 08             	pushl  0x8(%ebp)
  801cfc:	e8 c5 f0 ff ff       	call   800dc6 <fd_lookup>
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 18                	js     801d20 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d08:	83 ec 0c             	sub    $0xc,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	e8 4d f0 ff ff       	call   800d60 <fd2data>
	return _pipeisclosed(fd, p);
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	e8 21 fd ff ff       	call   801a3e <_pipeisclosed>
  801d1d:	83 c4 10             	add    $0x10,%esp
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d32:	68 87 27 80 00       	push   $0x802787
  801d37:	ff 75 0c             	pushl  0xc(%ebp)
  801d3a:	e8 dd e9 ff ff       	call   80071c <strcpy>
	return 0;
}
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	57                   	push   %edi
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d52:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d57:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5d:	eb 2d                	jmp    801d8c <devcons_write+0x46>
		m = n - tot;
  801d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d62:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d64:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d67:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d6c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	53                   	push   %ebx
  801d73:	03 45 0c             	add    0xc(%ebp),%eax
  801d76:	50                   	push   %eax
  801d77:	57                   	push   %edi
  801d78:	e8 31 eb ff ff       	call   8008ae <memmove>
		sys_cputs(buf, m);
  801d7d:	83 c4 08             	add    $0x8,%esp
  801d80:	53                   	push   %ebx
  801d81:	57                   	push   %edi
  801d82:	e8 dc ec ff ff       	call   800a63 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d87:	01 de                	add    %ebx,%esi
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	89 f0                	mov    %esi,%eax
  801d8e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d91:	72 cc                	jb     801d5f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801daa:	74 2a                	je     801dd6 <devcons_read+0x3b>
  801dac:	eb 05                	jmp    801db3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dae:	e8 4d ed ff ff       	call   800b00 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db3:	e8 c9 ec ff ff       	call   800a81 <sys_cgetc>
  801db8:	85 c0                	test   %eax,%eax
  801dba:	74 f2                	je     801dae <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 16                	js     801dd6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc0:	83 f8 04             	cmp    $0x4,%eax
  801dc3:	74 0c                	je     801dd1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc8:	88 02                	mov    %al,(%edx)
	return 1;
  801dca:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcf:	eb 05                	jmp    801dd6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
  801de1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de4:	6a 01                	push   $0x1
  801de6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	e8 74 ec ff ff       	call   800a63 <sys_cputs>
}
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <getchar>:

int
getchar(void)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dfa:	6a 01                	push   $0x1
  801dfc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dff:	50                   	push   %eax
  801e00:	6a 00                	push   $0x0
  801e02:	e8 25 f2 ff ff       	call   80102c <read>
	if (r < 0)
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	78 0f                	js     801e1d <getchar+0x29>
		return r;
	if (r < 1)
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	7e 06                	jle    801e18 <getchar+0x24>
		return -E_EOF;
	return c;
  801e12:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e16:	eb 05                	jmp    801e1d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e18:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e28:	50                   	push   %eax
  801e29:	ff 75 08             	pushl  0x8(%ebp)
  801e2c:	e8 95 ef ff ff       	call   800dc6 <fd_lookup>
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 11                	js     801e49 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e41:	39 10                	cmp    %edx,(%eax)
  801e43:	0f 94 c0             	sete   %al
  801e46:	0f b6 c0             	movzbl %al,%eax
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <opencons>:

int
opencons(void)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e54:	50                   	push   %eax
  801e55:	e8 1d ef ff ff       	call   800d77 <fd_alloc>
  801e5a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e5d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 3e                	js     801ea1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e63:	83 ec 04             	sub    $0x4,%esp
  801e66:	68 07 04 00 00       	push   $0x407
  801e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 aa ec ff ff       	call   800b1f <sys_page_alloc>
  801e75:	83 c4 10             	add    $0x10,%esp
		return r;
  801e78:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 23                	js     801ea1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e87:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e93:	83 ec 0c             	sub    $0xc,%esp
  801e96:	50                   	push   %eax
  801e97:	e8 b4 ee ff ff       	call   800d50 <fd2num>
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	83 c4 10             	add    $0x10,%esp
}
  801ea1:	89 d0                	mov    %edx,%eax
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eaa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ead:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eb3:	e8 29 ec ff ff       	call   800ae1 <sys_getenvid>
  801eb8:	83 ec 0c             	sub    $0xc,%esp
  801ebb:	ff 75 0c             	pushl  0xc(%ebp)
  801ebe:	ff 75 08             	pushl  0x8(%ebp)
  801ec1:	56                   	push   %esi
  801ec2:	50                   	push   %eax
  801ec3:	68 94 27 80 00       	push   $0x802794
  801ec8:	e8 ca e2 ff ff       	call   800197 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ecd:	83 c4 18             	add    $0x18,%esp
  801ed0:	53                   	push   %ebx
  801ed1:	ff 75 10             	pushl  0x10(%ebp)
  801ed4:	e8 6d e2 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  801ed9:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  801ee0:	e8 b2 e2 ff ff       	call   800197 <cprintf>
  801ee5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee8:	cc                   	int3   
  801ee9:	eb fd                	jmp    801ee8 <_panic+0x43>

00801eeb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	56                   	push   %esi
  801eef:	53                   	push   %ebx
  801ef0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	74 0e                	je     801f0b <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	50                   	push   %eax
  801f01:	e8 c9 ed ff ff       	call   800ccf <sys_ipc_recv>
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	eb 10                	jmp    801f1b <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	68 00 00 00 f0       	push   $0xf0000000
  801f13:	e8 b7 ed ff ff       	call   800ccf <sys_ipc_recv>
  801f18:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	74 0e                	je     801f2d <ipc_recv+0x42>
    	*from_env_store = 0;
  801f1f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801f25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801f2b:	eb 24                	jmp    801f51 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801f2d:	85 f6                	test   %esi,%esi
  801f2f:	74 0a                	je     801f3b <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801f31:	a1 08 40 80 00       	mov    0x804008,%eax
  801f36:	8b 40 74             	mov    0x74(%eax),%eax
  801f39:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f3b:	85 db                	test   %ebx,%ebx
  801f3d:	74 0a                	je     801f49 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f44:	8b 40 78             	mov    0x78(%eax),%eax
  801f47:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801f49:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 0c             	sub    $0xc,%esp
  801f61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801f6a:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f71:	0f 44 d8             	cmove  %eax,%ebx
  801f74:	eb 1c                	jmp    801f92 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801f76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f79:	74 12                	je     801f8d <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801f7b:	50                   	push   %eax
  801f7c:	68 b8 27 80 00       	push   $0x8027b8
  801f81:	6a 4b                	push   $0x4b
  801f83:	68 d0 27 80 00       	push   $0x8027d0
  801f88:	e8 18 ff ff ff       	call   801ea5 <_panic>
        }	
        sys_yield();
  801f8d:	e8 6e eb ff ff       	call   800b00 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f92:	ff 75 14             	pushl  0x14(%ebp)
  801f95:	53                   	push   %ebx
  801f96:	56                   	push   %esi
  801f97:	57                   	push   %edi
  801f98:	e8 0f ed ff ff       	call   800cac <sys_ipc_try_send>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	75 d2                	jne    801f76 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  801fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc0:	8b 52 50             	mov    0x50(%edx),%edx
  801fc3:	39 ca                	cmp    %ecx,%edx
  801fc5:	75 0d                	jne    801fd4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fcf:	8b 40 48             	mov    0x48(%eax),%eax
  801fd2:	eb 0f                	jmp    801fe3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd4:	83 c0 01             	add    $0x1,%eax
  801fd7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fdc:	75 d9                	jne    801fb7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	c1 e8 16             	shr    $0x16,%eax
  801ff0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffc:	f6 c1 01             	test   $0x1,%cl
  801fff:	74 1d                	je     80201e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802001:	c1 ea 0c             	shr    $0xc,%edx
  802004:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200b:	f6 c2 01             	test   $0x1,%dl
  80200e:	74 0e                	je     80201e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802010:	c1 ea 0c             	shr    $0xc,%edx
  802013:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201a:	ef 
  80201b:	0f b7 c0             	movzwl %ax,%eax
}
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
