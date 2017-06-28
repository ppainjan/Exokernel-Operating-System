
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 a8 0a 00 00       	call   800ae8 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 f9 0c 00 00       	call   800d57 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 22 80 00       	push   $0x8022c0
  80006a:	e8 2f 01 00 00       	call   80019e <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 22 80 00       	push   $0x8022d1
  800083:	e8 16 01 00 00       	call   80019e <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 28 0d 00 00       	call   800dc4 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ac:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000b3:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000b6:	e8 2d 0a 00 00       	call   800ae8 <sys_getenvid>
  8000bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c8:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7e 07                	jle    8000d8 <libmain+0x37>
		binaryname = argv[0];
  8000d1:	8b 06                	mov    (%esi),%eax
  8000d3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	e8 51 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e2:	e8 0a 00 00 00       	call   8000f1 <exit>
}
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f7:	e8 20 0f 00 00       	call   80101c <close_all>
	sys_env_destroy(0);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	6a 00                	push   $0x0
  800101:	e8 a1 09 00 00       	call   800aa7 <sys_env_destroy>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	53                   	push   %ebx
  80010f:	83 ec 04             	sub    $0x4,%esp
  800112:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800115:	8b 13                	mov    (%ebx),%edx
  800117:	8d 42 01             	lea    0x1(%edx),%eax
  80011a:	89 03                	mov    %eax,(%ebx)
  80011c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800123:	3d ff 00 00 00       	cmp    $0xff,%eax
  800128:	75 1a                	jne    800144 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	68 ff 00 00 00       	push   $0xff
  800132:	8d 43 08             	lea    0x8(%ebx),%eax
  800135:	50                   	push   %eax
  800136:	e8 2f 09 00 00       	call   800a6a <sys_cputs>
		b->idx = 0;
  80013b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800141:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800144:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800156:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015d:	00 00 00 
	b.cnt = 0;
  800160:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800167:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016a:	ff 75 0c             	pushl  0xc(%ebp)
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800176:	50                   	push   %eax
  800177:	68 0b 01 80 00       	push   $0x80010b
  80017c:	e8 54 01 00 00       	call   8002d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800181:	83 c4 08             	add    $0x8,%esp
  800184:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 d4 08 00 00       	call   800a6a <sys_cputs>

	return b.cnt;
}
  800196:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a7:	50                   	push   %eax
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	e8 9d ff ff ff       	call   80014d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 1c             	sub    $0x1c,%esp
  8001bb:	89 c7                	mov    %eax,%edi
  8001bd:	89 d6                	mov    %edx,%esi
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d9:	39 d3                	cmp    %edx,%ebx
  8001db:	72 05                	jb     8001e2 <printnum+0x30>
  8001dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e0:	77 45                	ja     800227 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	ff 75 18             	pushl  0x18(%ebp)
  8001e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001eb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ee:	53                   	push   %ebx
  8001ef:	ff 75 10             	pushl  0x10(%ebp)
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800201:	e8 2a 1e 00 00       	call   802030 <__udivdi3>
  800206:	83 c4 18             	add    $0x18,%esp
  800209:	52                   	push   %edx
  80020a:	50                   	push   %eax
  80020b:	89 f2                	mov    %esi,%edx
  80020d:	89 f8                	mov    %edi,%eax
  80020f:	e8 9e ff ff ff       	call   8001b2 <printnum>
  800214:	83 c4 20             	add    $0x20,%esp
  800217:	eb 18                	jmp    800231 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	ff 75 18             	pushl  0x18(%ebp)
  800220:	ff d7                	call   *%edi
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	eb 03                	jmp    80022a <printnum+0x78>
  800227:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022a:	83 eb 01             	sub    $0x1,%ebx
  80022d:	85 db                	test   %ebx,%ebx
  80022f:	7f e8                	jg     800219 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	83 ec 04             	sub    $0x4,%esp
  800238:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023b:	ff 75 e0             	pushl  -0x20(%ebp)
  80023e:	ff 75 dc             	pushl  -0x24(%ebp)
  800241:	ff 75 d8             	pushl  -0x28(%ebp)
  800244:	e8 17 1f 00 00       	call   802160 <__umoddi3>
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	0f be 80 f2 22 80 00 	movsbl 0x8022f2(%eax),%eax
  800253:	50                   	push   %eax
  800254:	ff d7                	call   *%edi
}
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800264:	83 fa 01             	cmp    $0x1,%edx
  800267:	7e 0e                	jle    800277 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	8b 52 04             	mov    0x4(%edx),%edx
  800275:	eb 22                	jmp    800299 <getuint+0x38>
	else if (lflag)
  800277:	85 d2                	test   %edx,%edx
  800279:	74 10                	je     80028b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800280:	89 08                	mov    %ecx,(%eax)
  800282:	8b 02                	mov    (%edx),%eax
  800284:	ba 00 00 00 00       	mov    $0x0,%edx
  800289:	eb 0e                	jmp    800299 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 02                	mov    (%edx),%eax
  800294:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002aa:	73 0a                	jae    8002b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	88 02                	mov    %al,(%edx)
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c1:	50                   	push   %eax
  8002c2:	ff 75 10             	pushl  0x10(%ebp)
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 05 00 00 00       	call   8002d5 <vprintfmt>
	va_end(ap);
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 2c             	sub    $0x2c,%esp
  8002de:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e7:	eb 12                	jmp    8002fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	0f 84 89 03 00 00    	je     80067a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	53                   	push   %ebx
  8002f5:	50                   	push   %eax
  8002f6:	ff d6                	call   *%esi
  8002f8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fb:	83 c7 01             	add    $0x1,%edi
  8002fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800302:	83 f8 25             	cmp    $0x25,%eax
  800305:	75 e2                	jne    8002e9 <vprintfmt+0x14>
  800307:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800312:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800319:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
  800325:	eb 07                	jmp    80032e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8d 47 01             	lea    0x1(%edi),%eax
  800331:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800334:	0f b6 07             	movzbl (%edi),%eax
  800337:	0f b6 c8             	movzbl %al,%ecx
  80033a:	83 e8 23             	sub    $0x23,%eax
  80033d:	3c 55                	cmp    $0x55,%al
  80033f:	0f 87 1a 03 00 00    	ja     80065f <vprintfmt+0x38a>
  800345:	0f b6 c0             	movzbl %al,%eax
  800348:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800352:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800356:	eb d6                	jmp    80032e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035b:	b8 00 00 00 00       	mov    $0x0,%eax
  800360:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800363:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800366:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80036d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800370:	83 fa 09             	cmp    $0x9,%edx
  800373:	77 39                	ja     8003ae <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800375:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800378:	eb e9                	jmp    800363 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 48 04             	lea    0x4(%eax),%ecx
  800380:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800383:	8b 00                	mov    (%eax),%eax
  800385:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038b:	eb 27                	jmp    8003b4 <vprintfmt+0xdf>
  80038d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800390:	85 c0                	test   %eax,%eax
  800392:	b9 00 00 00 00       	mov    $0x0,%ecx
  800397:	0f 49 c8             	cmovns %eax,%ecx
  80039a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a0:	eb 8c                	jmp    80032e <vprintfmt+0x59>
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ac:	eb 80                	jmp    80032e <vprintfmt+0x59>
  8003ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b8:	0f 89 70 ff ff ff    	jns    80032e <vprintfmt+0x59>
				width = precision, precision = -1;
  8003be:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cb:	e9 5e ff ff ff       	jmp    80032e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d6:	e9 53 ff ff ff       	jmp    80032e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 50 04             	lea    0x4(%eax),%edx
  8003e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	53                   	push   %ebx
  8003e8:	ff 30                	pushl  (%eax)
  8003ea:	ff d6                	call   *%esi
			break;
  8003ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f2:	e9 04 ff ff ff       	jmp    8002fb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 50 04             	lea    0x4(%eax),%edx
  8003fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	99                   	cltd   
  800403:	31 d0                	xor    %edx,%eax
  800405:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800407:	83 f8 0f             	cmp    $0xf,%eax
  80040a:	7f 0b                	jg     800417 <vprintfmt+0x142>
  80040c:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800413:	85 d2                	test   %edx,%edx
  800415:	75 18                	jne    80042f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800417:	50                   	push   %eax
  800418:	68 0a 23 80 00       	push   $0x80230a
  80041d:	53                   	push   %ebx
  80041e:	56                   	push   %esi
  80041f:	e8 94 fe ff ff       	call   8002b8 <printfmt>
  800424:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042a:	e9 cc fe ff ff       	jmp    8002fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80042f:	52                   	push   %edx
  800430:	68 f5 26 80 00       	push   $0x8026f5
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 7c fe ff ff       	call   8002b8 <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800442:	e9 b4 fe ff ff       	jmp    8002fb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800452:	85 ff                	test   %edi,%edi
  800454:	b8 03 23 80 00       	mov    $0x802303,%eax
  800459:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800460:	0f 8e 94 00 00 00    	jle    8004fa <vprintfmt+0x225>
  800466:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046a:	0f 84 98 00 00 00    	je     800508 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	ff 75 d0             	pushl  -0x30(%ebp)
  800476:	57                   	push   %edi
  800477:	e8 86 02 00 00       	call   800702 <strnlen>
  80047c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047f:	29 c1                	sub    %eax,%ecx
  800481:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800484:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800487:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800491:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	eb 0f                	jmp    8004a4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	53                   	push   %ebx
  800499:	ff 75 e0             	pushl  -0x20(%ebp)
  80049c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ef 01             	sub    $0x1,%edi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 ff                	test   %edi,%edi
  8004a6:	7f ed                	jg     800495 <vprintfmt+0x1c0>
  8004a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ab:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ae:	85 c9                	test   %ecx,%ecx
  8004b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b5:	0f 49 c1             	cmovns %ecx,%eax
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c3:	89 cb                	mov    %ecx,%ebx
  8004c5:	eb 4d                	jmp    800514 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cb:	74 1b                	je     8004e8 <vprintfmt+0x213>
  8004cd:	0f be c0             	movsbl %al,%eax
  8004d0:	83 e8 20             	sub    $0x20,%eax
  8004d3:	83 f8 5e             	cmp    $0x5e,%eax
  8004d6:	76 10                	jbe    8004e8 <vprintfmt+0x213>
					putch('?', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 0c             	pushl  0xc(%ebp)
  8004de:	6a 3f                	push   $0x3f
  8004e0:	ff 55 08             	call   *0x8(%ebp)
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 0d                	jmp    8004f5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ee:	52                   	push   %edx
  8004ef:	ff 55 08             	call   *0x8(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	83 eb 01             	sub    $0x1,%ebx
  8004f8:	eb 1a                	jmp    800514 <vprintfmt+0x23f>
  8004fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800503:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800506:	eb 0c                	jmp    800514 <vprintfmt+0x23f>
  800508:	89 75 08             	mov    %esi,0x8(%ebp)
  80050b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800511:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800514:	83 c7 01             	add    $0x1,%edi
  800517:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051b:	0f be d0             	movsbl %al,%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	74 23                	je     800545 <vprintfmt+0x270>
  800522:	85 f6                	test   %esi,%esi
  800524:	78 a1                	js     8004c7 <vprintfmt+0x1f2>
  800526:	83 ee 01             	sub    $0x1,%esi
  800529:	79 9c                	jns    8004c7 <vprintfmt+0x1f2>
  80052b:	89 df                	mov    %ebx,%edi
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800533:	eb 18                	jmp    80054d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 20                	push   $0x20
  80053b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053d:	83 ef 01             	sub    $0x1,%edi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 08                	jmp    80054d <vprintfmt+0x278>
  800545:	89 df                	mov    %ebx,%edi
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	85 ff                	test   %edi,%edi
  80054f:	7f e4                	jg     800535 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800554:	e9 a2 fd ff ff       	jmp    8002fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800559:	83 fa 01             	cmp    $0x1,%edx
  80055c:	7e 16                	jle    800574 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 08             	lea    0x8(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 50 04             	mov    0x4(%eax),%edx
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800572:	eb 32                	jmp    8005a6 <vprintfmt+0x2d1>
	else if (lflag)
  800574:	85 d2                	test   %edx,%edx
  800576:	74 18                	je     800590 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 04             	lea    0x4(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 c1                	mov    %eax,%ecx
  800588:	c1 f9 1f             	sar    $0x1f,%ecx
  80058b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058e:	eb 16                	jmp    8005a6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059e:	89 c1                	mov    %eax,%ecx
  8005a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b5:	79 74                	jns    80062b <vprintfmt+0x356>
				putch('-', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 2d                	push   $0x2d
  8005bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c5:	f7 d8                	neg    %eax
  8005c7:	83 d2 00             	adc    $0x0,%edx
  8005ca:	f7 da                	neg    %edx
  8005cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d4:	eb 55                	jmp    80062b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 83 fc ff ff       	call   800261 <getuint>
			base = 10;
  8005de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e3:	eb 46                	jmp    80062b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	e8 74 fc ff ff       	call   800261 <getuint>
		        base = 8;
  8005ed:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005f2:	eb 37                	jmp    80062b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 30                	push   $0x30
  8005fa:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fc:	83 c4 08             	add    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 78                	push   $0x78
  800602:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800614:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800617:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061c:	eb 0d                	jmp    80062b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 3b fc ff ff       	call   800261 <getuint>
			base = 16;
  800626:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800632:	57                   	push   %edi
  800633:	ff 75 e0             	pushl  -0x20(%ebp)
  800636:	51                   	push   %ecx
  800637:	52                   	push   %edx
  800638:	50                   	push   %eax
  800639:	89 da                	mov    %ebx,%edx
  80063b:	89 f0                	mov    %esi,%eax
  80063d:	e8 70 fb ff ff       	call   8001b2 <printnum>
			break;
  800642:	83 c4 20             	add    $0x20,%esp
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800648:	e9 ae fc ff ff       	jmp    8002fb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	51                   	push   %ecx
  800652:	ff d6                	call   *%esi
			break;
  800654:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065a:	e9 9c fc ff ff       	jmp    8002fb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 25                	push   $0x25
  800665:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	eb 03                	jmp    80066f <vprintfmt+0x39a>
  80066c:	83 ef 01             	sub    $0x1,%edi
  80066f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800673:	75 f7                	jne    80066c <vprintfmt+0x397>
  800675:	e9 81 fc ff ff       	jmp    8002fb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80067a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5e                   	pop    %esi
  80067f:	5f                   	pop    %edi
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 18             	sub    $0x18,%esp
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800691:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800695:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800698:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	74 26                	je     8006c9 <vsnprintf+0x47>
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	7e 22                	jle    8006c9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a7:	ff 75 14             	pushl  0x14(%ebp)
  8006aa:	ff 75 10             	pushl  0x10(%ebp)
  8006ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b0:	50                   	push   %eax
  8006b1:	68 9b 02 80 00       	push   $0x80029b
  8006b6:	e8 1a fc ff ff       	call   8002d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 05                	jmp    8006ce <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	ff 75 08             	pushl  0x8(%ebp)
  8006e3:	e8 9a ff ff ff       	call   800682 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	eb 03                	jmp    8006fa <strlen+0x10>
		n++;
  8006f7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fe:	75 f7                	jne    8006f7 <strlen+0xd>
		n++;
	return n;
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800708:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	ba 00 00 00 00       	mov    $0x0,%edx
  800710:	eb 03                	jmp    800715 <strnlen+0x13>
		n++;
  800712:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	39 c2                	cmp    %eax,%edx
  800717:	74 08                	je     800721 <strnlen+0x1f>
  800719:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071d:	75 f3                	jne    800712 <strnlen+0x10>
  80071f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072d:	89 c2                	mov    %eax,%edx
  80072f:	83 c2 01             	add    $0x1,%edx
  800732:	83 c1 01             	add    $0x1,%ecx
  800735:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800739:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073c:	84 db                	test   %bl,%bl
  80073e:	75 ef                	jne    80072f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800740:	5b                   	pop    %ebx
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074a:	53                   	push   %ebx
  80074b:	e8 9a ff ff ff       	call   8006ea <strlen>
  800750:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	01 d8                	add    %ebx,%eax
  800758:	50                   	push   %eax
  800759:	e8 c5 ff ff ff       	call   800723 <strcpy>
	return dst;
}
  80075e:	89 d8                	mov    %ebx,%eax
  800760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	56                   	push   %esi
  800769:	53                   	push   %ebx
  80076a:	8b 75 08             	mov    0x8(%ebp),%esi
  80076d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800770:	89 f3                	mov    %esi,%ebx
  800772:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800775:	89 f2                	mov    %esi,%edx
  800777:	eb 0f                	jmp    800788 <strncpy+0x23>
		*dst++ = *src;
  800779:	83 c2 01             	add    $0x1,%edx
  80077c:	0f b6 01             	movzbl (%ecx),%eax
  80077f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800782:	80 39 01             	cmpb   $0x1,(%ecx)
  800785:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	39 da                	cmp    %ebx,%edx
  80078a:	75 ed                	jne    800779 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078c:	89 f0                	mov    %esi,%eax
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	56                   	push   %esi
  800796:	53                   	push   %ebx
  800797:	8b 75 08             	mov    0x8(%ebp),%esi
  80079a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079d:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	74 21                	je     8007c7 <strlcpy+0x35>
  8007a6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007aa:	89 f2                	mov    %esi,%edx
  8007ac:	eb 09                	jmp    8007b7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ae:	83 c2 01             	add    $0x1,%edx
  8007b1:	83 c1 01             	add    $0x1,%ecx
  8007b4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b7:	39 c2                	cmp    %eax,%edx
  8007b9:	74 09                	je     8007c4 <strlcpy+0x32>
  8007bb:	0f b6 19             	movzbl (%ecx),%ebx
  8007be:	84 db                	test   %bl,%bl
  8007c0:	75 ec                	jne    8007ae <strlcpy+0x1c>
  8007c2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c7:	29 f0                	sub    %esi,%eax
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d6:	eb 06                	jmp    8007de <strcmp+0x11>
		p++, q++;
  8007d8:	83 c1 01             	add    $0x1,%ecx
  8007db:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007de:	0f b6 01             	movzbl (%ecx),%eax
  8007e1:	84 c0                	test   %al,%al
  8007e3:	74 04                	je     8007e9 <strcmp+0x1c>
  8007e5:	3a 02                	cmp    (%edx),%al
  8007e7:	74 ef                	je     8007d8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e9:	0f b6 c0             	movzbl %al,%eax
  8007ec:	0f b6 12             	movzbl (%edx),%edx
  8007ef:	29 d0                	sub    %edx,%eax
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 c3                	mov    %eax,%ebx
  8007ff:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800802:	eb 06                	jmp    80080a <strncmp+0x17>
		n--, p++, q++;
  800804:	83 c0 01             	add    $0x1,%eax
  800807:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080a:	39 d8                	cmp    %ebx,%eax
  80080c:	74 15                	je     800823 <strncmp+0x30>
  80080e:	0f b6 08             	movzbl (%eax),%ecx
  800811:	84 c9                	test   %cl,%cl
  800813:	74 04                	je     800819 <strncmp+0x26>
  800815:	3a 0a                	cmp    (%edx),%cl
  800817:	74 eb                	je     800804 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800819:	0f b6 00             	movzbl (%eax),%eax
  80081c:	0f b6 12             	movzbl (%edx),%edx
  80081f:	29 d0                	sub    %edx,%eax
  800821:	eb 05                	jmp    800828 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800835:	eb 07                	jmp    80083e <strchr+0x13>
		if (*s == c)
  800837:	38 ca                	cmp    %cl,%dl
  800839:	74 0f                	je     80084a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083b:	83 c0 01             	add    $0x1,%eax
  80083e:	0f b6 10             	movzbl (%eax),%edx
  800841:	84 d2                	test   %dl,%dl
  800843:	75 f2                	jne    800837 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800856:	eb 03                	jmp    80085b <strfind+0xf>
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085e:	38 ca                	cmp    %cl,%dl
  800860:	74 04                	je     800866 <strfind+0x1a>
  800862:	84 d2                	test   %dl,%dl
  800864:	75 f2                	jne    800858 <strfind+0xc>
			break;
	return (char *) s;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	57                   	push   %edi
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800871:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800874:	85 c9                	test   %ecx,%ecx
  800876:	74 36                	je     8008ae <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800878:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087e:	75 28                	jne    8008a8 <memset+0x40>
  800880:	f6 c1 03             	test   $0x3,%cl
  800883:	75 23                	jne    8008a8 <memset+0x40>
		c &= 0xFF;
  800885:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800889:	89 d3                	mov    %edx,%ebx
  80088b:	c1 e3 08             	shl    $0x8,%ebx
  80088e:	89 d6                	mov    %edx,%esi
  800890:	c1 e6 18             	shl    $0x18,%esi
  800893:	89 d0                	mov    %edx,%eax
  800895:	c1 e0 10             	shl    $0x10,%eax
  800898:	09 f0                	or     %esi,%eax
  80089a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089c:	89 d8                	mov    %ebx,%eax
  80089e:	09 d0                	or     %edx,%eax
  8008a0:	c1 e9 02             	shr    $0x2,%ecx
  8008a3:	fc                   	cld    
  8008a4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a6:	eb 06                	jmp    8008ae <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ab:	fc                   	cld    
  8008ac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ae:	89 f8                	mov    %edi,%eax
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5f                   	pop    %edi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	57                   	push   %edi
  8008b9:	56                   	push   %esi
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c3:	39 c6                	cmp    %eax,%esi
  8008c5:	73 35                	jae    8008fc <memmove+0x47>
  8008c7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ca:	39 d0                	cmp    %edx,%eax
  8008cc:	73 2e                	jae    8008fc <memmove+0x47>
		s += n;
		d += n;
  8008ce:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 d6                	mov    %edx,%esi
  8008d3:	09 fe                	or     %edi,%esi
  8008d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008db:	75 13                	jne    8008f0 <memmove+0x3b>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 0e                	jne    8008f0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e2:	83 ef 04             	sub    $0x4,%edi
  8008e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
  8008eb:	fd                   	std    
  8008ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ee:	eb 09                	jmp    8008f9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f0:	83 ef 01             	sub    $0x1,%edi
  8008f3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f6:	fd                   	std    
  8008f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f9:	fc                   	cld    
  8008fa:	eb 1d                	jmp    800919 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fc:	89 f2                	mov    %esi,%edx
  8008fe:	09 c2                	or     %eax,%edx
  800900:	f6 c2 03             	test   $0x3,%dl
  800903:	75 0f                	jne    800914 <memmove+0x5f>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0a                	jne    800914 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800912:	eb 05                	jmp    800919 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800914:	89 c7                	mov    %eax,%edi
  800916:	fc                   	cld    
  800917:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800920:	ff 75 10             	pushl  0x10(%ebp)
  800923:	ff 75 0c             	pushl  0xc(%ebp)
  800926:	ff 75 08             	pushl  0x8(%ebp)
  800929:	e8 87 ff ff ff       	call   8008b5 <memmove>
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800940:	eb 1a                	jmp    80095c <memcmp+0x2c>
		if (*s1 != *s2)
  800942:	0f b6 08             	movzbl (%eax),%ecx
  800945:	0f b6 1a             	movzbl (%edx),%ebx
  800948:	38 d9                	cmp    %bl,%cl
  80094a:	74 0a                	je     800956 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094c:	0f b6 c1             	movzbl %cl,%eax
  80094f:	0f b6 db             	movzbl %bl,%ebx
  800952:	29 d8                	sub    %ebx,%eax
  800954:	eb 0f                	jmp    800965 <memcmp+0x35>
		s1++, s2++;
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095c:	39 f0                	cmp    %esi,%eax
  80095e:	75 e2                	jne    800942 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800970:	89 c1                	mov    %eax,%ecx
  800972:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800975:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800979:	eb 0a                	jmp    800985 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097b:	0f b6 10             	movzbl (%eax),%edx
  80097e:	39 da                	cmp    %ebx,%edx
  800980:	74 07                	je     800989 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	39 c8                	cmp    %ecx,%eax
  800987:	72 f2                	jb     80097b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800989:	5b                   	pop    %ebx
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800995:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800998:	eb 03                	jmp    80099d <strtol+0x11>
		s++;
  80099a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099d:	0f b6 01             	movzbl (%ecx),%eax
  8009a0:	3c 20                	cmp    $0x20,%al
  8009a2:	74 f6                	je     80099a <strtol+0xe>
  8009a4:	3c 09                	cmp    $0x9,%al
  8009a6:	74 f2                	je     80099a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a8:	3c 2b                	cmp    $0x2b,%al
  8009aa:	75 0a                	jne    8009b6 <strtol+0x2a>
		s++;
  8009ac:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009af:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b4:	eb 11                	jmp    8009c7 <strtol+0x3b>
  8009b6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009bb:	3c 2d                	cmp    $0x2d,%al
  8009bd:	75 08                	jne    8009c7 <strtol+0x3b>
		s++, neg = 1;
  8009bf:	83 c1 01             	add    $0x1,%ecx
  8009c2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cd:	75 15                	jne    8009e4 <strtol+0x58>
  8009cf:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d2:	75 10                	jne    8009e4 <strtol+0x58>
  8009d4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d8:	75 7c                	jne    800a56 <strtol+0xca>
		s += 2, base = 16;
  8009da:	83 c1 02             	add    $0x2,%ecx
  8009dd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e2:	eb 16                	jmp    8009fa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e4:	85 db                	test   %ebx,%ebx
  8009e6:	75 12                	jne    8009fa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ed:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f0:	75 08                	jne    8009fa <strtol+0x6e>
		s++, base = 8;
  8009f2:	83 c1 01             	add    $0x1,%ecx
  8009f5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a02:	0f b6 11             	movzbl (%ecx),%edx
  800a05:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a08:	89 f3                	mov    %esi,%ebx
  800a0a:	80 fb 09             	cmp    $0x9,%bl
  800a0d:	77 08                	ja     800a17 <strtol+0x8b>
			dig = *s - '0';
  800a0f:	0f be d2             	movsbl %dl,%edx
  800a12:	83 ea 30             	sub    $0x30,%edx
  800a15:	eb 22                	jmp    800a39 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a17:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	80 fb 19             	cmp    $0x19,%bl
  800a1f:	77 08                	ja     800a29 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a21:	0f be d2             	movsbl %dl,%edx
  800a24:	83 ea 57             	sub    $0x57,%edx
  800a27:	eb 10                	jmp    800a39 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a29:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2c:	89 f3                	mov    %esi,%ebx
  800a2e:	80 fb 19             	cmp    $0x19,%bl
  800a31:	77 16                	ja     800a49 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a33:	0f be d2             	movsbl %dl,%edx
  800a36:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3c:	7d 0b                	jge    800a49 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a45:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a47:	eb b9                	jmp    800a02 <strtol+0x76>

	if (endptr)
  800a49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4d:	74 0d                	je     800a5c <strtol+0xd0>
		*endptr = (char *) s;
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	89 0e                	mov    %ecx,(%esi)
  800a54:	eb 06                	jmp    800a5c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	74 98                	je     8009f2 <strtol+0x66>
  800a5a:	eb 9e                	jmp    8009fa <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5c:	89 c2                	mov    %eax,%edx
  800a5e:	f7 da                	neg    %edx
  800a60:	85 ff                	test   %edi,%edi
  800a62:	0f 45 c2             	cmovne %edx,%eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	89 c3                	mov    %eax,%ebx
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	89 c6                	mov    %eax,%esi
  800a81:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a93:	b8 01 00 00 00       	mov    $0x1,%eax
  800a98:	89 d1                	mov    %edx,%ecx
  800a9a:	89 d3                	mov    %edx,%ebx
  800a9c:	89 d7                	mov    %edx,%edi
  800a9e:	89 d6                	mov    %edx,%esi
  800aa0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	89 cb                	mov    %ecx,%ebx
  800abf:	89 cf                	mov    %ecx,%edi
  800ac1:	89 ce                	mov    %ecx,%esi
  800ac3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac5:	85 c0                	test   %eax,%eax
  800ac7:	7e 17                	jle    800ae0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	50                   	push   %eax
  800acd:	6a 03                	push   $0x3
  800acf:	68 ff 25 80 00       	push   $0x8025ff
  800ad4:	6a 23                	push   $0x23
  800ad6:	68 1c 26 80 00       	push   $0x80261c
  800adb:	e8 c6 14 00 00       	call   801fa6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 02 00 00 00       	mov    $0x2,%eax
  800af8:	89 d1                	mov    %edx,%ecx
  800afa:	89 d3                	mov    %edx,%ebx
  800afc:	89 d7                	mov    %edx,%edi
  800afe:	89 d6                	mov    %edx,%esi
  800b00:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_yield>:

void
sys_yield(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b17:	89 d1                	mov    %edx,%ecx
  800b19:	89 d3                	mov    %edx,%ebx
  800b1b:	89 d7                	mov    %edx,%edi
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b2f:	be 00 00 00 00       	mov    $0x0,%esi
  800b34:	b8 04 00 00 00       	mov    $0x4,%eax
  800b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b42:	89 f7                	mov    %esi,%edi
  800b44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b46:	85 c0                	test   %eax,%eax
  800b48:	7e 17                	jle    800b61 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	50                   	push   %eax
  800b4e:	6a 04                	push   $0x4
  800b50:	68 ff 25 80 00       	push   $0x8025ff
  800b55:	6a 23                	push   $0x23
  800b57:	68 1c 26 80 00       	push   $0x80261c
  800b5c:	e8 45 14 00 00       	call   801fa6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b8 05 00 00 00       	mov    $0x5,%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b83:	8b 75 18             	mov    0x18(%ebp),%esi
  800b86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	7e 17                	jle    800ba3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	50                   	push   %eax
  800b90:	6a 05                	push   $0x5
  800b92:	68 ff 25 80 00       	push   $0x8025ff
  800b97:	6a 23                	push   $0x23
  800b99:	68 1c 26 80 00       	push   $0x80261c
  800b9e:	e8 03 14 00 00       	call   801fa6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	89 df                	mov    %ebx,%edi
  800bc6:	89 de                	mov    %ebx,%esi
  800bc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	7e 17                	jle    800be5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 06                	push   $0x6
  800bd4:	68 ff 25 80 00       	push   $0x8025ff
  800bd9:	6a 23                	push   $0x23
  800bdb:	68 1c 26 80 00       	push   $0x80261c
  800be0:	e8 c1 13 00 00       	call   801fa6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfb:	b8 08 00 00 00       	mov    $0x8,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	89 df                	mov    %ebx,%edi
  800c08:	89 de                	mov    %ebx,%esi
  800c0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 17                	jle    800c27 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 08                	push   $0x8
  800c16:	68 ff 25 80 00       	push   $0x8025ff
  800c1b:	6a 23                	push   $0x23
  800c1d:	68 1c 26 80 00       	push   $0x80261c
  800c22:	e8 7f 13 00 00       	call   801fa6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	89 df                	mov    %ebx,%edi
  800c4a:	89 de                	mov    %ebx,%esi
  800c4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7e 17                	jle    800c69 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	50                   	push   %eax
  800c56:	6a 09                	push   $0x9
  800c58:	68 ff 25 80 00       	push   $0x8025ff
  800c5d:	6a 23                	push   $0x23
  800c5f:	68 1c 26 80 00       	push   $0x80261c
  800c64:	e8 3d 13 00 00       	call   801fa6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	89 df                	mov    %ebx,%edi
  800c8c:	89 de                	mov    %ebx,%esi
  800c8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7e 17                	jle    800cab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 0a                	push   $0xa
  800c9a:	68 ff 25 80 00       	push   $0x8025ff
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 1c 26 80 00       	push   $0x80261c
  800ca6:	e8 fb 12 00 00       	call   801fa6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	be 00 00 00 00       	mov    $0x0,%esi
  800cbe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	89 cb                	mov    %ecx,%ebx
  800cee:	89 cf                	mov    %ecx,%edi
  800cf0:	89 ce                	mov    %ecx,%esi
  800cf2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7e 17                	jle    800d0f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 0d                	push   $0xd
  800cfe:	68 ff 25 80 00       	push   $0x8025ff
  800d03:	6a 23                	push   $0x23
  800d05:	68 1c 26 80 00       	push   $0x80261c
  800d0a:	e8 97 12 00 00       	call   801fa6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d27:	89 d1                	mov    %edx,%ecx
  800d29:	89 d3                	mov    %edx,%ebx
  800d2b:	89 d7                	mov    %edx,%edi
  800d2d:	89 d6                	mov    %edx,%esi
  800d2f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	74 0e                	je     800d77 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	e8 64 ff ff ff       	call   800cd6 <sys_ipc_recv>
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	eb 10                	jmp    800d87 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  800d77:	83 ec 0c             	sub    $0xc,%esp
  800d7a:	68 00 00 00 f0       	push   $0xf0000000
  800d7f:	e8 52 ff ff ff       	call   800cd6 <sys_ipc_recv>
  800d84:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  800d87:	85 c0                	test   %eax,%eax
  800d89:	74 0e                	je     800d99 <ipc_recv+0x42>
    	*from_env_store = 0;
  800d8b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  800d91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  800d97:	eb 24                	jmp    800dbd <ipc_recv+0x66>
    }	
    if (from_env_store) {
  800d99:	85 f6                	test   %esi,%esi
  800d9b:	74 0a                	je     800da7 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  800d9d:	a1 08 40 80 00       	mov    0x804008,%eax
  800da2:	8b 40 74             	mov    0x74(%eax),%eax
  800da5:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  800da7:	85 db                	test   %ebx,%ebx
  800da9:	74 0a                	je     800db5 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  800dab:	a1 08 40 80 00       	mov    0x804008,%eax
  800db0:	8b 40 78             	mov    0x78(%eax),%eax
  800db3:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  800db5:	a1 08 40 80 00       	mov    0x804008,%eax
  800dba:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  800dbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  800dd6:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  800dd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ddd:	0f 44 d8             	cmove  %eax,%ebx
  800de0:	eb 1c                	jmp    800dfe <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  800de2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800de5:	74 12                	je     800df9 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  800de7:	50                   	push   %eax
  800de8:	68 2a 26 80 00       	push   $0x80262a
  800ded:	6a 4b                	push   $0x4b
  800def:	68 42 26 80 00       	push   $0x802642
  800df4:	e8 ad 11 00 00       	call   801fa6 <_panic>
        }	
        sys_yield();
  800df9:	e8 09 fd ff ff       	call   800b07 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  800dfe:	ff 75 14             	pushl  0x14(%ebp)
  800e01:	53                   	push   %ebx
  800e02:	56                   	push   %esi
  800e03:	57                   	push   %edi
  800e04:	e8 aa fe ff ff       	call   800cb3 <sys_ipc_try_send>
  800e09:	83 c4 10             	add    $0x10,%esp
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	75 d2                	jne    800de2 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e23:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e26:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e2c:	8b 52 50             	mov    0x50(%edx),%edx
  800e2f:	39 ca                	cmp    %ecx,%edx
  800e31:	75 0d                	jne    800e40 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e33:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e36:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e3b:	8b 40 48             	mov    0x48(%eax),%eax
  800e3e:	eb 0f                	jmp    800e4f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e40:	83 c0 01             	add    $0x1,%eax
  800e43:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e48:	75 d9                	jne    800e23 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e71:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	c1 ea 16             	shr    $0x16,%edx
  800e88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8f:	f6 c2 01             	test   $0x1,%dl
  800e92:	74 11                	je     800ea5 <fd_alloc+0x2d>
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 0c             	shr    $0xc,%edx
  800e99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	75 09                	jne    800eae <fd_alloc+0x36>
			*fd_store = fd;
  800ea5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	eb 17                	jmp    800ec5 <fd_alloc+0x4d>
  800eae:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb8:	75 c9                	jne    800e83 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ecd:	83 f8 1f             	cmp    $0x1f,%eax
  800ed0:	77 36                	ja     800f08 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed2:	c1 e0 0c             	shl    $0xc,%eax
  800ed5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	c1 ea 16             	shr    $0x16,%edx
  800edf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	74 24                	je     800f0f <fd_lookup+0x48>
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	c1 ea 0c             	shr    $0xc,%edx
  800ef0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef7:	f6 c2 01             	test   $0x1,%dl
  800efa:	74 1a                	je     800f16 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eff:	89 02                	mov    %eax,(%edx)
	return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 13                	jmp    800f1b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0d:	eb 0c                	jmp    800f1b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f14:	eb 05                	jmp    800f1b <fd_lookup+0x54>
  800f16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f26:	ba c8 26 80 00       	mov    $0x8026c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2b:	eb 13                	jmp    800f40 <dev_lookup+0x23>
  800f2d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f30:	39 08                	cmp    %ecx,(%eax)
  800f32:	75 0c                	jne    800f40 <dev_lookup+0x23>
			*dev = devtab[i];
  800f34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f37:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 2e                	jmp    800f6e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f40:	8b 02                	mov    (%edx),%eax
  800f42:	85 c0                	test   %eax,%eax
  800f44:	75 e7                	jne    800f2d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f46:	a1 08 40 80 00       	mov    0x804008,%eax
  800f4b:	8b 40 48             	mov    0x48(%eax),%eax
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	51                   	push   %ecx
  800f52:	50                   	push   %eax
  800f53:	68 4c 26 80 00       	push   $0x80264c
  800f58:	e8 41 f2 ff ff       	call   80019e <cprintf>
	*dev = 0;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 10             	sub    $0x10,%esp
  800f78:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f88:	c1 e8 0c             	shr    $0xc,%eax
  800f8b:	50                   	push   %eax
  800f8c:	e8 36 ff ff ff       	call   800ec7 <fd_lookup>
  800f91:	83 c4 08             	add    $0x8,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 05                	js     800f9d <fd_close+0x2d>
	    || fd != fd2)
  800f98:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9b:	74 0c                	je     800fa9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f9d:	84 db                	test   %bl,%bl
  800f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa4:	0f 44 c2             	cmove  %edx,%eax
  800fa7:	eb 41                	jmp    800fea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	ff 36                	pushl  (%esi)
  800fb2:	e8 66 ff ff ff       	call   800f1d <dev_lookup>
  800fb7:	89 c3                	mov    %eax,%ebx
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 1a                	js     800fda <fd_close+0x6a>
		if (dev->dev_close)
  800fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	74 0b                	je     800fda <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	56                   	push   %esi
  800fd3:	ff d0                	call   *%eax
  800fd5:	89 c3                	mov    %eax,%ebx
  800fd7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 c6 fb ff ff       	call   800bab <sys_page_unmap>
	return r;
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	89 d8                	mov    %ebx,%eax
}
  800fea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 c4 fe ff ff       	call   800ec7 <fd_lookup>
  801003:	83 c4 08             	add    $0x8,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 10                	js     80101a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	6a 01                	push   $0x1
  80100f:	ff 75 f4             	pushl  -0xc(%ebp)
  801012:	e8 59 ff ff ff       	call   800f70 <fd_close>
  801017:	83 c4 10             	add    $0x10,%esp
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <close_all>:

void
close_all(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801023:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	53                   	push   %ebx
  80102c:	e8 c0 ff ff ff       	call   800ff1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801031:	83 c3 01             	add    $0x1,%ebx
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	83 fb 20             	cmp    $0x20,%ebx
  80103a:	75 ec                	jne    801028 <close_all+0xc>
		close(i);
}
  80103c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 2c             	sub    $0x2c,%esp
  80104a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	ff 75 08             	pushl  0x8(%ebp)
  801054:	e8 6e fe ff ff       	call   800ec7 <fd_lookup>
  801059:	83 c4 08             	add    $0x8,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	0f 88 c1 00 00 00    	js     801125 <dup+0xe4>
		return r;
	close(newfdnum);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	56                   	push   %esi
  801068:	e8 84 ff ff ff       	call   800ff1 <close>

	newfd = INDEX2FD(newfdnum);
  80106d:	89 f3                	mov    %esi,%ebx
  80106f:	c1 e3 0c             	shl    $0xc,%ebx
  801072:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801078:	83 c4 04             	add    $0x4,%esp
  80107b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107e:	e8 de fd ff ff       	call   800e61 <fd2data>
  801083:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801085:	89 1c 24             	mov    %ebx,(%esp)
  801088:	e8 d4 fd ff ff       	call   800e61 <fd2data>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801093:	89 f8                	mov    %edi,%eax
  801095:	c1 e8 16             	shr    $0x16,%eax
  801098:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	74 37                	je     8010da <dup+0x99>
  8010a3:	89 f8                	mov    %edi,%eax
  8010a5:	c1 e8 0c             	shr    $0xc,%eax
  8010a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 26                	je     8010da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c3:	50                   	push   %eax
  8010c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c7:	6a 00                	push   $0x0
  8010c9:	57                   	push   %edi
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 98 fa ff ff       	call   800b69 <sys_page_map>
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	83 c4 20             	add    $0x20,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 2e                	js     801108 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010dd:	89 d0                	mov    %edx,%eax
  8010df:	c1 e8 0c             	shr    $0xc,%eax
  8010e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f1:	50                   	push   %eax
  8010f2:	53                   	push   %ebx
  8010f3:	6a 00                	push   $0x0
  8010f5:	52                   	push   %edx
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 6c fa ff ff       	call   800b69 <sys_page_map>
  8010fd:	89 c7                	mov    %eax,%edi
  8010ff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801102:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801104:	85 ff                	test   %edi,%edi
  801106:	79 1d                	jns    801125 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	53                   	push   %ebx
  80110c:	6a 00                	push   $0x0
  80110e:	e8 98 fa ff ff       	call   800bab <sys_page_unmap>
	sys_page_unmap(0, nva);
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	ff 75 d4             	pushl  -0x2c(%ebp)
  801119:	6a 00                	push   $0x0
  80111b:	e8 8b fa ff ff       	call   800bab <sys_page_unmap>
	return r;
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	89 f8                	mov    %edi,%eax
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	53                   	push   %ebx
  801131:	83 ec 14             	sub    $0x14,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	53                   	push   %ebx
  80113c:	e8 86 fd ff ff       	call   800ec7 <fd_lookup>
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	89 c2                	mov    %eax,%edx
  801146:	85 c0                	test   %eax,%eax
  801148:	78 6d                	js     8011b7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801154:	ff 30                	pushl  (%eax)
  801156:	e8 c2 fd ff ff       	call   800f1d <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 4c                	js     8011ae <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801162:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801165:	8b 42 08             	mov    0x8(%edx),%eax
  801168:	83 e0 03             	and    $0x3,%eax
  80116b:	83 f8 01             	cmp    $0x1,%eax
  80116e:	75 21                	jne    801191 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801170:	a1 08 40 80 00       	mov    0x804008,%eax
  801175:	8b 40 48             	mov    0x48(%eax),%eax
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	53                   	push   %ebx
  80117c:	50                   	push   %eax
  80117d:	68 8d 26 80 00       	push   $0x80268d
  801182:	e8 17 f0 ff ff       	call   80019e <cprintf>
		return -E_INVAL;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118f:	eb 26                	jmp    8011b7 <read+0x8a>
	}
	if (!dev->dev_read)
  801191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801194:	8b 40 08             	mov    0x8(%eax),%eax
  801197:	85 c0                	test   %eax,%eax
  801199:	74 17                	je     8011b2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	ff 75 10             	pushl  0x10(%ebp)
  8011a1:	ff 75 0c             	pushl  0xc(%ebp)
  8011a4:	52                   	push   %edx
  8011a5:	ff d0                	call   *%eax
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	eb 09                	jmp    8011b7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	eb 05                	jmp    8011b7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	eb 21                	jmp    8011f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	89 f0                	mov    %esi,%eax
  8011d9:	29 d8                	sub    %ebx,%eax
  8011db:	50                   	push   %eax
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	03 45 0c             	add    0xc(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	57                   	push   %edi
  8011e3:	e8 45 ff ff ff       	call   80112d <read>
		if (m < 0)
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 10                	js     8011ff <readn+0x41>
			return m;
		if (m == 0)
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	74 0a                	je     8011fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f3:	01 c3                	add    %eax,%ebx
  8011f5:	39 f3                	cmp    %esi,%ebx
  8011f7:	72 db                	jb     8011d4 <readn+0x16>
  8011f9:	89 d8                	mov    %ebx,%eax
  8011fb:	eb 02                	jmp    8011ff <readn+0x41>
  8011fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	53                   	push   %ebx
  80120b:	83 ec 14             	sub    $0x14,%esp
  80120e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801211:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	53                   	push   %ebx
  801216:	e8 ac fc ff ff       	call   800ec7 <fd_lookup>
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 68                	js     80128c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	ff 30                	pushl  (%eax)
  801230:	e8 e8 fc ff ff       	call   800f1d <dev_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 47                	js     801283 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801243:	75 21                	jne    801266 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801245:	a1 08 40 80 00       	mov    0x804008,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	53                   	push   %ebx
  801251:	50                   	push   %eax
  801252:	68 a9 26 80 00       	push   $0x8026a9
  801257:	e8 42 ef ff ff       	call   80019e <cprintf>
		return -E_INVAL;
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801264:	eb 26                	jmp    80128c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801266:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801269:	8b 52 0c             	mov    0xc(%edx),%edx
  80126c:	85 d2                	test   %edx,%edx
  80126e:	74 17                	je     801287 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	ff 75 10             	pushl  0x10(%ebp)
  801276:	ff 75 0c             	pushl  0xc(%ebp)
  801279:	50                   	push   %eax
  80127a:	ff d2                	call   *%edx
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	eb 09                	jmp    80128c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	89 c2                	mov    %eax,%edx
  801285:	eb 05                	jmp    80128c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801287:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80128c:	89 d0                	mov    %edx,%eax
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <seek>:

int
seek(int fdnum, off_t offset)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801299:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 75 08             	pushl  0x8(%ebp)
  8012a0:	e8 22 fc ff ff       	call   800ec7 <fd_lookup>
  8012a5:	83 c4 08             	add    $0x8,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 0e                	js     8012ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 14             	sub    $0x14,%esp
  8012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	53                   	push   %ebx
  8012cb:	e8 f7 fb ff ff       	call   800ec7 <fd_lookup>
  8012d0:	83 c4 08             	add    $0x8,%esp
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 65                	js     80133e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e3:	ff 30                	pushl  (%eax)
  8012e5:	e8 33 fc ff ff       	call   800f1d <dev_lookup>
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 44                	js     801335 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f8:	75 21                	jne    80131b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fa:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ff:	8b 40 48             	mov    0x48(%eax),%eax
  801302:	83 ec 04             	sub    $0x4,%esp
  801305:	53                   	push   %ebx
  801306:	50                   	push   %eax
  801307:	68 6c 26 80 00       	push   $0x80266c
  80130c:	e8 8d ee ff ff       	call   80019e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801319:	eb 23                	jmp    80133e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80131b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131e:	8b 52 18             	mov    0x18(%edx),%edx
  801321:	85 d2                	test   %edx,%edx
  801323:	74 14                	je     801339 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	ff 75 0c             	pushl  0xc(%ebp)
  80132b:	50                   	push   %eax
  80132c:	ff d2                	call   *%edx
  80132e:	89 c2                	mov    %eax,%edx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	eb 09                	jmp    80133e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	89 c2                	mov    %eax,%edx
  801337:	eb 05                	jmp    80133e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801339:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80133e:	89 d0                	mov    %edx,%eax
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 14             	sub    $0x14,%esp
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 6c fb ff ff       	call   800ec7 <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	89 c2                	mov    %eax,%edx
  801360:	85 c0                	test   %eax,%eax
  801362:	78 58                	js     8013bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	ff 30                	pushl  (%eax)
  801370:	e8 a8 fb ff ff       	call   800f1d <dev_lookup>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 37                	js     8013b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801383:	74 32                	je     8013b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801385:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801388:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138f:	00 00 00 
	stat->st_isdir = 0;
  801392:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801399:	00 00 00 
	stat->st_dev = dev;
  80139c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	53                   	push   %ebx
  8013a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a9:	ff 50 14             	call   *0x14(%eax)
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	eb 09                	jmp    8013bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	eb 05                	jmp    8013bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013bc:	89 d0                	mov    %edx,%eax
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	6a 00                	push   $0x0
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 e7 01 00 00       	call   8015bc <open>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 1b                	js     8013f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	50                   	push   %eax
  8013e5:	e8 5b ff ff ff       	call   801345 <fstat>
  8013ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ec:	89 1c 24             	mov    %ebx,(%esp)
  8013ef:	e8 fd fb ff ff       	call   800ff1 <close>
	return r;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	89 f0                	mov    %esi,%eax
}
  8013f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	89 c6                	mov    %eax,%esi
  801407:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801409:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801410:	75 12                	jne    801424 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	6a 01                	push   $0x1
  801417:	e8 fc f9 ff ff       	call   800e18 <ipc_find_env>
  80141c:	a3 00 40 80 00       	mov    %eax,0x804000
  801421:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801424:	6a 07                	push   $0x7
  801426:	68 00 50 80 00       	push   $0x805000
  80142b:	56                   	push   %esi
  80142c:	ff 35 00 40 80 00    	pushl  0x804000
  801432:	e8 8d f9 ff ff       	call   800dc4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801437:	83 c4 0c             	add    $0xc,%esp
  80143a:	6a 00                	push   $0x0
  80143c:	53                   	push   %ebx
  80143d:	6a 00                	push   $0x0
  80143f:	e8 13 f9 ff ff       	call   800d57 <ipc_recv>
}
  801444:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8b 40 0c             	mov    0xc(%eax),%eax
  801457:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 02 00 00 00       	mov    $0x2,%eax
  80146e:	e8 8d ff ff ff       	call   801400 <fsipc>
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	8b 40 0c             	mov    0xc(%eax),%eax
  801481:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801486:	ba 00 00 00 00       	mov    $0x0,%edx
  80148b:	b8 06 00 00 00       	mov    $0x6,%eax
  801490:	e8 6b ff ff ff       	call   801400 <fsipc>
}
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	53                   	push   %ebx
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b6:	e8 45 ff ff ff       	call   801400 <fsipc>
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 2c                	js     8014eb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	68 00 50 80 00       	push   $0x805000
  8014c7:	53                   	push   %ebx
  8014c8:	e8 56 f2 ff ff       	call   800723 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8014fa:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014ff:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801504:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801507:	53                   	push   %ebx
  801508:	ff 75 0c             	pushl  0xc(%ebp)
  80150b:	68 08 50 80 00       	push   $0x805008
  801510:	e8 a0 f3 ff ff       	call   8008b5 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801520:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 04 00 00 00       	mov    $0x4,%eax
  801530:	e8 cb fe ff ff       	call   801400 <fsipc>
	//panic("devfile_write not implemented");
}
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801542:	8b 45 08             	mov    0x8(%ebp),%eax
  801545:	8b 40 0c             	mov    0xc(%eax),%eax
  801548:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	b8 03 00 00 00       	mov    $0x3,%eax
  80155d:	e8 9e fe ff ff       	call   801400 <fsipc>
  801562:	89 c3                	mov    %eax,%ebx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 4b                	js     8015b3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801568:	39 c6                	cmp    %eax,%esi
  80156a:	73 16                	jae    801582 <devfile_read+0x48>
  80156c:	68 dc 26 80 00       	push   $0x8026dc
  801571:	68 e3 26 80 00       	push   $0x8026e3
  801576:	6a 7c                	push   $0x7c
  801578:	68 f8 26 80 00       	push   $0x8026f8
  80157d:	e8 24 0a 00 00       	call   801fa6 <_panic>
	assert(r <= PGSIZE);
  801582:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801587:	7e 16                	jle    80159f <devfile_read+0x65>
  801589:	68 03 27 80 00       	push   $0x802703
  80158e:	68 e3 26 80 00       	push   $0x8026e3
  801593:	6a 7d                	push   $0x7d
  801595:	68 f8 26 80 00       	push   $0x8026f8
  80159a:	e8 07 0a 00 00       	call   801fa6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	50                   	push   %eax
  8015a3:	68 00 50 80 00       	push   $0x805000
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	e8 05 f3 ff ff       	call   8008b5 <memmove>
	return r;
  8015b0:	83 c4 10             	add    $0x10,%esp
}
  8015b3:	89 d8                	mov    %ebx,%eax
  8015b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 20             	sub    $0x20,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c6:	53                   	push   %ebx
  8015c7:	e8 1e f1 ff ff       	call   8006ea <strlen>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d4:	7f 67                	jg     80163d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	e8 96 f8 ff ff       	call   800e78 <fd_alloc>
  8015e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 57                	js     801642 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	68 00 50 80 00       	push   $0x805000
  8015f4:	e8 2a f1 ff ff       	call   800723 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801601:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801604:	b8 01 00 00 00       	mov    $0x1,%eax
  801609:	e8 f2 fd ff ff       	call   801400 <fsipc>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	79 14                	jns    80162b <open+0x6f>
		fd_close(fd, 0);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	6a 00                	push   $0x0
  80161c:	ff 75 f4             	pushl  -0xc(%ebp)
  80161f:	e8 4c f9 ff ff       	call   800f70 <fd_close>
		return r;
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	89 da                	mov    %ebx,%edx
  801629:	eb 17                	jmp    801642 <open+0x86>
	}

	return fd2num(fd);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 1b f8 ff ff       	call   800e51 <fd2num>
  801636:	89 c2                	mov    %eax,%edx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb 05                	jmp    801642 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801642:	89 d0                	mov    %edx,%eax
  801644:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	b8 08 00 00 00       	mov    $0x8,%eax
  801659:	e8 a2 fd ff ff       	call   801400 <fsipc>
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801666:	68 0f 27 80 00       	push   $0x80270f
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	e8 b0 f0 ff ff       	call   800723 <strcpy>
	return 0;
}
  801673:	b8 00 00 00 00       	mov    $0x0,%eax
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 10             	sub    $0x10,%esp
  801681:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801684:	53                   	push   %ebx
  801685:	e8 62 09 00 00       	call   801fec <pageref>
  80168a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80168d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801692:	83 f8 01             	cmp    $0x1,%eax
  801695:	75 10                	jne    8016a7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801697:	83 ec 0c             	sub    $0xc,%esp
  80169a:	ff 73 0c             	pushl  0xc(%ebx)
  80169d:	e8 c0 02 00 00       	call   801962 <nsipc_close>
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016b4:	6a 00                	push   $0x0
  8016b6:	ff 75 10             	pushl  0x10(%ebp)
  8016b9:	ff 75 0c             	pushl  0xc(%ebp)
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	ff 70 0c             	pushl  0xc(%eax)
  8016c2:	e8 78 03 00 00       	call   801a3f <nsipc_send>
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016cf:	6a 00                	push   $0x0
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	ff 70 0c             	pushl  0xc(%eax)
  8016dd:	e8 f1 02 00 00       	call   8019d3 <nsipc_recv>
}
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    

008016e4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016ea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016ed:	52                   	push   %edx
  8016ee:	50                   	push   %eax
  8016ef:	e8 d3 f7 ff ff       	call   800ec7 <fd_lookup>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 17                	js     801712 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fe:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801704:	39 08                	cmp    %ecx,(%eax)
  801706:	75 05                	jne    80170d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801708:	8b 40 0c             	mov    0xc(%eax),%eax
  80170b:	eb 05                	jmp    801712 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 1c             	sub    $0x1c,%esp
  80171c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80171e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	e8 51 f7 ff ff       	call   800e78 <fd_alloc>
  801727:	89 c3                	mov    %eax,%ebx
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 1b                	js     80174b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801730:	83 ec 04             	sub    $0x4,%esp
  801733:	68 07 04 00 00       	push   $0x407
  801738:	ff 75 f4             	pushl  -0xc(%ebp)
  80173b:	6a 00                	push   $0x0
  80173d:	e8 e4 f3 ff ff       	call   800b26 <sys_page_alloc>
  801742:	89 c3                	mov    %eax,%ebx
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	79 10                	jns    80175b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80174b:	83 ec 0c             	sub    $0xc,%esp
  80174e:	56                   	push   %esi
  80174f:	e8 0e 02 00 00       	call   801962 <nsipc_close>
		return r;
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	89 d8                	mov    %ebx,%eax
  801759:	eb 24                	jmp    80177f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80175b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801764:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801769:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801770:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	50                   	push   %eax
  801777:	e8 d5 f6 ff ff       	call   800e51 <fd2num>
  80177c:	83 c4 10             	add    $0x10,%esp
}
  80177f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	e8 50 ff ff ff       	call   8016e4 <fd2sockid>
		return r;
  801794:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801796:	85 c0                	test   %eax,%eax
  801798:	78 1f                	js     8017b9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	ff 75 10             	pushl  0x10(%ebp)
  8017a0:	ff 75 0c             	pushl  0xc(%ebp)
  8017a3:	50                   	push   %eax
  8017a4:	e8 12 01 00 00       	call   8018bb <nsipc_accept>
  8017a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ac:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 07                	js     8017b9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017b2:	e8 5d ff ff ff       	call   801714 <alloc_sockfd>
  8017b7:	89 c1                	mov    %eax,%ecx
}
  8017b9:	89 c8                	mov    %ecx,%eax
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	e8 19 ff ff ff       	call   8016e4 <fd2sockid>
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 12                	js     8017e1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	ff 75 10             	pushl  0x10(%ebp)
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	50                   	push   %eax
  8017d9:	e8 2d 01 00 00       	call   80190b <nsipc_bind>
  8017de:	83 c4 10             	add    $0x10,%esp
}
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <shutdown>:

int
shutdown(int s, int how)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	e8 f3 fe ff ff       	call   8016e4 <fd2sockid>
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 0f                	js     801804 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	ff 75 0c             	pushl  0xc(%ebp)
  8017fb:	50                   	push   %eax
  8017fc:	e8 3f 01 00 00       	call   801940 <nsipc_shutdown>
  801801:	83 c4 10             	add    $0x10,%esp
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	e8 d0 fe ff ff       	call   8016e4 <fd2sockid>
  801814:	85 c0                	test   %eax,%eax
  801816:	78 12                	js     80182a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801818:	83 ec 04             	sub    $0x4,%esp
  80181b:	ff 75 10             	pushl  0x10(%ebp)
  80181e:	ff 75 0c             	pushl  0xc(%ebp)
  801821:	50                   	push   %eax
  801822:	e8 55 01 00 00       	call   80197c <nsipc_connect>
  801827:	83 c4 10             	add    $0x10,%esp
}
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <listen>:

int
listen(int s, int backlog)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	e8 aa fe ff ff       	call   8016e4 <fd2sockid>
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 0f                	js     80184d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	50                   	push   %eax
  801845:	e8 67 01 00 00       	call   8019b1 <nsipc_listen>
  80184a:	83 c4 10             	add    $0x10,%esp
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801855:	ff 75 10             	pushl  0x10(%ebp)
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	ff 75 08             	pushl  0x8(%ebp)
  80185e:	e8 3a 02 00 00       	call   801a9d <nsipc_socket>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	78 05                	js     80186f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80186a:	e8 a5 fe ff ff       	call   801714 <alloc_sockfd>
}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	53                   	push   %ebx
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80187a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801881:	75 12                	jne    801895 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	6a 02                	push   $0x2
  801888:	e8 8b f5 ff ff       	call   800e18 <ipc_find_env>
  80188d:	a3 04 40 80 00       	mov    %eax,0x804004
  801892:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801895:	6a 07                	push   $0x7
  801897:	68 00 60 80 00       	push   $0x806000
  80189c:	53                   	push   %ebx
  80189d:	ff 35 04 40 80 00    	pushl  0x804004
  8018a3:	e8 1c f5 ff ff       	call   800dc4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018a8:	83 c4 0c             	add    $0xc,%esp
  8018ab:	6a 00                	push   $0x0
  8018ad:	6a 00                	push   $0x0
  8018af:	6a 00                	push   $0x0
  8018b1:	e8 a1 f4 ff ff       	call   800d57 <ipc_recv>
}
  8018b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018cb:	8b 06                	mov    (%esi),%eax
  8018cd:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d7:	e8 95 ff ff ff       	call   801871 <nsipc>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 20                	js     801902 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	ff 35 10 60 80 00    	pushl  0x806010
  8018eb:	68 00 60 80 00       	push   $0x806000
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	e8 bd ef ff ff       	call   8008b5 <memmove>
		*addrlen = ret->ret_addrlen;
  8018f8:	a1 10 60 80 00       	mov    0x806010,%eax
  8018fd:	89 06                	mov    %eax,(%esi)
  8018ff:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801902:	89 d8                	mov    %ebx,%eax
  801904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801907:	5b                   	pop    %ebx
  801908:	5e                   	pop    %esi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80191d:	53                   	push   %ebx
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	68 04 60 80 00       	push   $0x806004
  801926:	e8 8a ef ff ff       	call   8008b5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80192b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801931:	b8 02 00 00 00       	mov    $0x2,%eax
  801936:	e8 36 ff ff ff       	call   801871 <nsipc>
}
  80193b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801956:	b8 03 00 00 00       	mov    $0x3,%eax
  80195b:	e8 11 ff ff ff       	call   801871 <nsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <nsipc_close>:

int
nsipc_close(int s)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801970:	b8 04 00 00 00       	mov    $0x4,%eax
  801975:	e8 f7 fe ff ff       	call   801871 <nsipc>
}
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80198e:	53                   	push   %ebx
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	68 04 60 80 00       	push   $0x806004
  801997:	e8 19 ef ff ff       	call   8008b5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80199c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8019a7:	e8 c5 fe ff ff       	call   801871 <nsipc>
}
  8019ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8019cc:	e8 a0 fe ff ff       	call   801871 <nsipc>
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
  8019d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019e3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ec:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019f1:	b8 07 00 00 00       	mov    $0x7,%eax
  8019f6:	e8 76 fe ff ff       	call   801871 <nsipc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 35                	js     801a36 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a01:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a06:	7f 04                	jg     801a0c <nsipc_recv+0x39>
  801a08:	39 c6                	cmp    %eax,%esi
  801a0a:	7d 16                	jge    801a22 <nsipc_recv+0x4f>
  801a0c:	68 1b 27 80 00       	push   $0x80271b
  801a11:	68 e3 26 80 00       	push   $0x8026e3
  801a16:	6a 62                	push   $0x62
  801a18:	68 30 27 80 00       	push   $0x802730
  801a1d:	e8 84 05 00 00       	call   801fa6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a22:	83 ec 04             	sub    $0x4,%esp
  801a25:	50                   	push   %eax
  801a26:	68 00 60 80 00       	push   $0x806000
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	e8 82 ee ff ff       	call   8008b5 <memmove>
  801a33:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a36:	89 d8                	mov    %ebx,%eax
  801a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	53                   	push   %ebx
  801a43:	83 ec 04             	sub    $0x4,%esp
  801a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a51:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a57:	7e 16                	jle    801a6f <nsipc_send+0x30>
  801a59:	68 3c 27 80 00       	push   $0x80273c
  801a5e:	68 e3 26 80 00       	push   $0x8026e3
  801a63:	6a 6d                	push   $0x6d
  801a65:	68 30 27 80 00       	push   $0x802730
  801a6a:	e8 37 05 00 00       	call   801fa6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a6f:	83 ec 04             	sub    $0x4,%esp
  801a72:	53                   	push   %ebx
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	68 0c 60 80 00       	push   $0x80600c
  801a7b:	e8 35 ee ff ff       	call   8008b5 <memmove>
	nsipcbuf.send.req_size = size;
  801a80:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a86:	8b 45 14             	mov    0x14(%ebp),%eax
  801a89:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a8e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a93:	e8 d9 fd ff ff       	call   801871 <nsipc>
}
  801a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aae:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801abb:	b8 09 00 00 00       	mov    $0x9,%eax
  801ac0:	e8 ac fd ff ff       	call   801871 <nsipc>
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 08             	pushl  0x8(%ebp)
  801ad5:	e8 87 f3 ff ff       	call   800e61 <fd2data>
  801ada:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801adc:	83 c4 08             	add    $0x8,%esp
  801adf:	68 48 27 80 00       	push   $0x802748
  801ae4:	53                   	push   %ebx
  801ae5:	e8 39 ec ff ff       	call   800723 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aea:	8b 46 04             	mov    0x4(%esi),%eax
  801aed:	2b 06                	sub    (%esi),%eax
  801aef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801af5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801afc:	00 00 00 
	stat->st_dev = &devpipe;
  801aff:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b06:	30 80 00 
	return 0;
}
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b1f:	53                   	push   %ebx
  801b20:	6a 00                	push   $0x0
  801b22:	e8 84 f0 ff ff       	call   800bab <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b27:	89 1c 24             	mov    %ebx,(%esp)
  801b2a:	e8 32 f3 ff ff       	call   800e61 <fd2data>
  801b2f:	83 c4 08             	add    $0x8,%esp
  801b32:	50                   	push   %eax
  801b33:	6a 00                	push   $0x0
  801b35:	e8 71 f0 ff ff       	call   800bab <sys_page_unmap>
}
  801b3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	57                   	push   %edi
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 1c             	sub    $0x1c,%esp
  801b48:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b4b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b4d:	a1 08 40 80 00       	mov    0x804008,%eax
  801b52:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 e0             	pushl  -0x20(%ebp)
  801b5b:	e8 8c 04 00 00       	call   801fec <pageref>
  801b60:	89 c3                	mov    %eax,%ebx
  801b62:	89 3c 24             	mov    %edi,(%esp)
  801b65:	e8 82 04 00 00       	call   801fec <pageref>
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	39 c3                	cmp    %eax,%ebx
  801b6f:	0f 94 c1             	sete   %cl
  801b72:	0f b6 c9             	movzbl %cl,%ecx
  801b75:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b78:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b7e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b81:	39 ce                	cmp    %ecx,%esi
  801b83:	74 1b                	je     801ba0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b85:	39 c3                	cmp    %eax,%ebx
  801b87:	75 c4                	jne    801b4d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b89:	8b 42 58             	mov    0x58(%edx),%eax
  801b8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8f:	50                   	push   %eax
  801b90:	56                   	push   %esi
  801b91:	68 4f 27 80 00       	push   $0x80274f
  801b96:	e8 03 e6 ff ff       	call   80019e <cprintf>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	eb ad                	jmp    801b4d <_pipeisclosed+0xe>
	}
}
  801ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba6:	5b                   	pop    %ebx
  801ba7:	5e                   	pop    %esi
  801ba8:	5f                   	pop    %edi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 28             	sub    $0x28,%esp
  801bb4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bb7:	56                   	push   %esi
  801bb8:	e8 a4 f2 ff ff       	call   800e61 <fd2data>
  801bbd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801bc7:	eb 4b                	jmp    801c14 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bc9:	89 da                	mov    %ebx,%edx
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	e8 6d ff ff ff       	call   801b3f <_pipeisclosed>
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	75 48                	jne    801c1e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bd6:	e8 2c ef ff ff       	call   800b07 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bdb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bde:	8b 0b                	mov    (%ebx),%ecx
  801be0:	8d 51 20             	lea    0x20(%ecx),%edx
  801be3:	39 d0                	cmp    %edx,%eax
  801be5:	73 e2                	jae    801bc9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bf1:	89 c2                	mov    %eax,%edx
  801bf3:	c1 fa 1f             	sar    $0x1f,%edx
  801bf6:	89 d1                	mov    %edx,%ecx
  801bf8:	c1 e9 1b             	shr    $0x1b,%ecx
  801bfb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bfe:	83 e2 1f             	and    $0x1f,%edx
  801c01:	29 ca                	sub    %ecx,%edx
  801c03:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c07:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c0b:	83 c0 01             	add    $0x1,%eax
  801c0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c11:	83 c7 01             	add    $0x1,%edi
  801c14:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c17:	75 c2                	jne    801bdb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c19:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1c:	eb 05                	jmp    801c23 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	57                   	push   %edi
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 18             	sub    $0x18,%esp
  801c34:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c37:	57                   	push   %edi
  801c38:	e8 24 f2 ff ff       	call   800e61 <fd2data>
  801c3d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c47:	eb 3d                	jmp    801c86 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c49:	85 db                	test   %ebx,%ebx
  801c4b:	74 04                	je     801c51 <devpipe_read+0x26>
				return i;
  801c4d:	89 d8                	mov    %ebx,%eax
  801c4f:	eb 44                	jmp    801c95 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c51:	89 f2                	mov    %esi,%edx
  801c53:	89 f8                	mov    %edi,%eax
  801c55:	e8 e5 fe ff ff       	call   801b3f <_pipeisclosed>
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	75 32                	jne    801c90 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c5e:	e8 a4 ee ff ff       	call   800b07 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c63:	8b 06                	mov    (%esi),%eax
  801c65:	3b 46 04             	cmp    0x4(%esi),%eax
  801c68:	74 df                	je     801c49 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c6a:	99                   	cltd   
  801c6b:	c1 ea 1b             	shr    $0x1b,%edx
  801c6e:	01 d0                	add    %edx,%eax
  801c70:	83 e0 1f             	and    $0x1f,%eax
  801c73:	29 d0                	sub    %edx,%eax
  801c75:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c80:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c83:	83 c3 01             	add    $0x1,%ebx
  801c86:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c89:	75 d8                	jne    801c63 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8e:	eb 05                	jmp    801c95 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5f                   	pop    %edi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	e8 ca f1 ff ff       	call   800e78 <fd_alloc>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 2c 01 00 00    	js     801de7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	68 07 04 00 00       	push   $0x407
  801cc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 59 ee ff ff       	call   800b26 <sys_page_alloc>
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 0d 01 00 00    	js     801de7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce0:	50                   	push   %eax
  801ce1:	e8 92 f1 ff ff       	call   800e78 <fd_alloc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	0f 88 e2 00 00 00    	js     801dd5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf3:	83 ec 04             	sub    $0x4,%esp
  801cf6:	68 07 04 00 00       	push   $0x407
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 21 ee ff ff       	call   800b26 <sys_page_alloc>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	0f 88 c3 00 00 00    	js     801dd5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	ff 75 f4             	pushl  -0xc(%ebp)
  801d18:	e8 44 f1 ff ff       	call   800e61 <fd2data>
  801d1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1f:	83 c4 0c             	add    $0xc,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	50                   	push   %eax
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 f7 ed ff ff       	call   800b26 <sys_page_alloc>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	0f 88 89 00 00 00    	js     801dc5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d42:	e8 1a f1 ff ff       	call   800e61 <fd2data>
  801d47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d4e:	50                   	push   %eax
  801d4f:	6a 00                	push   $0x0
  801d51:	56                   	push   %esi
  801d52:	6a 00                	push   $0x0
  801d54:	e8 10 ee ff ff       	call   800b69 <sys_page_map>
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	83 c4 20             	add    $0x20,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 55                	js     801db7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d77:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d80:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d8c:	83 ec 0c             	sub    $0xc,%esp
  801d8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d92:	e8 ba f0 ff ff       	call   800e51 <fd2num>
  801d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d9c:	83 c4 04             	add    $0x4,%esp
  801d9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801da2:	e8 aa f0 ff ff       	call   800e51 <fd2num>
  801da7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801daa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	ba 00 00 00 00       	mov    $0x0,%edx
  801db5:	eb 30                	jmp    801de7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801db7:	83 ec 08             	sub    $0x8,%esp
  801dba:	56                   	push   %esi
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 e9 ed ff ff       	call   800bab <sys_page_unmap>
  801dc2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc5:	83 ec 08             	sub    $0x8,%esp
  801dc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 d9 ed ff ff       	call   800bab <sys_page_unmap>
  801dd2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd5:	83 ec 08             	sub    $0x8,%esp
  801dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 c9 ed ff ff       	call   800bab <sys_page_unmap>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801de7:	89 d0                	mov    %edx,%eax
  801de9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df9:	50                   	push   %eax
  801dfa:	ff 75 08             	pushl  0x8(%ebp)
  801dfd:	e8 c5 f0 ff ff       	call   800ec7 <fd_lookup>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 18                	js     801e21 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0f:	e8 4d f0 ff ff       	call   800e61 <fd2data>
	return _pipeisclosed(fd, p);
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e19:	e8 21 fd ff ff       	call   801b3f <_pipeisclosed>
  801e1e:	83 c4 10             	add    $0x10,%esp
}
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e26:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e33:	68 67 27 80 00       	push   $0x802767
  801e38:	ff 75 0c             	pushl  0xc(%ebp)
  801e3b:	e8 e3 e8 ff ff       	call   800723 <strcpy>
	return 0;
}
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	57                   	push   %edi
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e53:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e58:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5e:	eb 2d                	jmp    801e8d <devcons_write+0x46>
		m = n - tot;
  801e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e63:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e65:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e68:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e6d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	53                   	push   %ebx
  801e74:	03 45 0c             	add    0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	57                   	push   %edi
  801e79:	e8 37 ea ff ff       	call   8008b5 <memmove>
		sys_cputs(buf, m);
  801e7e:	83 c4 08             	add    $0x8,%esp
  801e81:	53                   	push   %ebx
  801e82:	57                   	push   %edi
  801e83:	e8 e2 eb ff ff       	call   800a6a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e88:	01 de                	add    %ebx,%esi
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	89 f0                	mov    %esi,%eax
  801e8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e92:	72 cc                	jb     801e60 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ea7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eab:	74 2a                	je     801ed7 <devcons_read+0x3b>
  801ead:	eb 05                	jmp    801eb4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eaf:	e8 53 ec ff ff       	call   800b07 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb4:	e8 cf eb ff ff       	call   800a88 <sys_cgetc>
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	74 f2                	je     801eaf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 16                	js     801ed7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec1:	83 f8 04             	cmp    $0x4,%eax
  801ec4:	74 0c                	je     801ed2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ec6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec9:	88 02                	mov    %al,(%edx)
	return 1;
  801ecb:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed0:	eb 05                	jmp    801ed7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ee5:	6a 01                	push   $0x1
  801ee7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eea:	50                   	push   %eax
  801eeb:	e8 7a eb ff ff       	call   800a6a <sys_cputs>
}
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <getchar>:

int
getchar(void)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801efb:	6a 01                	push   $0x1
  801efd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f00:	50                   	push   %eax
  801f01:	6a 00                	push   $0x0
  801f03:	e8 25 f2 ff ff       	call   80112d <read>
	if (r < 0)
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 0f                	js     801f1e <getchar+0x29>
		return r;
	if (r < 1)
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	7e 06                	jle    801f19 <getchar+0x24>
		return -E_EOF;
	return c;
  801f13:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f17:	eb 05                	jmp    801f1e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f19:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	ff 75 08             	pushl  0x8(%ebp)
  801f2d:	e8 95 ef ff ff       	call   800ec7 <fd_lookup>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 11                	js     801f4a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f42:	39 10                	cmp    %edx,(%eax)
  801f44:	0f 94 c0             	sete   %al
  801f47:	0f b6 c0             	movzbl %al,%eax
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <opencons>:

int
opencons(void)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	e8 1d ef ff ff       	call   800e78 <fd_alloc>
  801f5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 3e                	js     801fa2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f64:	83 ec 04             	sub    $0x4,%esp
  801f67:	68 07 04 00 00       	push   $0x407
  801f6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 b0 eb ff ff       	call   800b26 <sys_page_alloc>
  801f76:	83 c4 10             	add    $0x10,%esp
		return r;
  801f79:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	78 23                	js     801fa2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f7f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f88:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	50                   	push   %eax
  801f98:	e8 b4 ee ff ff       	call   800e51 <fd2num>
  801f9d:	89 c2                	mov    %eax,%edx
  801f9f:	83 c4 10             	add    $0x10,%esp
}
  801fa2:	89 d0                	mov    %edx,%eax
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fab:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fae:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fb4:	e8 2f eb ff ff       	call   800ae8 <sys_getenvid>
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 0c             	pushl  0xc(%ebp)
  801fbf:	ff 75 08             	pushl  0x8(%ebp)
  801fc2:	56                   	push   %esi
  801fc3:	50                   	push   %eax
  801fc4:	68 74 27 80 00       	push   $0x802774
  801fc9:	e8 d0 e1 ff ff       	call   80019e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fce:	83 c4 18             	add    $0x18,%esp
  801fd1:	53                   	push   %ebx
  801fd2:	ff 75 10             	pushl  0x10(%ebp)
  801fd5:	e8 73 e1 ff ff       	call   80014d <vcprintf>
	cprintf("\n");
  801fda:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  801fe1:	e8 b8 e1 ff ff       	call   80019e <cprintf>
  801fe6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fe9:	cc                   	int3   
  801fea:	eb fd                	jmp    801fe9 <_panic+0x43>

00801fec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	c1 e8 16             	shr    $0x16,%eax
  801ff7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802003:	f6 c1 01             	test   $0x1,%cl
  802006:	74 1d                	je     802025 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802008:	c1 ea 0c             	shr    $0xc,%edx
  80200b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802012:	f6 c2 01             	test   $0x1,%dl
  802015:	74 0e                	je     802025 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802017:	c1 ea 0c             	shr    $0xc,%edx
  80201a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802021:	ef 
  802022:	0f b7 c0             	movzwl %ax,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
