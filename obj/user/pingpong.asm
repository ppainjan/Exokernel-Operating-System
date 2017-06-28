
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 2d 0e 00 00       	call   800e6e <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 b6 0a 00 00       	call   800b05 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 80 26 80 00       	push   $0x802680
  800059:	e8 5d 01 00 00       	call   8001bb <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 84 10 00 00       	call   8010f0 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 04 10 00 00       	call   801083 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 7c 0a 00 00       	call   800b05 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 96 26 80 00       	push   $0x802696
  800091:	e8 25 01 00 00       	call   8001bb <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 42 10 00 00       	call   8010f0 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c9:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000d0:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d3:	e8 2d 0a 00 00       	call   800b05 <sys_getenvid>
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e5:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ea:	85 db                	test   %ebx,%ebx
  8000ec:	7e 07                	jle    8000f5 <libmain+0x37>
		binaryname = argv[0];
  8000ee:	8b 06                	mov    (%esi),%eax
  8000f0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	e8 34 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 0a 00 00 00       	call   80010e <exit>
}
  800104:	83 c4 10             	add    $0x10,%esp
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800114:	e8 2f 12 00 00       	call   801348 <close_all>
	sys_env_destroy(0);
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	6a 00                	push   $0x0
  80011e:	e8 a1 09 00 00       	call   800ac4 <sys_env_destroy>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 04             	sub    $0x4,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 13                	mov    (%ebx),%edx
  800134:	8d 42 01             	lea    0x1(%edx),%eax
  800137:	89 03                	mov    %eax,(%ebx)
  800139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	75 1a                	jne    800161 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	68 ff 00 00 00       	push   $0xff
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	50                   	push   %eax
  800153:	e8 2f 09 00 00       	call   800a87 <sys_cputs>
		b->idx = 0;
  800158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800161:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800165:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800173:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017a:	00 00 00 
	b.cnt = 0;
  80017d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800184:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800187:	ff 75 0c             	pushl  0xc(%ebp)
  80018a:	ff 75 08             	pushl  0x8(%ebp)
  80018d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800193:	50                   	push   %eax
  800194:	68 28 01 80 00       	push   $0x800128
  800199:	e8 54 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019e:	83 c4 08             	add    $0x8,%esp
  8001a1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 d4 08 00 00       	call   800a87 <sys_cputs>

	return b.cnt;
}
  8001b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c4:	50                   	push   %eax
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	e8 9d ff ff ff       	call   80016a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 1c             	sub    $0x1c,%esp
  8001d8:	89 c7                	mov    %eax,%edi
  8001da:	89 d6                	mov    %edx,%esi
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f6:	39 d3                	cmp    %edx,%ebx
  8001f8:	72 05                	jb     8001ff <printnum+0x30>
  8001fa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fd:	77 45                	ja     800244 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	ff 75 18             	pushl  0x18(%ebp)
  800205:	8b 45 14             	mov    0x14(%ebp),%eax
  800208:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020b:	53                   	push   %ebx
  80020c:	ff 75 10             	pushl  0x10(%ebp)
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	ff 75 e4             	pushl  -0x1c(%ebp)
  800215:	ff 75 e0             	pushl  -0x20(%ebp)
  800218:	ff 75 dc             	pushl  -0x24(%ebp)
  80021b:	ff 75 d8             	pushl  -0x28(%ebp)
  80021e:	e8 cd 21 00 00       	call   8023f0 <__udivdi3>
  800223:	83 c4 18             	add    $0x18,%esp
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	89 f2                	mov    %esi,%edx
  80022a:	89 f8                	mov    %edi,%eax
  80022c:	e8 9e ff ff ff       	call   8001cf <printnum>
  800231:	83 c4 20             	add    $0x20,%esp
  800234:	eb 18                	jmp    80024e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	ff 75 18             	pushl  0x18(%ebp)
  80023d:	ff d7                	call   *%edi
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	eb 03                	jmp    800247 <printnum+0x78>
  800244:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	83 eb 01             	sub    $0x1,%ebx
  80024a:	85 db                	test   %ebx,%ebx
  80024c:	7f e8                	jg     800236 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	83 ec 04             	sub    $0x4,%esp
  800255:	ff 75 e4             	pushl  -0x1c(%ebp)
  800258:	ff 75 e0             	pushl  -0x20(%ebp)
  80025b:	ff 75 dc             	pushl  -0x24(%ebp)
  80025e:	ff 75 d8             	pushl  -0x28(%ebp)
  800261:	e8 ba 22 00 00       	call   802520 <__umoddi3>
  800266:	83 c4 14             	add    $0x14,%esp
  800269:	0f be 80 b3 26 80 00 	movsbl 0x8026b3(%eax),%eax
  800270:	50                   	push   %eax
  800271:	ff d7                	call   *%edi
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x38>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c7:	73 0a                	jae    8002d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	88 02                	mov    %al,(%edx)
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002de:	50                   	push   %eax
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	e8 05 00 00 00       	call   8002f2 <vprintfmt>
	va_end(ap);
}
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 2c             	sub    $0x2c,%esp
  8002fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800301:	8b 7d 10             	mov    0x10(%ebp),%edi
  800304:	eb 12                	jmp    800318 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800306:	85 c0                	test   %eax,%eax
  800308:	0f 84 89 03 00 00    	je     800697 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	53                   	push   %ebx
  800312:	50                   	push   %eax
  800313:	ff d6                	call   *%esi
  800315:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800318:	83 c7 01             	add    $0x1,%edi
  80031b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031f:	83 f8 25             	cmp    $0x25,%eax
  800322:	75 e2                	jne    800306 <vprintfmt+0x14>
  800324:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800328:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800336:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 07                	jmp    80034b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800347:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8d 47 01             	lea    0x1(%edi),%eax
  80034e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800351:	0f b6 07             	movzbl (%edi),%eax
  800354:	0f b6 c8             	movzbl %al,%ecx
  800357:	83 e8 23             	sub    $0x23,%eax
  80035a:	3c 55                	cmp    $0x55,%al
  80035c:	0f 87 1a 03 00 00    	ja     80067c <vprintfmt+0x38a>
  800362:	0f b6 c0             	movzbl %al,%eax
  800365:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800373:	eb d6                	jmp    80034b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800380:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800383:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800387:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80038a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80038d:	83 fa 09             	cmp    $0x9,%edx
  800390:	77 39                	ja     8003cb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800392:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800395:	eb e9                	jmp    800380 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 48 04             	lea    0x4(%eax),%ecx
  80039d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a8:	eb 27                	jmp    8003d1 <vprintfmt+0xdf>
  8003aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	0f 49 c8             	cmovns %eax,%ecx
  8003b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	eb 8c                	jmp    80034b <vprintfmt+0x59>
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c9:	eb 80                	jmp    80034b <vprintfmt+0x59>
  8003cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ce:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	0f 89 70 ff ff ff    	jns    80034b <vprintfmt+0x59>
				width = precision, precision = -1;
  8003db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	e9 5e ff ff ff       	jmp    80034b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ed:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f3:	e9 53 ff ff ff       	jmp    80034b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	53                   	push   %ebx
  800405:	ff 30                	pushl  (%eax)
  800407:	ff d6                	call   *%esi
			break;
  800409:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040f:	e9 04 ff ff ff       	jmp    800318 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	99                   	cltd   
  800420:	31 d0                	xor    %edx,%eax
  800422:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800424:	83 f8 0f             	cmp    $0xf,%eax
  800427:	7f 0b                	jg     800434 <vprintfmt+0x142>
  800429:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800430:	85 d2                	test   %edx,%edx
  800432:	75 18                	jne    80044c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800434:	50                   	push   %eax
  800435:	68 cb 26 80 00       	push   $0x8026cb
  80043a:	53                   	push   %ebx
  80043b:	56                   	push   %esi
  80043c:	e8 94 fe ff ff       	call   8002d5 <printfmt>
  800441:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800447:	e9 cc fe ff ff       	jmp    800318 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044c:	52                   	push   %edx
  80044d:	68 11 2c 80 00       	push   $0x802c11
  800452:	53                   	push   %ebx
  800453:	56                   	push   %esi
  800454:	e8 7c fe ff ff       	call   8002d5 <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045f:	e9 b4 fe ff ff       	jmp    800318 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046f:	85 ff                	test   %edi,%edi
  800471:	b8 c4 26 80 00       	mov    $0x8026c4,%eax
  800476:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800479:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047d:	0f 8e 94 00 00 00    	jle    800517 <vprintfmt+0x225>
  800483:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800487:	0f 84 98 00 00 00    	je     800525 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 d0             	pushl  -0x30(%ebp)
  800493:	57                   	push   %edi
  800494:	e8 86 02 00 00       	call   80071f <strnlen>
  800499:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049c:	29 c1                	sub    %eax,%ecx
  80049e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ae:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	eb 0f                	jmp    8004c1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 ef 01             	sub    $0x1,%edi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 ff                	test   %edi,%edi
  8004c3:	7f ed                	jg     8004b2 <vprintfmt+0x1c0>
  8004c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004cb:	85 c9                	test   %ecx,%ecx
  8004cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d2:	0f 49 c1             	cmovns %ecx,%eax
  8004d5:	29 c1                	sub    %eax,%ecx
  8004d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e0:	89 cb                	mov    %ecx,%ebx
  8004e2:	eb 4d                	jmp    800531 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e8:	74 1b                	je     800505 <vprintfmt+0x213>
  8004ea:	0f be c0             	movsbl %al,%eax
  8004ed:	83 e8 20             	sub    $0x20,%eax
  8004f0:	83 f8 5e             	cmp    $0x5e,%eax
  8004f3:	76 10                	jbe    800505 <vprintfmt+0x213>
					putch('?', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	6a 3f                	push   $0x3f
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	eb 0d                	jmp    800512 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	52                   	push   %edx
  80050c:	ff 55 08             	call   *0x8(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800512:	83 eb 01             	sub    $0x1,%ebx
  800515:	eb 1a                	jmp    800531 <vprintfmt+0x23f>
  800517:	89 75 08             	mov    %esi,0x8(%ebp)
  80051a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800520:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800523:	eb 0c                	jmp    800531 <vprintfmt+0x23f>
  800525:	89 75 08             	mov    %esi,0x8(%ebp)
  800528:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800531:	83 c7 01             	add    $0x1,%edi
  800534:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800538:	0f be d0             	movsbl %al,%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 23                	je     800562 <vprintfmt+0x270>
  80053f:	85 f6                	test   %esi,%esi
  800541:	78 a1                	js     8004e4 <vprintfmt+0x1f2>
  800543:	83 ee 01             	sub    $0x1,%esi
  800546:	79 9c                	jns    8004e4 <vprintfmt+0x1f2>
  800548:	89 df                	mov    %ebx,%edi
  80054a:	8b 75 08             	mov    0x8(%ebp),%esi
  80054d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800550:	eb 18                	jmp    80056a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	53                   	push   %ebx
  800556:	6a 20                	push   $0x20
  800558:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055a:	83 ef 01             	sub    $0x1,%edi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb 08                	jmp    80056a <vprintfmt+0x278>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f e4                	jg     800552 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800571:	e9 a2 fd ff ff       	jmp    800318 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800576:	83 fa 01             	cmp    $0x1,%edx
  800579:	7e 16                	jle    800591 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 08             	lea    0x8(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 50 04             	mov    0x4(%eax),%edx
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	eb 32                	jmp    8005c3 <vprintfmt+0x2d1>
	else if (lflag)
  800591:	85 d2                	test   %edx,%edx
  800593:	74 18                	je     8005ad <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	89 c1                	mov    %eax,%ecx
  8005a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ab:	eb 16                	jmp    8005c3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	89 c1                	mov    %eax,%ecx
  8005bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d2:	79 74                	jns    800648 <vprintfmt+0x356>
				putch('-', putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 2d                	push   $0x2d
  8005da:	ff d6                	call   *%esi
				num = -(long long) num;
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e2:	f7 d8                	neg    %eax
  8005e4:	83 d2 00             	adc    $0x0,%edx
  8005e7:	f7 da                	neg    %edx
  8005e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f1:	eb 55                	jmp    800648 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 83 fc ff ff       	call   80027e <getuint>
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800600:	eb 46                	jmp    800648 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 74 fc ff ff       	call   80027e <getuint>
		        base = 8;
  80060a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80060f:	eb 37                	jmp    800648 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 30                	push   $0x30
  800617:	ff d6                	call   *%esi
			putch('x', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 78                	push   $0x78
  80061f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800631:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800634:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 3b fc ff ff       	call   80027e <getuint>
			base = 16;
  800643:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064f:	57                   	push   %edi
  800650:	ff 75 e0             	pushl  -0x20(%ebp)
  800653:	51                   	push   %ecx
  800654:	52                   	push   %edx
  800655:	50                   	push   %eax
  800656:	89 da                	mov    %ebx,%edx
  800658:	89 f0                	mov    %esi,%eax
  80065a:	e8 70 fb ff ff       	call   8001cf <printnum>
			break;
  80065f:	83 c4 20             	add    $0x20,%esp
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800665:	e9 ae fc ff ff       	jmp    800318 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	51                   	push   %ecx
  80066f:	ff d6                	call   *%esi
			break;
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800677:	e9 9c fc ff ff       	jmp    800318 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 25                	push   $0x25
  800682:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	eb 03                	jmp    80068c <vprintfmt+0x39a>
  800689:	83 ef 01             	sub    $0x1,%edi
  80068c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800690:	75 f7                	jne    800689 <vprintfmt+0x397>
  800692:	e9 81 fc ff ff       	jmp    800318 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800697:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069a:	5b                   	pop    %ebx
  80069b:	5e                   	pop    %esi
  80069c:	5f                   	pop    %edi
  80069d:	5d                   	pop    %ebp
  80069e:	c3                   	ret    

0080069f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	83 ec 18             	sub    $0x18,%esp
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 26                	je     8006e6 <vsnprintf+0x47>
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	7e 22                	jle    8006e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c4:	ff 75 14             	pushl  0x14(%ebp)
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	68 b8 02 80 00       	push   $0x8002b8
  8006d3:	e8 1a fc ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 05                	jmp    8006eb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    

008006ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f6:	50                   	push   %eax
  8006f7:	ff 75 10             	pushl  0x10(%ebp)
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	ff 75 08             	pushl  0x8(%ebp)
  800700:	e8 9a ff ff ff       	call   80069f <vsnprintf>
	va_end(ap);

	return rc;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	b8 00 00 00 00       	mov    $0x0,%eax
  800712:	eb 03                	jmp    800717 <strlen+0x10>
		n++;
  800714:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800717:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071b:	75 f7                	jne    800714 <strlen+0xd>
		n++;
	return n;
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800725:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	ba 00 00 00 00       	mov    $0x0,%edx
  80072d:	eb 03                	jmp    800732 <strnlen+0x13>
		n++;
  80072f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800732:	39 c2                	cmp    %eax,%edx
  800734:	74 08                	je     80073e <strnlen+0x1f>
  800736:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073a:	75 f3                	jne    80072f <strnlen+0x10>
  80073c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074a:	89 c2                	mov    %eax,%edx
  80074c:	83 c2 01             	add    $0x1,%edx
  80074f:	83 c1 01             	add    $0x1,%ecx
  800752:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800756:	88 5a ff             	mov    %bl,-0x1(%edx)
  800759:	84 db                	test   %bl,%bl
  80075b:	75 ef                	jne    80074c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80075d:	5b                   	pop    %ebx
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800767:	53                   	push   %ebx
  800768:	e8 9a ff ff ff       	call   800707 <strlen>
  80076d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	01 d8                	add    %ebx,%eax
  800775:	50                   	push   %eax
  800776:	e8 c5 ff ff ff       	call   800740 <strcpy>
	return dst;
}
  80077b:	89 d8                	mov    %ebx,%eax
  80077d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	56                   	push   %esi
  800786:	53                   	push   %ebx
  800787:	8b 75 08             	mov    0x8(%ebp),%esi
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078d:	89 f3                	mov    %esi,%ebx
  80078f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800792:	89 f2                	mov    %esi,%edx
  800794:	eb 0f                	jmp    8007a5 <strncpy+0x23>
		*dst++ = *src;
  800796:	83 c2 01             	add    $0x1,%edx
  800799:	0f b6 01             	movzbl (%ecx),%eax
  80079c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079f:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a5:	39 da                	cmp    %ebx,%edx
  8007a7:	75 ed                	jne    800796 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a9:	89 f0                	mov    %esi,%eax
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8007bd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 21                	je     8007e4 <strlcpy+0x35>
  8007c3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	eb 09                	jmp    8007d4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007cb:	83 c2 01             	add    $0x1,%edx
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d4:	39 c2                	cmp    %eax,%edx
  8007d6:	74 09                	je     8007e1 <strlcpy+0x32>
  8007d8:	0f b6 19             	movzbl (%ecx),%ebx
  8007db:	84 db                	test   %bl,%bl
  8007dd:	75 ec                	jne    8007cb <strlcpy+0x1c>
  8007df:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e4:	29 f0                	sub    %esi,%eax
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f3:	eb 06                	jmp    8007fb <strcmp+0x11>
		p++, q++;
  8007f5:	83 c1 01             	add    $0x1,%ecx
  8007f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fb:	0f b6 01             	movzbl (%ecx),%eax
  8007fe:	84 c0                	test   %al,%al
  800800:	74 04                	je     800806 <strcmp+0x1c>
  800802:	3a 02                	cmp    (%edx),%al
  800804:	74 ef                	je     8007f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800806:	0f b6 c0             	movzbl %al,%eax
  800809:	0f b6 12             	movzbl (%edx),%edx
  80080c:	29 d0                	sub    %edx,%eax
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	89 c3                	mov    %eax,%ebx
  80081c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081f:	eb 06                	jmp    800827 <strncmp+0x17>
		n--, p++, q++;
  800821:	83 c0 01             	add    $0x1,%eax
  800824:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800827:	39 d8                	cmp    %ebx,%eax
  800829:	74 15                	je     800840 <strncmp+0x30>
  80082b:	0f b6 08             	movzbl (%eax),%ecx
  80082e:	84 c9                	test   %cl,%cl
  800830:	74 04                	je     800836 <strncmp+0x26>
  800832:	3a 0a                	cmp    (%edx),%cl
  800834:	74 eb                	je     800821 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	0f b6 00             	movzbl (%eax),%eax
  800839:	0f b6 12             	movzbl (%edx),%edx
  80083c:	29 d0                	sub    %edx,%eax
  80083e:	eb 05                	jmp    800845 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800845:	5b                   	pop    %ebx
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800852:	eb 07                	jmp    80085b <strchr+0x13>
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 0f                	je     800867 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	0f b6 10             	movzbl (%eax),%edx
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f2                	jne    800854 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800873:	eb 03                	jmp    800878 <strfind+0xf>
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087b:	38 ca                	cmp    %cl,%dl
  80087d:	74 04                	je     800883 <strfind+0x1a>
  80087f:	84 d2                	test   %dl,%dl
  800881:	75 f2                	jne    800875 <strfind+0xc>
			break;
	return (char *) s;
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	57                   	push   %edi
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800891:	85 c9                	test   %ecx,%ecx
  800893:	74 36                	je     8008cb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800895:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089b:	75 28                	jne    8008c5 <memset+0x40>
  80089d:	f6 c1 03             	test   $0x3,%cl
  8008a0:	75 23                	jne    8008c5 <memset+0x40>
		c &= 0xFF;
  8008a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a6:	89 d3                	mov    %edx,%ebx
  8008a8:	c1 e3 08             	shl    $0x8,%ebx
  8008ab:	89 d6                	mov    %edx,%esi
  8008ad:	c1 e6 18             	shl    $0x18,%esi
  8008b0:	89 d0                	mov    %edx,%eax
  8008b2:	c1 e0 10             	shl    $0x10,%eax
  8008b5:	09 f0                	or     %esi,%eax
  8008b7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b9:	89 d8                	mov    %ebx,%eax
  8008bb:	09 d0                	or     %edx,%eax
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fc                   	cld    
  8008c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c3:	eb 06                	jmp    8008cb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	fc                   	cld    
  8008c9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008cb:	89 f8                	mov    %edi,%eax
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	5f                   	pop    %edi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e0:	39 c6                	cmp    %eax,%esi
  8008e2:	73 35                	jae    800919 <memmove+0x47>
  8008e4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e7:	39 d0                	cmp    %edx,%eax
  8008e9:	73 2e                	jae    800919 <memmove+0x47>
		s += n;
		d += n;
  8008eb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	09 fe                	or     %edi,%esi
  8008f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f8:	75 13                	jne    80090d <memmove+0x3b>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0e                	jne    80090d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ff:	83 ef 04             	sub    $0x4,%edi
  800902:	8d 72 fc             	lea    -0x4(%edx),%esi
  800905:	c1 e9 02             	shr    $0x2,%ecx
  800908:	fd                   	std    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 09                	jmp    800916 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80090d:	83 ef 01             	sub    $0x1,%edi
  800910:	8d 72 ff             	lea    -0x1(%edx),%esi
  800913:	fd                   	std    
  800914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800916:	fc                   	cld    
  800917:	eb 1d                	jmp    800936 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800919:	89 f2                	mov    %esi,%edx
  80091b:	09 c2                	or     %eax,%edx
  80091d:	f6 c2 03             	test   $0x3,%dl
  800920:	75 0f                	jne    800931 <memmove+0x5f>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	75 0a                	jne    800931 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800927:	c1 e9 02             	shr    $0x2,%ecx
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092f:	eb 05                	jmp    800936 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800931:	89 c7                	mov    %eax,%edi
  800933:	fc                   	cld    
  800934:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800936:	5e                   	pop    %esi
  800937:	5f                   	pop    %edi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80093d:	ff 75 10             	pushl  0x10(%ebp)
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	ff 75 08             	pushl  0x8(%ebp)
  800946:	e8 87 ff ff ff       	call   8008d2 <memmove>
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 55 0c             	mov    0xc(%ebp),%edx
  800958:	89 c6                	mov    %eax,%esi
  80095a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095d:	eb 1a                	jmp    800979 <memcmp+0x2c>
		if (*s1 != *s2)
  80095f:	0f b6 08             	movzbl (%eax),%ecx
  800962:	0f b6 1a             	movzbl (%edx),%ebx
  800965:	38 d9                	cmp    %bl,%cl
  800967:	74 0a                	je     800973 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800969:	0f b6 c1             	movzbl %cl,%eax
  80096c:	0f b6 db             	movzbl %bl,%ebx
  80096f:	29 d8                	sub    %ebx,%eax
  800971:	eb 0f                	jmp    800982 <memcmp+0x35>
		s1++, s2++;
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800979:	39 f0                	cmp    %esi,%eax
  80097b:	75 e2                	jne    80095f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80098d:	89 c1                	mov    %eax,%ecx
  80098f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800992:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800996:	eb 0a                	jmp    8009a2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800998:	0f b6 10             	movzbl (%eax),%edx
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	74 07                	je     8009a6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099f:	83 c0 01             	add    $0x1,%eax
  8009a2:	39 c8                	cmp    %ecx,%eax
  8009a4:	72 f2                	jb     800998 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b5:	eb 03                	jmp    8009ba <strtol+0x11>
		s++;
  8009b7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	3c 20                	cmp    $0x20,%al
  8009bf:	74 f6                	je     8009b7 <strtol+0xe>
  8009c1:	3c 09                	cmp    $0x9,%al
  8009c3:	74 f2                	je     8009b7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c5:	3c 2b                	cmp    $0x2b,%al
  8009c7:	75 0a                	jne    8009d3 <strtol+0x2a>
		s++;
  8009c9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d1:	eb 11                	jmp    8009e4 <strtol+0x3b>
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d8:	3c 2d                	cmp    $0x2d,%al
  8009da:	75 08                	jne    8009e4 <strtol+0x3b>
		s++, neg = 1;
  8009dc:	83 c1 01             	add    $0x1,%ecx
  8009df:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ea:	75 15                	jne    800a01 <strtol+0x58>
  8009ec:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ef:	75 10                	jne    800a01 <strtol+0x58>
  8009f1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f5:	75 7c                	jne    800a73 <strtol+0xca>
		s += 2, base = 16;
  8009f7:	83 c1 02             	add    $0x2,%ecx
  8009fa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ff:	eb 16                	jmp    800a17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a01:	85 db                	test   %ebx,%ebx
  800a03:	75 12                	jne    800a17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0d:	75 08                	jne    800a17 <strtol+0x6e>
		s++, base = 8;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1f:	0f b6 11             	movzbl (%ecx),%edx
  800a22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 09             	cmp    $0x9,%bl
  800a2a:	77 08                	ja     800a34 <strtol+0x8b>
			dig = *s - '0';
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 30             	sub    $0x30,%edx
  800a32:	eb 22                	jmp    800a56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a37:	89 f3                	mov    %esi,%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3e:	0f be d2             	movsbl %dl,%edx
  800a41:	83 ea 57             	sub    $0x57,%edx
  800a44:	eb 10                	jmp    800a56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a49:	89 f3                	mov    %esi,%ebx
  800a4b:	80 fb 19             	cmp    $0x19,%bl
  800a4e:	77 16                	ja     800a66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a50:	0f be d2             	movsbl %dl,%edx
  800a53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a59:	7d 0b                	jge    800a66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a64:	eb b9                	jmp    800a1f <strtol+0x76>

	if (endptr)
  800a66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6a:	74 0d                	je     800a79 <strtol+0xd0>
		*endptr = (char *) s;
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	89 0e                	mov    %ecx,(%esi)
  800a71:	eb 06                	jmp    800a79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	85 db                	test   %ebx,%ebx
  800a75:	74 98                	je     800a0f <strtol+0x66>
  800a77:	eb 9e                	jmp    800a17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	f7 da                	neg    %edx
  800a7d:	85 ff                	test   %edi,%edi
  800a7f:	0f 45 c2             	cmovne %edx,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a95:	8b 55 08             	mov    0x8(%ebp),%edx
  800a98:	89 c3                	mov    %eax,%ebx
  800a9a:	89 c7                	mov    %eax,%edi
  800a9c:	89 c6                	mov    %eax,%esi
  800a9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_cgetc>:

int
sys_cgetc(void)
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
  800ab0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab5:	89 d1                	mov    %edx,%ecx
  800ab7:	89 d3                	mov    %edx,%ebx
  800ab9:	89 d7                	mov    %edx,%edi
  800abb:	89 d6                	mov    %edx,%esi
  800abd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad7:	8b 55 08             	mov    0x8(%ebp),%edx
  800ada:	89 cb                	mov    %ecx,%ebx
  800adc:	89 cf                	mov    %ecx,%edi
  800ade:	89 ce                	mov    %ecx,%esi
  800ae0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	7e 17                	jle    800afd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	50                   	push   %eax
  800aea:	6a 03                	push   $0x3
  800aec:	68 bf 29 80 00       	push   $0x8029bf
  800af1:	6a 23                	push   $0x23
  800af3:	68 dc 29 80 00       	push   $0x8029dc
  800af8:	e8 d5 17 00 00       	call   8022d2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 02 00 00 00       	mov    $0x2,%eax
  800b15:	89 d1                	mov    %edx,%ecx
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_yield>:

void
sys_yield(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	be 00 00 00 00       	mov    $0x0,%esi
  800b51:	b8 04 00 00 00       	mov    $0x4,%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5f:	89 f7                	mov    %esi,%edi
  800b61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7e 17                	jle    800b7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	50                   	push   %eax
  800b6b:	6a 04                	push   $0x4
  800b6d:	68 bf 29 80 00       	push   $0x8029bf
  800b72:	6a 23                	push   $0x23
  800b74:	68 dc 29 80 00       	push   $0x8029dc
  800b79:	e8 54 17 00 00       	call   8022d2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7e 17                	jle    800bc0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	50                   	push   %eax
  800bad:	6a 05                	push   $0x5
  800baf:	68 bf 29 80 00       	push   $0x8029bf
  800bb4:	6a 23                	push   $0x23
  800bb6:	68 dc 29 80 00       	push   $0x8029dc
  800bbb:	e8 12 17 00 00       	call   8022d2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 df                	mov    %ebx,%edi
  800be3:	89 de                	mov    %ebx,%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 17                	jle    800c02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 06                	push   $0x6
  800bf1:	68 bf 29 80 00       	push   $0x8029bf
  800bf6:	6a 23                	push   $0x23
  800bf8:	68 dc 29 80 00       	push   $0x8029dc
  800bfd:	e8 d0 16 00 00       	call   8022d2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	89 de                	mov    %ebx,%esi
  800c27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 17                	jle    800c44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 08                	push   $0x8
  800c33:	68 bf 29 80 00       	push   $0x8029bf
  800c38:	6a 23                	push   $0x23
  800c3a:	68 dc 29 80 00       	push   $0x8029dc
  800c3f:	e8 8e 16 00 00       	call   8022d2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 17                	jle    800c86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	50                   	push   %eax
  800c73:	6a 09                	push   $0x9
  800c75:	68 bf 29 80 00       	push   $0x8029bf
  800c7a:	6a 23                	push   $0x23
  800c7c:	68 dc 29 80 00       	push   $0x8029dc
  800c81:	e8 4c 16 00 00       	call   8022d2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 0a                	push   $0xa
  800cb7:	68 bf 29 80 00       	push   $0x8029bf
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 dc 29 80 00       	push   $0x8029dc
  800cc3:	e8 0a 16 00 00       	call   8022d2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	be 00 00 00 00       	mov    $0x0,%esi
  800cdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 0d                	push   $0xd
  800d1b:	68 bf 29 80 00       	push   $0x8029bf
  800d20:	6a 23                	push   $0x23
  800d22:	68 dc 29 80 00       	push   $0x8029dc
  800d27:	e8 a6 15 00 00       	call   8022d2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d44:	89 d1                	mov    %edx,%ecx
  800d46:	89 d3                	mov    %edx,%ebx
  800d48:	89 d7                	mov    %edx,%edi
  800d4a:	89 d6                	mov    %edx,%esi
  800d4c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	53                   	push   %ebx
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d7e:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800d80:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d84:	74 2e                	je     800db4 <pgfault+0x40>
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	c1 ea 16             	shr    $0x16,%edx
  800d8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d92:	f6 c2 01             	test   $0x1,%dl
  800d95:	74 1d                	je     800db4 <pgfault+0x40>
  800d97:	89 c2                	mov    %eax,%edx
  800d99:	c1 ea 0c             	shr    $0xc,%edx
  800d9c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800da3:	f6 c1 01             	test   $0x1,%cl
  800da6:	74 0c                	je     800db4 <pgfault+0x40>
  800da8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800daf:	f6 c6 08             	test   $0x8,%dh
  800db2:	75 14                	jne    800dc8 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	68 ea 29 80 00       	push   $0x8029ea
  800dbc:	6a 1d                	push   $0x1d
  800dbe:	68 fd 29 80 00       	push   $0x8029fd
  800dc3:	e8 0a 15 00 00       	call   8022d2 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcd:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	6a 07                	push   $0x7
  800dd4:	68 00 f0 7f 00       	push   $0x7ff000
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 63 fd ff ff       	call   800b43 <sys_page_alloc>
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	79 14                	jns    800dfb <pgfault+0x87>
		panic("page alloc failed \n");
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	68 08 2a 80 00       	push   $0x802a08
  800def:	6a 28                	push   $0x28
  800df1:	68 fd 29 80 00       	push   $0x8029fd
  800df6:	e8 d7 14 00 00       	call   8022d2 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	68 00 10 00 00       	push   $0x1000
  800e03:	53                   	push   %ebx
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	e8 2c fb ff ff       	call   80093a <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800e0e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e15:	53                   	push   %ebx
  800e16:	6a 00                	push   $0x0
  800e18:	68 00 f0 7f 00       	push   $0x7ff000
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 62 fd ff ff       	call   800b86 <sys_page_map>
  800e24:	83 c4 20             	add    $0x20,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	79 14                	jns    800e3f <pgfault+0xcb>
        panic("page map failed \n");
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	68 1c 2a 80 00       	push   $0x802a1c
  800e33:	6a 2b                	push   $0x2b
  800e35:	68 fd 29 80 00       	push   $0x8029fd
  800e3a:	e8 93 14 00 00       	call   8022d2 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800e3f:	83 ec 08             	sub    $0x8,%esp
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	6a 00                	push   $0x0
  800e49:	e8 7a fd ff ff       	call   800bc8 <sys_page_unmap>
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	79 14                	jns    800e69 <pgfault+0xf5>
        panic("page unmap failed\n");
  800e55:	83 ec 04             	sub    $0x4,%esp
  800e58:	68 2e 2a 80 00       	push   $0x802a2e
  800e5d:	6a 2d                	push   $0x2d
  800e5f:	68 fd 29 80 00       	push   $0x8029fd
  800e64:	e8 69 14 00 00       	call   8022d2 <_panic>
	
	//panic("pgfault not implemented");
}
  800e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800e77:	68 74 0d 80 00       	push   $0x800d74
  800e7c:	e8 97 14 00 00       	call   802318 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e81:	b8 07 00 00 00       	mov    $0x7,%eax
  800e86:	cd 30                	int    $0x30
  800e88:	89 c7                	mov    %eax,%edi
  800e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	79 12                	jns    800ea6 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800e94:	50                   	push   %eax
  800e95:	68 41 2a 80 00       	push   $0x802a41
  800e9a:	6a 7a                	push   $0x7a
  800e9c:	68 fd 29 80 00       	push   $0x8029fd
  800ea1:	e8 2c 14 00 00       	call   8022d2 <_panic>
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800eab:	85 c0                	test   %eax,%eax
  800ead:	75 21                	jne    800ed0 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eaf:	e8 51 fc ff ff       	call   800b05 <sys_getenvid>
  800eb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ebc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec1:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	e9 91 01 00 00       	jmp    801061 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	c1 e8 16             	shr    $0x16,%eax
  800ed5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800edc:	a8 01                	test   $0x1,%al
  800ede:	0f 84 06 01 00 00    	je     800fea <fork+0x17c>
  800ee4:	89 d8                	mov    %ebx,%eax
  800ee6:	c1 e8 0c             	shr    $0xc,%eax
  800ee9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef0:	f6 c2 01             	test   $0x1,%dl
  800ef3:	0f 84 f1 00 00 00    	je     800fea <fork+0x17c>
  800ef9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f00:	f6 c2 04             	test   $0x4,%dl
  800f03:	0f 84 e1 00 00 00    	je     800fea <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800f09:	89 c6                	mov    %eax,%esi
  800f0b:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800f0e:	89 f2                	mov    %esi,%edx
  800f10:	c1 ea 16             	shr    $0x16,%edx
  800f13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800f1a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800f21:	f6 c6 04             	test   $0x4,%dh
  800f24:	74 39                	je     800f5f <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  800f26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	25 07 0e 00 00       	and    $0xe07,%eax
  800f35:	50                   	push   %eax
  800f36:	56                   	push   %esi
  800f37:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3a:	56                   	push   %esi
  800f3b:	6a 00                	push   $0x0
  800f3d:	e8 44 fc ff ff       	call   800b86 <sys_page_map>
  800f42:	83 c4 20             	add    $0x20,%esp
  800f45:	85 c0                	test   %eax,%eax
  800f47:	0f 89 9d 00 00 00    	jns    800fea <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 98 2a 80 00       	push   $0x802a98
  800f53:	6a 4b                	push   $0x4b
  800f55:	68 fd 29 80 00       	push   $0x8029fd
  800f5a:	e8 73 13 00 00       	call   8022d2 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  800f5f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f65:	74 59                	je     800fc0 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	68 05 08 00 00       	push   $0x805
  800f6f:	56                   	push   %esi
  800f70:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 0b fc ff ff       	call   800b86 <sys_page_map>
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 12                	jns    800f94 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  800f82:	50                   	push   %eax
  800f83:	68 c8 2a 80 00       	push   $0x802ac8
  800f88:	6a 50                	push   $0x50
  800f8a:	68 fd 29 80 00       	push   $0x8029fd
  800f8f:	e8 3e 13 00 00       	call   8022d2 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	68 05 08 00 00       	push   $0x805
  800f9c:	56                   	push   %esi
  800f9d:	6a 00                	push   $0x0
  800f9f:	56                   	push   %esi
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 df fb ff ff       	call   800b86 <sys_page_map>
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 3c                	jns    800fea <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  800fae:	50                   	push   %eax
  800faf:	68 f0 2a 80 00       	push   $0x802af0
  800fb4:	6a 53                	push   $0x53
  800fb6:	68 fd 29 80 00       	push   $0x8029fd
  800fbb:	e8 12 13 00 00       	call   8022d2 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	6a 05                	push   $0x5
  800fc5:	56                   	push   %esi
  800fc6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc9:	56                   	push   %esi
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 b5 fb ff ff       	call   800b86 <sys_page_map>
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	79 12                	jns    800fea <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  800fd8:	50                   	push   %eax
  800fd9:	68 18 2b 80 00       	push   $0x802b18
  800fde:	6a 58                	push   $0x58
  800fe0:	68 fd 29 80 00       	push   $0x8029fd
  800fe5:	e8 e8 12 00 00       	call   8022d2 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800fea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ff6:	0f 85 d4 fe ff ff    	jne    800ed0 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	6a 07                	push   $0x7
  801001:	68 00 f0 bf ee       	push   $0xeebff000
  801006:	57                   	push   %edi
  801007:	e8 37 fb ff ff       	call   800b43 <sys_page_alloc>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	79 17                	jns    80102a <fork+0x1bc>
        panic("page alloc failed\n");
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	68 53 2a 80 00       	push   $0x802a53
  80101b:	68 87 00 00 00       	push   $0x87
  801020:	68 fd 29 80 00       	push   $0x8029fd
  801025:	e8 a8 12 00 00       	call   8022d2 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	68 87 23 80 00       	push   $0x802387
  801032:	57                   	push   %edi
  801033:	e8 56 fc ff ff       	call   800c8e <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	6a 02                	push   $0x2
  80103d:	57                   	push   %edi
  80103e:	e8 c7 fb ff ff       	call   800c0a <sys_env_set_status>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 15                	jns    80105f <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80104a:	50                   	push   %eax
  80104b:	68 66 2a 80 00       	push   $0x802a66
  801050:	68 8c 00 00 00       	push   $0x8c
  801055:	68 fd 29 80 00       	push   $0x8029fd
  80105a:	e8 73 12 00 00       	call   8022d2 <_panic>

	return envid;
  80105f:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <sfork>:

// Challenge!
int
sfork(void)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80106f:	68 7f 2a 80 00       	push   $0x802a7f
  801074:	68 98 00 00 00       	push   $0x98
  801079:	68 fd 29 80 00       	push   $0x8029fd
  80107e:	e8 4f 12 00 00       	call   8022d2 <_panic>

00801083 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	8b 75 08             	mov    0x8(%ebp),%esi
  80108b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801091:	85 c0                	test   %eax,%eax
  801093:	74 0e                	je     8010a3 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	50                   	push   %eax
  801099:	e8 55 fc ff ff       	call   800cf3 <sys_ipc_recv>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	eb 10                	jmp    8010b3 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	68 00 00 00 f0       	push   $0xf0000000
  8010ab:	e8 43 fc ff ff       	call   800cf3 <sys_ipc_recv>
  8010b0:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 0e                	je     8010c5 <ipc_recv+0x42>
    	*from_env_store = 0;
  8010b7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8010bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8010c3:	eb 24                	jmp    8010e9 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8010c5:	85 f6                	test   %esi,%esi
  8010c7:	74 0a                	je     8010d3 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8010c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ce:	8b 40 74             	mov    0x74(%eax),%eax
  8010d1:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8010d3:	85 db                	test   %ebx,%ebx
  8010d5:	74 0a                	je     8010e1 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8010d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010dc:	8b 40 78             	mov    0x78(%eax),%eax
  8010df:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8010e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8010e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801102:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801109:	0f 44 d8             	cmove  %eax,%ebx
  80110c:	eb 1c                	jmp    80112a <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80110e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801111:	74 12                	je     801125 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801113:	50                   	push   %eax
  801114:	68 44 2b 80 00       	push   $0x802b44
  801119:	6a 4b                	push   $0x4b
  80111b:	68 5c 2b 80 00       	push   $0x802b5c
  801120:	e8 ad 11 00 00       	call   8022d2 <_panic>
        }	
        sys_yield();
  801125:	e8 fa f9 ff ff       	call   800b24 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80112a:	ff 75 14             	pushl  0x14(%ebp)
  80112d:	53                   	push   %ebx
  80112e:	56                   	push   %esi
  80112f:	57                   	push   %edi
  801130:	e8 9b fb ff ff       	call   800cd0 <sys_ipc_try_send>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	75 d2                	jne    80110e <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80113c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80114a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80114f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801152:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801158:	8b 52 50             	mov    0x50(%edx),%edx
  80115b:	39 ca                	cmp    %ecx,%edx
  80115d:	75 0d                	jne    80116c <ipc_find_env+0x28>
			return envs[i].env_id;
  80115f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801167:	8b 40 48             	mov    0x48(%eax),%eax
  80116a:	eb 0f                	jmp    80117b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80116c:	83 c0 01             	add    $0x1,%eax
  80116f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801174:	75 d9                	jne    80114f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
}
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
  801198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	c1 ea 16             	shr    $0x16,%edx
  8011b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 11                	je     8011d1 <fd_alloc+0x2d>
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 0c             	shr    $0xc,%edx
  8011c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	75 09                	jne    8011da <fd_alloc+0x36>
			*fd_store = fd;
  8011d1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d8:	eb 17                	jmp    8011f1 <fd_alloc+0x4d>
  8011da:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011df:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e4:	75 c9                	jne    8011af <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 f8 1f             	cmp    $0x1f,%eax
  8011fc:	77 36                	ja     801234 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
  801201:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 24                	je     80123b <fd_lookup+0x48>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 1a                	je     801242 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 02                	mov    %eax,(%edx)
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 13                	jmp    801247 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb 0c                	jmp    801247 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb 05                	jmp    801247 <fd_lookup+0x54>
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801252:	ba e4 2b 80 00       	mov    $0x802be4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801257:	eb 13                	jmp    80126c <dev_lookup+0x23>
  801259:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125c:	39 08                	cmp    %ecx,(%eax)
  80125e:	75 0c                	jne    80126c <dev_lookup+0x23>
			*dev = devtab[i];
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	89 01                	mov    %eax,(%ecx)
			return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	eb 2e                	jmp    80129a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126c:	8b 02                	mov    (%edx),%eax
  80126e:	85 c0                	test   %eax,%eax
  801270:	75 e7                	jne    801259 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801272:	a1 08 40 80 00       	mov    0x804008,%eax
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	51                   	push   %ecx
  80127e:	50                   	push   %eax
  80127f:	68 68 2b 80 00       	push   $0x802b68
  801284:	e8 32 ef ff ff       	call   8001bb <cprintf>
	*dev = 0;
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 10             	sub    $0x10,%esp
  8012a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b4:	c1 e8 0c             	shr    $0xc,%eax
  8012b7:	50                   	push   %eax
  8012b8:	e8 36 ff ff ff       	call   8011f3 <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 05                	js     8012c9 <fd_close+0x2d>
	    || fd != fd2)
  8012c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c7:	74 0c                	je     8012d5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c9:	84 db                	test   %bl,%bl
  8012cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d0:	0f 44 c2             	cmove  %edx,%eax
  8012d3:	eb 41                	jmp    801316 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	ff 36                	pushl  (%esi)
  8012de:	e8 66 ff ff ff       	call   801249 <dev_lookup>
  8012e3:	89 c3                	mov    %eax,%ebx
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 1a                	js     801306 <fd_close+0x6a>
		if (dev->dev_close)
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	74 0b                	je     801306 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	ff d0                	call   *%eax
  801301:	89 c3                	mov    %eax,%ebx
  801303:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	56                   	push   %esi
  80130a:	6a 00                	push   $0x0
  80130c:	e8 b7 f8 ff ff       	call   800bc8 <sys_page_unmap>
	return r;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	89 d8                	mov    %ebx,%eax
}
  801316:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 c4 fe ff ff       	call   8011f3 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 10                	js     801346 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	6a 01                	push   $0x1
  80133b:	ff 75 f4             	pushl  -0xc(%ebp)
  80133e:	e8 59 ff ff ff       	call   80129c <fd_close>
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <close_all>:

void
close_all(void)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	53                   	push   %ebx
  801358:	e8 c0 ff ff ff       	call   80131d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135d:	83 c3 01             	add    $0x1,%ebx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	83 fb 20             	cmp    $0x20,%ebx
  801366:	75 ec                	jne    801354 <close_all+0xc>
		close(i);
}
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	57                   	push   %edi
  801371:	56                   	push   %esi
  801372:	53                   	push   %ebx
  801373:	83 ec 2c             	sub    $0x2c,%esp
  801376:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 6e fe ff ff       	call   8011f3 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	0f 88 c1 00 00 00    	js     801451 <dup+0xe4>
		return r;
	close(newfdnum);
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	56                   	push   %esi
  801394:	e8 84 ff ff ff       	call   80131d <close>

	newfd = INDEX2FD(newfdnum);
  801399:	89 f3                	mov    %esi,%ebx
  80139b:	c1 e3 0c             	shl    $0xc,%ebx
  80139e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a4:	83 c4 04             	add    $0x4,%esp
  8013a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013aa:	e8 de fd ff ff       	call   80118d <fd2data>
  8013af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 d4 fd ff ff       	call   80118d <fd2data>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	c1 e8 16             	shr    $0x16,%eax
  8013c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cb:	a8 01                	test   $0x1,%al
  8013cd:	74 37                	je     801406 <dup+0x99>
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	c1 e8 0c             	shr    $0xc,%eax
  8013d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013db:	f6 c2 01             	test   $0x1,%dl
  8013de:	74 26                	je     801406 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f3:	6a 00                	push   $0x0
  8013f5:	57                   	push   %edi
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 89 f7 ff ff       	call   800b86 <sys_page_map>
  8013fd:	89 c7                	mov    %eax,%edi
  8013ff:	83 c4 20             	add    $0x20,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 2e                	js     801434 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801406:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801409:	89 d0                	mov    %edx,%eax
  80140b:	c1 e8 0c             	shr    $0xc,%eax
  80140e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	25 07 0e 00 00       	and    $0xe07,%eax
  80141d:	50                   	push   %eax
  80141e:	53                   	push   %ebx
  80141f:	6a 00                	push   $0x0
  801421:	52                   	push   %edx
  801422:	6a 00                	push   $0x0
  801424:	e8 5d f7 ff ff       	call   800b86 <sys_page_map>
  801429:	89 c7                	mov    %eax,%edi
  80142b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801430:	85 ff                	test   %edi,%edi
  801432:	79 1d                	jns    801451 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	e8 89 f7 ff ff       	call   800bc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	ff 75 d4             	pushl  -0x2c(%ebp)
  801445:	6a 00                	push   $0x0
  801447:	e8 7c f7 ff ff       	call   800bc8 <sys_page_unmap>
	return r;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	89 f8                	mov    %edi,%eax
}
  801451:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5f                   	pop    %edi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 14             	sub    $0x14,%esp
  801460:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	53                   	push   %ebx
  801468:	e8 86 fd ff ff       	call   8011f3 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	89 c2                	mov    %eax,%edx
  801472:	85 c0                	test   %eax,%eax
  801474:	78 6d                	js     8014e3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	ff 30                	pushl  (%eax)
  801482:	e8 c2 fd ff ff       	call   801249 <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 4c                	js     8014da <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801491:	8b 42 08             	mov    0x8(%edx),%eax
  801494:	83 e0 03             	and    $0x3,%eax
  801497:	83 f8 01             	cmp    $0x1,%eax
  80149a:	75 21                	jne    8014bd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149c:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a1:	8b 40 48             	mov    0x48(%eax),%eax
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	50                   	push   %eax
  8014a9:	68 a9 2b 80 00       	push   $0x802ba9
  8014ae:	e8 08 ed ff ff       	call   8001bb <cprintf>
		return -E_INVAL;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bb:	eb 26                	jmp    8014e3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	8b 40 08             	mov    0x8(%eax),%eax
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	74 17                	je     8014de <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c7:	83 ec 04             	sub    $0x4,%esp
  8014ca:	ff 75 10             	pushl  0x10(%ebp)
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	52                   	push   %edx
  8014d1:	ff d0                	call   *%eax
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 09                	jmp    8014e3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	eb 05                	jmp    8014e3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e3:	89 d0                	mov    %edx,%eax
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fe:	eb 21                	jmp    801521 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	89 f0                	mov    %esi,%eax
  801505:	29 d8                	sub    %ebx,%eax
  801507:	50                   	push   %eax
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	03 45 0c             	add    0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	57                   	push   %edi
  80150f:	e8 45 ff ff ff       	call   801459 <read>
		if (m < 0)
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 10                	js     80152b <readn+0x41>
			return m;
		if (m == 0)
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 0a                	je     801529 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151f:	01 c3                	add    %eax,%ebx
  801521:	39 f3                	cmp    %esi,%ebx
  801523:	72 db                	jb     801500 <readn+0x16>
  801525:	89 d8                	mov    %ebx,%eax
  801527:	eb 02                	jmp    80152b <readn+0x41>
  801529:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	53                   	push   %ebx
  801542:	e8 ac fc ff ff       	call   8011f3 <fd_lookup>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	89 c2                	mov    %eax,%edx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 68                	js     8015b8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	ff 30                	pushl  (%eax)
  80155c:	e8 e8 fc ff ff       	call   801249 <dev_lookup>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 47                	js     8015af <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156f:	75 21                	jne    801592 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801571:	a1 08 40 80 00       	mov    0x804008,%eax
  801576:	8b 40 48             	mov    0x48(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	53                   	push   %ebx
  80157d:	50                   	push   %eax
  80157e:	68 c5 2b 80 00       	push   $0x802bc5
  801583:	e8 33 ec ff ff       	call   8001bb <cprintf>
		return -E_INVAL;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801590:	eb 26                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801592:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801595:	8b 52 0c             	mov    0xc(%edx),%edx
  801598:	85 d2                	test   %edx,%edx
  80159a:	74 17                	je     8015b3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	50                   	push   %eax
  8015a6:	ff d2                	call   *%edx
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 09                	jmp    8015b8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	eb 05                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 22 fc ff ff       	call   8011f3 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 0e                	js     8015e6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015de:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 14             	sub    $0x14,%esp
  8015ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	53                   	push   %ebx
  8015f7:	e8 f7 fb ff ff       	call   8011f3 <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 65                	js     80166a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 33 fc ff ff       	call   801249 <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 44                	js     801661 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801624:	75 21                	jne    801647 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801626:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162b:	8b 40 48             	mov    0x48(%eax),%eax
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	53                   	push   %ebx
  801632:	50                   	push   %eax
  801633:	68 88 2b 80 00       	push   $0x802b88
  801638:	e8 7e eb ff ff       	call   8001bb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801645:	eb 23                	jmp    80166a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	8b 52 18             	mov    0x18(%edx),%edx
  80164d:	85 d2                	test   %edx,%edx
  80164f:	74 14                	je     801665 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	ff d2                	call   *%edx
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	ff 75 08             	pushl  0x8(%ebp)
  801682:	e8 6c fb ff ff       	call   8011f3 <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 58                	js     8016e8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 a8 fb ff ff       	call   801249 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 37                	js     8016df <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016af:	74 32                	je     8016e3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bb:	00 00 00 
	stat->st_isdir = 0;
  8016be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c5:	00 00 00 
	stat->st_dev = dev;
  8016c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d5:	ff 50 14             	call   *0x14(%eax)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb 09                	jmp    8016e8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	eb 05                	jmp    8016e8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e8:	89 d0                	mov    %edx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	6a 00                	push   $0x0
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 e7 01 00 00       	call   8018e8 <open>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 1b                	js     801725 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	ff 75 0c             	pushl  0xc(%ebp)
  801710:	50                   	push   %eax
  801711:	e8 5b ff ff ff       	call   801671 <fstat>
  801716:	89 c6                	mov    %eax,%esi
	close(fd);
  801718:	89 1c 24             	mov    %ebx,(%esp)
  80171b:	e8 fd fb ff ff       	call   80131d <close>
	return r;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	89 f0                	mov    %esi,%eax
}
  801725:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	89 c6                	mov    %eax,%esi
  801733:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801735:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173c:	75 12                	jne    801750 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	6a 01                	push   $0x1
  801743:	e8 fc f9 ff ff       	call   801144 <ipc_find_env>
  801748:	a3 00 40 80 00       	mov    %eax,0x804000
  80174d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801750:	6a 07                	push   $0x7
  801752:	68 00 50 80 00       	push   $0x805000
  801757:	56                   	push   %esi
  801758:	ff 35 00 40 80 00    	pushl  0x804000
  80175e:	e8 8d f9 ff ff       	call   8010f0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801763:	83 c4 0c             	add    $0xc,%esp
  801766:	6a 00                	push   $0x0
  801768:	53                   	push   %ebx
  801769:	6a 00                	push   $0x0
  80176b:	e8 13 f9 ff ff       	call   801083 <ipc_recv>
}
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 02 00 00 00       	mov    $0x2,%eax
  80179a:	e8 8d ff ff ff       	call   80172c <fsipc>
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bc:	e8 6b ff ff ff       	call   80172c <fsipc>
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e2:	e8 45 ff ff ff       	call   80172c <fsipc>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 2c                	js     801817 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	53                   	push   %ebx
  8017f4:	e8 47 ef ff ff       	call   800740 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801804:	a1 84 50 80 00       	mov    0x805084,%eax
  801809:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	53                   	push   %ebx
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801826:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80182b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801830:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801833:	53                   	push   %ebx
  801834:	ff 75 0c             	pushl  0xc(%ebp)
  801837:	68 08 50 80 00       	push   $0x805008
  80183c:	e8 91 f0 ff ff       	call   8008d2 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
  801847:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  80184c:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 04 00 00 00       	mov    $0x4,%eax
  80185c:	e8 cb fe ff ff       	call   80172c <fsipc>
	//panic("devfile_write not implemented");
}
  801861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 40 0c             	mov    0xc(%eax),%eax
  801874:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801879:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 03 00 00 00       	mov    $0x3,%eax
  801889:	e8 9e fe ff ff       	call   80172c <fsipc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	85 c0                	test   %eax,%eax
  801892:	78 4b                	js     8018df <devfile_read+0x79>
		return r;
	assert(r <= n);
  801894:	39 c6                	cmp    %eax,%esi
  801896:	73 16                	jae    8018ae <devfile_read+0x48>
  801898:	68 f8 2b 80 00       	push   $0x802bf8
  80189d:	68 ff 2b 80 00       	push   $0x802bff
  8018a2:	6a 7c                	push   $0x7c
  8018a4:	68 14 2c 80 00       	push   $0x802c14
  8018a9:	e8 24 0a 00 00       	call   8022d2 <_panic>
	assert(r <= PGSIZE);
  8018ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b3:	7e 16                	jle    8018cb <devfile_read+0x65>
  8018b5:	68 1f 2c 80 00       	push   $0x802c1f
  8018ba:	68 ff 2b 80 00       	push   $0x802bff
  8018bf:	6a 7d                	push   $0x7d
  8018c1:	68 14 2c 80 00       	push   $0x802c14
  8018c6:	e8 07 0a 00 00       	call   8022d2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	50                   	push   %eax
  8018cf:	68 00 50 80 00       	push   $0x805000
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	e8 f6 ef ff ff       	call   8008d2 <memmove>
	return r;
  8018dc:	83 c4 10             	add    $0x10,%esp
}
  8018df:	89 d8                	mov    %ebx,%eax
  8018e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 20             	sub    $0x20,%esp
  8018ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f2:	53                   	push   %ebx
  8018f3:	e8 0f ee ff ff       	call   800707 <strlen>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801900:	7f 67                	jg     801969 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801902:	83 ec 0c             	sub    $0xc,%esp
  801905:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	e8 96 f8 ff ff       	call   8011a4 <fd_alloc>
  80190e:	83 c4 10             	add    $0x10,%esp
		return r;
  801911:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801913:	85 c0                	test   %eax,%eax
  801915:	78 57                	js     80196e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	53                   	push   %ebx
  80191b:	68 00 50 80 00       	push   $0x805000
  801920:	e8 1b ee ff ff       	call   800740 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801925:	8b 45 0c             	mov    0xc(%ebp),%eax
  801928:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801930:	b8 01 00 00 00       	mov    $0x1,%eax
  801935:	e8 f2 fd ff ff       	call   80172c <fsipc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	79 14                	jns    801957 <open+0x6f>
		fd_close(fd, 0);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	6a 00                	push   $0x0
  801948:	ff 75 f4             	pushl  -0xc(%ebp)
  80194b:	e8 4c f9 ff ff       	call   80129c <fd_close>
		return r;
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	89 da                	mov    %ebx,%edx
  801955:	eb 17                	jmp    80196e <open+0x86>
	}

	return fd2num(fd);
  801957:	83 ec 0c             	sub    $0xc,%esp
  80195a:	ff 75 f4             	pushl  -0xc(%ebp)
  80195d:	e8 1b f8 ff ff       	call   80117d <fd2num>
  801962:	89 c2                	mov    %eax,%edx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	eb 05                	jmp    80196e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801969:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196e:	89 d0                	mov    %edx,%eax
  801970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 08 00 00 00       	mov    $0x8,%eax
  801985:	e8 a2 fd ff ff       	call   80172c <fsipc>
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801992:	68 2b 2c 80 00       	push   $0x802c2b
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	e8 a1 ed ff ff       	call   800740 <strcpy>
	return 0;
}
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 10             	sub    $0x10,%esp
  8019ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019b0:	53                   	push   %ebx
  8019b1:	e8 f5 09 00 00       	call   8023ab <pageref>
  8019b6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019b9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019be:	83 f8 01             	cmp    $0x1,%eax
  8019c1:	75 10                	jne    8019d3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 73 0c             	pushl  0xc(%ebx)
  8019c9:	e8 c0 02 00 00       	call   801c8e <nsipc_close>
  8019ce:	89 c2                	mov    %eax,%edx
  8019d0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019d3:	89 d0                	mov    %edx,%eax
  8019d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019e0:	6a 00                	push   $0x0
  8019e2:	ff 75 10             	pushl  0x10(%ebp)
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	ff 70 0c             	pushl  0xc(%eax)
  8019ee:	e8 78 03 00 00       	call   801d6b <nsipc_send>
}
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 10             	pushl  0x10(%ebp)
  801a00:	ff 75 0c             	pushl  0xc(%ebp)
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	ff 70 0c             	pushl  0xc(%eax)
  801a09:	e8 f1 02 00 00       	call   801cff <nsipc_recv>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a16:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a19:	52                   	push   %edx
  801a1a:	50                   	push   %eax
  801a1b:	e8 d3 f7 ff ff       	call   8011f3 <fd_lookup>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 17                	js     801a3e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a30:	39 08                	cmp    %ecx,(%eax)
  801a32:	75 05                	jne    801a39 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a34:	8b 40 0c             	mov    0xc(%eax),%eax
  801a37:	eb 05                	jmp    801a3e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a39:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
  801a48:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4d:	50                   	push   %eax
  801a4e:	e8 51 f7 ff ff       	call   8011a4 <fd_alloc>
  801a53:	89 c3                	mov    %eax,%ebx
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 1b                	js     801a77 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 f4             	pushl  -0xc(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 d5 f0 ff ff       	call   800b43 <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	79 10                	jns    801a87 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	56                   	push   %esi
  801a7b:	e8 0e 02 00 00       	call   801c8e <nsipc_close>
		return r;
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	89 d8                	mov    %ebx,%eax
  801a85:	eb 24                	jmp    801aab <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a9c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	50                   	push   %eax
  801aa3:	e8 d5 f6 ff ff       	call   80117d <fd2num>
  801aa8:	83 c4 10             	add    $0x10,%esp
}
  801aab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aae:	5b                   	pop    %ebx
  801aaf:	5e                   	pop    %esi
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	e8 50 ff ff ff       	call   801a10 <fd2sockid>
		return r;
  801ac0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 1f                	js     801ae5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	ff 75 10             	pushl  0x10(%ebp)
  801acc:	ff 75 0c             	pushl  0xc(%ebp)
  801acf:	50                   	push   %eax
  801ad0:	e8 12 01 00 00       	call   801be7 <nsipc_accept>
  801ad5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ada:	85 c0                	test   %eax,%eax
  801adc:	78 07                	js     801ae5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ade:	e8 5d ff ff ff       	call   801a40 <alloc_sockfd>
  801ae3:	89 c1                	mov    %eax,%ecx
}
  801ae5:	89 c8                	mov    %ecx,%eax
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
  801af2:	e8 19 ff ff ff       	call   801a10 <fd2sockid>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 12                	js     801b0d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801afb:	83 ec 04             	sub    $0x4,%esp
  801afe:	ff 75 10             	pushl  0x10(%ebp)
  801b01:	ff 75 0c             	pushl  0xc(%ebp)
  801b04:	50                   	push   %eax
  801b05:	e8 2d 01 00 00       	call   801c37 <nsipc_bind>
  801b0a:	83 c4 10             	add    $0x10,%esp
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <shutdown>:

int
shutdown(int s, int how)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b15:	8b 45 08             	mov    0x8(%ebp),%eax
  801b18:	e8 f3 fe ff ff       	call   801a10 <fd2sockid>
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 0f                	js     801b30 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	ff 75 0c             	pushl  0xc(%ebp)
  801b27:	50                   	push   %eax
  801b28:	e8 3f 01 00 00       	call   801c6c <nsipc_shutdown>
  801b2d:	83 c4 10             	add    $0x10,%esp
}
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	e8 d0 fe ff ff       	call   801a10 <fd2sockid>
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 12                	js     801b56 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b44:	83 ec 04             	sub    $0x4,%esp
  801b47:	ff 75 10             	pushl  0x10(%ebp)
  801b4a:	ff 75 0c             	pushl  0xc(%ebp)
  801b4d:	50                   	push   %eax
  801b4e:	e8 55 01 00 00       	call   801ca8 <nsipc_connect>
  801b53:	83 c4 10             	add    $0x10,%esp
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <listen>:

int
listen(int s, int backlog)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	e8 aa fe ff ff       	call   801a10 <fd2sockid>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 0f                	js     801b79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b6a:	83 ec 08             	sub    $0x8,%esp
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	50                   	push   %eax
  801b71:	e8 67 01 00 00       	call   801cdd <nsipc_listen>
  801b76:	83 c4 10             	add    $0x10,%esp
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b81:	ff 75 10             	pushl  0x10(%ebp)
  801b84:	ff 75 0c             	pushl  0xc(%ebp)
  801b87:	ff 75 08             	pushl  0x8(%ebp)
  801b8a:	e8 3a 02 00 00       	call   801dc9 <nsipc_socket>
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	78 05                	js     801b9b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b96:	e8 a5 fe ff ff       	call   801a40 <alloc_sockfd>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bad:	75 12                	jne    801bc1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	6a 02                	push   $0x2
  801bb4:	e8 8b f5 ff ff       	call   801144 <ipc_find_env>
  801bb9:	a3 04 40 80 00       	mov    %eax,0x804004
  801bbe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc1:	6a 07                	push   $0x7
  801bc3:	68 00 60 80 00       	push   $0x806000
  801bc8:	53                   	push   %ebx
  801bc9:	ff 35 04 40 80 00    	pushl  0x804004
  801bcf:	e8 1c f5 ff ff       	call   8010f0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd4:	83 c4 0c             	add    $0xc,%esp
  801bd7:	6a 00                	push   $0x0
  801bd9:	6a 00                	push   $0x0
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 a1 f4 ff ff       	call   801083 <ipc_recv>
}
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bef:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf7:	8b 06                	mov    (%esi),%eax
  801bf9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801c03:	e8 95 ff ff ff       	call   801b9d <nsipc>
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	78 20                	js     801c2e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c0e:	83 ec 04             	sub    $0x4,%esp
  801c11:	ff 35 10 60 80 00    	pushl  0x806010
  801c17:	68 00 60 80 00       	push   $0x806000
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	e8 ae ec ff ff       	call   8008d2 <memmove>
		*addrlen = ret->ret_addrlen;
  801c24:	a1 10 60 80 00       	mov    0x806010,%eax
  801c29:	89 06                	mov    %eax,(%esi)
  801c2b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c2e:	89 d8                	mov    %ebx,%eax
  801c30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 08             	sub    $0x8,%esp
  801c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c49:	53                   	push   %ebx
  801c4a:	ff 75 0c             	pushl  0xc(%ebp)
  801c4d:	68 04 60 80 00       	push   $0x806004
  801c52:	e8 7b ec ff ff       	call   8008d2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c57:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c5d:	b8 02 00 00 00       	mov    $0x2,%eax
  801c62:	e8 36 ff ff ff       	call   801b9d <nsipc>
}
  801c67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c82:	b8 03 00 00 00       	mov    $0x3,%eax
  801c87:	e8 11 ff ff ff       	call   801b9d <nsipc>
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <nsipc_close>:

int
nsipc_close(int s)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c9c:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca1:	e8 f7 fe ff ff       	call   801b9d <nsipc>
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	53                   	push   %ebx
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cba:	53                   	push   %ebx
  801cbb:	ff 75 0c             	pushl  0xc(%ebp)
  801cbe:	68 04 60 80 00       	push   $0x806004
  801cc3:	e8 0a ec ff ff       	call   8008d2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cce:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd3:	e8 c5 fe ff ff       	call   801b9d <nsipc>
}
  801cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    

00801cdd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cee:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cf3:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf8:	e8 a0 fe ff ff       	call   801b9d <nsipc>
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d0f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d15:	8b 45 14             	mov    0x14(%ebp),%eax
  801d18:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d1d:	b8 07 00 00 00       	mov    $0x7,%eax
  801d22:	e8 76 fe ff ff       	call   801b9d <nsipc>
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 35                	js     801d62 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d2d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d32:	7f 04                	jg     801d38 <nsipc_recv+0x39>
  801d34:	39 c6                	cmp    %eax,%esi
  801d36:	7d 16                	jge    801d4e <nsipc_recv+0x4f>
  801d38:	68 37 2c 80 00       	push   $0x802c37
  801d3d:	68 ff 2b 80 00       	push   $0x802bff
  801d42:	6a 62                	push   $0x62
  801d44:	68 4c 2c 80 00       	push   $0x802c4c
  801d49:	e8 84 05 00 00       	call   8022d2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	50                   	push   %eax
  801d52:	68 00 60 80 00       	push   $0x806000
  801d57:	ff 75 0c             	pushl  0xc(%ebp)
  801d5a:	e8 73 eb ff ff       	call   8008d2 <memmove>
  801d5f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d62:	89 d8                	mov    %ebx,%eax
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d75:	8b 45 08             	mov    0x8(%ebp),%eax
  801d78:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d7d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d83:	7e 16                	jle    801d9b <nsipc_send+0x30>
  801d85:	68 58 2c 80 00       	push   $0x802c58
  801d8a:	68 ff 2b 80 00       	push   $0x802bff
  801d8f:	6a 6d                	push   $0x6d
  801d91:	68 4c 2c 80 00       	push   $0x802c4c
  801d96:	e8 37 05 00 00       	call   8022d2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	53                   	push   %ebx
  801d9f:	ff 75 0c             	pushl  0xc(%ebp)
  801da2:	68 0c 60 80 00       	push   $0x80600c
  801da7:	e8 26 eb ff ff       	call   8008d2 <memmove>
	nsipcbuf.send.req_size = size;
  801dac:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801db2:	8b 45 14             	mov    0x14(%ebp),%eax
  801db5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dba:	b8 08 00 00 00       	mov    $0x8,%eax
  801dbf:	e8 d9 fd ff ff       	call   801b9d <nsipc>
}
  801dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dda:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ddf:	8b 45 10             	mov    0x10(%ebp),%eax
  801de2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de7:	b8 09 00 00 00       	mov    $0x9,%eax
  801dec:	e8 ac fd ff ff       	call   801b9d <nsipc>
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	ff 75 08             	pushl  0x8(%ebp)
  801e01:	e8 87 f3 ff ff       	call   80118d <fd2data>
  801e06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e08:	83 c4 08             	add    $0x8,%esp
  801e0b:	68 64 2c 80 00       	push   $0x802c64
  801e10:	53                   	push   %ebx
  801e11:	e8 2a e9 ff ff       	call   800740 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e16:	8b 46 04             	mov    0x4(%esi),%eax
  801e19:	2b 06                	sub    (%esi),%eax
  801e1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e28:	00 00 00 
	stat->st_dev = &devpipe;
  801e2b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e32:	30 80 00 
	return 0;
}
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	53                   	push   %ebx
  801e45:	83 ec 0c             	sub    $0xc,%esp
  801e48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4b:	53                   	push   %ebx
  801e4c:	6a 00                	push   $0x0
  801e4e:	e8 75 ed ff ff       	call   800bc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e53:	89 1c 24             	mov    %ebx,(%esp)
  801e56:	e8 32 f3 ff ff       	call   80118d <fd2data>
  801e5b:	83 c4 08             	add    $0x8,%esp
  801e5e:	50                   	push   %eax
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 62 ed ff ff       	call   800bc8 <sys_page_unmap>
}
  801e66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	57                   	push   %edi
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	83 ec 1c             	sub    $0x1c,%esp
  801e74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e77:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e79:	a1 08 40 80 00       	mov    0x804008,%eax
  801e7e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	ff 75 e0             	pushl  -0x20(%ebp)
  801e87:	e8 1f 05 00 00       	call   8023ab <pageref>
  801e8c:	89 c3                	mov    %eax,%ebx
  801e8e:	89 3c 24             	mov    %edi,(%esp)
  801e91:	e8 15 05 00 00       	call   8023ab <pageref>
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	39 c3                	cmp    %eax,%ebx
  801e9b:	0f 94 c1             	sete   %cl
  801e9e:	0f b6 c9             	movzbl %cl,%ecx
  801ea1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ea4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eaa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ead:	39 ce                	cmp    %ecx,%esi
  801eaf:	74 1b                	je     801ecc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eb1:	39 c3                	cmp    %eax,%ebx
  801eb3:	75 c4                	jne    801e79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb5:	8b 42 58             	mov    0x58(%edx),%eax
  801eb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ebb:	50                   	push   %eax
  801ebc:	56                   	push   %esi
  801ebd:	68 6b 2c 80 00       	push   $0x802c6b
  801ec2:	e8 f4 e2 ff ff       	call   8001bb <cprintf>
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	eb ad                	jmp    801e79 <_pipeisclosed+0xe>
	}
}
  801ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ecf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5f                   	pop    %edi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    

00801ed7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	57                   	push   %edi
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
  801edd:	83 ec 28             	sub    $0x28,%esp
  801ee0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ee3:	56                   	push   %esi
  801ee4:	e8 a4 f2 ff ff       	call   80118d <fd2data>
  801ee9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef3:	eb 4b                	jmp    801f40 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef5:	89 da                	mov    %ebx,%edx
  801ef7:	89 f0                	mov    %esi,%eax
  801ef9:	e8 6d ff ff ff       	call   801e6b <_pipeisclosed>
  801efe:	85 c0                	test   %eax,%eax
  801f00:	75 48                	jne    801f4a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f02:	e8 1d ec ff ff       	call   800b24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f07:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0a:	8b 0b                	mov    (%ebx),%ecx
  801f0c:	8d 51 20             	lea    0x20(%ecx),%edx
  801f0f:	39 d0                	cmp    %edx,%eax
  801f11:	73 e2                	jae    801ef5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f16:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f1a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f1d:	89 c2                	mov    %eax,%edx
  801f1f:	c1 fa 1f             	sar    $0x1f,%edx
  801f22:	89 d1                	mov    %edx,%ecx
  801f24:	c1 e9 1b             	shr    $0x1b,%ecx
  801f27:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f2a:	83 e2 1f             	and    $0x1f,%edx
  801f2d:	29 ca                	sub    %ecx,%edx
  801f2f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f33:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f37:	83 c0 01             	add    $0x1,%eax
  801f3a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3d:	83 c7 01             	add    $0x1,%edi
  801f40:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f43:	75 c2                	jne    801f07 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f45:	8b 45 10             	mov    0x10(%ebp),%eax
  801f48:	eb 05                	jmp    801f4f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	57                   	push   %edi
  801f5b:	56                   	push   %esi
  801f5c:	53                   	push   %ebx
  801f5d:	83 ec 18             	sub    $0x18,%esp
  801f60:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f63:	57                   	push   %edi
  801f64:	e8 24 f2 ff ff       	call   80118d <fd2data>
  801f69:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f73:	eb 3d                	jmp    801fb2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f75:	85 db                	test   %ebx,%ebx
  801f77:	74 04                	je     801f7d <devpipe_read+0x26>
				return i;
  801f79:	89 d8                	mov    %ebx,%eax
  801f7b:	eb 44                	jmp    801fc1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f7d:	89 f2                	mov    %esi,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	e8 e5 fe ff ff       	call   801e6b <_pipeisclosed>
  801f86:	85 c0                	test   %eax,%eax
  801f88:	75 32                	jne    801fbc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f8a:	e8 95 eb ff ff       	call   800b24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f8f:	8b 06                	mov    (%esi),%eax
  801f91:	3b 46 04             	cmp    0x4(%esi),%eax
  801f94:	74 df                	je     801f75 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f96:	99                   	cltd   
  801f97:	c1 ea 1b             	shr    $0x1b,%edx
  801f9a:	01 d0                	add    %edx,%eax
  801f9c:	83 e0 1f             	and    $0x1f,%eax
  801f9f:	29 d0                	sub    %edx,%eax
  801fa1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fac:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801faf:	83 c3 01             	add    $0x1,%ebx
  801fb2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb5:	75 d8                	jne    801f8f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fb7:	8b 45 10             	mov    0x10(%ebp),%eax
  801fba:	eb 05                	jmp    801fc1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd4:	50                   	push   %eax
  801fd5:	e8 ca f1 ff ff       	call   8011a4 <fd_alloc>
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	89 c2                	mov    %eax,%edx
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	0f 88 2c 01 00 00    	js     802113 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe7:	83 ec 04             	sub    $0x4,%esp
  801fea:	68 07 04 00 00       	push   $0x407
  801fef:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff2:	6a 00                	push   $0x0
  801ff4:	e8 4a eb ff ff       	call   800b43 <sys_page_alloc>
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	89 c2                	mov    %eax,%edx
  801ffe:	85 c0                	test   %eax,%eax
  802000:	0f 88 0d 01 00 00    	js     802113 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802006:	83 ec 0c             	sub    $0xc,%esp
  802009:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 92 f1 ff ff       	call   8011a4 <fd_alloc>
  802012:	89 c3                	mov    %eax,%ebx
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	85 c0                	test   %eax,%eax
  802019:	0f 88 e2 00 00 00    	js     802101 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201f:	83 ec 04             	sub    $0x4,%esp
  802022:	68 07 04 00 00       	push   $0x407
  802027:	ff 75 f0             	pushl  -0x10(%ebp)
  80202a:	6a 00                	push   $0x0
  80202c:	e8 12 eb ff ff       	call   800b43 <sys_page_alloc>
  802031:	89 c3                	mov    %eax,%ebx
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	0f 88 c3 00 00 00    	js     802101 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80203e:	83 ec 0c             	sub    $0xc,%esp
  802041:	ff 75 f4             	pushl  -0xc(%ebp)
  802044:	e8 44 f1 ff ff       	call   80118d <fd2data>
  802049:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204b:	83 c4 0c             	add    $0xc,%esp
  80204e:	68 07 04 00 00       	push   $0x407
  802053:	50                   	push   %eax
  802054:	6a 00                	push   $0x0
  802056:	e8 e8 ea ff ff       	call   800b43 <sys_page_alloc>
  80205b:	89 c3                	mov    %eax,%ebx
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	85 c0                	test   %eax,%eax
  802062:	0f 88 89 00 00 00    	js     8020f1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802068:	83 ec 0c             	sub    $0xc,%esp
  80206b:	ff 75 f0             	pushl  -0x10(%ebp)
  80206e:	e8 1a f1 ff ff       	call   80118d <fd2data>
  802073:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80207a:	50                   	push   %eax
  80207b:	6a 00                	push   $0x0
  80207d:	56                   	push   %esi
  80207e:	6a 00                	push   $0x0
  802080:	e8 01 eb ff ff       	call   800b86 <sys_page_map>
  802085:	89 c3                	mov    %eax,%ebx
  802087:	83 c4 20             	add    $0x20,%esp
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 55                	js     8020e3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80208e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802094:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802097:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802099:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020a3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8020be:	e8 ba f0 ff ff       	call   80117d <fd2num>
  8020c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c8:	83 c4 04             	add    $0x4,%esp
  8020cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ce:	e8 aa f0 ff ff       	call   80117d <fd2num>
  8020d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e1:	eb 30                	jmp    802113 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020e3:	83 ec 08             	sub    $0x8,%esp
  8020e6:	56                   	push   %esi
  8020e7:	6a 00                	push   $0x0
  8020e9:	e8 da ea ff ff       	call   800bc8 <sys_page_unmap>
  8020ee:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020f1:	83 ec 08             	sub    $0x8,%esp
  8020f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f7:	6a 00                	push   $0x0
  8020f9:	e8 ca ea ff ff       	call   800bc8 <sys_page_unmap>
  8020fe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802101:	83 ec 08             	sub    $0x8,%esp
  802104:	ff 75 f4             	pushl  -0xc(%ebp)
  802107:	6a 00                	push   $0x0
  802109:	e8 ba ea ff ff       	call   800bc8 <sys_page_unmap>
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802113:	89 d0                	mov    %edx,%eax
  802115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802118:	5b                   	pop    %ebx
  802119:	5e                   	pop    %esi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802125:	50                   	push   %eax
  802126:	ff 75 08             	pushl  0x8(%ebp)
  802129:	e8 c5 f0 ff ff       	call   8011f3 <fd_lookup>
  80212e:	83 c4 10             	add    $0x10,%esp
  802131:	85 c0                	test   %eax,%eax
  802133:	78 18                	js     80214d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802135:	83 ec 0c             	sub    $0xc,%esp
  802138:	ff 75 f4             	pushl  -0xc(%ebp)
  80213b:	e8 4d f0 ff ff       	call   80118d <fd2data>
	return _pipeisclosed(fd, p);
  802140:	89 c2                	mov    %eax,%edx
  802142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802145:	e8 21 fd ff ff       	call   801e6b <_pipeisclosed>
  80214a:	83 c4 10             	add    $0x10,%esp
}
  80214d:	c9                   	leave  
  80214e:	c3                   	ret    

0080214f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802152:	b8 00 00 00 00       	mov    $0x0,%eax
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80215f:	68 83 2c 80 00       	push   $0x802c83
  802164:	ff 75 0c             	pushl  0xc(%ebp)
  802167:	e8 d4 e5 ff ff       	call   800740 <strcpy>
	return 0;
}
  80216c:	b8 00 00 00 00       	mov    $0x0,%eax
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	57                   	push   %edi
  802177:	56                   	push   %esi
  802178:	53                   	push   %ebx
  802179:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80217f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802184:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218a:	eb 2d                	jmp    8021b9 <devcons_write+0x46>
		m = n - tot;
  80218c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802191:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802194:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802199:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219c:	83 ec 04             	sub    $0x4,%esp
  80219f:	53                   	push   %ebx
  8021a0:	03 45 0c             	add    0xc(%ebp),%eax
  8021a3:	50                   	push   %eax
  8021a4:	57                   	push   %edi
  8021a5:	e8 28 e7 ff ff       	call   8008d2 <memmove>
		sys_cputs(buf, m);
  8021aa:	83 c4 08             	add    $0x8,%esp
  8021ad:	53                   	push   %ebx
  8021ae:	57                   	push   %edi
  8021af:	e8 d3 e8 ff ff       	call   800a87 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b4:	01 de                	add    %ebx,%esi
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021be:	72 cc                	jb     80218c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    

008021c8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 08             	sub    $0x8,%esp
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d7:	74 2a                	je     802203 <devcons_read+0x3b>
  8021d9:	eb 05                	jmp    8021e0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021db:	e8 44 e9 ff ff       	call   800b24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021e0:	e8 c0 e8 ff ff       	call   800aa5 <sys_cgetc>
  8021e5:	85 c0                	test   %eax,%eax
  8021e7:	74 f2                	je     8021db <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	78 16                	js     802203 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ed:	83 f8 04             	cmp    $0x4,%eax
  8021f0:	74 0c                	je     8021fe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f5:	88 02                	mov    %al,(%edx)
	return 1;
  8021f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fc:	eb 05                	jmp    802203 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802211:	6a 01                	push   $0x1
  802213:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802216:	50                   	push   %eax
  802217:	e8 6b e8 ff ff       	call   800a87 <sys_cputs>
}
  80221c:	83 c4 10             	add    $0x10,%esp
  80221f:	c9                   	leave  
  802220:	c3                   	ret    

00802221 <getchar>:

int
getchar(void)
{
  802221:	55                   	push   %ebp
  802222:	89 e5                	mov    %esp,%ebp
  802224:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802227:	6a 01                	push   $0x1
  802229:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222c:	50                   	push   %eax
  80222d:	6a 00                	push   $0x0
  80222f:	e8 25 f2 ff ff       	call   801459 <read>
	if (r < 0)
  802234:	83 c4 10             	add    $0x10,%esp
  802237:	85 c0                	test   %eax,%eax
  802239:	78 0f                	js     80224a <getchar+0x29>
		return r;
	if (r < 1)
  80223b:	85 c0                	test   %eax,%eax
  80223d:	7e 06                	jle    802245 <getchar+0x24>
		return -E_EOF;
	return c;
  80223f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802243:	eb 05                	jmp    80224a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802245:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802252:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802255:	50                   	push   %eax
  802256:	ff 75 08             	pushl  0x8(%ebp)
  802259:	e8 95 ef ff ff       	call   8011f3 <fd_lookup>
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	85 c0                	test   %eax,%eax
  802263:	78 11                	js     802276 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802268:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80226e:	39 10                	cmp    %edx,(%eax)
  802270:	0f 94 c0             	sete   %al
  802273:	0f b6 c0             	movzbl %al,%eax
}
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <opencons>:

int
opencons(void)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80227e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802281:	50                   	push   %eax
  802282:	e8 1d ef ff ff       	call   8011a4 <fd_alloc>
  802287:	83 c4 10             	add    $0x10,%esp
		return r;
  80228a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228c:	85 c0                	test   %eax,%eax
  80228e:	78 3e                	js     8022ce <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802290:	83 ec 04             	sub    $0x4,%esp
  802293:	68 07 04 00 00       	push   $0x407
  802298:	ff 75 f4             	pushl  -0xc(%ebp)
  80229b:	6a 00                	push   $0x0
  80229d:	e8 a1 e8 ff ff       	call   800b43 <sys_page_alloc>
  8022a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	78 23                	js     8022ce <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022ab:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c0:	83 ec 0c             	sub    $0xc,%esp
  8022c3:	50                   	push   %eax
  8022c4:	e8 b4 ee ff ff       	call   80117d <fd2num>
  8022c9:	89 c2                	mov    %eax,%edx
  8022cb:	83 c4 10             	add    $0x10,%esp
}
  8022ce:	89 d0                	mov    %edx,%eax
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	56                   	push   %esi
  8022d6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022d7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022da:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022e0:	e8 20 e8 ff ff       	call   800b05 <sys_getenvid>
  8022e5:	83 ec 0c             	sub    $0xc,%esp
  8022e8:	ff 75 0c             	pushl  0xc(%ebp)
  8022eb:	ff 75 08             	pushl  0x8(%ebp)
  8022ee:	56                   	push   %esi
  8022ef:	50                   	push   %eax
  8022f0:	68 90 2c 80 00       	push   $0x802c90
  8022f5:	e8 c1 de ff ff       	call   8001bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022fa:	83 c4 18             	add    $0x18,%esp
  8022fd:	53                   	push   %ebx
  8022fe:	ff 75 10             	pushl  0x10(%ebp)
  802301:	e8 64 de ff ff       	call   80016a <vcprintf>
	cprintf("\n");
  802306:	c7 04 24 1a 2a 80 00 	movl   $0x802a1a,(%esp)
  80230d:	e8 a9 de ff ff       	call   8001bb <cprintf>
  802312:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802315:	cc                   	int3   
  802316:	eb fd                	jmp    802315 <_panic+0x43>

00802318 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80231e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802325:	75 2c                	jne    802353 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802327:	83 ec 04             	sub    $0x4,%esp
  80232a:	6a 07                	push   $0x7
  80232c:	68 00 f0 bf ee       	push   $0xeebff000
  802331:	6a 00                	push   $0x0
  802333:	e8 0b e8 ff ff       	call   800b43 <sys_page_alloc>
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	85 c0                	test   %eax,%eax
  80233d:	79 14                	jns    802353 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  80233f:	83 ec 04             	sub    $0x4,%esp
  802342:	68 b3 2c 80 00       	push   $0x802cb3
  802347:	6a 22                	push   $0x22
  802349:	68 ca 2c 80 00       	push   $0x802cca
  80234e:	e8 7f ff ff ff       	call   8022d2 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  802353:	8b 45 08             	mov    0x8(%ebp),%eax
  802356:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80235b:	83 ec 08             	sub    $0x8,%esp
  80235e:	68 87 23 80 00       	push   $0x802387
  802363:	6a 00                	push   $0x0
  802365:	e8 24 e9 ff ff       	call   800c8e <sys_env_set_pgfault_upcall>
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	85 c0                	test   %eax,%eax
  80236f:	79 14                	jns    802385 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  802371:	83 ec 04             	sub    $0x4,%esp
  802374:	68 d8 2c 80 00       	push   $0x802cd8
  802379:	6a 27                	push   $0x27
  80237b:	68 ca 2c 80 00       	push   $0x802cca
  802380:	e8 4d ff ff ff       	call   8022d2 <_panic>
    
}
  802385:	c9                   	leave  
  802386:	c3                   	ret    

00802387 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802387:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802388:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80238d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80238f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  802392:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  802396:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  80239b:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80239f:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8023a1:	83 c4 08             	add    $0x8,%esp
	popal
  8023a4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8023a5:	83 c4 04             	add    $0x4,%esp
	popfl
  8023a8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023a9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023aa:	c3                   	ret    

008023ab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b1:	89 d0                	mov    %edx,%eax
  8023b3:	c1 e8 16             	shr    $0x16,%eax
  8023b6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023bd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023c2:	f6 c1 01             	test   $0x1,%cl
  8023c5:	74 1d                	je     8023e4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023c7:	c1 ea 0c             	shr    $0xc,%edx
  8023ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023d1:	f6 c2 01             	test   $0x1,%dl
  8023d4:	74 0e                	je     8023e4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023d6:	c1 ea 0c             	shr    $0xc,%edx
  8023d9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023e0:	ef 
  8023e1:	0f b7 c0             	movzwl %ax,%eax
}
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
  8023e6:	66 90                	xchg   %ax,%ax
  8023e8:	66 90                	xchg   %ax,%ax
  8023ea:	66 90                	xchg   %ax,%ax
  8023ec:	66 90                	xchg   %ax,%ax
  8023ee:	66 90                	xchg   %ax,%ax

008023f0 <__udivdi3>:
  8023f0:	55                   	push   %ebp
  8023f1:	57                   	push   %edi
  8023f2:	56                   	push   %esi
  8023f3:	53                   	push   %ebx
  8023f4:	83 ec 1c             	sub    $0x1c,%esp
  8023f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802403:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802407:	85 f6                	test   %esi,%esi
  802409:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80240d:	89 ca                	mov    %ecx,%edx
  80240f:	89 f8                	mov    %edi,%eax
  802411:	75 3d                	jne    802450 <__udivdi3+0x60>
  802413:	39 cf                	cmp    %ecx,%edi
  802415:	0f 87 c5 00 00 00    	ja     8024e0 <__udivdi3+0xf0>
  80241b:	85 ff                	test   %edi,%edi
  80241d:	89 fd                	mov    %edi,%ebp
  80241f:	75 0b                	jne    80242c <__udivdi3+0x3c>
  802421:	b8 01 00 00 00       	mov    $0x1,%eax
  802426:	31 d2                	xor    %edx,%edx
  802428:	f7 f7                	div    %edi
  80242a:	89 c5                	mov    %eax,%ebp
  80242c:	89 c8                	mov    %ecx,%eax
  80242e:	31 d2                	xor    %edx,%edx
  802430:	f7 f5                	div    %ebp
  802432:	89 c1                	mov    %eax,%ecx
  802434:	89 d8                	mov    %ebx,%eax
  802436:	89 cf                	mov    %ecx,%edi
  802438:	f7 f5                	div    %ebp
  80243a:	89 c3                	mov    %eax,%ebx
  80243c:	89 d8                	mov    %ebx,%eax
  80243e:	89 fa                	mov    %edi,%edx
  802440:	83 c4 1c             	add    $0x1c,%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5f                   	pop    %edi
  802446:	5d                   	pop    %ebp
  802447:	c3                   	ret    
  802448:	90                   	nop
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	39 ce                	cmp    %ecx,%esi
  802452:	77 74                	ja     8024c8 <__udivdi3+0xd8>
  802454:	0f bd fe             	bsr    %esi,%edi
  802457:	83 f7 1f             	xor    $0x1f,%edi
  80245a:	0f 84 98 00 00 00    	je     8024f8 <__udivdi3+0x108>
  802460:	bb 20 00 00 00       	mov    $0x20,%ebx
  802465:	89 f9                	mov    %edi,%ecx
  802467:	89 c5                	mov    %eax,%ebp
  802469:	29 fb                	sub    %edi,%ebx
  80246b:	d3 e6                	shl    %cl,%esi
  80246d:	89 d9                	mov    %ebx,%ecx
  80246f:	d3 ed                	shr    %cl,%ebp
  802471:	89 f9                	mov    %edi,%ecx
  802473:	d3 e0                	shl    %cl,%eax
  802475:	09 ee                	or     %ebp,%esi
  802477:	89 d9                	mov    %ebx,%ecx
  802479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80247d:	89 d5                	mov    %edx,%ebp
  80247f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802483:	d3 ed                	shr    %cl,%ebp
  802485:	89 f9                	mov    %edi,%ecx
  802487:	d3 e2                	shl    %cl,%edx
  802489:	89 d9                	mov    %ebx,%ecx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	09 c2                	or     %eax,%edx
  80248f:	89 d0                	mov    %edx,%eax
  802491:	89 ea                	mov    %ebp,%edx
  802493:	f7 f6                	div    %esi
  802495:	89 d5                	mov    %edx,%ebp
  802497:	89 c3                	mov    %eax,%ebx
  802499:	f7 64 24 0c          	mull   0xc(%esp)
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	72 10                	jb     8024b1 <__udivdi3+0xc1>
  8024a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e6                	shl    %cl,%esi
  8024a9:	39 c6                	cmp    %eax,%esi
  8024ab:	73 07                	jae    8024b4 <__udivdi3+0xc4>
  8024ad:	39 d5                	cmp    %edx,%ebp
  8024af:	75 03                	jne    8024b4 <__udivdi3+0xc4>
  8024b1:	83 eb 01             	sub    $0x1,%ebx
  8024b4:	31 ff                	xor    %edi,%edi
  8024b6:	89 d8                	mov    %ebx,%eax
  8024b8:	89 fa                	mov    %edi,%edx
  8024ba:	83 c4 1c             	add    $0x1c,%esp
  8024bd:	5b                   	pop    %ebx
  8024be:	5e                   	pop    %esi
  8024bf:	5f                   	pop    %edi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    
  8024c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024c8:	31 ff                	xor    %edi,%edi
  8024ca:	31 db                	xor    %ebx,%ebx
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	89 fa                	mov    %edi,%edx
  8024d0:	83 c4 1c             	add    $0x1c,%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    
  8024d8:	90                   	nop
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	89 d8                	mov    %ebx,%eax
  8024e2:	f7 f7                	div    %edi
  8024e4:	31 ff                	xor    %edi,%edi
  8024e6:	89 c3                	mov    %eax,%ebx
  8024e8:	89 d8                	mov    %ebx,%eax
  8024ea:	89 fa                	mov    %edi,%edx
  8024ec:	83 c4 1c             	add    $0x1c,%esp
  8024ef:	5b                   	pop    %ebx
  8024f0:	5e                   	pop    %esi
  8024f1:	5f                   	pop    %edi
  8024f2:	5d                   	pop    %ebp
  8024f3:	c3                   	ret    
  8024f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024f8:	39 ce                	cmp    %ecx,%esi
  8024fa:	72 0c                	jb     802508 <__udivdi3+0x118>
  8024fc:	31 db                	xor    %ebx,%ebx
  8024fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802502:	0f 87 34 ff ff ff    	ja     80243c <__udivdi3+0x4c>
  802508:	bb 01 00 00 00       	mov    $0x1,%ebx
  80250d:	e9 2a ff ff ff       	jmp    80243c <__udivdi3+0x4c>
  802512:	66 90                	xchg   %ax,%ax
  802514:	66 90                	xchg   %ax,%ax
  802516:	66 90                	xchg   %ax,%ax
  802518:	66 90                	xchg   %ax,%ax
  80251a:	66 90                	xchg   %ax,%ax
  80251c:	66 90                	xchg   %ax,%ax
  80251e:	66 90                	xchg   %ax,%ax

00802520 <__umoddi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	53                   	push   %ebx
  802524:	83 ec 1c             	sub    $0x1c,%esp
  802527:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80252b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80252f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802533:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802537:	85 d2                	test   %edx,%edx
  802539:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80253d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802541:	89 f3                	mov    %esi,%ebx
  802543:	89 3c 24             	mov    %edi,(%esp)
  802546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80254a:	75 1c                	jne    802568 <__umoddi3+0x48>
  80254c:	39 f7                	cmp    %esi,%edi
  80254e:	76 50                	jbe    8025a0 <__umoddi3+0x80>
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	f7 f7                	div    %edi
  802556:	89 d0                	mov    %edx,%eax
  802558:	31 d2                	xor    %edx,%edx
  80255a:	83 c4 1c             	add    $0x1c,%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5f                   	pop    %edi
  802560:	5d                   	pop    %ebp
  802561:	c3                   	ret    
  802562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802568:	39 f2                	cmp    %esi,%edx
  80256a:	89 d0                	mov    %edx,%eax
  80256c:	77 52                	ja     8025c0 <__umoddi3+0xa0>
  80256e:	0f bd ea             	bsr    %edx,%ebp
  802571:	83 f5 1f             	xor    $0x1f,%ebp
  802574:	75 5a                	jne    8025d0 <__umoddi3+0xb0>
  802576:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80257a:	0f 82 e0 00 00 00    	jb     802660 <__umoddi3+0x140>
  802580:	39 0c 24             	cmp    %ecx,(%esp)
  802583:	0f 86 d7 00 00 00    	jbe    802660 <__umoddi3+0x140>
  802589:	8b 44 24 08          	mov    0x8(%esp),%eax
  80258d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802591:	83 c4 1c             	add    $0x1c,%esp
  802594:	5b                   	pop    %ebx
  802595:	5e                   	pop    %esi
  802596:	5f                   	pop    %edi
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	85 ff                	test   %edi,%edi
  8025a2:	89 fd                	mov    %edi,%ebp
  8025a4:	75 0b                	jne    8025b1 <__umoddi3+0x91>
  8025a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	f7 f7                	div    %edi
  8025af:	89 c5                	mov    %eax,%ebp
  8025b1:	89 f0                	mov    %esi,%eax
  8025b3:	31 d2                	xor    %edx,%edx
  8025b5:	f7 f5                	div    %ebp
  8025b7:	89 c8                	mov    %ecx,%eax
  8025b9:	f7 f5                	div    %ebp
  8025bb:	89 d0                	mov    %edx,%eax
  8025bd:	eb 99                	jmp    802558 <__umoddi3+0x38>
  8025bf:	90                   	nop
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 f2                	mov    %esi,%edx
  8025c4:	83 c4 1c             	add    $0x1c,%esp
  8025c7:	5b                   	pop    %ebx
  8025c8:	5e                   	pop    %esi
  8025c9:	5f                   	pop    %edi
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    
  8025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	8b 34 24             	mov    (%esp),%esi
  8025d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025d8:	89 e9                	mov    %ebp,%ecx
  8025da:	29 ef                	sub    %ebp,%edi
  8025dc:	d3 e0                	shl    %cl,%eax
  8025de:	89 f9                	mov    %edi,%ecx
  8025e0:	89 f2                	mov    %esi,%edx
  8025e2:	d3 ea                	shr    %cl,%edx
  8025e4:	89 e9                	mov    %ebp,%ecx
  8025e6:	09 c2                	or     %eax,%edx
  8025e8:	89 d8                	mov    %ebx,%eax
  8025ea:	89 14 24             	mov    %edx,(%esp)
  8025ed:	89 f2                	mov    %esi,%edx
  8025ef:	d3 e2                	shl    %cl,%edx
  8025f1:	89 f9                	mov    %edi,%ecx
  8025f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025fb:	d3 e8                	shr    %cl,%eax
  8025fd:	89 e9                	mov    %ebp,%ecx
  8025ff:	89 c6                	mov    %eax,%esi
  802601:	d3 e3                	shl    %cl,%ebx
  802603:	89 f9                	mov    %edi,%ecx
  802605:	89 d0                	mov    %edx,%eax
  802607:	d3 e8                	shr    %cl,%eax
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	09 d8                	or     %ebx,%eax
  80260d:	89 d3                	mov    %edx,%ebx
  80260f:	89 f2                	mov    %esi,%edx
  802611:	f7 34 24             	divl   (%esp)
  802614:	89 d6                	mov    %edx,%esi
  802616:	d3 e3                	shl    %cl,%ebx
  802618:	f7 64 24 04          	mull   0x4(%esp)
  80261c:	39 d6                	cmp    %edx,%esi
  80261e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802622:	89 d1                	mov    %edx,%ecx
  802624:	89 c3                	mov    %eax,%ebx
  802626:	72 08                	jb     802630 <__umoddi3+0x110>
  802628:	75 11                	jne    80263b <__umoddi3+0x11b>
  80262a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80262e:	73 0b                	jae    80263b <__umoddi3+0x11b>
  802630:	2b 44 24 04          	sub    0x4(%esp),%eax
  802634:	1b 14 24             	sbb    (%esp),%edx
  802637:	89 d1                	mov    %edx,%ecx
  802639:	89 c3                	mov    %eax,%ebx
  80263b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80263f:	29 da                	sub    %ebx,%edx
  802641:	19 ce                	sbb    %ecx,%esi
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 f0                	mov    %esi,%eax
  802647:	d3 e0                	shl    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	d3 ea                	shr    %cl,%edx
  80264d:	89 e9                	mov    %ebp,%ecx
  80264f:	d3 ee                	shr    %cl,%esi
  802651:	09 d0                	or     %edx,%eax
  802653:	89 f2                	mov    %esi,%edx
  802655:	83 c4 1c             	add    $0x1c,%esp
  802658:	5b                   	pop    %ebx
  802659:	5e                   	pop    %esi
  80265a:	5f                   	pop    %edi
  80265b:	5d                   	pop    %ebp
  80265c:	c3                   	ret    
  80265d:	8d 76 00             	lea    0x0(%esi),%esi
  802660:	29 f9                	sub    %edi,%ecx
  802662:	19 d6                	sbb    %edx,%esi
  802664:	89 74 24 04          	mov    %esi,0x4(%esp)
  802668:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80266c:	e9 18 ff ff ff       	jmp    802589 <__umoddi3+0x69>
