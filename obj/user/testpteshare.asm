
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 f7 07 00 00       	call   800840 <strcpy>
	exit();
  800049:	e8 7a 01 00 00       	call   8001c8 <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 ca 0b 00 00       	call   800c43 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 4c 2d 80 00       	push   $0x802d4c
  800086:	6a 13                	push   $0x13
  800088:	68 5f 2d 80 00       	push   $0x802d5f
  80008d:	e8 50 01 00 00       	call   8001e2 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 d7 0e 00 00       	call   800f6e <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 73 2d 80 00       	push   $0x802d73
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 5f 2d 80 00       	push   $0x802d5f
  8000aa:	e8 33 01 00 00       	call   8001e2 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 7a 07 00 00       	call   800840 <strcpy>
		exit();
  8000c6:	e8 fd 00 00 00       	call   8001c8 <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 28 26 00 00       	call   8026ff <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 00 08 00 00       	call   8008ea <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 46 2d 80 00       	mov    $0x802d46,%edx
  8000f4:	b8 40 2d 80 00       	mov    $0x802d40,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 7c 2d 80 00       	push   $0x802d7c
  800102:	e8 b4 01 00 00       	call   8002bb <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 97 2d 80 00       	push   $0x802d97
  80010e:	68 9c 2d 80 00       	push   $0x802d9c
  800113:	68 9b 2d 80 00       	push   $0x802d9b
  800118:	e8 ac 1d 00 00       	call   801ec9 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 a9 2d 80 00       	push   $0x802da9
  80012a:	6a 21                	push   $0x21
  80012c:	68 5f 2d 80 00       	push   $0x802d5f
  800131:	e8 ac 00 00 00       	call   8001e2 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 c0 25 00 00       	call   8026ff <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 98 07 00 00       	call   8008ea <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 46 2d 80 00       	mov    $0x802d46,%edx
  80015c:	b8 40 2d 80 00       	mov    $0x802d40,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 b3 2d 80 00       	push   $0x802db3
  80016a:	e8 4c 01 00 00       	call   8002bb <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800183:	c7 05 08 50 80 00 00 	movl   $0x0,0x805008
  80018a:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80018d:	e8 73 0a 00 00       	call   800c05 <sys_getenvid>
  800192:	25 ff 03 00 00       	and    $0x3ff,%eax
  800197:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80019f:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a4:	85 db                	test   %ebx,%ebx
  8001a6:	7e 07                	jle    8001af <libmain+0x37>
		binaryname = argv[0];
  8001a8:	8b 06                	mov    (%esi),%eax
  8001aa:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001af:	83 ec 08             	sub    $0x8,%esp
  8001b2:	56                   	push   %esi
  8001b3:	53                   	push   %ebx
  8001b4:	e8 9a fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001b9:	e8 0a 00 00 00       	call   8001c8 <exit>
}
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001ce:	e8 7b 11 00 00       	call   80134e <close_all>
	sys_env_destroy(0);
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	6a 00                	push   $0x0
  8001d8:	e8 e7 09 00 00       	call   800bc4 <sys_env_destroy>
}
  8001dd:	83 c4 10             	add    $0x10,%esp
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ea:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001f0:	e8 10 0a 00 00       	call   800c05 <sys_getenvid>
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 0c             	pushl  0xc(%ebp)
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	56                   	push   %esi
  8001ff:	50                   	push   %eax
  800200:	68 f8 2d 80 00       	push   $0x802df8
  800205:	e8 b1 00 00 00       	call   8002bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020a:	83 c4 18             	add    $0x18,%esp
  80020d:	53                   	push   %ebx
  80020e:	ff 75 10             	pushl  0x10(%ebp)
  800211:	e8 54 00 00 00       	call   80026a <vcprintf>
	cprintf("\n");
  800216:	c7 04 24 7a 31 80 00 	movl   $0x80317a,(%esp)
  80021d:	e8 99 00 00 00       	call   8002bb <cprintf>
  800222:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800225:	cc                   	int3   
  800226:	eb fd                	jmp    800225 <_panic+0x43>

00800228 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	53                   	push   %ebx
  80022c:	83 ec 04             	sub    $0x4,%esp
  80022f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800232:	8b 13                	mov    (%ebx),%edx
  800234:	8d 42 01             	lea    0x1(%edx),%eax
  800237:	89 03                	mov    %eax,(%ebx)
  800239:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800240:	3d ff 00 00 00       	cmp    $0xff,%eax
  800245:	75 1a                	jne    800261 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	68 ff 00 00 00       	push   $0xff
  80024f:	8d 43 08             	lea    0x8(%ebx),%eax
  800252:	50                   	push   %eax
  800253:	e8 2f 09 00 00       	call   800b87 <sys_cputs>
		b->idx = 0;
  800258:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80025e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800261:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800273:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027a:	00 00 00 
	b.cnt = 0;
  80027d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800284:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800293:	50                   	push   %eax
  800294:	68 28 02 80 00       	push   $0x800228
  800299:	e8 54 01 00 00       	call   8003f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029e:	83 c4 08             	add    $0x8,%esp
  8002a1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ad:	50                   	push   %eax
  8002ae:	e8 d4 08 00 00       	call   800b87 <sys_cputs>

	return b.cnt;
}
  8002b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c4:	50                   	push   %eax
  8002c5:	ff 75 08             	pushl  0x8(%ebp)
  8002c8:	e8 9d ff ff ff       	call   80026a <vcprintf>
	va_end(ap);

	return cnt;
}
  8002cd:	c9                   	leave  
  8002ce:	c3                   	ret    

008002cf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 1c             	sub    $0x1c,%esp
  8002d8:	89 c7                	mov    %eax,%edi
  8002da:	89 d6                	mov    %edx,%esi
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f6:	39 d3                	cmp    %edx,%ebx
  8002f8:	72 05                	jb     8002ff <printnum+0x30>
  8002fa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002fd:	77 45                	ja     800344 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ff:	83 ec 0c             	sub    $0xc,%esp
  800302:	ff 75 18             	pushl  0x18(%ebp)
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030b:	53                   	push   %ebx
  80030c:	ff 75 10             	pushl  0x10(%ebp)
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	ff 75 e4             	pushl  -0x1c(%ebp)
  800315:	ff 75 e0             	pushl  -0x20(%ebp)
  800318:	ff 75 dc             	pushl  -0x24(%ebp)
  80031b:	ff 75 d8             	pushl  -0x28(%ebp)
  80031e:	e8 7d 27 00 00       	call   802aa0 <__udivdi3>
  800323:	83 c4 18             	add    $0x18,%esp
  800326:	52                   	push   %edx
  800327:	50                   	push   %eax
  800328:	89 f2                	mov    %esi,%edx
  80032a:	89 f8                	mov    %edi,%eax
  80032c:	e8 9e ff ff ff       	call   8002cf <printnum>
  800331:	83 c4 20             	add    $0x20,%esp
  800334:	eb 18                	jmp    80034e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	56                   	push   %esi
  80033a:	ff 75 18             	pushl  0x18(%ebp)
  80033d:	ff d7                	call   *%edi
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	eb 03                	jmp    800347 <printnum+0x78>
  800344:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800347:	83 eb 01             	sub    $0x1,%ebx
  80034a:	85 db                	test   %ebx,%ebx
  80034c:	7f e8                	jg     800336 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	56                   	push   %esi
  800352:	83 ec 04             	sub    $0x4,%esp
  800355:	ff 75 e4             	pushl  -0x1c(%ebp)
  800358:	ff 75 e0             	pushl  -0x20(%ebp)
  80035b:	ff 75 dc             	pushl  -0x24(%ebp)
  80035e:	ff 75 d8             	pushl  -0x28(%ebp)
  800361:	e8 6a 28 00 00       	call   802bd0 <__umoddi3>
  800366:	83 c4 14             	add    $0x14,%esp
  800369:	0f be 80 1b 2e 80 00 	movsbl 0x802e1b(%eax),%eax
  800370:	50                   	push   %eax
  800371:	ff d7                	call   *%edi
}
  800373:	83 c4 10             	add    $0x10,%esp
  800376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800381:	83 fa 01             	cmp    $0x1,%edx
  800384:	7e 0e                	jle    800394 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	8b 52 04             	mov    0x4(%edx),%edx
  800392:	eb 22                	jmp    8003b6 <getuint+0x38>
	else if (lflag)
  800394:	85 d2                	test   %edx,%edx
  800396:	74 10                	je     8003a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800398:	8b 10                	mov    (%eax),%edx
  80039a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 02                	mov    (%edx),%eax
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a6:	eb 0e                	jmp    8003b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a8:	8b 10                	mov    (%eax),%edx
  8003aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 02                	mov    (%edx),%eax
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c2:	8b 10                	mov    (%eax),%edx
  8003c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c7:	73 0a                	jae    8003d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cc:	89 08                	mov    %ecx,(%eax)
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d1:	88 02                	mov    %al,(%edx)
}
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003de:	50                   	push   %eax
  8003df:	ff 75 10             	pushl  0x10(%ebp)
  8003e2:	ff 75 0c             	pushl  0xc(%ebp)
  8003e5:	ff 75 08             	pushl  0x8(%ebp)
  8003e8:	e8 05 00 00 00       	call   8003f2 <vprintfmt>
	va_end(ap);
}
  8003ed:	83 c4 10             	add    $0x10,%esp
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 2c             	sub    $0x2c,%esp
  8003fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	eb 12                	jmp    800418 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800406:	85 c0                	test   %eax,%eax
  800408:	0f 84 89 03 00 00    	je     800797 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	53                   	push   %ebx
  800412:	50                   	push   %eax
  800413:	ff d6                	call   *%esi
  800415:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800418:	83 c7 01             	add    $0x1,%edi
  80041b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041f:	83 f8 25             	cmp    $0x25,%eax
  800422:	75 e2                	jne    800406 <vprintfmt+0x14>
  800424:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800428:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800436:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	eb 07                	jmp    80044b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800447:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8d 47 01             	lea    0x1(%edi),%eax
  80044e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800451:	0f b6 07             	movzbl (%edi),%eax
  800454:	0f b6 c8             	movzbl %al,%ecx
  800457:	83 e8 23             	sub    $0x23,%eax
  80045a:	3c 55                	cmp    $0x55,%al
  80045c:	0f 87 1a 03 00 00    	ja     80077c <vprintfmt+0x38a>
  800462:	0f b6 c0             	movzbl %al,%eax
  800465:	ff 24 85 60 2f 80 00 	jmp    *0x802f60(,%eax,4)
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800473:	eb d6                	jmp    80044b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800480:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800483:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800487:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80048a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80048d:	83 fa 09             	cmp    $0x9,%edx
  800490:	77 39                	ja     8004cb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800492:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800495:	eb e9                	jmp    800480 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 48 04             	lea    0x4(%eax),%ecx
  80049d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a8:	eb 27                	jmp    8004d1 <vprintfmt+0xdf>
  8004aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b4:	0f 49 c8             	cmovns %eax,%ecx
  8004b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bd:	eb 8c                	jmp    80044b <vprintfmt+0x59>
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c9:	eb 80                	jmp    80044b <vprintfmt+0x59>
  8004cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ce:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d5:	0f 89 70 ff ff ff    	jns    80044b <vprintfmt+0x59>
				width = precision, precision = -1;
  8004db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e8:	e9 5e ff ff ff       	jmp    80044b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ed:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f3:	e9 53 ff ff ff       	jmp    80044b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	ff 30                	pushl  (%eax)
  800507:	ff d6                	call   *%esi
			break;
  800509:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050f:	e9 04 ff ff ff       	jmp    800418 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 04             	lea    0x4(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	99                   	cltd   
  800520:	31 d0                	xor    %edx,%eax
  800522:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800524:	83 f8 0f             	cmp    $0xf,%eax
  800527:	7f 0b                	jg     800534 <vprintfmt+0x142>
  800529:	8b 14 85 c0 30 80 00 	mov    0x8030c0(,%eax,4),%edx
  800530:	85 d2                	test   %edx,%edx
  800532:	75 18                	jne    80054c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800534:	50                   	push   %eax
  800535:	68 33 2e 80 00       	push   $0x802e33
  80053a:	53                   	push   %ebx
  80053b:	56                   	push   %esi
  80053c:	e8 94 fe ff ff       	call   8003d5 <printfmt>
  800541:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800547:	e9 cc fe ff ff       	jmp    800418 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054c:	52                   	push   %edx
  80054d:	68 4d 33 80 00       	push   $0x80334d
  800552:	53                   	push   %ebx
  800553:	56                   	push   %esi
  800554:	e8 7c fe ff ff       	call   8003d5 <printfmt>
  800559:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055f:	e9 b4 fe ff ff       	jmp    800418 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80056f:	85 ff                	test   %edi,%edi
  800571:	b8 2c 2e 80 00       	mov    $0x802e2c,%eax
  800576:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800579:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057d:	0f 8e 94 00 00 00    	jle    800617 <vprintfmt+0x225>
  800583:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800587:	0f 84 98 00 00 00    	je     800625 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 d0             	pushl  -0x30(%ebp)
  800593:	57                   	push   %edi
  800594:	e8 86 02 00 00       	call   80081f <strnlen>
  800599:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059c:	29 c1                	sub    %eax,%ecx
  80059e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ae:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b0:	eb 0f                	jmp    8005c1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	83 ef 01             	sub    $0x1,%edi
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	7f ed                	jg     8005b2 <vprintfmt+0x1c0>
  8005c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d2:	0f 49 c1             	cmovns %ecx,%eax
  8005d5:	29 c1                	sub    %eax,%ecx
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	89 cb                	mov    %ecx,%ebx
  8005e2:	eb 4d                	jmp    800631 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e8:	74 1b                	je     800605 <vprintfmt+0x213>
  8005ea:	0f be c0             	movsbl %al,%eax
  8005ed:	83 e8 20             	sub    $0x20,%eax
  8005f0:	83 f8 5e             	cmp    $0x5e,%eax
  8005f3:	76 10                	jbe    800605 <vprintfmt+0x213>
					putch('?', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	ff 75 0c             	pushl  0xc(%ebp)
  8005fb:	6a 3f                	push   $0x3f
  8005fd:	ff 55 08             	call   *0x8(%ebp)
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb 0d                	jmp    800612 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	ff 75 0c             	pushl  0xc(%ebp)
  80060b:	52                   	push   %edx
  80060c:	ff 55 08             	call   *0x8(%ebp)
  80060f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800612:	83 eb 01             	sub    $0x1,%ebx
  800615:	eb 1a                	jmp    800631 <vprintfmt+0x23f>
  800617:	89 75 08             	mov    %esi,0x8(%ebp)
  80061a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800620:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800623:	eb 0c                	jmp    800631 <vprintfmt+0x23f>
  800625:	89 75 08             	mov    %esi,0x8(%ebp)
  800628:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800631:	83 c7 01             	add    $0x1,%edi
  800634:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800638:	0f be d0             	movsbl %al,%edx
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 23                	je     800662 <vprintfmt+0x270>
  80063f:	85 f6                	test   %esi,%esi
  800641:	78 a1                	js     8005e4 <vprintfmt+0x1f2>
  800643:	83 ee 01             	sub    $0x1,%esi
  800646:	79 9c                	jns    8005e4 <vprintfmt+0x1f2>
  800648:	89 df                	mov    %ebx,%edi
  80064a:	8b 75 08             	mov    0x8(%ebp),%esi
  80064d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800650:	eb 18                	jmp    80066a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 20                	push   $0x20
  800658:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb 08                	jmp    80066a <vprintfmt+0x278>
  800662:	89 df                	mov    %ebx,%edi
  800664:	8b 75 08             	mov    0x8(%ebp),%esi
  800667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066a:	85 ff                	test   %edi,%edi
  80066c:	7f e4                	jg     800652 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800671:	e9 a2 fd ff ff       	jmp    800418 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800676:	83 fa 01             	cmp    $0x1,%edx
  800679:	7e 16                	jle    800691 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 08             	lea    0x8(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	8b 50 04             	mov    0x4(%eax),%edx
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068f:	eb 32                	jmp    8006c3 <vprintfmt+0x2d1>
	else if (lflag)
  800691:	85 d2                	test   %edx,%edx
  800693:	74 18                	je     8006ad <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 04             	lea    0x4(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)
  80069e:	8b 00                	mov    (%eax),%eax
  8006a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a3:	89 c1                	mov    %eax,%ecx
  8006a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ab:	eb 16                	jmp    8006c3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bb:	89 c1                	mov    %eax,%ecx
  8006bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d2:	79 74                	jns    800748 <vprintfmt+0x356>
				putch('-', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 2d                	push   $0x2d
  8006da:	ff d6                	call   *%esi
				num = -(long long) num;
  8006dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e2:	f7 d8                	neg    %eax
  8006e4:	83 d2 00             	adc    $0x0,%edx
  8006e7:	f7 da                	neg    %edx
  8006e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f1:	eb 55                	jmp    800748 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 83 fc ff ff       	call   80037e <getuint>
			base = 10;
  8006fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800700:	eb 46                	jmp    800748 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
  800705:	e8 74 fc ff ff       	call   80037e <getuint>
		        base = 8;
  80070a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80070f:	eb 37                	jmp    800748 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 30                	push   $0x30
  800717:	ff d6                	call   *%esi
			putch('x', putdat);
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	6a 78                	push   $0x78
  80071f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8d 50 04             	lea    0x4(%eax),%edx
  800727:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072a:	8b 00                	mov    (%eax),%eax
  80072c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800731:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800734:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800739:	eb 0d                	jmp    800748 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 3b fc ff ff       	call   80037e <getuint>
			base = 16;
  800743:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800748:	83 ec 0c             	sub    $0xc,%esp
  80074b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80074f:	57                   	push   %edi
  800750:	ff 75 e0             	pushl  -0x20(%ebp)
  800753:	51                   	push   %ecx
  800754:	52                   	push   %edx
  800755:	50                   	push   %eax
  800756:	89 da                	mov    %ebx,%edx
  800758:	89 f0                	mov    %esi,%eax
  80075a:	e8 70 fb ff ff       	call   8002cf <printnum>
			break;
  80075f:	83 c4 20             	add    $0x20,%esp
  800762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800765:	e9 ae fc ff ff       	jmp    800418 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	51                   	push   %ecx
  80076f:	ff d6                	call   *%esi
			break;
  800771:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800777:	e9 9c fc ff ff       	jmp    800418 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 25                	push   $0x25
  800782:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 03                	jmp    80078c <vprintfmt+0x39a>
  800789:	83 ef 01             	sub    $0x1,%edi
  80078c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800790:	75 f7                	jne    800789 <vprintfmt+0x397>
  800792:	e9 81 fc ff ff       	jmp    800418 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5f                   	pop    %edi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 18             	sub    $0x18,%esp
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	74 26                	je     8007e6 <vsnprintf+0x47>
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	7e 22                	jle    8007e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c4:	ff 75 14             	pushl  0x14(%ebp)
  8007c7:	ff 75 10             	pushl  0x10(%ebp)
  8007ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cd:	50                   	push   %eax
  8007ce:	68 b8 03 80 00       	push   $0x8003b8
  8007d3:	e8 1a fc ff ff       	call   8003f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	eb 05                	jmp    8007eb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f6:	50                   	push   %eax
  8007f7:	ff 75 10             	pushl  0x10(%ebp)
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	ff 75 08             	pushl  0x8(%ebp)
  800800:	e8 9a ff ff ff       	call   80079f <vsnprintf>
	va_end(ap);

	return rc;
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	eb 03                	jmp    800817 <strlen+0x10>
		n++;
  800814:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800817:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081b:	75 f7                	jne    800814 <strlen+0xd>
		n++;
	return n;
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	ba 00 00 00 00       	mov    $0x0,%edx
  80082d:	eb 03                	jmp    800832 <strnlen+0x13>
		n++;
  80082f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800832:	39 c2                	cmp    %eax,%edx
  800834:	74 08                	je     80083e <strnlen+0x1f>
  800836:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083a:	75 f3                	jne    80082f <strnlen+0x10>
  80083c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084a:	89 c2                	mov    %eax,%edx
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800856:	88 5a ff             	mov    %bl,-0x1(%edx)
  800859:	84 db                	test   %bl,%bl
  80085b:	75 ef                	jne    80084c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80085d:	5b                   	pop    %ebx
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800867:	53                   	push   %ebx
  800868:	e8 9a ff ff ff       	call   800807 <strlen>
  80086d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800870:	ff 75 0c             	pushl  0xc(%ebp)
  800873:	01 d8                	add    %ebx,%eax
  800875:	50                   	push   %eax
  800876:	e8 c5 ff ff ff       	call   800840 <strcpy>
	return dst;
}
  80087b:	89 d8                	mov    %ebx,%eax
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	89 f3                	mov    %esi,%ebx
  80088f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800892:	89 f2                	mov    %esi,%edx
  800894:	eb 0f                	jmp    8008a5 <strncpy+0x23>
		*dst++ = *src;
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	0f b6 01             	movzbl (%ecx),%eax
  80089c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089f:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	39 da                	cmp    %ebx,%edx
  8008a7:	75 ed                	jne    800896 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a9:	89 f0                	mov    %esi,%eax
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8008bd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bf:	85 d2                	test   %edx,%edx
  8008c1:	74 21                	je     8008e4 <strlcpy+0x35>
  8008c3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c7:	89 f2                	mov    %esi,%edx
  8008c9:	eb 09                	jmp    8008d4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	83 c1 01             	add    $0x1,%ecx
  8008d1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d4:	39 c2                	cmp    %eax,%edx
  8008d6:	74 09                	je     8008e1 <strlcpy+0x32>
  8008d8:	0f b6 19             	movzbl (%ecx),%ebx
  8008db:	84 db                	test   %bl,%bl
  8008dd:	75 ec                	jne    8008cb <strlcpy+0x1c>
  8008df:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e4:	29 f0                	sub    %esi,%eax
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f3:	eb 06                	jmp    8008fb <strcmp+0x11>
		p++, q++;
  8008f5:	83 c1 01             	add    $0x1,%ecx
  8008f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	84 c0                	test   %al,%al
  800900:	74 04                	je     800906 <strcmp+0x1c>
  800902:	3a 02                	cmp    (%edx),%al
  800904:	74 ef                	je     8008f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	89 c3                	mov    %eax,%ebx
  80091c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091f:	eb 06                	jmp    800927 <strncmp+0x17>
		n--, p++, q++;
  800921:	83 c0 01             	add    $0x1,%eax
  800924:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800927:	39 d8                	cmp    %ebx,%eax
  800929:	74 15                	je     800940 <strncmp+0x30>
  80092b:	0f b6 08             	movzbl (%eax),%ecx
  80092e:	84 c9                	test   %cl,%cl
  800930:	74 04                	je     800936 <strncmp+0x26>
  800932:	3a 0a                	cmp    (%edx),%cl
  800934:	74 eb                	je     800921 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800936:	0f b6 00             	movzbl (%eax),%eax
  800939:	0f b6 12             	movzbl (%edx),%edx
  80093c:	29 d0                	sub    %edx,%eax
  80093e:	eb 05                	jmp    800945 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800945:	5b                   	pop    %ebx
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800952:	eb 07                	jmp    80095b <strchr+0x13>
		if (*s == c)
  800954:	38 ca                	cmp    %cl,%dl
  800956:	74 0f                	je     800967 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	0f b6 10             	movzbl (%eax),%edx
  80095e:	84 d2                	test   %dl,%dl
  800960:	75 f2                	jne    800954 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800973:	eb 03                	jmp    800978 <strfind+0xf>
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097b:	38 ca                	cmp    %cl,%dl
  80097d:	74 04                	je     800983 <strfind+0x1a>
  80097f:	84 d2                	test   %dl,%dl
  800981:	75 f2                	jne    800975 <strfind+0xc>
			break;
	return (char *) s;
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800991:	85 c9                	test   %ecx,%ecx
  800993:	74 36                	je     8009cb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 28                	jne    8009c5 <memset+0x40>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 23                	jne    8009c5 <memset+0x40>
		c &= 0xFF;
  8009a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a6:	89 d3                	mov    %edx,%ebx
  8009a8:	c1 e3 08             	shl    $0x8,%ebx
  8009ab:	89 d6                	mov    %edx,%esi
  8009ad:	c1 e6 18             	shl    $0x18,%esi
  8009b0:	89 d0                	mov    %edx,%eax
  8009b2:	c1 e0 10             	shl    $0x10,%eax
  8009b5:	09 f0                	or     %esi,%eax
  8009b7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b9:	89 d8                	mov    %ebx,%eax
  8009bb:	09 d0                	or     %edx,%eax
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
  8009c0:	fc                   	cld    
  8009c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c3:	eb 06                	jmp    8009cb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	fc                   	cld    
  8009c9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	57                   	push   %edi
  8009d6:	56                   	push   %esi
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e0:	39 c6                	cmp    %eax,%esi
  8009e2:	73 35                	jae    800a19 <memmove+0x47>
  8009e4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e7:	39 d0                	cmp    %edx,%eax
  8009e9:	73 2e                	jae    800a19 <memmove+0x47>
		s += n;
		d += n;
  8009eb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	89 d6                	mov    %edx,%esi
  8009f0:	09 fe                	or     %edi,%esi
  8009f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f8:	75 13                	jne    800a0d <memmove+0x3b>
  8009fa:	f6 c1 03             	test   $0x3,%cl
  8009fd:	75 0e                	jne    800a0d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ff:	83 ef 04             	sub    $0x4,%edi
  800a02:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a05:	c1 e9 02             	shr    $0x2,%ecx
  800a08:	fd                   	std    
  800a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0b:	eb 09                	jmp    800a16 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0d:	83 ef 01             	sub    $0x1,%edi
  800a10:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a13:	fd                   	std    
  800a14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a16:	fc                   	cld    
  800a17:	eb 1d                	jmp    800a36 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a19:	89 f2                	mov    %esi,%edx
  800a1b:	09 c2                	or     %eax,%edx
  800a1d:	f6 c2 03             	test   $0x3,%dl
  800a20:	75 0f                	jne    800a31 <memmove+0x5f>
  800a22:	f6 c1 03             	test   $0x3,%cl
  800a25:	75 0a                	jne    800a31 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a27:	c1 e9 02             	shr    $0x2,%ecx
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	fc                   	cld    
  800a2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2f:	eb 05                	jmp    800a36 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3d:	ff 75 10             	pushl  0x10(%ebp)
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	ff 75 08             	pushl  0x8(%ebp)
  800a46:	e8 87 ff ff ff       	call   8009d2 <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a58:	89 c6                	mov    %eax,%esi
  800a5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5d:	eb 1a                	jmp    800a79 <memcmp+0x2c>
		if (*s1 != *s2)
  800a5f:	0f b6 08             	movzbl (%eax),%ecx
  800a62:	0f b6 1a             	movzbl (%edx),%ebx
  800a65:	38 d9                	cmp    %bl,%cl
  800a67:	74 0a                	je     800a73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a69:	0f b6 c1             	movzbl %cl,%eax
  800a6c:	0f b6 db             	movzbl %bl,%ebx
  800a6f:	29 d8                	sub    %ebx,%eax
  800a71:	eb 0f                	jmp    800a82 <memcmp+0x35>
		s1++, s2++;
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a79:	39 f0                	cmp    %esi,%eax
  800a7b:	75 e2                	jne    800a5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	53                   	push   %ebx
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a8d:	89 c1                	mov    %eax,%ecx
  800a8f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a96:	eb 0a                	jmp    800aa2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a98:	0f b6 10             	movzbl (%eax),%edx
  800a9b:	39 da                	cmp    %ebx,%edx
  800a9d:	74 07                	je     800aa6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9f:	83 c0 01             	add    $0x1,%eax
  800aa2:	39 c8                	cmp    %ecx,%eax
  800aa4:	72 f2                	jb     800a98 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab5:	eb 03                	jmp    800aba <strtol+0x11>
		s++;
  800ab7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aba:	0f b6 01             	movzbl (%ecx),%eax
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f6                	je     800ab7 <strtol+0xe>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	74 f2                	je     800ab7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac5:	3c 2b                	cmp    $0x2b,%al
  800ac7:	75 0a                	jne    800ad3 <strtol+0x2a>
		s++;
  800ac9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad1:	eb 11                	jmp    800ae4 <strtol+0x3b>
  800ad3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad8:	3c 2d                	cmp    $0x2d,%al
  800ada:	75 08                	jne    800ae4 <strtol+0x3b>
		s++, neg = 1;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aea:	75 15                	jne    800b01 <strtol+0x58>
  800aec:	80 39 30             	cmpb   $0x30,(%ecx)
  800aef:	75 10                	jne    800b01 <strtol+0x58>
  800af1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af5:	75 7c                	jne    800b73 <strtol+0xca>
		s += 2, base = 16;
  800af7:	83 c1 02             	add    $0x2,%ecx
  800afa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aff:	eb 16                	jmp    800b17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b01:	85 db                	test   %ebx,%ebx
  800b03:	75 12                	jne    800b17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0d:	75 08                	jne    800b17 <strtol+0x6e>
		s++, base = 8;
  800b0f:	83 c1 01             	add    $0x1,%ecx
  800b12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1f:	0f b6 11             	movzbl (%ecx),%edx
  800b22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 09             	cmp    $0x9,%bl
  800b2a:	77 08                	ja     800b34 <strtol+0x8b>
			dig = *s - '0';
  800b2c:	0f be d2             	movsbl %dl,%edx
  800b2f:	83 ea 30             	sub    $0x30,%edx
  800b32:	eb 22                	jmp    800b56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b37:	89 f3                	mov    %esi,%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b3e:	0f be d2             	movsbl %dl,%edx
  800b41:	83 ea 57             	sub    $0x57,%edx
  800b44:	eb 10                	jmp    800b56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 16                	ja     800b66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b59:	7d 0b                	jge    800b66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b5b:	83 c1 01             	add    $0x1,%ecx
  800b5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b64:	eb b9                	jmp    800b1f <strtol+0x76>

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 0d                	je     800b79 <strtol+0xd0>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
  800b71:	eb 06                	jmp    800b79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b73:	85 db                	test   %ebx,%ebx
  800b75:	74 98                	je     800b0f <strtol+0x66>
  800b77:	eb 9e                	jmp    800b17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	f7 da                	neg    %edx
  800b7d:	85 ff                	test   %edi,%edi
  800b7f:	0f 45 c2             	cmovne %edx,%eax
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	89 c3                	mov    %eax,%ebx
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	89 c6                	mov    %eax,%esi
  800b9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 cb                	mov    %ecx,%ebx
  800bdc:	89 cf                	mov    %ecx,%edi
  800bde:	89 ce                	mov    %ecx,%esi
  800be0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 03                	push   $0x3
  800bec:	68 1f 31 80 00       	push   $0x80311f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 3c 31 80 00       	push   $0x80313c
  800bf8:	e8 e5 f5 ff ff       	call   8001e2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 02 00 00 00       	mov    $0x2,%eax
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_yield>:

void
sys_yield(void)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c4c:	be 00 00 00 00       	mov    $0x0,%esi
  800c51:	b8 04 00 00 00       	mov    $0x4,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5f:	89 f7                	mov    %esi,%edi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 04                	push   $0x4
  800c6d:	68 1f 31 80 00       	push   $0x80311f
  800c72:	6a 23                	push   $0x23
  800c74:	68 3c 31 80 00       	push   $0x80313c
  800c79:	e8 64 f5 ff ff       	call   8001e2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 05                	push   $0x5
  800caf:	68 1f 31 80 00       	push   $0x80311f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 3c 31 80 00       	push   $0x80313c
  800cbb:	e8 22 f5 ff ff       	call   8001e2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7e 17                	jle    800d02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 06                	push   $0x6
  800cf1:	68 1f 31 80 00       	push   $0x80311f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 3c 31 80 00       	push   $0x80313c
  800cfd:	e8 e0 f4 ff ff       	call   8001e2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 08                	push   $0x8
  800d33:	68 1f 31 80 00       	push   $0x80311f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 3c 31 80 00       	push   $0x80313c
  800d3f:	e8 9e f4 ff ff       	call   8001e2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 09                	push   $0x9
  800d75:	68 1f 31 80 00       	push   $0x80311f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 3c 31 80 00       	push   $0x80313c
  800d81:	e8 5c f4 ff ff       	call   8001e2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 0a                	push   $0xa
  800db7:	68 1f 31 80 00       	push   $0x80311f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 3c 31 80 00       	push   $0x80313c
  800dc3:	e8 1a f4 ff ff       	call   8001e2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	be 00 00 00 00       	mov    $0x0,%esi
  800ddb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 cb                	mov    %ecx,%ebx
  800e0b:	89 cf                	mov    %ecx,%edi
  800e0d:	89 ce                	mov    %ecx,%esi
  800e0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7e 17                	jle    800e2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 0d                	push   $0xd
  800e1b:	68 1f 31 80 00       	push   $0x80311f
  800e20:	6a 23                	push   $0x23
  800e22:	68 3c 31 80 00       	push   $0x80313c
  800e27:	e8 b6 f3 ff ff       	call   8001e2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e44:	89 d1                	mov    %edx,%ecx
  800e46:	89 d3                	mov    %edx,%ebx
  800e48:	89 d7                	mov    %edx,%edi
  800e4a:	89 d6                	mov    %edx,%esi
  800e4c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	53                   	push   %ebx
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e7e:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	 if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)  && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e80:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e84:	74 2e                	je     800eb4 <pgfault+0x40>
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	c1 ea 16             	shr    $0x16,%edx
  800e8b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e92:	f6 c2 01             	test   $0x1,%dl
  800e95:	74 1d                	je     800eb4 <pgfault+0x40>
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 0c             	shr    $0xc,%edx
  800e9c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ea3:	f6 c1 01             	test   $0x1,%cl
  800ea6:	74 0c                	je     800eb4 <pgfault+0x40>
  800ea8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eaf:	f6 c6 08             	test   $0x8,%dh
  800eb2:	75 14                	jne    800ec8 <pgfault+0x54>
        panic("Not copy-on-write\n");
  800eb4:	83 ec 04             	sub    $0x4,%esp
  800eb7:	68 4a 31 80 00       	push   $0x80314a
  800ebc:	6a 1d                	push   $0x1d
  800ebe:	68 5d 31 80 00       	push   $0x80315d
  800ec3:	e8 1a f3 ff ff       	call   8001e2 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	// LAB 4: Your code here.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800ec8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ecd:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP,  PTE_W | PTE_P | PTE_U) < 0)
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	6a 07                	push   $0x7
  800ed4:	68 00 f0 7f 00       	push   $0x7ff000
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 63 fd ff ff       	call   800c43 <sys_page_alloc>
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	79 14                	jns    800efb <pgfault+0x87>
		panic("page alloc failed \n");
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	68 68 31 80 00       	push   $0x803168
  800eef:	6a 28                	push   $0x28
  800ef1:	68 5d 31 80 00       	push   $0x80315d
  800ef6:	e8 e7 f2 ff ff       	call   8001e2 <_panic>
	memcpy(PFTEMP,addr, PGSIZE);
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	68 00 10 00 00       	push   $0x1000
  800f03:	53                   	push   %ebx
  800f04:	68 00 f0 7f 00       	push   $0x7ff000
  800f09:	e8 2c fb ff ff       	call   800a3a <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P) < 0)
  800f0e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f15:	53                   	push   %ebx
  800f16:	6a 00                	push   $0x0
  800f18:	68 00 f0 7f 00       	push   $0x7ff000
  800f1d:	6a 00                	push   $0x0
  800f1f:	e8 62 fd ff ff       	call   800c86 <sys_page_map>
  800f24:	83 c4 20             	add    $0x20,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 14                	jns    800f3f <pgfault+0xcb>
        panic("page map failed \n");
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 7c 31 80 00       	push   $0x80317c
  800f33:	6a 2b                	push   $0x2b
  800f35:	68 5d 31 80 00       	push   $0x80315d
  800f3a:	e8 a3 f2 ff ff       	call   8001e2 <_panic>
    if (sys_page_unmap(0, PFTEMP) < 0)
  800f3f:	83 ec 08             	sub    $0x8,%esp
  800f42:	68 00 f0 7f 00       	push   $0x7ff000
  800f47:	6a 00                	push   $0x0
  800f49:	e8 7a fd ff ff       	call   800cc8 <sys_page_unmap>
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	79 14                	jns    800f69 <pgfault+0xf5>
        panic("page unmap failed\n");
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	68 8e 31 80 00       	push   $0x80318e
  800f5d:	6a 2d                	push   $0x2d
  800f5f:	68 5d 31 80 00       	push   $0x80315d
  800f64:	e8 79 f2 ff ff       	call   8001e2 <_panic>
	
	//panic("pgfault not implemented");
}
  800f69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
    uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	 
	set_pgfault_handler(pgfault);
  800f77:	68 74 0e 80 00       	push   $0x800e74
  800f7c:	e8 50 19 00 00       	call   8028d1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f81:	b8 07 00 00 00       	mov    $0x7,%eax
  800f86:	cd 30                	int    $0x30
  800f88:	89 c7                	mov    %eax,%edi
  800f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    envid = sys_exofork();
	if (envid < 0)
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	79 12                	jns    800fa6 <fork+0x38>
		panic("sys_exofork: %e \n", envid);
  800f94:	50                   	push   %eax
  800f95:	68 a1 31 80 00       	push   $0x8031a1
  800f9a:	6a 7a                	push   $0x7a
  800f9c:	68 5d 31 80 00       	push   $0x80315d
  800fa1:	e8 3c f2 ff ff       	call   8001e2 <_panic>
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800fab:	85 c0                	test   %eax,%eax
  800fad:	75 21                	jne    800fd0 <fork+0x62>
		thisenv = &envs[ENVX(sys_getenvid())];
  800faf:	e8 51 fc ff ff       	call   800c05 <sys_getenvid>
  800fb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fbc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc1:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	e9 91 01 00 00       	jmp    801161 <fork+0x1f3>
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	c1 e8 16             	shr    $0x16,%eax
  800fd5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	0f 84 06 01 00 00    	je     8010ea <fork+0x17c>
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
  800fe9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff0:	f6 c2 01             	test   $0x1,%dl
  800ff3:	0f 84 f1 00 00 00    	je     8010ea <fork+0x17c>
  800ff9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801000:	f6 c2 04             	test   $0x4,%dl
  801003:	0f 84 e1 00 00 00    	je     8010ea <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
    pte_t ptEntry;
    pde_t pdEntry;
    void *addr = (void *)(pn * PGSIZE);
  801009:	89 c6                	mov    %eax,%esi
  80100b:	c1 e6 0c             	shl    $0xc,%esi
	// LAB 4: Your code here.
    pdEntry = uvpd[PDX(addr)];
  80100e:	89 f2                	mov    %esi,%edx
  801010:	c1 ea 16             	shr    $0x16,%edx
  801013:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    ptEntry = uvpt[pn]; 
  80101a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
    
    if (ptEntry & PTE_SHARE) {
  801021:	f6 c6 04             	test   $0x4,%dh
  801024:	74 39                	je     80105f <fork+0xf1>
    	// Share this page with parent
        if ((r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL)) < 0)
  801026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	25 07 0e 00 00       	and    $0xe07,%eax
  801035:	50                   	push   %eax
  801036:	56                   	push   %esi
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	56                   	push   %esi
  80103b:	6a 00                	push   $0x0
  80103d:	e8 44 fc ff ff       	call   800c86 <sys_page_map>
  801042:	83 c4 20             	add    $0x20,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	0f 89 9d 00 00 00    	jns    8010ea <fork+0x17c>
        	panic("duppage: sys_page_map page to be shared %e \n", r);
  80104d:	50                   	push   %eax
  80104e:	68 f8 31 80 00       	push   $0x8031f8
  801053:	6a 4b                	push   $0x4b
  801055:	68 5d 31 80 00       	push   $0x80315d
  80105a:	e8 83 f1 ff ff       	call   8001e2 <_panic>
    }
    else if (ptEntry & PTE_W || ptEntry & PTE_COW) {
  80105f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801065:	74 59                	je     8010c0 <fork+0x152>
    	// Map to new env COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	68 05 08 00 00       	push   $0x805
  80106f:	56                   	push   %esi
  801070:	ff 75 e4             	pushl  -0x1c(%ebp)
  801073:	56                   	push   %esi
  801074:	6a 00                	push   $0x0
  801076:	e8 0b fc ff ff       	call   800c86 <sys_page_map>
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	79 12                	jns    801094 <fork+0x126>
        	panic("duppage: sys_page_map to new env %e \n", r);
  801082:	50                   	push   %eax
  801083:	68 28 32 80 00       	push   $0x803228
  801088:	6a 50                	push   $0x50
  80108a:	68 5d 31 80 00       	push   $0x80315d
  80108f:	e8 4e f1 ff ff       	call   8001e2 <_panic>
        // Remap our own to COW
        if ((r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_U | PTE_P)) < 0)
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	68 05 08 00 00       	push   $0x805
  80109c:	56                   	push   %esi
  80109d:	6a 00                	push   $0x0
  80109f:	56                   	push   %esi
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 df fb ff ff       	call   800c86 <sys_page_map>
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	79 3c                	jns    8010ea <fork+0x17c>
            panic("duppage: sys_page_map for remap %e \n", r);
  8010ae:	50                   	push   %eax
  8010af:	68 50 32 80 00       	push   $0x803250
  8010b4:	6a 53                	push   $0x53
  8010b6:	68 5d 31 80 00       	push   $0x80315d
  8010bb:	e8 22 f1 ff ff       	call   8001e2 <_panic>
    }
    else {
    	// Just directly map pages that are present but not W or COW
        if ((r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U)) < 0)
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	6a 05                	push   $0x5
  8010c5:	56                   	push   %esi
  8010c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c9:	56                   	push   %esi
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 b5 fb ff ff       	call   800c86 <sys_page_map>
  8010d1:	83 c4 20             	add    $0x20,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	79 12                	jns    8010ea <fork+0x17c>
        	panic("duppage: sys_page_map to new env PTE_P %e \n", r);
  8010d8:	50                   	push   %eax
  8010d9:	68 78 32 80 00       	push   $0x803278
  8010de:	6a 58                	push   $0x58
  8010e0:	68 5d 31 80 00       	push   $0x80315d
  8010e5:	e8 f8 f0 ff ff       	call   8001e2 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  8010ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010f6:	0f 85 d4 fe ff ff    	jne    800fd0 <fork+0x62>
    	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P ) && (uvpt[PGNUM(addr)] & PTE_U )) {
            duppage(envid, PGNUM(addr));
        }
	}
	
	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W| PTE_P) < 0)
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	6a 07                	push   $0x7
  801101:	68 00 f0 bf ee       	push   $0xeebff000
  801106:	57                   	push   %edi
  801107:	e8 37 fb ff ff       	call   800c43 <sys_page_alloc>
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 17                	jns    80112a <fork+0x1bc>
        panic("page alloc failed\n");
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	68 b3 31 80 00       	push   $0x8031b3
  80111b:	68 87 00 00 00       	push   $0x87
  801120:	68 5d 31 80 00       	push   $0x80315d
  801125:	e8 b8 f0 ff ff       	call   8001e2 <_panic>
	
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	68 40 29 80 00       	push   $0x802940
  801132:	57                   	push   %edi
  801133:	e8 56 fc ff ff       	call   800d8e <sys_env_set_pgfault_upcall>
	
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801138:	83 c4 08             	add    $0x8,%esp
  80113b:	6a 02                	push   $0x2
  80113d:	57                   	push   %edi
  80113e:	e8 c7 fb ff ff       	call   800d0a <sys_env_set_status>
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	79 15                	jns    80115f <fork+0x1f1>
		panic("sys_env_set_status: %e \n", r);
  80114a:	50                   	push   %eax
  80114b:	68 c6 31 80 00       	push   $0x8031c6
  801150:	68 8c 00 00 00       	push   $0x8c
  801155:	68 5d 31 80 00       	push   $0x80315d
  80115a:	e8 83 f0 ff ff       	call   8001e2 <_panic>

	return envid;
  80115f:	89 f8                	mov    %edi,%eax
	
	
	//panic("fork not implemented");
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <sfork>:

// Challenge!
int
sfork(void)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80116f:	68 df 31 80 00       	push   $0x8031df
  801174:	68 98 00 00 00       	push   $0x98
  801179:	68 5d 31 80 00       	push   $0x80315d
  80117e:	e8 5f f0 ff ff       	call   8001e2 <_panic>

00801183 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	05 00 00 00 30       	add    $0x30000000,%eax
  80118e:	c1 e8 0c             	shr    $0xc,%eax
}
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	05 00 00 00 30       	add    $0x30000000,%eax
  80119e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011a3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 16             	shr    $0x16,%edx
  8011ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	74 11                	je     8011d7 <fd_alloc+0x2d>
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	c1 ea 0c             	shr    $0xc,%edx
  8011cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	75 09                	jne    8011e0 <fd_alloc+0x36>
			*fd_store = fd;
  8011d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011de:	eb 17                	jmp    8011f7 <fd_alloc+0x4d>
  8011e0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ea:	75 c9                	jne    8011b5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ec:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011f2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ff:	83 f8 1f             	cmp    $0x1f,%eax
  801202:	77 36                	ja     80123a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801204:	c1 e0 0c             	shl    $0xc,%eax
  801207:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	c1 ea 16             	shr    $0x16,%edx
  801211:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 24                	je     801241 <fd_lookup+0x48>
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 0c             	shr    $0xc,%edx
  801222:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	74 1a                	je     801248 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801231:	89 02                	mov    %eax,(%edx)
	return 0;
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	eb 13                	jmp    80124d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123f:	eb 0c                	jmp    80124d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801246:	eb 05                	jmp    80124d <fd_lookup+0x54>
  801248:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801258:	ba 20 33 80 00       	mov    $0x803320,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80125d:	eb 13                	jmp    801272 <dev_lookup+0x23>
  80125f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801262:	39 08                	cmp    %ecx,(%eax)
  801264:	75 0c                	jne    801272 <dev_lookup+0x23>
			*dev = devtab[i];
  801266:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801269:	89 01                	mov    %eax,(%ecx)
			return 0;
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	eb 2e                	jmp    8012a0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801272:	8b 02                	mov    (%edx),%eax
  801274:	85 c0                	test   %eax,%eax
  801276:	75 e7                	jne    80125f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801278:	a1 08 50 80 00       	mov    0x805008,%eax
  80127d:	8b 40 48             	mov    0x48(%eax),%eax
  801280:	83 ec 04             	sub    $0x4,%esp
  801283:	51                   	push   %ecx
  801284:	50                   	push   %eax
  801285:	68 a4 32 80 00       	push   $0x8032a4
  80128a:	e8 2c f0 ff ff       	call   8002bb <cprintf>
	*dev = 0;
  80128f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801292:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 10             	sub    $0x10,%esp
  8012aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ba:	c1 e8 0c             	shr    $0xc,%eax
  8012bd:	50                   	push   %eax
  8012be:	e8 36 ff ff ff       	call   8011f9 <fd_lookup>
  8012c3:	83 c4 08             	add    $0x8,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 05                	js     8012cf <fd_close+0x2d>
	    || fd != fd2)
  8012ca:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012cd:	74 0c                	je     8012db <fd_close+0x39>
		return (must_exist ? r : 0);
  8012cf:	84 db                	test   %bl,%bl
  8012d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d6:	0f 44 c2             	cmove  %edx,%eax
  8012d9:	eb 41                	jmp    80131c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 36                	pushl  (%esi)
  8012e4:	e8 66 ff ff ff       	call   80124f <dev_lookup>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 1a                	js     80130c <fd_close+0x6a>
		if (dev->dev_close)
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	74 0b                	je     80130c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	56                   	push   %esi
  801305:	ff d0                	call   *%eax
  801307:	89 c3                	mov    %eax,%ebx
  801309:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	56                   	push   %esi
  801310:	6a 00                	push   $0x0
  801312:	e8 b1 f9 ff ff       	call   800cc8 <sys_page_unmap>
	return r;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	89 d8                	mov    %ebx,%eax
}
  80131c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	pushl  0x8(%ebp)
  801330:	e8 c4 fe ff ff       	call   8011f9 <fd_lookup>
  801335:	83 c4 08             	add    $0x8,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 10                	js     80134c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	6a 01                	push   $0x1
  801341:	ff 75 f4             	pushl  -0xc(%ebp)
  801344:	e8 59 ff ff ff       	call   8012a2 <fd_close>
  801349:	83 c4 10             	add    $0x10,%esp
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <close_all>:

void
close_all(void)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	53                   	push   %ebx
  801352:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801355:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	53                   	push   %ebx
  80135e:	e8 c0 ff ff ff       	call   801323 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801363:	83 c3 01             	add    $0x1,%ebx
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	83 fb 20             	cmp    $0x20,%ebx
  80136c:	75 ec                	jne    80135a <close_all+0xc>
		close(i);
}
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	57                   	push   %edi
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 2c             	sub    $0x2c,%esp
  80137c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801382:	50                   	push   %eax
  801383:	ff 75 08             	pushl  0x8(%ebp)
  801386:	e8 6e fe ff ff       	call   8011f9 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	0f 88 c1 00 00 00    	js     801457 <dup+0xe4>
		return r;
	close(newfdnum);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	56                   	push   %esi
  80139a:	e8 84 ff ff ff       	call   801323 <close>

	newfd = INDEX2FD(newfdnum);
  80139f:	89 f3                	mov    %esi,%ebx
  8013a1:	c1 e3 0c             	shl    $0xc,%ebx
  8013a4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013aa:	83 c4 04             	add    $0x4,%esp
  8013ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013b0:	e8 de fd ff ff       	call   801193 <fd2data>
  8013b5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b7:	89 1c 24             	mov    %ebx,(%esp)
  8013ba:	e8 d4 fd ff ff       	call   801193 <fd2data>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c5:	89 f8                	mov    %edi,%eax
  8013c7:	c1 e8 16             	shr    $0x16,%eax
  8013ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d1:	a8 01                	test   $0x1,%al
  8013d3:	74 37                	je     80140c <dup+0x99>
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	c1 e8 0c             	shr    $0xc,%eax
  8013da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e1:	f6 c2 01             	test   $0x1,%dl
  8013e4:	74 26                	je     80140c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f9:	6a 00                	push   $0x0
  8013fb:	57                   	push   %edi
  8013fc:	6a 00                	push   $0x0
  8013fe:	e8 83 f8 ff ff       	call   800c86 <sys_page_map>
  801403:	89 c7                	mov    %eax,%edi
  801405:	83 c4 20             	add    $0x20,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 2e                	js     80143a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80140f:	89 d0                	mov    %edx,%eax
  801411:	c1 e8 0c             	shr    $0xc,%eax
  801414:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141b:	83 ec 0c             	sub    $0xc,%esp
  80141e:	25 07 0e 00 00       	and    $0xe07,%eax
  801423:	50                   	push   %eax
  801424:	53                   	push   %ebx
  801425:	6a 00                	push   $0x0
  801427:	52                   	push   %edx
  801428:	6a 00                	push   $0x0
  80142a:	e8 57 f8 ff ff       	call   800c86 <sys_page_map>
  80142f:	89 c7                	mov    %eax,%edi
  801431:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801434:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801436:	85 ff                	test   %edi,%edi
  801438:	79 1d                	jns    801457 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	53                   	push   %ebx
  80143e:	6a 00                	push   $0x0
  801440:	e8 83 f8 ff ff       	call   800cc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144b:	6a 00                	push   $0x0
  80144d:	e8 76 f8 ff ff       	call   800cc8 <sys_page_unmap>
	return r;
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	89 f8                	mov    %edi,%eax
}
  801457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    

0080145f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	53                   	push   %ebx
  801463:	83 ec 14             	sub    $0x14,%esp
  801466:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801469:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	53                   	push   %ebx
  80146e:	e8 86 fd ff ff       	call   8011f9 <fd_lookup>
  801473:	83 c4 08             	add    $0x8,%esp
  801476:	89 c2                	mov    %eax,%edx
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 6d                	js     8014e9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	ff 30                	pushl  (%eax)
  801488:	e8 c2 fd ff ff       	call   80124f <dev_lookup>
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 4c                	js     8014e0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801494:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801497:	8b 42 08             	mov    0x8(%edx),%eax
  80149a:	83 e0 03             	and    $0x3,%eax
  80149d:	83 f8 01             	cmp    $0x1,%eax
  8014a0:	75 21                	jne    8014c3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a2:	a1 08 50 80 00       	mov    0x805008,%eax
  8014a7:	8b 40 48             	mov    0x48(%eax),%eax
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	50                   	push   %eax
  8014af:	68 e5 32 80 00       	push   $0x8032e5
  8014b4:	e8 02 ee ff ff       	call   8002bb <cprintf>
		return -E_INVAL;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c1:	eb 26                	jmp    8014e9 <read+0x8a>
	}
	if (!dev->dev_read)
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c6:	8b 40 08             	mov    0x8(%eax),%eax
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	74 17                	je     8014e4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	ff 75 10             	pushl  0x10(%ebp)
  8014d3:	ff 75 0c             	pushl  0xc(%ebp)
  8014d6:	52                   	push   %edx
  8014d7:	ff d0                	call   *%eax
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb 09                	jmp    8014e9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	eb 05                	jmp    8014e9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e9:	89 d0                	mov    %edx,%eax
  8014eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	57                   	push   %edi
  8014f4:	56                   	push   %esi
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801504:	eb 21                	jmp    801527 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801506:	83 ec 04             	sub    $0x4,%esp
  801509:	89 f0                	mov    %esi,%eax
  80150b:	29 d8                	sub    %ebx,%eax
  80150d:	50                   	push   %eax
  80150e:	89 d8                	mov    %ebx,%eax
  801510:	03 45 0c             	add    0xc(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	57                   	push   %edi
  801515:	e8 45 ff ff ff       	call   80145f <read>
		if (m < 0)
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 10                	js     801531 <readn+0x41>
			return m;
		if (m == 0)
  801521:	85 c0                	test   %eax,%eax
  801523:	74 0a                	je     80152f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801525:	01 c3                	add    %eax,%ebx
  801527:	39 f3                	cmp    %esi,%ebx
  801529:	72 db                	jb     801506 <readn+0x16>
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	eb 02                	jmp    801531 <readn+0x41>
  80152f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	53                   	push   %ebx
  80153d:	83 ec 14             	sub    $0x14,%esp
  801540:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801543:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	53                   	push   %ebx
  801548:	e8 ac fc ff ff       	call   8011f9 <fd_lookup>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	89 c2                	mov    %eax,%edx
  801552:	85 c0                	test   %eax,%eax
  801554:	78 68                	js     8015be <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	ff 30                	pushl  (%eax)
  801562:	e8 e8 fc ff ff       	call   80124f <dev_lookup>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 47                	js     8015b5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801575:	75 21                	jne    801598 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801577:	a1 08 50 80 00       	mov    0x805008,%eax
  80157c:	8b 40 48             	mov    0x48(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	50                   	push   %eax
  801584:	68 01 33 80 00       	push   $0x803301
  801589:	e8 2d ed ff ff       	call   8002bb <cprintf>
		return -E_INVAL;
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801596:	eb 26                	jmp    8015be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801598:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159b:	8b 52 0c             	mov    0xc(%edx),%edx
  80159e:	85 d2                	test   %edx,%edx
  8015a0:	74 17                	je     8015b9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	ff d2                	call   *%edx
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 09                	jmp    8015be <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	eb 05                	jmp    8015be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	ff 75 08             	pushl  0x8(%ebp)
  8015d2:	e8 22 fc ff ff       	call   8011f9 <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 0e                	js     8015ec <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 14             	sub    $0x14,%esp
  8015f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	53                   	push   %ebx
  8015fd:	e8 f7 fb ff ff       	call   8011f9 <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	89 c2                	mov    %eax,%edx
  801607:	85 c0                	test   %eax,%eax
  801609:	78 65                	js     801670 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 33 fc ff ff       	call   80124f <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 44                	js     801667 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162a:	75 21                	jne    80164d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80162c:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801631:	8b 40 48             	mov    0x48(%eax),%eax
  801634:	83 ec 04             	sub    $0x4,%esp
  801637:	53                   	push   %ebx
  801638:	50                   	push   %eax
  801639:	68 c4 32 80 00       	push   $0x8032c4
  80163e:	e8 78 ec ff ff       	call   8002bb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164b:	eb 23                	jmp    801670 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801650:	8b 52 18             	mov    0x18(%edx),%edx
  801653:	85 d2                	test   %edx,%edx
  801655:	74 14                	je     80166b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	50                   	push   %eax
  80165e:	ff d2                	call   *%edx
  801660:	89 c2                	mov    %eax,%edx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 09                	jmp    801670 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801667:	89 c2                	mov    %eax,%edx
  801669:	eb 05                	jmp    801670 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80166b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801670:	89 d0                	mov    %edx,%eax
  801672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 14             	sub    $0x14,%esp
  80167e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 6c fb ff ff       	call   8011f9 <fd_lookup>
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	89 c2                	mov    %eax,%edx
  801692:	85 c0                	test   %eax,%eax
  801694:	78 58                	js     8016ee <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169c:	50                   	push   %eax
  80169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a0:	ff 30                	pushl  (%eax)
  8016a2:	e8 a8 fb ff ff       	call   80124f <dev_lookup>
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 37                	js     8016e5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016b5:	74 32                	je     8016e9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c1:	00 00 00 
	stat->st_isdir = 0;
  8016c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016cb:	00 00 00 
	stat->st_dev = dev;
  8016ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8016db:	ff 50 14             	call   *0x14(%eax)
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	eb 09                	jmp    8016ee <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	eb 05                	jmp    8016ee <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ee:	89 d0                	mov    %edx,%eax
  8016f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f3:	c9                   	leave  
  8016f4:	c3                   	ret    

008016f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	6a 00                	push   $0x0
  8016ff:	ff 75 08             	pushl  0x8(%ebp)
  801702:	e8 e7 01 00 00       	call   8018ee <open>
  801707:	89 c3                	mov    %eax,%ebx
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 1b                	js     80172b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	50                   	push   %eax
  801717:	e8 5b ff ff ff       	call   801677 <fstat>
  80171c:	89 c6                	mov    %eax,%esi
	close(fd);
  80171e:	89 1c 24             	mov    %ebx,(%esp)
  801721:	e8 fd fb ff ff       	call   801323 <close>
	return r;
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	89 f0                	mov    %esi,%eax
}
  80172b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	89 c6                	mov    %eax,%esi
  801739:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80173b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801742:	75 12                	jne    801756 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	6a 01                	push   $0x1
  801749:	e8 d7 12 00 00       	call   802a25 <ipc_find_env>
  80174e:	a3 00 50 80 00       	mov    %eax,0x805000
  801753:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801756:	6a 07                	push   $0x7
  801758:	68 00 60 80 00       	push   $0x806000
  80175d:	56                   	push   %esi
  80175e:	ff 35 00 50 80 00    	pushl  0x805000
  801764:	e8 68 12 00 00       	call   8029d1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801769:	83 c4 0c             	add    $0xc,%esp
  80176c:	6a 00                	push   $0x0
  80176e:	53                   	push   %ebx
  80176f:	6a 00                	push   $0x0
  801771:	e8 ee 11 00 00       	call   802964 <ipc_recv>
}
  801776:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	8b 40 0c             	mov    0xc(%eax),%eax
  801789:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80178e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801791:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a0:	e8 8d ff ff ff       	call   801732 <fsipc>
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b3:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c2:	e8 6b ff ff ff       	call   801732 <fsipc>
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e8:	e8 45 ff ff ff       	call   801732 <fsipc>
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 2c                	js     80181d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	68 00 60 80 00       	push   $0x806000
  8017f9:	53                   	push   %ebx
  8017fa:	e8 41 f0 ff ff       	call   800840 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ff:	a1 80 60 80 00       	mov    0x806080,%eax
  801804:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80180a:	a1 84 60 80 00       	mov    0x806084,%eax
  80180f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80182c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801831:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801836:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  801839:	53                   	push   %ebx
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	68 08 60 80 00       	push   $0x806008
  801842:	e8 8b f1 ff ff       	call   8009d2 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	8b 40 0c             	mov    0xc(%eax),%eax
  80184d:	a3 00 60 80 00       	mov    %eax,0x806000
 	fsipcbuf.write.req_n = n;
  801852:	89 1d 04 60 80 00    	mov    %ebx,0x806004

 	return fsipc(FSREQ_WRITE, NULL);
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 04 00 00 00       	mov    $0x4,%eax
  801862:	e8 cb fe ff ff       	call   801732 <fsipc>
	//panic("devfile_write not implemented");
}
  801867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801874:	8b 45 08             	mov    0x8(%ebp),%eax
  801877:	8b 40 0c             	mov    0xc(%eax),%eax
  80187a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80187f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 03 00 00 00       	mov    $0x3,%eax
  80188f:	e8 9e fe ff ff       	call   801732 <fsipc>
  801894:	89 c3                	mov    %eax,%ebx
  801896:	85 c0                	test   %eax,%eax
  801898:	78 4b                	js     8018e5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80189a:	39 c6                	cmp    %eax,%esi
  80189c:	73 16                	jae    8018b4 <devfile_read+0x48>
  80189e:	68 34 33 80 00       	push   $0x803334
  8018a3:	68 3b 33 80 00       	push   $0x80333b
  8018a8:	6a 7c                	push   $0x7c
  8018aa:	68 50 33 80 00       	push   $0x803350
  8018af:	e8 2e e9 ff ff       	call   8001e2 <_panic>
	assert(r <= PGSIZE);
  8018b4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b9:	7e 16                	jle    8018d1 <devfile_read+0x65>
  8018bb:	68 5b 33 80 00       	push   $0x80335b
  8018c0:	68 3b 33 80 00       	push   $0x80333b
  8018c5:	6a 7d                	push   $0x7d
  8018c7:	68 50 33 80 00       	push   $0x803350
  8018cc:	e8 11 e9 ff ff       	call   8001e2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d1:	83 ec 04             	sub    $0x4,%esp
  8018d4:	50                   	push   %eax
  8018d5:	68 00 60 80 00       	push   $0x806000
  8018da:	ff 75 0c             	pushl  0xc(%ebp)
  8018dd:	e8 f0 f0 ff ff       	call   8009d2 <memmove>
	return r;
  8018e2:	83 c4 10             	add    $0x10,%esp
}
  8018e5:	89 d8                	mov    %ebx,%eax
  8018e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 20             	sub    $0x20,%esp
  8018f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f8:	53                   	push   %ebx
  8018f9:	e8 09 ef ff ff       	call   800807 <strlen>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801906:	7f 67                	jg     80196f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190e:	50                   	push   %eax
  80190f:	e8 96 f8 ff ff       	call   8011aa <fd_alloc>
  801914:	83 c4 10             	add    $0x10,%esp
		return r;
  801917:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 57                	js     801974 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	53                   	push   %ebx
  801921:	68 00 60 80 00       	push   $0x806000
  801926:	e8 15 ef ff ff       	call   800840 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801933:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801936:	b8 01 00 00 00       	mov    $0x1,%eax
  80193b:	e8 f2 fd ff ff       	call   801732 <fsipc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	79 14                	jns    80195d <open+0x6f>
		fd_close(fd, 0);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	6a 00                	push   $0x0
  80194e:	ff 75 f4             	pushl  -0xc(%ebp)
  801951:	e8 4c f9 ff ff       	call   8012a2 <fd_close>
		return r;
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	89 da                	mov    %ebx,%edx
  80195b:	eb 17                	jmp    801974 <open+0x86>
	}

	return fd2num(fd);
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	ff 75 f4             	pushl  -0xc(%ebp)
  801963:	e8 1b f8 ff ff       	call   801183 <fd2num>
  801968:	89 c2                	mov    %eax,%edx
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb 05                	jmp    801974 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801974:	89 d0                	mov    %edx,%eax
  801976:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801981:	ba 00 00 00 00       	mov    $0x0,%edx
  801986:	b8 08 00 00 00       	mov    $0x8,%eax
  80198b:	e8 a2 fd ff ff       	call   801732 <fsipc>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	57                   	push   %edi
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
  801998:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80199e:	6a 00                	push   $0x0
  8019a0:	ff 75 08             	pushl  0x8(%ebp)
  8019a3:	e8 46 ff ff ff       	call   8018ee <open>
  8019a8:	89 c7                	mov    %eax,%edi
  8019aa:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	0f 88 a4 04 00 00    	js     801e5f <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019bb:	83 ec 04             	sub    $0x4,%esp
  8019be:	68 00 02 00 00       	push   $0x200
  8019c3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019c9:	50                   	push   %eax
  8019ca:	57                   	push   %edi
  8019cb:	e8 20 fb ff ff       	call   8014f0 <readn>
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019d8:	75 0c                	jne    8019e6 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019da:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019e1:	45 4c 46 
  8019e4:	74 33                	je     801a19 <spawn+0x87>
		close(fd);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019ef:	e8 2f f9 ff ff       	call   801323 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019f4:	83 c4 0c             	add    $0xc,%esp
  8019f7:	68 7f 45 4c 46       	push   $0x464c457f
  8019fc:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a02:	68 67 33 80 00       	push   $0x803367
  801a07:	e8 af e8 ff ff       	call   8002bb <cprintf>
		return -E_NOT_EXEC;
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a14:	e9 a6 04 00 00       	jmp    801ebf <spawn+0x52d>
  801a19:	b8 07 00 00 00       	mov    $0x7,%eax
  801a1e:	cd 30                	int    $0x30
  801a20:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a26:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	0f 88 33 04 00 00    	js     801e67 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a34:	89 c6                	mov    %eax,%esi
  801a36:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a3c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a3f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a45:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a4b:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a52:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a58:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a63:	be 00 00 00 00       	mov    $0x0,%esi
  801a68:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a6b:	eb 13                	jmp    801a80 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	50                   	push   %eax
  801a71:	e8 91 ed ff ff       	call   800807 <strlen>
  801a76:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a7a:	83 c3 01             	add    $0x1,%ebx
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a87:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	75 df                	jne    801a6d <spawn+0xdb>
  801a8e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a94:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a9a:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a9f:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801aa1:	89 fa                	mov    %edi,%edx
  801aa3:	83 e2 fc             	and    $0xfffffffc,%edx
  801aa6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801aad:	29 c2                	sub    %eax,%edx
  801aaf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ab5:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ab8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801abd:	0f 86 b4 03 00 00    	jbe    801e77 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ac3:	83 ec 04             	sub    $0x4,%esp
  801ac6:	6a 07                	push   $0x7
  801ac8:	68 00 00 40 00       	push   $0x400000
  801acd:	6a 00                	push   $0x0
  801acf:	e8 6f f1 ff ff       	call   800c43 <sys_page_alloc>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 9f 03 00 00    	js     801e7e <spawn+0x4ec>
  801adf:	be 00 00 00 00       	mov    $0x0,%esi
  801ae4:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aed:	eb 30                	jmp    801b1f <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801aef:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801af5:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801afb:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b04:	57                   	push   %edi
  801b05:	e8 36 ed ff ff       	call   800840 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b0a:	83 c4 04             	add    $0x4,%esp
  801b0d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b10:	e8 f2 ec ff ff       	call   800807 <strlen>
  801b15:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b19:	83 c6 01             	add    $0x1,%esi
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b25:	7f c8                	jg     801aef <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b27:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b2d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b33:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b3a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b40:	74 19                	je     801b5b <spawn+0x1c9>
  801b42:	68 dc 33 80 00       	push   $0x8033dc
  801b47:	68 3b 33 80 00       	push   $0x80333b
  801b4c:	68 f1 00 00 00       	push   $0xf1
  801b51:	68 81 33 80 00       	push   $0x803381
  801b56:	e8 87 e6 ff ff       	call   8001e2 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b5b:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b61:	89 f8                	mov    %edi,%eax
  801b63:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b68:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b6b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b71:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b74:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b7a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	6a 07                	push   $0x7
  801b85:	68 00 d0 bf ee       	push   $0xeebfd000
  801b8a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b90:	68 00 00 40 00       	push   $0x400000
  801b95:	6a 00                	push   $0x0
  801b97:	e8 ea f0 ff ff       	call   800c86 <sys_page_map>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	83 c4 20             	add    $0x20,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	0f 88 04 03 00 00    	js     801ead <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ba9:	83 ec 08             	sub    $0x8,%esp
  801bac:	68 00 00 40 00       	push   $0x400000
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 10 f1 ff ff       	call   800cc8 <sys_page_unmap>
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 e8 02 00 00    	js     801ead <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bc5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bcb:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bd2:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bd8:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bdf:	00 00 00 
  801be2:	e9 88 01 00 00       	jmp    801d6f <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801be7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bed:	83 38 01             	cmpl   $0x1,(%eax)
  801bf0:	0f 85 6b 01 00 00    	jne    801d61 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bf6:	89 c7                	mov    %eax,%edi
  801bf8:	8b 40 18             	mov    0x18(%eax),%eax
  801bfb:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c01:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c04:	83 f8 01             	cmp    $0x1,%eax
  801c07:	19 c0                	sbb    %eax,%eax
  801c09:	83 e0 fe             	and    $0xfffffffe,%eax
  801c0c:	83 c0 07             	add    $0x7,%eax
  801c0f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c15:	89 f8                	mov    %edi,%eax
  801c17:	8b 7f 04             	mov    0x4(%edi),%edi
  801c1a:	89 f9                	mov    %edi,%ecx
  801c1c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c22:	8b 78 10             	mov    0x10(%eax),%edi
  801c25:	8b 50 14             	mov    0x14(%eax),%edx
  801c28:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c2e:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c31:	89 f0                	mov    %esi,%eax
  801c33:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c38:	74 14                	je     801c4e <spawn+0x2bc>
		va -= i;
  801c3a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c3c:	01 c2                	add    %eax,%edx
  801c3e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c44:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c46:	29 c1                	sub    %eax,%ecx
  801c48:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c53:	e9 f7 00 00 00       	jmp    801d4f <spawn+0x3bd>
		if (i >= filesz) {
  801c58:	39 df                	cmp    %ebx,%edi
  801c5a:	77 27                	ja     801c83 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c5c:	83 ec 04             	sub    $0x4,%esp
  801c5f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c65:	56                   	push   %esi
  801c66:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c6c:	e8 d2 ef ff ff       	call   800c43 <sys_page_alloc>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	0f 89 c7 00 00 00    	jns    801d43 <spawn+0x3b1>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	e9 09 02 00 00       	jmp    801e8c <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c83:	83 ec 04             	sub    $0x4,%esp
  801c86:	6a 07                	push   $0x7
  801c88:	68 00 00 40 00       	push   $0x400000
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 af ef ff ff       	call   800c43 <sys_page_alloc>
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 88 e3 01 00 00    	js     801e82 <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ca8:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cae:	50                   	push   %eax
  801caf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cb5:	e8 0b f9 ff ff       	call   8015c5 <seek>
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	0f 88 c1 01 00 00    	js     801e86 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cc5:	83 ec 04             	sub    $0x4,%esp
  801cc8:	89 f8                	mov    %edi,%eax
  801cca:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cd0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cd5:	ba 00 10 00 00       	mov    $0x1000,%edx
  801cda:	0f 47 c2             	cmova  %edx,%eax
  801cdd:	50                   	push   %eax
  801cde:	68 00 00 40 00       	push   $0x400000
  801ce3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ce9:	e8 02 f8 ff ff       	call   8014f0 <readn>
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	0f 88 91 01 00 00    	js     801e8a <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d02:	56                   	push   %esi
  801d03:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d09:	68 00 00 40 00       	push   $0x400000
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 71 ef ff ff       	call   800c86 <sys_page_map>
  801d15:	83 c4 20             	add    $0x20,%esp
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	79 15                	jns    801d31 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801d1c:	50                   	push   %eax
  801d1d:	68 8d 33 80 00       	push   $0x80338d
  801d22:	68 24 01 00 00       	push   $0x124
  801d27:	68 81 33 80 00       	push   $0x803381
  801d2c:	e8 b1 e4 ff ff       	call   8001e2 <_panic>
			sys_page_unmap(0, UTEMP);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	68 00 00 40 00       	push   $0x400000
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 88 ef ff ff       	call   800cc8 <sys_page_unmap>
  801d40:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d43:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d49:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d4f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d55:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d5b:	0f 87 f7 fe ff ff    	ja     801c58 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d61:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d68:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d6f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d76:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d7c:	0f 8c 65 fe ff ff    	jl     801be7 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d8b:	e8 93 f5 ff ff       	call   801323 <close>
  801d90:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d98:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
 	{
    	if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)) {
  801d9e:	89 d8                	mov    %ebx,%eax
  801da0:	c1 e8 16             	shr    $0x16,%eax
  801da3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801daa:	a8 01                	test   $0x1,%al
  801dac:	74 46                	je     801df4 <spawn+0x462>
  801dae:	89 d8                	mov    %ebx,%eax
  801db0:	c1 e8 0c             	shr    $0xc,%eax
  801db3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dba:	f6 c2 01             	test   $0x1,%dl
  801dbd:	74 35                	je     801df4 <spawn+0x462>
  801dbf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dc6:	f6 c2 04             	test   $0x4,%dl
  801dc9:	74 29                	je     801df4 <spawn+0x462>
  801dcb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dd2:	f6 c6 04             	test   $0x4,%dh
  801dd5:	74 1d                	je     801df4 <spawn+0x462>
        	sys_page_map(0, (void*)i, child, (void*)i, (uvpt[PGNUM(i)] & PTE_SYSCALL));
  801dd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	25 07 0e 00 00       	and    $0xe07,%eax
  801de6:	50                   	push   %eax
  801de7:	53                   	push   %ebx
  801de8:	56                   	push   %esi
  801de9:	53                   	push   %ebx
  801dea:	6a 00                	push   $0x0
  801dec:	e8 95 ee ff ff       	call   800c86 <sys_page_map>
  801df1:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
  	uintptr_t i;
 	for (i = 0; i < USTACKTOP; i += PGSIZE)
  801df4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dfa:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801e00:	75 9c                	jne    801d9e <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e12:	e8 35 ef ff ff       	call   800d4c <sys_env_set_trapframe>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	79 15                	jns    801e33 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  801e1e:	50                   	push   %eax
  801e1f:	68 aa 33 80 00       	push   $0x8033aa
  801e24:	68 85 00 00 00       	push   $0x85
  801e29:	68 81 33 80 00       	push   $0x803381
  801e2e:	e8 af e3 ff ff       	call   8001e2 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e33:	83 ec 08             	sub    $0x8,%esp
  801e36:	6a 02                	push   $0x2
  801e38:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e3e:	e8 c7 ee ff ff       	call   800d0a <sys_env_set_status>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	79 25                	jns    801e6f <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801e4a:	50                   	push   %eax
  801e4b:	68 c4 33 80 00       	push   $0x8033c4
  801e50:	68 88 00 00 00       	push   $0x88
  801e55:	68 81 33 80 00       	push   $0x803381
  801e5a:	e8 83 e3 ff ff       	call   8001e2 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e5f:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e65:	eb 58                	jmp    801ebf <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e67:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e6d:	eb 50                	jmp    801ebf <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e6f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e75:	eb 48                	jmp    801ebf <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e77:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e7c:	eb 41                	jmp    801ebf <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	eb 3d                	jmp    801ebf <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	eb 06                	jmp    801e8c <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e86:	89 c3                	mov    %eax,%ebx
  801e88:	eb 02                	jmp    801e8c <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e8a:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e95:	e8 2a ed ff ff       	call   800bc4 <sys_env_destroy>
	close(fd);
  801e9a:	83 c4 04             	add    $0x4,%esp
  801e9d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ea3:	e8 7b f4 ff ff       	call   801323 <close>
	return r;
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	eb 12                	jmp    801ebf <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	68 00 00 40 00       	push   $0x400000
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 0c ee ff ff       	call   800cc8 <sys_page_unmap>
  801ebc:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ebf:	89 d8                	mov    %ebx,%eax
  801ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ece:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ed1:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ed6:	eb 03                	jmp    801edb <spawnl+0x12>
		argc++;
  801ed8:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801edb:	83 c2 04             	add    $0x4,%edx
  801ede:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ee2:	75 f4                	jne    801ed8 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ee4:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801eeb:	83 e2 f0             	and    $0xfffffff0,%edx
  801eee:	29 d4                	sub    %edx,%esp
  801ef0:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ef4:	c1 ea 02             	shr    $0x2,%edx
  801ef7:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801efe:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f03:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f0a:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f11:	00 
  801f12:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
  801f19:	eb 0a                	jmp    801f25 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f1b:	83 c0 01             	add    $0x1,%eax
  801f1e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f22:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f25:	39 d0                	cmp    %edx,%eax
  801f27:	75 f2                	jne    801f1b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f29:	83 ec 08             	sub    $0x8,%esp
  801f2c:	56                   	push   %esi
  801f2d:	ff 75 08             	pushl  0x8(%ebp)
  801f30:	e8 5d fa ff ff       	call   801992 <spawn>
}
  801f35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f42:	68 02 34 80 00       	push   $0x803402
  801f47:	ff 75 0c             	pushl  0xc(%ebp)
  801f4a:	e8 f1 e8 ff ff       	call   800840 <strcpy>
	return 0;
}
  801f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	53                   	push   %ebx
  801f5a:	83 ec 10             	sub    $0x10,%esp
  801f5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f60:	53                   	push   %ebx
  801f61:	e8 f8 0a 00 00       	call   802a5e <pageref>
  801f66:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f69:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f6e:	83 f8 01             	cmp    $0x1,%eax
  801f71:	75 10                	jne    801f83 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f73:	83 ec 0c             	sub    $0xc,%esp
  801f76:	ff 73 0c             	pushl  0xc(%ebx)
  801f79:	e8 c0 02 00 00       	call   80223e <nsipc_close>
  801f7e:	89 c2                	mov    %eax,%edx
  801f80:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801f83:	89 d0                	mov    %edx,%eax
  801f85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f90:	6a 00                	push   $0x0
  801f92:	ff 75 10             	pushl  0x10(%ebp)
  801f95:	ff 75 0c             	pushl  0xc(%ebp)
  801f98:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9b:	ff 70 0c             	pushl  0xc(%eax)
  801f9e:	e8 78 03 00 00       	call   80231b <nsipc_send>
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fab:	6a 00                	push   $0x0
  801fad:	ff 75 10             	pushl  0x10(%ebp)
  801fb0:	ff 75 0c             	pushl  0xc(%ebp)
  801fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb6:	ff 70 0c             	pushl  0xc(%eax)
  801fb9:	e8 f1 02 00 00       	call   8022af <nsipc_recv>
}
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fc6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fc9:	52                   	push   %edx
  801fca:	50                   	push   %eax
  801fcb:	e8 29 f2 ff ff       	call   8011f9 <fd_lookup>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	78 17                	js     801fee <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fda:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  801fe0:	39 08                	cmp    %ecx,(%eax)
  801fe2:	75 05                	jne    801fe9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fe4:	8b 40 0c             	mov    0xc(%eax),%eax
  801fe7:	eb 05                	jmp    801fee <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801fe9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	56                   	push   %esi
  801ff4:	53                   	push   %ebx
  801ff5:	83 ec 1c             	sub    $0x1c,%esp
  801ff8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffd:	50                   	push   %eax
  801ffe:	e8 a7 f1 ff ff       	call   8011aa <fd_alloc>
  802003:	89 c3                	mov    %eax,%ebx
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 1b                	js     802027 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80200c:	83 ec 04             	sub    $0x4,%esp
  80200f:	68 07 04 00 00       	push   $0x407
  802014:	ff 75 f4             	pushl  -0xc(%ebp)
  802017:	6a 00                	push   $0x0
  802019:	e8 25 ec ff ff       	call   800c43 <sys_page_alloc>
  80201e:	89 c3                	mov    %eax,%ebx
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	85 c0                	test   %eax,%eax
  802025:	79 10                	jns    802037 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	56                   	push   %esi
  80202b:	e8 0e 02 00 00       	call   80223e <nsipc_close>
		return r;
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	89 d8                	mov    %ebx,%eax
  802035:	eb 24                	jmp    80205b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802037:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80203d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802040:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80204c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	50                   	push   %eax
  802053:	e8 2b f1 ff ff       	call   801183 <fd2num>
  802058:	83 c4 10             	add    $0x10,%esp
}
  80205b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5e                   	pop    %esi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    

00802062 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802068:	8b 45 08             	mov    0x8(%ebp),%eax
  80206b:	e8 50 ff ff ff       	call   801fc0 <fd2sockid>
		return r;
  802070:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802072:	85 c0                	test   %eax,%eax
  802074:	78 1f                	js     802095 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802076:	83 ec 04             	sub    $0x4,%esp
  802079:	ff 75 10             	pushl  0x10(%ebp)
  80207c:	ff 75 0c             	pushl  0xc(%ebp)
  80207f:	50                   	push   %eax
  802080:	e8 12 01 00 00       	call   802197 <nsipc_accept>
  802085:	83 c4 10             	add    $0x10,%esp
		return r;
  802088:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 07                	js     802095 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80208e:	e8 5d ff ff ff       	call   801ff0 <alloc_sockfd>
  802093:	89 c1                	mov    %eax,%ecx
}
  802095:	89 c8                	mov    %ecx,%eax
  802097:	c9                   	leave  
  802098:	c3                   	ret    

00802099 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	e8 19 ff ff ff       	call   801fc0 <fd2sockid>
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 12                	js     8020bd <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8020ab:	83 ec 04             	sub    $0x4,%esp
  8020ae:	ff 75 10             	pushl  0x10(%ebp)
  8020b1:	ff 75 0c             	pushl  0xc(%ebp)
  8020b4:	50                   	push   %eax
  8020b5:	e8 2d 01 00 00       	call   8021e7 <nsipc_bind>
  8020ba:	83 c4 10             	add    $0x10,%esp
}
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <shutdown>:

int
shutdown(int s, int how)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c8:	e8 f3 fe ff ff       	call   801fc0 <fd2sockid>
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 0f                	js     8020e0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020d1:	83 ec 08             	sub    $0x8,%esp
  8020d4:	ff 75 0c             	pushl  0xc(%ebp)
  8020d7:	50                   	push   %eax
  8020d8:	e8 3f 01 00 00       	call   80221c <nsipc_shutdown>
  8020dd:	83 c4 10             	add    $0x10,%esp
}
  8020e0:	c9                   	leave  
  8020e1:	c3                   	ret    

008020e2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	e8 d0 fe ff ff       	call   801fc0 <fd2sockid>
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	78 12                	js     802106 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8020f4:	83 ec 04             	sub    $0x4,%esp
  8020f7:	ff 75 10             	pushl  0x10(%ebp)
  8020fa:	ff 75 0c             	pushl  0xc(%ebp)
  8020fd:	50                   	push   %eax
  8020fe:	e8 55 01 00 00       	call   802258 <nsipc_connect>
  802103:	83 c4 10             	add    $0x10,%esp
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <listen>:

int
listen(int s, int backlog)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	e8 aa fe ff ff       	call   801fc0 <fd2sockid>
  802116:	85 c0                	test   %eax,%eax
  802118:	78 0f                	js     802129 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80211a:	83 ec 08             	sub    $0x8,%esp
  80211d:	ff 75 0c             	pushl  0xc(%ebp)
  802120:	50                   	push   %eax
  802121:	e8 67 01 00 00       	call   80228d <nsipc_listen>
  802126:	83 c4 10             	add    $0x10,%esp
}
  802129:	c9                   	leave  
  80212a:	c3                   	ret    

0080212b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802131:	ff 75 10             	pushl  0x10(%ebp)
  802134:	ff 75 0c             	pushl  0xc(%ebp)
  802137:	ff 75 08             	pushl  0x8(%ebp)
  80213a:	e8 3a 02 00 00       	call   802379 <nsipc_socket>
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	85 c0                	test   %eax,%eax
  802144:	78 05                	js     80214b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802146:	e8 a5 fe ff ff       	call   801ff0 <alloc_sockfd>
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
  802150:	53                   	push   %ebx
  802151:	83 ec 04             	sub    $0x4,%esp
  802154:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802156:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80215d:	75 12                	jne    802171 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80215f:	83 ec 0c             	sub    $0xc,%esp
  802162:	6a 02                	push   $0x2
  802164:	e8 bc 08 00 00       	call   802a25 <ipc_find_env>
  802169:	a3 04 50 80 00       	mov    %eax,0x805004
  80216e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802171:	6a 07                	push   $0x7
  802173:	68 00 70 80 00       	push   $0x807000
  802178:	53                   	push   %ebx
  802179:	ff 35 04 50 80 00    	pushl  0x805004
  80217f:	e8 4d 08 00 00       	call   8029d1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802184:	83 c4 0c             	add    $0xc,%esp
  802187:	6a 00                	push   $0x0
  802189:	6a 00                	push   $0x0
  80218b:	6a 00                	push   $0x0
  80218d:	e8 d2 07 00 00       	call   802964 <ipc_recv>
}
  802192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802195:	c9                   	leave  
  802196:	c3                   	ret    

00802197 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	56                   	push   %esi
  80219b:	53                   	push   %ebx
  80219c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80219f:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021a7:	8b 06                	mov    (%esi),%eax
  8021a9:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b3:	e8 95 ff ff ff       	call   80214d <nsipc>
  8021b8:	89 c3                	mov    %eax,%ebx
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	78 20                	js     8021de <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021be:	83 ec 04             	sub    $0x4,%esp
  8021c1:	ff 35 10 70 80 00    	pushl  0x807010
  8021c7:	68 00 70 80 00       	push   $0x807000
  8021cc:	ff 75 0c             	pushl  0xc(%ebp)
  8021cf:	e8 fe e7 ff ff       	call   8009d2 <memmove>
		*addrlen = ret->ret_addrlen;
  8021d4:	a1 10 70 80 00       	mov    0x807010,%eax
  8021d9:	89 06                	mov    %eax,(%esi)
  8021db:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8021de:	89 d8                	mov    %ebx,%eax
  8021e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    

008021e7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	53                   	push   %ebx
  8021eb:	83 ec 08             	sub    $0x8,%esp
  8021ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f4:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021f9:	53                   	push   %ebx
  8021fa:	ff 75 0c             	pushl  0xc(%ebp)
  8021fd:	68 04 70 80 00       	push   $0x807004
  802202:	e8 cb e7 ff ff       	call   8009d2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802207:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80220d:	b8 02 00 00 00       	mov    $0x2,%eax
  802212:	e8 36 ff ff ff       	call   80214d <nsipc>
}
  802217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    

0080221c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802222:	8b 45 08             	mov    0x8(%ebp),%eax
  802225:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80222a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802232:	b8 03 00 00 00       	mov    $0x3,%eax
  802237:	e8 11 ff ff ff       	call   80214d <nsipc>
}
  80223c:	c9                   	leave  
  80223d:	c3                   	ret    

0080223e <nsipc_close>:

int
nsipc_close(int s)
{
  80223e:	55                   	push   %ebp
  80223f:	89 e5                	mov    %esp,%ebp
  802241:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802244:	8b 45 08             	mov    0x8(%ebp),%eax
  802247:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80224c:	b8 04 00 00 00       	mov    $0x4,%eax
  802251:	e8 f7 fe ff ff       	call   80214d <nsipc>
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	53                   	push   %ebx
  80225c:	83 ec 08             	sub    $0x8,%esp
  80225f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802262:	8b 45 08             	mov    0x8(%ebp),%eax
  802265:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80226a:	53                   	push   %ebx
  80226b:	ff 75 0c             	pushl  0xc(%ebp)
  80226e:	68 04 70 80 00       	push   $0x807004
  802273:	e8 5a e7 ff ff       	call   8009d2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802278:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80227e:	b8 05 00 00 00       	mov    $0x5,%eax
  802283:	e8 c5 fe ff ff       	call   80214d <nsipc>
}
  802288:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80228b:	c9                   	leave  
  80228c:	c3                   	ret    

0080228d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802293:	8b 45 08             	mov    0x8(%ebp),%eax
  802296:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80229b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8022a8:	e8 a0 fe ff ff       	call   80214d <nsipc>
}
  8022ad:	c9                   	leave  
  8022ae:	c3                   	ret    

008022af <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ba:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8022bf:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8022c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8022c8:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022cd:	b8 07 00 00 00       	mov    $0x7,%eax
  8022d2:	e8 76 fe ff ff       	call   80214d <nsipc>
  8022d7:	89 c3                	mov    %eax,%ebx
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 35                	js     802312 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8022dd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022e2:	7f 04                	jg     8022e8 <nsipc_recv+0x39>
  8022e4:	39 c6                	cmp    %eax,%esi
  8022e6:	7d 16                	jge    8022fe <nsipc_recv+0x4f>
  8022e8:	68 0e 34 80 00       	push   $0x80340e
  8022ed:	68 3b 33 80 00       	push   $0x80333b
  8022f2:	6a 62                	push   $0x62
  8022f4:	68 23 34 80 00       	push   $0x803423
  8022f9:	e8 e4 de ff ff       	call   8001e2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022fe:	83 ec 04             	sub    $0x4,%esp
  802301:	50                   	push   %eax
  802302:	68 00 70 80 00       	push   $0x807000
  802307:	ff 75 0c             	pushl  0xc(%ebp)
  80230a:	e8 c3 e6 ff ff       	call   8009d2 <memmove>
  80230f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802312:	89 d8                	mov    %ebx,%eax
  802314:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    

0080231b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	53                   	push   %ebx
  80231f:	83 ec 04             	sub    $0x4,%esp
  802322:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802325:	8b 45 08             	mov    0x8(%ebp),%eax
  802328:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80232d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802333:	7e 16                	jle    80234b <nsipc_send+0x30>
  802335:	68 2f 34 80 00       	push   $0x80342f
  80233a:	68 3b 33 80 00       	push   $0x80333b
  80233f:	6a 6d                	push   $0x6d
  802341:	68 23 34 80 00       	push   $0x803423
  802346:	e8 97 de ff ff       	call   8001e2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80234b:	83 ec 04             	sub    $0x4,%esp
  80234e:	53                   	push   %ebx
  80234f:	ff 75 0c             	pushl  0xc(%ebp)
  802352:	68 0c 70 80 00       	push   $0x80700c
  802357:	e8 76 e6 ff ff       	call   8009d2 <memmove>
	nsipcbuf.send.req_size = size;
  80235c:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802362:	8b 45 14             	mov    0x14(%ebp),%eax
  802365:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80236a:	b8 08 00 00 00       	mov    $0x8,%eax
  80236f:	e8 d9 fd ff ff       	call   80214d <nsipc>
}
  802374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802377:	c9                   	leave  
  802378:	c3                   	ret    

00802379 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80237f:	8b 45 08             	mov    0x8(%ebp),%eax
  802382:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80238a:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80238f:	8b 45 10             	mov    0x10(%ebp),%eax
  802392:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802397:	b8 09 00 00 00       	mov    $0x9,%eax
  80239c:	e8 ac fd ff ff       	call   80214d <nsipc>
}
  8023a1:	c9                   	leave  
  8023a2:	c3                   	ret    

008023a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023a3:	55                   	push   %ebp
  8023a4:	89 e5                	mov    %esp,%ebp
  8023a6:	56                   	push   %esi
  8023a7:	53                   	push   %ebx
  8023a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023ab:	83 ec 0c             	sub    $0xc,%esp
  8023ae:	ff 75 08             	pushl  0x8(%ebp)
  8023b1:	e8 dd ed ff ff       	call   801193 <fd2data>
  8023b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8023b8:	83 c4 08             	add    $0x8,%esp
  8023bb:	68 3b 34 80 00       	push   $0x80343b
  8023c0:	53                   	push   %ebx
  8023c1:	e8 7a e4 ff ff       	call   800840 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023c6:	8b 46 04             	mov    0x4(%esi),%eax
  8023c9:	2b 06                	sub    (%esi),%eax
  8023cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8023d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8023d8:	00 00 00 
	stat->st_dev = &devpipe;
  8023db:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  8023e2:	40 80 00 
	return 0;
}
  8023e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	53                   	push   %ebx
  8023f5:	83 ec 0c             	sub    $0xc,%esp
  8023f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023fb:	53                   	push   %ebx
  8023fc:	6a 00                	push   $0x0
  8023fe:	e8 c5 e8 ff ff       	call   800cc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802403:	89 1c 24             	mov    %ebx,(%esp)
  802406:	e8 88 ed ff ff       	call   801193 <fd2data>
  80240b:	83 c4 08             	add    $0x8,%esp
  80240e:	50                   	push   %eax
  80240f:	6a 00                	push   $0x0
  802411:	e8 b2 e8 ff ff       	call   800cc8 <sys_page_unmap>
}
  802416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802419:	c9                   	leave  
  80241a:	c3                   	ret    

0080241b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80241b:	55                   	push   %ebp
  80241c:	89 e5                	mov    %esp,%ebp
  80241e:	57                   	push   %edi
  80241f:	56                   	push   %esi
  802420:	53                   	push   %ebx
  802421:	83 ec 1c             	sub    $0x1c,%esp
  802424:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802427:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802429:	a1 08 50 80 00       	mov    0x805008,%eax
  80242e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802431:	83 ec 0c             	sub    $0xc,%esp
  802434:	ff 75 e0             	pushl  -0x20(%ebp)
  802437:	e8 22 06 00 00       	call   802a5e <pageref>
  80243c:	89 c3                	mov    %eax,%ebx
  80243e:	89 3c 24             	mov    %edi,(%esp)
  802441:	e8 18 06 00 00       	call   802a5e <pageref>
  802446:	83 c4 10             	add    $0x10,%esp
  802449:	39 c3                	cmp    %eax,%ebx
  80244b:	0f 94 c1             	sete   %cl
  80244e:	0f b6 c9             	movzbl %cl,%ecx
  802451:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802454:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80245a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80245d:	39 ce                	cmp    %ecx,%esi
  80245f:	74 1b                	je     80247c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802461:	39 c3                	cmp    %eax,%ebx
  802463:	75 c4                	jne    802429 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802465:	8b 42 58             	mov    0x58(%edx),%eax
  802468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80246b:	50                   	push   %eax
  80246c:	56                   	push   %esi
  80246d:	68 42 34 80 00       	push   $0x803442
  802472:	e8 44 de ff ff       	call   8002bb <cprintf>
  802477:	83 c4 10             	add    $0x10,%esp
  80247a:	eb ad                	jmp    802429 <_pipeisclosed+0xe>
	}
}
  80247c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80247f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802482:	5b                   	pop    %ebx
  802483:	5e                   	pop    %esi
  802484:	5f                   	pop    %edi
  802485:	5d                   	pop    %ebp
  802486:	c3                   	ret    

00802487 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	57                   	push   %edi
  80248b:	56                   	push   %esi
  80248c:	53                   	push   %ebx
  80248d:	83 ec 28             	sub    $0x28,%esp
  802490:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802493:	56                   	push   %esi
  802494:	e8 fa ec ff ff       	call   801193 <fd2data>
  802499:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80249b:	83 c4 10             	add    $0x10,%esp
  80249e:	bf 00 00 00 00       	mov    $0x0,%edi
  8024a3:	eb 4b                	jmp    8024f0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024a5:	89 da                	mov    %ebx,%edx
  8024a7:	89 f0                	mov    %esi,%eax
  8024a9:	e8 6d ff ff ff       	call   80241b <_pipeisclosed>
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	75 48                	jne    8024fa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8024b2:	e8 6d e7 ff ff       	call   800c24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024b7:	8b 43 04             	mov    0x4(%ebx),%eax
  8024ba:	8b 0b                	mov    (%ebx),%ecx
  8024bc:	8d 51 20             	lea    0x20(%ecx),%edx
  8024bf:	39 d0                	cmp    %edx,%eax
  8024c1:	73 e2                	jae    8024a5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8024c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024c6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8024ca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8024cd:	89 c2                	mov    %eax,%edx
  8024cf:	c1 fa 1f             	sar    $0x1f,%edx
  8024d2:	89 d1                	mov    %edx,%ecx
  8024d4:	c1 e9 1b             	shr    $0x1b,%ecx
  8024d7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8024da:	83 e2 1f             	and    $0x1f,%edx
  8024dd:	29 ca                	sub    %ecx,%edx
  8024df:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8024e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024e7:	83 c0 01             	add    $0x1,%eax
  8024ea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024ed:	83 c7 01             	add    $0x1,%edi
  8024f0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024f3:	75 c2                	jne    8024b7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8024f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f8:	eb 05                	jmp    8024ff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024fa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8024ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802502:	5b                   	pop    %ebx
  802503:	5e                   	pop    %esi
  802504:	5f                   	pop    %edi
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    

00802507 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	57                   	push   %edi
  80250b:	56                   	push   %esi
  80250c:	53                   	push   %ebx
  80250d:	83 ec 18             	sub    $0x18,%esp
  802510:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802513:	57                   	push   %edi
  802514:	e8 7a ec ff ff       	call   801193 <fd2data>
  802519:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80251b:	83 c4 10             	add    $0x10,%esp
  80251e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802523:	eb 3d                	jmp    802562 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802525:	85 db                	test   %ebx,%ebx
  802527:	74 04                	je     80252d <devpipe_read+0x26>
				return i;
  802529:	89 d8                	mov    %ebx,%eax
  80252b:	eb 44                	jmp    802571 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80252d:	89 f2                	mov    %esi,%edx
  80252f:	89 f8                	mov    %edi,%eax
  802531:	e8 e5 fe ff ff       	call   80241b <_pipeisclosed>
  802536:	85 c0                	test   %eax,%eax
  802538:	75 32                	jne    80256c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80253a:	e8 e5 e6 ff ff       	call   800c24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80253f:	8b 06                	mov    (%esi),%eax
  802541:	3b 46 04             	cmp    0x4(%esi),%eax
  802544:	74 df                	je     802525 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802546:	99                   	cltd   
  802547:	c1 ea 1b             	shr    $0x1b,%edx
  80254a:	01 d0                	add    %edx,%eax
  80254c:	83 e0 1f             	and    $0x1f,%eax
  80254f:	29 d0                	sub    %edx,%eax
  802551:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802556:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802559:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80255c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80255f:	83 c3 01             	add    $0x1,%ebx
  802562:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802565:	75 d8                	jne    80253f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802567:	8b 45 10             	mov    0x10(%ebp),%eax
  80256a:	eb 05                	jmp    802571 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80256c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802574:	5b                   	pop    %ebx
  802575:	5e                   	pop    %esi
  802576:	5f                   	pop    %edi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    

00802579 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802579:	55                   	push   %ebp
  80257a:	89 e5                	mov    %esp,%ebp
  80257c:	56                   	push   %esi
  80257d:	53                   	push   %ebx
  80257e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802584:	50                   	push   %eax
  802585:	e8 20 ec ff ff       	call   8011aa <fd_alloc>
  80258a:	83 c4 10             	add    $0x10,%esp
  80258d:	89 c2                	mov    %eax,%edx
  80258f:	85 c0                	test   %eax,%eax
  802591:	0f 88 2c 01 00 00    	js     8026c3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802597:	83 ec 04             	sub    $0x4,%esp
  80259a:	68 07 04 00 00       	push   $0x407
  80259f:	ff 75 f4             	pushl  -0xc(%ebp)
  8025a2:	6a 00                	push   $0x0
  8025a4:	e8 9a e6 ff ff       	call   800c43 <sys_page_alloc>
  8025a9:	83 c4 10             	add    $0x10,%esp
  8025ac:	89 c2                	mov    %eax,%edx
  8025ae:	85 c0                	test   %eax,%eax
  8025b0:	0f 88 0d 01 00 00    	js     8026c3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025b6:	83 ec 0c             	sub    $0xc,%esp
  8025b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025bc:	50                   	push   %eax
  8025bd:	e8 e8 eb ff ff       	call   8011aa <fd_alloc>
  8025c2:	89 c3                	mov    %eax,%ebx
  8025c4:	83 c4 10             	add    $0x10,%esp
  8025c7:	85 c0                	test   %eax,%eax
  8025c9:	0f 88 e2 00 00 00    	js     8026b1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025cf:	83 ec 04             	sub    $0x4,%esp
  8025d2:	68 07 04 00 00       	push   $0x407
  8025d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8025da:	6a 00                	push   $0x0
  8025dc:	e8 62 e6 ff ff       	call   800c43 <sys_page_alloc>
  8025e1:	89 c3                	mov    %eax,%ebx
  8025e3:	83 c4 10             	add    $0x10,%esp
  8025e6:	85 c0                	test   %eax,%eax
  8025e8:	0f 88 c3 00 00 00    	js     8026b1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8025ee:	83 ec 0c             	sub    $0xc,%esp
  8025f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f4:	e8 9a eb ff ff       	call   801193 <fd2data>
  8025f9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025fb:	83 c4 0c             	add    $0xc,%esp
  8025fe:	68 07 04 00 00       	push   $0x407
  802603:	50                   	push   %eax
  802604:	6a 00                	push   $0x0
  802606:	e8 38 e6 ff ff       	call   800c43 <sys_page_alloc>
  80260b:	89 c3                	mov    %eax,%ebx
  80260d:	83 c4 10             	add    $0x10,%esp
  802610:	85 c0                	test   %eax,%eax
  802612:	0f 88 89 00 00 00    	js     8026a1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802618:	83 ec 0c             	sub    $0xc,%esp
  80261b:	ff 75 f0             	pushl  -0x10(%ebp)
  80261e:	e8 70 eb ff ff       	call   801193 <fd2data>
  802623:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80262a:	50                   	push   %eax
  80262b:	6a 00                	push   $0x0
  80262d:	56                   	push   %esi
  80262e:	6a 00                	push   $0x0
  802630:	e8 51 e6 ff ff       	call   800c86 <sys_page_map>
  802635:	89 c3                	mov    %eax,%ebx
  802637:	83 c4 20             	add    $0x20,%esp
  80263a:	85 c0                	test   %eax,%eax
  80263c:	78 55                	js     802693 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80263e:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802647:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802653:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80265c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80265e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802661:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802668:	83 ec 0c             	sub    $0xc,%esp
  80266b:	ff 75 f4             	pushl  -0xc(%ebp)
  80266e:	e8 10 eb ff ff       	call   801183 <fd2num>
  802673:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802676:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802678:	83 c4 04             	add    $0x4,%esp
  80267b:	ff 75 f0             	pushl  -0x10(%ebp)
  80267e:	e8 00 eb ff ff       	call   801183 <fd2num>
  802683:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802686:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802689:	83 c4 10             	add    $0x10,%esp
  80268c:	ba 00 00 00 00       	mov    $0x0,%edx
  802691:	eb 30                	jmp    8026c3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802693:	83 ec 08             	sub    $0x8,%esp
  802696:	56                   	push   %esi
  802697:	6a 00                	push   $0x0
  802699:	e8 2a e6 ff ff       	call   800cc8 <sys_page_unmap>
  80269e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8026a1:	83 ec 08             	sub    $0x8,%esp
  8026a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8026a7:	6a 00                	push   $0x0
  8026a9:	e8 1a e6 ff ff       	call   800cc8 <sys_page_unmap>
  8026ae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8026b1:	83 ec 08             	sub    $0x8,%esp
  8026b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8026b7:	6a 00                	push   $0x0
  8026b9:	e8 0a e6 ff ff       	call   800cc8 <sys_page_unmap>
  8026be:	83 c4 10             	add    $0x10,%esp
  8026c1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8026c3:	89 d0                	mov    %edx,%eax
  8026c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026c8:	5b                   	pop    %ebx
  8026c9:	5e                   	pop    %esi
  8026ca:	5d                   	pop    %ebp
  8026cb:	c3                   	ret    

008026cc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8026cc:	55                   	push   %ebp
  8026cd:	89 e5                	mov    %esp,%ebp
  8026cf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026d5:	50                   	push   %eax
  8026d6:	ff 75 08             	pushl  0x8(%ebp)
  8026d9:	e8 1b eb ff ff       	call   8011f9 <fd_lookup>
  8026de:	83 c4 10             	add    $0x10,%esp
  8026e1:	85 c0                	test   %eax,%eax
  8026e3:	78 18                	js     8026fd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8026e5:	83 ec 0c             	sub    $0xc,%esp
  8026e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8026eb:	e8 a3 ea ff ff       	call   801193 <fd2data>
	return _pipeisclosed(fd, p);
  8026f0:	89 c2                	mov    %eax,%edx
  8026f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f5:	e8 21 fd ff ff       	call   80241b <_pipeisclosed>
  8026fa:	83 c4 10             	add    $0x10,%esp
}
  8026fd:	c9                   	leave  
  8026fe:	c3                   	ret    

008026ff <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8026ff:	55                   	push   %ebp
  802700:	89 e5                	mov    %esp,%ebp
  802702:	56                   	push   %esi
  802703:	53                   	push   %ebx
  802704:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802707:	85 f6                	test   %esi,%esi
  802709:	75 16                	jne    802721 <wait+0x22>
  80270b:	68 5a 34 80 00       	push   $0x80345a
  802710:	68 3b 33 80 00       	push   $0x80333b
  802715:	6a 09                	push   $0x9
  802717:	68 65 34 80 00       	push   $0x803465
  80271c:	e8 c1 da ff ff       	call   8001e2 <_panic>
	e = &envs[ENVX(envid)];
  802721:	89 f3                	mov    %esi,%ebx
  802723:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802729:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80272c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802732:	eb 05                	jmp    802739 <wait+0x3a>
		sys_yield();
  802734:	e8 eb e4 ff ff       	call   800c24 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802739:	8b 43 48             	mov    0x48(%ebx),%eax
  80273c:	39 c6                	cmp    %eax,%esi
  80273e:	75 07                	jne    802747 <wait+0x48>
  802740:	8b 43 54             	mov    0x54(%ebx),%eax
  802743:	85 c0                	test   %eax,%eax
  802745:	75 ed                	jne    802734 <wait+0x35>
		sys_yield();
}
  802747:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80274a:	5b                   	pop    %ebx
  80274b:	5e                   	pop    %esi
  80274c:	5d                   	pop    %ebp
  80274d:	c3                   	ret    

0080274e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80274e:	55                   	push   %ebp
  80274f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802751:	b8 00 00 00 00       	mov    $0x0,%eax
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    

00802758 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802758:	55                   	push   %ebp
  802759:	89 e5                	mov    %esp,%ebp
  80275b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80275e:	68 70 34 80 00       	push   $0x803470
  802763:	ff 75 0c             	pushl  0xc(%ebp)
  802766:	e8 d5 e0 ff ff       	call   800840 <strcpy>
	return 0;
}
  80276b:	b8 00 00 00 00       	mov    $0x0,%eax
  802770:	c9                   	leave  
  802771:	c3                   	ret    

00802772 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802772:	55                   	push   %ebp
  802773:	89 e5                	mov    %esp,%ebp
  802775:	57                   	push   %edi
  802776:	56                   	push   %esi
  802777:	53                   	push   %ebx
  802778:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80277e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802783:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802789:	eb 2d                	jmp    8027b8 <devcons_write+0x46>
		m = n - tot;
  80278b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80278e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802790:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802793:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802798:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80279b:	83 ec 04             	sub    $0x4,%esp
  80279e:	53                   	push   %ebx
  80279f:	03 45 0c             	add    0xc(%ebp),%eax
  8027a2:	50                   	push   %eax
  8027a3:	57                   	push   %edi
  8027a4:	e8 29 e2 ff ff       	call   8009d2 <memmove>
		sys_cputs(buf, m);
  8027a9:	83 c4 08             	add    $0x8,%esp
  8027ac:	53                   	push   %ebx
  8027ad:	57                   	push   %edi
  8027ae:	e8 d4 e3 ff ff       	call   800b87 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027b3:	01 de                	add    %ebx,%esi
  8027b5:	83 c4 10             	add    $0x10,%esp
  8027b8:	89 f0                	mov    %esi,%eax
  8027ba:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027bd:	72 cc                	jb     80278b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c2:	5b                   	pop    %ebx
  8027c3:	5e                   	pop    %esi
  8027c4:	5f                   	pop    %edi
  8027c5:	5d                   	pop    %ebp
  8027c6:	c3                   	ret    

008027c7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027c7:	55                   	push   %ebp
  8027c8:	89 e5                	mov    %esp,%ebp
  8027ca:	83 ec 08             	sub    $0x8,%esp
  8027cd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8027d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027d6:	74 2a                	je     802802 <devcons_read+0x3b>
  8027d8:	eb 05                	jmp    8027df <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027da:	e8 45 e4 ff ff       	call   800c24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027df:	e8 c1 e3 ff ff       	call   800ba5 <sys_cgetc>
  8027e4:	85 c0                	test   %eax,%eax
  8027e6:	74 f2                	je     8027da <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8027e8:	85 c0                	test   %eax,%eax
  8027ea:	78 16                	js     802802 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027ec:	83 f8 04             	cmp    $0x4,%eax
  8027ef:	74 0c                	je     8027fd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8027f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027f4:	88 02                	mov    %al,(%edx)
	return 1;
  8027f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027fb:	eb 05                	jmp    802802 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8027fd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802802:	c9                   	leave  
  802803:	c3                   	ret    

00802804 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802804:	55                   	push   %ebp
  802805:	89 e5                	mov    %esp,%ebp
  802807:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80280a:	8b 45 08             	mov    0x8(%ebp),%eax
  80280d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802810:	6a 01                	push   $0x1
  802812:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802815:	50                   	push   %eax
  802816:	e8 6c e3 ff ff       	call   800b87 <sys_cputs>
}
  80281b:	83 c4 10             	add    $0x10,%esp
  80281e:	c9                   	leave  
  80281f:	c3                   	ret    

00802820 <getchar>:

int
getchar(void)
{
  802820:	55                   	push   %ebp
  802821:	89 e5                	mov    %esp,%ebp
  802823:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802826:	6a 01                	push   $0x1
  802828:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80282b:	50                   	push   %eax
  80282c:	6a 00                	push   $0x0
  80282e:	e8 2c ec ff ff       	call   80145f <read>
	if (r < 0)
  802833:	83 c4 10             	add    $0x10,%esp
  802836:	85 c0                	test   %eax,%eax
  802838:	78 0f                	js     802849 <getchar+0x29>
		return r;
	if (r < 1)
  80283a:	85 c0                	test   %eax,%eax
  80283c:	7e 06                	jle    802844 <getchar+0x24>
		return -E_EOF;
	return c;
  80283e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802842:	eb 05                	jmp    802849 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802844:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802849:	c9                   	leave  
  80284a:	c3                   	ret    

0080284b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80284b:	55                   	push   %ebp
  80284c:	89 e5                	mov    %esp,%ebp
  80284e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802854:	50                   	push   %eax
  802855:	ff 75 08             	pushl  0x8(%ebp)
  802858:	e8 9c e9 ff ff       	call   8011f9 <fd_lookup>
  80285d:	83 c4 10             	add    $0x10,%esp
  802860:	85 c0                	test   %eax,%eax
  802862:	78 11                	js     802875 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802867:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80286d:	39 10                	cmp    %edx,(%eax)
  80286f:	0f 94 c0             	sete   %al
  802872:	0f b6 c0             	movzbl %al,%eax
}
  802875:	c9                   	leave  
  802876:	c3                   	ret    

00802877 <opencons>:

int
opencons(void)
{
  802877:	55                   	push   %ebp
  802878:	89 e5                	mov    %esp,%ebp
  80287a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80287d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802880:	50                   	push   %eax
  802881:	e8 24 e9 ff ff       	call   8011aa <fd_alloc>
  802886:	83 c4 10             	add    $0x10,%esp
		return r;
  802889:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80288b:	85 c0                	test   %eax,%eax
  80288d:	78 3e                	js     8028cd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80288f:	83 ec 04             	sub    $0x4,%esp
  802892:	68 07 04 00 00       	push   $0x407
  802897:	ff 75 f4             	pushl  -0xc(%ebp)
  80289a:	6a 00                	push   $0x0
  80289c:	e8 a2 e3 ff ff       	call   800c43 <sys_page_alloc>
  8028a1:	83 c4 10             	add    $0x10,%esp
		return r;
  8028a4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028a6:	85 c0                	test   %eax,%eax
  8028a8:	78 23                	js     8028cd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028aa:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8028b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028bf:	83 ec 0c             	sub    $0xc,%esp
  8028c2:	50                   	push   %eax
  8028c3:	e8 bb e8 ff ff       	call   801183 <fd2num>
  8028c8:	89 c2                	mov    %eax,%edx
  8028ca:	83 c4 10             	add    $0x10,%esp
}
  8028cd:	89 d0                	mov    %edx,%eax
  8028cf:	c9                   	leave  
  8028d0:	c3                   	ret    

008028d1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028d1:	55                   	push   %ebp
  8028d2:	89 e5                	mov    %esp,%ebp
  8028d4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028d7:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8028de:	75 2c                	jne    80290c <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8028e0:	83 ec 04             	sub    $0x4,%esp
  8028e3:	6a 07                	push   $0x7
  8028e5:	68 00 f0 bf ee       	push   $0xeebff000
  8028ea:	6a 00                	push   $0x0
  8028ec:	e8 52 e3 ff ff       	call   800c43 <sys_page_alloc>
  8028f1:	83 c4 10             	add    $0x10,%esp
  8028f4:	85 c0                	test   %eax,%eax
  8028f6:	79 14                	jns    80290c <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  8028f8:	83 ec 04             	sub    $0x4,%esp
  8028fb:	68 7c 34 80 00       	push   $0x80347c
  802900:	6a 22                	push   $0x22
  802902:	68 93 34 80 00       	push   $0x803493
  802907:	e8 d6 d8 ff ff       	call   8001e2 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  80290c:	8b 45 08             	mov    0x8(%ebp),%eax
  80290f:	a3 00 80 80 00       	mov    %eax,0x808000
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802914:	83 ec 08             	sub    $0x8,%esp
  802917:	68 40 29 80 00       	push   $0x802940
  80291c:	6a 00                	push   $0x0
  80291e:	e8 6b e4 ff ff       	call   800d8e <sys_env_set_pgfault_upcall>
  802923:	83 c4 10             	add    $0x10,%esp
  802926:	85 c0                	test   %eax,%eax
  802928:	79 14                	jns    80293e <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  80292a:	83 ec 04             	sub    $0x4,%esp
  80292d:	68 a4 34 80 00       	push   $0x8034a4
  802932:	6a 27                	push   $0x27
  802934:	68 93 34 80 00       	push   $0x803493
  802939:	e8 a4 d8 ff ff       	call   8001e2 <_panic>
    
}
  80293e:	c9                   	leave  
  80293f:	c3                   	ret    

00802940 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802940:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802941:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802946:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802948:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  80294b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  80294f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  802954:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  802958:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80295a:	83 c4 08             	add    $0x8,%esp
	popal
  80295d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  80295e:	83 c4 04             	add    $0x4,%esp
	popfl
  802961:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802962:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802963:	c3                   	ret    

00802964 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802964:	55                   	push   %ebp
  802965:	89 e5                	mov    %esp,%ebp
  802967:	56                   	push   %esi
  802968:	53                   	push   %ebx
  802969:	8b 75 08             	mov    0x8(%ebp),%esi
  80296c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80296f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  802972:	85 c0                	test   %eax,%eax
  802974:	74 0e                	je     802984 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  802976:	83 ec 0c             	sub    $0xc,%esp
  802979:	50                   	push   %eax
  80297a:	e8 74 e4 ff ff       	call   800df3 <sys_ipc_recv>
  80297f:	83 c4 10             	add    $0x10,%esp
  802982:	eb 10                	jmp    802994 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  802984:	83 ec 0c             	sub    $0xc,%esp
  802987:	68 00 00 00 f0       	push   $0xf0000000
  80298c:	e8 62 e4 ff ff       	call   800df3 <sys_ipc_recv>
  802991:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  802994:	85 c0                	test   %eax,%eax
  802996:	74 0e                	je     8029a6 <ipc_recv+0x42>
    	*from_env_store = 0;
  802998:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  80299e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  8029a4:	eb 24                	jmp    8029ca <ipc_recv+0x66>
    }	
    if (from_env_store) {
  8029a6:	85 f6                	test   %esi,%esi
  8029a8:	74 0a                	je     8029b4 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  8029aa:	a1 08 50 80 00       	mov    0x805008,%eax
  8029af:	8b 40 74             	mov    0x74(%eax),%eax
  8029b2:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  8029b4:	85 db                	test   %ebx,%ebx
  8029b6:	74 0a                	je     8029c2 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  8029b8:	a1 08 50 80 00       	mov    0x805008,%eax
  8029bd:	8b 40 78             	mov    0x78(%eax),%eax
  8029c0:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  8029c2:	a1 08 50 80 00       	mov    0x805008,%eax
  8029c7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8029ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029cd:	5b                   	pop    %ebx
  8029ce:	5e                   	pop    %esi
  8029cf:	5d                   	pop    %ebp
  8029d0:	c3                   	ret    

008029d1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029d1:	55                   	push   %ebp
  8029d2:	89 e5                	mov    %esp,%ebp
  8029d4:	57                   	push   %edi
  8029d5:	56                   	push   %esi
  8029d6:	53                   	push   %ebx
  8029d7:	83 ec 0c             	sub    $0xc,%esp
  8029da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  8029e3:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  8029e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8029ea:	0f 44 d8             	cmove  %eax,%ebx
  8029ed:	eb 1c                	jmp    802a0b <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  8029ef:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029f2:	74 12                	je     802a06 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  8029f4:	50                   	push   %eax
  8029f5:	68 c8 34 80 00       	push   $0x8034c8
  8029fa:	6a 4b                	push   $0x4b
  8029fc:	68 e0 34 80 00       	push   $0x8034e0
  802a01:	e8 dc d7 ff ff       	call   8001e2 <_panic>
        }	
        sys_yield();
  802a06:	e8 19 e2 ff ff       	call   800c24 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802a0b:	ff 75 14             	pushl  0x14(%ebp)
  802a0e:	53                   	push   %ebx
  802a0f:	56                   	push   %esi
  802a10:	57                   	push   %edi
  802a11:	e8 ba e3 ff ff       	call   800dd0 <sys_ipc_try_send>
  802a16:	83 c4 10             	add    $0x10,%esp
  802a19:	85 c0                	test   %eax,%eax
  802a1b:	75 d2                	jne    8029ef <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802a1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a20:	5b                   	pop    %ebx
  802a21:	5e                   	pop    %esi
  802a22:	5f                   	pop    %edi
  802a23:	5d                   	pop    %ebp
  802a24:	c3                   	ret    

00802a25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a25:	55                   	push   %ebp
  802a26:	89 e5                	mov    %esp,%ebp
  802a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a2b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a30:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a33:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a39:	8b 52 50             	mov    0x50(%edx),%edx
  802a3c:	39 ca                	cmp    %ecx,%edx
  802a3e:	75 0d                	jne    802a4d <ipc_find_env+0x28>
			return envs[i].env_id;
  802a40:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a43:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a48:	8b 40 48             	mov    0x48(%eax),%eax
  802a4b:	eb 0f                	jmp    802a5c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a4d:	83 c0 01             	add    $0x1,%eax
  802a50:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a55:	75 d9                	jne    802a30 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a5c:	5d                   	pop    %ebp
  802a5d:	c3                   	ret    

00802a5e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a5e:	55                   	push   %ebp
  802a5f:	89 e5                	mov    %esp,%ebp
  802a61:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a64:	89 d0                	mov    %edx,%eax
  802a66:	c1 e8 16             	shr    $0x16,%eax
  802a69:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802a70:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a75:	f6 c1 01             	test   $0x1,%cl
  802a78:	74 1d                	je     802a97 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a7a:	c1 ea 0c             	shr    $0xc,%edx
  802a7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a84:	f6 c2 01             	test   $0x1,%dl
  802a87:	74 0e                	je     802a97 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a89:	c1 ea 0c             	shr    $0xc,%edx
  802a8c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a93:	ef 
  802a94:	0f b7 c0             	movzwl %ax,%eax
}
  802a97:	5d                   	pop    %ebp
  802a98:	c3                   	ret    
  802a99:	66 90                	xchg   %ax,%ax
  802a9b:	66 90                	xchg   %ax,%ax
  802a9d:	66 90                	xchg   %ax,%ax
  802a9f:	90                   	nop

00802aa0 <__udivdi3>:
  802aa0:	55                   	push   %ebp
  802aa1:	57                   	push   %edi
  802aa2:	56                   	push   %esi
  802aa3:	53                   	push   %ebx
  802aa4:	83 ec 1c             	sub    $0x1c,%esp
  802aa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802aab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802aaf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802ab3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ab7:	85 f6                	test   %esi,%esi
  802ab9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802abd:	89 ca                	mov    %ecx,%edx
  802abf:	89 f8                	mov    %edi,%eax
  802ac1:	75 3d                	jne    802b00 <__udivdi3+0x60>
  802ac3:	39 cf                	cmp    %ecx,%edi
  802ac5:	0f 87 c5 00 00 00    	ja     802b90 <__udivdi3+0xf0>
  802acb:	85 ff                	test   %edi,%edi
  802acd:	89 fd                	mov    %edi,%ebp
  802acf:	75 0b                	jne    802adc <__udivdi3+0x3c>
  802ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ad6:	31 d2                	xor    %edx,%edx
  802ad8:	f7 f7                	div    %edi
  802ada:	89 c5                	mov    %eax,%ebp
  802adc:	89 c8                	mov    %ecx,%eax
  802ade:	31 d2                	xor    %edx,%edx
  802ae0:	f7 f5                	div    %ebp
  802ae2:	89 c1                	mov    %eax,%ecx
  802ae4:	89 d8                	mov    %ebx,%eax
  802ae6:	89 cf                	mov    %ecx,%edi
  802ae8:	f7 f5                	div    %ebp
  802aea:	89 c3                	mov    %eax,%ebx
  802aec:	89 d8                	mov    %ebx,%eax
  802aee:	89 fa                	mov    %edi,%edx
  802af0:	83 c4 1c             	add    $0x1c,%esp
  802af3:	5b                   	pop    %ebx
  802af4:	5e                   	pop    %esi
  802af5:	5f                   	pop    %edi
  802af6:	5d                   	pop    %ebp
  802af7:	c3                   	ret    
  802af8:	90                   	nop
  802af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b00:	39 ce                	cmp    %ecx,%esi
  802b02:	77 74                	ja     802b78 <__udivdi3+0xd8>
  802b04:	0f bd fe             	bsr    %esi,%edi
  802b07:	83 f7 1f             	xor    $0x1f,%edi
  802b0a:	0f 84 98 00 00 00    	je     802ba8 <__udivdi3+0x108>
  802b10:	bb 20 00 00 00       	mov    $0x20,%ebx
  802b15:	89 f9                	mov    %edi,%ecx
  802b17:	89 c5                	mov    %eax,%ebp
  802b19:	29 fb                	sub    %edi,%ebx
  802b1b:	d3 e6                	shl    %cl,%esi
  802b1d:	89 d9                	mov    %ebx,%ecx
  802b1f:	d3 ed                	shr    %cl,%ebp
  802b21:	89 f9                	mov    %edi,%ecx
  802b23:	d3 e0                	shl    %cl,%eax
  802b25:	09 ee                	or     %ebp,%esi
  802b27:	89 d9                	mov    %ebx,%ecx
  802b29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b2d:	89 d5                	mov    %edx,%ebp
  802b2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b33:	d3 ed                	shr    %cl,%ebp
  802b35:	89 f9                	mov    %edi,%ecx
  802b37:	d3 e2                	shl    %cl,%edx
  802b39:	89 d9                	mov    %ebx,%ecx
  802b3b:	d3 e8                	shr    %cl,%eax
  802b3d:	09 c2                	or     %eax,%edx
  802b3f:	89 d0                	mov    %edx,%eax
  802b41:	89 ea                	mov    %ebp,%edx
  802b43:	f7 f6                	div    %esi
  802b45:	89 d5                	mov    %edx,%ebp
  802b47:	89 c3                	mov    %eax,%ebx
  802b49:	f7 64 24 0c          	mull   0xc(%esp)
  802b4d:	39 d5                	cmp    %edx,%ebp
  802b4f:	72 10                	jb     802b61 <__udivdi3+0xc1>
  802b51:	8b 74 24 08          	mov    0x8(%esp),%esi
  802b55:	89 f9                	mov    %edi,%ecx
  802b57:	d3 e6                	shl    %cl,%esi
  802b59:	39 c6                	cmp    %eax,%esi
  802b5b:	73 07                	jae    802b64 <__udivdi3+0xc4>
  802b5d:	39 d5                	cmp    %edx,%ebp
  802b5f:	75 03                	jne    802b64 <__udivdi3+0xc4>
  802b61:	83 eb 01             	sub    $0x1,%ebx
  802b64:	31 ff                	xor    %edi,%edi
  802b66:	89 d8                	mov    %ebx,%eax
  802b68:	89 fa                	mov    %edi,%edx
  802b6a:	83 c4 1c             	add    $0x1c,%esp
  802b6d:	5b                   	pop    %ebx
  802b6e:	5e                   	pop    %esi
  802b6f:	5f                   	pop    %edi
  802b70:	5d                   	pop    %ebp
  802b71:	c3                   	ret    
  802b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b78:	31 ff                	xor    %edi,%edi
  802b7a:	31 db                	xor    %ebx,%ebx
  802b7c:	89 d8                	mov    %ebx,%eax
  802b7e:	89 fa                	mov    %edi,%edx
  802b80:	83 c4 1c             	add    $0x1c,%esp
  802b83:	5b                   	pop    %ebx
  802b84:	5e                   	pop    %esi
  802b85:	5f                   	pop    %edi
  802b86:	5d                   	pop    %ebp
  802b87:	c3                   	ret    
  802b88:	90                   	nop
  802b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b90:	89 d8                	mov    %ebx,%eax
  802b92:	f7 f7                	div    %edi
  802b94:	31 ff                	xor    %edi,%edi
  802b96:	89 c3                	mov    %eax,%ebx
  802b98:	89 d8                	mov    %ebx,%eax
  802b9a:	89 fa                	mov    %edi,%edx
  802b9c:	83 c4 1c             	add    $0x1c,%esp
  802b9f:	5b                   	pop    %ebx
  802ba0:	5e                   	pop    %esi
  802ba1:	5f                   	pop    %edi
  802ba2:	5d                   	pop    %ebp
  802ba3:	c3                   	ret    
  802ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ba8:	39 ce                	cmp    %ecx,%esi
  802baa:	72 0c                	jb     802bb8 <__udivdi3+0x118>
  802bac:	31 db                	xor    %ebx,%ebx
  802bae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802bb2:	0f 87 34 ff ff ff    	ja     802aec <__udivdi3+0x4c>
  802bb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802bbd:	e9 2a ff ff ff       	jmp    802aec <__udivdi3+0x4c>
  802bc2:	66 90                	xchg   %ax,%ax
  802bc4:	66 90                	xchg   %ax,%ax
  802bc6:	66 90                	xchg   %ax,%ax
  802bc8:	66 90                	xchg   %ax,%ax
  802bca:	66 90                	xchg   %ax,%ax
  802bcc:	66 90                	xchg   %ax,%ax
  802bce:	66 90                	xchg   %ax,%ax

00802bd0 <__umoddi3>:
  802bd0:	55                   	push   %ebp
  802bd1:	57                   	push   %edi
  802bd2:	56                   	push   %esi
  802bd3:	53                   	push   %ebx
  802bd4:	83 ec 1c             	sub    $0x1c,%esp
  802bd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802bdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802bdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802be7:	85 d2                	test   %edx,%edx
  802be9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bf1:	89 f3                	mov    %esi,%ebx
  802bf3:	89 3c 24             	mov    %edi,(%esp)
  802bf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802bfa:	75 1c                	jne    802c18 <__umoddi3+0x48>
  802bfc:	39 f7                	cmp    %esi,%edi
  802bfe:	76 50                	jbe    802c50 <__umoddi3+0x80>
  802c00:	89 c8                	mov    %ecx,%eax
  802c02:	89 f2                	mov    %esi,%edx
  802c04:	f7 f7                	div    %edi
  802c06:	89 d0                	mov    %edx,%eax
  802c08:	31 d2                	xor    %edx,%edx
  802c0a:	83 c4 1c             	add    $0x1c,%esp
  802c0d:	5b                   	pop    %ebx
  802c0e:	5e                   	pop    %esi
  802c0f:	5f                   	pop    %edi
  802c10:	5d                   	pop    %ebp
  802c11:	c3                   	ret    
  802c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c18:	39 f2                	cmp    %esi,%edx
  802c1a:	89 d0                	mov    %edx,%eax
  802c1c:	77 52                	ja     802c70 <__umoddi3+0xa0>
  802c1e:	0f bd ea             	bsr    %edx,%ebp
  802c21:	83 f5 1f             	xor    $0x1f,%ebp
  802c24:	75 5a                	jne    802c80 <__umoddi3+0xb0>
  802c26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802c2a:	0f 82 e0 00 00 00    	jb     802d10 <__umoddi3+0x140>
  802c30:	39 0c 24             	cmp    %ecx,(%esp)
  802c33:	0f 86 d7 00 00 00    	jbe    802d10 <__umoddi3+0x140>
  802c39:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c41:	83 c4 1c             	add    $0x1c,%esp
  802c44:	5b                   	pop    %ebx
  802c45:	5e                   	pop    %esi
  802c46:	5f                   	pop    %edi
  802c47:	5d                   	pop    %ebp
  802c48:	c3                   	ret    
  802c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c50:	85 ff                	test   %edi,%edi
  802c52:	89 fd                	mov    %edi,%ebp
  802c54:	75 0b                	jne    802c61 <__umoddi3+0x91>
  802c56:	b8 01 00 00 00       	mov    $0x1,%eax
  802c5b:	31 d2                	xor    %edx,%edx
  802c5d:	f7 f7                	div    %edi
  802c5f:	89 c5                	mov    %eax,%ebp
  802c61:	89 f0                	mov    %esi,%eax
  802c63:	31 d2                	xor    %edx,%edx
  802c65:	f7 f5                	div    %ebp
  802c67:	89 c8                	mov    %ecx,%eax
  802c69:	f7 f5                	div    %ebp
  802c6b:	89 d0                	mov    %edx,%eax
  802c6d:	eb 99                	jmp    802c08 <__umoddi3+0x38>
  802c6f:	90                   	nop
  802c70:	89 c8                	mov    %ecx,%eax
  802c72:	89 f2                	mov    %esi,%edx
  802c74:	83 c4 1c             	add    $0x1c,%esp
  802c77:	5b                   	pop    %ebx
  802c78:	5e                   	pop    %esi
  802c79:	5f                   	pop    %edi
  802c7a:	5d                   	pop    %ebp
  802c7b:	c3                   	ret    
  802c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c80:	8b 34 24             	mov    (%esp),%esi
  802c83:	bf 20 00 00 00       	mov    $0x20,%edi
  802c88:	89 e9                	mov    %ebp,%ecx
  802c8a:	29 ef                	sub    %ebp,%edi
  802c8c:	d3 e0                	shl    %cl,%eax
  802c8e:	89 f9                	mov    %edi,%ecx
  802c90:	89 f2                	mov    %esi,%edx
  802c92:	d3 ea                	shr    %cl,%edx
  802c94:	89 e9                	mov    %ebp,%ecx
  802c96:	09 c2                	or     %eax,%edx
  802c98:	89 d8                	mov    %ebx,%eax
  802c9a:	89 14 24             	mov    %edx,(%esp)
  802c9d:	89 f2                	mov    %esi,%edx
  802c9f:	d3 e2                	shl    %cl,%edx
  802ca1:	89 f9                	mov    %edi,%ecx
  802ca3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ca7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802cab:	d3 e8                	shr    %cl,%eax
  802cad:	89 e9                	mov    %ebp,%ecx
  802caf:	89 c6                	mov    %eax,%esi
  802cb1:	d3 e3                	shl    %cl,%ebx
  802cb3:	89 f9                	mov    %edi,%ecx
  802cb5:	89 d0                	mov    %edx,%eax
  802cb7:	d3 e8                	shr    %cl,%eax
  802cb9:	89 e9                	mov    %ebp,%ecx
  802cbb:	09 d8                	or     %ebx,%eax
  802cbd:	89 d3                	mov    %edx,%ebx
  802cbf:	89 f2                	mov    %esi,%edx
  802cc1:	f7 34 24             	divl   (%esp)
  802cc4:	89 d6                	mov    %edx,%esi
  802cc6:	d3 e3                	shl    %cl,%ebx
  802cc8:	f7 64 24 04          	mull   0x4(%esp)
  802ccc:	39 d6                	cmp    %edx,%esi
  802cce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cd2:	89 d1                	mov    %edx,%ecx
  802cd4:	89 c3                	mov    %eax,%ebx
  802cd6:	72 08                	jb     802ce0 <__umoddi3+0x110>
  802cd8:	75 11                	jne    802ceb <__umoddi3+0x11b>
  802cda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802cde:	73 0b                	jae    802ceb <__umoddi3+0x11b>
  802ce0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802ce4:	1b 14 24             	sbb    (%esp),%edx
  802ce7:	89 d1                	mov    %edx,%ecx
  802ce9:	89 c3                	mov    %eax,%ebx
  802ceb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802cef:	29 da                	sub    %ebx,%edx
  802cf1:	19 ce                	sbb    %ecx,%esi
  802cf3:	89 f9                	mov    %edi,%ecx
  802cf5:	89 f0                	mov    %esi,%eax
  802cf7:	d3 e0                	shl    %cl,%eax
  802cf9:	89 e9                	mov    %ebp,%ecx
  802cfb:	d3 ea                	shr    %cl,%edx
  802cfd:	89 e9                	mov    %ebp,%ecx
  802cff:	d3 ee                	shr    %cl,%esi
  802d01:	09 d0                	or     %edx,%eax
  802d03:	89 f2                	mov    %esi,%edx
  802d05:	83 c4 1c             	add    $0x1c,%esp
  802d08:	5b                   	pop    %ebx
  802d09:	5e                   	pop    %esi
  802d0a:	5f                   	pop    %edi
  802d0b:	5d                   	pop    %ebp
  802d0c:	c3                   	ret    
  802d0d:	8d 76 00             	lea    0x0(%esi),%esi
  802d10:	29 f9                	sub    %edi,%ecx
  802d12:	19 d6                	sbb    %edx,%esi
  802d14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d1c:	e9 18 ff ff ff       	jmp    802c39 <__umoddi3+0x69>
