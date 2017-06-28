
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 40 28 80 00       	push   $0x802840
  800047:	e8 72 01 00 00       	call   8001be <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 5e 28 80 00       	push   $0x80285e
  800056:	68 5e 28 80 00       	push   $0x80285e
  80005b:	e8 5d 1a 00 00       	call   801abd <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 64 28 80 00       	push   $0x802864
  80006d:	6a 09                	push   $0x9
  80006f:	68 7c 28 80 00       	push   $0x80287c
  800074:	e8 6c 00 00 00       	call   8000e5 <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800086:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80008d:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800090:	e8 73 0a 00 00       	call   800b08 <sys_getenvid>
  800095:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80009d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a7:	85 db                	test   %ebx,%ebx
  8000a9:	7e 07                	jle    8000b2 <libmain+0x37>
		binaryname = argv[0];
  8000ab:	8b 06                	mov    (%esi),%eax
  8000ad:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	56                   	push   %esi
  8000b6:	53                   	push   %ebx
  8000b7:	e8 77 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 0a 00 00 00       	call   8000cb <exit>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d1:	e8 6c 0e 00 00       	call   800f42 <close_all>
	sys_env_destroy(0);
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	6a 00                	push   $0x0
  8000db:	e8 e7 09 00 00       	call   800ac7 <sys_env_destroy>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000ed:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000f3:	e8 10 0a 00 00       	call   800b08 <sys_getenvid>
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	ff 75 0c             	pushl  0xc(%ebp)
  8000fe:	ff 75 08             	pushl  0x8(%ebp)
  800101:	56                   	push   %esi
  800102:	50                   	push   %eax
  800103:	68 98 28 80 00       	push   $0x802898
  800108:	e8 b1 00 00 00       	call   8001be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80010d:	83 c4 18             	add    $0x18,%esp
  800110:	53                   	push   %ebx
  800111:	ff 75 10             	pushl  0x10(%ebp)
  800114:	e8 54 00 00 00       	call   80016d <vcprintf>
	cprintf("\n");
  800119:	c7 04 24 9d 2d 80 00 	movl   $0x802d9d,(%esp)
  800120:	e8 99 00 00 00       	call   8001be <cprintf>
  800125:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800128:	cc                   	int3   
  800129:	eb fd                	jmp    800128 <_panic+0x43>

0080012b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	53                   	push   %ebx
  80012f:	83 ec 04             	sub    $0x4,%esp
  800132:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800135:	8b 13                	mov    (%ebx),%edx
  800137:	8d 42 01             	lea    0x1(%edx),%eax
  80013a:	89 03                	mov    %eax,(%ebx)
  80013c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800143:	3d ff 00 00 00       	cmp    $0xff,%eax
  800148:	75 1a                	jne    800164 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	68 ff 00 00 00       	push   $0xff
  800152:	8d 43 08             	lea    0x8(%ebx),%eax
  800155:	50                   	push   %eax
  800156:	e8 2f 09 00 00       	call   800a8a <sys_cputs>
		b->idx = 0;
  80015b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800161:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800164:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800176:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017d:	00 00 00 
	b.cnt = 0;
  800180:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800187:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018a:	ff 75 0c             	pushl  0xc(%ebp)
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	68 2b 01 80 00       	push   $0x80012b
  80019c:	e8 54 01 00 00       	call   8002f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	83 c4 08             	add    $0x8,%esp
  8001a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 d4 08 00 00       	call   800a8a <sys_cputs>

	return b.cnt;
}
  8001b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c7:	50                   	push   %eax
  8001c8:	ff 75 08             	pushl  0x8(%ebp)
  8001cb:	e8 9d ff ff ff       	call   80016d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    

008001d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 1c             	sub    $0x1c,%esp
  8001db:	89 c7                	mov    %eax,%edi
  8001dd:	89 d6                	mov    %edx,%esi
  8001df:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f9:	39 d3                	cmp    %edx,%ebx
  8001fb:	72 05                	jb     800202 <printnum+0x30>
  8001fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800200:	77 45                	ja     800247 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	ff 75 18             	pushl  0x18(%ebp)
  800208:	8b 45 14             	mov    0x14(%ebp),%eax
  80020b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020e:	53                   	push   %ebx
  80020f:	ff 75 10             	pushl  0x10(%ebp)
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	ff 75 e4             	pushl  -0x1c(%ebp)
  800218:	ff 75 e0             	pushl  -0x20(%ebp)
  80021b:	ff 75 dc             	pushl  -0x24(%ebp)
  80021e:	ff 75 d8             	pushl  -0x28(%ebp)
  800221:	e8 8a 23 00 00       	call   8025b0 <__udivdi3>
  800226:	83 c4 18             	add    $0x18,%esp
  800229:	52                   	push   %edx
  80022a:	50                   	push   %eax
  80022b:	89 f2                	mov    %esi,%edx
  80022d:	89 f8                	mov    %edi,%eax
  80022f:	e8 9e ff ff ff       	call   8001d2 <printnum>
  800234:	83 c4 20             	add    $0x20,%esp
  800237:	eb 18                	jmp    800251 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800239:	83 ec 08             	sub    $0x8,%esp
  80023c:	56                   	push   %esi
  80023d:	ff 75 18             	pushl  0x18(%ebp)
  800240:	ff d7                	call   *%edi
  800242:	83 c4 10             	add    $0x10,%esp
  800245:	eb 03                	jmp    80024a <printnum+0x78>
  800247:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	85 db                	test   %ebx,%ebx
  80024f:	7f e8                	jg     800239 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	83 ec 04             	sub    $0x4,%esp
  800258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025b:	ff 75 e0             	pushl  -0x20(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 77 24 00 00       	call   8026e0 <__umoddi3>
  800269:	83 c4 14             	add    $0x14,%esp
  80026c:	0f be 80 bb 28 80 00 	movsbl 0x8028bb(%eax),%eax
  800273:	50                   	push   %eax
  800274:	ff d7                	call   *%edi
}
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800284:	83 fa 01             	cmp    $0x1,%edx
  800287:	7e 0e                	jle    800297 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	8b 52 04             	mov    0x4(%edx),%edx
  800295:	eb 22                	jmp    8002b9 <getuint+0x38>
	else if (lflag)
  800297:	85 d2                	test   %edx,%edx
  800299:	74 10                	je     8002ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a9:	eb 0e                	jmp    8002b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 02                	mov    (%edx),%eax
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ca:	73 0a                	jae    8002d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	88 02                	mov    %al,(%edx)
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e1:	50                   	push   %eax
  8002e2:	ff 75 10             	pushl  0x10(%ebp)
  8002e5:	ff 75 0c             	pushl  0xc(%ebp)
  8002e8:	ff 75 08             	pushl  0x8(%ebp)
  8002eb:	e8 05 00 00 00       	call   8002f5 <vprintfmt>
	va_end(ap);
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 2c             	sub    $0x2c,%esp
  8002fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800301:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800304:	8b 7d 10             	mov    0x10(%ebp),%edi
  800307:	eb 12                	jmp    80031b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800309:	85 c0                	test   %eax,%eax
  80030b:	0f 84 89 03 00 00    	je     80069a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	53                   	push   %ebx
  800315:	50                   	push   %eax
  800316:	ff d6                	call   *%esi
  800318:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031b:	83 c7 01             	add    $0x1,%edi
  80031e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800322:	83 f8 25             	cmp    $0x25,%eax
  800325:	75 e2                	jne    800309 <vprintfmt+0x14>
  800327:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80032b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800332:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800339:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800340:	ba 00 00 00 00       	mov    $0x0,%edx
  800345:	eb 07                	jmp    80034e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80034a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8d 47 01             	lea    0x1(%edi),%eax
  800351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800354:	0f b6 07             	movzbl (%edi),%eax
  800357:	0f b6 c8             	movzbl %al,%ecx
  80035a:	83 e8 23             	sub    $0x23,%eax
  80035d:	3c 55                	cmp    $0x55,%al
  80035f:	0f 87 1a 03 00 00    	ja     80067f <vprintfmt+0x38a>
  800365:	0f b6 c0             	movzbl %al,%eax
  800368:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800372:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800376:	eb d6                	jmp    80034e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037b:	b8 00 00 00 00       	mov    $0x0,%eax
  800380:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800383:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800386:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80038a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80038d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800390:	83 fa 09             	cmp    $0x9,%edx
  800393:	77 39                	ja     8003ce <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800395:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800398:	eb e9                	jmp    800383 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ab:	eb 27                	jmp    8003d4 <vprintfmt+0xdf>
  8003ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b7:	0f 49 c8             	cmovns %eax,%ecx
  8003ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	eb 8c                	jmp    80034e <vprintfmt+0x59>
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003cc:	eb 80                	jmp    80034e <vprintfmt+0x59>
  8003ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d8:	0f 89 70 ff ff ff    	jns    80034e <vprintfmt+0x59>
				width = precision, precision = -1;
  8003de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003eb:	e9 5e ff ff ff       	jmp    80034e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f6:	e9 53 ff ff ff       	jmp    80034e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 50 04             	lea    0x4(%eax),%edx
  800401:	89 55 14             	mov    %edx,0x14(%ebp)
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	ff 30                	pushl  (%eax)
  80040a:	ff d6                	call   *%esi
			break;
  80040c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800412:	e9 04 ff ff ff       	jmp    80031b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	99                   	cltd   
  800423:	31 d0                	xor    %edx,%eax
  800425:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800427:	83 f8 0f             	cmp    $0xf,%eax
  80042a:	7f 0b                	jg     800437 <vprintfmt+0x142>
  80042c:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800433:	85 d2                	test   %edx,%edx
  800435:	75 18                	jne    80044f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800437:	50                   	push   %eax
  800438:	68 d3 28 80 00       	push   $0x8028d3
  80043d:	53                   	push   %ebx
  80043e:	56                   	push   %esi
  80043f:	e8 94 fe ff ff       	call   8002d8 <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044a:	e9 cc fe ff ff       	jmp    80031b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044f:	52                   	push   %edx
  800450:	68 95 2c 80 00       	push   $0x802c95
  800455:	53                   	push   %ebx
  800456:	56                   	push   %esi
  800457:	e8 7c fe ff ff       	call   8002d8 <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800462:	e9 b4 fe ff ff       	jmp    80031b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800472:	85 ff                	test   %edi,%edi
  800474:	b8 cc 28 80 00       	mov    $0x8028cc,%eax
  800479:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800480:	0f 8e 94 00 00 00    	jle    80051a <vprintfmt+0x225>
  800486:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048a:	0f 84 98 00 00 00    	je     800528 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 d0             	pushl  -0x30(%ebp)
  800496:	57                   	push   %edi
  800497:	e8 86 02 00 00       	call   800722 <strnlen>
  80049c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049f:	29 c1                	sub    %eax,%ecx
  8004a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	eb 0f                	jmp    8004c4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	53                   	push   %ebx
  8004b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004be:	83 ef 01             	sub    $0x1,%edi
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	85 ff                	test   %edi,%edi
  8004c6:	7f ed                	jg     8004b5 <vprintfmt+0x1c0>
  8004c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ce:	85 c9                	test   %ecx,%ecx
  8004d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d5:	0f 49 c1             	cmovns %ecx,%eax
  8004d8:	29 c1                	sub    %eax,%ecx
  8004da:	89 75 08             	mov    %esi,0x8(%ebp)
  8004dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e3:	89 cb                	mov    %ecx,%ebx
  8004e5:	eb 4d                	jmp    800534 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004eb:	74 1b                	je     800508 <vprintfmt+0x213>
  8004ed:	0f be c0             	movsbl %al,%eax
  8004f0:	83 e8 20             	sub    $0x20,%eax
  8004f3:	83 f8 5e             	cmp    $0x5e,%eax
  8004f6:	76 10                	jbe    800508 <vprintfmt+0x213>
					putch('?', putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 0c             	pushl  0xc(%ebp)
  8004fe:	6a 3f                	push   $0x3f
  800500:	ff 55 08             	call   *0x8(%ebp)
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	eb 0d                	jmp    800515 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	52                   	push   %edx
  80050f:	ff 55 08             	call   *0x8(%ebp)
  800512:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800515:	83 eb 01             	sub    $0x1,%ebx
  800518:	eb 1a                	jmp    800534 <vprintfmt+0x23f>
  80051a:	89 75 08             	mov    %esi,0x8(%ebp)
  80051d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800520:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800523:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800526:	eb 0c                	jmp    800534 <vprintfmt+0x23f>
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800531:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800534:	83 c7 01             	add    $0x1,%edi
  800537:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053b:	0f be d0             	movsbl %al,%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	74 23                	je     800565 <vprintfmt+0x270>
  800542:	85 f6                	test   %esi,%esi
  800544:	78 a1                	js     8004e7 <vprintfmt+0x1f2>
  800546:	83 ee 01             	sub    $0x1,%esi
  800549:	79 9c                	jns    8004e7 <vprintfmt+0x1f2>
  80054b:	89 df                	mov    %ebx,%edi
  80054d:	8b 75 08             	mov    0x8(%ebp),%esi
  800550:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800553:	eb 18                	jmp    80056d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	6a 20                	push   $0x20
  80055b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055d:	83 ef 01             	sub    $0x1,%edi
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	eb 08                	jmp    80056d <vprintfmt+0x278>
  800565:	89 df                	mov    %ebx,%edi
  800567:	8b 75 08             	mov    0x8(%ebp),%esi
  80056a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056d:	85 ff                	test   %edi,%edi
  80056f:	7f e4                	jg     800555 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800574:	e9 a2 fd ff ff       	jmp    80031b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800579:	83 fa 01             	cmp    $0x1,%edx
  80057c:	7e 16                	jle    800594 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 08             	lea    0x8(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 50 04             	mov    0x4(%eax),%edx
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	eb 32                	jmp    8005c6 <vprintfmt+0x2d1>
	else if (lflag)
  800594:	85 d2                	test   %edx,%edx
  800596:	74 18                	je     8005b0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 50 04             	lea    0x4(%eax),%edx
  80059e:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 c1                	mov    %eax,%ecx
  8005a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ae:	eb 16                	jmp    8005c6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 c1                	mov    %eax,%ecx
  8005c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d5:	79 74                	jns    80064b <vprintfmt+0x356>
				putch('-', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	6a 2d                	push   $0x2d
  8005dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e5:	f7 d8                	neg    %eax
  8005e7:	83 d2 00             	adc    $0x0,%edx
  8005ea:	f7 da                	neg    %edx
  8005ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f4:	eb 55                	jmp    80064b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 83 fc ff ff       	call   800281 <getuint>
			base = 10;
  8005fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800603:	eb 46                	jmp    80064b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800605:	8d 45 14             	lea    0x14(%ebp),%eax
  800608:	e8 74 fc ff ff       	call   800281 <getuint>
		        base = 8;
  80060d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800612:	eb 37                	jmp    80064b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 30                	push   $0x30
  80061a:	ff d6                	call   *%esi
			putch('x', putdat);
  80061c:	83 c4 08             	add    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 78                	push   $0x78
  800622:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800634:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800637:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80063c:	eb 0d                	jmp    80064b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 3b fc ff ff       	call   800281 <getuint>
			base = 16;
  800646:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064b:	83 ec 0c             	sub    $0xc,%esp
  80064e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800652:	57                   	push   %edi
  800653:	ff 75 e0             	pushl  -0x20(%ebp)
  800656:	51                   	push   %ecx
  800657:	52                   	push   %edx
  800658:	50                   	push   %eax
  800659:	89 da                	mov    %ebx,%edx
  80065b:	89 f0                	mov    %esi,%eax
  80065d:	e8 70 fb ff ff       	call   8001d2 <printnum>
			break;
  800662:	83 c4 20             	add    $0x20,%esp
  800665:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800668:	e9 ae fc ff ff       	jmp    80031b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	53                   	push   %ebx
  800671:	51                   	push   %ecx
  800672:	ff d6                	call   *%esi
			break;
  800674:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067a:	e9 9c fc ff ff       	jmp    80031b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	6a 25                	push   $0x25
  800685:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	eb 03                	jmp    80068f <vprintfmt+0x39a>
  80068c:	83 ef 01             	sub    $0x1,%edi
  80068f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800693:	75 f7                	jne    80068c <vprintfmt+0x397>
  800695:	e9 81 fc ff ff       	jmp    80031b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80069a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069d:	5b                   	pop    %ebx
  80069e:	5e                   	pop    %esi
  80069f:	5f                   	pop    %edi
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	83 ec 18             	sub    $0x18,%esp
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	74 26                	je     8006e9 <vsnprintf+0x47>
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	7e 22                	jle    8006e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c7:	ff 75 14             	pushl  0x14(%ebp)
  8006ca:	ff 75 10             	pushl  0x10(%ebp)
  8006cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d0:	50                   	push   %eax
  8006d1:	68 bb 02 80 00       	push   $0x8002bb
  8006d6:	e8 1a fc ff ff       	call   8002f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb 05                	jmp    8006ee <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ee:	c9                   	leave  
  8006ef:	c3                   	ret    

008006f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f9:	50                   	push   %eax
  8006fa:	ff 75 10             	pushl  0x10(%ebp)
  8006fd:	ff 75 0c             	pushl  0xc(%ebp)
  800700:	ff 75 08             	pushl  0x8(%ebp)
  800703:	e8 9a ff ff ff       	call   8006a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800710:	b8 00 00 00 00       	mov    $0x0,%eax
  800715:	eb 03                	jmp    80071a <strlen+0x10>
		n++;
  800717:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071e:	75 f7                	jne    800717 <strlen+0xd>
		n++;
	return n;
}
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	ba 00 00 00 00       	mov    $0x0,%edx
  800730:	eb 03                	jmp    800735 <strnlen+0x13>
		n++;
  800732:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800735:	39 c2                	cmp    %eax,%edx
  800737:	74 08                	je     800741 <strnlen+0x1f>
  800739:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073d:	75 f3                	jne    800732 <strnlen+0x10>
  80073f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074d:	89 c2                	mov    %eax,%edx
  80074f:	83 c2 01             	add    $0x1,%edx
  800752:	83 c1 01             	add    $0x1,%ecx
  800755:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800759:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075c:	84 db                	test   %bl,%bl
  80075e:	75 ef                	jne    80074f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800760:	5b                   	pop    %ebx
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076a:	53                   	push   %ebx
  80076b:	e8 9a ff ff ff       	call   80070a <strlen>
  800770:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	01 d8                	add    %ebx,%eax
  800778:	50                   	push   %eax
  800779:	e8 c5 ff ff ff       	call   800743 <strcpy>
	return dst;
}
  80077e:	89 d8                	mov    %ebx,%eax
  800780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	89 f3                	mov    %esi,%ebx
  800792:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800795:	89 f2                	mov    %esi,%edx
  800797:	eb 0f                	jmp    8007a8 <strncpy+0x23>
		*dst++ = *src;
  800799:	83 c2 01             	add    $0x1,%edx
  80079c:	0f b6 01             	movzbl (%ecx),%eax
  80079f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	39 da                	cmp    %ebx,%edx
  8007aa:	75 ed                	jne    800799 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	74 21                	je     8007e7 <strlcpy+0x35>
  8007c6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ca:	89 f2                	mov    %esi,%edx
  8007cc:	eb 09                	jmp    8007d7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ce:	83 c2 01             	add    $0x1,%edx
  8007d1:	83 c1 01             	add    $0x1,%ecx
  8007d4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d7:	39 c2                	cmp    %eax,%edx
  8007d9:	74 09                	je     8007e4 <strlcpy+0x32>
  8007db:	0f b6 19             	movzbl (%ecx),%ebx
  8007de:	84 db                	test   %bl,%bl
  8007e0:	75 ec                	jne    8007ce <strlcpy+0x1c>
  8007e2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e7:	29 f0                	sub    %esi,%eax
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f6:	eb 06                	jmp    8007fe <strcmp+0x11>
		p++, q++;
  8007f8:	83 c1 01             	add    $0x1,%ecx
  8007fb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fe:	0f b6 01             	movzbl (%ecx),%eax
  800801:	84 c0                	test   %al,%al
  800803:	74 04                	je     800809 <strcmp+0x1c>
  800805:	3a 02                	cmp    (%edx),%al
  800807:	74 ef                	je     8007f8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800809:	0f b6 c0             	movzbl %al,%eax
  80080c:	0f b6 12             	movzbl (%edx),%edx
  80080f:	29 d0                	sub    %edx,%eax
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081d:	89 c3                	mov    %eax,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800822:	eb 06                	jmp    80082a <strncmp+0x17>
		n--, p++, q++;
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082a:	39 d8                	cmp    %ebx,%eax
  80082c:	74 15                	je     800843 <strncmp+0x30>
  80082e:	0f b6 08             	movzbl (%eax),%ecx
  800831:	84 c9                	test   %cl,%cl
  800833:	74 04                	je     800839 <strncmp+0x26>
  800835:	3a 0a                	cmp    (%edx),%cl
  800837:	74 eb                	je     800824 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 00             	movzbl (%eax),%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
  800841:	eb 05                	jmp    800848 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800848:	5b                   	pop    %ebx
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800855:	eb 07                	jmp    80085e <strchr+0x13>
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	74 0f                	je     80086a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	0f b6 10             	movzbl (%eax),%edx
  800861:	84 d2                	test   %dl,%dl
  800863:	75 f2                	jne    800857 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800876:	eb 03                	jmp    80087b <strfind+0xf>
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80087e:	38 ca                	cmp    %cl,%dl
  800880:	74 04                	je     800886 <strfind+0x1a>
  800882:	84 d2                	test   %dl,%dl
  800884:	75 f2                	jne    800878 <strfind+0xc>
			break;
	return (char *) s;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	53                   	push   %ebx
  80088e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800891:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 36                	je     8008ce <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800898:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089e:	75 28                	jne    8008c8 <memset+0x40>
  8008a0:	f6 c1 03             	test   $0x3,%cl
  8008a3:	75 23                	jne    8008c8 <memset+0x40>
		c &= 0xFF;
  8008a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a9:	89 d3                	mov    %edx,%ebx
  8008ab:	c1 e3 08             	shl    $0x8,%ebx
  8008ae:	89 d6                	mov    %edx,%esi
  8008b0:	c1 e6 18             	shl    $0x18,%esi
  8008b3:	89 d0                	mov    %edx,%eax
  8008b5:	c1 e0 10             	shl    $0x10,%eax
  8008b8:	09 f0                	or     %esi,%eax
  8008ba:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008bc:	89 d8                	mov    %ebx,%eax
  8008be:	09 d0                	or     %edx,%eax
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
  8008c3:	fc                   	cld    
  8008c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c6:	eb 06                	jmp    8008ce <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	fc                   	cld    
  8008cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ce:	89 f8                	mov    %edi,%eax
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5f                   	pop    %edi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	57                   	push   %edi
  8008d9:	56                   	push   %esi
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e3:	39 c6                	cmp    %eax,%esi
  8008e5:	73 35                	jae    80091c <memmove+0x47>
  8008e7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ea:	39 d0                	cmp    %edx,%eax
  8008ec:	73 2e                	jae    80091c <memmove+0x47>
		s += n;
		d += n;
  8008ee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f1:	89 d6                	mov    %edx,%esi
  8008f3:	09 fe                	or     %edi,%esi
  8008f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fb:	75 13                	jne    800910 <memmove+0x3b>
  8008fd:	f6 c1 03             	test   $0x3,%cl
  800900:	75 0e                	jne    800910 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800902:	83 ef 04             	sub    $0x4,%edi
  800905:	8d 72 fc             	lea    -0x4(%edx),%esi
  800908:	c1 e9 02             	shr    $0x2,%ecx
  80090b:	fd                   	std    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 09                	jmp    800919 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800910:	83 ef 01             	sub    $0x1,%edi
  800913:	8d 72 ff             	lea    -0x1(%edx),%esi
  800916:	fd                   	std    
  800917:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800919:	fc                   	cld    
  80091a:	eb 1d                	jmp    800939 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091c:	89 f2                	mov    %esi,%edx
  80091e:	09 c2                	or     %eax,%edx
  800920:	f6 c2 03             	test   $0x3,%dl
  800923:	75 0f                	jne    800934 <memmove+0x5f>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 0a                	jne    800934 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092a:	c1 e9 02             	shr    $0x2,%ecx
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800932:	eb 05                	jmp    800939 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800934:	89 c7                	mov    %eax,%edi
  800936:	fc                   	cld    
  800937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800940:	ff 75 10             	pushl  0x10(%ebp)
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	ff 75 08             	pushl  0x8(%ebp)
  800949:	e8 87 ff ff ff       	call   8008d5 <memmove>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095b:	89 c6                	mov    %eax,%esi
  80095d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800960:	eb 1a                	jmp    80097c <memcmp+0x2c>
		if (*s1 != *s2)
  800962:	0f b6 08             	movzbl (%eax),%ecx
  800965:	0f b6 1a             	movzbl (%edx),%ebx
  800968:	38 d9                	cmp    %bl,%cl
  80096a:	74 0a                	je     800976 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096c:	0f b6 c1             	movzbl %cl,%eax
  80096f:	0f b6 db             	movzbl %bl,%ebx
  800972:	29 d8                	sub    %ebx,%eax
  800974:	eb 0f                	jmp    800985 <memcmp+0x35>
		s1++, s2++;
  800976:	83 c0 01             	add    $0x1,%eax
  800979:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097c:	39 f0                	cmp    %esi,%eax
  80097e:	75 e2                	jne    800962 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	53                   	push   %ebx
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800990:	89 c1                	mov    %eax,%ecx
  800992:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800995:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800999:	eb 0a                	jmp    8009a5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	39 da                	cmp    %ebx,%edx
  8009a0:	74 07                	je     8009a9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	39 c8                	cmp    %ecx,%eax
  8009a7:	72 f2                	jb     80099b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b8:	eb 03                	jmp    8009bd <strtol+0x11>
		s++;
  8009ba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bd:	0f b6 01             	movzbl (%ecx),%eax
  8009c0:	3c 20                	cmp    $0x20,%al
  8009c2:	74 f6                	je     8009ba <strtol+0xe>
  8009c4:	3c 09                	cmp    $0x9,%al
  8009c6:	74 f2                	je     8009ba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c8:	3c 2b                	cmp    $0x2b,%al
  8009ca:	75 0a                	jne    8009d6 <strtol+0x2a>
		s++;
  8009cc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d4:	eb 11                	jmp    8009e7 <strtol+0x3b>
  8009d6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009db:	3c 2d                	cmp    $0x2d,%al
  8009dd:	75 08                	jne    8009e7 <strtol+0x3b>
		s++, neg = 1;
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ed:	75 15                	jne    800a04 <strtol+0x58>
  8009ef:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f2:	75 10                	jne    800a04 <strtol+0x58>
  8009f4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f8:	75 7c                	jne    800a76 <strtol+0xca>
		s += 2, base = 16;
  8009fa:	83 c1 02             	add    $0x2,%ecx
  8009fd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a02:	eb 16                	jmp    800a1a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a04:	85 db                	test   %ebx,%ebx
  800a06:	75 12                	jne    800a1a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a10:	75 08                	jne    800a1a <strtol+0x6e>
		s++, base = 8;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a22:	0f b6 11             	movzbl (%ecx),%edx
  800a25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	80 fb 09             	cmp    $0x9,%bl
  800a2d:	77 08                	ja     800a37 <strtol+0x8b>
			dig = *s - '0';
  800a2f:	0f be d2             	movsbl %dl,%edx
  800a32:	83 ea 30             	sub    $0x30,%edx
  800a35:	eb 22                	jmp    800a59 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3a:	89 f3                	mov    %esi,%ebx
  800a3c:	80 fb 19             	cmp    $0x19,%bl
  800a3f:	77 08                	ja     800a49 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 57             	sub    $0x57,%edx
  800a47:	eb 10                	jmp    800a59 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 19             	cmp    $0x19,%bl
  800a51:	77 16                	ja     800a69 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a53:	0f be d2             	movsbl %dl,%edx
  800a56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5c:	7d 0b                	jge    800a69 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a67:	eb b9                	jmp    800a22 <strtol+0x76>

	if (endptr)
  800a69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6d:	74 0d                	je     800a7c <strtol+0xd0>
		*endptr = (char *) s;
  800a6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a72:	89 0e                	mov    %ecx,(%esi)
  800a74:	eb 06                	jmp    800a7c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	74 98                	je     800a12 <strtol+0x66>
  800a7a:	eb 9e                	jmp    800a1a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7c:	89 c2                	mov    %eax,%edx
  800a7e:	f7 da                	neg    %edx
  800a80:	85 ff                	test   %edi,%edi
  800a82:	0f 45 c2             	cmovne %edx,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
  800a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a98:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	89 c7                	mov    %eax,%edi
  800a9f:	89 c6                	mov    %eax,%esi
  800aa1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab8:	89 d1                	mov    %edx,%ecx
  800aba:	89 d3                	mov    %edx,%ebx
  800abc:	89 d7                	mov    %edx,%edi
  800abe:	89 d6                	mov    %edx,%esi
  800ac0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad5:	b8 03 00 00 00       	mov    $0x3,%eax
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 cb                	mov    %ecx,%ebx
  800adf:	89 cf                	mov    %ecx,%edi
  800ae1:	89 ce                	mov    %ecx,%esi
  800ae3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae5:	85 c0                	test   %eax,%eax
  800ae7:	7e 17                	jle    800b00 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	50                   	push   %eax
  800aed:	6a 03                	push   $0x3
  800aef:	68 bf 2b 80 00       	push   $0x802bbf
  800af4:	6a 23                	push   $0x23
  800af6:	68 dc 2b 80 00       	push   $0x802bdc
  800afb:	e8 e5 f5 ff ff       	call   8000e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b13:	b8 02 00 00 00       	mov    $0x2,%eax
  800b18:	89 d1                	mov    %edx,%ecx
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	89 d7                	mov    %edx,%edi
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_yield>:

void
sys_yield(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4f:	be 00 00 00 00       	mov    $0x0,%esi
  800b54:	b8 04 00 00 00       	mov    $0x4,%eax
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b62:	89 f7                	mov    %esi,%edi
  800b64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b66:	85 c0                	test   %eax,%eax
  800b68:	7e 17                	jle    800b81 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	50                   	push   %eax
  800b6e:	6a 04                	push   $0x4
  800b70:	68 bf 2b 80 00       	push   $0x802bbf
  800b75:	6a 23                	push   $0x23
  800b77:	68 dc 2b 80 00       	push   $0x802bdc
  800b7c:	e8 64 f5 ff ff       	call   8000e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b8 05 00 00 00       	mov    $0x5,%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 17                	jle    800bc3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 05                	push   $0x5
  800bb2:	68 bf 2b 80 00       	push   $0x802bbf
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 dc 2b 80 00       	push   $0x802bdc
  800bbe:	e8 22 f5 ff ff       	call   8000e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	89 df                	mov    %ebx,%edi
  800be6:	89 de                	mov    %ebx,%esi
  800be8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 17                	jle    800c05 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 06                	push   $0x6
  800bf4:	68 bf 2b 80 00       	push   $0x802bbf
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 dc 2b 80 00       	push   $0x802bdc
  800c00:	e8 e0 f4 ff ff       	call   8000e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 df                	mov    %ebx,%edi
  800c28:	89 de                	mov    %ebx,%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 08                	push   $0x8
  800c36:	68 bf 2b 80 00       	push   $0x802bbf
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 dc 2b 80 00       	push   $0x802bdc
  800c42:	e8 9e f4 ff ff       	call   8000e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 09                	push   $0x9
  800c78:	68 bf 2b 80 00       	push   $0x802bbf
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 dc 2b 80 00       	push   $0x802bdc
  800c84:	e8 5c f4 ff ff       	call   8000e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 df                	mov    %ebx,%edi
  800cac:	89 de                	mov    %ebx,%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 0a                	push   $0xa
  800cba:	68 bf 2b 80 00       	push   $0x802bbf
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 dc 2b 80 00       	push   $0x802bdc
  800cc6:	e8 1a f4 ff ff       	call   8000e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	be 00 00 00 00       	mov    $0x0,%esi
  800cde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	89 cb                	mov    %ecx,%ebx
  800d0e:	89 cf                	mov    %ecx,%edi
  800d10:	89 ce                	mov    %ecx,%esi
  800d12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 17                	jle    800d2f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 0d                	push   $0xd
  800d1e:	68 bf 2b 80 00       	push   $0x802bbf
  800d23:	6a 23                	push   $0x23
  800d25:	68 dc 2b 80 00       	push   $0x802bdc
  800d2a:	e8 b6 f3 ff ff       	call   8000e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d42:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d47:	89 d1                	mov    %edx,%ecx
  800d49:	89 d3                	mov    %edx,%ebx
  800d4b:	89 d7                	mov    %edx,%edi
  800d4d:	89 d6                	mov    %edx,%esi
  800d4f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d82:	c1 e8 0c             	shr    $0xc,%eax
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d97:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da9:	89 c2                	mov    %eax,%edx
  800dab:	c1 ea 16             	shr    $0x16,%edx
  800dae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db5:	f6 c2 01             	test   $0x1,%dl
  800db8:	74 11                	je     800dcb <fd_alloc+0x2d>
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	c1 ea 0c             	shr    $0xc,%edx
  800dbf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc6:	f6 c2 01             	test   $0x1,%dl
  800dc9:	75 09                	jne    800dd4 <fd_alloc+0x36>
			*fd_store = fd;
  800dcb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	eb 17                	jmp    800deb <fd_alloc+0x4d>
  800dd4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dde:	75 c9                	jne    800da9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800de0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df3:	83 f8 1f             	cmp    $0x1f,%eax
  800df6:	77 36                	ja     800e2e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df8:	c1 e0 0c             	shl    $0xc,%eax
  800dfb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e00:	89 c2                	mov    %eax,%edx
  800e02:	c1 ea 16             	shr    $0x16,%edx
  800e05:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0c:	f6 c2 01             	test   $0x1,%dl
  800e0f:	74 24                	je     800e35 <fd_lookup+0x48>
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	c1 ea 0c             	shr    $0xc,%edx
  800e16:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1d:	f6 c2 01             	test   $0x1,%dl
  800e20:	74 1a                	je     800e3c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e25:	89 02                	mov    %eax,(%edx)
	return 0;
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2c:	eb 13                	jmp    800e41 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e33:	eb 0c                	jmp    800e41 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3a:	eb 05                	jmp    800e41 <fd_lookup+0x54>
  800e3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	83 ec 08             	sub    $0x8,%esp
  800e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4c:	ba 68 2c 80 00       	mov    $0x802c68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e51:	eb 13                	jmp    800e66 <dev_lookup+0x23>
  800e53:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e56:	39 08                	cmp    %ecx,(%eax)
  800e58:	75 0c                	jne    800e66 <dev_lookup+0x23>
			*dev = devtab[i];
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	eb 2e                	jmp    800e94 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e66:	8b 02                	mov    (%edx),%eax
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	75 e7                	jne    800e53 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6c:	a1 08 40 80 00       	mov    0x804008,%eax
  800e71:	8b 40 48             	mov    0x48(%eax),%eax
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	51                   	push   %ecx
  800e78:	50                   	push   %eax
  800e79:	68 ec 2b 80 00       	push   $0x802bec
  800e7e:	e8 3b f3 ff ff       	call   8001be <cprintf>
	*dev = 0;
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 10             	sub    $0x10,%esp
  800e9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea7:	50                   	push   %eax
  800ea8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
  800eb1:	50                   	push   %eax
  800eb2:	e8 36 ff ff ff       	call   800ded <fd_lookup>
  800eb7:	83 c4 08             	add    $0x8,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 05                	js     800ec3 <fd_close+0x2d>
	    || fd != fd2)
  800ebe:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec1:	74 0c                	je     800ecf <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec3:	84 db                	test   %bl,%bl
  800ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eca:	0f 44 c2             	cmove  %edx,%eax
  800ecd:	eb 41                	jmp    800f10 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	ff 36                	pushl  (%esi)
  800ed8:	e8 66 ff ff ff       	call   800e43 <dev_lookup>
  800edd:	89 c3                	mov    %eax,%ebx
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	78 1a                	js     800f00 <fd_close+0x6a>
		if (dev->dev_close)
  800ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	74 0b                	je     800f00 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	56                   	push   %esi
  800ef9:	ff d0                	call   *%eax
  800efb:	89 c3                	mov    %eax,%ebx
  800efd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	56                   	push   %esi
  800f04:	6a 00                	push   $0x0
  800f06:	e8 c0 fc ff ff       	call   800bcb <sys_page_unmap>
	return r;
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	89 d8                	mov    %ebx,%eax
}
  800f10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	ff 75 08             	pushl  0x8(%ebp)
  800f24:	e8 c4 fe ff ff       	call   800ded <fd_lookup>
  800f29:	83 c4 08             	add    $0x8,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 10                	js     800f40 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	6a 01                	push   $0x1
  800f35:	ff 75 f4             	pushl  -0xc(%ebp)
  800f38:	e8 59 ff ff ff       	call   800e96 <fd_close>
  800f3d:	83 c4 10             	add    $0x10,%esp
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <close_all>:

void
close_all(void)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	53                   	push   %ebx
  800f46:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	53                   	push   %ebx
  800f52:	e8 c0 ff ff ff       	call   800f17 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f57:	83 c3 01             	add    $0x1,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	83 fb 20             	cmp    $0x20,%ebx
  800f60:	75 ec                	jne    800f4e <close_all+0xc>
		close(i);
}
  800f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 2c             	sub    $0x2c,%esp
  800f70:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f73:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	ff 75 08             	pushl  0x8(%ebp)
  800f7a:	e8 6e fe ff ff       	call   800ded <fd_lookup>
  800f7f:	83 c4 08             	add    $0x8,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	0f 88 c1 00 00 00    	js     80104b <dup+0xe4>
		return r;
	close(newfdnum);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	56                   	push   %esi
  800f8e:	e8 84 ff ff ff       	call   800f17 <close>

	newfd = INDEX2FD(newfdnum);
  800f93:	89 f3                	mov    %esi,%ebx
  800f95:	c1 e3 0c             	shl    $0xc,%ebx
  800f98:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f9e:	83 c4 04             	add    $0x4,%esp
  800fa1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa4:	e8 de fd ff ff       	call   800d87 <fd2data>
  800fa9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fab:	89 1c 24             	mov    %ebx,(%esp)
  800fae:	e8 d4 fd ff ff       	call   800d87 <fd2data>
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	c1 e8 16             	shr    $0x16,%eax
  800fbe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc5:	a8 01                	test   $0x1,%al
  800fc7:	74 37                	je     801000 <dup+0x99>
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	c1 e8 0c             	shr    $0xc,%eax
  800fce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd5:	f6 c2 01             	test   $0x1,%dl
  800fd8:	74 26                	je     801000 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fed:	6a 00                	push   $0x0
  800fef:	57                   	push   %edi
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 92 fb ff ff       	call   800b89 <sys_page_map>
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	83 c4 20             	add    $0x20,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	78 2e                	js     80102e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801000:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801003:	89 d0                	mov    %edx,%eax
  801005:	c1 e8 0c             	shr    $0xc,%eax
  801008:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	25 07 0e 00 00       	and    $0xe07,%eax
  801017:	50                   	push   %eax
  801018:	53                   	push   %ebx
  801019:	6a 00                	push   $0x0
  80101b:	52                   	push   %edx
  80101c:	6a 00                	push   $0x0
  80101e:	e8 66 fb ff ff       	call   800b89 <sys_page_map>
  801023:	89 c7                	mov    %eax,%edi
  801025:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801028:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102a:	85 ff                	test   %edi,%edi
  80102c:	79 1d                	jns    80104b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	53                   	push   %ebx
  801032:	6a 00                	push   $0x0
  801034:	e8 92 fb ff ff       	call   800bcb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	e8 85 fb ff ff       	call   800bcb <sys_page_unmap>
	return r;
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	89 f8                	mov    %edi,%eax
}
  80104b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 14             	sub    $0x14,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	53                   	push   %ebx
  801062:	e8 86 fd ff ff       	call   800ded <fd_lookup>
  801067:	83 c4 08             	add    $0x8,%esp
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 6d                	js     8010dd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107a:	ff 30                	pushl  (%eax)
  80107c:	e8 c2 fd ff ff       	call   800e43 <dev_lookup>
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 4c                	js     8010d4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	8b 42 08             	mov    0x8(%edx),%eax
  80108e:	83 e0 03             	and    $0x3,%eax
  801091:	83 f8 01             	cmp    $0x1,%eax
  801094:	75 21                	jne    8010b7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801096:	a1 08 40 80 00       	mov    0x804008,%eax
  80109b:	8b 40 48             	mov    0x48(%eax),%eax
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	50                   	push   %eax
  8010a3:	68 2d 2c 80 00       	push   $0x802c2d
  8010a8:	e8 11 f1 ff ff       	call   8001be <cprintf>
		return -E_INVAL;
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010b5:	eb 26                	jmp    8010dd <read+0x8a>
	}
	if (!dev->dev_read)
  8010b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ba:	8b 40 08             	mov    0x8(%eax),%eax
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	74 17                	je     8010d8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	ff 75 10             	pushl  0x10(%ebp)
  8010c7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ca:	52                   	push   %edx
  8010cb:	ff d0                	call   *%eax
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	eb 09                	jmp    8010dd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d4:	89 c2                	mov    %eax,%edx
  8010d6:	eb 05                	jmp    8010dd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010dd:	89 d0                	mov    %edx,%eax
  8010df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	eb 21                	jmp    80111b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	89 f0                	mov    %esi,%eax
  8010ff:	29 d8                	sub    %ebx,%eax
  801101:	50                   	push   %eax
  801102:	89 d8                	mov    %ebx,%eax
  801104:	03 45 0c             	add    0xc(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	57                   	push   %edi
  801109:	e8 45 ff ff ff       	call   801053 <read>
		if (m < 0)
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 10                	js     801125 <readn+0x41>
			return m;
		if (m == 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	74 0a                	je     801123 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801119:	01 c3                	add    %eax,%ebx
  80111b:	39 f3                	cmp    %esi,%ebx
  80111d:	72 db                	jb     8010fa <readn+0x16>
  80111f:	89 d8                	mov    %ebx,%eax
  801121:	eb 02                	jmp    801125 <readn+0x41>
  801123:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  80113c:	e8 ac fc ff ff       	call   800ded <fd_lookup>
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	89 c2                	mov    %eax,%edx
  801146:	85 c0                	test   %eax,%eax
  801148:	78 68                	js     8011b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801154:	ff 30                	pushl  (%eax)
  801156:	e8 e8 fc ff ff       	call   800e43 <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 47                	js     8011a9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801169:	75 21                	jne    80118c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116b:	a1 08 40 80 00       	mov    0x804008,%eax
  801170:	8b 40 48             	mov    0x48(%eax),%eax
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	53                   	push   %ebx
  801177:	50                   	push   %eax
  801178:	68 49 2c 80 00       	push   $0x802c49
  80117d:	e8 3c f0 ff ff       	call   8001be <cprintf>
		return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118a:	eb 26                	jmp    8011b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118f:	8b 52 0c             	mov    0xc(%edx),%edx
  801192:	85 d2                	test   %edx,%edx
  801194:	74 17                	je     8011ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	ff 75 10             	pushl  0x10(%ebp)
  80119c:	ff 75 0c             	pushl  0xc(%ebp)
  80119f:	50                   	push   %eax
  8011a0:	ff d2                	call   *%edx
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	eb 09                	jmp    8011b2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	eb 05                	jmp    8011b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	ff 75 08             	pushl  0x8(%ebp)
  8011c6:	e8 22 fc ff ff       	call   800ded <fd_lookup>
  8011cb:	83 c4 08             	add    $0x8,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 0e                	js     8011e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 14             	sub    $0x14,%esp
  8011e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	53                   	push   %ebx
  8011f1:	e8 f7 fb ff ff       	call   800ded <fd_lookup>
  8011f6:	83 c4 08             	add    $0x8,%esp
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 65                	js     801264 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	ff 30                	pushl  (%eax)
  80120b:	e8 33 fc ff ff       	call   800e43 <dev_lookup>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 44                	js     80125b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121e:	75 21                	jne    801241 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801220:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801225:	8b 40 48             	mov    0x48(%eax),%eax
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	53                   	push   %ebx
  80122c:	50                   	push   %eax
  80122d:	68 0c 2c 80 00       	push   $0x802c0c
  801232:	e8 87 ef ff ff       	call   8001be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123f:	eb 23                	jmp    801264 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801241:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801244:	8b 52 18             	mov    0x18(%edx),%edx
  801247:	85 d2                	test   %edx,%edx
  801249:	74 14                	je     80125f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	ff 75 0c             	pushl  0xc(%ebp)
  801251:	50                   	push   %eax
  801252:	ff d2                	call   *%edx
  801254:	89 c2                	mov    %eax,%edx
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	eb 09                	jmp    801264 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	eb 05                	jmp    801264 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80125f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801264:	89 d0                	mov    %edx,%eax
  801266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	53                   	push   %ebx
  80126f:	83 ec 14             	sub    $0x14,%esp
  801272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801275:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 75 08             	pushl  0x8(%ebp)
  80127c:	e8 6c fb ff ff       	call   800ded <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	89 c2                	mov    %eax,%edx
  801286:	85 c0                	test   %eax,%eax
  801288:	78 58                	js     8012e2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801294:	ff 30                	pushl  (%eax)
  801296:	e8 a8 fb ff ff       	call   800e43 <dev_lookup>
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 37                	js     8012d9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a9:	74 32                	je     8012dd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b5:	00 00 00 
	stat->st_isdir = 0;
  8012b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012bf:	00 00 00 
	stat->st_dev = dev;
  8012c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012cf:	ff 50 14             	call   *0x14(%eax)
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	eb 09                	jmp    8012e2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	eb 05                	jmp    8012e2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e2:	89 d0                	mov    %edx,%eax
  8012e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	6a 00                	push   $0x0
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 e7 01 00 00       	call   8014e2 <open>
  8012fb:	89 c3                	mov    %eax,%ebx
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 1b                	js     80131f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 0c             	pushl  0xc(%ebp)
  80130a:	50                   	push   %eax
  80130b:	e8 5b ff ff ff       	call   80126b <fstat>
  801310:	89 c6                	mov    %eax,%esi
	close(fd);
  801312:	89 1c 24             	mov    %ebx,(%esp)
  801315:	e8 fd fb ff ff       	call   800f17 <close>
	return r;
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	89 f0                	mov    %esi,%eax
}
  80131f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801322:	5b                   	pop    %ebx
  801323:	5e                   	pop    %esi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	89 c6                	mov    %eax,%esi
  80132d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80132f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801336:	75 12                	jne    80134a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	6a 01                	push   $0x1
  80133d:	e8 f5 11 00 00       	call   802537 <ipc_find_env>
  801342:	a3 00 40 80 00       	mov    %eax,0x804000
  801347:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80134a:	6a 07                	push   $0x7
  80134c:	68 00 50 80 00       	push   $0x805000
  801351:	56                   	push   %esi
  801352:	ff 35 00 40 80 00    	pushl  0x804000
  801358:	e8 86 11 00 00       	call   8024e3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135d:	83 c4 0c             	add    $0xc,%esp
  801360:	6a 00                	push   $0x0
  801362:	53                   	push   %ebx
  801363:	6a 00                	push   $0x0
  801365:	e8 0c 11 00 00       	call   802476 <ipc_recv>
}
  80136a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	8b 40 0c             	mov    0xc(%eax),%eax
  80137d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801382:	8b 45 0c             	mov    0xc(%ebp),%eax
  801385:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80138a:	ba 00 00 00 00       	mov    $0x0,%edx
  80138f:	b8 02 00 00 00       	mov    $0x2,%eax
  801394:	e8 8d ff ff ff       	call   801326 <fsipc>
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b6:	e8 6b ff ff ff       	call   801326 <fsipc>
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013dc:	e8 45 ff ff ff       	call   801326 <fsipc>
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 2c                	js     801411 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	68 00 50 80 00       	push   $0x805000
  8013ed:	53                   	push   %ebx
  8013ee:	e8 50 f3 ff ff       	call   800743 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801403:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801411:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	53                   	push   %ebx
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801420:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801425:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80142a:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80142d:	53                   	push   %ebx
  80142e:	ff 75 0c             	pushl  0xc(%ebp)
  801431:	68 08 50 80 00       	push   $0x805008
  801436:	e8 9a f4 ff ff       	call   8008d5 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801446:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80144c:	ba 00 00 00 00       	mov    $0x0,%edx
  801451:	b8 04 00 00 00       	mov    $0x4,%eax
  801456:	e8 cb fe ff ff       	call   801326 <fsipc>
	//panic("devfile_write not implemented");
}
  80145b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	56                   	push   %esi
  801464:	53                   	push   %ebx
  801465:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801468:	8b 45 08             	mov    0x8(%ebp),%eax
  80146b:	8b 40 0c             	mov    0xc(%eax),%eax
  80146e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801473:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	b8 03 00 00 00       	mov    $0x3,%eax
  801483:	e8 9e fe ff ff       	call   801326 <fsipc>
  801488:	89 c3                	mov    %eax,%ebx
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 4b                	js     8014d9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80148e:	39 c6                	cmp    %eax,%esi
  801490:	73 16                	jae    8014a8 <devfile_read+0x48>
  801492:	68 7c 2c 80 00       	push   $0x802c7c
  801497:	68 83 2c 80 00       	push   $0x802c83
  80149c:	6a 7c                	push   $0x7c
  80149e:	68 98 2c 80 00       	push   $0x802c98
  8014a3:	e8 3d ec ff ff       	call   8000e5 <_panic>
	assert(r <= PGSIZE);
  8014a8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ad:	7e 16                	jle    8014c5 <devfile_read+0x65>
  8014af:	68 a3 2c 80 00       	push   $0x802ca3
  8014b4:	68 83 2c 80 00       	push   $0x802c83
  8014b9:	6a 7d                	push   $0x7d
  8014bb:	68 98 2c 80 00       	push   $0x802c98
  8014c0:	e8 20 ec ff ff       	call   8000e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c5:	83 ec 04             	sub    $0x4,%esp
  8014c8:	50                   	push   %eax
  8014c9:	68 00 50 80 00       	push   $0x805000
  8014ce:	ff 75 0c             	pushl  0xc(%ebp)
  8014d1:	e8 ff f3 ff ff       	call   8008d5 <memmove>
	return r;
  8014d6:	83 c4 10             	add    $0x10,%esp
}
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 20             	sub    $0x20,%esp
  8014e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014ec:	53                   	push   %ebx
  8014ed:	e8 18 f2 ff ff       	call   80070a <strlen>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014fa:	7f 67                	jg     801563 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	e8 96 f8 ff ff       	call   800d9e <fd_alloc>
  801508:	83 c4 10             	add    $0x10,%esp
		return r;
  80150b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 57                	js     801568 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	53                   	push   %ebx
  801515:	68 00 50 80 00       	push   $0x805000
  80151a:	e8 24 f2 ff ff       	call   800743 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80151f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801522:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801527:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152a:	b8 01 00 00 00       	mov    $0x1,%eax
  80152f:	e8 f2 fd ff ff       	call   801326 <fsipc>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	79 14                	jns    801551 <open+0x6f>
		fd_close(fd, 0);
  80153d:	83 ec 08             	sub    $0x8,%esp
  801540:	6a 00                	push   $0x0
  801542:	ff 75 f4             	pushl  -0xc(%ebp)
  801545:	e8 4c f9 ff ff       	call   800e96 <fd_close>
		return r;
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	89 da                	mov    %ebx,%edx
  80154f:	eb 17                	jmp    801568 <open+0x86>
	}

	return fd2num(fd);
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	ff 75 f4             	pushl  -0xc(%ebp)
  801557:	e8 1b f8 ff ff       	call   800d77 <fd2num>
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	eb 05                	jmp    801568 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801563:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801568:	89 d0                	mov    %edx,%eax
  80156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801575:	ba 00 00 00 00       	mov    $0x0,%edx
  80157a:	b8 08 00 00 00       	mov    $0x8,%eax
  80157f:	e8 a2 fd ff ff       	call   801326 <fsipc>
}
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	57                   	push   %edi
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801592:	6a 00                	push   $0x0
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	e8 46 ff ff ff       	call   8014e2 <open>
  80159c:	89 c7                	mov    %eax,%edi
  80159e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	0f 88 a4 04 00 00    	js     801a53 <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	68 00 02 00 00       	push   $0x200
  8015b7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	57                   	push   %edi
  8015bf:	e8 20 fb ff ff       	call   8010e4 <readn>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015cc:	75 0c                	jne    8015da <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015ce:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015d5:	45 4c 46 
  8015d8:	74 33                	je     80160d <spawn+0x87>
		close(fd);
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015e3:	e8 2f f9 ff ff       	call   800f17 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015e8:	83 c4 0c             	add    $0xc,%esp
  8015eb:	68 7f 45 4c 46       	push   $0x464c457f
  8015f0:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015f6:	68 af 2c 80 00       	push   $0x802caf
  8015fb:	e8 be eb ff ff       	call   8001be <cprintf>
		return -E_NOT_EXEC;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801608:	e9 a6 04 00 00       	jmp    801ab3 <spawn+0x52d>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80160d:	b8 07 00 00 00       	mov    $0x7,%eax
  801612:	cd 30                	int    $0x30
  801614:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80161a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801620:	85 c0                	test   %eax,%eax
  801622:	0f 88 33 04 00 00    	js     801a5b <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801628:	89 c6                	mov    %eax,%esi
  80162a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801630:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801633:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801639:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80163f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801644:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801646:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80164c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801652:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801657:	be 00 00 00 00       	mov    $0x0,%esi
  80165c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165f:	eb 13                	jmp    801674 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	50                   	push   %eax
  801665:	e8 a0 f0 ff ff       	call   80070a <strlen>
  80166a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80166e:	83 c3 01             	add    $0x1,%ebx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80167b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80167e:	85 c0                	test   %eax,%eax
  801680:	75 df                	jne    801661 <spawn+0xdb>
  801682:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801688:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80168e:	bf 00 10 40 00       	mov    $0x401000,%edi
  801693:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801695:	89 fa                	mov    %edi,%edx
  801697:	83 e2 fc             	and    $0xfffffffc,%edx
  80169a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016a1:	29 c2                	sub    %eax,%edx
  8016a3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016a9:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016ac:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016b1:	0f 86 b4 03 00 00    	jbe    801a6b <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	6a 07                	push   $0x7
  8016bc:	68 00 00 40 00       	push   $0x400000
  8016c1:	6a 00                	push   $0x0
  8016c3:	e8 7e f4 ff ff       	call   800b46 <sys_page_alloc>
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	0f 88 9f 03 00 00    	js     801a72 <spawn+0x4ec>
  8016d3:	be 00 00 00 00       	mov    $0x0,%esi
  8016d8:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e1:	eb 30                	jmp    801713 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016e3:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016e9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016ef:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016f8:	57                   	push   %edi
  8016f9:	e8 45 f0 ff ff       	call   800743 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016fe:	83 c4 04             	add    $0x4,%esp
  801701:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801704:	e8 01 f0 ff ff       	call   80070a <strlen>
  801709:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80170d:	83 c6 01             	add    $0x1,%esi
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801719:	7f c8                	jg     8016e3 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80171b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801721:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801727:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80172e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801734:	74 19                	je     80174f <spawn+0x1c9>
  801736:	68 24 2d 80 00       	push   $0x802d24
  80173b:	68 83 2c 80 00       	push   $0x802c83
  801740:	68 f1 00 00 00       	push   $0xf1
  801745:	68 c9 2c 80 00       	push   $0x802cc9
  80174a:	e8 96 e9 ff ff       	call   8000e5 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80174f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801755:	89 f8                	mov    %edi,%eax
  801757:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80175c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80175f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801765:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801768:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80176e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	6a 07                	push   $0x7
  801779:	68 00 d0 bf ee       	push   $0xeebfd000
  80177e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801784:	68 00 00 40 00       	push   $0x400000
  801789:	6a 00                	push   $0x0
  80178b:	e8 f9 f3 ff ff       	call   800b89 <sys_page_map>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	83 c4 20             	add    $0x20,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	0f 88 04 03 00 00    	js     801aa1 <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	68 00 00 40 00       	push   $0x400000
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 1f f4 ff ff       	call   800bcb <sys_page_unmap>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	0f 88 e8 02 00 00    	js     801aa1 <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017b9:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017bf:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017c6:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017cc:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017d3:	00 00 00 
  8017d6:	e9 88 01 00 00       	jmp    801963 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8017db:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017e1:	83 38 01             	cmpl   $0x1,(%eax)
  8017e4:	0f 85 6b 01 00 00    	jne    801955 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017ea:	89 c7                	mov    %eax,%edi
  8017ec:	8b 40 18             	mov    0x18(%eax),%eax
  8017ef:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017f5:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017f8:	83 f8 01             	cmp    $0x1,%eax
  8017fb:	19 c0                	sbb    %eax,%eax
  8017fd:	83 e0 fe             	and    $0xfffffffe,%eax
  801800:	83 c0 07             	add    $0x7,%eax
  801803:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801809:	89 f8                	mov    %edi,%eax
  80180b:	8b 7f 04             	mov    0x4(%edi),%edi
  80180e:	89 f9                	mov    %edi,%ecx
  801810:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801816:	8b 78 10             	mov    0x10(%eax),%edi
  801819:	8b 50 14             	mov    0x14(%eax),%edx
  80181c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801822:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801825:	89 f0                	mov    %esi,%eax
  801827:	25 ff 0f 00 00       	and    $0xfff,%eax
  80182c:	74 14                	je     801842 <spawn+0x2bc>
		va -= i;
  80182e:	29 c6                	sub    %eax,%esi
		memsz += i;
  801830:	01 c2                	add    %eax,%edx
  801832:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801838:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80183a:	29 c1                	sub    %eax,%ecx
  80183c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801842:	bb 00 00 00 00       	mov    $0x0,%ebx
  801847:	e9 f7 00 00 00       	jmp    801943 <spawn+0x3bd>
		if (i >= filesz) {
  80184c:	39 df                	cmp    %ebx,%edi
  80184e:	77 27                	ja     801877 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801859:	56                   	push   %esi
  80185a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801860:	e8 e1 f2 ff ff       	call   800b46 <sys_page_alloc>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	0f 89 c7 00 00 00    	jns    801937 <spawn+0x3b1>
  801870:	89 c3                	mov    %eax,%ebx
  801872:	e9 09 02 00 00       	jmp    801a80 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801877:	83 ec 04             	sub    $0x4,%esp
  80187a:	6a 07                	push   $0x7
  80187c:	68 00 00 40 00       	push   $0x400000
  801881:	6a 00                	push   $0x0
  801883:	e8 be f2 ff ff       	call   800b46 <sys_page_alloc>
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	85 c0                	test   %eax,%eax
  80188d:	0f 88 e3 01 00 00    	js     801a76 <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80189c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018a2:	50                   	push   %eax
  8018a3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018a9:	e8 0b f9 ff ff       	call   8011b9 <seek>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	0f 88 c1 01 00 00    	js     801a7a <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018b9:	83 ec 04             	sub    $0x4,%esp
  8018bc:	89 f8                	mov    %edi,%eax
  8018be:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018c4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c9:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018ce:	0f 47 c2             	cmova  %edx,%eax
  8018d1:	50                   	push   %eax
  8018d2:	68 00 00 40 00       	push   $0x400000
  8018d7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018dd:	e8 02 f8 ff ff       	call   8010e4 <readn>
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	0f 88 91 01 00 00    	js     801a7e <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018ed:	83 ec 0c             	sub    $0xc,%esp
  8018f0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018f6:	56                   	push   %esi
  8018f7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018fd:	68 00 00 40 00       	push   $0x400000
  801902:	6a 00                	push   $0x0
  801904:	e8 80 f2 ff ff       	call   800b89 <sys_page_map>
  801909:	83 c4 20             	add    $0x20,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	79 15                	jns    801925 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801910:	50                   	push   %eax
  801911:	68 d5 2c 80 00       	push   $0x802cd5
  801916:	68 24 01 00 00       	push   $0x124
  80191b:	68 c9 2c 80 00       	push   $0x802cc9
  801920:	e8 c0 e7 ff ff       	call   8000e5 <_panic>
			sys_page_unmap(0, UTEMP);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	68 00 00 40 00       	push   $0x400000
  80192d:	6a 00                	push   $0x0
  80192f:	e8 97 f2 ff ff       	call   800bcb <sys_page_unmap>
  801934:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801937:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80193d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801943:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801949:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80194f:	0f 87 f7 fe ff ff    	ja     80184c <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801955:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80195c:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801963:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80196a:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801970:	0f 8c 65 fe ff ff    	jl     8017db <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80197f:	e8 93 f5 ff ff       	call   800f17 <close>
  801984:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801987:	bb 00 00 00 00       	mov    $0x0,%ebx
  80198c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
 	{
    	if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)) {
  801992:	89 d8                	mov    %ebx,%eax
  801994:	c1 e8 16             	shr    $0x16,%eax
  801997:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80199e:	a8 01                	test   $0x1,%al
  8019a0:	74 46                	je     8019e8 <spawn+0x462>
  8019a2:	89 d8                	mov    %ebx,%eax
  8019a4:	c1 e8 0c             	shr    $0xc,%eax
  8019a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019ae:	f6 c2 01             	test   $0x1,%dl
  8019b1:	74 35                	je     8019e8 <spawn+0x462>
  8019b3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019ba:	f6 c2 04             	test   $0x4,%dl
  8019bd:	74 29                	je     8019e8 <spawn+0x462>
  8019bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019c6:	f6 c6 04             	test   $0x4,%dh
  8019c9:	74 1d                	je     8019e8 <spawn+0x462>
        	sys_page_map(0, (void*)i, child, (void*)i, (uvpt[PGNUM(i)] & PTE_SYSCALL));
  8019cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8019da:	50                   	push   %eax
  8019db:	53                   	push   %ebx
  8019dc:	56                   	push   %esi
  8019dd:	53                   	push   %ebx
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 a4 f1 ff ff       	call   800b89 <sys_page_map>
  8019e5:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  8019e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019ee:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019f4:	75 9c                	jne    801992 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a06:	e8 44 f2 ff ff       	call   800c4f <sys_env_set_trapframe>
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	79 15                	jns    801a27 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  801a12:	50                   	push   %eax
  801a13:	68 f2 2c 80 00       	push   $0x802cf2
  801a18:	68 85 00 00 00       	push   $0x85
  801a1d:	68 c9 2c 80 00       	push   $0x802cc9
  801a22:	e8 be e6 ff ff       	call   8000e5 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	6a 02                	push   $0x2
  801a2c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a32:	e8 d6 f1 ff ff       	call   800c0d <sys_env_set_status>
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	79 25                	jns    801a63 <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801a3e:	50                   	push   %eax
  801a3f:	68 0c 2d 80 00       	push   $0x802d0c
  801a44:	68 88 00 00 00       	push   $0x88
  801a49:	68 c9 2c 80 00       	push   $0x802cc9
  801a4e:	e8 92 e6 ff ff       	call   8000e5 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a53:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a59:	eb 58                	jmp    801ab3 <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a5b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a61:	eb 50                	jmp    801ab3 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a63:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a69:	eb 48                	jmp    801ab3 <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a6b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a70:	eb 41                	jmp    801ab3 <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a72:	89 c3                	mov    %eax,%ebx
  801a74:	eb 3d                	jmp    801ab3 <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	eb 06                	jmp    801a80 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a7a:	89 c3                	mov    %eax,%ebx
  801a7c:	eb 02                	jmp    801a80 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a7e:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a89:	e8 39 f0 ff ff       	call   800ac7 <sys_env_destroy>
	close(fd);
  801a8e:	83 c4 04             	add    $0x4,%esp
  801a91:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a97:	e8 7b f4 ff ff       	call   800f17 <close>
	return r;
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	eb 12                	jmp    801ab3 <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	68 00 00 40 00       	push   $0x400000
  801aa9:	6a 00                	push   $0x0
  801aab:	e8 1b f1 ff ff       	call   800bcb <sys_page_unmap>
  801ab0:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ab3:	89 d8                	mov    %ebx,%eax
  801ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac2:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aca:	eb 03                	jmp    801acf <spawnl+0x12>
		argc++;
  801acc:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801acf:	83 c2 04             	add    $0x4,%edx
  801ad2:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ad6:	75 f4                	jne    801acc <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ad8:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801adf:	83 e2 f0             	and    $0xfffffff0,%edx
  801ae2:	29 d4                	sub    %edx,%esp
  801ae4:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ae8:	c1 ea 02             	shr    $0x2,%edx
  801aeb:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801af2:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af7:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801afe:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b05:	00 
  801b06:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0d:	eb 0a                	jmp    801b19 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b16:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b19:	39 d0                	cmp    %edx,%eax
  801b1b:	75 f2                	jne    801b0f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	56                   	push   %esi
  801b21:	ff 75 08             	pushl  0x8(%ebp)
  801b24:	e8 5d fa ff ff       	call   801586 <spawn>
}
  801b29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b36:	68 4c 2d 80 00       	push   $0x802d4c
  801b3b:	ff 75 0c             	pushl  0xc(%ebp)
  801b3e:	e8 00 ec ff ff       	call   800743 <strcpy>
	return 0;
}
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 10             	sub    $0x10,%esp
  801b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b54:	53                   	push   %ebx
  801b55:	e8 16 0a 00 00       	call   802570 <pageref>
  801b5a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b62:	83 f8 01             	cmp    $0x1,%eax
  801b65:	75 10                	jne    801b77 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 73 0c             	pushl  0xc(%ebx)
  801b6d:	e8 c0 02 00 00       	call   801e32 <nsipc_close>
  801b72:	89 c2                	mov    %eax,%edx
  801b74:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b77:	89 d0                	mov    %edx,%eax
  801b79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b84:	6a 00                	push   $0x0
  801b86:	ff 75 10             	pushl  0x10(%ebp)
  801b89:	ff 75 0c             	pushl  0xc(%ebp)
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	ff 70 0c             	pushl  0xc(%eax)
  801b92:	e8 78 03 00 00       	call   801f0f <nsipc_send>
}
  801b97:	c9                   	leave  
  801b98:	c3                   	ret    

00801b99 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b9f:	6a 00                	push   $0x0
  801ba1:	ff 75 10             	pushl  0x10(%ebp)
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	ff 70 0c             	pushl  0xc(%eax)
  801bad:	e8 f1 02 00 00       	call   801ea3 <nsipc_recv>
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bbd:	52                   	push   %edx
  801bbe:	50                   	push   %eax
  801bbf:	e8 29 f2 ff ff       	call   800ded <fd_lookup>
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 17                	js     801be2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bce:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801bd4:	39 08                	cmp    %ecx,(%eax)
  801bd6:	75 05                	jne    801bdd <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bd8:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdb:	eb 05                	jmp    801be2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bdd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 1c             	sub    $0x1c,%esp
  801bec:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 a7 f1 ff ff       	call   800d9e <fd_alloc>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 1b                	js     801c1b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c00:	83 ec 04             	sub    $0x4,%esp
  801c03:	68 07 04 00 00       	push   $0x407
  801c08:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0b:	6a 00                	push   $0x0
  801c0d:	e8 34 ef ff ff       	call   800b46 <sys_page_alloc>
  801c12:	89 c3                	mov    %eax,%ebx
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 c0                	test   %eax,%eax
  801c19:	79 10                	jns    801c2b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	56                   	push   %esi
  801c1f:	e8 0e 02 00 00       	call   801e32 <nsipc_close>
		return r;
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	89 d8                	mov    %ebx,%eax
  801c29:	eb 24                	jmp    801c4f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c34:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c39:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c40:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	50                   	push   %eax
  801c47:	e8 2b f1 ff ff       	call   800d77 <fd2num>
  801c4c:	83 c4 10             	add    $0x10,%esp
}
  801c4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	e8 50 ff ff ff       	call   801bb4 <fd2sockid>
		return r;
  801c64:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 1f                	js     801c89 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	ff 75 10             	pushl  0x10(%ebp)
  801c70:	ff 75 0c             	pushl  0xc(%ebp)
  801c73:	50                   	push   %eax
  801c74:	e8 12 01 00 00       	call   801d8b <nsipc_accept>
  801c79:	83 c4 10             	add    $0x10,%esp
		return r;
  801c7c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 07                	js     801c89 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c82:	e8 5d ff ff ff       	call   801be4 <alloc_sockfd>
  801c87:	89 c1                	mov    %eax,%ecx
}
  801c89:	89 c8                	mov    %ecx,%eax
  801c8b:	c9                   	leave  
  801c8c:	c3                   	ret    

00801c8d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
  801c96:	e8 19 ff ff ff       	call   801bb4 <fd2sockid>
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 12                	js     801cb1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c9f:	83 ec 04             	sub    $0x4,%esp
  801ca2:	ff 75 10             	pushl  0x10(%ebp)
  801ca5:	ff 75 0c             	pushl  0xc(%ebp)
  801ca8:	50                   	push   %eax
  801ca9:	e8 2d 01 00 00       	call   801ddb <nsipc_bind>
  801cae:	83 c4 10             	add    $0x10,%esp
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <shutdown>:

int
shutdown(int s, int how)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	e8 f3 fe ff ff       	call   801bb4 <fd2sockid>
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	78 0f                	js     801cd4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cc5:	83 ec 08             	sub    $0x8,%esp
  801cc8:	ff 75 0c             	pushl  0xc(%ebp)
  801ccb:	50                   	push   %eax
  801ccc:	e8 3f 01 00 00       	call   801e10 <nsipc_shutdown>
  801cd1:	83 c4 10             	add    $0x10,%esp
}
  801cd4:	c9                   	leave  
  801cd5:	c3                   	ret    

00801cd6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdf:	e8 d0 fe ff ff       	call   801bb4 <fd2sockid>
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 12                	js     801cfa <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ce8:	83 ec 04             	sub    $0x4,%esp
  801ceb:	ff 75 10             	pushl  0x10(%ebp)
  801cee:	ff 75 0c             	pushl  0xc(%ebp)
  801cf1:	50                   	push   %eax
  801cf2:	e8 55 01 00 00       	call   801e4c <nsipc_connect>
  801cf7:	83 c4 10             	add    $0x10,%esp
}
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <listen>:

int
listen(int s, int backlog)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d02:	8b 45 08             	mov    0x8(%ebp),%eax
  801d05:	e8 aa fe ff ff       	call   801bb4 <fd2sockid>
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 0f                	js     801d1d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d0e:	83 ec 08             	sub    $0x8,%esp
  801d11:	ff 75 0c             	pushl  0xc(%ebp)
  801d14:	50                   	push   %eax
  801d15:	e8 67 01 00 00       	call   801e81 <nsipc_listen>
  801d1a:	83 c4 10             	add    $0x10,%esp
}
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    

00801d1f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d25:	ff 75 10             	pushl  0x10(%ebp)
  801d28:	ff 75 0c             	pushl  0xc(%ebp)
  801d2b:	ff 75 08             	pushl  0x8(%ebp)
  801d2e:	e8 3a 02 00 00       	call   801f6d <nsipc_socket>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 05                	js     801d3f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d3a:	e8 a5 fe ff ff       	call   801be4 <alloc_sockfd>
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	53                   	push   %ebx
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d4a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d51:	75 12                	jne    801d65 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	6a 02                	push   $0x2
  801d58:	e8 da 07 00 00       	call   802537 <ipc_find_env>
  801d5d:	a3 04 40 80 00       	mov    %eax,0x804004
  801d62:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d65:	6a 07                	push   $0x7
  801d67:	68 00 60 80 00       	push   $0x806000
  801d6c:	53                   	push   %ebx
  801d6d:	ff 35 04 40 80 00    	pushl  0x804004
  801d73:	e8 6b 07 00 00       	call   8024e3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d78:	83 c4 0c             	add    $0xc,%esp
  801d7b:	6a 00                	push   $0x0
  801d7d:	6a 00                	push   $0x0
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 f0 06 00 00       	call   802476 <ipc_recv>
}
  801d86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d9b:	8b 06                	mov    (%esi),%eax
  801d9d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801da2:	b8 01 00 00 00       	mov    $0x1,%eax
  801da7:	e8 95 ff ff ff       	call   801d41 <nsipc>
  801dac:	89 c3                	mov    %eax,%ebx
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 20                	js     801dd2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	ff 35 10 60 80 00    	pushl  0x806010
  801dbb:	68 00 60 80 00       	push   $0x806000
  801dc0:	ff 75 0c             	pushl  0xc(%ebp)
  801dc3:	e8 0d eb ff ff       	call   8008d5 <memmove>
		*addrlen = ret->ret_addrlen;
  801dc8:	a1 10 60 80 00       	mov    0x806010,%eax
  801dcd:	89 06                	mov    %eax,(%esi)
  801dcf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801dd2:	89 d8                	mov    %ebx,%eax
  801dd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	53                   	push   %ebx
  801ddf:	83 ec 08             	sub    $0x8,%esp
  801de2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ded:	53                   	push   %ebx
  801dee:	ff 75 0c             	pushl  0xc(%ebp)
  801df1:	68 04 60 80 00       	push   $0x806004
  801df6:	e8 da ea ff ff       	call   8008d5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dfb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e01:	b8 02 00 00 00       	mov    $0x2,%eax
  801e06:	e8 36 ff ff ff       	call   801d41 <nsipc>
}
  801e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e26:	b8 03 00 00 00       	mov    $0x3,%eax
  801e2b:	e8 11 ff ff ff       	call   801d41 <nsipc>
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <nsipc_close>:

int
nsipc_close(int s)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e40:	b8 04 00 00 00       	mov    $0x4,%eax
  801e45:	e8 f7 fe ff ff       	call   801d41 <nsipc>
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 08             	sub    $0x8,%esp
  801e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e56:	8b 45 08             	mov    0x8(%ebp),%eax
  801e59:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e5e:	53                   	push   %ebx
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	68 04 60 80 00       	push   $0x806004
  801e67:	e8 69 ea ff ff       	call   8008d5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e6c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e72:	b8 05 00 00 00       	mov    $0x5,%eax
  801e77:	e8 c5 fe ff ff       	call   801d41 <nsipc>
}
  801e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e92:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e97:	b8 06 00 00 00       	mov    $0x6,%eax
  801e9c:	e8 a0 fe ff ff       	call   801d41 <nsipc>
}
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801eb3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801ebc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ec1:	b8 07 00 00 00       	mov    $0x7,%eax
  801ec6:	e8 76 fe ff ff       	call   801d41 <nsipc>
  801ecb:	89 c3                	mov    %eax,%ebx
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 35                	js     801f06 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ed1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ed6:	7f 04                	jg     801edc <nsipc_recv+0x39>
  801ed8:	39 c6                	cmp    %eax,%esi
  801eda:	7d 16                	jge    801ef2 <nsipc_recv+0x4f>
  801edc:	68 58 2d 80 00       	push   $0x802d58
  801ee1:	68 83 2c 80 00       	push   $0x802c83
  801ee6:	6a 62                	push   $0x62
  801ee8:	68 6d 2d 80 00       	push   $0x802d6d
  801eed:	e8 f3 e1 ff ff       	call   8000e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	50                   	push   %eax
  801ef6:	68 00 60 80 00       	push   $0x806000
  801efb:	ff 75 0c             	pushl  0xc(%ebp)
  801efe:	e8 d2 e9 ff ff       	call   8008d5 <memmove>
  801f03:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f06:	89 d8                	mov    %ebx,%eax
  801f08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0b:	5b                   	pop    %ebx
  801f0c:	5e                   	pop    %esi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	53                   	push   %ebx
  801f13:	83 ec 04             	sub    $0x4,%esp
  801f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f19:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f21:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f27:	7e 16                	jle    801f3f <nsipc_send+0x30>
  801f29:	68 79 2d 80 00       	push   $0x802d79
  801f2e:	68 83 2c 80 00       	push   $0x802c83
  801f33:	6a 6d                	push   $0x6d
  801f35:	68 6d 2d 80 00       	push   $0x802d6d
  801f3a:	e8 a6 e1 ff ff       	call   8000e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f3f:	83 ec 04             	sub    $0x4,%esp
  801f42:	53                   	push   %ebx
  801f43:	ff 75 0c             	pushl  0xc(%ebp)
  801f46:	68 0c 60 80 00       	push   $0x80600c
  801f4b:	e8 85 e9 ff ff       	call   8008d5 <memmove>
	nsipcbuf.send.req_size = size;
  801f50:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f56:	8b 45 14             	mov    0x14(%ebp),%eax
  801f59:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801f63:	e8 d9 fd ff ff       	call   801d41 <nsipc>
}
  801f68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    

00801f6d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f83:	8b 45 10             	mov    0x10(%ebp),%eax
  801f86:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f8b:	b8 09 00 00 00       	mov    $0x9,%eax
  801f90:	e8 ac fd ff ff       	call   801d41 <nsipc>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	56                   	push   %esi
  801f9b:	53                   	push   %ebx
  801f9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f9f:	83 ec 0c             	sub    $0xc,%esp
  801fa2:	ff 75 08             	pushl  0x8(%ebp)
  801fa5:	e8 dd ed ff ff       	call   800d87 <fd2data>
  801faa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fac:	83 c4 08             	add    $0x8,%esp
  801faf:	68 85 2d 80 00       	push   $0x802d85
  801fb4:	53                   	push   %ebx
  801fb5:	e8 89 e7 ff ff       	call   800743 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fba:	8b 46 04             	mov    0x4(%esi),%eax
  801fbd:	2b 06                	sub    (%esi),%eax
  801fbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fc5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fcc:	00 00 00 
	stat->st_dev = &devpipe;
  801fcf:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801fd6:	30 80 00 
	return 0;
}
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fef:	53                   	push   %ebx
  801ff0:	6a 00                	push   $0x0
  801ff2:	e8 d4 eb ff ff       	call   800bcb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ff7:	89 1c 24             	mov    %ebx,(%esp)
  801ffa:	e8 88 ed ff ff       	call   800d87 <fd2data>
  801fff:	83 c4 08             	add    $0x8,%esp
  802002:	50                   	push   %eax
  802003:	6a 00                	push   $0x0
  802005:	e8 c1 eb ff ff       	call   800bcb <sys_page_unmap>
}
  80200a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    

0080200f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	57                   	push   %edi
  802013:	56                   	push   %esi
  802014:	53                   	push   %ebx
  802015:	83 ec 1c             	sub    $0x1c,%esp
  802018:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80201b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80201d:	a1 08 40 80 00       	mov    0x804008,%eax
  802022:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802025:	83 ec 0c             	sub    $0xc,%esp
  802028:	ff 75 e0             	pushl  -0x20(%ebp)
  80202b:	e8 40 05 00 00       	call   802570 <pageref>
  802030:	89 c3                	mov    %eax,%ebx
  802032:	89 3c 24             	mov    %edi,(%esp)
  802035:	e8 36 05 00 00       	call   802570 <pageref>
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	39 c3                	cmp    %eax,%ebx
  80203f:	0f 94 c1             	sete   %cl
  802042:	0f b6 c9             	movzbl %cl,%ecx
  802045:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802048:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80204e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802051:	39 ce                	cmp    %ecx,%esi
  802053:	74 1b                	je     802070 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802055:	39 c3                	cmp    %eax,%ebx
  802057:	75 c4                	jne    80201d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802059:	8b 42 58             	mov    0x58(%edx),%eax
  80205c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80205f:	50                   	push   %eax
  802060:	56                   	push   %esi
  802061:	68 8c 2d 80 00       	push   $0x802d8c
  802066:	e8 53 e1 ff ff       	call   8001be <cprintf>
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	eb ad                	jmp    80201d <_pipeisclosed+0xe>
	}
}
  802070:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802076:	5b                   	pop    %ebx
  802077:	5e                   	pop    %esi
  802078:	5f                   	pop    %edi
  802079:	5d                   	pop    %ebp
  80207a:	c3                   	ret    

0080207b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	57                   	push   %edi
  80207f:	56                   	push   %esi
  802080:	53                   	push   %ebx
  802081:	83 ec 28             	sub    $0x28,%esp
  802084:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802087:	56                   	push   %esi
  802088:	e8 fa ec ff ff       	call   800d87 <fd2data>
  80208d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	bf 00 00 00 00       	mov    $0x0,%edi
  802097:	eb 4b                	jmp    8020e4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802099:	89 da                	mov    %ebx,%edx
  80209b:	89 f0                	mov    %esi,%eax
  80209d:	e8 6d ff ff ff       	call   80200f <_pipeisclosed>
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	75 48                	jne    8020ee <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020a6:	e8 7c ea ff ff       	call   800b27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020ab:	8b 43 04             	mov    0x4(%ebx),%eax
  8020ae:	8b 0b                	mov    (%ebx),%ecx
  8020b0:	8d 51 20             	lea    0x20(%ecx),%edx
  8020b3:	39 d0                	cmp    %edx,%eax
  8020b5:	73 e2                	jae    802099 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020be:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020c1:	89 c2                	mov    %eax,%edx
  8020c3:	c1 fa 1f             	sar    $0x1f,%edx
  8020c6:	89 d1                	mov    %edx,%ecx
  8020c8:	c1 e9 1b             	shr    $0x1b,%ecx
  8020cb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020ce:	83 e2 1f             	and    $0x1f,%edx
  8020d1:	29 ca                	sub    %ecx,%edx
  8020d3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020db:	83 c0 01             	add    $0x1,%eax
  8020de:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020e1:	83 c7 01             	add    $0x1,%edi
  8020e4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020e7:	75 c2                	jne    8020ab <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ec:	eb 05                	jmp    8020f3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f6:	5b                   	pop    %ebx
  8020f7:	5e                   	pop    %esi
  8020f8:	5f                   	pop    %edi
  8020f9:	5d                   	pop    %ebp
  8020fa:	c3                   	ret    

008020fb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020fb:	55                   	push   %ebp
  8020fc:	89 e5                	mov    %esp,%ebp
  8020fe:	57                   	push   %edi
  8020ff:	56                   	push   %esi
  802100:	53                   	push   %ebx
  802101:	83 ec 18             	sub    $0x18,%esp
  802104:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802107:	57                   	push   %edi
  802108:	e8 7a ec ff ff       	call   800d87 <fd2data>
  80210d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	bb 00 00 00 00       	mov    $0x0,%ebx
  802117:	eb 3d                	jmp    802156 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802119:	85 db                	test   %ebx,%ebx
  80211b:	74 04                	je     802121 <devpipe_read+0x26>
				return i;
  80211d:	89 d8                	mov    %ebx,%eax
  80211f:	eb 44                	jmp    802165 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802121:	89 f2                	mov    %esi,%edx
  802123:	89 f8                	mov    %edi,%eax
  802125:	e8 e5 fe ff ff       	call   80200f <_pipeisclosed>
  80212a:	85 c0                	test   %eax,%eax
  80212c:	75 32                	jne    802160 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80212e:	e8 f4 e9 ff ff       	call   800b27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802133:	8b 06                	mov    (%esi),%eax
  802135:	3b 46 04             	cmp    0x4(%esi),%eax
  802138:	74 df                	je     802119 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80213a:	99                   	cltd   
  80213b:	c1 ea 1b             	shr    $0x1b,%edx
  80213e:	01 d0                	add    %edx,%eax
  802140:	83 e0 1f             	and    $0x1f,%eax
  802143:	29 d0                	sub    %edx,%eax
  802145:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80214a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80214d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802150:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802153:	83 c3 01             	add    $0x1,%ebx
  802156:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802159:	75 d8                	jne    802133 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80215b:	8b 45 10             	mov    0x10(%ebp),%eax
  80215e:	eb 05                	jmp    802165 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802160:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    

0080216d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	56                   	push   %esi
  802171:	53                   	push   %ebx
  802172:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802175:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802178:	50                   	push   %eax
  802179:	e8 20 ec ff ff       	call   800d9e <fd_alloc>
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	89 c2                	mov    %eax,%edx
  802183:	85 c0                	test   %eax,%eax
  802185:	0f 88 2c 01 00 00    	js     8022b7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218b:	83 ec 04             	sub    $0x4,%esp
  80218e:	68 07 04 00 00       	push   $0x407
  802193:	ff 75 f4             	pushl  -0xc(%ebp)
  802196:	6a 00                	push   $0x0
  802198:	e8 a9 e9 ff ff       	call   800b46 <sys_page_alloc>
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	89 c2                	mov    %eax,%edx
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	0f 88 0d 01 00 00    	js     8022b7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021aa:	83 ec 0c             	sub    $0xc,%esp
  8021ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021b0:	50                   	push   %eax
  8021b1:	e8 e8 eb ff ff       	call   800d9e <fd_alloc>
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	83 c4 10             	add    $0x10,%esp
  8021bb:	85 c0                	test   %eax,%eax
  8021bd:	0f 88 e2 00 00 00    	js     8022a5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c3:	83 ec 04             	sub    $0x4,%esp
  8021c6:	68 07 04 00 00       	push   $0x407
  8021cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ce:	6a 00                	push   $0x0
  8021d0:	e8 71 e9 ff ff       	call   800b46 <sys_page_alloc>
  8021d5:	89 c3                	mov    %eax,%ebx
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	0f 88 c3 00 00 00    	js     8022a5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e8:	e8 9a eb ff ff       	call   800d87 <fd2data>
  8021ed:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ef:	83 c4 0c             	add    $0xc,%esp
  8021f2:	68 07 04 00 00       	push   $0x407
  8021f7:	50                   	push   %eax
  8021f8:	6a 00                	push   $0x0
  8021fa:	e8 47 e9 ff ff       	call   800b46 <sys_page_alloc>
  8021ff:	89 c3                	mov    %eax,%ebx
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	85 c0                	test   %eax,%eax
  802206:	0f 88 89 00 00 00    	js     802295 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80220c:	83 ec 0c             	sub    $0xc,%esp
  80220f:	ff 75 f0             	pushl  -0x10(%ebp)
  802212:	e8 70 eb ff ff       	call   800d87 <fd2data>
  802217:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80221e:	50                   	push   %eax
  80221f:	6a 00                	push   $0x0
  802221:	56                   	push   %esi
  802222:	6a 00                	push   $0x0
  802224:	e8 60 e9 ff ff       	call   800b89 <sys_page_map>
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	83 c4 20             	add    $0x20,%esp
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 55                	js     802287 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802232:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802238:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80223d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802240:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802247:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80224d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802250:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802255:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80225c:	83 ec 0c             	sub    $0xc,%esp
  80225f:	ff 75 f4             	pushl  -0xc(%ebp)
  802262:	e8 10 eb ff ff       	call   800d77 <fd2num>
  802267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80226a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80226c:	83 c4 04             	add    $0x4,%esp
  80226f:	ff 75 f0             	pushl  -0x10(%ebp)
  802272:	e8 00 eb ff ff       	call   800d77 <fd2num>
  802277:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80227a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	ba 00 00 00 00       	mov    $0x0,%edx
  802285:	eb 30                	jmp    8022b7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802287:	83 ec 08             	sub    $0x8,%esp
  80228a:	56                   	push   %esi
  80228b:	6a 00                	push   $0x0
  80228d:	e8 39 e9 ff ff       	call   800bcb <sys_page_unmap>
  802292:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802295:	83 ec 08             	sub    $0x8,%esp
  802298:	ff 75 f0             	pushl  -0x10(%ebp)
  80229b:	6a 00                	push   $0x0
  80229d:	e8 29 e9 ff ff       	call   800bcb <sys_page_unmap>
  8022a2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022a5:	83 ec 08             	sub    $0x8,%esp
  8022a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ab:	6a 00                	push   $0x0
  8022ad:	e8 19 e9 ff ff       	call   800bcb <sys_page_unmap>
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022b7:	89 d0                	mov    %edx,%eax
  8022b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5d                   	pop    %ebp
  8022bf:	c3                   	ret    

008022c0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c9:	50                   	push   %eax
  8022ca:	ff 75 08             	pushl  0x8(%ebp)
  8022cd:	e8 1b eb ff ff       	call   800ded <fd_lookup>
  8022d2:	83 c4 10             	add    $0x10,%esp
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	78 18                	js     8022f1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022d9:	83 ec 0c             	sub    $0xc,%esp
  8022dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8022df:	e8 a3 ea ff ff       	call   800d87 <fd2data>
	return _pipeisclosed(fd, p);
  8022e4:	89 c2                	mov    %eax,%edx
  8022e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e9:	e8 21 fd ff ff       	call   80200f <_pipeisclosed>
  8022ee:	83 c4 10             	add    $0x10,%esp
}
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    

008022fd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802303:	68 a4 2d 80 00       	push   $0x802da4
  802308:	ff 75 0c             	pushl  0xc(%ebp)
  80230b:	e8 33 e4 ff ff       	call   800743 <strcpy>
	return 0;
}
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
  802315:	c9                   	leave  
  802316:	c3                   	ret    

00802317 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	57                   	push   %edi
  80231b:	56                   	push   %esi
  80231c:	53                   	push   %ebx
  80231d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802323:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802328:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232e:	eb 2d                	jmp    80235d <devcons_write+0x46>
		m = n - tot;
  802330:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802333:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802335:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802338:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80233d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802340:	83 ec 04             	sub    $0x4,%esp
  802343:	53                   	push   %ebx
  802344:	03 45 0c             	add    0xc(%ebp),%eax
  802347:	50                   	push   %eax
  802348:	57                   	push   %edi
  802349:	e8 87 e5 ff ff       	call   8008d5 <memmove>
		sys_cputs(buf, m);
  80234e:	83 c4 08             	add    $0x8,%esp
  802351:	53                   	push   %ebx
  802352:	57                   	push   %edi
  802353:	e8 32 e7 ff ff       	call   800a8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802358:	01 de                	add    %ebx,%esi
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	89 f0                	mov    %esi,%eax
  80235f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802362:	72 cc                	jb     802330 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5f                   	pop    %edi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    

0080236c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	83 ec 08             	sub    $0x8,%esp
  802372:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802377:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80237b:	74 2a                	je     8023a7 <devcons_read+0x3b>
  80237d:	eb 05                	jmp    802384 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80237f:	e8 a3 e7 ff ff       	call   800b27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802384:	e8 1f e7 ff ff       	call   800aa8 <sys_cgetc>
  802389:	85 c0                	test   %eax,%eax
  80238b:	74 f2                	je     80237f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 16                	js     8023a7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802391:	83 f8 04             	cmp    $0x4,%eax
  802394:	74 0c                	je     8023a2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802396:	8b 55 0c             	mov    0xc(%ebp),%edx
  802399:	88 02                	mov    %al,(%edx)
	return 1;
  80239b:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a0:	eb 05                	jmp    8023a7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023a2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023a7:	c9                   	leave  
  8023a8:	c3                   	ret    

008023a9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023af:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023b5:	6a 01                	push   $0x1
  8023b7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ba:	50                   	push   %eax
  8023bb:	e8 ca e6 ff ff       	call   800a8a <sys_cputs>
}
  8023c0:	83 c4 10             	add    $0x10,%esp
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    

008023c5 <getchar>:

int
getchar(void)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023cb:	6a 01                	push   $0x1
  8023cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d0:	50                   	push   %eax
  8023d1:	6a 00                	push   $0x0
  8023d3:	e8 7b ec ff ff       	call   801053 <read>
	if (r < 0)
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	78 0f                	js     8023ee <getchar+0x29>
		return r;
	if (r < 1)
  8023df:	85 c0                	test   %eax,%eax
  8023e1:	7e 06                	jle    8023e9 <getchar+0x24>
		return -E_EOF;
	return c;
  8023e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023e7:	eb 05                	jmp    8023ee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023e9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ee:	c9                   	leave  
  8023ef:	c3                   	ret    

008023f0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
  8023f3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f9:	50                   	push   %eax
  8023fa:	ff 75 08             	pushl  0x8(%ebp)
  8023fd:	e8 eb e9 ff ff       	call   800ded <fd_lookup>
  802402:	83 c4 10             	add    $0x10,%esp
  802405:	85 c0                	test   %eax,%eax
  802407:	78 11                	js     80241a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802412:	39 10                	cmp    %edx,(%eax)
  802414:	0f 94 c0             	sete   %al
  802417:	0f b6 c0             	movzbl %al,%eax
}
  80241a:	c9                   	leave  
  80241b:	c3                   	ret    

0080241c <opencons>:

int
opencons(void)
{
  80241c:	55                   	push   %ebp
  80241d:	89 e5                	mov    %esp,%ebp
  80241f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802425:	50                   	push   %eax
  802426:	e8 73 e9 ff ff       	call   800d9e <fd_alloc>
  80242b:	83 c4 10             	add    $0x10,%esp
		return r;
  80242e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802430:	85 c0                	test   %eax,%eax
  802432:	78 3e                	js     802472 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802434:	83 ec 04             	sub    $0x4,%esp
  802437:	68 07 04 00 00       	push   $0x407
  80243c:	ff 75 f4             	pushl  -0xc(%ebp)
  80243f:	6a 00                	push   $0x0
  802441:	e8 00 e7 ff ff       	call   800b46 <sys_page_alloc>
  802446:	83 c4 10             	add    $0x10,%esp
		return r;
  802449:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80244b:	85 c0                	test   %eax,%eax
  80244d:	78 23                	js     802472 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80244f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802458:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802464:	83 ec 0c             	sub    $0xc,%esp
  802467:	50                   	push   %eax
  802468:	e8 0a e9 ff ff       	call   800d77 <fd2num>
  80246d:	89 c2                	mov    %eax,%edx
  80246f:	83 c4 10             	add    $0x10,%esp
}
  802472:	89 d0                	mov    %edx,%eax
  802474:	c9                   	leave  
  802475:	c3                   	ret    

00802476 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802476:	55                   	push   %ebp
  802477:	89 e5                	mov    %esp,%ebp
  802479:	56                   	push   %esi
  80247a:	53                   	push   %ebx
  80247b:	8b 75 08             	mov    0x8(%ebp),%esi
  80247e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802481:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802484:	85 c0                	test   %eax,%eax
  802486:	74 0e                	je     802496 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802488:	83 ec 0c             	sub    $0xc,%esp
  80248b:	50                   	push   %eax
  80248c:	e8 65 e8 ff ff       	call   800cf6 <sys_ipc_recv>
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	eb 10                	jmp    8024a6 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802496:	83 ec 0c             	sub    $0xc,%esp
  802499:	68 00 00 00 f0       	push   $0xf0000000
  80249e:	e8 53 e8 ff ff       	call   800cf6 <sys_ipc_recv>
  8024a3:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8024a6:	85 c0                	test   %eax,%eax
  8024a8:	74 0e                	je     8024b8 <ipc_recv+0x42>
    	*from_env_store = 0;
  8024aa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8024b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8024b6:	eb 24                	jmp    8024dc <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8024b8:	85 f6                	test   %esi,%esi
  8024ba:	74 0a                	je     8024c6 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8024bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8024c1:	8b 40 74             	mov    0x74(%eax),%eax
  8024c4:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8024c6:	85 db                	test   %ebx,%ebx
  8024c8:	74 0a                	je     8024d4 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8024ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8024cf:	8b 40 78             	mov    0x78(%eax),%eax
  8024d2:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8024d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8024d9:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8024dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    

008024e3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	57                   	push   %edi
  8024e7:	56                   	push   %esi
  8024e8:	53                   	push   %ebx
  8024e9:	83 ec 0c             	sub    $0xc,%esp
  8024ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8024f5:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8024f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024fc:	0f 44 d8             	cmove  %eax,%ebx
  8024ff:	eb 1c                	jmp    80251d <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802501:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802504:	74 12                	je     802518 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802506:	50                   	push   %eax
  802507:	68 b0 2d 80 00       	push   $0x802db0
  80250c:	6a 4b                	push   $0x4b
  80250e:	68 c8 2d 80 00       	push   $0x802dc8
  802513:	e8 cd db ff ff       	call   8000e5 <_panic>
        }	
        sys_yield();
  802518:	e8 0a e6 ff ff       	call   800b27 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80251d:	ff 75 14             	pushl  0x14(%ebp)
  802520:	53                   	push   %ebx
  802521:	56                   	push   %esi
  802522:	57                   	push   %edi
  802523:	e8 ab e7 ff ff       	call   800cd3 <sys_ipc_try_send>
  802528:	83 c4 10             	add    $0x10,%esp
  80252b:	85 c0                	test   %eax,%eax
  80252d:	75 d2                	jne    802501 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80252f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802532:	5b                   	pop    %ebx
  802533:	5e                   	pop    %esi
  802534:	5f                   	pop    %edi
  802535:	5d                   	pop    %ebp
  802536:	c3                   	ret    

00802537 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80253d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802542:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802545:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80254b:	8b 52 50             	mov    0x50(%edx),%edx
  80254e:	39 ca                	cmp    %ecx,%edx
  802550:	75 0d                	jne    80255f <ipc_find_env+0x28>
			return envs[i].env_id;
  802552:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802555:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80255a:	8b 40 48             	mov    0x48(%eax),%eax
  80255d:	eb 0f                	jmp    80256e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80255f:	83 c0 01             	add    $0x1,%eax
  802562:	3d 00 04 00 00       	cmp    $0x400,%eax
  802567:	75 d9                	jne    802542 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802569:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    

00802570 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802570:	55                   	push   %ebp
  802571:	89 e5                	mov    %esp,%ebp
  802573:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802576:	89 d0                	mov    %edx,%eax
  802578:	c1 e8 16             	shr    $0x16,%eax
  80257b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802582:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802587:	f6 c1 01             	test   $0x1,%cl
  80258a:	74 1d                	je     8025a9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80258c:	c1 ea 0c             	shr    $0xc,%edx
  80258f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802596:	f6 c2 01             	test   $0x1,%dl
  802599:	74 0e                	je     8025a9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259b:	c1 ea 0c             	shr    $0xc,%edx
  80259e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a5:	ef 
  8025a6:	0f b7 c0             	movzwl %ax,%eax
}
  8025a9:	5d                   	pop    %ebp
  8025aa:	c3                   	ret    
  8025ab:	66 90                	xchg   %ax,%ax
  8025ad:	66 90                	xchg   %ax,%ax
  8025af:	90                   	nop

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
