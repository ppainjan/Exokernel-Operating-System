
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 80 26 80 00       	push   $0x802680
  80003f:	e8 6e 01 00 00       	call   8001b2 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 1c 0e 00 00       	call   800e65 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 f8 26 80 00       	push   $0x8026f8
  800058:	e8 55 01 00 00       	call   8001b2 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 a8 26 80 00       	push   $0x8026a8
  80006c:	e8 41 01 00 00       	call   8001b2 <cprintf>
	sys_yield();
  800071:	e8 a5 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  800076:	e8 a0 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  80007b:	e8 9b 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  800080:	e8 96 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  800085:	e8 91 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  80008a:	e8 8c 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  80008f:	e8 87 0a 00 00       	call   800b1b <sys_yield>
	sys_yield();
  800094:	e8 82 0a 00 00       	call   800b1b <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 d0 26 80 00 	movl   $0x8026d0,(%esp)
  8000a0:	e8 0d 01 00 00       	call   8001b2 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 0e 0a 00 00       	call   800abb <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c0:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000c7:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ca:	e8 2d 0a 00 00       	call   800afc <sys_getenvid>
  8000cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dc:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e1:	85 db                	test   %ebx,%ebx
  8000e3:	7e 07                	jle    8000ec <libmain+0x37>
		binaryname = argv[0];
  8000e5:	8b 06                	mov    (%esi),%eax
  8000e7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	e8 3d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f6:	e8 0a 00 00 00       	call   800105 <exit>
}
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010b:	e8 35 11 00 00       	call   801245 <close_all>
	sys_env_destroy(0);
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	6a 00                	push   $0x0
  800115:	e8 a1 09 00 00       	call   800abb <sys_env_destroy>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	53                   	push   %ebx
  800123:	83 ec 04             	sub    $0x4,%esp
  800126:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800129:	8b 13                	mov    (%ebx),%edx
  80012b:	8d 42 01             	lea    0x1(%edx),%eax
  80012e:	89 03                	mov    %eax,(%ebx)
  800130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800133:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800137:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013c:	75 1a                	jne    800158 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013e:	83 ec 08             	sub    $0x8,%esp
  800141:	68 ff 00 00 00       	push   $0xff
  800146:	8d 43 08             	lea    0x8(%ebx),%eax
  800149:	50                   	push   %eax
  80014a:	e8 2f 09 00 00       	call   800a7e <sys_cputs>
		b->idx = 0;
  80014f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800155:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800158:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800171:	00 00 00 
	b.cnt = 0;
  800174:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017e:	ff 75 0c             	pushl  0xc(%ebp)
  800181:	ff 75 08             	pushl  0x8(%ebp)
  800184:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	68 1f 01 80 00       	push   $0x80011f
  800190:	e8 54 01 00 00       	call   8002e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800195:	83 c4 08             	add    $0x8,%esp
  800198:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 d4 08 00 00       	call   800a7e <sys_cputs>

	return b.cnt;
}
  8001aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bb:	50                   	push   %eax
  8001bc:	ff 75 08             	pushl  0x8(%ebp)
  8001bf:	e8 9d ff ff ff       	call   800161 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 1c             	sub    $0x1c,%esp
  8001cf:	89 c7                	mov    %eax,%edi
  8001d1:	89 d6                	mov    %edx,%esi
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ea:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ed:	39 d3                	cmp    %edx,%ebx
  8001ef:	72 05                	jb     8001f6 <printnum+0x30>
  8001f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f4:	77 45                	ja     80023b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	ff 75 18             	pushl  0x18(%ebp)
  8001fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ff:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800202:	53                   	push   %ebx
  800203:	ff 75 10             	pushl  0x10(%ebp)
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020c:	ff 75 e0             	pushl  -0x20(%ebp)
  80020f:	ff 75 dc             	pushl  -0x24(%ebp)
  800212:	ff 75 d8             	pushl  -0x28(%ebp)
  800215:	e8 c6 21 00 00       	call   8023e0 <__udivdi3>
  80021a:	83 c4 18             	add    $0x18,%esp
  80021d:	52                   	push   %edx
  80021e:	50                   	push   %eax
  80021f:	89 f2                	mov    %esi,%edx
  800221:	89 f8                	mov    %edi,%eax
  800223:	e8 9e ff ff ff       	call   8001c6 <printnum>
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	eb 18                	jmp    800245 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	ff 75 18             	pushl  0x18(%ebp)
  800234:	ff d7                	call   *%edi
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	eb 03                	jmp    80023e <printnum+0x78>
  80023b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	85 db                	test   %ebx,%ebx
  800243:	7f e8                	jg     80022d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	56                   	push   %esi
  800249:	83 ec 04             	sub    $0x4,%esp
  80024c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024f:	ff 75 e0             	pushl  -0x20(%ebp)
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	e8 b3 22 00 00       	call   802510 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 20 27 80 00 	movsbl 0x802720(%eax),%eax
  800267:	50                   	push   %eax
  800268:	ff d7                	call   *%edi
}
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800278:	83 fa 01             	cmp    $0x1,%edx
  80027b:	7e 0e                	jle    80028b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	8b 52 04             	mov    0x4(%edx),%edx
  800289:	eb 22                	jmp    8002ad <getuint+0x38>
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 10                	je     80029f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
  80029d:	eb 0e                	jmp    8002ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002be:	73 0a                	jae    8002ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	88 02                	mov    %al,(%edx)
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d5:	50                   	push   %eax
  8002d6:	ff 75 10             	pushl  0x10(%ebp)
  8002d9:	ff 75 0c             	pushl  0xc(%ebp)
  8002dc:	ff 75 08             	pushl  0x8(%ebp)
  8002df:	e8 05 00 00 00       	call   8002e9 <vprintfmt>
	va_end(ap);
}
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	57                   	push   %edi
  8002ed:	56                   	push   %esi
  8002ee:	53                   	push   %ebx
  8002ef:	83 ec 2c             	sub    $0x2c,%esp
  8002f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fb:	eb 12                	jmp    80030f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	0f 84 89 03 00 00    	je     80068e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	53                   	push   %ebx
  800309:	50                   	push   %eax
  80030a:	ff d6                	call   *%esi
  80030c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030f:	83 c7 01             	add    $0x1,%edi
  800312:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800316:	83 f8 25             	cmp    $0x25,%eax
  800319:	75 e2                	jne    8002fd <vprintfmt+0x14>
  80031b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800326:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800334:	ba 00 00 00 00       	mov    $0x0,%edx
  800339:	eb 07                	jmp    800342 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8d 47 01             	lea    0x1(%edi),%eax
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	0f b6 07             	movzbl (%edi),%eax
  80034b:	0f b6 c8             	movzbl %al,%ecx
  80034e:	83 e8 23             	sub    $0x23,%eax
  800351:	3c 55                	cmp    $0x55,%al
  800353:	0f 87 1a 03 00 00    	ja     800673 <vprintfmt+0x38a>
  800359:	0f b6 c0             	movzbl %al,%eax
  80035c:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800366:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036a:	eb d6                	jmp    800342 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036f:	b8 00 00 00 00       	mov    $0x0,%eax
  800374:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800377:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800381:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800384:	83 fa 09             	cmp    $0x9,%edx
  800387:	77 39                	ja     8003c2 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800389:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038c:	eb e9                	jmp    800377 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 48 04             	lea    0x4(%eax),%ecx
  800394:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800397:	8b 00                	mov    (%eax),%eax
  800399:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039f:	eb 27                	jmp    8003c8 <vprintfmt+0xdf>
  8003a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a4:	85 c0                	test   %eax,%eax
  8003a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ab:	0f 49 c8             	cmovns %eax,%ecx
  8003ae:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	eb 8c                	jmp    800342 <vprintfmt+0x59>
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c0:	eb 80                	jmp    800342 <vprintfmt+0x59>
  8003c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c5:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cc:	0f 89 70 ff ff ff    	jns    800342 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003df:	e9 5e ff ff ff       	jmp    800342 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ea:	e9 53 ff ff ff       	jmp    800342 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	53                   	push   %ebx
  8003fc:	ff 30                	pushl  (%eax)
  8003fe:	ff d6                	call   *%esi
			break;
  800400:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800406:	e9 04 ff ff ff       	jmp    80030f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	99                   	cltd   
  800417:	31 d0                	xor    %edx,%eax
  800419:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 0f             	cmp    $0xf,%eax
  80041e:	7f 0b                	jg     80042b <vprintfmt+0x142>
  800420:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	75 18                	jne    800443 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042b:	50                   	push   %eax
  80042c:	68 38 27 80 00       	push   $0x802738
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 94 fe ff ff       	call   8002cc <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043e:	e9 cc fe ff ff       	jmp    80030f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 4d 2c 80 00       	push   $0x802c4d
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 7c fe ff ff       	call   8002cc <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800456:	e9 b4 fe ff ff       	jmp    80030f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800466:	85 ff                	test   %edi,%edi
  800468:	b8 31 27 80 00       	mov    $0x802731,%eax
  80046d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800470:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800474:	0f 8e 94 00 00 00    	jle    80050e <vprintfmt+0x225>
  80047a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047e:	0f 84 98 00 00 00    	je     80051c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	ff 75 d0             	pushl  -0x30(%ebp)
  80048a:	57                   	push   %edi
  80048b:	e8 86 02 00 00       	call   800716 <strnlen>
  800490:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800493:	29 c1                	sub    %eax,%ecx
  800495:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	eb 0f                	jmp    8004b8 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	53                   	push   %ebx
  8004ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	7f ed                	jg     8004a9 <vprintfmt+0x1c0>
  8004bc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c2:	85 c9                	test   %ecx,%ecx
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	0f 49 c1             	cmovns %ecx,%eax
  8004cc:	29 c1                	sub    %eax,%ecx
  8004ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d7:	89 cb                	mov    %ecx,%ebx
  8004d9:	eb 4d                	jmp    800528 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004df:	74 1b                	je     8004fc <vprintfmt+0x213>
  8004e1:	0f be c0             	movsbl %al,%eax
  8004e4:	83 e8 20             	sub    $0x20,%eax
  8004e7:	83 f8 5e             	cmp    $0x5e,%eax
  8004ea:	76 10                	jbe    8004fc <vprintfmt+0x213>
					putch('?', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	ff 75 0c             	pushl  0xc(%ebp)
  8004f2:	6a 3f                	push   $0x3f
  8004f4:	ff 55 08             	call   *0x8(%ebp)
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	eb 0d                	jmp    800509 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	52                   	push   %edx
  800503:	ff 55 08             	call   *0x8(%ebp)
  800506:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800509:	83 eb 01             	sub    $0x1,%ebx
  80050c:	eb 1a                	jmp    800528 <vprintfmt+0x23f>
  80050e:	89 75 08             	mov    %esi,0x8(%ebp)
  800511:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800514:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800517:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051a:	eb 0c                	jmp    800528 <vprintfmt+0x23f>
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800528:	83 c7 01             	add    $0x1,%edi
  80052b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052f:	0f be d0             	movsbl %al,%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	74 23                	je     800559 <vprintfmt+0x270>
  800536:	85 f6                	test   %esi,%esi
  800538:	78 a1                	js     8004db <vprintfmt+0x1f2>
  80053a:	83 ee 01             	sub    $0x1,%esi
  80053d:	79 9c                	jns    8004db <vprintfmt+0x1f2>
  80053f:	89 df                	mov    %ebx,%edi
  800541:	8b 75 08             	mov    0x8(%ebp),%esi
  800544:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800547:	eb 18                	jmp    800561 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	53                   	push   %ebx
  80054d:	6a 20                	push   $0x20
  80054f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800551:	83 ef 01             	sub    $0x1,%edi
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb 08                	jmp    800561 <vprintfmt+0x278>
  800559:	89 df                	mov    %ebx,%edi
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	85 ff                	test   %edi,%edi
  800563:	7f e4                	jg     800549 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800568:	e9 a2 fd ff ff       	jmp    80030f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056d:	83 fa 01             	cmp    $0x1,%edx
  800570:	7e 16                	jle    800588 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 08             	lea    0x8(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 50 04             	mov    0x4(%eax),%edx
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	eb 32                	jmp    8005ba <vprintfmt+0x2d1>
	else if (lflag)
  800588:	85 d2                	test   %edx,%edx
  80058a:	74 18                	je     8005a4 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	89 c1                	mov    %eax,%ecx
  80059c:	c1 f9 1f             	sar    $0x1f,%ecx
  80059f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a2:	eb 16                	jmp    8005ba <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	89 c1                	mov    %eax,%ecx
  8005b4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c9:	79 74                	jns    80063f <vprintfmt+0x356>
				putch('-', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 2d                	push   $0x2d
  8005d1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d9:	f7 d8                	neg    %eax
  8005db:	83 d2 00             	adc    $0x0,%edx
  8005de:	f7 da                	neg    %edx
  8005e0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e8:	eb 55                	jmp    80063f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ed:	e8 83 fc ff ff       	call   800275 <getuint>
			base = 10;
  8005f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f7:	eb 46                	jmp    80063f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fc:	e8 74 fc ff ff       	call   800275 <getuint>
		        base = 8;
  800601:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800606:	eb 37                	jmp    80063f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 30                	push   $0x30
  80060e:	ff d6                	call   *%esi
			putch('x', putdat);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 78                	push   $0x78
  800616:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800628:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800630:	eb 0d                	jmp    80063f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 3b fc ff ff       	call   800275 <getuint>
			base = 16;
  80063a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800646:	57                   	push   %edi
  800647:	ff 75 e0             	pushl  -0x20(%ebp)
  80064a:	51                   	push   %ecx
  80064b:	52                   	push   %edx
  80064c:	50                   	push   %eax
  80064d:	89 da                	mov    %ebx,%edx
  80064f:	89 f0                	mov    %esi,%eax
  800651:	e8 70 fb ff ff       	call   8001c6 <printnum>
			break;
  800656:	83 c4 20             	add    $0x20,%esp
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065c:	e9 ae fc ff ff       	jmp    80030f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	51                   	push   %ecx
  800666:	ff d6                	call   *%esi
			break;
  800668:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066e:	e9 9c fc ff ff       	jmp    80030f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 25                	push   $0x25
  800679:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	eb 03                	jmp    800683 <vprintfmt+0x39a>
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800687:	75 f7                	jne    800680 <vprintfmt+0x397>
  800689:	e9 81 fc ff ff       	jmp    80030f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5f                   	pop    %edi
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	83 ec 18             	sub    $0x18,%esp
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	74 26                	je     8006dd <vsnprintf+0x47>
  8006b7:	85 d2                	test   %edx,%edx
  8006b9:	7e 22                	jle    8006dd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bb:	ff 75 14             	pushl  0x14(%ebp)
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	68 af 02 80 00       	push   $0x8002af
  8006ca:	e8 1a fc ff ff       	call   8002e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 05                	jmp    8006e2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ed:	50                   	push   %eax
  8006ee:	ff 75 10             	pushl  0x10(%ebp)
  8006f1:	ff 75 0c             	pushl  0xc(%ebp)
  8006f4:	ff 75 08             	pushl  0x8(%ebp)
  8006f7:	e8 9a ff ff ff       	call   800696 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	eb 03                	jmp    80070e <strlen+0x10>
		n++;
  80070b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800712:	75 f7                	jne    80070b <strlen+0xd>
		n++;
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
  800724:	eb 03                	jmp    800729 <strnlen+0x13>
		n++;
  800726:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800729:	39 c2                	cmp    %eax,%edx
  80072b:	74 08                	je     800735 <strnlen+0x1f>
  80072d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800731:	75 f3                	jne    800726 <strnlen+0x10>
  800733:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	53                   	push   %ebx
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800741:	89 c2                	mov    %eax,%edx
  800743:	83 c2 01             	add    $0x1,%edx
  800746:	83 c1 01             	add    $0x1,%ecx
  800749:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800750:	84 db                	test   %bl,%bl
  800752:	75 ef                	jne    800743 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800754:	5b                   	pop    %ebx
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075e:	53                   	push   %ebx
  80075f:	e8 9a ff ff ff       	call   8006fe <strlen>
  800764:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800767:	ff 75 0c             	pushl  0xc(%ebp)
  80076a:	01 d8                	add    %ebx,%eax
  80076c:	50                   	push   %eax
  80076d:	e8 c5 ff ff ff       	call   800737 <strcpy>
	return dst;
}
  800772:	89 d8                	mov    %ebx,%eax
  800774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800777:	c9                   	leave  
  800778:	c3                   	ret    

00800779 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	89 f3                	mov    %esi,%ebx
  800786:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800789:	89 f2                	mov    %esi,%edx
  80078b:	eb 0f                	jmp    80079c <strncpy+0x23>
		*dst++ = *src;
  80078d:	83 c2 01             	add    $0x1,%edx
  800790:	0f b6 01             	movzbl (%ecx),%eax
  800793:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800796:	80 39 01             	cmpb   $0x1,(%ecx)
  800799:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079c:	39 da                	cmp    %ebx,%edx
  80079e:	75 ed                	jne    80078d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a0:	89 f0                	mov    %esi,%eax
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	56                   	push   %esi
  8007aa:	53                   	push   %ebx
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 21                	je     8007db <strlcpy+0x35>
  8007ba:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007be:	89 f2                	mov    %esi,%edx
  8007c0:	eb 09                	jmp    8007cb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cb:	39 c2                	cmp    %eax,%edx
  8007cd:	74 09                	je     8007d8 <strlcpy+0x32>
  8007cf:	0f b6 19             	movzbl (%ecx),%ebx
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ec                	jne    8007c2 <strlcpy+0x1c>
  8007d6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007db:	29 f0                	sub    %esi,%eax
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ea:	eb 06                	jmp    8007f2 <strcmp+0x11>
		p++, q++;
  8007ec:	83 c1 01             	add    $0x1,%ecx
  8007ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 04                	je     8007fd <strcmp+0x1c>
  8007f9:	3a 02                	cmp    (%edx),%al
  8007fb:	74 ef                	je     8007ec <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 c0             	movzbl %al,%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 c3                	mov    %eax,%ebx
  800813:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800816:	eb 06                	jmp    80081e <strncmp+0x17>
		n--, p++, q++;
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081e:	39 d8                	cmp    %ebx,%eax
  800820:	74 15                	je     800837 <strncmp+0x30>
  800822:	0f b6 08             	movzbl (%eax),%ecx
  800825:	84 c9                	test   %cl,%cl
  800827:	74 04                	je     80082d <strncmp+0x26>
  800829:	3a 0a                	cmp    (%edx),%cl
  80082b:	74 eb                	je     800818 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082d:	0f b6 00             	movzbl (%eax),%eax
  800830:	0f b6 12             	movzbl (%edx),%edx
  800833:	29 d0                	sub    %edx,%eax
  800835:	eb 05                	jmp    80083c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800849:	eb 07                	jmp    800852 <strchr+0x13>
		if (*s == c)
  80084b:	38 ca                	cmp    %cl,%dl
  80084d:	74 0f                	je     80085e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	0f b6 10             	movzbl (%eax),%edx
  800855:	84 d2                	test   %dl,%dl
  800857:	75 f2                	jne    80084b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	eb 03                	jmp    80086f <strfind+0xf>
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800872:	38 ca                	cmp    %cl,%dl
  800874:	74 04                	je     80087a <strfind+0x1a>
  800876:	84 d2                	test   %dl,%dl
  800878:	75 f2                	jne    80086c <strfind+0xc>
			break;
	return (char *) s;
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	8b 7d 08             	mov    0x8(%ebp),%edi
  800885:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	74 36                	je     8008c2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800892:	75 28                	jne    8008bc <memset+0x40>
  800894:	f6 c1 03             	test   $0x3,%cl
  800897:	75 23                	jne    8008bc <memset+0x40>
		c &= 0xFF;
  800899:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089d:	89 d3                	mov    %edx,%ebx
  80089f:	c1 e3 08             	shl    $0x8,%ebx
  8008a2:	89 d6                	mov    %edx,%esi
  8008a4:	c1 e6 18             	shl    $0x18,%esi
  8008a7:	89 d0                	mov    %edx,%eax
  8008a9:	c1 e0 10             	shl    $0x10,%eax
  8008ac:	09 f0                	or     %esi,%eax
  8008ae:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b0:	89 d8                	mov    %ebx,%eax
  8008b2:	09 d0                	or     %edx,%eax
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
  8008b7:	fc                   	cld    
  8008b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ba:	eb 06                	jmp    8008c2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	fc                   	cld    
  8008c0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c2:	89 f8                	mov    %edi,%eax
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5f                   	pop    %edi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	57                   	push   %edi
  8008cd:	56                   	push   %esi
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d7:	39 c6                	cmp    %eax,%esi
  8008d9:	73 35                	jae    800910 <memmove+0x47>
  8008db:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008de:	39 d0                	cmp    %edx,%eax
  8008e0:	73 2e                	jae    800910 <memmove+0x47>
		s += n;
		d += n;
  8008e2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	09 fe                	or     %edi,%esi
  8008e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ef:	75 13                	jne    800904 <memmove+0x3b>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 0e                	jne    800904 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f6:	83 ef 04             	sub    $0x4,%edi
  8008f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
  8008ff:	fd                   	std    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 09                	jmp    80090d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800904:	83 ef 01             	sub    $0x1,%edi
  800907:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090a:	fd                   	std    
  80090b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090d:	fc                   	cld    
  80090e:	eb 1d                	jmp    80092d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800910:	89 f2                	mov    %esi,%edx
  800912:	09 c2                	or     %eax,%edx
  800914:	f6 c2 03             	test   $0x3,%dl
  800917:	75 0f                	jne    800928 <memmove+0x5f>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0a                	jne    800928 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800926:	eb 05                	jmp    80092d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800928:	89 c7                	mov    %eax,%edi
  80092a:	fc                   	cld    
  80092b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800934:	ff 75 10             	pushl  0x10(%ebp)
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	ff 75 08             	pushl  0x8(%ebp)
  80093d:	e8 87 ff ff ff       	call   8008c9 <memmove>
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	89 c6                	mov    %eax,%esi
  800951:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800954:	eb 1a                	jmp    800970 <memcmp+0x2c>
		if (*s1 != *s2)
  800956:	0f b6 08             	movzbl (%eax),%ecx
  800959:	0f b6 1a             	movzbl (%edx),%ebx
  80095c:	38 d9                	cmp    %bl,%cl
  80095e:	74 0a                	je     80096a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800960:	0f b6 c1             	movzbl %cl,%eax
  800963:	0f b6 db             	movzbl %bl,%ebx
  800966:	29 d8                	sub    %ebx,%eax
  800968:	eb 0f                	jmp    800979 <memcmp+0x35>
		s1++, s2++;
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800970:	39 f0                	cmp    %esi,%eax
  800972:	75 e2                	jne    800956 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800984:	89 c1                	mov    %eax,%ecx
  800986:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800989:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098d:	eb 0a                	jmp    800999 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098f:	0f b6 10             	movzbl (%eax),%edx
  800992:	39 da                	cmp    %ebx,%edx
  800994:	74 07                	je     80099d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	39 c8                	cmp    %ecx,%eax
  80099b:	72 f2                	jb     80098f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	eb 03                	jmp    8009b1 <strtol+0x11>
		s++;
  8009ae:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	3c 20                	cmp    $0x20,%al
  8009b6:	74 f6                	je     8009ae <strtol+0xe>
  8009b8:	3c 09                	cmp    $0x9,%al
  8009ba:	74 f2                	je     8009ae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bc:	3c 2b                	cmp    $0x2b,%al
  8009be:	75 0a                	jne    8009ca <strtol+0x2a>
		s++;
  8009c0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c8:	eb 11                	jmp    8009db <strtol+0x3b>
  8009ca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cf:	3c 2d                	cmp    $0x2d,%al
  8009d1:	75 08                	jne    8009db <strtol+0x3b>
		s++, neg = 1;
  8009d3:	83 c1 01             	add    $0x1,%ecx
  8009d6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009db:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e1:	75 15                	jne    8009f8 <strtol+0x58>
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 10                	jne    8009f8 <strtol+0x58>
  8009e8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ec:	75 7c                	jne    800a6a <strtol+0xca>
		s += 2, base = 16;
  8009ee:	83 c1 02             	add    $0x2,%ecx
  8009f1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f6:	eb 16                	jmp    800a0e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	75 12                	jne    800a0e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a01:	80 39 30             	cmpb   $0x30,(%ecx)
  800a04:	75 08                	jne    800a0e <strtol+0x6e>
		s++, base = 8;
  800a06:	83 c1 01             	add    $0x1,%ecx
  800a09:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a16:	0f b6 11             	movzbl (%ecx),%edx
  800a19:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1c:	89 f3                	mov    %esi,%ebx
  800a1e:	80 fb 09             	cmp    $0x9,%bl
  800a21:	77 08                	ja     800a2b <strtol+0x8b>
			dig = *s - '0';
  800a23:	0f be d2             	movsbl %dl,%edx
  800a26:	83 ea 30             	sub    $0x30,%edx
  800a29:	eb 22                	jmp    800a4d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 19             	cmp    $0x19,%bl
  800a33:	77 08                	ja     800a3d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 57             	sub    $0x57,%edx
  800a3b:	eb 10                	jmp    800a4d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a40:	89 f3                	mov    %esi,%ebx
  800a42:	80 fb 19             	cmp    $0x19,%bl
  800a45:	77 16                	ja     800a5d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a47:	0f be d2             	movsbl %dl,%edx
  800a4a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a50:	7d 0b                	jge    800a5d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a59:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5b:	eb b9                	jmp    800a16 <strtol+0x76>

	if (endptr)
  800a5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a61:	74 0d                	je     800a70 <strtol+0xd0>
		*endptr = (char *) s;
  800a63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a66:	89 0e                	mov    %ecx,(%esi)
  800a68:	eb 06                	jmp    800a70 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	74 98                	je     800a06 <strtol+0x66>
  800a6e:	eb 9e                	jmp    800a0e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a70:	89 c2                	mov    %eax,%edx
  800a72:	f7 da                	neg    %edx
  800a74:	85 ff                	test   %edi,%edi
  800a76:	0f 45 c2             	cmovne %edx,%eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	89 c6                	mov    %eax,%esi
  800a95:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aac:	89 d1                	mov    %edx,%ecx
  800aae:	89 d3                	mov    %edx,%ebx
  800ab0:	89 d7                	mov    %edx,%edi
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 cb                	mov    %ecx,%ebx
  800ad3:	89 cf                	mov    %ecx,%edi
  800ad5:	89 ce                	mov    %ecx,%esi
  800ad7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	7e 17                	jle    800af4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800add:	83 ec 0c             	sub    $0xc,%esp
  800ae0:	50                   	push   %eax
  800ae1:	6a 03                	push   $0x3
  800ae3:	68 1f 2a 80 00       	push   $0x802a1f
  800ae8:	6a 23                	push   $0x23
  800aea:	68 3c 2a 80 00       	push   $0x802a3c
  800aef:	e8 db 16 00 00       	call   8021cf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_yield>:

void
sys_yield(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	be 00 00 00 00       	mov    $0x0,%esi
  800b48:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b56:	89 f7                	mov    %esi,%edi
  800b58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 04                	push   $0x4
  800b64:	68 1f 2a 80 00       	push   $0x802a1f
  800b69:	6a 23                	push   $0x23
  800b6b:	68 3c 2a 80 00       	push   $0x802a3c
  800b70:	e8 5a 16 00 00       	call   8021cf <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b97:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 05                	push   $0x5
  800ba6:	68 1f 2a 80 00       	push   $0x802a1f
  800bab:	6a 23                	push   $0x23
  800bad:	68 3c 2a 80 00       	push   $0x802a3c
  800bb2:	e8 18 16 00 00       	call   8021cf <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcd:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	89 df                	mov    %ebx,%edi
  800bda:	89 de                	mov    %ebx,%esi
  800bdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 06                	push   $0x6
  800be8:	68 1f 2a 80 00       	push   $0x802a1f
  800bed:	6a 23                	push   $0x23
  800bef:	68 3c 2a 80 00       	push   $0x802a3c
  800bf4:	e8 d6 15 00 00       	call   8021cf <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 08                	push   $0x8
  800c2a:	68 1f 2a 80 00       	push   $0x802a1f
  800c2f:	6a 23                	push   $0x23
  800c31:	68 3c 2a 80 00       	push   $0x802a3c
  800c36:	e8 94 15 00 00       	call   8021cf <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 09 00 00 00       	mov    $0x9,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 09                	push   $0x9
  800c6c:	68 1f 2a 80 00       	push   $0x802a1f
  800c71:	6a 23                	push   $0x23
  800c73:	68 3c 2a 80 00       	push   $0x802a3c
  800c78:	e8 52 15 00 00       	call   8021cf <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 0a                	push   $0xa
  800cae:	68 1f 2a 80 00       	push   $0x802a1f
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 3c 2a 80 00       	push   $0x802a3c
  800cba:	e8 10 15 00 00       	call   8021cf <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	be 00 00 00 00       	mov    $0x0,%esi
  800cd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 cb                	mov    %ecx,%ebx
  800d02:	89 cf                	mov    %ecx,%edi
  800d04:	89 ce                	mov    %ecx,%esi
  800d06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 0d                	push   $0xd
  800d12:	68 1f 2a 80 00       	push   $0x802a1f
  800d17:	6a 23                	push   $0x23
  800d19:	68 3c 2a 80 00       	push   $0x802a3c
  800d1e:	e8 ac 14 00 00       	call   8021cf <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	ba 00 00 00 00       	mov    $0x0,%edx
  800d36:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3b:	89 d1                	mov    %edx,%ecx
  800d3d:	89 d3                	mov    %edx,%ebx
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 d6                	mov    %edx,%esi
  800d43:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d75:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800d77:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d7b:	74 2e                	je     800dab <pgfault+0x40>
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	c1 ea 16             	shr    $0x16,%edx
  800d82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d89:	f6 c2 01             	test   $0x1,%dl
  800d8c:	74 1d                	je     800dab <pgfault+0x40>
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	c1 ea 0c             	shr    $0xc,%edx
  800d93:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d9a:	f6 c1 01             	test   $0x1,%cl
  800d9d:	74 0c                	je     800dab <pgfault+0x40>
  800d9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da6:	f6 c6 08             	test   $0x8,%dh
  800da9:	75 14                	jne    800dbf <pgfault+0x54>
        panic("Not copy-on-write\n");
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	68 4a 2a 80 00       	push   $0x802a4a
  800db3:	6a 1d                	push   $0x1d
  800db5:	68 5d 2a 80 00       	push   $0x802a5d
  800dba:	e8 10 14 00 00       	call   8021cf <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800dbf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc4:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	6a 07                	push   $0x7
  800dcb:	68 00 f0 7f 00       	push   $0x7ff000
  800dd0:	6a 00                	push   $0x0
  800dd2:	e8 63 fd ff ff       	call   800b3a <sys_page_alloc>
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	79 14                	jns    800df2 <pgfault+0x87>
		panic("page alloc failed \n");
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	68 68 2a 80 00       	push   $0x802a68
  800de6:	6a 28                	push   $0x28
  800de8:	68 5d 2a 80 00       	push   $0x802a5d
  800ded:	e8 dd 13 00 00       	call   8021cf <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 00 10 00 00       	push   $0x1000
  800dfa:	53                   	push   %ebx
  800dfb:	68 00 f0 7f 00       	push   $0x7ff000
  800e00:	e8 2c fb ff ff       	call   800931 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800e05:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e0c:	53                   	push   %ebx
  800e0d:	6a 00                	push   $0x0
  800e0f:	68 00 f0 7f 00       	push   $0x7ff000
  800e14:	6a 00                	push   $0x0
  800e16:	e8 62 fd ff ff       	call   800b7d <sys_page_map>
  800e1b:	83 c4 20             	add    $0x20,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 14                	jns    800e36 <pgfault+0xcb>
        panic("page map failed \n");
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	68 7c 2a 80 00       	push   $0x802a7c
  800e2a:	6a 2b                	push   $0x2b
  800e2c:	68 5d 2a 80 00       	push   $0x802a5d
  800e31:	e8 99 13 00 00       	call   8021cf <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	68 00 f0 7f 00       	push   $0x7ff000
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 7a fd ff ff       	call   800bbf <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	79 14                	jns    800e60 <pgfault+0xf5>
        panic("page unmap failed\n");
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	68 8e 2a 80 00       	push   $0x802a8e
  800e54:	6a 2d                	push   $0x2d
  800e56:	68 5d 2a 80 00       	push   $0x802a5d
  800e5b:	e8 6f 13 00 00       	call   8021cf <_panic>
	
	//panic("pgfault not implemented");
}
  800e60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800e6e:	68 6b 0d 80 00       	push   $0x800d6b
  800e73:	e8 9d 13 00 00       	call   802215 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e78:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7d:	cd 30                	int    $0x30
  800e7f:	89 c7                	mov    %eax,%edi
  800e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 12                	jns    800e9d <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800e8b:	50                   	push   %eax
  800e8c:	68 a1 2a 80 00       	push   $0x802aa1
  800e91:	6a 7a                	push   $0x7a
  800e93:	68 5d 2a 80 00       	push   $0x802a5d
  800e98:	e8 32 13 00 00       	call   8021cf <_panic>
  800e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	75 21                	jne    800ec7 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea6:	e8 51 fc ff ff       	call   800afc <sys_getenvid>
  800eab:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eb3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	e9 91 01 00 00       	jmp    801058 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	c1 e8 16             	shr    $0x16,%eax
  800ecc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed3:	a8 01                	test   $0x1,%al
  800ed5:	0f 84 06 01 00 00    	je     800fe1 <fork+0x17c>
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	c1 e8 0c             	shr    $0xc,%eax
  800ee0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	0f 84 f1 00 00 00    	je     800fe1 <fork+0x17c>
  800ef0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef7:	f6 c2 04             	test   $0x4,%dl
  800efa:	0f 84 e1 00 00 00    	je     800fe1 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800f00:	89 c6                	mov    %eax,%esi
  800f02:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800f05:	89 f2                	mov    %esi,%edx
  800f07:	c1 ea 16             	shr    $0x16,%edx
  800f0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800f11:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800f18:	f6 c6 04             	test   $0x4,%dh
  800f1b:	74 39                	je     800f56 <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  800f1d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f24:	83 ec 0c             	sub    $0xc,%esp
  800f27:	25 07 0e 00 00       	and    $0xe07,%eax
  800f2c:	50                   	push   %eax
  800f2d:	56                   	push   %esi
  800f2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f31:	56                   	push   %esi
  800f32:	6a 00                	push   $0x0
  800f34:	e8 44 fc ff ff       	call   800b7d <sys_page_map>
  800f39:	83 c4 20             	add    $0x20,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	0f 89 9d 00 00 00    	jns    800fe1 <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  800f44:	50                   	push   %eax
  800f45:	68 f8 2a 80 00       	push   $0x802af8
  800f4a:	6a 4b                	push   $0x4b
  800f4c:	68 5d 2a 80 00       	push   $0x802a5d
  800f51:	e8 79 12 00 00       	call   8021cf <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  800f56:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f5c:	74 59                	je     800fb7 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	68 05 08 00 00       	push   $0x805
  800f66:	56                   	push   %esi
  800f67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 0b fc ff ff       	call   800b7d <sys_page_map>
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 12                	jns    800f8b <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  800f79:	50                   	push   %eax
  800f7a:	68 28 2b 80 00       	push   $0x802b28
  800f7f:	6a 50                	push   $0x50
  800f81:	68 5d 2a 80 00       	push   $0x802a5d
  800f86:	e8 44 12 00 00       	call   8021cf <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	68 05 08 00 00       	push   $0x805
  800f93:	56                   	push   %esi
  800f94:	6a 00                	push   $0x0
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 df fb ff ff       	call   800b7d <sys_page_map>
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	79 3c                	jns    800fe1 <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  800fa5:	50                   	push   %eax
  800fa6:	68 50 2b 80 00       	push   $0x802b50
  800fab:	6a 53                	push   $0x53
  800fad:	68 5d 2a 80 00       	push   $0x802a5d
  800fb2:	e8 18 12 00 00       	call   8021cf <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	6a 05                	push   $0x5
  800fbc:	56                   	push   %esi
  800fbd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc0:	56                   	push   %esi
  800fc1:	6a 00                	push   $0x0
  800fc3:	e8 b5 fb ff ff       	call   800b7d <sys_page_map>
  800fc8:	83 c4 20             	add    $0x20,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	79 12                	jns    800fe1 <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  800fcf:	50                   	push   %eax
  800fd0:	68 78 2b 80 00       	push   $0x802b78
  800fd5:	6a 58                	push   $0x58
  800fd7:	68 5d 2a 80 00       	push   $0x802a5d
  800fdc:	e8 ee 11 00 00       	call   8021cf <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800fe1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe7:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fed:	0f 85 d4 fe ff ff    	jne    800ec7 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	6a 07                	push   $0x7
  800ff8:	68 00 f0 bf ee       	push   $0xeebff000
  800ffd:	57                   	push   %edi
  800ffe:	e8 37 fb ff ff       	call   800b3a <sys_page_alloc>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	79 17                	jns    801021 <fork+0x1bc>
        panic("page alloc failed\n");
  80100a:	83 ec 04             	sub    $0x4,%esp
  80100d:	68 b3 2a 80 00       	push   $0x802ab3
  801012:	68 87 00 00 00       	push   $0x87
  801017:	68 5d 2a 80 00       	push   $0x802a5d
  80101c:	e8 ae 11 00 00       	call   8021cf <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801021:	83 ec 08             	sub    $0x8,%esp
  801024:	68 84 22 80 00       	push   $0x802284
  801029:	57                   	push   %edi
  80102a:	e8 56 fc ff ff       	call   800c85 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80102f:	83 c4 08             	add    $0x8,%esp
  801032:	6a 02                	push   $0x2
  801034:	57                   	push   %edi
  801035:	e8 c7 fb ff ff       	call   800c01 <sys_env_set_status>
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	79 15                	jns    801056 <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  801041:	50                   	push   %eax
  801042:	68 c6 2a 80 00       	push   $0x802ac6
  801047:	68 8c 00 00 00       	push   $0x8c
  80104c:	68 5d 2a 80 00       	push   $0x802a5d
  801051:	e8 79 11 00 00       	call   8021cf <_panic>

	return envid;
  801056:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <sfork>:

// Challenge!
int
sfork(void)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801066:	68 df 2a 80 00       	push   $0x802adf
  80106b:	68 98 00 00 00       	push   $0x98
  801070:	68 5d 2a 80 00       	push   $0x802a5d
  801075:	e8 55 11 00 00       	call   8021cf <_panic>

0080107a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	05 00 00 00 30       	add    $0x30000000,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
}
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	05 00 00 00 30       	add    $0x30000000,%eax
  801095:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80109a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	c1 ea 16             	shr    $0x16,%edx
  8010b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b8:	f6 c2 01             	test   $0x1,%dl
  8010bb:	74 11                	je     8010ce <fd_alloc+0x2d>
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	c1 ea 0c             	shr    $0xc,%edx
  8010c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c9:	f6 c2 01             	test   $0x1,%dl
  8010cc:	75 09                	jne    8010d7 <fd_alloc+0x36>
			*fd_store = fd;
  8010ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d5:	eb 17                	jmp    8010ee <fd_alloc+0x4d>
  8010d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010e1:	75 c9                	jne    8010ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f6:	83 f8 1f             	cmp    $0x1f,%eax
  8010f9:	77 36                	ja     801131 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010fb:	c1 e0 0c             	shl    $0xc,%eax
  8010fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801103:	89 c2                	mov    %eax,%edx
  801105:	c1 ea 16             	shr    $0x16,%edx
  801108:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110f:	f6 c2 01             	test   $0x1,%dl
  801112:	74 24                	je     801138 <fd_lookup+0x48>
  801114:	89 c2                	mov    %eax,%edx
  801116:	c1 ea 0c             	shr    $0xc,%edx
  801119:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	74 1a                	je     80113f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801125:	8b 55 0c             	mov    0xc(%ebp),%edx
  801128:	89 02                	mov    %eax,(%edx)
	return 0;
  80112a:	b8 00 00 00 00       	mov    $0x0,%eax
  80112f:	eb 13                	jmp    801144 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801131:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801136:	eb 0c                	jmp    801144 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801138:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113d:	eb 05                	jmp    801144 <fd_lookup+0x54>
  80113f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114f:	ba 20 2c 80 00       	mov    $0x802c20,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801154:	eb 13                	jmp    801169 <dev_lookup+0x23>
  801156:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801159:	39 08                	cmp    %ecx,(%eax)
  80115b:	75 0c                	jne    801169 <dev_lookup+0x23>
			*dev = devtab[i];
  80115d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801160:	89 01                	mov    %eax,(%ecx)
			return 0;
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
  801167:	eb 2e                	jmp    801197 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801169:	8b 02                	mov    (%edx),%eax
  80116b:	85 c0                	test   %eax,%eax
  80116d:	75 e7                	jne    801156 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116f:	a1 08 40 80 00       	mov    0x804008,%eax
  801174:	8b 40 48             	mov    0x48(%eax),%eax
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	51                   	push   %ecx
  80117b:	50                   	push   %eax
  80117c:	68 a4 2b 80 00       	push   $0x802ba4
  801181:	e8 2c f0 ff ff       	call   8001b2 <cprintf>
	*dev = 0;
  801186:	8b 45 0c             	mov    0xc(%ebp),%eax
  801189:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801197:	c9                   	leave  
  801198:	c3                   	ret    

00801199 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	56                   	push   %esi
  80119d:	53                   	push   %ebx
  80119e:	83 ec 10             	sub    $0x10,%esp
  8011a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011b1:	c1 e8 0c             	shr    $0xc,%eax
  8011b4:	50                   	push   %eax
  8011b5:	e8 36 ff ff ff       	call   8010f0 <fd_lookup>
  8011ba:	83 c4 08             	add    $0x8,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 05                	js     8011c6 <fd_close+0x2d>
	    || fd != fd2)
  8011c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c4:	74 0c                	je     8011d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011c6:	84 db                	test   %bl,%bl
  8011c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cd:	0f 44 c2             	cmove  %edx,%eax
  8011d0:	eb 41                	jmp    801213 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	ff 36                	pushl  (%esi)
  8011db:	e8 66 ff ff ff       	call   801146 <dev_lookup>
  8011e0:	89 c3                	mov    %eax,%ebx
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 1a                	js     801203 <fd_close+0x6a>
		if (dev->dev_close)
  8011e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	74 0b                	je     801203 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f8:	83 ec 0c             	sub    $0xc,%esp
  8011fb:	56                   	push   %esi
  8011fc:	ff d0                	call   *%eax
  8011fe:	89 c3                	mov    %eax,%ebx
  801200:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	56                   	push   %esi
  801207:	6a 00                	push   $0x0
  801209:	e8 b1 f9 ff ff       	call   800bbf <sys_page_unmap>
	return r;
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	89 d8                	mov    %ebx,%eax
}
  801213:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801220:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	ff 75 08             	pushl  0x8(%ebp)
  801227:	e8 c4 fe ff ff       	call   8010f0 <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 10                	js     801243 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801233:	83 ec 08             	sub    $0x8,%esp
  801236:	6a 01                	push   $0x1
  801238:	ff 75 f4             	pushl  -0xc(%ebp)
  80123b:	e8 59 ff ff ff       	call   801199 <fd_close>
  801240:	83 c4 10             	add    $0x10,%esp
}
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <close_all>:

void
close_all(void)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	53                   	push   %ebx
  801249:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80124c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	53                   	push   %ebx
  801255:	e8 c0 ff ff ff       	call   80121a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80125a:	83 c3 01             	add    $0x1,%ebx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	83 fb 20             	cmp    $0x20,%ebx
  801263:	75 ec                	jne    801251 <close_all+0xc>
		close(i);
}
  801265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	57                   	push   %edi
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
  801270:	83 ec 2c             	sub    $0x2c,%esp
  801273:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801276:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 6e fe ff ff       	call   8010f0 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	0f 88 c1 00 00 00    	js     80134e <dup+0xe4>
		return r;
	close(newfdnum);
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	56                   	push   %esi
  801291:	e8 84 ff ff ff       	call   80121a <close>

	newfd = INDEX2FD(newfdnum);
  801296:	89 f3                	mov    %esi,%ebx
  801298:	c1 e3 0c             	shl    $0xc,%ebx
  80129b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012a1:	83 c4 04             	add    $0x4,%esp
  8012a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a7:	e8 de fd ff ff       	call   80108a <fd2data>
  8012ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ae:	89 1c 24             	mov    %ebx,(%esp)
  8012b1:	e8 d4 fd ff ff       	call   80108a <fd2data>
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012bc:	89 f8                	mov    %edi,%eax
  8012be:	c1 e8 16             	shr    $0x16,%eax
  8012c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c8:	a8 01                	test   $0x1,%al
  8012ca:	74 37                	je     801303 <dup+0x99>
  8012cc:	89 f8                	mov    %edi,%eax
  8012ce:	c1 e8 0c             	shr    $0xc,%eax
  8012d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d8:	f6 c2 01             	test   $0x1,%dl
  8012db:	74 26                	je     801303 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ec:	50                   	push   %eax
  8012ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f0:	6a 00                	push   $0x0
  8012f2:	57                   	push   %edi
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 83 f8 ff ff       	call   800b7d <sys_page_map>
  8012fa:	89 c7                	mov    %eax,%edi
  8012fc:	83 c4 20             	add    $0x20,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 2e                	js     801331 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801303:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801306:	89 d0                	mov    %edx,%eax
  801308:	c1 e8 0c             	shr    $0xc,%eax
  80130b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	25 07 0e 00 00       	and    $0xe07,%eax
  80131a:	50                   	push   %eax
  80131b:	53                   	push   %ebx
  80131c:	6a 00                	push   $0x0
  80131e:	52                   	push   %edx
  80131f:	6a 00                	push   $0x0
  801321:	e8 57 f8 ff ff       	call   800b7d <sys_page_map>
  801326:	89 c7                	mov    %eax,%edi
  801328:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80132b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132d:	85 ff                	test   %edi,%edi
  80132f:	79 1d                	jns    80134e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	6a 00                	push   $0x0
  801337:	e8 83 f8 ff ff       	call   800bbf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133c:	83 c4 08             	add    $0x8,%esp
  80133f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801342:	6a 00                	push   $0x0
  801344:	e8 76 f8 ff ff       	call   800bbf <sys_page_unmap>
	return r;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	89 f8                	mov    %edi,%eax
}
  80134e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 14             	sub    $0x14,%esp
  80135d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	53                   	push   %ebx
  801365:	e8 86 fd ff ff       	call   8010f0 <fd_lookup>
  80136a:	83 c4 08             	add    $0x8,%esp
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 6d                	js     8013e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	ff 30                	pushl  (%eax)
  80137f:	e8 c2 fd ff ff       	call   801146 <dev_lookup>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 4c                	js     8013d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80138b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138e:	8b 42 08             	mov    0x8(%edx),%eax
  801391:	83 e0 03             	and    $0x3,%eax
  801394:	83 f8 01             	cmp    $0x1,%eax
  801397:	75 21                	jne    8013ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801399:	a1 08 40 80 00       	mov    0x804008,%eax
  80139e:	8b 40 48             	mov    0x48(%eax),%eax
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	50                   	push   %eax
  8013a6:	68 e5 2b 80 00       	push   $0x802be5
  8013ab:	e8 02 ee ff ff       	call   8001b2 <cprintf>
		return -E_INVAL;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b8:	eb 26                	jmp    8013e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bd:	8b 40 08             	mov    0x8(%eax),%eax
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 17                	je     8013db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	ff 75 10             	pushl  0x10(%ebp)
  8013ca:	ff 75 0c             	pushl  0xc(%ebp)
  8013cd:	52                   	push   %edx
  8013ce:	ff d0                	call   *%eax
  8013d0:	89 c2                	mov    %eax,%edx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	eb 09                	jmp    8013e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d7:	89 c2                	mov    %eax,%edx
  8013d9:	eb 05                	jmp    8013e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013e0:	89 d0                	mov    %edx,%eax
  8013e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	57                   	push   %edi
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fb:	eb 21                	jmp    80141e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	89 f0                	mov    %esi,%eax
  801402:	29 d8                	sub    %ebx,%eax
  801404:	50                   	push   %eax
  801405:	89 d8                	mov    %ebx,%eax
  801407:	03 45 0c             	add    0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	57                   	push   %edi
  80140c:	e8 45 ff ff ff       	call   801356 <read>
		if (m < 0)
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 10                	js     801428 <readn+0x41>
			return m;
		if (m == 0)
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 0a                	je     801426 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141c:	01 c3                	add    %eax,%ebx
  80141e:	39 f3                	cmp    %esi,%ebx
  801420:	72 db                	jb     8013fd <readn+0x16>
  801422:	89 d8                	mov    %ebx,%eax
  801424:	eb 02                	jmp    801428 <readn+0x41>
  801426:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	53                   	push   %ebx
  801434:	83 ec 14             	sub    $0x14,%esp
  801437:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	53                   	push   %ebx
  80143f:	e8 ac fc ff ff       	call   8010f0 <fd_lookup>
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	89 c2                	mov    %eax,%edx
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 68                	js     8014b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801457:	ff 30                	pushl  (%eax)
  801459:	e8 e8 fc ff ff       	call   801146 <dev_lookup>
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	85 c0                	test   %eax,%eax
  801463:	78 47                	js     8014ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801465:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801468:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80146c:	75 21                	jne    80148f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80146e:	a1 08 40 80 00       	mov    0x804008,%eax
  801473:	8b 40 48             	mov    0x48(%eax),%eax
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	53                   	push   %ebx
  80147a:	50                   	push   %eax
  80147b:	68 01 2c 80 00       	push   $0x802c01
  801480:	e8 2d ed ff ff       	call   8001b2 <cprintf>
		return -E_INVAL;
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148d:	eb 26                	jmp    8014b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801492:	8b 52 0c             	mov    0xc(%edx),%edx
  801495:	85 d2                	test   %edx,%edx
  801497:	74 17                	je     8014b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	ff 75 10             	pushl  0x10(%ebp)
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	50                   	push   %eax
  8014a3:	ff d2                	call   *%edx
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb 09                	jmp    8014b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	eb 05                	jmp    8014b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	pushl  0x8(%ebp)
  8014c9:	e8 22 fc ff ff       	call   8010f0 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 0e                	js     8014e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 14             	sub    $0x14,%esp
  8014ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	53                   	push   %ebx
  8014f4:	e8 f7 fb ff ff       	call   8010f0 <fd_lookup>
  8014f9:	83 c4 08             	add    $0x8,%esp
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 65                	js     801567 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150c:	ff 30                	pushl  (%eax)
  80150e:	e8 33 fc ff ff       	call   801146 <dev_lookup>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 44                	js     80155e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801521:	75 21                	jne    801544 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801523:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801528:	8b 40 48             	mov    0x48(%eax),%eax
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	53                   	push   %ebx
  80152f:	50                   	push   %eax
  801530:	68 c4 2b 80 00       	push   $0x802bc4
  801535:	e8 78 ec ff ff       	call   8001b2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801542:	eb 23                	jmp    801567 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801544:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801547:	8b 52 18             	mov    0x18(%edx),%edx
  80154a:	85 d2                	test   %edx,%edx
  80154c:	74 14                	je     801562 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	ff 75 0c             	pushl  0xc(%ebp)
  801554:	50                   	push   %eax
  801555:	ff d2                	call   *%edx
  801557:	89 c2                	mov    %eax,%edx
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	eb 09                	jmp    801567 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155e:	89 c2                	mov    %eax,%edx
  801560:	eb 05                	jmp    801567 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801562:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801567:	89 d0                	mov    %edx,%eax
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	53                   	push   %ebx
  801572:	83 ec 14             	sub    $0x14,%esp
  801575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801578:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157b:	50                   	push   %eax
  80157c:	ff 75 08             	pushl  0x8(%ebp)
  80157f:	e8 6c fb ff ff       	call   8010f0 <fd_lookup>
  801584:	83 c4 08             	add    $0x8,%esp
  801587:	89 c2                	mov    %eax,%edx
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 58                	js     8015e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801597:	ff 30                	pushl  (%eax)
  801599:	e8 a8 fb ff ff       	call   801146 <dev_lookup>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 37                	js     8015dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ac:	74 32                	je     8015e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b8:	00 00 00 
	stat->st_isdir = 0;
  8015bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c2:	00 00 00 
	stat->st_dev = dev;
  8015c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	53                   	push   %ebx
  8015cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d2:	ff 50 14             	call   *0x14(%eax)
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 09                	jmp    8015e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	eb 05                	jmp    8015e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	6a 00                	push   $0x0
  8015f6:	ff 75 08             	pushl  0x8(%ebp)
  8015f9:	e8 e7 01 00 00       	call   8017e5 <open>
  8015fe:	89 c3                	mov    %eax,%ebx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 1b                	js     801622 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	ff 75 0c             	pushl  0xc(%ebp)
  80160d:	50                   	push   %eax
  80160e:	e8 5b ff ff ff       	call   80156e <fstat>
  801613:	89 c6                	mov    %eax,%esi
	close(fd);
  801615:	89 1c 24             	mov    %ebx,(%esp)
  801618:	e8 fd fb ff ff       	call   80121a <close>
	return r;
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	89 f0                	mov    %esi,%eax
}
  801622:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	89 c6                	mov    %eax,%esi
  801630:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801632:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801639:	75 12                	jne    80164d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	6a 01                	push   $0x1
  801640:	e8 24 0d 00 00       	call   802369 <ipc_find_env>
  801645:	a3 00 40 80 00       	mov    %eax,0x804000
  80164a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164d:	6a 07                	push   $0x7
  80164f:	68 00 50 80 00       	push   $0x805000
  801654:	56                   	push   %esi
  801655:	ff 35 00 40 80 00    	pushl  0x804000
  80165b:	e8 b5 0c 00 00       	call   802315 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801660:	83 c4 0c             	add    $0xc,%esp
  801663:	6a 00                	push   $0x0
  801665:	53                   	push   %ebx
  801666:	6a 00                	push   $0x0
  801668:	e8 3b 0c 00 00       	call   8022a8 <ipc_recv>
}
  80166d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	8b 40 0c             	mov    0xc(%eax),%eax
  801680:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801685:	8b 45 0c             	mov    0xc(%ebp),%eax
  801688:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168d:	ba 00 00 00 00       	mov    $0x0,%edx
  801692:	b8 02 00 00 00       	mov    $0x2,%eax
  801697:	e8 8d ff ff ff       	call   801629 <fsipc>
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b9:	e8 6b ff ff ff       	call   801629 <fsipc>
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 04             	sub    $0x4,%esp
  8016c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016da:	b8 05 00 00 00       	mov    $0x5,%eax
  8016df:	e8 45 ff ff ff       	call   801629 <fsipc>
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 2c                	js     801714 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	68 00 50 80 00       	push   $0x805000
  8016f0:	53                   	push   %ebx
  8016f1:	e8 41 f0 ff ff       	call   800737 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8016fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801701:	a1 84 50 80 00       	mov    0x805084,%eax
  801706:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	53                   	push   %ebx
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801723:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801728:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80172d:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801730:	53                   	push   %ebx
  801731:	ff 75 0c             	pushl  0xc(%ebp)
  801734:	68 08 50 80 00       	push   $0x805008
  801739:	e8 8b f1 ff ff       	call   8008c9 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801749:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	b8 04 00 00 00       	mov    $0x4,%eax
  801759:	e8 cb fe ff ff       	call   801629 <fsipc>
	//panic("devfile_write not implemented");
}
  80175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801776:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177c:	ba 00 00 00 00       	mov    $0x0,%edx
  801781:	b8 03 00 00 00       	mov    $0x3,%eax
  801786:	e8 9e fe ff ff       	call   801629 <fsipc>
  80178b:	89 c3                	mov    %eax,%ebx
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 4b                	js     8017dc <devfile_read+0x79>
		return r;
	assert(r <= n);
  801791:	39 c6                	cmp    %eax,%esi
  801793:	73 16                	jae    8017ab <devfile_read+0x48>
  801795:	68 34 2c 80 00       	push   $0x802c34
  80179a:	68 3b 2c 80 00       	push   $0x802c3b
  80179f:	6a 7c                	push   $0x7c
  8017a1:	68 50 2c 80 00       	push   $0x802c50
  8017a6:	e8 24 0a 00 00       	call   8021cf <_panic>
	assert(r <= PGSIZE);
  8017ab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b0:	7e 16                	jle    8017c8 <devfile_read+0x65>
  8017b2:	68 5b 2c 80 00       	push   $0x802c5b
  8017b7:	68 3b 2c 80 00       	push   $0x802c3b
  8017bc:	6a 7d                	push   $0x7d
  8017be:	68 50 2c 80 00       	push   $0x802c50
  8017c3:	e8 07 0a 00 00       	call   8021cf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	50                   	push   %eax
  8017cc:	68 00 50 80 00       	push   $0x805000
  8017d1:	ff 75 0c             	pushl  0xc(%ebp)
  8017d4:	e8 f0 f0 ff ff       	call   8008c9 <memmove>
	return r;
  8017d9:	83 c4 10             	add    $0x10,%esp
}
  8017dc:	89 d8                	mov    %ebx,%eax
  8017de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e1:	5b                   	pop    %ebx
  8017e2:	5e                   	pop    %esi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 20             	sub    $0x20,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ef:	53                   	push   %ebx
  8017f0:	e8 09 ef ff ff       	call   8006fe <strlen>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fd:	7f 67                	jg     801866 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	e8 96 f8 ff ff       	call   8010a1 <fd_alloc>
  80180b:	83 c4 10             	add    $0x10,%esp
		return r;
  80180e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801810:	85 c0                	test   %eax,%eax
  801812:	78 57                	js     80186b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	53                   	push   %ebx
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	e8 15 ef ff ff       	call   800737 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	e8 f2 fd ff ff       	call   801629 <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	79 14                	jns    801854 <open+0x6f>
		fd_close(fd, 0);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	6a 00                	push   $0x0
  801845:	ff 75 f4             	pushl  -0xc(%ebp)
  801848:	e8 4c f9 ff ff       	call   801199 <fd_close>
		return r;
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	89 da                	mov    %ebx,%edx
  801852:	eb 17                	jmp    80186b <open+0x86>
	}

	return fd2num(fd);
  801854:	83 ec 0c             	sub    $0xc,%esp
  801857:	ff 75 f4             	pushl  -0xc(%ebp)
  80185a:	e8 1b f8 ff ff       	call   80107a <fd2num>
  80185f:	89 c2                	mov    %eax,%edx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	eb 05                	jmp    80186b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801866:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 08 00 00 00       	mov    $0x8,%eax
  801882:	e8 a2 fd ff ff       	call   801629 <fsipc>
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80188f:	68 67 2c 80 00       	push   $0x802c67
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	e8 9b ee ff ff       	call   800737 <strcpy>
	return 0;
}
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 10             	sub    $0x10,%esp
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018ad:	53                   	push   %ebx
  8018ae:	e8 ef 0a 00 00       	call   8023a2 <pageref>
  8018b3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018bb:	83 f8 01             	cmp    $0x1,%eax
  8018be:	75 10                	jne    8018d0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	ff 73 0c             	pushl  0xc(%ebx)
  8018c6:	e8 c0 02 00 00       	call   801b8b <nsipc_close>
  8018cb:	89 c2                	mov    %eax,%edx
  8018cd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018d0:	89 d0                	mov    %edx,%eax
  8018d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018dd:	6a 00                	push   $0x0
  8018df:	ff 75 10             	pushl  0x10(%ebp)
  8018e2:	ff 75 0c             	pushl  0xc(%ebp)
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	ff 70 0c             	pushl  0xc(%eax)
  8018eb:	e8 78 03 00 00       	call   801c68 <nsipc_send>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018f8:	6a 00                	push   $0x0
  8018fa:	ff 75 10             	pushl  0x10(%ebp)
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	ff 70 0c             	pushl  0xc(%eax)
  801906:	e8 f1 02 00 00       	call   801bfc <nsipc_recv>
}
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801913:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801916:	52                   	push   %edx
  801917:	50                   	push   %eax
  801918:	e8 d3 f7 ff ff       	call   8010f0 <fd_lookup>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 17                	js     80193b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801927:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80192d:	39 08                	cmp    %ecx,(%eax)
  80192f:	75 05                	jne    801936 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	eb 05                	jmp    80193b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801936:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	83 ec 1c             	sub    $0x1c,%esp
  801945:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	e8 51 f7 ff ff       	call   8010a1 <fd_alloc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	78 1b                	js     801974 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801959:	83 ec 04             	sub    $0x4,%esp
  80195c:	68 07 04 00 00       	push   $0x407
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	6a 00                	push   $0x0
  801966:	e8 cf f1 ff ff       	call   800b3a <sys_page_alloc>
  80196b:	89 c3                	mov    %eax,%ebx
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	79 10                	jns    801984 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	56                   	push   %esi
  801978:	e8 0e 02 00 00       	call   801b8b <nsipc_close>
		return r;
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	89 d8                	mov    %ebx,%eax
  801982:	eb 24                	jmp    8019a8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801984:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801999:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	50                   	push   %eax
  8019a0:	e8 d5 f6 ff ff       	call   80107a <fd2num>
  8019a5:	83 c4 10             	add    $0x10,%esp
}
  8019a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	e8 50 ff ff ff       	call   80190d <fd2sockid>
		return r;
  8019bd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 1f                	js     8019e2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019c3:	83 ec 04             	sub    $0x4,%esp
  8019c6:	ff 75 10             	pushl  0x10(%ebp)
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	50                   	push   %eax
  8019cd:	e8 12 01 00 00       	call   801ae4 <nsipc_accept>
  8019d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 07                	js     8019e2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019db:	e8 5d ff ff ff       	call   80193d <alloc_sockfd>
  8019e0:	89 c1                	mov    %eax,%ecx
}
  8019e2:	89 c8                	mov    %ecx,%eax
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	e8 19 ff ff ff       	call   80190d <fd2sockid>
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 12                	js     801a0a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	ff 75 10             	pushl  0x10(%ebp)
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	50                   	push   %eax
  801a02:	e8 2d 01 00 00       	call   801b34 <nsipc_bind>
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <shutdown>:

int
shutdown(int s, int how)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	e8 f3 fe ff ff       	call   80190d <fd2sockid>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 0f                	js     801a2d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	50                   	push   %eax
  801a25:	e8 3f 01 00 00       	call   801b69 <nsipc_shutdown>
  801a2a:	83 c4 10             	add    $0x10,%esp
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	e8 d0 fe ff ff       	call   80190d <fd2sockid>
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 12                	js     801a53 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a41:	83 ec 04             	sub    $0x4,%esp
  801a44:	ff 75 10             	pushl  0x10(%ebp)
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 55 01 00 00       	call   801ba5 <nsipc_connect>
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <listen>:

int
listen(int s, int backlog)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	e8 aa fe ff ff       	call   80190d <fd2sockid>
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 0f                	js     801a76 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	ff 75 0c             	pushl  0xc(%ebp)
  801a6d:	50                   	push   %eax
  801a6e:	e8 67 01 00 00       	call   801bda <nsipc_listen>
  801a73:	83 c4 10             	add    $0x10,%esp
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a7e:	ff 75 10             	pushl  0x10(%ebp)
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	ff 75 08             	pushl  0x8(%ebp)
  801a87:	e8 3a 02 00 00       	call   801cc6 <nsipc_socket>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 05                	js     801a98 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a93:	e8 a5 fe ff ff       	call   80193d <alloc_sockfd>
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 04             	sub    $0x4,%esp
  801aa1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801aa3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801aaa:	75 12                	jne    801abe <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	6a 02                	push   $0x2
  801ab1:	e8 b3 08 00 00       	call   802369 <ipc_find_env>
  801ab6:	a3 04 40 80 00       	mov    %eax,0x804004
  801abb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801abe:	6a 07                	push   $0x7
  801ac0:	68 00 60 80 00       	push   $0x806000
  801ac5:	53                   	push   %ebx
  801ac6:	ff 35 04 40 80 00    	pushl  0x804004
  801acc:	e8 44 08 00 00       	call   802315 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ad1:	83 c4 0c             	add    $0xc,%esp
  801ad4:	6a 00                	push   $0x0
  801ad6:	6a 00                	push   $0x0
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 c9 07 00 00       	call   8022a8 <ipc_recv>
}
  801adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801af4:	8b 06                	mov    (%esi),%eax
  801af6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801afb:	b8 01 00 00 00       	mov    $0x1,%eax
  801b00:	e8 95 ff ff ff       	call   801a9a <nsipc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 20                	js     801b2b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	ff 35 10 60 80 00    	pushl  0x806010
  801b14:	68 00 60 80 00       	push   $0x806000
  801b19:	ff 75 0c             	pushl  0xc(%ebp)
  801b1c:	e8 a8 ed ff ff       	call   8008c9 <memmove>
		*addrlen = ret->ret_addrlen;
  801b21:	a1 10 60 80 00       	mov    0x806010,%eax
  801b26:	89 06                	mov    %eax,(%esi)
  801b28:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b2b:	89 d8                	mov    %ebx,%eax
  801b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	53                   	push   %ebx
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b46:	53                   	push   %ebx
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	68 04 60 80 00       	push   $0x806004
  801b4f:	e8 75 ed ff ff       	call   8008c9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b54:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b5a:	b8 02 00 00 00       	mov    $0x2,%eax
  801b5f:	e8 36 ff ff ff       	call   801a9a <nsipc>
}
  801b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b84:	e8 11 ff ff ff       	call   801a9a <nsipc>
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <nsipc_close>:

int
nsipc_close(int s)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b99:	b8 04 00 00 00       	mov    $0x4,%eax
  801b9e:	e8 f7 fe ff ff       	call   801a9a <nsipc>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 08             	sub    $0x8,%esp
  801bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801baf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bb7:	53                   	push   %ebx
  801bb8:	ff 75 0c             	pushl  0xc(%ebp)
  801bbb:	68 04 60 80 00       	push   $0x806004
  801bc0:	e8 04 ed ff ff       	call   8008c9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bc5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bcb:	b8 05 00 00 00       	mov    $0x5,%eax
  801bd0:	e8 c5 fe ff ff       	call   801a9a <nsipc>
}
  801bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801beb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bf0:	b8 06 00 00 00       	mov    $0x6,%eax
  801bf5:	e8 a0 fe ff ff       	call   801a9a <nsipc>
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c0c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c12:	8b 45 14             	mov    0x14(%ebp),%eax
  801c15:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c1a:	b8 07 00 00 00       	mov    $0x7,%eax
  801c1f:	e8 76 fe ff ff       	call   801a9a <nsipc>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 35                	js     801c5f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c2a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c2f:	7f 04                	jg     801c35 <nsipc_recv+0x39>
  801c31:	39 c6                	cmp    %eax,%esi
  801c33:	7d 16                	jge    801c4b <nsipc_recv+0x4f>
  801c35:	68 73 2c 80 00       	push   $0x802c73
  801c3a:	68 3b 2c 80 00       	push   $0x802c3b
  801c3f:	6a 62                	push   $0x62
  801c41:	68 88 2c 80 00       	push   $0x802c88
  801c46:	e8 84 05 00 00       	call   8021cf <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c4b:	83 ec 04             	sub    $0x4,%esp
  801c4e:	50                   	push   %eax
  801c4f:	68 00 60 80 00       	push   $0x806000
  801c54:	ff 75 0c             	pushl  0xc(%ebp)
  801c57:	e8 6d ec ff ff       	call   8008c9 <memmove>
  801c5c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 04             	sub    $0x4,%esp
  801c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c7a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c80:	7e 16                	jle    801c98 <nsipc_send+0x30>
  801c82:	68 94 2c 80 00       	push   $0x802c94
  801c87:	68 3b 2c 80 00       	push   $0x802c3b
  801c8c:	6a 6d                	push   $0x6d
  801c8e:	68 88 2c 80 00       	push   $0x802c88
  801c93:	e8 37 05 00 00       	call   8021cf <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	53                   	push   %ebx
  801c9c:	ff 75 0c             	pushl  0xc(%ebp)
  801c9f:	68 0c 60 80 00       	push   $0x80600c
  801ca4:	e8 20 ec ff ff       	call   8008c9 <memmove>
	nsipcbuf.send.req_size = size;
  801ca9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801caf:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cb7:	b8 08 00 00 00       	mov    $0x8,%eax
  801cbc:	e8 d9 fd ff ff       	call   801a9a <nsipc>
}
  801cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801cdf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ce4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ce9:	e8 ac fd ff ff       	call   801a9a <nsipc>
}
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 87 f3 ff ff       	call   80108a <fd2data>
  801d03:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d05:	83 c4 08             	add    $0x8,%esp
  801d08:	68 a0 2c 80 00       	push   $0x802ca0
  801d0d:	53                   	push   %ebx
  801d0e:	e8 24 ea ff ff       	call   800737 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d13:	8b 46 04             	mov    0x4(%esi),%eax
  801d16:	2b 06                	sub    (%esi),%eax
  801d18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d25:	00 00 00 
	stat->st_dev = &devpipe;
  801d28:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d2f:	30 80 00 
	return 0;
}
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
  801d37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3a:	5b                   	pop    %ebx
  801d3b:	5e                   	pop    %esi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	53                   	push   %ebx
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d48:	53                   	push   %ebx
  801d49:	6a 00                	push   $0x0
  801d4b:	e8 6f ee ff ff       	call   800bbf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d50:	89 1c 24             	mov    %ebx,(%esp)
  801d53:	e8 32 f3 ff ff       	call   80108a <fd2data>
  801d58:	83 c4 08             	add    $0x8,%esp
  801d5b:	50                   	push   %eax
  801d5c:	6a 00                	push   $0x0
  801d5e:	e8 5c ee ff ff       	call   800bbf <sys_page_unmap>
}
  801d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 1c             	sub    $0x1c,%esp
  801d71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d74:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d76:	a1 08 40 80 00       	mov    0x804008,%eax
  801d7b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 e0             	pushl  -0x20(%ebp)
  801d84:	e8 19 06 00 00       	call   8023a2 <pageref>
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	89 3c 24             	mov    %edi,(%esp)
  801d8e:	e8 0f 06 00 00       	call   8023a2 <pageref>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	39 c3                	cmp    %eax,%ebx
  801d98:	0f 94 c1             	sete   %cl
  801d9b:	0f b6 c9             	movzbl %cl,%ecx
  801d9e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801da1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801da7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801daa:	39 ce                	cmp    %ecx,%esi
  801dac:	74 1b                	je     801dc9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dae:	39 c3                	cmp    %eax,%ebx
  801db0:	75 c4                	jne    801d76 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801db2:	8b 42 58             	mov    0x58(%edx),%eax
  801db5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801db8:	50                   	push   %eax
  801db9:	56                   	push   %esi
  801dba:	68 a7 2c 80 00       	push   $0x802ca7
  801dbf:	e8 ee e3 ff ff       	call   8001b2 <cprintf>
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	eb ad                	jmp    801d76 <_pipeisclosed+0xe>
	}
}
  801dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	57                   	push   %edi
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 28             	sub    $0x28,%esp
  801ddd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801de0:	56                   	push   %esi
  801de1:	e8 a4 f2 ff ff       	call   80108a <fd2data>
  801de6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	bf 00 00 00 00       	mov    $0x0,%edi
  801df0:	eb 4b                	jmp    801e3d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801df2:	89 da                	mov    %ebx,%edx
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	e8 6d ff ff ff       	call   801d68 <_pipeisclosed>
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	75 48                	jne    801e47 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dff:	e8 17 ed ff ff       	call   800b1b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e04:	8b 43 04             	mov    0x4(%ebx),%eax
  801e07:	8b 0b                	mov    (%ebx),%ecx
  801e09:	8d 51 20             	lea    0x20(%ecx),%edx
  801e0c:	39 d0                	cmp    %edx,%eax
  801e0e:	73 e2                	jae    801df2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e13:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e17:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	c1 fa 1f             	sar    $0x1f,%edx
  801e1f:	89 d1                	mov    %edx,%ecx
  801e21:	c1 e9 1b             	shr    $0x1b,%ecx
  801e24:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e27:	83 e2 1f             	and    $0x1f,%edx
  801e2a:	29 ca                	sub    %ecx,%edx
  801e2c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e30:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e34:	83 c0 01             	add    $0x1,%eax
  801e37:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3a:	83 c7 01             	add    $0x1,%edi
  801e3d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e40:	75 c2                	jne    801e04 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e42:	8b 45 10             	mov    0x10(%ebp),%eax
  801e45:	eb 05                	jmp    801e4c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 18             	sub    $0x18,%esp
  801e5d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e60:	57                   	push   %edi
  801e61:	e8 24 f2 ff ff       	call   80108a <fd2data>
  801e66:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e70:	eb 3d                	jmp    801eaf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e72:	85 db                	test   %ebx,%ebx
  801e74:	74 04                	je     801e7a <devpipe_read+0x26>
				return i;
  801e76:	89 d8                	mov    %ebx,%eax
  801e78:	eb 44                	jmp    801ebe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e7a:	89 f2                	mov    %esi,%edx
  801e7c:	89 f8                	mov    %edi,%eax
  801e7e:	e8 e5 fe ff ff       	call   801d68 <_pipeisclosed>
  801e83:	85 c0                	test   %eax,%eax
  801e85:	75 32                	jne    801eb9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e87:	e8 8f ec ff ff       	call   800b1b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e8c:	8b 06                	mov    (%esi),%eax
  801e8e:	3b 46 04             	cmp    0x4(%esi),%eax
  801e91:	74 df                	je     801e72 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e93:	99                   	cltd   
  801e94:	c1 ea 1b             	shr    $0x1b,%edx
  801e97:	01 d0                	add    %edx,%eax
  801e99:	83 e0 1f             	and    $0x1f,%eax
  801e9c:	29 d0                	sub    %edx,%eax
  801e9e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ea9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eac:	83 c3 01             	add    $0x1,%ebx
  801eaf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eb2:	75 d8                	jne    801e8c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb7:	eb 05                	jmp    801ebe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ece:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed1:	50                   	push   %eax
  801ed2:	e8 ca f1 ff ff       	call   8010a1 <fd_alloc>
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	89 c2                	mov    %eax,%edx
  801edc:	85 c0                	test   %eax,%eax
  801ede:	0f 88 2c 01 00 00    	js     802010 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee4:	83 ec 04             	sub    $0x4,%esp
  801ee7:	68 07 04 00 00       	push   $0x407
  801eec:	ff 75 f4             	pushl  -0xc(%ebp)
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 44 ec ff ff       	call   800b3a <sys_page_alloc>
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	89 c2                	mov    %eax,%edx
  801efb:	85 c0                	test   %eax,%eax
  801efd:	0f 88 0d 01 00 00    	js     802010 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f09:	50                   	push   %eax
  801f0a:	e8 92 f1 ff ff       	call   8010a1 <fd_alloc>
  801f0f:	89 c3                	mov    %eax,%ebx
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	85 c0                	test   %eax,%eax
  801f16:	0f 88 e2 00 00 00    	js     801ffe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1c:	83 ec 04             	sub    $0x4,%esp
  801f1f:	68 07 04 00 00       	push   $0x407
  801f24:	ff 75 f0             	pushl  -0x10(%ebp)
  801f27:	6a 00                	push   $0x0
  801f29:	e8 0c ec ff ff       	call   800b3a <sys_page_alloc>
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	0f 88 c3 00 00 00    	js     801ffe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f41:	e8 44 f1 ff ff       	call   80108a <fd2data>
  801f46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f48:	83 c4 0c             	add    $0xc,%esp
  801f4b:	68 07 04 00 00       	push   $0x407
  801f50:	50                   	push   %eax
  801f51:	6a 00                	push   $0x0
  801f53:	e8 e2 eb ff ff       	call   800b3a <sys_page_alloc>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	0f 88 89 00 00 00    	js     801fee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6b:	e8 1a f1 ff ff       	call   80108a <fd2data>
  801f70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f77:	50                   	push   %eax
  801f78:	6a 00                	push   $0x0
  801f7a:	56                   	push   %esi
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 fb eb ff ff       	call   800b7d <sys_page_map>
  801f82:	89 c3                	mov    %eax,%ebx
  801f84:	83 c4 20             	add    $0x20,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 55                	js     801fe0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fa0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbb:	e8 ba f0 ff ff       	call   80107a <fd2num>
  801fc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc5:	83 c4 04             	add    $0x4,%esp
  801fc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcb:	e8 aa f0 ff ff       	call   80107a <fd2num>
  801fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	ba 00 00 00 00       	mov    $0x0,%edx
  801fde:	eb 30                	jmp    802010 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fe0:	83 ec 08             	sub    $0x8,%esp
  801fe3:	56                   	push   %esi
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 d4 eb ff ff       	call   800bbf <sys_page_unmap>
  801feb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fee:	83 ec 08             	sub    $0x8,%esp
  801ff1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff4:	6a 00                	push   $0x0
  801ff6:	e8 c4 eb ff ff       	call   800bbf <sys_page_unmap>
  801ffb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	ff 75 f4             	pushl  -0xc(%ebp)
  802004:	6a 00                	push   $0x0
  802006:	e8 b4 eb ff ff       	call   800bbf <sys_page_unmap>
  80200b:	83 c4 10             	add    $0x10,%esp
  80200e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802010:	89 d0                	mov    %edx,%eax
  802012:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802022:	50                   	push   %eax
  802023:	ff 75 08             	pushl  0x8(%ebp)
  802026:	e8 c5 f0 ff ff       	call   8010f0 <fd_lookup>
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 18                	js     80204a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802032:	83 ec 0c             	sub    $0xc,%esp
  802035:	ff 75 f4             	pushl  -0xc(%ebp)
  802038:	e8 4d f0 ff ff       	call   80108a <fd2data>
	return _pipeisclosed(fd, p);
  80203d:	89 c2                	mov    %eax,%edx
  80203f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802042:	e8 21 fd ff ff       	call   801d68 <_pipeisclosed>
  802047:	83 c4 10             	add    $0x10,%esp
}
  80204a:	c9                   	leave  
  80204b:	c3                   	ret    

0080204c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    

00802056 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80205c:	68 bf 2c 80 00       	push   $0x802cbf
  802061:	ff 75 0c             	pushl  0xc(%ebp)
  802064:	e8 ce e6 ff ff       	call   800737 <strcpy>
	return 0;
}
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	57                   	push   %edi
  802074:	56                   	push   %esi
  802075:	53                   	push   %ebx
  802076:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802081:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802087:	eb 2d                	jmp    8020b6 <devcons_write+0x46>
		m = n - tot;
  802089:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80208c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80208e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802091:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802096:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802099:	83 ec 04             	sub    $0x4,%esp
  80209c:	53                   	push   %ebx
  80209d:	03 45 0c             	add    0xc(%ebp),%eax
  8020a0:	50                   	push   %eax
  8020a1:	57                   	push   %edi
  8020a2:	e8 22 e8 ff ff       	call   8008c9 <memmove>
		sys_cputs(buf, m);
  8020a7:	83 c4 08             	add    $0x8,%esp
  8020aa:	53                   	push   %ebx
  8020ab:	57                   	push   %edi
  8020ac:	e8 cd e9 ff ff       	call   800a7e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b1:	01 de                	add    %ebx,%esi
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	89 f0                	mov    %esi,%eax
  8020b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020bb:	72 cc                	jb     802089 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 08             	sub    $0x8,%esp
  8020cb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020d4:	74 2a                	je     802100 <devcons_read+0x3b>
  8020d6:	eb 05                	jmp    8020dd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020d8:	e8 3e ea ff ff       	call   800b1b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020dd:	e8 ba e9 ff ff       	call   800a9c <sys_cgetc>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	74 f2                	je     8020d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	78 16                	js     802100 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ea:	83 f8 04             	cmp    $0x4,%eax
  8020ed:	74 0c                	je     8020fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f2:	88 02                	mov    %al,(%edx)
	return 1;
  8020f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f9:	eb 05                	jmp    802100 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802100:	c9                   	leave  
  802101:	c3                   	ret    

00802102 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80210e:	6a 01                	push   $0x1
  802110:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802113:	50                   	push   %eax
  802114:	e8 65 e9 ff ff       	call   800a7e <sys_cputs>
}
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <getchar>:

int
getchar(void)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802124:	6a 01                	push   $0x1
  802126:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	6a 00                	push   $0x0
  80212c:	e8 25 f2 ff ff       	call   801356 <read>
	if (r < 0)
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	85 c0                	test   %eax,%eax
  802136:	78 0f                	js     802147 <getchar+0x29>
		return r;
	if (r < 1)
  802138:	85 c0                	test   %eax,%eax
  80213a:	7e 06                	jle    802142 <getchar+0x24>
		return -E_EOF;
	return c;
  80213c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802140:	eb 05                	jmp    802147 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802142:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802147:	c9                   	leave  
  802148:	c3                   	ret    

00802149 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	50                   	push   %eax
  802153:	ff 75 08             	pushl  0x8(%ebp)
  802156:	e8 95 ef ff ff       	call   8010f0 <fd_lookup>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 11                	js     802173 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802165:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80216b:	39 10                	cmp    %edx,(%eax)
  80216d:	0f 94 c0             	sete   %al
  802170:	0f b6 c0             	movzbl %al,%eax
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <opencons>:

int
opencons(void)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217e:	50                   	push   %eax
  80217f:	e8 1d ef ff ff       	call   8010a1 <fd_alloc>
  802184:	83 c4 10             	add    $0x10,%esp
		return r;
  802187:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 3e                	js     8021cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80218d:	83 ec 04             	sub    $0x4,%esp
  802190:	68 07 04 00 00       	push   $0x407
  802195:	ff 75 f4             	pushl  -0xc(%ebp)
  802198:	6a 00                	push   $0x0
  80219a:	e8 9b e9 ff ff       	call   800b3a <sys_page_alloc>
  80219f:	83 c4 10             	add    $0x10,%esp
		return r;
  8021a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 23                	js     8021cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021a8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021bd:	83 ec 0c             	sub    $0xc,%esp
  8021c0:	50                   	push   %eax
  8021c1:	e8 b4 ee ff ff       	call   80107a <fd2num>
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	83 c4 10             	add    $0x10,%esp
}
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021d7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021dd:	e8 1a e9 ff ff       	call   800afc <sys_getenvid>
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	ff 75 0c             	pushl  0xc(%ebp)
  8021e8:	ff 75 08             	pushl  0x8(%ebp)
  8021eb:	56                   	push   %esi
  8021ec:	50                   	push   %eax
  8021ed:	68 cc 2c 80 00       	push   $0x802ccc
  8021f2:	e8 bb df ff ff       	call   8001b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021f7:	83 c4 18             	add    $0x18,%esp
  8021fa:	53                   	push   %ebx
  8021fb:	ff 75 10             	pushl  0x10(%ebp)
  8021fe:	e8 5e df ff ff       	call   800161 <vcprintf>
	cprintf("\n");
  802203:	c7 04 24 7a 2a 80 00 	movl   $0x802a7a,(%esp)
  80220a:	e8 a3 df ff ff       	call   8001b2 <cprintf>
  80220f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802212:	cc                   	int3   
  802213:	eb fd                	jmp    802212 <_panic+0x43>

00802215 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80221b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802222:	75 2c                	jne    802250 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802224:	83 ec 04             	sub    $0x4,%esp
  802227:	6a 07                	push   $0x7
  802229:	68 00 f0 bf ee       	push   $0xeebff000
  80222e:	6a 00                	push   $0x0
  802230:	e8 05 e9 ff ff       	call   800b3a <sys_page_alloc>
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	85 c0                	test   %eax,%eax
  80223a:	79 14                	jns    802250 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80223c:	83 ec 04             	sub    $0x4,%esp
  80223f:	68 ef 2c 80 00       	push   $0x802cef
  802244:	6a 22                	push   $0x22
  802246:	68 06 2d 80 00       	push   $0x802d06
  80224b:	e8 7f ff ff ff       	call   8021cf <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802250:	8b 45 08             	mov    0x8(%ebp),%eax
  802253:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802258:	83 ec 08             	sub    $0x8,%esp
  80225b:	68 84 22 80 00       	push   $0x802284
  802260:	6a 00                	push   $0x0
  802262:	e8 1e ea ff ff       	call   800c85 <sys_env_set_pgfault_upcall>
  802267:	83 c4 10             	add    $0x10,%esp
  80226a:	85 c0                	test   %eax,%eax
  80226c:	79 14                	jns    802282 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80226e:	83 ec 04             	sub    $0x4,%esp
  802271:	68 14 2d 80 00       	push   $0x802d14
  802276:	6a 27                	push   $0x27
  802278:	68 06 2d 80 00       	push   $0x802d06
  80227d:	e8 4d ff ff ff       	call   8021cf <_panic>
    
}
  802282:	c9                   	leave  
  802283:	c3                   	ret    

00802284 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802284:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802285:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80228a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80228c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  80228f:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  802293:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  802298:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80229c:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80229e:	83 c4 08             	add    $0x8,%esp
	popal
  8022a1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8022a2:	83 c4 04             	add    $0x4,%esp
	popfl
  8022a5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022a6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022a7:	c3                   	ret    

008022a8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	56                   	push   %esi
  8022ac:	53                   	push   %ebx
  8022ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8022b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8022b6:	85 c0                	test   %eax,%eax
  8022b8:	74 0e                	je     8022c8 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8022ba:	83 ec 0c             	sub    $0xc,%esp
  8022bd:	50                   	push   %eax
  8022be:	e8 27 ea ff ff       	call   800cea <sys_ipc_recv>
  8022c3:	83 c4 10             	add    $0x10,%esp
  8022c6:	eb 10                	jmp    8022d8 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8022c8:	83 ec 0c             	sub    $0xc,%esp
  8022cb:	68 00 00 00 f0       	push   $0xf0000000
  8022d0:	e8 15 ea ff ff       	call   800cea <sys_ipc_recv>
  8022d5:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	74 0e                	je     8022ea <ipc_recv+0x42>
    	*from_env_store = 0;
  8022dc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8022e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8022e8:	eb 24                	jmp    80230e <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8022ea:	85 f6                	test   %esi,%esi
  8022ec:	74 0a                	je     8022f8 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8022ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8022f3:	8b 40 74             	mov    0x74(%eax),%eax
  8022f6:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8022f8:	85 db                	test   %ebx,%ebx
  8022fa:	74 0a                	je     802306 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8022fc:	a1 08 40 80 00       	mov    0x804008,%eax
  802301:	8b 40 78             	mov    0x78(%eax),%eax
  802304:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802306:	a1 08 40 80 00       	mov    0x804008,%eax
  80230b:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80230e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    

00802315 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802315:	55                   	push   %ebp
  802316:	89 e5                	mov    %esp,%ebp
  802318:	57                   	push   %edi
  802319:	56                   	push   %esi
  80231a:	53                   	push   %ebx
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802321:	8b 75 0c             	mov    0xc(%ebp),%esi
  802324:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802327:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80232e:	0f 44 d8             	cmove  %eax,%ebx
  802331:	eb 1c                	jmp    80234f <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802333:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802336:	74 12                	je     80234a <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802338:	50                   	push   %eax
  802339:	68 38 2d 80 00       	push   $0x802d38
  80233e:	6a 4b                	push   $0x4b
  802340:	68 50 2d 80 00       	push   $0x802d50
  802345:	e8 85 fe ff ff       	call   8021cf <_panic>
        }	
        sys_yield();
  80234a:	e8 cc e7 ff ff       	call   800b1b <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80234f:	ff 75 14             	pushl  0x14(%ebp)
  802352:	53                   	push   %ebx
  802353:	56                   	push   %esi
  802354:	57                   	push   %edi
  802355:	e8 6d e9 ff ff       	call   800cc7 <sys_ipc_try_send>
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	85 c0                	test   %eax,%eax
  80235f:	75 d2                	jne    802333 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802361:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    

00802369 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80236f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802374:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802377:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80237d:	8b 52 50             	mov    0x50(%edx),%edx
  802380:	39 ca                	cmp    %ecx,%edx
  802382:	75 0d                	jne    802391 <ipc_find_env+0x28>
			return envs[i].env_id;
  802384:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802387:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80238c:	8b 40 48             	mov    0x48(%eax),%eax
  80238f:	eb 0f                	jmp    8023a0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802391:	83 c0 01             	add    $0x1,%eax
  802394:	3d 00 04 00 00       	cmp    $0x400,%eax
  802399:	75 d9                	jne    802374 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80239b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023a0:	5d                   	pop    %ebp
  8023a1:	c3                   	ret    

008023a2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a8:	89 d0                	mov    %edx,%eax
  8023aa:	c1 e8 16             	shr    $0x16,%eax
  8023ad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023b4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b9:	f6 c1 01             	test   $0x1,%cl
  8023bc:	74 1d                	je     8023db <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023be:	c1 ea 0c             	shr    $0xc,%edx
  8023c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023c8:	f6 c2 01             	test   $0x1,%dl
  8023cb:	74 0e                	je     8023db <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023cd:	c1 ea 0c             	shr    $0xc,%edx
  8023d0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023d7:	ef 
  8023d8:	0f b7 c0             	movzwl %ax,%eax
}
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	66 90                	xchg   %ax,%ax
  8023df:	90                   	nop

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	53                   	push   %ebx
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
  8023e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f7:	85 f6                	test   %esi,%esi
  8023f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fd:	89 ca                	mov    %ecx,%edx
  8023ff:	89 f8                	mov    %edi,%eax
  802401:	75 3d                	jne    802440 <__udivdi3+0x60>
  802403:	39 cf                	cmp    %ecx,%edi
  802405:	0f 87 c5 00 00 00    	ja     8024d0 <__udivdi3+0xf0>
  80240b:	85 ff                	test   %edi,%edi
  80240d:	89 fd                	mov    %edi,%ebp
  80240f:	75 0b                	jne    80241c <__udivdi3+0x3c>
  802411:	b8 01 00 00 00       	mov    $0x1,%eax
  802416:	31 d2                	xor    %edx,%edx
  802418:	f7 f7                	div    %edi
  80241a:	89 c5                	mov    %eax,%ebp
  80241c:	89 c8                	mov    %ecx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  802420:	f7 f5                	div    %ebp
  802422:	89 c1                	mov    %eax,%ecx
  802424:	89 d8                	mov    %ebx,%eax
  802426:	89 cf                	mov    %ecx,%edi
  802428:	f7 f5                	div    %ebp
  80242a:	89 c3                	mov    %eax,%ebx
  80242c:	89 d8                	mov    %ebx,%eax
  80242e:	89 fa                	mov    %edi,%edx
  802430:	83 c4 1c             	add    $0x1c,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	39 ce                	cmp    %ecx,%esi
  802442:	77 74                	ja     8024b8 <__udivdi3+0xd8>
  802444:	0f bd fe             	bsr    %esi,%edi
  802447:	83 f7 1f             	xor    $0x1f,%edi
  80244a:	0f 84 98 00 00 00    	je     8024e8 <__udivdi3+0x108>
  802450:	bb 20 00 00 00       	mov    $0x20,%ebx
  802455:	89 f9                	mov    %edi,%ecx
  802457:	89 c5                	mov    %eax,%ebp
  802459:	29 fb                	sub    %edi,%ebx
  80245b:	d3 e6                	shl    %cl,%esi
  80245d:	89 d9                	mov    %ebx,%ecx
  80245f:	d3 ed                	shr    %cl,%ebp
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e0                	shl    %cl,%eax
  802465:	09 ee                	or     %ebp,%esi
  802467:	89 d9                	mov    %ebx,%ecx
  802469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246d:	89 d5                	mov    %edx,%ebp
  80246f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802473:	d3 ed                	shr    %cl,%ebp
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e2                	shl    %cl,%edx
  802479:	89 d9                	mov    %ebx,%ecx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	09 c2                	or     %eax,%edx
  80247f:	89 d0                	mov    %edx,%eax
  802481:	89 ea                	mov    %ebp,%edx
  802483:	f7 f6                	div    %esi
  802485:	89 d5                	mov    %edx,%ebp
  802487:	89 c3                	mov    %eax,%ebx
  802489:	f7 64 24 0c          	mull   0xc(%esp)
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	72 10                	jb     8024a1 <__udivdi3+0xc1>
  802491:	8b 74 24 08          	mov    0x8(%esp),%esi
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e6                	shl    %cl,%esi
  802499:	39 c6                	cmp    %eax,%esi
  80249b:	73 07                	jae    8024a4 <__udivdi3+0xc4>
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	75 03                	jne    8024a4 <__udivdi3+0xc4>
  8024a1:	83 eb 01             	sub    $0x1,%ebx
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	89 fa                	mov    %edi,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	31 ff                	xor    %edi,%edi
  8024ba:	31 db                	xor    %ebx,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 d8                	mov    %ebx,%eax
  8024d2:	f7 f7                	div    %edi
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 c3                	mov    %eax,%ebx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 fa                	mov    %edi,%edx
  8024dc:	83 c4 1c             	add    $0x1c,%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	39 ce                	cmp    %ecx,%esi
  8024ea:	72 0c                	jb     8024f8 <__udivdi3+0x118>
  8024ec:	31 db                	xor    %ebx,%ebx
  8024ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024f2:	0f 87 34 ff ff ff    	ja     80242c <__udivdi3+0x4c>
  8024f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024fd:	e9 2a ff ff ff       	jmp    80242c <__udivdi3+0x4c>
  802502:	66 90                	xchg   %ax,%ax
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80251b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80251f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 d2                	test   %edx,%edx
  802529:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 f3                	mov    %esi,%ebx
  802533:	89 3c 24             	mov    %edi,(%esp)
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	75 1c                	jne    802558 <__umoddi3+0x48>
  80253c:	39 f7                	cmp    %esi,%edi
  80253e:	76 50                	jbe    802590 <__umoddi3+0x80>
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	f7 f7                	div    %edi
  802546:	89 d0                	mov    %edx,%eax
  802548:	31 d2                	xor    %edx,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	39 f2                	cmp    %esi,%edx
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	77 52                	ja     8025b0 <__umoddi3+0xa0>
  80255e:	0f bd ea             	bsr    %edx,%ebp
  802561:	83 f5 1f             	xor    $0x1f,%ebp
  802564:	75 5a                	jne    8025c0 <__umoddi3+0xb0>
  802566:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80256a:	0f 82 e0 00 00 00    	jb     802650 <__umoddi3+0x140>
  802570:	39 0c 24             	cmp    %ecx,(%esp)
  802573:	0f 86 d7 00 00 00    	jbe    802650 <__umoddi3+0x140>
  802579:	8b 44 24 08          	mov    0x8(%esp),%eax
  80257d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802581:	83 c4 1c             	add    $0x1c,%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	85 ff                	test   %edi,%edi
  802592:	89 fd                	mov    %edi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f7                	div    %edi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	89 f0                	mov    %esi,%eax
  8025a3:	31 d2                	xor    %edx,%edx
  8025a5:	f7 f5                	div    %ebp
  8025a7:	89 c8                	mov    %ecx,%eax
  8025a9:	f7 f5                	div    %ebp
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	eb 99                	jmp    802548 <__umoddi3+0x38>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	83 c4 1c             	add    $0x1c,%esp
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 34 24             	mov    (%esp),%esi
  8025c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ef                	sub    %ebp,%edi
  8025cc:	d3 e0                	shl    %cl,%eax
  8025ce:	89 f9                	mov    %edi,%ecx
  8025d0:	89 f2                	mov    %esi,%edx
  8025d2:	d3 ea                	shr    %cl,%edx
  8025d4:	89 e9                	mov    %ebp,%ecx
  8025d6:	09 c2                	or     %eax,%edx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 14 24             	mov    %edx,(%esp)
  8025dd:	89 f2                	mov    %esi,%edx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	89 f9                	mov    %edi,%ecx
  8025e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	89 c6                	mov    %eax,%esi
  8025f1:	d3 e3                	shl    %cl,%ebx
  8025f3:	89 f9                	mov    %edi,%ecx
  8025f5:	89 d0                	mov    %edx,%eax
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	09 d8                	or     %ebx,%eax
  8025fd:	89 d3                	mov    %edx,%ebx
  8025ff:	89 f2                	mov    %esi,%edx
  802601:	f7 34 24             	divl   (%esp)
  802604:	89 d6                	mov    %edx,%esi
  802606:	d3 e3                	shl    %cl,%ebx
  802608:	f7 64 24 04          	mull   0x4(%esp)
  80260c:	39 d6                	cmp    %edx,%esi
  80260e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802612:	89 d1                	mov    %edx,%ecx
  802614:	89 c3                	mov    %eax,%ebx
  802616:	72 08                	jb     802620 <__umoddi3+0x110>
  802618:	75 11                	jne    80262b <__umoddi3+0x11b>
  80261a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80261e:	73 0b                	jae    80262b <__umoddi3+0x11b>
  802620:	2b 44 24 04          	sub    0x4(%esp),%eax
  802624:	1b 14 24             	sbb    (%esp),%edx
  802627:	89 d1                	mov    %edx,%ecx
  802629:	89 c3                	mov    %eax,%ebx
  80262b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80262f:	29 da                	sub    %ebx,%edx
  802631:	19 ce                	sbb    %ecx,%esi
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 f0                	mov    %esi,%eax
  802637:	d3 e0                	shl    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	d3 ea                	shr    %cl,%edx
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	d3 ee                	shr    %cl,%esi
  802641:	09 d0                	or     %edx,%eax
  802643:	89 f2                	mov    %esi,%edx
  802645:	83 c4 1c             	add    $0x1c,%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	29 f9                	sub    %edi,%ecx
  802652:	19 d6                	sbb    %edx,%esi
  802654:	89 74 24 04          	mov    %esi,0x4(%esp)
  802658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265c:	e9 18 ff ff ff       	jmp    802579 <__umoddi3+0x69>
