
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 98 11 00 00       	call   8011e5 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 60 24 80 00       	push   $0x802460
  800060:	6a 0d                	push   $0xd
  800062:	68 7b 24 80 00       	push   $0x80247b
  800067:	e8 31 01 00 00       	call   80019d <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 8c 10 00 00       	call   80110b <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 86 24 80 00       	push   $0x802486
  800098:	6a 0f                	push   $0xf
  80009a:	68 7b 24 80 00       	push   $0x80247b
  80009f:	e8 f9 00 00 00       	call   80019d <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 9b 	movl   $0x80249b,0x803000
  8000be:	24 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 9f 24 80 00       	push   $0x80249f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 ad 14 00 00       	call   80159a <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 a7 24 80 00       	push   $0x8024a7
  800102:	e8 31 16 00 00       	call   801738 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 af 0e 00 00       	call   800fcf <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80013e:	c7 05 20 60 80 00 00 	movl   $0x0,0x806020
  800145:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800148:	e8 73 0a 00 00       	call   800bc0 <sys_getenvid>
  80014d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800152:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800155:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015a:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015f:	85 db                	test   %ebx,%ebx
  800161:	7e 07                	jle    80016a <libmain+0x37>
		binaryname = argv[0];
  800163:	8b 06                	mov    (%esi),%eax
  800165:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	e8 37 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  800174:	e8 0a 00 00 00       	call   800183 <exit>
}
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800189:	e8 6c 0e 00 00       	call   800ffa <close_all>
	sys_env_destroy(0);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	6a 00                	push   $0x0
  800193:	e8 e7 09 00 00       	call   800b7f <sys_env_destroy>
}
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001ab:	e8 10 0a 00 00       	call   800bc0 <sys_getenvid>
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	ff 75 0c             	pushl  0xc(%ebp)
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	56                   	push   %esi
  8001ba:	50                   	push   %eax
  8001bb:	68 c4 24 80 00       	push   $0x8024c4
  8001c0:	e8 b1 00 00 00       	call   800276 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c5:	83 c4 18             	add    $0x18,%esp
  8001c8:	53                   	push   %ebx
  8001c9:	ff 75 10             	pushl  0x10(%ebp)
  8001cc:	e8 54 00 00 00       	call   800225 <vcprintf>
	cprintf("\n");
  8001d1:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8001d8:	e8 99 00 00 00       	call   800276 <cprintf>
  8001dd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e0:	cc                   	int3   
  8001e1:	eb fd                	jmp    8001e0 <_panic+0x43>

008001e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ed:	8b 13                	mov    (%ebx),%edx
  8001ef:	8d 42 01             	lea    0x1(%edx),%eax
  8001f2:	89 03                	mov    %eax,(%ebx)
  8001f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800200:	75 1a                	jne    80021c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	68 ff 00 00 00       	push   $0xff
  80020a:	8d 43 08             	lea    0x8(%ebx),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 2f 09 00 00       	call   800b42 <sys_cputs>
		b->idx = 0;
  800213:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800219:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800235:	00 00 00 
	b.cnt = 0;
  800238:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024e:	50                   	push   %eax
  80024f:	68 e3 01 80 00       	push   $0x8001e3
  800254:	e8 54 01 00 00       	call   8003ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800259:	83 c4 08             	add    $0x8,%esp
  80025c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800262:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	e8 d4 08 00 00       	call   800b42 <sys_cputs>

	return b.cnt;
}
  80026e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027f:	50                   	push   %eax
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	e8 9d ff ff ff       	call   800225 <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 1c             	sub    $0x1c,%esp
  800293:	89 c7                	mov    %eax,%edi
  800295:	89 d6                	mov    %edx,%esi
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ae:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002b1:	39 d3                	cmp    %edx,%ebx
  8002b3:	72 05                	jb     8002ba <printnum+0x30>
  8002b5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b8:	77 45                	ja     8002ff <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	ff 75 18             	pushl  0x18(%ebp)
  8002c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c6:	53                   	push   %ebx
  8002c7:	ff 75 10             	pushl  0x10(%ebp)
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d9:	e8 f2 1e 00 00       	call   8021d0 <__udivdi3>
  8002de:	83 c4 18             	add    $0x18,%esp
  8002e1:	52                   	push   %edx
  8002e2:	50                   	push   %eax
  8002e3:	89 f2                	mov    %esi,%edx
  8002e5:	89 f8                	mov    %edi,%eax
  8002e7:	e8 9e ff ff ff       	call   80028a <printnum>
  8002ec:	83 c4 20             	add    $0x20,%esp
  8002ef:	eb 18                	jmp    800309 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	ff 75 18             	pushl  0x18(%ebp)
  8002f8:	ff d7                	call   *%edi
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	eb 03                	jmp    800302 <printnum+0x78>
  8002ff:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	83 eb 01             	sub    $0x1,%ebx
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f e8                	jg     8002f1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	ff 75 e4             	pushl  -0x1c(%ebp)
  800313:	ff 75 e0             	pushl  -0x20(%ebp)
  800316:	ff 75 dc             	pushl  -0x24(%ebp)
  800319:	ff 75 d8             	pushl  -0x28(%ebp)
  80031c:	e8 df 1f 00 00       	call   802300 <__umoddi3>
  800321:	83 c4 14             	add    $0x14,%esp
  800324:	0f be 80 e7 24 80 00 	movsbl 0x8024e7(%eax),%eax
  80032b:	50                   	push   %eax
  80032c:	ff d7                	call   *%edi
}
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033c:	83 fa 01             	cmp    $0x1,%edx
  80033f:	7e 0e                	jle    80034f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800341:	8b 10                	mov    (%eax),%edx
  800343:	8d 4a 08             	lea    0x8(%edx),%ecx
  800346:	89 08                	mov    %ecx,(%eax)
  800348:	8b 02                	mov    (%edx),%eax
  80034a:	8b 52 04             	mov    0x4(%edx),%edx
  80034d:	eb 22                	jmp    800371 <getuint+0x38>
	else if (lflag)
  80034f:	85 d2                	test   %edx,%edx
  800351:	74 10                	je     800363 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800353:	8b 10                	mov    (%eax),%edx
  800355:	8d 4a 04             	lea    0x4(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	ba 00 00 00 00       	mov    $0x0,%edx
  800361:	eb 0e                	jmp    800371 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800363:	8b 10                	mov    (%eax),%edx
  800365:	8d 4a 04             	lea    0x4(%edx),%ecx
  800368:	89 08                	mov    %ecx,(%eax)
  80036a:	8b 02                	mov    (%edx),%eax
  80036c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800379:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	3b 50 04             	cmp    0x4(%eax),%edx
  800382:	73 0a                	jae    80038e <sprintputch+0x1b>
		*b->buf++ = ch;
  800384:	8d 4a 01             	lea    0x1(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	88 02                	mov    %al,(%edx)
}
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800396:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800399:	50                   	push   %eax
  80039a:	ff 75 10             	pushl  0x10(%ebp)
  80039d:	ff 75 0c             	pushl  0xc(%ebp)
  8003a0:	ff 75 08             	pushl  0x8(%ebp)
  8003a3:	e8 05 00 00 00       	call   8003ad <vprintfmt>
	va_end(ap);
}
  8003a8:	83 c4 10             	add    $0x10,%esp
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	57                   	push   %edi
  8003b1:	56                   	push   %esi
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 2c             	sub    $0x2c,%esp
  8003b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003bf:	eb 12                	jmp    8003d3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	0f 84 89 03 00 00    	je     800752 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	53                   	push   %ebx
  8003cd:	50                   	push   %eax
  8003ce:	ff d6                	call   *%esi
  8003d0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d3:	83 c7 01             	add    $0x1,%edi
  8003d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003da:	83 f8 25             	cmp    $0x25,%eax
  8003dd:	75 e2                	jne    8003c1 <vprintfmt+0x14>
  8003df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fd:	eb 07                	jmp    800406 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800402:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8d 47 01             	lea    0x1(%edi),%eax
  800409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040c:	0f b6 07             	movzbl (%edi),%eax
  80040f:	0f b6 c8             	movzbl %al,%ecx
  800412:	83 e8 23             	sub    $0x23,%eax
  800415:	3c 55                	cmp    $0x55,%al
  800417:	0f 87 1a 03 00 00    	ja     800737 <vprintfmt+0x38a>
  80041d:	0f b6 c0             	movzbl %al,%eax
  800420:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042e:	eb d6                	jmp    800406 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800442:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800445:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800448:	83 fa 09             	cmp    $0x9,%edx
  80044b:	77 39                	ja     800486 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800450:	eb e9                	jmp    80043b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 48 04             	lea    0x4(%eax),%ecx
  800458:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800463:	eb 27                	jmp    80048c <vprintfmt+0xdf>
  800465:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800468:	85 c0                	test   %eax,%eax
  80046a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046f:	0f 49 c8             	cmovns %eax,%ecx
  800472:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800478:	eb 8c                	jmp    800406 <vprintfmt+0x59>
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800484:	eb 80                	jmp    800406 <vprintfmt+0x59>
  800486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800489:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80048c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800490:	0f 89 70 ff ff ff    	jns    800406 <vprintfmt+0x59>
				width = precision, precision = -1;
  800496:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800499:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a3:	e9 5e ff ff ff       	jmp    800406 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ae:	e9 53 ff ff ff       	jmp    800406 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 50 04             	lea    0x4(%eax),%edx
  8004b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	ff 30                	pushl  (%eax)
  8004c2:	ff d6                	call   *%esi
			break;
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ca:	e9 04 ff ff ff       	jmp    8003d3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	99                   	cltd   
  8004db:	31 d0                	xor    %edx,%eax
  8004dd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004df:	83 f8 0f             	cmp    $0xf,%eax
  8004e2:	7f 0b                	jg     8004ef <vprintfmt+0x142>
  8004e4:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	75 18                	jne    800507 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ef:	50                   	push   %eax
  8004f0:	68 ff 24 80 00       	push   $0x8024ff
  8004f5:	53                   	push   %ebx
  8004f6:	56                   	push   %esi
  8004f7:	e8 94 fe ff ff       	call   800390 <printfmt>
  8004fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800502:	e9 cc fe ff ff       	jmp    8003d3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800507:	52                   	push   %edx
  800508:	68 b9 28 80 00       	push   $0x8028b9
  80050d:	53                   	push   %ebx
  80050e:	56                   	push   %esi
  80050f:	e8 7c fe ff ff       	call   800390 <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051a:	e9 b4 fe ff ff       	jmp    8003d3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052a:	85 ff                	test   %edi,%edi
  80052c:	b8 f8 24 80 00       	mov    $0x8024f8,%eax
  800531:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	0f 8e 94 00 00 00    	jle    8005d2 <vprintfmt+0x225>
  80053e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800542:	0f 84 98 00 00 00    	je     8005e0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	ff 75 d0             	pushl  -0x30(%ebp)
  80054e:	57                   	push   %edi
  80054f:	e8 86 02 00 00       	call   8007da <strnlen>
  800554:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800557:	29 c1                	sub    %eax,%ecx
  800559:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80055f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800563:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800566:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800569:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	eb 0f                	jmp    80057c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	ff 75 e0             	pushl  -0x20(%ebp)
  800574:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800576:	83 ef 01             	sub    $0x1,%edi
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	85 ff                	test   %edi,%edi
  80057e:	7f ed                	jg     80056d <vprintfmt+0x1c0>
  800580:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800583:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800586:	85 c9                	test   %ecx,%ecx
  800588:	b8 00 00 00 00       	mov    $0x0,%eax
  80058d:	0f 49 c1             	cmovns %ecx,%eax
  800590:	29 c1                	sub    %eax,%ecx
  800592:	89 75 08             	mov    %esi,0x8(%ebp)
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800598:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059b:	89 cb                	mov    %ecx,%ebx
  80059d:	eb 4d                	jmp    8005ec <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a3:	74 1b                	je     8005c0 <vprintfmt+0x213>
  8005a5:	0f be c0             	movsbl %al,%eax
  8005a8:	83 e8 20             	sub    $0x20,%eax
  8005ab:	83 f8 5e             	cmp    $0x5e,%eax
  8005ae:	76 10                	jbe    8005c0 <vprintfmt+0x213>
					putch('?', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	ff 75 0c             	pushl  0xc(%ebp)
  8005b6:	6a 3f                	push   $0x3f
  8005b8:	ff 55 08             	call   *0x8(%ebp)
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	eb 0d                	jmp    8005cd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	ff 75 0c             	pushl  0xc(%ebp)
  8005c6:	52                   	push   %edx
  8005c7:	ff 55 08             	call   *0x8(%ebp)
  8005ca:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cd:	83 eb 01             	sub    $0x1,%ebx
  8005d0:	eb 1a                	jmp    8005ec <vprintfmt+0x23f>
  8005d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005de:	eb 0c                	jmp    8005ec <vprintfmt+0x23f>
  8005e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ec:	83 c7 01             	add    $0x1,%edi
  8005ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f3:	0f be d0             	movsbl %al,%edx
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	74 23                	je     80061d <vprintfmt+0x270>
  8005fa:	85 f6                	test   %esi,%esi
  8005fc:	78 a1                	js     80059f <vprintfmt+0x1f2>
  8005fe:	83 ee 01             	sub    $0x1,%esi
  800601:	79 9c                	jns    80059f <vprintfmt+0x1f2>
  800603:	89 df                	mov    %ebx,%edi
  800605:	8b 75 08             	mov    0x8(%ebp),%esi
  800608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060b:	eb 18                	jmp    800625 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 20                	push   $0x20
  800613:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800615:	83 ef 01             	sub    $0x1,%edi
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	eb 08                	jmp    800625 <vprintfmt+0x278>
  80061d:	89 df                	mov    %ebx,%edi
  80061f:	8b 75 08             	mov    0x8(%ebp),%esi
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	85 ff                	test   %edi,%edi
  800627:	7f e4                	jg     80060d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062c:	e9 a2 fd ff ff       	jmp    8003d3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800631:	83 fa 01             	cmp    $0x1,%edx
  800634:	7e 16                	jle    80064c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 50 08             	lea    0x8(%eax),%edx
  80063c:	89 55 14             	mov    %edx,0x14(%ebp)
  80063f:	8b 50 04             	mov    0x4(%eax),%edx
  800642:	8b 00                	mov    (%eax),%eax
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064a:	eb 32                	jmp    80067e <vprintfmt+0x2d1>
	else if (lflag)
  80064c:	85 d2                	test   %edx,%edx
  80064e:	74 18                	je     800668 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	89 c1                	mov    %eax,%ecx
  800660:	c1 f9 1f             	sar    $0x1f,%ecx
  800663:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800666:	eb 16                	jmp    80067e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800676:	89 c1                	mov    %eax,%ecx
  800678:	c1 f9 1f             	sar    $0x1f,%ecx
  80067b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800681:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800684:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800689:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068d:	79 74                	jns    800703 <vprintfmt+0x356>
				putch('-', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 2d                	push   $0x2d
  800695:	ff d6                	call   *%esi
				num = -(long long) num;
  800697:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069d:	f7 d8                	neg    %eax
  80069f:	83 d2 00             	adc    $0x0,%edx
  8006a2:	f7 da                	neg    %edx
  8006a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ac:	eb 55                	jmp    800703 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 83 fc ff ff       	call   800339 <getuint>
			base = 10;
  8006b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006bb:	eb 46                	jmp    800703 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c0:	e8 74 fc ff ff       	call   800339 <getuint>
		        base = 8;
  8006c5:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006ca:	eb 37                	jmp    800703 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	6a 30                	push   $0x30
  8006d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d4:	83 c4 08             	add    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 78                	push   $0x78
  8006da:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ef:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f4:	eb 0d                	jmp    800703 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 3b fc ff ff       	call   800339 <getuint>
			base = 16;
  8006fe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800703:	83 ec 0c             	sub    $0xc,%esp
  800706:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80070a:	57                   	push   %edi
  80070b:	ff 75 e0             	pushl  -0x20(%ebp)
  80070e:	51                   	push   %ecx
  80070f:	52                   	push   %edx
  800710:	50                   	push   %eax
  800711:	89 da                	mov    %ebx,%edx
  800713:	89 f0                	mov    %esi,%eax
  800715:	e8 70 fb ff ff       	call   80028a <printnum>
			break;
  80071a:	83 c4 20             	add    $0x20,%esp
  80071d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800720:	e9 ae fc ff ff       	jmp    8003d3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	51                   	push   %ecx
  80072a:	ff d6                	call   *%esi
			break;
  80072c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800732:	e9 9c fc ff ff       	jmp    8003d3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 25                	push   $0x25
  80073d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	eb 03                	jmp    800747 <vprintfmt+0x39a>
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074b:	75 f7                	jne    800744 <vprintfmt+0x397>
  80074d:	e9 81 fc ff ff       	jmp    8003d3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 18             	sub    $0x18,%esp
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800769:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800777:	85 c0                	test   %eax,%eax
  800779:	74 26                	je     8007a1 <vsnprintf+0x47>
  80077b:	85 d2                	test   %edx,%edx
  80077d:	7e 22                	jle    8007a1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	ff 75 14             	pushl  0x14(%ebp)
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	50                   	push   %eax
  800789:	68 73 03 80 00       	push   $0x800373
  80078e:	e8 1a fc ff ff       	call   8003ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800793:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800796:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	ff 75 08             	pushl  0x8(%ebp)
  8007bb:	e8 9a ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	eb 03                	jmp    8007d2 <strlen+0x10>
		n++;
  8007cf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d6:	75 f7                	jne    8007cf <strlen+0xd>
		n++;
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e8:	eb 03                	jmp    8007ed <strnlen+0x13>
		n++;
  8007ea:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 08                	je     8007f9 <strnlen+0x1f>
  8007f1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f5:	75 f3                	jne    8007ea <strnlen+0x10>
  8007f7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	89 c2                	mov    %eax,%edx
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
  800814:	84 db                	test   %bl,%bl
  800816:	75 ef                	jne    800807 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	53                   	push   %ebx
  800823:	e8 9a ff ff ff       	call   8007c2 <strlen>
  800828:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	01 d8                	add    %ebx,%eax
  800830:	50                   	push   %eax
  800831:	e8 c5 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  800836:	89 d8                	mov    %ebx,%eax
  800838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	8b 75 08             	mov    0x8(%ebp),%esi
  800845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800848:	89 f3                	mov    %esi,%ebx
  80084a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	89 f2                	mov    %esi,%edx
  80084f:	eb 0f                	jmp    800860 <strncpy+0x23>
		*dst++ = *src;
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085a:	80 39 01             	cmpb   $0x1,(%ecx)
  80085d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	39 da                	cmp    %ebx,%edx
  800862:	75 ed                	jne    800851 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800864:	89 f0                	mov    %esi,%eax
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 75 08             	mov    0x8(%ebp),%esi
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800875:	8b 55 10             	mov    0x10(%ebp),%edx
  800878:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	74 21                	je     80089f <strlcpy+0x35>
  80087e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800882:	89 f2                	mov    %esi,%edx
  800884:	eb 09                	jmp    80088f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088f:	39 c2                	cmp    %eax,%edx
  800891:	74 09                	je     80089c <strlcpy+0x32>
  800893:	0f b6 19             	movzbl (%ecx),%ebx
  800896:	84 db                	test   %bl,%bl
  800898:	75 ec                	jne    800886 <strlcpy+0x1c>
  80089a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089f:	29 f0                	sub    %esi,%eax
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ae:	eb 06                	jmp    8008b6 <strcmp+0x11>
		p++, q++;
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b6:	0f b6 01             	movzbl (%ecx),%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 04                	je     8008c1 <strcmp+0x1c>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	74 ef                	je     8008b0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 c0             	movzbl %al,%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d5:	89 c3                	mov    %eax,%ebx
  8008d7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008da:	eb 06                	jmp    8008e2 <strncmp+0x17>
		n--, p++, q++;
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	74 15                	je     8008fb <strncmp+0x30>
  8008e6:	0f b6 08             	movzbl (%eax),%ecx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	74 04                	je     8008f1 <strncmp+0x26>
  8008ed:	3a 0a                	cmp    (%edx),%cl
  8008ef:	74 eb                	je     8008dc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f1:	0f b6 00             	movzbl (%eax),%eax
  8008f4:	0f b6 12             	movzbl (%edx),%edx
  8008f7:	29 d0                	sub    %edx,%eax
  8008f9:	eb 05                	jmp    800900 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090d:	eb 07                	jmp    800916 <strchr+0x13>
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	74 0f                	je     800922 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	0f b6 10             	movzbl (%eax),%edx
  800919:	84 d2                	test   %dl,%dl
  80091b:	75 f2                	jne    80090f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092e:	eb 03                	jmp    800933 <strfind+0xf>
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 04                	je     80093e <strfind+0x1a>
  80093a:	84 d2                	test   %dl,%dl
  80093c:	75 f2                	jne    800930 <strfind+0xc>
			break;
	return (char *) s;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 7d 08             	mov    0x8(%ebp),%edi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094c:	85 c9                	test   %ecx,%ecx
  80094e:	74 36                	je     800986 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800950:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800956:	75 28                	jne    800980 <memset+0x40>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 23                	jne    800980 <memset+0x40>
		c &= 0xFF;
  80095d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800974:	89 d8                	mov    %ebx,%eax
  800976:	09 d0                	or     %edx,%eax
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	fc                   	cld    
  80097c:	f3 ab                	rep stos %eax,%es:(%edi)
  80097e:	eb 06                	jmp    800986 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
  800983:	fc                   	cld    
  800984:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800986:	89 f8                	mov    %edi,%eax
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 75 0c             	mov    0xc(%ebp),%esi
  800998:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099b:	39 c6                	cmp    %eax,%esi
  80099d:	73 35                	jae    8009d4 <memmove+0x47>
  80099f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a2:	39 d0                	cmp    %edx,%eax
  8009a4:	73 2e                	jae    8009d4 <memmove+0x47>
		s += n;
		d += n;
  8009a6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 d6                	mov    %edx,%esi
  8009ab:	09 fe                	or     %edi,%esi
  8009ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b3:	75 13                	jne    8009c8 <memmove+0x3b>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0e                	jne    8009c8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ba:	83 ef 04             	sub    $0x4,%edi
  8009bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
  8009c3:	fd                   	std    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 09                	jmp    8009d1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	83 ef 01             	sub    $0x1,%edi
  8009cb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ce:	fd                   	std    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d1:	fc                   	cld    
  8009d2:	eb 1d                	jmp    8009f1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	09 c2                	or     %eax,%edx
  8009d8:	f6 c2 03             	test   $0x3,%dl
  8009db:	75 0f                	jne    8009ec <memmove+0x5f>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 0a                	jne    8009ec <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb 05                	jmp    8009f1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f8:	ff 75 10             	pushl  0x10(%ebp)
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	ff 75 08             	pushl  0x8(%ebp)
  800a01:	e8 87 ff ff ff       	call   80098d <memmove>
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 c6                	mov    %eax,%esi
  800a15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a18:	eb 1a                	jmp    800a34 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1a:	0f b6 08             	movzbl (%eax),%ecx
  800a1d:	0f b6 1a             	movzbl (%edx),%ebx
  800a20:	38 d9                	cmp    %bl,%cl
  800a22:	74 0a                	je     800a2e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a24:	0f b6 c1             	movzbl %cl,%eax
  800a27:	0f b6 db             	movzbl %bl,%ebx
  800a2a:	29 d8                	sub    %ebx,%eax
  800a2c:	eb 0f                	jmp    800a3d <memcmp+0x35>
		s1++, s2++;
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a34:	39 f0                	cmp    %esi,%eax
  800a36:	75 e2                	jne    800a1a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a48:	89 c1                	mov    %eax,%ecx
  800a4a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	eb 0a                	jmp    800a5d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a53:	0f b6 10             	movzbl (%eax),%edx
  800a56:	39 da                	cmp    %ebx,%edx
  800a58:	74 07                	je     800a61 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 c8                	cmp    %ecx,%eax
  800a5f:	72 f2                	jb     800a53 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a61:	5b                   	pop    %ebx
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a70:	eb 03                	jmp    800a75 <strtol+0x11>
		s++;
  800a72:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	0f b6 01             	movzbl (%ecx),%eax
  800a78:	3c 20                	cmp    $0x20,%al
  800a7a:	74 f6                	je     800a72 <strtol+0xe>
  800a7c:	3c 09                	cmp    $0x9,%al
  800a7e:	74 f2                	je     800a72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a80:	3c 2b                	cmp    $0x2b,%al
  800a82:	75 0a                	jne    800a8e <strtol+0x2a>
		s++;
  800a84:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8c:	eb 11                	jmp    800a9f <strtol+0x3b>
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a93:	3c 2d                	cmp    $0x2d,%al
  800a95:	75 08                	jne    800a9f <strtol+0x3b>
		s++, neg = 1;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa5:	75 15                	jne    800abc <strtol+0x58>
  800aa7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaa:	75 10                	jne    800abc <strtol+0x58>
  800aac:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab0:	75 7c                	jne    800b2e <strtol+0xca>
		s += 2, base = 16;
  800ab2:	83 c1 02             	add    $0x2,%ecx
  800ab5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aba:	eb 16                	jmp    800ad2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abc:	85 db                	test   %ebx,%ebx
  800abe:	75 12                	jne    800ad2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac8:	75 08                	jne    800ad2 <strtol+0x6e>
		s++, base = 8;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ada:	0f b6 11             	movzbl (%ecx),%edx
  800add:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 09             	cmp    $0x9,%bl
  800ae5:	77 08                	ja     800aef <strtol+0x8b>
			dig = *s - '0';
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 30             	sub    $0x30,%edx
  800aed:	eb 22                	jmp    800b11 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aef:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 08                	ja     800b01 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 57             	sub    $0x57,%edx
  800aff:	eb 10                	jmp    800b11 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 16                	ja     800b21 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b14:	7d 0b                	jge    800b21 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1f:	eb b9                	jmp    800ada <strtol+0x76>

	if (endptr)
  800b21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b25:	74 0d                	je     800b34 <strtol+0xd0>
		*endptr = (char *) s;
  800b27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2a:	89 0e                	mov    %ecx,(%esi)
  800b2c:	eb 06                	jmp    800b34 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	74 98                	je     800aca <strtol+0x66>
  800b32:	eb 9e                	jmp    800ad2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b34:	89 c2                	mov    %eax,%edx
  800b36:	f7 da                	neg    %edx
  800b38:	85 ff                	test   %edi,%edi
  800b3a:	0f 45 c2             	cmovne %edx,%eax
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	89 c6                	mov    %eax,%esi
  800b59:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b70:	89 d1                	mov    %edx,%ecx
  800b72:	89 d3                	mov    %edx,%ebx
  800b74:	89 d7                	mov    %edx,%edi
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	89 cb                	mov    %ecx,%ebx
  800b97:	89 cf                	mov    %ecx,%edi
  800b99:	89 ce                	mov    %ecx,%esi
  800b9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 03                	push   $0x3
  800ba7:	68 df 27 80 00       	push   $0x8027df
  800bac:	6a 23                	push   $0x23
  800bae:	68 fc 27 80 00       	push   $0x8027fc
  800bb3:	e8 e5 f5 ff ff       	call   80019d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd0:	89 d1                	mov    %edx,%ecx
  800bd2:	89 d3                	mov    %edx,%ebx
  800bd4:	89 d7                	mov    %edx,%edi
  800bd6:	89 d6                	mov    %edx,%esi
  800bd8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_yield>:

void
sys_yield(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bef:	89 d1                	mov    %edx,%ecx
  800bf1:	89 d3                	mov    %edx,%ebx
  800bf3:	89 d7                	mov    %edx,%edi
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	be 00 00 00 00       	mov    $0x0,%esi
  800c0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1a:	89 f7                	mov    %esi,%edi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 04                	push   $0x4
  800c28:	68 df 27 80 00       	push   $0x8027df
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 fc 27 80 00       	push   $0x8027fc
  800c34:	e8 64 f5 ff ff       	call   80019d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 05                	push   $0x5
  800c6a:	68 df 27 80 00       	push   $0x8027df
  800c6f:	6a 23                	push   $0x23
  800c71:	68 fc 27 80 00       	push   $0x8027fc
  800c76:	e8 22 f5 ff ff       	call   80019d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 06 00 00 00       	mov    $0x6,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 06                	push   $0x6
  800cac:	68 df 27 80 00       	push   $0x8027df
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 fc 27 80 00       	push   $0x8027fc
  800cb8:	e8 e0 f4 ff ff       	call   80019d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 08                	push   $0x8
  800cee:	68 df 27 80 00       	push   $0x8027df
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 fc 27 80 00       	push   $0x8027fc
  800cfa:	e8 9e f4 ff ff       	call   80019d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 09                	push   $0x9
  800d30:	68 df 27 80 00       	push   $0x8027df
  800d35:	6a 23                	push   $0x23
  800d37:	68 fc 27 80 00       	push   $0x8027fc
  800d3c:	e8 5c f4 ff ff       	call   80019d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 df                	mov    %ebx,%edi
  800d64:	89 de                	mov    %ebx,%esi
  800d66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 17                	jle    800d83 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	50                   	push   %eax
  800d70:	6a 0a                	push   $0xa
  800d72:	68 df 27 80 00       	push   $0x8027df
  800d77:	6a 23                	push   $0x23
  800d79:	68 fc 27 80 00       	push   $0x8027fc
  800d7e:	e8 1a f4 ff ff       	call   80019d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	be 00 00 00 00       	mov    $0x0,%esi
  800d96:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 cb                	mov    %ecx,%ebx
  800dc6:	89 cf                	mov    %ecx,%edi
  800dc8:	89 ce                	mov    %ecx,%esi
  800dca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7e 17                	jle    800de7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	50                   	push   %eax
  800dd4:	6a 0d                	push   $0xd
  800dd6:	68 df 27 80 00       	push   $0x8027df
  800ddb:	6a 23                	push   $0x23
  800ddd:	68 fc 27 80 00       	push   $0x8027fc
  800de2:	e8 b6 f3 ff ff       	call   80019d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dff:	89 d1                	mov    %edx,%ecx
  800e01:	89 d3                	mov    %edx,%ebx
  800e03:	89 d7                	mov    %edx,%edi
  800e05:	89 d6                	mov    %edx,%esi
  800e07:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e19:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	89 df                	mov    %ebx,%edi
  800e26:	89 de                	mov    %ebx,%esi
  800e28:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	c1 ea 16             	shr    $0x16,%edx
  800e66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 11                	je     800e83 <fd_alloc+0x2d>
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	c1 ea 0c             	shr    $0xc,%edx
  800e77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7e:	f6 c2 01             	test   $0x1,%dl
  800e81:	75 09                	jne    800e8c <fd_alloc+0x36>
			*fd_store = fd;
  800e83:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8a:	eb 17                	jmp    800ea3 <fd_alloc+0x4d>
  800e8c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e91:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e96:	75 c9                	jne    800e61 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e98:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eab:	83 f8 1f             	cmp    $0x1f,%eax
  800eae:	77 36                	ja     800ee6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb0:	c1 e0 0c             	shl    $0xc,%eax
  800eb3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 ea 16             	shr    $0x16,%edx
  800ebd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec4:	f6 c2 01             	test   $0x1,%dl
  800ec7:	74 24                	je     800eed <fd_lookup+0x48>
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 0c             	shr    $0xc,%edx
  800ece:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	74 1a                	je     800ef4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edd:	89 02                	mov    %eax,(%edx)
	return 0;
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	eb 13                	jmp    800ef9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eeb:	eb 0c                	jmp    800ef9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef2:	eb 05                	jmp    800ef9 <fd_lookup+0x54>
  800ef4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f04:	ba 8c 28 80 00       	mov    $0x80288c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f09:	eb 13                	jmp    800f1e <dev_lookup+0x23>
  800f0b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0e:	39 08                	cmp    %ecx,(%eax)
  800f10:	75 0c                	jne    800f1e <dev_lookup+0x23>
			*dev = devtab[i];
  800f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	eb 2e                	jmp    800f4c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1e:	8b 02                	mov    (%edx),%eax
  800f20:	85 c0                	test   %eax,%eax
  800f22:	75 e7                	jne    800f0b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f24:	a1 20 60 80 00       	mov    0x806020,%eax
  800f29:	8b 40 48             	mov    0x48(%eax),%eax
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	51                   	push   %ecx
  800f30:	50                   	push   %eax
  800f31:	68 0c 28 80 00       	push   $0x80280c
  800f36:	e8 3b f3 ff ff       	call   800276 <cprintf>
	*dev = 0;
  800f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 10             	sub    $0x10,%esp
  800f56:	8b 75 08             	mov    0x8(%ebp),%esi
  800f59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	50                   	push   %eax
  800f6a:	e8 36 ff ff ff       	call   800ea5 <fd_lookup>
  800f6f:	83 c4 08             	add    $0x8,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 05                	js     800f7b <fd_close+0x2d>
	    || fd != fd2)
  800f76:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f79:	74 0c                	je     800f87 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7b:	84 db                	test   %bl,%bl
  800f7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f82:	0f 44 c2             	cmove  %edx,%eax
  800f85:	eb 41                	jmp    800fc8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8d:	50                   	push   %eax
  800f8e:	ff 36                	pushl  (%esi)
  800f90:	e8 66 ff ff ff       	call   800efb <dev_lookup>
  800f95:	89 c3                	mov    %eax,%ebx
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 1a                	js     800fb8 <fd_close+0x6a>
		if (dev->dev_close)
  800f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	74 0b                	je     800fb8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	56                   	push   %esi
  800fb1:	ff d0                	call   *%eax
  800fb3:	89 c3                	mov    %eax,%ebx
  800fb5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	56                   	push   %esi
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 c0 fc ff ff       	call   800c83 <sys_page_unmap>
	return r;
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	89 d8                	mov    %ebx,%eax
}
  800fc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	ff 75 08             	pushl  0x8(%ebp)
  800fdc:	e8 c4 fe ff ff       	call   800ea5 <fd_lookup>
  800fe1:	83 c4 08             	add    $0x8,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 10                	js     800ff8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	6a 01                	push   $0x1
  800fed:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff0:	e8 59 ff ff ff       	call   800f4e <fd_close>
  800ff5:	83 c4 10             	add    $0x10,%esp
}
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <close_all>:

void
close_all(void)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	53                   	push   %ebx
  80100a:	e8 c0 ff ff ff       	call   800fcf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100f:	83 c3 01             	add    $0x1,%ebx
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	83 fb 20             	cmp    $0x20,%ebx
  801018:	75 ec                	jne    801006 <close_all+0xc>
		close(i);
}
  80101a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 2c             	sub    $0x2c,%esp
  801028:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102e:	50                   	push   %eax
  80102f:	ff 75 08             	pushl  0x8(%ebp)
  801032:	e8 6e fe ff ff       	call   800ea5 <fd_lookup>
  801037:	83 c4 08             	add    $0x8,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	0f 88 c1 00 00 00    	js     801103 <dup+0xe4>
		return r;
	close(newfdnum);
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	56                   	push   %esi
  801046:	e8 84 ff ff ff       	call   800fcf <close>

	newfd = INDEX2FD(newfdnum);
  80104b:	89 f3                	mov    %esi,%ebx
  80104d:	c1 e3 0c             	shl    $0xc,%ebx
  801050:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801056:	83 c4 04             	add    $0x4,%esp
  801059:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105c:	e8 de fd ff ff       	call   800e3f <fd2data>
  801061:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801063:	89 1c 24             	mov    %ebx,(%esp)
  801066:	e8 d4 fd ff ff       	call   800e3f <fd2data>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801071:	89 f8                	mov    %edi,%eax
  801073:	c1 e8 16             	shr    $0x16,%eax
  801076:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107d:	a8 01                	test   $0x1,%al
  80107f:	74 37                	je     8010b8 <dup+0x99>
  801081:	89 f8                	mov    %edi,%eax
  801083:	c1 e8 0c             	shr    $0xc,%eax
  801086:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108d:	f6 c2 01             	test   $0x1,%dl
  801090:	74 26                	je     8010b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801092:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a1:	50                   	push   %eax
  8010a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a5:	6a 00                	push   $0x0
  8010a7:	57                   	push   %edi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 92 fb ff ff       	call   800c41 <sys_page_map>
  8010af:	89 c7                	mov    %eax,%edi
  8010b1:	83 c4 20             	add    $0x20,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 2e                	js     8010e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	c1 e8 0c             	shr    $0xc,%eax
  8010c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cf:	50                   	push   %eax
  8010d0:	53                   	push   %ebx
  8010d1:	6a 00                	push   $0x0
  8010d3:	52                   	push   %edx
  8010d4:	6a 00                	push   $0x0
  8010d6:	e8 66 fb ff ff       	call   800c41 <sys_page_map>
  8010db:	89 c7                	mov    %eax,%edi
  8010dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e2:	85 ff                	test   %edi,%edi
  8010e4:	79 1d                	jns    801103 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 92 fb ff ff       	call   800c83 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f1:	83 c4 08             	add    $0x8,%esp
  8010f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 85 fb ff ff       	call   800c83 <sys_page_unmap>
	return r;
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	89 f8                	mov    %edi,%eax
}
  801103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	53                   	push   %ebx
  80110f:	83 ec 14             	sub    $0x14,%esp
  801112:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801115:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	53                   	push   %ebx
  80111a:	e8 86 fd ff ff       	call   800ea5 <fd_lookup>
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	89 c2                	mov    %eax,%edx
  801124:	85 c0                	test   %eax,%eax
  801126:	78 6d                	js     801195 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801132:	ff 30                	pushl  (%eax)
  801134:	e8 c2 fd ff ff       	call   800efb <dev_lookup>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 4c                	js     80118c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801140:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801143:	8b 42 08             	mov    0x8(%edx),%eax
  801146:	83 e0 03             	and    $0x3,%eax
  801149:	83 f8 01             	cmp    $0x1,%eax
  80114c:	75 21                	jne    80116f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114e:	a1 20 60 80 00       	mov    0x806020,%eax
  801153:	8b 40 48             	mov    0x48(%eax),%eax
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	53                   	push   %ebx
  80115a:	50                   	push   %eax
  80115b:	68 50 28 80 00       	push   $0x802850
  801160:	e8 11 f1 ff ff       	call   800276 <cprintf>
		return -E_INVAL;
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116d:	eb 26                	jmp    801195 <read+0x8a>
	}
	if (!dev->dev_read)
  80116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801172:	8b 40 08             	mov    0x8(%eax),%eax
  801175:	85 c0                	test   %eax,%eax
  801177:	74 17                	je     801190 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	ff 75 10             	pushl  0x10(%ebp)
  80117f:	ff 75 0c             	pushl  0xc(%ebp)
  801182:	52                   	push   %edx
  801183:	ff d0                	call   *%eax
  801185:	89 c2                	mov    %eax,%edx
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	eb 09                	jmp    801195 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	eb 05                	jmp    801195 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801190:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801195:	89 d0                	mov    %edx,%eax
  801197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119a:	c9                   	leave  
  80119b:	c3                   	ret    

0080119c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b0:	eb 21                	jmp    8011d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	89 f0                	mov    %esi,%eax
  8011b7:	29 d8                	sub    %ebx,%eax
  8011b9:	50                   	push   %eax
  8011ba:	89 d8                	mov    %ebx,%eax
  8011bc:	03 45 0c             	add    0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	57                   	push   %edi
  8011c1:	e8 45 ff ff ff       	call   80110b <read>
		if (m < 0)
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 10                	js     8011dd <readn+0x41>
			return m;
		if (m == 0)
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	74 0a                	je     8011db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d1:	01 c3                	add    %eax,%ebx
  8011d3:	39 f3                	cmp    %esi,%ebx
  8011d5:	72 db                	jb     8011b2 <readn+0x16>
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	eb 02                	jmp    8011dd <readn+0x41>
  8011db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 14             	sub    $0x14,%esp
  8011ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	53                   	push   %ebx
  8011f4:	e8 ac fc ff ff       	call   800ea5 <fd_lookup>
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 68                	js     80126a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120c:	ff 30                	pushl  (%eax)
  80120e:	e8 e8 fc ff ff       	call   800efb <dev_lookup>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 47                	js     801261 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801221:	75 21                	jne    801244 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801223:	a1 20 60 80 00       	mov    0x806020,%eax
  801228:	8b 40 48             	mov    0x48(%eax),%eax
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	53                   	push   %ebx
  80122f:	50                   	push   %eax
  801230:	68 6c 28 80 00       	push   $0x80286c
  801235:	e8 3c f0 ff ff       	call   800276 <cprintf>
		return -E_INVAL;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801242:	eb 26                	jmp    80126a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801244:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801247:	8b 52 0c             	mov    0xc(%edx),%edx
  80124a:	85 d2                	test   %edx,%edx
  80124c:	74 17                	je     801265 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124e:	83 ec 04             	sub    $0x4,%esp
  801251:	ff 75 10             	pushl  0x10(%ebp)
  801254:	ff 75 0c             	pushl  0xc(%ebp)
  801257:	50                   	push   %eax
  801258:	ff d2                	call   *%edx
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	eb 09                	jmp    80126a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	89 c2                	mov    %eax,%edx
  801263:	eb 05                	jmp    80126a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801265:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126a:	89 d0                	mov    %edx,%eax
  80126c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <seek>:

int
seek(int fdnum, off_t offset)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801277:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 22 fc ff ff       	call   800ea5 <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 0e                	js     801298 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801290:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	53                   	push   %ebx
  80129e:	83 ec 14             	sub    $0x14,%esp
  8012a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	53                   	push   %ebx
  8012a9:	e8 f7 fb ff ff       	call   800ea5 <fd_lookup>
  8012ae:	83 c4 08             	add    $0x8,%esp
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 65                	js     80131c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	ff 30                	pushl  (%eax)
  8012c3:	e8 33 fc ff ff       	call   800efb <dev_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 44                	js     801313 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d6:	75 21                	jne    8012f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d8:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012dd:	8b 40 48             	mov    0x48(%eax),%eax
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	50                   	push   %eax
  8012e5:	68 2c 28 80 00       	push   $0x80282c
  8012ea:	e8 87 ef ff ff       	call   800276 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f7:	eb 23                	jmp    80131c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fc:	8b 52 18             	mov    0x18(%edx),%edx
  8012ff:	85 d2                	test   %edx,%edx
  801301:	74 14                	je     801317 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 0c             	pushl  0xc(%ebp)
  801309:	50                   	push   %eax
  80130a:	ff d2                	call   *%edx
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	eb 09                	jmp    80131c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801313:	89 c2                	mov    %eax,%edx
  801315:	eb 05                	jmp    80131c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801317:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	53                   	push   %ebx
  801327:	83 ec 14             	sub    $0x14,%esp
  80132a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 75 08             	pushl  0x8(%ebp)
  801334:	e8 6c fb ff ff       	call   800ea5 <fd_lookup>
  801339:	83 c4 08             	add    $0x8,%esp
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 58                	js     80139a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	ff 30                	pushl  (%eax)
  80134e:	e8 a8 fb ff ff       	call   800efb <dev_lookup>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 37                	js     801391 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801361:	74 32                	je     801395 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801363:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801366:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136d:	00 00 00 
	stat->st_isdir = 0;
  801370:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801377:	00 00 00 
	stat->st_dev = dev;
  80137a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	53                   	push   %ebx
  801384:	ff 75 f0             	pushl  -0x10(%ebp)
  801387:	ff 50 14             	call   *0x14(%eax)
  80138a:	89 c2                	mov    %eax,%edx
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	eb 09                	jmp    80139a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801391:	89 c2                	mov    %eax,%edx
  801393:	eb 05                	jmp    80139a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801395:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139a:	89 d0                	mov    %edx,%eax
  80139c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	6a 00                	push   $0x0
  8013ab:	ff 75 08             	pushl  0x8(%ebp)
  8013ae:	e8 e7 01 00 00       	call   80159a <open>
  8013b3:	89 c3                	mov    %eax,%ebx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 1b                	js     8013d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	ff 75 0c             	pushl  0xc(%ebp)
  8013c2:	50                   	push   %eax
  8013c3:	e8 5b ff ff ff       	call   801323 <fstat>
  8013c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ca:	89 1c 24             	mov    %ebx,(%esp)
  8013cd:	e8 fd fb ff ff       	call   800fcf <close>
	return r;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 f0                	mov    %esi,%eax
}
  8013d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	89 c6                	mov    %eax,%esi
  8013e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ee:	75 12                	jne    801402 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	6a 01                	push   $0x1
  8013f5:	e8 5b 0d 00 00       	call   802155 <ipc_find_env>
  8013fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801402:	6a 07                	push   $0x7
  801404:	68 00 70 80 00       	push   $0x807000
  801409:	56                   	push   %esi
  80140a:	ff 35 00 40 80 00    	pushl  0x804000
  801410:	e8 ec 0c 00 00       	call   802101 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801415:	83 c4 0c             	add    $0xc,%esp
  801418:	6a 00                	push   $0x0
  80141a:	53                   	push   %ebx
  80141b:	6a 00                	push   $0x0
  80141d:	e8 72 0c 00 00       	call   802094 <ipc_recv>
}
  801422:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801425:	5b                   	pop    %ebx
  801426:	5e                   	pop    %esi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    

00801429 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80143a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 02 00 00 00       	mov    $0x2,%eax
  80144c:	e8 8d ff ff ff       	call   8013de <fsipc>
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 06 00 00 00       	mov    $0x6,%eax
  80146e:	e8 6b ff ff ff       	call   8013de <fsipc>
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	53                   	push   %ebx
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 40 0c             	mov    0xc(%eax),%eax
  801485:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	b8 05 00 00 00       	mov    $0x5,%eax
  801494:	e8 45 ff ff ff       	call   8013de <fsipc>
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 2c                	js     8014c9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	68 00 70 80 00       	push   $0x807000
  8014a5:	53                   	push   %ebx
  8014a6:	e8 50 f3 ff ff       	call   8007fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ab:	a1 80 70 80 00       	mov    0x807080,%eax
  8014b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b6:	a1 84 70 80 00       	mov    0x807084,%eax
  8014bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8014d8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014dd:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014e2:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e5:	53                   	push   %ebx
  8014e6:	ff 75 0c             	pushl  0xc(%ebp)
  8014e9:	68 08 70 80 00       	push   $0x807008
  8014ee:	e8 9a f4 ff ff       	call   80098d <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f9:	a3 00 70 80 00       	mov    %eax,0x807000
 	fsipcbuf.write.req_n = n;
  8014fe:	89 1d 04 70 80 00    	mov    %ebx,0x807004

 	return fsipc(FSREQ_WRITE, NULL);
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 04 00 00 00       	mov    $0x4,%eax
  80150e:	e8 cb fe ff ff       	call   8013de <fsipc>
	//panic("devfile_write not implemented");
}
  801513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	8b 40 0c             	mov    0xc(%eax),%eax
  801526:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80152b:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 03 00 00 00       	mov    $0x3,%eax
  80153b:	e8 9e fe ff ff       	call   8013de <fsipc>
  801540:	89 c3                	mov    %eax,%ebx
  801542:	85 c0                	test   %eax,%eax
  801544:	78 4b                	js     801591 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801546:	39 c6                	cmp    %eax,%esi
  801548:	73 16                	jae    801560 <devfile_read+0x48>
  80154a:	68 a0 28 80 00       	push   $0x8028a0
  80154f:	68 a7 28 80 00       	push   $0x8028a7
  801554:	6a 7c                	push   $0x7c
  801556:	68 bc 28 80 00       	push   $0x8028bc
  80155b:	e8 3d ec ff ff       	call   80019d <_panic>
	assert(r <= PGSIZE);
  801560:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801565:	7e 16                	jle    80157d <devfile_read+0x65>
  801567:	68 c7 28 80 00       	push   $0x8028c7
  80156c:	68 a7 28 80 00       	push   $0x8028a7
  801571:	6a 7d                	push   $0x7d
  801573:	68 bc 28 80 00       	push   $0x8028bc
  801578:	e8 20 ec ff ff       	call   80019d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	50                   	push   %eax
  801581:	68 00 70 80 00       	push   $0x807000
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	e8 ff f3 ff ff       	call   80098d <memmove>
	return r;
  80158e:	83 c4 10             	add    $0x10,%esp
}
  801591:	89 d8                	mov    %ebx,%eax
  801593:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 20             	sub    $0x20,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a4:	53                   	push   %ebx
  8015a5:	e8 18 f2 ff ff       	call   8007c2 <strlen>
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b2:	7f 67                	jg     80161b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	e8 96 f8 ff ff       	call   800e56 <fd_alloc>
  8015c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 57                	js     801620 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	68 00 70 80 00       	push   $0x807000
  8015d2:	e8 24 f2 ff ff       	call   8007fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015da:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e7:	e8 f2 fd ff ff       	call   8013de <fsipc>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	79 14                	jns    801609 <open+0x6f>
		fd_close(fd, 0);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	6a 00                	push   $0x0
  8015fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fd:	e8 4c f9 ff ff       	call   800f4e <fd_close>
		return r;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	89 da                	mov    %ebx,%edx
  801607:	eb 17                	jmp    801620 <open+0x86>
	}

	return fd2num(fd);
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	ff 75 f4             	pushl  -0xc(%ebp)
  80160f:	e8 1b f8 ff ff       	call   800e2f <fd2num>
  801614:	89 c2                	mov    %eax,%edx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb 05                	jmp    801620 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80161b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801620:	89 d0                	mov    %edx,%eax
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 08 00 00 00       	mov    $0x8,%eax
  801637:	e8 a2 fd ff ff       	call   8013de <fsipc>
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80163e:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801642:	7e 37                	jle    80167b <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	53                   	push   %ebx
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80164d:	ff 70 04             	pushl  0x4(%eax)
  801650:	8d 40 10             	lea    0x10(%eax),%eax
  801653:	50                   	push   %eax
  801654:	ff 33                	pushl  (%ebx)
  801656:	e8 8a fb ff ff       	call   8011e5 <write>
		if (result > 0)
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	7e 03                	jle    801665 <writebuf+0x27>
			b->result += result;
  801662:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801665:	3b 43 04             	cmp    0x4(%ebx),%eax
  801668:	74 0d                	je     801677 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80166a:	85 c0                	test   %eax,%eax
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
  801671:	0f 4f c2             	cmovg  %edx,%eax
  801674:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	f3 c3                	repz ret 

0080167d <putch>:

static void
putch(int ch, void *thunk)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	53                   	push   %ebx
  801681:	83 ec 04             	sub    $0x4,%esp
  801684:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801687:	8b 53 04             	mov    0x4(%ebx),%edx
  80168a:	8d 42 01             	lea    0x1(%edx),%eax
  80168d:	89 43 04             	mov    %eax,0x4(%ebx)
  801690:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801693:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801697:	3d 00 01 00 00       	cmp    $0x100,%eax
  80169c:	75 0e                	jne    8016ac <putch+0x2f>
		writebuf(b);
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	e8 99 ff ff ff       	call   80163e <writebuf>
		b->idx = 0;
  8016a5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016ac:	83 c4 04             	add    $0x4,%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016c4:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016cb:	00 00 00 
	b.result = 0;
  8016ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016d5:	00 00 00 
	b.error = 1;
  8016d8:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016df:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016e2:	ff 75 10             	pushl  0x10(%ebp)
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	68 7d 16 80 00       	push   $0x80167d
  8016f4:	e8 b4 ec ff ff       	call   8003ad <vprintfmt>
	if (b.idx > 0)
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801703:	7e 0b                	jle    801710 <vfprintf+0x5e>
		writebuf(&b);
  801705:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80170b:	e8 2e ff ff ff       	call   80163e <writebuf>

	return (b.result ? b.result : b.error);
  801710:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801716:	85 c0                	test   %eax,%eax
  801718:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801727:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80172a:	50                   	push   %eax
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	ff 75 08             	pushl  0x8(%ebp)
  801731:	e8 7c ff ff ff       	call   8016b2 <vfprintf>
	va_end(ap);

	return cnt;
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <printf>:

int
printf(const char *fmt, ...)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80173e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801741:	50                   	push   %eax
  801742:	ff 75 08             	pushl  0x8(%ebp)
  801745:	6a 01                	push   $0x1
  801747:	e8 66 ff ff ff       	call   8016b2 <vfprintf>
	va_end(ap);

	return cnt;
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801754:	68 d3 28 80 00       	push   $0x8028d3
  801759:	ff 75 0c             	pushl  0xc(%ebp)
  80175c:	e8 9a f0 ff ff       	call   8007fb <strcpy>
	return 0;
}
  801761:	b8 00 00 00 00       	mov    $0x0,%eax
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	53                   	push   %ebx
  80176c:	83 ec 10             	sub    $0x10,%esp
  80176f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801772:	53                   	push   %ebx
  801773:	e8 16 0a 00 00       	call   80218e <pageref>
  801778:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801780:	83 f8 01             	cmp    $0x1,%eax
  801783:	75 10                	jne    801795 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801785:	83 ec 0c             	sub    $0xc,%esp
  801788:	ff 73 0c             	pushl  0xc(%ebx)
  80178b:	e8 c0 02 00 00       	call   801a50 <nsipc_close>
  801790:	89 c2                	mov    %eax,%edx
  801792:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801795:	89 d0                	mov    %edx,%eax
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017a2:	6a 00                	push   $0x0
  8017a4:	ff 75 10             	pushl  0x10(%ebp)
  8017a7:	ff 75 0c             	pushl  0xc(%ebp)
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	ff 70 0c             	pushl  0xc(%eax)
  8017b0:	e8 78 03 00 00       	call   801b2d <nsipc_send>
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8017bd:	6a 00                	push   $0x0
  8017bf:	ff 75 10             	pushl  0x10(%ebp)
  8017c2:	ff 75 0c             	pushl  0xc(%ebp)
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	ff 70 0c             	pushl  0xc(%eax)
  8017cb:	e8 f1 02 00 00       	call   801ac1 <nsipc_recv>
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017d8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017db:	52                   	push   %edx
  8017dc:	50                   	push   %eax
  8017dd:	e8 c3 f6 ff ff       	call   800ea5 <fd_lookup>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 17                	js     801800 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8017e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ec:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8017f2:	39 08                	cmp    %ecx,(%eax)
  8017f4:	75 05                	jne    8017fb <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	eb 05                	jmp    801800 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8017fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	83 ec 1c             	sub    $0x1c,%esp
  80180a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80180c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180f:	50                   	push   %eax
  801810:	e8 41 f6 ff ff       	call   800e56 <fd_alloc>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 1b                	js     801839 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80181e:	83 ec 04             	sub    $0x4,%esp
  801821:	68 07 04 00 00       	push   $0x407
  801826:	ff 75 f4             	pushl  -0xc(%ebp)
  801829:	6a 00                	push   $0x0
  80182b:	e8 ce f3 ff ff       	call   800bfe <sys_page_alloc>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	79 10                	jns    801849 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	56                   	push   %esi
  80183d:	e8 0e 02 00 00       	call   801a50 <nsipc_close>
		return r;
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	89 d8                	mov    %ebx,%eax
  801847:	eb 24                	jmp    80186d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801849:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80184f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801852:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80185e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801861:	83 ec 0c             	sub    $0xc,%esp
  801864:	50                   	push   %eax
  801865:	e8 c5 f5 ff ff       	call   800e2f <fd2num>
  80186a:	83 c4 10             	add    $0x10,%esp
}
  80186d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    

00801874 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	e8 50 ff ff ff       	call   8017d2 <fd2sockid>
		return r;
  801882:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801884:	85 c0                	test   %eax,%eax
  801886:	78 1f                	js     8018a7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	ff 75 10             	pushl  0x10(%ebp)
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	50                   	push   %eax
  801892:	e8 12 01 00 00       	call   8019a9 <nsipc_accept>
  801897:	83 c4 10             	add    $0x10,%esp
		return r;
  80189a:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 07                	js     8018a7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8018a0:	e8 5d ff ff ff       	call   801802 <alloc_sockfd>
  8018a5:	89 c1                	mov    %eax,%ecx
}
  8018a7:	89 c8                	mov    %ecx,%eax
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	e8 19 ff ff ff       	call   8017d2 <fd2sockid>
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 12                	js     8018cf <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8018bd:	83 ec 04             	sub    $0x4,%esp
  8018c0:	ff 75 10             	pushl  0x10(%ebp)
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	50                   	push   %eax
  8018c7:	e8 2d 01 00 00       	call   8019f9 <nsipc_bind>
  8018cc:	83 c4 10             	add    $0x10,%esp
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <shutdown>:

int
shutdown(int s, int how)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	e8 f3 fe ff ff       	call   8017d2 <fd2sockid>
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 0f                	js     8018f2 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	50                   	push   %eax
  8018ea:	e8 3f 01 00 00       	call   801a2e <nsipc_shutdown>
  8018ef:	83 c4 10             	add    $0x10,%esp
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	e8 d0 fe ff ff       	call   8017d2 <fd2sockid>
  801902:	85 c0                	test   %eax,%eax
  801904:	78 12                	js     801918 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801906:	83 ec 04             	sub    $0x4,%esp
  801909:	ff 75 10             	pushl  0x10(%ebp)
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	50                   	push   %eax
  801910:	e8 55 01 00 00       	call   801a6a <nsipc_connect>
  801915:	83 c4 10             	add    $0x10,%esp
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <listen>:

int
listen(int s, int backlog)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	e8 aa fe ff ff       	call   8017d2 <fd2sockid>
  801928:	85 c0                	test   %eax,%eax
  80192a:	78 0f                	js     80193b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	ff 75 0c             	pushl  0xc(%ebp)
  801932:	50                   	push   %eax
  801933:	e8 67 01 00 00       	call   801a9f <nsipc_listen>
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801943:	ff 75 10             	pushl  0x10(%ebp)
  801946:	ff 75 0c             	pushl  0xc(%ebp)
  801949:	ff 75 08             	pushl  0x8(%ebp)
  80194c:	e8 3a 02 00 00       	call   801b8b <nsipc_socket>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	85 c0                	test   %eax,%eax
  801956:	78 05                	js     80195d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801958:	e8 a5 fe ff ff       	call   801802 <alloc_sockfd>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	53                   	push   %ebx
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801968:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80196f:	75 12                	jne    801983 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	6a 02                	push   $0x2
  801976:	e8 da 07 00 00       	call   802155 <ipc_find_env>
  80197b:	a3 04 40 80 00       	mov    %eax,0x804004
  801980:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801983:	6a 07                	push   $0x7
  801985:	68 00 80 80 00       	push   $0x808000
  80198a:	53                   	push   %ebx
  80198b:	ff 35 04 40 80 00    	pushl  0x804004
  801991:	e8 6b 07 00 00       	call   802101 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801996:	83 c4 0c             	add    $0xc,%esp
  801999:	6a 00                	push   $0x0
  80199b:	6a 00                	push   $0x0
  80199d:	6a 00                	push   $0x0
  80199f:	e8 f0 06 00 00       	call   802094 <ipc_recv>
}
  8019a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019b9:	8b 06                	mov    (%esi),%eax
  8019bb:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c5:	e8 95 ff ff ff       	call   80195f <nsipc>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 20                	js     8019f0 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	ff 35 10 80 80 00    	pushl  0x808010
  8019d9:	68 00 80 80 00       	push   $0x808000
  8019de:	ff 75 0c             	pushl  0xc(%ebp)
  8019e1:	e8 a7 ef ff ff       	call   80098d <memmove>
		*addrlen = ret->ret_addrlen;
  8019e6:	a1 10 80 80 00       	mov    0x808010,%eax
  8019eb:	89 06                	mov    %eax,(%esi)
  8019ed:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a0b:	53                   	push   %ebx
  801a0c:	ff 75 0c             	pushl  0xc(%ebp)
  801a0f:	68 04 80 80 00       	push   $0x808004
  801a14:	e8 74 ef ff ff       	call   80098d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a19:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801a1f:	b8 02 00 00 00       	mov    $0x2,%eax
  801a24:	e8 36 ff ff ff       	call   80195f <nsipc>
}
  801a29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801a44:	b8 03 00 00 00       	mov    $0x3,%eax
  801a49:	e8 11 ff ff ff       	call   80195f <nsipc>
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <nsipc_close>:

int
nsipc_close(int s)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801a5e:	b8 04 00 00 00       	mov    $0x4,%eax
  801a63:	e8 f7 fe ff ff       	call   80195f <nsipc>
}
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a7c:	53                   	push   %ebx
  801a7d:	ff 75 0c             	pushl  0xc(%ebp)
  801a80:	68 04 80 80 00       	push   $0x808004
  801a85:	e8 03 ef ff ff       	call   80098d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a8a:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801a90:	b8 05 00 00 00       	mov    $0x5,%eax
  801a95:	e8 c5 fe ff ff       	call   80195f <nsipc>
}
  801a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab0:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801ab5:	b8 06 00 00 00       	mov    $0x6,%eax
  801aba:	e8 a0 fe ff ff       	call   80195f <nsipc>
}
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801ad1:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801ad7:	8b 45 14             	mov    0x14(%ebp),%eax
  801ada:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801adf:	b8 07 00 00 00       	mov    $0x7,%eax
  801ae4:	e8 76 fe ff ff       	call   80195f <nsipc>
  801ae9:	89 c3                	mov    %eax,%ebx
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 35                	js     801b24 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801aef:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801af4:	7f 04                	jg     801afa <nsipc_recv+0x39>
  801af6:	39 c6                	cmp    %eax,%esi
  801af8:	7d 16                	jge    801b10 <nsipc_recv+0x4f>
  801afa:	68 df 28 80 00       	push   $0x8028df
  801aff:	68 a7 28 80 00       	push   $0x8028a7
  801b04:	6a 62                	push   $0x62
  801b06:	68 f4 28 80 00       	push   $0x8028f4
  801b0b:	e8 8d e6 ff ff       	call   80019d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	50                   	push   %eax
  801b14:	68 00 80 80 00       	push   $0x808000
  801b19:	ff 75 0c             	pushl  0xc(%ebp)
  801b1c:	e8 6c ee ff ff       	call   80098d <memmove>
  801b21:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b24:	89 d8                	mov    %ebx,%eax
  801b26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	53                   	push   %ebx
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801b3f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b45:	7e 16                	jle    801b5d <nsipc_send+0x30>
  801b47:	68 00 29 80 00       	push   $0x802900
  801b4c:	68 a7 28 80 00       	push   $0x8028a7
  801b51:	6a 6d                	push   $0x6d
  801b53:	68 f4 28 80 00       	push   $0x8028f4
  801b58:	e8 40 e6 ff ff       	call   80019d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	53                   	push   %ebx
  801b61:	ff 75 0c             	pushl  0xc(%ebp)
  801b64:	68 0c 80 80 00       	push   $0x80800c
  801b69:	e8 1f ee ff ff       	call   80098d <memmove>
	nsipcbuf.send.req_size = size;
  801b6e:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801b74:	8b 45 14             	mov    0x14(%ebp),%eax
  801b77:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801b7c:	b8 08 00 00 00       	mov    $0x8,%eax
  801b81:	e8 d9 fd ff ff       	call   80195f <nsipc>
}
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9c:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba4:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801ba9:	b8 09 00 00 00       	mov    $0x9,%eax
  801bae:	e8 ac fd ff ff       	call   80195f <nsipc>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 77 f2 ff ff       	call   800e3f <fd2data>
  801bc8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bca:	83 c4 08             	add    $0x8,%esp
  801bcd:	68 0c 29 80 00       	push   $0x80290c
  801bd2:	53                   	push   %ebx
  801bd3:	e8 23 ec ff ff       	call   8007fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd8:	8b 46 04             	mov    0x4(%esi),%eax
  801bdb:	2b 06                	sub    (%esi),%eax
  801bdd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801be3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bea:	00 00 00 
	stat->st_dev = &devpipe;
  801bed:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bf4:	30 80 00 
	return 0;
}
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	53                   	push   %ebx
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c0d:	53                   	push   %ebx
  801c0e:	6a 00                	push   $0x0
  801c10:	e8 6e f0 ff ff       	call   800c83 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c15:	89 1c 24             	mov    %ebx,(%esp)
  801c18:	e8 22 f2 ff ff       	call   800e3f <fd2data>
  801c1d:	83 c4 08             	add    $0x8,%esp
  801c20:	50                   	push   %eax
  801c21:	6a 00                	push   $0x0
  801c23:	e8 5b f0 ff ff       	call   800c83 <sys_page_unmap>
}
  801c28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	57                   	push   %edi
  801c31:	56                   	push   %esi
  801c32:	53                   	push   %ebx
  801c33:	83 ec 1c             	sub    $0x1c,%esp
  801c36:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c39:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c3b:	a1 20 60 80 00       	mov    0x806020,%eax
  801c40:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c43:	83 ec 0c             	sub    $0xc,%esp
  801c46:	ff 75 e0             	pushl  -0x20(%ebp)
  801c49:	e8 40 05 00 00       	call   80218e <pageref>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	89 3c 24             	mov    %edi,(%esp)
  801c53:	e8 36 05 00 00       	call   80218e <pageref>
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	39 c3                	cmp    %eax,%ebx
  801c5d:	0f 94 c1             	sete   %cl
  801c60:	0f b6 c9             	movzbl %cl,%ecx
  801c63:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c66:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c6c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c6f:	39 ce                	cmp    %ecx,%esi
  801c71:	74 1b                	je     801c8e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c73:	39 c3                	cmp    %eax,%ebx
  801c75:	75 c4                	jne    801c3b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c77:	8b 42 58             	mov    0x58(%edx),%eax
  801c7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c7d:	50                   	push   %eax
  801c7e:	56                   	push   %esi
  801c7f:	68 13 29 80 00       	push   $0x802913
  801c84:	e8 ed e5 ff ff       	call   800276 <cprintf>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	eb ad                	jmp    801c3b <_pipeisclosed+0xe>
	}
}
  801c8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	83 ec 28             	sub    $0x28,%esp
  801ca2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ca5:	56                   	push   %esi
  801ca6:	e8 94 f1 ff ff       	call   800e3f <fd2data>
  801cab:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	bf 00 00 00 00       	mov    $0x0,%edi
  801cb5:	eb 4b                	jmp    801d02 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cb7:	89 da                	mov    %ebx,%edx
  801cb9:	89 f0                	mov    %esi,%eax
  801cbb:	e8 6d ff ff ff       	call   801c2d <_pipeisclosed>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	75 48                	jne    801d0c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cc4:	e8 16 ef ff ff       	call   800bdf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc9:	8b 43 04             	mov    0x4(%ebx),%eax
  801ccc:	8b 0b                	mov    (%ebx),%ecx
  801cce:	8d 51 20             	lea    0x20(%ecx),%edx
  801cd1:	39 d0                	cmp    %edx,%eax
  801cd3:	73 e2                	jae    801cb7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cdc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cdf:	89 c2                	mov    %eax,%edx
  801ce1:	c1 fa 1f             	sar    $0x1f,%edx
  801ce4:	89 d1                	mov    %edx,%ecx
  801ce6:	c1 e9 1b             	shr    $0x1b,%ecx
  801ce9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cec:	83 e2 1f             	and    $0x1f,%edx
  801cef:	29 ca                	sub    %ecx,%edx
  801cf1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cf5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf9:	83 c0 01             	add    $0x1,%eax
  801cfc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cff:	83 c7 01             	add    $0x1,%edi
  801d02:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d05:	75 c2                	jne    801cc9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d07:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0a:	eb 05                	jmp    801d11 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d0c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    

00801d19 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	57                   	push   %edi
  801d1d:	56                   	push   %esi
  801d1e:	53                   	push   %ebx
  801d1f:	83 ec 18             	sub    $0x18,%esp
  801d22:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d25:	57                   	push   %edi
  801d26:	e8 14 f1 ff ff       	call   800e3f <fd2data>
  801d2b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d35:	eb 3d                	jmp    801d74 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d37:	85 db                	test   %ebx,%ebx
  801d39:	74 04                	je     801d3f <devpipe_read+0x26>
				return i;
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	eb 44                	jmp    801d83 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d3f:	89 f2                	mov    %esi,%edx
  801d41:	89 f8                	mov    %edi,%eax
  801d43:	e8 e5 fe ff ff       	call   801c2d <_pipeisclosed>
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	75 32                	jne    801d7e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d4c:	e8 8e ee ff ff       	call   800bdf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d51:	8b 06                	mov    (%esi),%eax
  801d53:	3b 46 04             	cmp    0x4(%esi),%eax
  801d56:	74 df                	je     801d37 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d58:	99                   	cltd   
  801d59:	c1 ea 1b             	shr    $0x1b,%edx
  801d5c:	01 d0                	add    %edx,%eax
  801d5e:	83 e0 1f             	and    $0x1f,%eax
  801d61:	29 d0                	sub    %edx,%eax
  801d63:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d6e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d71:	83 c3 01             	add    $0x1,%ebx
  801d74:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d77:	75 d8                	jne    801d51 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d79:	8b 45 10             	mov    0x10(%ebp),%eax
  801d7c:	eb 05                	jmp    801d83 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5f                   	pop    %edi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d96:	50                   	push   %eax
  801d97:	e8 ba f0 ff ff       	call   800e56 <fd_alloc>
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	89 c2                	mov    %eax,%edx
  801da1:	85 c0                	test   %eax,%eax
  801da3:	0f 88 2c 01 00 00    	js     801ed5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da9:	83 ec 04             	sub    $0x4,%esp
  801dac:	68 07 04 00 00       	push   $0x407
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	6a 00                	push   $0x0
  801db6:	e8 43 ee ff ff       	call   800bfe <sys_page_alloc>
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	0f 88 0d 01 00 00    	js     801ed5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dc8:	83 ec 0c             	sub    $0xc,%esp
  801dcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	e8 82 f0 ff ff       	call   800e56 <fd_alloc>
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	0f 88 e2 00 00 00    	js     801ec3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de1:	83 ec 04             	sub    $0x4,%esp
  801de4:	68 07 04 00 00       	push   $0x407
  801de9:	ff 75 f0             	pushl  -0x10(%ebp)
  801dec:	6a 00                	push   $0x0
  801dee:	e8 0b ee ff ff       	call   800bfe <sys_page_alloc>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	0f 88 c3 00 00 00    	js     801ec3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	ff 75 f4             	pushl  -0xc(%ebp)
  801e06:	e8 34 f0 ff ff       	call   800e3f <fd2data>
  801e0b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0d:	83 c4 0c             	add    $0xc,%esp
  801e10:	68 07 04 00 00       	push   $0x407
  801e15:	50                   	push   %eax
  801e16:	6a 00                	push   $0x0
  801e18:	e8 e1 ed ff ff       	call   800bfe <sys_page_alloc>
  801e1d:	89 c3                	mov    %eax,%ebx
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	0f 88 89 00 00 00    	js     801eb3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2a:	83 ec 0c             	sub    $0xc,%esp
  801e2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e30:	e8 0a f0 ff ff       	call   800e3f <fd2data>
  801e35:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e3c:	50                   	push   %eax
  801e3d:	6a 00                	push   $0x0
  801e3f:	56                   	push   %esi
  801e40:	6a 00                	push   $0x0
  801e42:	e8 fa ed ff ff       	call   800c41 <sys_page_map>
  801e47:	89 c3                	mov    %eax,%ebx
  801e49:	83 c4 20             	add    $0x20,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 55                	js     801ea5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e50:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e59:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e65:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e73:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e80:	e8 aa ef ff ff       	call   800e2f <fd2num>
  801e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e88:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e8a:	83 c4 04             	add    $0x4,%esp
  801e8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e90:	e8 9a ef ff ff       	call   800e2f <fd2num>
  801e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e98:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea3:	eb 30                	jmp    801ed5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ea5:	83 ec 08             	sub    $0x8,%esp
  801ea8:	56                   	push   %esi
  801ea9:	6a 00                	push   $0x0
  801eab:	e8 d3 ed ff ff       	call   800c83 <sys_page_unmap>
  801eb0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 c3 ed ff ff       	call   800c83 <sys_page_unmap>
  801ec0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 b3 ed ff ff       	call   800c83 <sys_page_unmap>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ed5:	89 d0                	mov    %edx,%eax
  801ed7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee7:	50                   	push   %eax
  801ee8:	ff 75 08             	pushl  0x8(%ebp)
  801eeb:	e8 b5 ef ff ff       	call   800ea5 <fd_lookup>
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	78 18                	js     801f0f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ef7:	83 ec 0c             	sub    $0xc,%esp
  801efa:	ff 75 f4             	pushl  -0xc(%ebp)
  801efd:	e8 3d ef ff ff       	call   800e3f <fd2data>
	return _pipeisclosed(fd, p);
  801f02:	89 c2                	mov    %eax,%edx
  801f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f07:	e8 21 fd ff ff       	call   801c2d <_pipeisclosed>
  801f0c:	83 c4 10             	add    $0x10,%esp
}
  801f0f:	c9                   	leave  
  801f10:	c3                   	ret    

00801f11 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
  801f19:	5d                   	pop    %ebp
  801f1a:	c3                   	ret    

00801f1b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f21:	68 2b 29 80 00       	push   $0x80292b
  801f26:	ff 75 0c             	pushl  0xc(%ebp)
  801f29:	e8 cd e8 ff ff       	call   8007fb <strcpy>
	return 0;
}
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	57                   	push   %edi
  801f39:	56                   	push   %esi
  801f3a:	53                   	push   %ebx
  801f3b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f41:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f46:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f4c:	eb 2d                	jmp    801f7b <devcons_write+0x46>
		m = n - tot;
  801f4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f51:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f53:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f56:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f5b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5e:	83 ec 04             	sub    $0x4,%esp
  801f61:	53                   	push   %ebx
  801f62:	03 45 0c             	add    0xc(%ebp),%eax
  801f65:	50                   	push   %eax
  801f66:	57                   	push   %edi
  801f67:	e8 21 ea ff ff       	call   80098d <memmove>
		sys_cputs(buf, m);
  801f6c:	83 c4 08             	add    $0x8,%esp
  801f6f:	53                   	push   %ebx
  801f70:	57                   	push   %edi
  801f71:	e8 cc eb ff ff       	call   800b42 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f76:	01 de                	add    %ebx,%esi
  801f78:	83 c4 10             	add    $0x10,%esp
  801f7b:	89 f0                	mov    %esi,%eax
  801f7d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f80:	72 cc                	jb     801f4e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5f                   	pop    %edi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 08             	sub    $0x8,%esp
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f99:	74 2a                	je     801fc5 <devcons_read+0x3b>
  801f9b:	eb 05                	jmp    801fa2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f9d:	e8 3d ec ff ff       	call   800bdf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fa2:	e8 b9 eb ff ff       	call   800b60 <sys_cgetc>
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	74 f2                	je     801f9d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 16                	js     801fc5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801faf:	83 f8 04             	cmp    $0x4,%eax
  801fb2:	74 0c                	je     801fc0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb7:	88 02                	mov    %al,(%edx)
	return 1;
  801fb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbe:	eb 05                	jmp    801fc5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fd3:	6a 01                	push   $0x1
  801fd5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd8:	50                   	push   %eax
  801fd9:	e8 64 eb ff ff       	call   800b42 <sys_cputs>
}
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <getchar>:

int
getchar(void)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe9:	6a 01                	push   $0x1
  801feb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fee:	50                   	push   %eax
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 15 f1 ff ff       	call   80110b <read>
	if (r < 0)
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	78 0f                	js     80200c <getchar+0x29>
		return r;
	if (r < 1)
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	7e 06                	jle    802007 <getchar+0x24>
		return -E_EOF;
	return c;
  802001:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802005:	eb 05                	jmp    80200c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802007:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802014:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802017:	50                   	push   %eax
  802018:	ff 75 08             	pushl  0x8(%ebp)
  80201b:	e8 85 ee ff ff       	call   800ea5 <fd_lookup>
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	85 c0                	test   %eax,%eax
  802025:	78 11                	js     802038 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802027:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802030:	39 10                	cmp    %edx,(%eax)
  802032:	0f 94 c0             	sete   %al
  802035:	0f b6 c0             	movzbl %al,%eax
}
  802038:	c9                   	leave  
  802039:	c3                   	ret    

0080203a <opencons>:

int
opencons(void)
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802040:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802043:	50                   	push   %eax
  802044:	e8 0d ee ff ff       	call   800e56 <fd_alloc>
  802049:	83 c4 10             	add    $0x10,%esp
		return r;
  80204c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 3e                	js     802090 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802052:	83 ec 04             	sub    $0x4,%esp
  802055:	68 07 04 00 00       	push   $0x407
  80205a:	ff 75 f4             	pushl  -0xc(%ebp)
  80205d:	6a 00                	push   $0x0
  80205f:	e8 9a eb ff ff       	call   800bfe <sys_page_alloc>
  802064:	83 c4 10             	add    $0x10,%esp
		return r;
  802067:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802069:	85 c0                	test   %eax,%eax
  80206b:	78 23                	js     802090 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80206d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802073:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802076:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802082:	83 ec 0c             	sub    $0xc,%esp
  802085:	50                   	push   %eax
  802086:	e8 a4 ed ff ff       	call   800e2f <fd2num>
  80208b:	89 c2                	mov    %eax,%edx
  80208d:	83 c4 10             	add    $0x10,%esp
}
  802090:	89 d0                	mov    %edx,%eax
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	56                   	push   %esi
  802098:	53                   	push   %ebx
  802099:	8b 75 08             	mov    0x8(%ebp),%esi
  80209c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	74 0e                	je     8020b4 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  8020a6:	83 ec 0c             	sub    $0xc,%esp
  8020a9:	50                   	push   %eax
  8020aa:	e8 ff ec ff ff       	call   800dae <sys_ipc_recv>
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	eb 10                	jmp    8020c4 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	68 00 00 00 f0       	push   $0xf0000000
  8020bc:	e8 ed ec ff ff       	call   800dae <sys_ipc_recv>
  8020c1:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	74 0e                	je     8020d6 <ipc_recv+0x42>
    	*from_env_store = 0;
  8020c8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  8020ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8020d4:	eb 24                	jmp    8020fa <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8020d6:	85 f6                	test   %esi,%esi
  8020d8:	74 0a                	je     8020e4 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8020da:	a1 20 60 80 00       	mov    0x806020,%eax
  8020df:	8b 40 74             	mov    0x74(%eax),%eax
  8020e2:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8020e4:	85 db                	test   %ebx,%ebx
  8020e6:	74 0a                	je     8020f2 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8020e8:	a1 20 60 80 00       	mov    0x806020,%eax
  8020ed:	8b 40 78             	mov    0x78(%eax),%eax
  8020f0:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8020f2:	a1 20 60 80 00       	mov    0x806020,%eax
  8020f7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8020fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    

00802101 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	57                   	push   %edi
  802105:	56                   	push   %esi
  802106:	53                   	push   %ebx
  802107:	83 ec 0c             	sub    $0xc,%esp
  80210a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80210d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802110:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802113:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  802115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80211a:	0f 44 d8             	cmove  %eax,%ebx
  80211d:	eb 1c                	jmp    80213b <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  80211f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802122:	74 12                	je     802136 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802124:	50                   	push   %eax
  802125:	68 37 29 80 00       	push   $0x802937
  80212a:	6a 4b                	push   $0x4b
  80212c:	68 4f 29 80 00       	push   $0x80294f
  802131:	e8 67 e0 ff ff       	call   80019d <_panic>
        }	
        sys_yield();
  802136:	e8 a4 ea ff ff       	call   800bdf <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80213b:	ff 75 14             	pushl  0x14(%ebp)
  80213e:	53                   	push   %ebx
  80213f:	56                   	push   %esi
  802140:	57                   	push   %edi
  802141:	e8 45 ec ff ff       	call   800d8b <sys_ipc_try_send>
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	85 c0                	test   %eax,%eax
  80214b:	75 d2                	jne    80211f <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  80214d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802160:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802163:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802169:	8b 52 50             	mov    0x50(%edx),%edx
  80216c:	39 ca                	cmp    %ecx,%edx
  80216e:	75 0d                	jne    80217d <ipc_find_env+0x28>
			return envs[i].env_id;
  802170:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802178:	8b 40 48             	mov    0x48(%eax),%eax
  80217b:	eb 0f                	jmp    80218c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80217d:	83 c0 01             	add    $0x1,%eax
  802180:	3d 00 04 00 00       	cmp    $0x400,%eax
  802185:	75 d9                	jne    802160 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802187:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80218c:	5d                   	pop    %ebp
  80218d:	c3                   	ret    

0080218e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802194:	89 d0                	mov    %edx,%eax
  802196:	c1 e8 16             	shr    $0x16,%eax
  802199:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a5:	f6 c1 01             	test   $0x1,%cl
  8021a8:	74 1d                	je     8021c7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021aa:	c1 ea 0c             	shr    $0xc,%edx
  8021ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021b4:	f6 c2 01             	test   $0x1,%dl
  8021b7:	74 0e                	je     8021c7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021b9:	c1 ea 0c             	shr    $0xc,%edx
  8021bc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c3:	ef 
  8021c4:	0f b7 c0             	movzwl %ax,%eax
}
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	66 90                	xchg   %ax,%ax
  8021cb:	66 90                	xchg   %ax,%ax
  8021cd:	66 90                	xchg   %ax,%ax
  8021cf:	90                   	nop

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
