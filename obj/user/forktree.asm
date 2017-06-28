
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 e6 0a 00 00       	call   800b28 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 a0 26 80 00       	push   $0x8026a0
  80004c:	e8 8d 01 00 00       	call   8001de <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 a7 06 00 00       	call   80072a <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 b1 26 80 00       	push   $0x8026b1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 6b 06 00 00       	call   800710 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 e4 0d 00 00       	call   800e91 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 6f 00 00 00       	call   800131 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 1b 2a 80 00       	push   $0x802a1b
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ec:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000f3:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f6:	e8 2d 0a 00 00       	call   800b28 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x37>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	e8 aa ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800122:	e8 0a 00 00 00       	call   800131 <exit>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800137:	e8 35 11 00 00       	call   801271 <close_all>
	sys_env_destroy(0);
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	6a 00                	push   $0x0
  800141:	e8 a1 09 00 00       	call   800ae7 <sys_env_destroy>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	53                   	push   %ebx
  80014f:	83 ec 04             	sub    $0x4,%esp
  800152:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800155:	8b 13                	mov    (%ebx),%edx
  800157:	8d 42 01             	lea    0x1(%edx),%eax
  80015a:	89 03                	mov    %eax,(%ebx)
  80015c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800163:	3d ff 00 00 00       	cmp    $0xff,%eax
  800168:	75 1a                	jne    800184 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	68 ff 00 00 00       	push   $0xff
  800172:	8d 43 08             	lea    0x8(%ebx),%eax
  800175:	50                   	push   %eax
  800176:	e8 2f 09 00 00       	call   800aaa <sys_cputs>
		b->idx = 0;
  80017b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800181:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800184:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800196:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019d:	00 00 00 
	b.cnt = 0;
  8001a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	68 4b 01 80 00       	push   $0x80014b
  8001bc:	e8 54 01 00 00       	call   800315 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c1:	83 c4 08             	add    $0x8,%esp
  8001c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 d4 08 00 00       	call   800aaa <sys_cputs>

	return b.cnt;
}
  8001d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    

008001de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e7:	50                   	push   %eax
  8001e8:	ff 75 08             	pushl  0x8(%ebp)
  8001eb:	e8 9d ff ff ff       	call   80018d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    

008001f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 1c             	sub    $0x1c,%esp
  8001fb:	89 c7                	mov    %eax,%edi
  8001fd:	89 d6                	mov    %edx,%esi
  8001ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800202:	8b 55 0c             	mov    0xc(%ebp),%edx
  800205:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800208:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800213:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800216:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800219:	39 d3                	cmp    %edx,%ebx
  80021b:	72 05                	jb     800222 <printnum+0x30>
  80021d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800220:	77 45                	ja     800267 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	8b 45 14             	mov    0x14(%ebp),%eax
  80022b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80022e:	53                   	push   %ebx
  80022f:	ff 75 10             	pushl  0x10(%ebp)
  800232:	83 ec 08             	sub    $0x8,%esp
  800235:	ff 75 e4             	pushl  -0x1c(%ebp)
  800238:	ff 75 e0             	pushl  -0x20(%ebp)
  80023b:	ff 75 dc             	pushl  -0x24(%ebp)
  80023e:	ff 75 d8             	pushl  -0x28(%ebp)
  800241:	e8 ca 21 00 00       	call   802410 <__udivdi3>
  800246:	83 c4 18             	add    $0x18,%esp
  800249:	52                   	push   %edx
  80024a:	50                   	push   %eax
  80024b:	89 f2                	mov    %esi,%edx
  80024d:	89 f8                	mov    %edi,%eax
  80024f:	e8 9e ff ff ff       	call   8001f2 <printnum>
  800254:	83 c4 20             	add    $0x20,%esp
  800257:	eb 18                	jmp    800271 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	56                   	push   %esi
  80025d:	ff 75 18             	pushl  0x18(%ebp)
  800260:	ff d7                	call   *%edi
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	eb 03                	jmp    80026a <printnum+0x78>
  800267:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026a:	83 eb 01             	sub    $0x1,%ebx
  80026d:	85 db                	test   %ebx,%ebx
  80026f:	7f e8                	jg     800259 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	56                   	push   %esi
  800275:	83 ec 04             	sub    $0x4,%esp
  800278:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027b:	ff 75 e0             	pushl  -0x20(%ebp)
  80027e:	ff 75 dc             	pushl  -0x24(%ebp)
  800281:	ff 75 d8             	pushl  -0x28(%ebp)
  800284:	e8 b7 22 00 00       	call   802540 <__umoddi3>
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	0f be 80 c0 26 80 00 	movsbl 0x8026c0(%eax),%eax
  800293:	50                   	push   %eax
  800294:	ff d7                	call   *%edi
}
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a4:	83 fa 01             	cmp    $0x1,%edx
  8002a7:	7e 0e                	jle    8002b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	8b 52 04             	mov    0x4(%edx),%edx
  8002b5:	eb 22                	jmp    8002d9 <getuint+0x38>
	else if (lflag)
  8002b7:	85 d2                	test   %edx,%edx
  8002b9:	74 10                	je     8002cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c9:	eb 0e                	jmp    8002d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ea:	73 0a                	jae    8002f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	88 02                	mov    %al,(%edx)
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800301:	50                   	push   %eax
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	ff 75 0c             	pushl  0xc(%ebp)
  800308:	ff 75 08             	pushl  0x8(%ebp)
  80030b:	e8 05 00 00 00       	call   800315 <vprintfmt>
	va_end(ap);
}
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 2c             	sub    $0x2c,%esp
  80031e:	8b 75 08             	mov    0x8(%ebp),%esi
  800321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800324:	8b 7d 10             	mov    0x10(%ebp),%edi
  800327:	eb 12                	jmp    80033b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800329:	85 c0                	test   %eax,%eax
  80032b:	0f 84 89 03 00 00    	je     8006ba <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	53                   	push   %ebx
  800335:	50                   	push   %eax
  800336:	ff d6                	call   *%esi
  800338:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033b:	83 c7 01             	add    $0x1,%edi
  80033e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800342:	83 f8 25             	cmp    $0x25,%eax
  800345:	75 e2                	jne    800329 <vprintfmt+0x14>
  800347:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80034b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800359:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800360:	ba 00 00 00 00       	mov    $0x0,%edx
  800365:	eb 07                	jmp    80036e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8d 47 01             	lea    0x1(%edi),%eax
  800371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800374:	0f b6 07             	movzbl (%edi),%eax
  800377:	0f b6 c8             	movzbl %al,%ecx
  80037a:	83 e8 23             	sub    $0x23,%eax
  80037d:	3c 55                	cmp    $0x55,%al
  80037f:	0f 87 1a 03 00 00    	ja     80069f <vprintfmt+0x38a>
  800385:	0f b6 c0             	movzbl %al,%eax
  800388:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800392:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800396:	eb d6                	jmp    80036e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003aa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ad:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003b0:	83 fa 09             	cmp    $0x9,%edx
  8003b3:	77 39                	ja     8003ee <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b8:	eb e9                	jmp    8003a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c3:	8b 00                	mov    (%eax),%eax
  8003c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cb:	eb 27                	jmp    8003f4 <vprintfmt+0xdf>
  8003cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d7:	0f 49 c8             	cmovns %eax,%ecx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	eb 8c                	jmp    80036e <vprintfmt+0x59>
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ec:	eb 80                	jmp    80036e <vprintfmt+0x59>
  8003ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f8:	0f 89 70 ff ff ff    	jns    80036e <vprintfmt+0x59>
				width = precision, precision = -1;
  8003fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800401:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800404:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040b:	e9 5e ff ff ff       	jmp    80036e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800410:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800416:	e9 53 ff ff ff       	jmp    80036e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	53                   	push   %ebx
  800428:	ff 30                	pushl  (%eax)
  80042a:	ff d6                	call   *%esi
			break;
  80042c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800432:	e9 04 ff ff ff       	jmp    80033b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 50 04             	lea    0x4(%eax),%edx
  80043d:	89 55 14             	mov    %edx,0x14(%ebp)
  800440:	8b 00                	mov    (%eax),%eax
  800442:	99                   	cltd   
  800443:	31 d0                	xor    %edx,%eax
  800445:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 0f             	cmp    $0xf,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x142>
  80044c:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800453:	85 d2                	test   %edx,%edx
  800455:	75 18                	jne    80046f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800457:	50                   	push   %eax
  800458:	68 d8 26 80 00       	push   $0x8026d8
  80045d:	53                   	push   %ebx
  80045e:	56                   	push   %esi
  80045f:	e8 94 fe ff ff       	call   8002f8 <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046a:	e9 cc fe ff ff       	jmp    80033b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80046f:	52                   	push   %edx
  800470:	68 ed 2b 80 00       	push   $0x802bed
  800475:	53                   	push   %ebx
  800476:	56                   	push   %esi
  800477:	e8 7c fe ff ff       	call   8002f8 <printfmt>
  80047c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800482:	e9 b4 fe ff ff       	jmp    80033b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 50 04             	lea    0x4(%eax),%edx
  80048d:	89 55 14             	mov    %edx,0x14(%ebp)
  800490:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800492:	85 ff                	test   %edi,%edi
  800494:	b8 d1 26 80 00       	mov    $0x8026d1,%eax
  800499:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a0:	0f 8e 94 00 00 00    	jle    80053a <vprintfmt+0x225>
  8004a6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004aa:	0f 84 98 00 00 00    	je     800548 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b6:	57                   	push   %edi
  8004b7:	e8 86 02 00 00       	call   800742 <strnlen>
  8004bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004bf:	29 c1                	sub    %eax,%ecx
  8004c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	eb 0f                	jmp    8004e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004dc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004de:	83 ef 01             	sub    $0x1,%edi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	85 ff                	test   %edi,%edi
  8004e6:	7f ed                	jg     8004d5 <vprintfmt+0x1c0>
  8004e8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004eb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ee:	85 c9                	test   %ecx,%ecx
  8004f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f5:	0f 49 c1             	cmovns %ecx,%eax
  8004f8:	29 c1                	sub    %eax,%ecx
  8004fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800503:	89 cb                	mov    %ecx,%ebx
  800505:	eb 4d                	jmp    800554 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050b:	74 1b                	je     800528 <vprintfmt+0x213>
  80050d:	0f be c0             	movsbl %al,%eax
  800510:	83 e8 20             	sub    $0x20,%eax
  800513:	83 f8 5e             	cmp    $0x5e,%eax
  800516:	76 10                	jbe    800528 <vprintfmt+0x213>
					putch('?', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	6a 3f                	push   $0x3f
  800520:	ff 55 08             	call   *0x8(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	eb 0d                	jmp    800535 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	52                   	push   %edx
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800535:	83 eb 01             	sub    $0x1,%ebx
  800538:	eb 1a                	jmp    800554 <vprintfmt+0x23f>
  80053a:	89 75 08             	mov    %esi,0x8(%ebp)
  80053d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800540:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800543:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800546:	eb 0c                	jmp    800554 <vprintfmt+0x23f>
  800548:	89 75 08             	mov    %esi,0x8(%ebp)
  80054b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800551:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800554:	83 c7 01             	add    $0x1,%edi
  800557:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055b:	0f be d0             	movsbl %al,%edx
  80055e:	85 d2                	test   %edx,%edx
  800560:	74 23                	je     800585 <vprintfmt+0x270>
  800562:	85 f6                	test   %esi,%esi
  800564:	78 a1                	js     800507 <vprintfmt+0x1f2>
  800566:	83 ee 01             	sub    $0x1,%esi
  800569:	79 9c                	jns    800507 <vprintfmt+0x1f2>
  80056b:	89 df                	mov    %ebx,%edi
  80056d:	8b 75 08             	mov    0x8(%ebp),%esi
  800570:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800573:	eb 18                	jmp    80058d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	53                   	push   %ebx
  800579:	6a 20                	push   $0x20
  80057b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057d:	83 ef 01             	sub    $0x1,%edi
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	eb 08                	jmp    80058d <vprintfmt+0x278>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	85 ff                	test   %edi,%edi
  80058f:	7f e4                	jg     800575 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800594:	e9 a2 fd ff ff       	jmp    80033b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800599:	83 fa 01             	cmp    $0x1,%edx
  80059c:	7e 16                	jle    8005b4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 50 08             	lea    0x8(%eax),%edx
  8005a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a7:	8b 50 04             	mov    0x4(%eax),%edx
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b2:	eb 32                	jmp    8005e6 <vprintfmt+0x2d1>
	else if (lflag)
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 18                	je     8005d0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ce:	eb 16                	jmp    8005e6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	89 c1                	mov    %eax,%ecx
  8005e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f5:	79 74                	jns    80066b <vprintfmt+0x356>
				putch('-', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 2d                	push   $0x2d
  8005fd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800602:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800605:	f7 d8                	neg    %eax
  800607:	83 d2 00             	adc    $0x0,%edx
  80060a:	f7 da                	neg    %edx
  80060c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800614:	eb 55                	jmp    80066b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 83 fc ff ff       	call   8002a1 <getuint>
			base = 10;
  80061e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800623:	eb 46                	jmp    80066b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 74 fc ff ff       	call   8002a1 <getuint>
		        base = 8;
  80062d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800632:	eb 37                	jmp    80066b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 30                	push   $0x30
  80063a:	ff d6                	call   *%esi
			putch('x', putdat);
  80063c:	83 c4 08             	add    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 78                	push   $0x78
  800642:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800657:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80065c:	eb 0d                	jmp    80066b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 3b fc ff ff       	call   8002a1 <getuint>
			base = 16;
  800666:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066b:	83 ec 0c             	sub    $0xc,%esp
  80066e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800672:	57                   	push   %edi
  800673:	ff 75 e0             	pushl  -0x20(%ebp)
  800676:	51                   	push   %ecx
  800677:	52                   	push   %edx
  800678:	50                   	push   %eax
  800679:	89 da                	mov    %ebx,%edx
  80067b:	89 f0                	mov    %esi,%eax
  80067d:	e8 70 fb ff ff       	call   8001f2 <printnum>
			break;
  800682:	83 c4 20             	add    $0x20,%esp
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800688:	e9 ae fc ff ff       	jmp    80033b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	51                   	push   %ecx
  800692:	ff d6                	call   *%esi
			break;
  800694:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069a:	e9 9c fc ff ff       	jmp    80033b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 03                	jmp    8006af <vprintfmt+0x39a>
  8006ac:	83 ef 01             	sub    $0x1,%edi
  8006af:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b3:	75 f7                	jne    8006ac <vprintfmt+0x397>
  8006b5:	e9 81 fc ff ff       	jmp    80033b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5f                   	pop    %edi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 18             	sub    $0x18,%esp
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 26                	je     800709 <vsnprintf+0x47>
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	7e 22                	jle    800709 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e7:	ff 75 14             	pushl  0x14(%ebp)
  8006ea:	ff 75 10             	pushl  0x10(%ebp)
  8006ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	68 db 02 80 00       	push   $0x8002db
  8006f6:	e8 1a fc ff ff       	call   800315 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 05                	jmp    80070e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800709:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800719:	50                   	push   %eax
  80071a:	ff 75 10             	pushl  0x10(%ebp)
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	ff 75 08             	pushl  0x8(%ebp)
  800723:	e8 9a ff ff ff       	call   8006c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	b8 00 00 00 00       	mov    $0x0,%eax
  800735:	eb 03                	jmp    80073a <strlen+0x10>
		n++;
  800737:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073e:	75 f7                	jne    800737 <strlen+0xd>
		n++;
	return n;
}
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800748:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	ba 00 00 00 00       	mov    $0x0,%edx
  800750:	eb 03                	jmp    800755 <strnlen+0x13>
		n++;
  800752:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800755:	39 c2                	cmp    %eax,%edx
  800757:	74 08                	je     800761 <strnlen+0x1f>
  800759:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80075d:	75 f3                	jne    800752 <strnlen+0x10>
  80075f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	89 c2                	mov    %eax,%edx
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	83 c1 01             	add    $0x1,%ecx
  800775:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800779:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077c:	84 db                	test   %bl,%bl
  80077e:	75 ef                	jne    80076f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	53                   	push   %ebx
  80078b:	e8 9a ff ff ff       	call   80072a <strlen>
  800790:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	01 d8                	add    %ebx,%eax
  800798:	50                   	push   %eax
  800799:	e8 c5 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  80079e:	89 d8                	mov    %ebx,%eax
  8007a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	89 f3                	mov    %esi,%ebx
  8007b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	eb 0f                	jmp    8007c8 <strncpy+0x23>
		*dst++ = *src;
  8007b9:	83 c2 01             	add    $0x1,%edx
  8007bc:	0f b6 01             	movzbl (%ecx),%eax
  8007bf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	39 da                	cmp    %ebx,%edx
  8007ca:	75 ed                	jne    8007b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	74 21                	je     800807 <strlcpy+0x35>
  8007e6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	eb 09                	jmp    8007f7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	83 c1 01             	add    $0x1,%ecx
  8007f4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f7:	39 c2                	cmp    %eax,%edx
  8007f9:	74 09                	je     800804 <strlcpy+0x32>
  8007fb:	0f b6 19             	movzbl (%ecx),%ebx
  8007fe:	84 db                	test   %bl,%bl
  800800:	75 ec                	jne    8007ee <strlcpy+0x1c>
  800802:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800804:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800807:	29 f0                	sub    %esi,%eax
}
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800816:	eb 06                	jmp    80081e <strcmp+0x11>
		p++, q++;
  800818:	83 c1 01             	add    $0x1,%ecx
  80081b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081e:	0f b6 01             	movzbl (%ecx),%eax
  800821:	84 c0                	test   %al,%al
  800823:	74 04                	je     800829 <strcmp+0x1c>
  800825:	3a 02                	cmp    (%edx),%al
  800827:	74 ef                	je     800818 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800829:	0f b6 c0             	movzbl %al,%eax
  80082c:	0f b6 12             	movzbl (%edx),%edx
  80082f:	29 d0                	sub    %edx,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	89 c3                	mov    %eax,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800842:	eb 06                	jmp    80084a <strncmp+0x17>
		n--, p++, q++;
  800844:	83 c0 01             	add    $0x1,%eax
  800847:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084a:	39 d8                	cmp    %ebx,%eax
  80084c:	74 15                	je     800863 <strncmp+0x30>
  80084e:	0f b6 08             	movzbl (%eax),%ecx
  800851:	84 c9                	test   %cl,%cl
  800853:	74 04                	je     800859 <strncmp+0x26>
  800855:	3a 0a                	cmp    (%edx),%cl
  800857:	74 eb                	je     800844 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 00             	movzbl (%eax),%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
  800861:	eb 05                	jmp    800868 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800875:	eb 07                	jmp    80087e <strchr+0x13>
		if (*s == c)
  800877:	38 ca                	cmp    %cl,%dl
  800879:	74 0f                	je     80088a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	0f b6 10             	movzbl (%eax),%edx
  800881:	84 d2                	test   %dl,%dl
  800883:	75 f2                	jne    800877 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800896:	eb 03                	jmp    80089b <strfind+0xf>
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089e:	38 ca                	cmp    %cl,%dl
  8008a0:	74 04                	je     8008a6 <strfind+0x1a>
  8008a2:	84 d2                	test   %dl,%dl
  8008a4:	75 f2                	jne    800898 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b4:	85 c9                	test   %ecx,%ecx
  8008b6:	74 36                	je     8008ee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008be:	75 28                	jne    8008e8 <memset+0x40>
  8008c0:	f6 c1 03             	test   $0x3,%cl
  8008c3:	75 23                	jne    8008e8 <memset+0x40>
		c &= 0xFF;
  8008c5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c9:	89 d3                	mov    %edx,%ebx
  8008cb:	c1 e3 08             	shl    $0x8,%ebx
  8008ce:	89 d6                	mov    %edx,%esi
  8008d0:	c1 e6 18             	shl    $0x18,%esi
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	c1 e0 10             	shl    $0x10,%eax
  8008d8:	09 f0                	or     %esi,%eax
  8008da:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008dc:	89 d8                	mov    %ebx,%eax
  8008de:	09 d0                	or     %edx,%eax
  8008e0:	c1 e9 02             	shr    $0x2,%ecx
  8008e3:	fc                   	cld    
  8008e4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e6:	eb 06                	jmp    8008ee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	fc                   	cld    
  8008ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ee:	89 f8                	mov    %edi,%eax
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5f                   	pop    %edi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	57                   	push   %edi
  8008f9:	56                   	push   %esi
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800903:	39 c6                	cmp    %eax,%esi
  800905:	73 35                	jae    80093c <memmove+0x47>
  800907:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090a:	39 d0                	cmp    %edx,%eax
  80090c:	73 2e                	jae    80093c <memmove+0x47>
		s += n;
		d += n;
  80090e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800911:	89 d6                	mov    %edx,%esi
  800913:	09 fe                	or     %edi,%esi
  800915:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091b:	75 13                	jne    800930 <memmove+0x3b>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 0e                	jne    800930 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800922:	83 ef 04             	sub    $0x4,%edi
  800925:	8d 72 fc             	lea    -0x4(%edx),%esi
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fd                   	std    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 09                	jmp    800939 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800930:	83 ef 01             	sub    $0x1,%edi
  800933:	8d 72 ff             	lea    -0x1(%edx),%esi
  800936:	fd                   	std    
  800937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800939:	fc                   	cld    
  80093a:	eb 1d                	jmp    800959 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	09 c2                	or     %eax,%edx
  800940:	f6 c2 03             	test   $0x3,%dl
  800943:	75 0f                	jne    800954 <memmove+0x5f>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 0a                	jne    800954 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	fc                   	cld    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 05                	jmp    800959 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800954:	89 c7                	mov    %eax,%edi
  800956:	fc                   	cld    
  800957:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 87 ff ff ff       	call   8008f5 <memmove>
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	89 c6                	mov    %eax,%esi
  80097d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800980:	eb 1a                	jmp    80099c <memcmp+0x2c>
		if (*s1 != *s2)
  800982:	0f b6 08             	movzbl (%eax),%ecx
  800985:	0f b6 1a             	movzbl (%edx),%ebx
  800988:	38 d9                	cmp    %bl,%cl
  80098a:	74 0a                	je     800996 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80098c:	0f b6 c1             	movzbl %cl,%eax
  80098f:	0f b6 db             	movzbl %bl,%ebx
  800992:	29 d8                	sub    %ebx,%eax
  800994:	eb 0f                	jmp    8009a5 <memcmp+0x35>
		s1++, s2++;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099c:	39 f0                	cmp    %esi,%eax
  80099e:	75 e2                	jne    800982 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b0:	89 c1                	mov    %eax,%ecx
  8009b2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b9:	eb 0a                	jmp    8009c5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bb:	0f b6 10             	movzbl (%eax),%edx
  8009be:	39 da                	cmp    %ebx,%edx
  8009c0:	74 07                	je     8009c9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	39 c8                	cmp    %ecx,%eax
  8009c7:	72 f2                	jb     8009bb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d8:	eb 03                	jmp    8009dd <strtol+0x11>
		s++;
  8009da:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	3c 20                	cmp    $0x20,%al
  8009e2:	74 f6                	je     8009da <strtol+0xe>
  8009e4:	3c 09                	cmp    $0x9,%al
  8009e6:	74 f2                	je     8009da <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e8:	3c 2b                	cmp    $0x2b,%al
  8009ea:	75 0a                	jne    8009f6 <strtol+0x2a>
		s++;
  8009ec:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f4:	eb 11                	jmp    800a07 <strtol+0x3b>
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fb:	3c 2d                	cmp    $0x2d,%al
  8009fd:	75 08                	jne    800a07 <strtol+0x3b>
		s++, neg = 1;
  8009ff:	83 c1 01             	add    $0x1,%ecx
  800a02:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0d:	75 15                	jne    800a24 <strtol+0x58>
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 10                	jne    800a24 <strtol+0x58>
  800a14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a18:	75 7c                	jne    800a96 <strtol+0xca>
		s += 2, base = 16;
  800a1a:	83 c1 02             	add    $0x2,%ecx
  800a1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a22:	eb 16                	jmp    800a3a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a24:	85 db                	test   %ebx,%ebx
  800a26:	75 12                	jne    800a3a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a28:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a30:	75 08                	jne    800a3a <strtol+0x6e>
		s++, base = 8;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a42:	0f b6 11             	movzbl (%ecx),%edx
  800a45:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 09             	cmp    $0x9,%bl
  800a4d:	77 08                	ja     800a57 <strtol+0x8b>
			dig = *s - '0';
  800a4f:	0f be d2             	movsbl %dl,%edx
  800a52:	83 ea 30             	sub    $0x30,%edx
  800a55:	eb 22                	jmp    800a79 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a57:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 19             	cmp    $0x19,%bl
  800a5f:	77 08                	ja     800a69 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a61:	0f be d2             	movsbl %dl,%edx
  800a64:	83 ea 57             	sub    $0x57,%edx
  800a67:	eb 10                	jmp    800a79 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a69:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 19             	cmp    $0x19,%bl
  800a71:	77 16                	ja     800a89 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a73:	0f be d2             	movsbl %dl,%edx
  800a76:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a79:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a7c:	7d 0b                	jge    800a89 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a85:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a87:	eb b9                	jmp    800a42 <strtol+0x76>

	if (endptr)
  800a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8d:	74 0d                	je     800a9c <strtol+0xd0>
		*endptr = (char *) s;
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	89 0e                	mov    %ecx,(%esi)
  800a94:	eb 06                	jmp    800a9c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a96:	85 db                	test   %ebx,%ebx
  800a98:	74 98                	je     800a32 <strtol+0x66>
  800a9a:	eb 9e                	jmp    800a3a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a9c:	89 c2                	mov    %eax,%edx
  800a9e:	f7 da                	neg    %edx
  800aa0:	85 ff                	test   %edi,%edi
  800aa2:	0f 45 c2             	cmovne %edx,%eax
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	89 c3                	mov    %eax,%ebx
  800abd:	89 c7                	mov    %eax,%edi
  800abf:	89 c6                	mov    %eax,%esi
  800ac1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad8:	89 d1                	mov    %edx,%ecx
  800ada:	89 d3                	mov    %edx,%ebx
  800adc:	89 d7                	mov    %edx,%edi
  800ade:	89 d6                	mov    %edx,%esi
  800ae0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af5:	b8 03 00 00 00       	mov    $0x3,%eax
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	89 cb                	mov    %ecx,%ebx
  800aff:	89 cf                	mov    %ecx,%edi
  800b01:	89 ce                	mov    %ecx,%esi
  800b03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b05:	85 c0                	test   %eax,%eax
  800b07:	7e 17                	jle    800b20 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	50                   	push   %eax
  800b0d:	6a 03                	push   $0x3
  800b0f:	68 bf 29 80 00       	push   $0x8029bf
  800b14:	6a 23                	push   $0x23
  800b16:	68 dc 29 80 00       	push   $0x8029dc
  800b1b:	e8 db 16 00 00       	call   8021fb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 02 00 00 00       	mov    $0x2,%eax
  800b38:	89 d1                	mov    %edx,%ecx
  800b3a:	89 d3                	mov    %edx,%ebx
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_yield>:

void
sys_yield(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	be 00 00 00 00       	mov    $0x0,%esi
  800b74:	b8 04 00 00 00       	mov    $0x4,%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b82:	89 f7                	mov    %esi,%edi
  800b84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 17                	jle    800ba1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 04                	push   $0x4
  800b90:	68 bf 29 80 00       	push   $0x8029bf
  800b95:	6a 23                	push   $0x23
  800b97:	68 dc 29 80 00       	push   $0x8029dc
  800b9c:	e8 5a 16 00 00       	call   8021fb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 17                	jle    800be3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 05                	push   $0x5
  800bd2:	68 bf 29 80 00       	push   $0x8029bf
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 dc 29 80 00       	push   $0x8029dc
  800bde:	e8 18 16 00 00       	call   8021fb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	89 df                	mov    %ebx,%edi
  800c06:	89 de                	mov    %ebx,%esi
  800c08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7e 17                	jle    800c25 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 06                	push   $0x6
  800c14:	68 bf 29 80 00       	push   $0x8029bf
  800c19:	6a 23                	push   $0x23
  800c1b:	68 dc 29 80 00       	push   $0x8029dc
  800c20:	e8 d6 15 00 00       	call   8021fb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 df                	mov    %ebx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 08                	push   $0x8
  800c56:	68 bf 29 80 00       	push   $0x8029bf
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 dc 29 80 00       	push   $0x8029dc
  800c62:	e8 94 15 00 00       	call   8021fb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 17                	jle    800ca9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 09                	push   $0x9
  800c98:	68 bf 29 80 00       	push   $0x8029bf
  800c9d:	6a 23                	push   $0x23
  800c9f:	68 dc 29 80 00       	push   $0x8029dc
  800ca4:	e8 52 15 00 00       	call   8021fb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7e 17                	jle    800ceb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	50                   	push   %eax
  800cd8:	6a 0a                	push   $0xa
  800cda:	68 bf 29 80 00       	push   $0x8029bf
  800cdf:	6a 23                	push   $0x23
  800ce1:	68 dc 29 80 00       	push   $0x8029dc
  800ce6:	e8 10 15 00 00       	call   8021fb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800cf9:	be 00 00 00 00       	mov    $0x0,%esi
  800cfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d24:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 cb                	mov    %ecx,%ebx
  800d2e:	89 cf                	mov    %ecx,%edi
  800d30:	89 ce                	mov    %ecx,%esi
  800d32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 17                	jle    800d4f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 0d                	push   $0xd
  800d3e:	68 bf 29 80 00       	push   $0x8029bf
  800d43:	6a 23                	push   $0x23
  800d45:	68 dc 29 80 00       	push   $0x8029dc
  800d4a:	e8 ac 14 00 00       	call   8021fb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d62:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d67:	89 d1                	mov    %edx,%ecx
  800d69:	89 d3                	mov    %edx,%ebx
  800d6b:	89 d7                	mov    %edx,%edi
  800d6d:	89 d6                	mov    %edx,%esi
  800d6f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800da1:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800da3:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800da7:	74 2e                	je     800dd7 <pgfault+0x40>
  800da9:	89 c2                	mov    %eax,%edx
  800dab:	c1 ea 16             	shr    $0x16,%edx
  800dae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db5:	f6 c2 01             	test   $0x1,%dl
  800db8:	74 1d                	je     800dd7 <pgfault+0x40>
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	c1 ea 0c             	shr    $0xc,%edx
  800dbf:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dc6:	f6 c1 01             	test   $0x1,%cl
  800dc9:	74 0c                	je     800dd7 <pgfault+0x40>
  800dcb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd2:	f6 c6 08             	test   $0x8,%dh
  800dd5:	75 14                	jne    800deb <pgfault+0x54>
        panic("Not copy-on-write\n");
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	68 ea 29 80 00       	push   $0x8029ea
  800ddf:	6a 1d                	push   $0x1d
  800de1:	68 fd 29 80 00       	push   $0x8029fd
  800de6:	e8 10 14 00 00       	call   8021fb <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800deb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df0:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	6a 07                	push   $0x7
  800df7:	68 00 f0 7f 00       	push   $0x7ff000
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 63 fd ff ff       	call   800b66 <sys_page_alloc>
  800e03:	83 c4 10             	add    $0x10,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	79 14                	jns    800e1e <pgfault+0x87>
		panic("page alloc failed \n");
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 08 2a 80 00       	push   $0x802a08
  800e12:	6a 28                	push   $0x28
  800e14:	68 fd 29 80 00       	push   $0x8029fd
  800e19:	e8 dd 13 00 00       	call   8021fb <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 00 10 00 00       	push   $0x1000
  800e26:	53                   	push   %ebx
  800e27:	68 00 f0 7f 00       	push   $0x7ff000
  800e2c:	e8 2c fb ff ff       	call   80095d <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800e31:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e38:	53                   	push   %ebx
  800e39:	6a 00                	push   $0x0
  800e3b:	68 00 f0 7f 00       	push   $0x7ff000
  800e40:	6a 00                	push   $0x0
  800e42:	e8 62 fd ff ff       	call   800ba9 <sys_page_map>
  800e47:	83 c4 20             	add    $0x20,%esp
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	79 14                	jns    800e62 <pgfault+0xcb>
        panic("page map failed \n");
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	68 1c 2a 80 00       	push   $0x802a1c
  800e56:	6a 2b                	push   $0x2b
  800e58:	68 fd 29 80 00       	push   $0x8029fd
  800e5d:	e8 99 13 00 00       	call   8021fb <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	68 00 f0 7f 00       	push   $0x7ff000
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 7a fd ff ff       	call   800beb <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	79 14                	jns    800e8c <pgfault+0xf5>
        panic("page unmap failed\n");
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	68 2e 2a 80 00       	push   $0x802a2e
  800e80:	6a 2d                	push   $0x2d
  800e82:	68 fd 29 80 00       	push   $0x8029fd
  800e87:	e8 6f 13 00 00       	call   8021fb <_panic>
	
	//panic("pgfault not implemented");
}
  800e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800e9a:	68 97 0d 80 00       	push   $0x800d97
  800e9f:	e8 9d 13 00 00       	call   802241 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ea4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ea9:	cd 30                	int    $0x30
  800eab:	89 c7                	mov    %eax,%edi
  800ead:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	79 12                	jns    800ec9 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800eb7:	50                   	push   %eax
  800eb8:	68 41 2a 80 00       	push   $0x802a41
  800ebd:	6a 7a                	push   $0x7a
  800ebf:	68 fd 29 80 00       	push   $0x8029fd
  800ec4:	e8 32 13 00 00       	call   8021fb <_panic>
  800ec9:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	75 21                	jne    800ef3 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed2:	e8 51 fc ff ff       	call   800b28 <sys_getenvid>
  800ed7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800edc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800edf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee4:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	e9 91 01 00 00       	jmp    801084 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800ef3:	89 d8                	mov    %ebx,%eax
  800ef5:	c1 e8 16             	shr    $0x16,%eax
  800ef8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eff:	a8 01                	test   $0x1,%al
  800f01:	0f 84 06 01 00 00    	je     80100d <fork+0x17c>
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	c1 e8 0c             	shr    $0xc,%eax
  800f0c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f13:	f6 c2 01             	test   $0x1,%dl
  800f16:	0f 84 f1 00 00 00    	je     80100d <fork+0x17c>
  800f1c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f23:	f6 c2 04             	test   $0x4,%dl
  800f26:	0f 84 e1 00 00 00    	je     80100d <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  800f2c:	89 c6                	mov    %eax,%esi
  800f2e:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	c1 ea 16             	shr    $0x16,%edx
  800f36:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  800f3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  800f44:	f6 c6 04             	test   $0x4,%dh
  800f47:	74 39                	je     800f82 <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  800f49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	25 07 0e 00 00       	and    $0xe07,%eax
  800f58:	50                   	push   %eax
  800f59:	56                   	push   %esi
  800f5a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5d:	56                   	push   %esi
  800f5e:	6a 00                	push   $0x0
  800f60:	e8 44 fc ff ff       	call   800ba9 <sys_page_map>
  800f65:	83 c4 20             	add    $0x20,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	0f 89 9d 00 00 00    	jns    80100d <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  800f70:	50                   	push   %eax
  800f71:	68 98 2a 80 00       	push   $0x802a98
  800f76:	6a 4b                	push   $0x4b
  800f78:	68 fd 29 80 00       	push   $0x8029fd
  800f7d:	e8 79 12 00 00       	call   8021fb <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  800f82:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f88:	74 59                	je     800fe3 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	68 05 08 00 00       	push   $0x805
  800f92:	56                   	push   %esi
  800f93:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 0b fc ff ff       	call   800ba9 <sys_page_map>
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	79 12                	jns    800fb7 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  800fa5:	50                   	push   %eax
  800fa6:	68 c8 2a 80 00       	push   $0x802ac8
  800fab:	6a 50                	push   $0x50
  800fad:	68 fd 29 80 00       	push   $0x8029fd
  800fb2:	e8 44 12 00 00       	call   8021fb <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	68 05 08 00 00       	push   $0x805
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	56                   	push   %esi
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 df fb ff ff       	call   800ba9 <sys_page_map>
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 3c                	jns    80100d <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  800fd1:	50                   	push   %eax
  800fd2:	68 f0 2a 80 00       	push   $0x802af0
  800fd7:	6a 53                	push   $0x53
  800fd9:	68 fd 29 80 00       	push   $0x8029fd
  800fde:	e8 18 12 00 00       	call   8021fb <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	6a 05                	push   $0x5
  800fe8:	56                   	push   %esi
  800fe9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fec:	56                   	push   %esi
  800fed:	6a 00                	push   $0x0
  800fef:	e8 b5 fb ff ff       	call   800ba9 <sys_page_map>
  800ff4:	83 c4 20             	add    $0x20,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	79 12                	jns    80100d <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  800ffb:	50                   	push   %eax
  800ffc:	68 18 2b 80 00       	push   $0x802b18
  801001:	6a 58                	push   $0x58
  801003:	68 fd 29 80 00       	push   $0x8029fd
  801008:	e8 ee 11 00 00       	call   8021fb <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80100d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801013:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801019:	0f 85 d4 fe ff ff    	jne    800ef3 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  80101f:	83 ec 04             	sub    $0x4,%esp
  801022:	6a 07                	push   $0x7
  801024:	68 00 f0 bf ee       	push   $0xeebff000
  801029:	57                   	push   %edi
  80102a:	e8 37 fb ff ff       	call   800b66 <sys_page_alloc>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	79 17                	jns    80104d <fork+0x1bc>
        panic("page alloc failed\n");
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	68 53 2a 80 00       	push   $0x802a53
  80103e:	68 87 00 00 00       	push   $0x87
  801043:	68 fd 29 80 00       	push   $0x8029fd
  801048:	e8 ae 11 00 00       	call   8021fb <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	68 b0 22 80 00       	push   $0x8022b0
  801055:	57                   	push   %edi
  801056:	e8 56 fc ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	6a 02                	push   $0x2
  801060:	57                   	push   %edi
  801061:	e8 c7 fb ff ff       	call   800c2d <sys_env_set_status>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 15                	jns    801082 <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80106d:	50                   	push   %eax
  80106e:	68 66 2a 80 00       	push   $0x802a66
  801073:	68 8c 00 00 00       	push   $0x8c
  801078:	68 fd 29 80 00       	push   $0x8029fd
  80107d:	e8 79 11 00 00       	call   8021fb <_panic>

	return envid;
  801082:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801084:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <sfork>:

// Challenge!
int
sfork(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801092:	68 7f 2a 80 00       	push   $0x802a7f
  801097:	68 98 00 00 00       	push   $0x98
  80109c:	68 fd 29 80 00       	push   $0x8029fd
  8010a1:	e8 55 11 00 00       	call   8021fb <_panic>

008010a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b1:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d8:	89 c2                	mov    %eax,%edx
  8010da:	c1 ea 16             	shr    $0x16,%edx
  8010dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e4:	f6 c2 01             	test   $0x1,%dl
  8010e7:	74 11                	je     8010fa <fd_alloc+0x2d>
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	c1 ea 0c             	shr    $0xc,%edx
  8010ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f5:	f6 c2 01             	test   $0x1,%dl
  8010f8:	75 09                	jne    801103 <fd_alloc+0x36>
			*fd_store = fd;
  8010fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801101:	eb 17                	jmp    80111a <fd_alloc+0x4d>
  801103:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801108:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110d:	75 c9                	jne    8010d8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801115:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801122:	83 f8 1f             	cmp    $0x1f,%eax
  801125:	77 36                	ja     80115d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801127:	c1 e0 0c             	shl    $0xc,%eax
  80112a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 ea 16             	shr    $0x16,%edx
  801134:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113b:	f6 c2 01             	test   $0x1,%dl
  80113e:	74 24                	je     801164 <fd_lookup+0x48>
  801140:	89 c2                	mov    %eax,%edx
  801142:	c1 ea 0c             	shr    $0xc,%edx
  801145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114c:	f6 c2 01             	test   $0x1,%dl
  80114f:	74 1a                	je     80116b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801151:	8b 55 0c             	mov    0xc(%ebp),%edx
  801154:	89 02                	mov    %eax,(%edx)
	return 0;
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
  80115b:	eb 13                	jmp    801170 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80115d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801162:	eb 0c                	jmp    801170 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801164:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801169:	eb 05                	jmp    801170 <fd_lookup+0x54>
  80116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117b:	ba c0 2b 80 00       	mov    $0x802bc0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801180:	eb 13                	jmp    801195 <dev_lookup+0x23>
  801182:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801185:	39 08                	cmp    %ecx,(%eax)
  801187:	75 0c                	jne    801195 <dev_lookup+0x23>
			*dev = devtab[i];
  801189:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
  801193:	eb 2e                	jmp    8011c3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801195:	8b 02                	mov    (%edx),%eax
  801197:	85 c0                	test   %eax,%eax
  801199:	75 e7                	jne    801182 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80119b:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a0:	8b 40 48             	mov    0x48(%eax),%eax
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	51                   	push   %ecx
  8011a7:	50                   	push   %eax
  8011a8:	68 44 2b 80 00       	push   $0x802b44
  8011ad:	e8 2c f0 ff ff       	call   8001de <cprintf>
	*dev = 0;
  8011b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c3:	c9                   	leave  
  8011c4:	c3                   	ret    

008011c5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	56                   	push   %esi
  8011c9:	53                   	push   %ebx
  8011ca:	83 ec 10             	sub    $0x10,%esp
  8011cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d6:	50                   	push   %eax
  8011d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011dd:	c1 e8 0c             	shr    $0xc,%eax
  8011e0:	50                   	push   %eax
  8011e1:	e8 36 ff ff ff       	call   80111c <fd_lookup>
  8011e6:	83 c4 08             	add    $0x8,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 05                	js     8011f2 <fd_close+0x2d>
	    || fd != fd2)
  8011ed:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011f0:	74 0c                	je     8011fe <fd_close+0x39>
		return (must_exist ? r : 0);
  8011f2:	84 db                	test   %bl,%bl
  8011f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f9:	0f 44 c2             	cmove  %edx,%eax
  8011fc:	eb 41                	jmp    80123f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 36                	pushl  (%esi)
  801207:	e8 66 ff ff ff       	call   801172 <dev_lookup>
  80120c:	89 c3                	mov    %eax,%ebx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 1a                	js     80122f <fd_close+0x6a>
		if (dev->dev_close)
  801215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801218:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80121b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801220:	85 c0                	test   %eax,%eax
  801222:	74 0b                	je     80122f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	56                   	push   %esi
  801228:	ff d0                	call   *%eax
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	56                   	push   %esi
  801233:	6a 00                	push   $0x0
  801235:	e8 b1 f9 ff ff       	call   800beb <sys_page_unmap>
	return r;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	89 d8                	mov    %ebx,%eax
}
  80123f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 c4 fe ff ff       	call   80111c <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 10                	js     80126f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	6a 01                	push   $0x1
  801264:	ff 75 f4             	pushl  -0xc(%ebp)
  801267:	e8 59 ff ff ff       	call   8011c5 <fd_close>
  80126c:	83 c4 10             	add    $0x10,%esp
}
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <close_all>:

void
close_all(void)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	53                   	push   %ebx
  801275:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801278:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	53                   	push   %ebx
  801281:	e8 c0 ff ff ff       	call   801246 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801286:	83 c3 01             	add    $0x1,%ebx
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	83 fb 20             	cmp    $0x20,%ebx
  80128f:	75 ec                	jne    80127d <close_all+0xc>
		close(i);
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 2c             	sub    $0x2c,%esp
  80129f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	ff 75 08             	pushl  0x8(%ebp)
  8012a9:	e8 6e fe ff ff       	call   80111c <fd_lookup>
  8012ae:	83 c4 08             	add    $0x8,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	0f 88 c1 00 00 00    	js     80137a <dup+0xe4>
		return r;
	close(newfdnum);
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	56                   	push   %esi
  8012bd:	e8 84 ff ff ff       	call   801246 <close>

	newfd = INDEX2FD(newfdnum);
  8012c2:	89 f3                	mov    %esi,%ebx
  8012c4:	c1 e3 0c             	shl    $0xc,%ebx
  8012c7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012cd:	83 c4 04             	add    $0x4,%esp
  8012d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d3:	e8 de fd ff ff       	call   8010b6 <fd2data>
  8012d8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012da:	89 1c 24             	mov    %ebx,(%esp)
  8012dd:	e8 d4 fd ff ff       	call   8010b6 <fd2data>
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e8:	89 f8                	mov    %edi,%eax
  8012ea:	c1 e8 16             	shr    $0x16,%eax
  8012ed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f4:	a8 01                	test   $0x1,%al
  8012f6:	74 37                	je     80132f <dup+0x99>
  8012f8:	89 f8                	mov    %edi,%eax
  8012fa:	c1 e8 0c             	shr    $0xc,%eax
  8012fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801304:	f6 c2 01             	test   $0x1,%dl
  801307:	74 26                	je     80132f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801309:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	25 07 0e 00 00       	and    $0xe07,%eax
  801318:	50                   	push   %eax
  801319:	ff 75 d4             	pushl  -0x2c(%ebp)
  80131c:	6a 00                	push   $0x0
  80131e:	57                   	push   %edi
  80131f:	6a 00                	push   $0x0
  801321:	e8 83 f8 ff ff       	call   800ba9 <sys_page_map>
  801326:	89 c7                	mov    %eax,%edi
  801328:	83 c4 20             	add    $0x20,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 2e                	js     80135d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801332:	89 d0                	mov    %edx,%eax
  801334:	c1 e8 0c             	shr    $0xc,%eax
  801337:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133e:	83 ec 0c             	sub    $0xc,%esp
  801341:	25 07 0e 00 00       	and    $0xe07,%eax
  801346:	50                   	push   %eax
  801347:	53                   	push   %ebx
  801348:	6a 00                	push   $0x0
  80134a:	52                   	push   %edx
  80134b:	6a 00                	push   $0x0
  80134d:	e8 57 f8 ff ff       	call   800ba9 <sys_page_map>
  801352:	89 c7                	mov    %eax,%edi
  801354:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801357:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801359:	85 ff                	test   %edi,%edi
  80135b:	79 1d                	jns    80137a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	53                   	push   %ebx
  801361:	6a 00                	push   $0x0
  801363:	e8 83 f8 ff ff       	call   800beb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136e:	6a 00                	push   $0x0
  801370:	e8 76 f8 ff ff       	call   800beb <sys_page_unmap>
	return r;
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	89 f8                	mov    %edi,%eax
}
  80137a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 14             	sub    $0x14,%esp
  801389:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	53                   	push   %ebx
  801391:	e8 86 fd ff ff       	call   80111c <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	89 c2                	mov    %eax,%edx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 6d                	js     80140c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	e8 c2 fd ff ff       	call   801172 <dev_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 4c                	js     801403 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ba:	8b 42 08             	mov    0x8(%edx),%eax
  8013bd:	83 e0 03             	and    $0x3,%eax
  8013c0:	83 f8 01             	cmp    $0x1,%eax
  8013c3:	75 21                	jne    8013e6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ca:	8b 40 48             	mov    0x48(%eax),%eax
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	50                   	push   %eax
  8013d2:	68 85 2b 80 00       	push   $0x802b85
  8013d7:	e8 02 ee ff ff       	call   8001de <cprintf>
		return -E_INVAL;
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e4:	eb 26                	jmp    80140c <read+0x8a>
	}
	if (!dev->dev_read)
  8013e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e9:	8b 40 08             	mov    0x8(%eax),%eax
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	74 17                	je     801407 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f0:	83 ec 04             	sub    $0x4,%esp
  8013f3:	ff 75 10             	pushl  0x10(%ebp)
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	52                   	push   %edx
  8013fa:	ff d0                	call   *%eax
  8013fc:	89 c2                	mov    %eax,%edx
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	eb 09                	jmp    80140c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801403:	89 c2                	mov    %eax,%edx
  801405:	eb 05                	jmp    80140c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801407:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80140c:	89 d0                	mov    %edx,%eax
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801422:	bb 00 00 00 00       	mov    $0x0,%ebx
  801427:	eb 21                	jmp    80144a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801429:	83 ec 04             	sub    $0x4,%esp
  80142c:	89 f0                	mov    %esi,%eax
  80142e:	29 d8                	sub    %ebx,%eax
  801430:	50                   	push   %eax
  801431:	89 d8                	mov    %ebx,%eax
  801433:	03 45 0c             	add    0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	57                   	push   %edi
  801438:	e8 45 ff ff ff       	call   801382 <read>
		if (m < 0)
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 10                	js     801454 <readn+0x41>
			return m;
		if (m == 0)
  801444:	85 c0                	test   %eax,%eax
  801446:	74 0a                	je     801452 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801448:	01 c3                	add    %eax,%ebx
  80144a:	39 f3                	cmp    %esi,%ebx
  80144c:	72 db                	jb     801429 <readn+0x16>
  80144e:	89 d8                	mov    %ebx,%eax
  801450:	eb 02                	jmp    801454 <readn+0x41>
  801452:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801454:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	53                   	push   %ebx
  801460:	83 ec 14             	sub    $0x14,%esp
  801463:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801466:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	53                   	push   %ebx
  80146b:	e8 ac fc ff ff       	call   80111c <fd_lookup>
  801470:	83 c4 08             	add    $0x8,%esp
  801473:	89 c2                	mov    %eax,%edx
  801475:	85 c0                	test   %eax,%eax
  801477:	78 68                	js     8014e1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801483:	ff 30                	pushl  (%eax)
  801485:	e8 e8 fc ff ff       	call   801172 <dev_lookup>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 47                	js     8014d8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801491:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801494:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801498:	75 21                	jne    8014bb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80149a:	a1 08 40 80 00       	mov    0x804008,%eax
  80149f:	8b 40 48             	mov    0x48(%eax),%eax
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	53                   	push   %ebx
  8014a6:	50                   	push   %eax
  8014a7:	68 a1 2b 80 00       	push   $0x802ba1
  8014ac:	e8 2d ed ff ff       	call   8001de <cprintf>
		return -E_INVAL;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b9:	eb 26                	jmp    8014e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014be:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c1:	85 d2                	test   %edx,%edx
  8014c3:	74 17                	je     8014dc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c5:	83 ec 04             	sub    $0x4,%esp
  8014c8:	ff 75 10             	pushl  0x10(%ebp)
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	50                   	push   %eax
  8014cf:	ff d2                	call   *%edx
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	eb 09                	jmp    8014e1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d8:	89 c2                	mov    %eax,%edx
  8014da:	eb 05                	jmp    8014e1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014e1:	89 d0                	mov    %edx,%eax
  8014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	ff 75 08             	pushl  0x8(%ebp)
  8014f5:	e8 22 fc ff ff       	call   80111c <fd_lookup>
  8014fa:	83 c4 08             	add    $0x8,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 0e                	js     80150f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801501:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801504:	8b 55 0c             	mov    0xc(%ebp),%edx
  801507:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	53                   	push   %ebx
  801515:	83 ec 14             	sub    $0x14,%esp
  801518:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	53                   	push   %ebx
  801520:	e8 f7 fb ff ff       	call   80111c <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	89 c2                	mov    %eax,%edx
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 65                	js     801593 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	ff 30                	pushl  (%eax)
  80153a:	e8 33 fc ff ff       	call   801172 <dev_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 44                	js     80158a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801549:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154d:	75 21                	jne    801570 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801554:	8b 40 48             	mov    0x48(%eax),%eax
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	53                   	push   %ebx
  80155b:	50                   	push   %eax
  80155c:	68 64 2b 80 00       	push   $0x802b64
  801561:	e8 78 ec ff ff       	call   8001de <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156e:	eb 23                	jmp    801593 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	8b 52 18             	mov    0x18(%edx),%edx
  801576:	85 d2                	test   %edx,%edx
  801578:	74 14                	je     80158e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	ff 75 0c             	pushl  0xc(%ebp)
  801580:	50                   	push   %eax
  801581:	ff d2                	call   *%edx
  801583:	89 c2                	mov    %eax,%edx
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	eb 09                	jmp    801593 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	eb 05                	jmp    801593 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801593:	89 d0                	mov    %edx,%eax
  801595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 14             	sub    $0x14,%esp
  8015a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	e8 6c fb ff ff       	call   80111c <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 58                	js     801611 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c3:	ff 30                	pushl  (%eax)
  8015c5:	e8 a8 fb ff ff       	call   801172 <dev_lookup>
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 37                	js     801608 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d8:	74 32                	je     80160c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e4:	00 00 00 
	stat->st_isdir = 0;
  8015e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ee:	00 00 00 
	stat->st_dev = dev;
  8015f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fe:	ff 50 14             	call   *0x14(%eax)
  801601:	89 c2                	mov    %eax,%edx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb 09                	jmp    801611 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801608:	89 c2                	mov    %eax,%edx
  80160a:	eb 05                	jmp    801611 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80160c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801611:	89 d0                	mov    %edx,%eax
  801613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	6a 00                	push   $0x0
  801622:	ff 75 08             	pushl  0x8(%ebp)
  801625:	e8 e7 01 00 00       	call   801811 <open>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 1b                	js     80164e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	ff 75 0c             	pushl  0xc(%ebp)
  801639:	50                   	push   %eax
  80163a:	e8 5b ff ff ff       	call   80159a <fstat>
  80163f:	89 c6                	mov    %eax,%esi
	close(fd);
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 fd fb ff ff       	call   801246 <close>
	return r;
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	89 f0                	mov    %esi,%eax
}
  80164e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	89 c6                	mov    %eax,%esi
  80165c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80165e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801665:	75 12                	jne    801679 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	6a 01                	push   $0x1
  80166c:	e8 24 0d 00 00       	call   802395 <ipc_find_env>
  801671:	a3 00 40 80 00       	mov    %eax,0x804000
  801676:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801679:	6a 07                	push   $0x7
  80167b:	68 00 50 80 00       	push   $0x805000
  801680:	56                   	push   %esi
  801681:	ff 35 00 40 80 00    	pushl  0x804000
  801687:	e8 b5 0c 00 00       	call   802341 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80168c:	83 c4 0c             	add    $0xc,%esp
  80168f:	6a 00                	push   $0x0
  801691:	53                   	push   %ebx
  801692:	6a 00                	push   $0x0
  801694:	e8 3b 0c 00 00       	call   8022d4 <ipc_recv>
}
  801699:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169c:	5b                   	pop    %ebx
  80169d:	5e                   	pop    %esi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c3:	e8 8d ff ff ff       	call   801655 <fsipc>
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e5:	e8 6b ff ff ff       	call   801655 <fsipc>
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 04             	sub    $0x4,%esp
  8016f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	b8 05 00 00 00       	mov    $0x5,%eax
  80170b:	e8 45 ff ff ff       	call   801655 <fsipc>
  801710:	85 c0                	test   %eax,%eax
  801712:	78 2c                	js     801740 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	68 00 50 80 00       	push   $0x805000
  80171c:	53                   	push   %ebx
  80171d:	e8 41 f0 ff ff       	call   800763 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801722:	a1 80 50 80 00       	mov    0x805080,%eax
  801727:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172d:	a1 84 50 80 00       	mov    0x805084,%eax
  801732:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80174f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801754:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801759:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80175c:	53                   	push   %ebx
  80175d:	ff 75 0c             	pushl  0xc(%ebp)
  801760:	68 08 50 80 00       	push   $0x805008
  801765:	e8 8b f1 ff ff       	call   8008f5 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	8b 40 0c             	mov    0xc(%eax),%eax
  801770:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801775:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 04 00 00 00       	mov    $0x4,%eax
  801785:	e8 cb fe ff ff       	call   801655 <fsipc>
	//panic("devfile_write not implemented");
}
  80178a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
  801794:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b2:	e8 9e fe ff ff       	call   801655 <fsipc>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 4b                	js     801808 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017bd:	39 c6                	cmp    %eax,%esi
  8017bf:	73 16                	jae    8017d7 <devfile_read+0x48>
  8017c1:	68 d4 2b 80 00       	push   $0x802bd4
  8017c6:	68 db 2b 80 00       	push   $0x802bdb
  8017cb:	6a 7c                	push   $0x7c
  8017cd:	68 f0 2b 80 00       	push   $0x802bf0
  8017d2:	e8 24 0a 00 00       	call   8021fb <_panic>
	assert(r <= PGSIZE);
  8017d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017dc:	7e 16                	jle    8017f4 <devfile_read+0x65>
  8017de:	68 fb 2b 80 00       	push   $0x802bfb
  8017e3:	68 db 2b 80 00       	push   $0x802bdb
  8017e8:	6a 7d                	push   $0x7d
  8017ea:	68 f0 2b 80 00       	push   $0x802bf0
  8017ef:	e8 07 0a 00 00       	call   8021fb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	50                   	push   %eax
  8017f8:	68 00 50 80 00       	push   $0x805000
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	e8 f0 f0 ff ff       	call   8008f5 <memmove>
	return r;
  801805:	83 c4 10             	add    $0x10,%esp
}
  801808:	89 d8                	mov    %ebx,%eax
  80180a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5e                   	pop    %esi
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	53                   	push   %ebx
  801815:	83 ec 20             	sub    $0x20,%esp
  801818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181b:	53                   	push   %ebx
  80181c:	e8 09 ef ff ff       	call   80072a <strlen>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801829:	7f 67                	jg     801892 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 96 f8 ff ff       	call   8010cd <fd_alloc>
  801837:	83 c4 10             	add    $0x10,%esp
		return r;
  80183a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 57                	js     801897 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	53                   	push   %ebx
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	e8 15 ef ff ff       	call   800763 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801851:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801856:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801859:	b8 01 00 00 00       	mov    $0x1,%eax
  80185e:	e8 f2 fd ff ff       	call   801655 <fsipc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	79 14                	jns    801880 <open+0x6f>
		fd_close(fd, 0);
  80186c:	83 ec 08             	sub    $0x8,%esp
  80186f:	6a 00                	push   $0x0
  801871:	ff 75 f4             	pushl  -0xc(%ebp)
  801874:	e8 4c f9 ff ff       	call   8011c5 <fd_close>
		return r;
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	89 da                	mov    %ebx,%edx
  80187e:	eb 17                	jmp    801897 <open+0x86>
	}

	return fd2num(fd);
  801880:	83 ec 0c             	sub    $0xc,%esp
  801883:	ff 75 f4             	pushl  -0xc(%ebp)
  801886:	e8 1b f8 ff ff       	call   8010a6 <fd2num>
  80188b:	89 c2                	mov    %eax,%edx
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	eb 05                	jmp    801897 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801892:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801897:	89 d0                	mov    %edx,%eax
  801899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ae:	e8 a2 fd ff ff       	call   801655 <fsipc>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018bb:	68 07 2c 80 00       	push   $0x802c07
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	e8 9b ee ff ff       	call   800763 <strcpy>
	return 0;
}
  8018c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 10             	sub    $0x10,%esp
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018d9:	53                   	push   %ebx
  8018da:	e8 ef 0a 00 00       	call   8023ce <pageref>
  8018df:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018e7:	83 f8 01             	cmp    $0x1,%eax
  8018ea:	75 10                	jne    8018fc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	ff 73 0c             	pushl  0xc(%ebx)
  8018f2:	e8 c0 02 00 00       	call   801bb7 <nsipc_close>
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018fc:	89 d0                	mov    %edx,%eax
  8018fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801909:	6a 00                	push   $0x0
  80190b:	ff 75 10             	pushl  0x10(%ebp)
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	ff 70 0c             	pushl  0xc(%eax)
  801917:	e8 78 03 00 00       	call   801c94 <nsipc_send>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801924:	6a 00                	push   $0x0
  801926:	ff 75 10             	pushl  0x10(%ebp)
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	ff 70 0c             	pushl  0xc(%eax)
  801932:	e8 f1 02 00 00       	call   801c28 <nsipc_recv>
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80193f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801942:	52                   	push   %edx
  801943:	50                   	push   %eax
  801944:	e8 d3 f7 ff ff       	call   80111c <fd_lookup>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 17                	js     801967 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801959:	39 08                	cmp    %ecx,(%eax)
  80195b:	75 05                	jne    801962 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	eb 05                	jmp    801967 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801962:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	83 ec 1c             	sub    $0x1c,%esp
  801971:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	e8 51 f7 ff ff       	call   8010cd <fd_alloc>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	78 1b                	js     8019a0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	68 07 04 00 00       	push   $0x407
  80198d:	ff 75 f4             	pushl  -0xc(%ebp)
  801990:	6a 00                	push   $0x0
  801992:	e8 cf f1 ff ff       	call   800b66 <sys_page_alloc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	79 10                	jns    8019b0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	56                   	push   %esi
  8019a4:	e8 0e 02 00 00       	call   801bb7 <nsipc_close>
		return r;
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	89 d8                	mov    %ebx,%eax
  8019ae:	eb 24                	jmp    8019d4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019b0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019c5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	50                   	push   %eax
  8019cc:	e8 d5 f6 ff ff       	call   8010a6 <fd2num>
  8019d1:	83 c4 10             	add    $0x10,%esp
}
  8019d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	e8 50 ff ff ff       	call   801939 <fd2sockid>
		return r;
  8019e9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 1f                	js     801a0e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	ff 75 10             	pushl  0x10(%ebp)
  8019f5:	ff 75 0c             	pushl  0xc(%ebp)
  8019f8:	50                   	push   %eax
  8019f9:	e8 12 01 00 00       	call   801b10 <nsipc_accept>
  8019fe:	83 c4 10             	add    $0x10,%esp
		return r;
  801a01:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 07                	js     801a0e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a07:	e8 5d ff ff ff       	call   801969 <alloc_sockfd>
  801a0c:	89 c1                	mov    %eax,%ecx
}
  801a0e:	89 c8                	mov    %ecx,%eax
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	e8 19 ff ff ff       	call   801939 <fd2sockid>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 12                	js     801a36 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	ff 75 10             	pushl  0x10(%ebp)
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	50                   	push   %eax
  801a2e:	e8 2d 01 00 00       	call   801b60 <nsipc_bind>
  801a33:	83 c4 10             	add    $0x10,%esp
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <shutdown>:

int
shutdown(int s, int how)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	e8 f3 fe ff ff       	call   801939 <fd2sockid>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 0f                	js     801a59 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	50                   	push   %eax
  801a51:	e8 3f 01 00 00       	call   801b95 <nsipc_shutdown>
  801a56:	83 c4 10             	add    $0x10,%esp
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	e8 d0 fe ff ff       	call   801939 <fd2sockid>
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 12                	js     801a7f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a6d:	83 ec 04             	sub    $0x4,%esp
  801a70:	ff 75 10             	pushl  0x10(%ebp)
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	50                   	push   %eax
  801a77:	e8 55 01 00 00       	call   801bd1 <nsipc_connect>
  801a7c:	83 c4 10             	add    $0x10,%esp
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <listen>:

int
listen(int s, int backlog)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a87:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8a:	e8 aa fe ff ff       	call   801939 <fd2sockid>
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 0f                	js     801aa2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	50                   	push   %eax
  801a9a:	e8 67 01 00 00       	call   801c06 <nsipc_listen>
  801a9f:	83 c4 10             	add    $0x10,%esp
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801aaa:	ff 75 10             	pushl  0x10(%ebp)
  801aad:	ff 75 0c             	pushl  0xc(%ebp)
  801ab0:	ff 75 08             	pushl  0x8(%ebp)
  801ab3:	e8 3a 02 00 00       	call   801cf2 <nsipc_socket>
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 05                	js     801ac4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801abf:	e8 a5 fe ff ff       	call   801969 <alloc_sockfd>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 04             	sub    $0x4,%esp
  801acd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801acf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ad6:	75 12                	jne    801aea <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	6a 02                	push   $0x2
  801add:	e8 b3 08 00 00       	call   802395 <ipc_find_env>
  801ae2:	a3 04 40 80 00       	mov    %eax,0x804004
  801ae7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801aea:	6a 07                	push   $0x7
  801aec:	68 00 60 80 00       	push   $0x806000
  801af1:	53                   	push   %ebx
  801af2:	ff 35 04 40 80 00    	pushl  0x804004
  801af8:	e8 44 08 00 00       	call   802341 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801afd:	83 c4 0c             	add    $0xc,%esp
  801b00:	6a 00                	push   $0x0
  801b02:	6a 00                	push   $0x0
  801b04:	6a 00                	push   $0x0
  801b06:	e8 c9 07 00 00       	call   8022d4 <ipc_recv>
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b20:	8b 06                	mov    (%esi),%eax
  801b22:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b27:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2c:	e8 95 ff ff ff       	call   801ac6 <nsipc>
  801b31:	89 c3                	mov    %eax,%ebx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 20                	js     801b57 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	ff 35 10 60 80 00    	pushl  0x806010
  801b40:	68 00 60 80 00       	push   $0x806000
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	e8 a8 ed ff ff       	call   8008f5 <memmove>
		*addrlen = ret->ret_addrlen;
  801b4d:	a1 10 60 80 00       	mov    0x806010,%eax
  801b52:	89 06                	mov    %eax,(%esi)
  801b54:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	53                   	push   %ebx
  801b64:	83 ec 08             	sub    $0x8,%esp
  801b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b72:	53                   	push   %ebx
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	68 04 60 80 00       	push   $0x806004
  801b7b:	e8 75 ed ff ff       	call   8008f5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b80:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b86:	b8 02 00 00 00       	mov    $0x2,%eax
  801b8b:	e8 36 ff ff ff       	call   801ac6 <nsipc>
}
  801b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bab:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb0:	e8 11 ff ff ff       	call   801ac6 <nsipc>
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <nsipc_close>:

int
nsipc_close(int s)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bc5:	b8 04 00 00 00       	mov    $0x4,%eax
  801bca:	e8 f7 fe ff ff       	call   801ac6 <nsipc>
}
  801bcf:	c9                   	leave  
  801bd0:	c3                   	ret    

00801bd1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801be3:	53                   	push   %ebx
  801be4:	ff 75 0c             	pushl  0xc(%ebp)
  801be7:	68 04 60 80 00       	push   $0x806004
  801bec:	e8 04 ed ff ff       	call   8008f5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bf1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bf7:	b8 05 00 00 00       	mov    $0x5,%eax
  801bfc:	e8 c5 fe ff ff       	call   801ac6 <nsipc>
}
  801c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c17:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c1c:	b8 06 00 00 00       	mov    $0x6,%eax
  801c21:	e8 a0 fe ff ff       	call   801ac6 <nsipc>
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c38:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c3e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c41:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c46:	b8 07 00 00 00       	mov    $0x7,%eax
  801c4b:	e8 76 fe ff ff       	call   801ac6 <nsipc>
  801c50:	89 c3                	mov    %eax,%ebx
  801c52:	85 c0                	test   %eax,%eax
  801c54:	78 35                	js     801c8b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c56:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c5b:	7f 04                	jg     801c61 <nsipc_recv+0x39>
  801c5d:	39 c6                	cmp    %eax,%esi
  801c5f:	7d 16                	jge    801c77 <nsipc_recv+0x4f>
  801c61:	68 13 2c 80 00       	push   $0x802c13
  801c66:	68 db 2b 80 00       	push   $0x802bdb
  801c6b:	6a 62                	push   $0x62
  801c6d:	68 28 2c 80 00       	push   $0x802c28
  801c72:	e8 84 05 00 00       	call   8021fb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	50                   	push   %eax
  801c7b:	68 00 60 80 00       	push   $0x806000
  801c80:	ff 75 0c             	pushl  0xc(%ebp)
  801c83:	e8 6d ec ff ff       	call   8008f5 <memmove>
  801c88:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ca6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cac:	7e 16                	jle    801cc4 <nsipc_send+0x30>
  801cae:	68 34 2c 80 00       	push   $0x802c34
  801cb3:	68 db 2b 80 00       	push   $0x802bdb
  801cb8:	6a 6d                	push   $0x6d
  801cba:	68 28 2c 80 00       	push   $0x802c28
  801cbf:	e8 37 05 00 00       	call   8021fb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	53                   	push   %ebx
  801cc8:	ff 75 0c             	pushl  0xc(%ebp)
  801ccb:	68 0c 60 80 00       	push   $0x80600c
  801cd0:	e8 20 ec ff ff       	call   8008f5 <memmove>
	nsipcbuf.send.req_size = size;
  801cd5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cdb:	8b 45 14             	mov    0x14(%ebp),%eax
  801cde:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce8:	e8 d9 fd ff ff       	call   801ac6 <nsipc>
}
  801ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d03:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d08:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d10:	b8 09 00 00 00       	mov    $0x9,%eax
  801d15:	e8 ac fd ff ff       	call   801ac6 <nsipc>
}
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	56                   	push   %esi
  801d20:	53                   	push   %ebx
  801d21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 08             	pushl  0x8(%ebp)
  801d2a:	e8 87 f3 ff ff       	call   8010b6 <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d31:	83 c4 08             	add    $0x8,%esp
  801d34:	68 40 2c 80 00       	push   $0x802c40
  801d39:	53                   	push   %ebx
  801d3a:	e8 24 ea ff ff       	call   800763 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d3f:	8b 46 04             	mov    0x4(%esi),%eax
  801d42:	2b 06                	sub    (%esi),%eax
  801d44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d51:	00 00 00 
	stat->st_dev = &devpipe;
  801d54:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d5b:	30 80 00 
	return 0;
}
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d74:	53                   	push   %ebx
  801d75:	6a 00                	push   $0x0
  801d77:	e8 6f ee ff ff       	call   800beb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d7c:	89 1c 24             	mov    %ebx,(%esp)
  801d7f:	e8 32 f3 ff ff       	call   8010b6 <fd2data>
  801d84:	83 c4 08             	add    $0x8,%esp
  801d87:	50                   	push   %eax
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 5c ee ff ff       	call   800beb <sys_page_unmap>
}
  801d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 1c             	sub    $0x1c,%esp
  801d9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801da0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801da2:	a1 08 40 80 00       	mov    0x804008,%eax
  801da7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	ff 75 e0             	pushl  -0x20(%ebp)
  801db0:	e8 19 06 00 00       	call   8023ce <pageref>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	89 3c 24             	mov    %edi,(%esp)
  801dba:	e8 0f 06 00 00       	call   8023ce <pageref>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	39 c3                	cmp    %eax,%ebx
  801dc4:	0f 94 c1             	sete   %cl
  801dc7:	0f b6 c9             	movzbl %cl,%ecx
  801dca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801dcd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801dd3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dd6:	39 ce                	cmp    %ecx,%esi
  801dd8:	74 1b                	je     801df5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dda:	39 c3                	cmp    %eax,%ebx
  801ddc:	75 c4                	jne    801da2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dde:	8b 42 58             	mov    0x58(%edx),%eax
  801de1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801de4:	50                   	push   %eax
  801de5:	56                   	push   %esi
  801de6:	68 47 2c 80 00       	push   $0x802c47
  801deb:	e8 ee e3 ff ff       	call   8001de <cprintf>
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	eb ad                	jmp    801da2 <_pipeisclosed+0xe>
	}
}
  801df5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	57                   	push   %edi
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	83 ec 28             	sub    $0x28,%esp
  801e09:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e0c:	56                   	push   %esi
  801e0d:	e8 a4 f2 ff ff       	call   8010b6 <fd2data>
  801e12:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1c:	eb 4b                	jmp    801e69 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e1e:	89 da                	mov    %ebx,%edx
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	e8 6d ff ff ff       	call   801d94 <_pipeisclosed>
  801e27:	85 c0                	test   %eax,%eax
  801e29:	75 48                	jne    801e73 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e2b:	e8 17 ed ff ff       	call   800b47 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e30:	8b 43 04             	mov    0x4(%ebx),%eax
  801e33:	8b 0b                	mov    (%ebx),%ecx
  801e35:	8d 51 20             	lea    0x20(%ecx),%edx
  801e38:	39 d0                	cmp    %edx,%eax
  801e3a:	73 e2                	jae    801e1e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e46:	89 c2                	mov    %eax,%edx
  801e48:	c1 fa 1f             	sar    $0x1f,%edx
  801e4b:	89 d1                	mov    %edx,%ecx
  801e4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801e50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e53:	83 e2 1f             	and    $0x1f,%edx
  801e56:	29 ca                	sub    %ecx,%edx
  801e58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e60:	83 c0 01             	add    $0x1,%eax
  801e63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e66:	83 c7 01             	add    $0x1,%edi
  801e69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6c:	75 c2                	jne    801e30 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e71:	eb 05                	jmp    801e78 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5f                   	pop    %edi
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 18             	sub    $0x18,%esp
  801e89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e8c:	57                   	push   %edi
  801e8d:	e8 24 f2 ff ff       	call   8010b6 <fd2data>
  801e92:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e9c:	eb 3d                	jmp    801edb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e9e:	85 db                	test   %ebx,%ebx
  801ea0:	74 04                	je     801ea6 <devpipe_read+0x26>
				return i;
  801ea2:	89 d8                	mov    %ebx,%eax
  801ea4:	eb 44                	jmp    801eea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ea6:	89 f2                	mov    %esi,%edx
  801ea8:	89 f8                	mov    %edi,%eax
  801eaa:	e8 e5 fe ff ff       	call   801d94 <_pipeisclosed>
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	75 32                	jne    801ee5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eb3:	e8 8f ec ff ff       	call   800b47 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eb8:	8b 06                	mov    (%esi),%eax
  801eba:	3b 46 04             	cmp    0x4(%esi),%eax
  801ebd:	74 df                	je     801e9e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ebf:	99                   	cltd   
  801ec0:	c1 ea 1b             	shr    $0x1b,%edx
  801ec3:	01 d0                	add    %edx,%eax
  801ec5:	83 e0 1f             	and    $0x1f,%eax
  801ec8:	29 d0                	sub    %edx,%eax
  801eca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ed5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed8:	83 c3 01             	add    $0x1,%ebx
  801edb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ede:	75 d8                	jne    801eb8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ee0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee3:	eb 05                	jmp    801eea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	56                   	push   %esi
  801ef6:	53                   	push   %ebx
  801ef7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801efa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efd:	50                   	push   %eax
  801efe:	e8 ca f1 ff ff       	call   8010cd <fd_alloc>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	0f 88 2c 01 00 00    	js     80203c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 04 00 00       	push   $0x407
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 44 ec ff ff       	call   800b66 <sys_page_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	89 c2                	mov    %eax,%edx
  801f27:	85 c0                	test   %eax,%eax
  801f29:	0f 88 0d 01 00 00    	js     80203c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f35:	50                   	push   %eax
  801f36:	e8 92 f1 ff ff       	call   8010cd <fd_alloc>
  801f3b:	89 c3                	mov    %eax,%ebx
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	0f 88 e2 00 00 00    	js     80202a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f48:	83 ec 04             	sub    $0x4,%esp
  801f4b:	68 07 04 00 00       	push   $0x407
  801f50:	ff 75 f0             	pushl  -0x10(%ebp)
  801f53:	6a 00                	push   $0x0
  801f55:	e8 0c ec ff ff       	call   800b66 <sys_page_alloc>
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	0f 88 c3 00 00 00    	js     80202a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f67:	83 ec 0c             	sub    $0xc,%esp
  801f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6d:	e8 44 f1 ff ff       	call   8010b6 <fd2data>
  801f72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f74:	83 c4 0c             	add    $0xc,%esp
  801f77:	68 07 04 00 00       	push   $0x407
  801f7c:	50                   	push   %eax
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 e2 eb ff ff       	call   800b66 <sys_page_alloc>
  801f84:	89 c3                	mov    %eax,%ebx
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	0f 88 89 00 00 00    	js     80201a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	ff 75 f0             	pushl  -0x10(%ebp)
  801f97:	e8 1a f1 ff ff       	call   8010b6 <fd2data>
  801f9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fa3:	50                   	push   %eax
  801fa4:	6a 00                	push   $0x0
  801fa6:	56                   	push   %esi
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 fb eb ff ff       	call   800ba9 <sys_page_map>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	83 c4 20             	add    $0x20,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	78 55                	js     80200c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fb7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fda:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fe1:	83 ec 0c             	sub    $0xc,%esp
  801fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe7:	e8 ba f0 ff ff       	call   8010a6 <fd2num>
  801fec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ff1:	83 c4 04             	add    $0x4,%esp
  801ff4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff7:	e8 aa f0 ff ff       	call   8010a6 <fd2num>
  801ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	ba 00 00 00 00       	mov    $0x0,%edx
  80200a:	eb 30                	jmp    80203c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80200c:	83 ec 08             	sub    $0x8,%esp
  80200f:	56                   	push   %esi
  802010:	6a 00                	push   $0x0
  802012:	e8 d4 eb ff ff       	call   800beb <sys_page_unmap>
  802017:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	ff 75 f0             	pushl  -0x10(%ebp)
  802020:	6a 00                	push   $0x0
  802022:	e8 c4 eb ff ff       	call   800beb <sys_page_unmap>
  802027:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80202a:	83 ec 08             	sub    $0x8,%esp
  80202d:	ff 75 f4             	pushl  -0xc(%ebp)
  802030:	6a 00                	push   $0x0
  802032:	e8 b4 eb ff ff       	call   800beb <sys_page_unmap>
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80203c:	89 d0                	mov    %edx,%eax
  80203e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204e:	50                   	push   %eax
  80204f:	ff 75 08             	pushl  0x8(%ebp)
  802052:	e8 c5 f0 ff ff       	call   80111c <fd_lookup>
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	85 c0                	test   %eax,%eax
  80205c:	78 18                	js     802076 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	ff 75 f4             	pushl  -0xc(%ebp)
  802064:	e8 4d f0 ff ff       	call   8010b6 <fd2data>
	return _pipeisclosed(fd, p);
  802069:	89 c2                	mov    %eax,%edx
  80206b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206e:	e8 21 fd ff ff       	call   801d94 <_pipeisclosed>
  802073:	83 c4 10             	add    $0x10,%esp
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802088:	68 5f 2c 80 00       	push   $0x802c5f
  80208d:	ff 75 0c             	pushl  0xc(%ebp)
  802090:	e8 ce e6 ff ff       	call   800763 <strcpy>
	return 0;
}
  802095:	b8 00 00 00 00       	mov    $0x0,%eax
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	57                   	push   %edi
  8020a0:	56                   	push   %esi
  8020a1:	53                   	push   %ebx
  8020a2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020ad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b3:	eb 2d                	jmp    8020e2 <devcons_write+0x46>
		m = n - tot;
  8020b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020b8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020ba:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020bd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020c2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020c5:	83 ec 04             	sub    $0x4,%esp
  8020c8:	53                   	push   %ebx
  8020c9:	03 45 0c             	add    0xc(%ebp),%eax
  8020cc:	50                   	push   %eax
  8020cd:	57                   	push   %edi
  8020ce:	e8 22 e8 ff ff       	call   8008f5 <memmove>
		sys_cputs(buf, m);
  8020d3:	83 c4 08             	add    $0x8,%esp
  8020d6:	53                   	push   %ebx
  8020d7:	57                   	push   %edi
  8020d8:	e8 cd e9 ff ff       	call   800aaa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020dd:	01 de                	add    %ebx,%esi
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	89 f0                	mov    %esi,%eax
  8020e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020e7:	72 cc                	jb     8020b5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ec:	5b                   	pop    %ebx
  8020ed:	5e                   	pop    %esi
  8020ee:	5f                   	pop    %edi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    

008020f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	83 ec 08             	sub    $0x8,%esp
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802100:	74 2a                	je     80212c <devcons_read+0x3b>
  802102:	eb 05                	jmp    802109 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802104:	e8 3e ea ff ff       	call   800b47 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802109:	e8 ba e9 ff ff       	call   800ac8 <sys_cgetc>
  80210e:	85 c0                	test   %eax,%eax
  802110:	74 f2                	je     802104 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802112:	85 c0                	test   %eax,%eax
  802114:	78 16                	js     80212c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802116:	83 f8 04             	cmp    $0x4,%eax
  802119:	74 0c                	je     802127 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80211b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80211e:	88 02                	mov    %al,(%edx)
	return 1;
  802120:	b8 01 00 00 00       	mov    $0x1,%eax
  802125:	eb 05                	jmp    80212c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802134:	8b 45 08             	mov    0x8(%ebp),%eax
  802137:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80213a:	6a 01                	push   $0x1
  80213c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80213f:	50                   	push   %eax
  802140:	e8 65 e9 ff ff       	call   800aaa <sys_cputs>
}
  802145:	83 c4 10             	add    $0x10,%esp
  802148:	c9                   	leave  
  802149:	c3                   	ret    

0080214a <getchar>:

int
getchar(void)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802150:	6a 01                	push   $0x1
  802152:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802155:	50                   	push   %eax
  802156:	6a 00                	push   $0x0
  802158:	e8 25 f2 ff ff       	call   801382 <read>
	if (r < 0)
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	85 c0                	test   %eax,%eax
  802162:	78 0f                	js     802173 <getchar+0x29>
		return r;
	if (r < 1)
  802164:	85 c0                	test   %eax,%eax
  802166:	7e 06                	jle    80216e <getchar+0x24>
		return -E_EOF;
	return c;
  802168:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80216c:	eb 05                	jmp    802173 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80216e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80217b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217e:	50                   	push   %eax
  80217f:	ff 75 08             	pushl  0x8(%ebp)
  802182:	e8 95 ef ff ff       	call   80111c <fd_lookup>
  802187:	83 c4 10             	add    $0x10,%esp
  80218a:	85 c0                	test   %eax,%eax
  80218c:	78 11                	js     80219f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80218e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802191:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802197:	39 10                	cmp    %edx,(%eax)
  802199:	0f 94 c0             	sete   %al
  80219c:	0f b6 c0             	movzbl %al,%eax
}
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    

008021a1 <opencons>:

int
opencons(void)
{
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021aa:	50                   	push   %eax
  8021ab:	e8 1d ef ff ff       	call   8010cd <fd_alloc>
  8021b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8021b3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	78 3e                	js     8021f7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021b9:	83 ec 04             	sub    $0x4,%esp
  8021bc:	68 07 04 00 00       	push   $0x407
  8021c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c4:	6a 00                	push   $0x0
  8021c6:	e8 9b e9 ff ff       	call   800b66 <sys_page_alloc>
  8021cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8021ce:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 23                	js     8021f7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021d4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021e9:	83 ec 0c             	sub    $0xc,%esp
  8021ec:	50                   	push   %eax
  8021ed:	e8 b4 ee ff ff       	call   8010a6 <fd2num>
  8021f2:	89 c2                	mov    %eax,%edx
  8021f4:	83 c4 10             	add    $0x10,%esp
}
  8021f7:	89 d0                	mov    %edx,%eax
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	56                   	push   %esi
  8021ff:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802200:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802203:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802209:	e8 1a e9 ff ff       	call   800b28 <sys_getenvid>
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	ff 75 0c             	pushl  0xc(%ebp)
  802214:	ff 75 08             	pushl  0x8(%ebp)
  802217:	56                   	push   %esi
  802218:	50                   	push   %eax
  802219:	68 6c 2c 80 00       	push   $0x802c6c
  80221e:	e8 bb df ff ff       	call   8001de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802223:	83 c4 18             	add    $0x18,%esp
  802226:	53                   	push   %ebx
  802227:	ff 75 10             	pushl  0x10(%ebp)
  80222a:	e8 5e df ff ff       	call   80018d <vcprintf>
	cprintf("\n");
  80222f:	c7 04 24 1a 2a 80 00 	movl   $0x802a1a,(%esp)
  802236:	e8 a3 df ff ff       	call   8001de <cprintf>
  80223b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80223e:	cc                   	int3   
  80223f:	eb fd                	jmp    80223e <_panic+0x43>

00802241 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802247:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80224e:	75 2c                	jne    80227c <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802250:	83 ec 04             	sub    $0x4,%esp
  802253:	6a 07                	push   $0x7
  802255:	68 00 f0 bf ee       	push   $0xeebff000
  80225a:	6a 00                	push   $0x0
  80225c:	e8 05 e9 ff ff       	call   800b66 <sys_page_alloc>
  802261:	83 c4 10             	add    $0x10,%esp
  802264:	85 c0                	test   %eax,%eax
  802266:	79 14                	jns    80227c <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  802268:	83 ec 04             	sub    $0x4,%esp
  80226b:	68 8f 2c 80 00       	push   $0x802c8f
  802270:	6a 22                	push   $0x22
  802272:	68 a6 2c 80 00       	push   $0x802ca6
  802277:	e8 7f ff ff ff       	call   8021fb <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
  80227f:	a3 00 70 80 00       	mov    %eax,0x807000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802284:	83 ec 08             	sub    $0x8,%esp
  802287:	68 b0 22 80 00       	push   $0x8022b0
  80228c:	6a 00                	push   $0x0
  80228e:	e8 1e ea ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
  802293:	83 c4 10             	add    $0x10,%esp
  802296:	85 c0                	test   %eax,%eax
  802298:	79 14                	jns    8022ae <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80229a:	83 ec 04             	sub    $0x4,%esp
  80229d:	68 b4 2c 80 00       	push   $0x802cb4
  8022a2:	6a 27                	push   $0x27
  8022a4:	68 a6 2c 80 00       	push   $0x802ca6
  8022a9:	e8 4d ff ff ff       	call   8021fb <_panic>
    
}
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022b1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022b8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  8022bb:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  8022bf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  8022c4:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8022c8:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8022ca:	83 c4 08             	add    $0x8,%esp
	popal
  8022cd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  8022ce:	83 c4 04             	add    $0x4,%esp
	popfl
  8022d1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022d2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022d3:	c3                   	ret    

008022d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	56                   	push   %esi
  8022d8:	53                   	push   %ebx
  8022d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8022dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	74 0e                	je     8022f4 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8022e6:	83 ec 0c             	sub    $0xc,%esp
  8022e9:	50                   	push   %eax
  8022ea:	e8 27 ea ff ff       	call   800d16 <sys_ipc_recv>
  8022ef:	83 c4 10             	add    $0x10,%esp
  8022f2:	eb 10                	jmp    802304 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8022f4:	83 ec 0c             	sub    $0xc,%esp
  8022f7:	68 00 00 00 f0       	push   $0xf0000000
  8022fc:	e8 15 ea ff ff       	call   800d16 <sys_ipc_recv>
  802301:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802304:	85 c0                	test   %eax,%eax
  802306:	74 0e                	je     802316 <ipc_recv+0x42>
    	*from_env_store = 0;
  802308:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80230e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  802314:	eb 24                	jmp    80233a <ipc_recv+0x66>
    }	
    if (from_env_store) {
  802316:	85 f6                	test   %esi,%esi
  802318:	74 0a                	je     802324 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  80231a:	a1 08 40 80 00       	mov    0x804008,%eax
  80231f:	8b 40 74             	mov    0x74(%eax),%eax
  802322:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  802324:	85 db                	test   %ebx,%ebx
  802326:	74 0a                	je     802332 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802328:	a1 08 40 80 00       	mov    0x804008,%eax
  80232d:	8b 40 78             	mov    0x78(%eax),%eax
  802330:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  802332:	a1 08 40 80 00       	mov    0x804008,%eax
  802337:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80233a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	57                   	push   %edi
  802345:	56                   	push   %esi
  802346:	53                   	push   %ebx
  802347:	83 ec 0c             	sub    $0xc,%esp
  80234a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80234d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802350:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802353:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80235a:	0f 44 d8             	cmove  %eax,%ebx
  80235d:	eb 1c                	jmp    80237b <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80235f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802362:	74 12                	je     802376 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802364:	50                   	push   %eax
  802365:	68 d8 2c 80 00       	push   $0x802cd8
  80236a:	6a 4b                	push   $0x4b
  80236c:	68 f0 2c 80 00       	push   $0x802cf0
  802371:	e8 85 fe ff ff       	call   8021fb <_panic>
        }	
        sys_yield();
  802376:	e8 cc e7 ff ff       	call   800b47 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80237b:	ff 75 14             	pushl  0x14(%ebp)
  80237e:	53                   	push   %ebx
  80237f:	56                   	push   %esi
  802380:	57                   	push   %edi
  802381:	e8 6d e9 ff ff       	call   800cf3 <sys_ipc_try_send>
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	85 c0                	test   %eax,%eax
  80238b:	75 d2                	jne    80235f <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80238d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802390:	5b                   	pop    %ebx
  802391:	5e                   	pop    %esi
  802392:	5f                   	pop    %edi
  802393:	5d                   	pop    %ebp
  802394:	c3                   	ret    

00802395 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802395:	55                   	push   %ebp
  802396:	89 e5                	mov    %esp,%ebp
  802398:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80239b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023a0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023a3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023a9:	8b 52 50             	mov    0x50(%edx),%edx
  8023ac:	39 ca                	cmp    %ecx,%edx
  8023ae:	75 0d                	jne    8023bd <ipc_find_env+0x28>
			return envs[i].env_id;
  8023b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023b8:	8b 40 48             	mov    0x48(%eax),%eax
  8023bb:	eb 0f                	jmp    8023cc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023bd:	83 c0 01             	add    $0x1,%eax
  8023c0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023c5:	75 d9                	jne    8023a0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023cc:	5d                   	pop    %ebp
  8023cd:	c3                   	ret    

008023ce <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d4:	89 d0                	mov    %edx,%eax
  8023d6:	c1 e8 16             	shr    $0x16,%eax
  8023d9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023e0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e5:	f6 c1 01             	test   $0x1,%cl
  8023e8:	74 1d                	je     802407 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ea:	c1 ea 0c             	shr    $0xc,%edx
  8023ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f4:	f6 c2 01             	test   $0x1,%dl
  8023f7:	74 0e                	je     802407 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f9:	c1 ea 0c             	shr    $0xc,%edx
  8023fc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802403:	ef 
  802404:	0f b7 c0             	movzwl %ax,%eax
}
  802407:	5d                   	pop    %ebp
  802408:	c3                   	ret    
  802409:	66 90                	xchg   %ax,%ax
  80240b:	66 90                	xchg   %ax,%ax
  80240d:	66 90                	xchg   %ax,%ax
  80240f:	90                   	nop

00802410 <__udivdi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80241b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80241f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 f6                	test   %esi,%esi
  802429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242d:	89 ca                	mov    %ecx,%edx
  80242f:	89 f8                	mov    %edi,%eax
  802431:	75 3d                	jne    802470 <__udivdi3+0x60>
  802433:	39 cf                	cmp    %ecx,%edi
  802435:	0f 87 c5 00 00 00    	ja     802500 <__udivdi3+0xf0>
  80243b:	85 ff                	test   %edi,%edi
  80243d:	89 fd                	mov    %edi,%ebp
  80243f:	75 0b                	jne    80244c <__udivdi3+0x3c>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	31 d2                	xor    %edx,%edx
  802448:	f7 f7                	div    %edi
  80244a:	89 c5                	mov    %eax,%ebp
  80244c:	89 c8                	mov    %ecx,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f5                	div    %ebp
  802452:	89 c1                	mov    %eax,%ecx
  802454:	89 d8                	mov    %ebx,%eax
  802456:	89 cf                	mov    %ecx,%edi
  802458:	f7 f5                	div    %ebp
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	39 ce                	cmp    %ecx,%esi
  802472:	77 74                	ja     8024e8 <__udivdi3+0xd8>
  802474:	0f bd fe             	bsr    %esi,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0x108>
  802480:	bb 20 00 00 00       	mov    $0x20,%ebx
  802485:	89 f9                	mov    %edi,%ecx
  802487:	89 c5                	mov    %eax,%ebp
  802489:	29 fb                	sub    %edi,%ebx
  80248b:	d3 e6                	shl    %cl,%esi
  80248d:	89 d9                	mov    %ebx,%ecx
  80248f:	d3 ed                	shr    %cl,%ebp
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e0                	shl    %cl,%eax
  802495:	09 ee                	or     %ebp,%esi
  802497:	89 d9                	mov    %ebx,%ecx
  802499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249d:	89 d5                	mov    %edx,%ebp
  80249f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024a3:	d3 ed                	shr    %cl,%ebp
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e2                	shl    %cl,%edx
  8024a9:	89 d9                	mov    %ebx,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 c2                	or     %eax,%edx
  8024af:	89 d0                	mov    %edx,%eax
  8024b1:	89 ea                	mov    %ebp,%edx
  8024b3:	f7 f6                	div    %esi
  8024b5:	89 d5                	mov    %edx,%ebp
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	72 10                	jb     8024d1 <__udivdi3+0xc1>
  8024c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e6                	shl    %cl,%esi
  8024c9:	39 c6                	cmp    %eax,%esi
  8024cb:	73 07                	jae    8024d4 <__udivdi3+0xc4>
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	75 03                	jne    8024d4 <__udivdi3+0xc4>
  8024d1:	83 eb 01             	sub    $0x1,%ebx
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 d8                	mov    %ebx,%eax
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 ff                	xor    %edi,%edi
  8024ea:	31 db                	xor    %ebx,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d8                	mov    %ebx,%eax
  802502:	f7 f7                	div    %edi
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 c3                	mov    %eax,%ebx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 fa                	mov    %edi,%edx
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	39 ce                	cmp    %ecx,%esi
  80251a:	72 0c                	jb     802528 <__udivdi3+0x118>
  80251c:	31 db                	xor    %ebx,%ebx
  80251e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802522:	0f 87 34 ff ff ff    	ja     80245c <__udivdi3+0x4c>
  802528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80252d:	e9 2a ff ff ff       	jmp    80245c <__udivdi3+0x4c>
  802532:	66 90                	xchg   %ax,%ax
  802534:	66 90                	xchg   %ax,%ax
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80254b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80254f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 d2                	test   %edx,%edx
  802559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f3                	mov    %esi,%ebx
  802563:	89 3c 24             	mov    %edi,(%esp)
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	75 1c                	jne    802588 <__umoddi3+0x48>
  80256c:	39 f7                	cmp    %esi,%edi
  80256e:	76 50                	jbe    8025c0 <__umoddi3+0x80>
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	f7 f7                	div    %edi
  802576:	89 d0                	mov    %edx,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	39 f2                	cmp    %esi,%edx
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	77 52                	ja     8025e0 <__umoddi3+0xa0>
  80258e:	0f bd ea             	bsr    %edx,%ebp
  802591:	83 f5 1f             	xor    $0x1f,%ebp
  802594:	75 5a                	jne    8025f0 <__umoddi3+0xb0>
  802596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80259a:	0f 82 e0 00 00 00    	jb     802680 <__umoddi3+0x140>
  8025a0:	39 0c 24             	cmp    %ecx,(%esp)
  8025a3:	0f 86 d7 00 00 00    	jbe    802680 <__umoddi3+0x140>
  8025a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	85 ff                	test   %edi,%edi
  8025c2:	89 fd                	mov    %edi,%ebp
  8025c4:	75 0b                	jne    8025d1 <__umoddi3+0x91>
  8025c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	f7 f7                	div    %edi
  8025cf:	89 c5                	mov    %eax,%ebp
  8025d1:	89 f0                	mov    %esi,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 f5                	div    %ebp
  8025d7:	89 c8                	mov    %ecx,%eax
  8025d9:	f7 f5                	div    %ebp
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	eb 99                	jmp    802578 <__umoddi3+0x38>
  8025df:	90                   	nop
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	83 c4 1c             	add    $0x1c,%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	8b 34 24             	mov    (%esp),%esi
  8025f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	29 ef                	sub    %ebp,%edi
  8025fc:	d3 e0                	shl    %cl,%eax
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	89 f2                	mov    %esi,%edx
  802602:	d3 ea                	shr    %cl,%edx
  802604:	89 e9                	mov    %ebp,%ecx
  802606:	09 c2                	or     %eax,%edx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 14 24             	mov    %edx,(%esp)
  80260d:	89 f2                	mov    %esi,%edx
  80260f:	d3 e2                	shl    %cl,%edx
  802611:	89 f9                	mov    %edi,%ecx
  802613:	89 54 24 04          	mov    %edx,0x4(%esp)
  802617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	89 c6                	mov    %eax,%esi
  802621:	d3 e3                	shl    %cl,%ebx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 d0                	mov    %edx,%eax
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	09 d8                	or     %ebx,%eax
  80262d:	89 d3                	mov    %edx,%ebx
  80262f:	89 f2                	mov    %esi,%edx
  802631:	f7 34 24             	divl   (%esp)
  802634:	89 d6                	mov    %edx,%esi
  802636:	d3 e3                	shl    %cl,%ebx
  802638:	f7 64 24 04          	mull   0x4(%esp)
  80263c:	39 d6                	cmp    %edx,%esi
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 d1                	mov    %edx,%ecx
  802644:	89 c3                	mov    %eax,%ebx
  802646:	72 08                	jb     802650 <__umoddi3+0x110>
  802648:	75 11                	jne    80265b <__umoddi3+0x11b>
  80264a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80264e:	73 0b                	jae    80265b <__umoddi3+0x11b>
  802650:	2b 44 24 04          	sub    0x4(%esp),%eax
  802654:	1b 14 24             	sbb    (%esp),%edx
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80265f:	29 da                	sub    %ebx,%edx
  802661:	19 ce                	sbb    %ecx,%esi
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 f0                	mov    %esi,%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	09 d0                	or     %edx,%eax
  802673:	89 f2                	mov    %esi,%edx
  802675:	83 c4 1c             	add    $0x1c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    
  80267d:	8d 76 00             	lea    0x0(%esi),%esi
  802680:	29 f9                	sub    %edi,%ecx
  802682:	19 d6                	sbb    %edx,%esi
  802684:	89 74 24 04          	mov    %esi,0x4(%esp)
  802688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80268c:	e9 18 ff ff ff       	jmp    8025a9 <__umoddi3+0x69>
