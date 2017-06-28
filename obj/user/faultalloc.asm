
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 80 23 80 00       	push   $0x802380
  800045:	e8 c3 01 00 00       	call   80020d <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 37 0b 00 00       	call   800b95 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 23 80 00       	push   $0x8023a0
  80006f:	6a 0e                	push   $0xe
  800071:	68 8a 23 80 00       	push   $0x80238a
  800076:	e8 b9 00 00 00       	call   800134 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 23 80 00       	push   $0x8023cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 b6 06 00 00       	call   80073f <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 25 0d 00 00       	call   800dc6 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 23 80 00       	push   $0x80239c
  8000ae:	e8 5a 01 00 00       	call   80020d <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 23 80 00       	push   $0x80239c
  8000c0:	e8 48 01 00 00       	call   80020d <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d5:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  8000dc:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000df:	e8 73 0a 00 00       	call   800b57 <sys_getenvid>
  8000e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f1:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f6:	85 db                	test   %ebx,%ebx
  8000f8:	7e 07                	jle    800101 <libmain+0x37>
		binaryname = argv[0];
  8000fa:	8b 06                	mov    (%esi),%eax
  8000fc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 86 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  80010b:	e8 0a 00 00 00       	call   80011a <exit>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800120:	e8 ff 0e 00 00       	call   801024 <close_all>
	sys_env_destroy(0);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	6a 00                	push   $0x0
  80012a:	e8 e7 09 00 00       	call   800b16 <sys_env_destroy>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800142:	e8 10 0a 00 00       	call   800b57 <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 f8 23 80 00       	push   $0x8023f8
  800157:	e8 b1 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 54 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
  80016f:	e8 99 00 00 00       	call   80020d <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 1a                	jne    8001b3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 2f 09 00 00       	call   800ad9 <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	ff 75 0c             	pushl  0xc(%ebp)
  8001dc:	ff 75 08             	pushl  0x8(%ebp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	68 7a 01 80 00       	push   $0x80017a
  8001eb:	e8 54 01 00 00       	call   800344 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f0:	83 c4 08             	add    $0x8,%esp
  8001f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	e8 d4 08 00 00       	call   800ad9 <sys_cputs>

	return b.cnt;
}
  800205:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800213:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800216:	50                   	push   %eax
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 9d ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 1c             	sub    $0x1c,%esp
  80022a:	89 c7                	mov    %eax,%edi
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800245:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800248:	39 d3                	cmp    %edx,%ebx
  80024a:	72 05                	jb     800251 <printnum+0x30>
  80024c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024f:	77 45                	ja     800296 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	8b 45 14             	mov    0x14(%ebp),%eax
  80025a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025d:	53                   	push   %ebx
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 e4             	pushl  -0x1c(%ebp)
  800267:	ff 75 e0             	pushl  -0x20(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 7b 1e 00 00       	call   8020f0 <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 f2                	mov    %esi,%edx
  80027c:	89 f8                	mov    %edi,%eax
  80027e:	e8 9e ff ff ff       	call   800221 <printnum>
  800283:	83 c4 20             	add    $0x20,%esp
  800286:	eb 18                	jmp    8002a0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	ff 75 18             	pushl  0x18(%ebp)
  80028f:	ff d7                	call   *%edi
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	eb 03                	jmp    800299 <printnum+0x78>
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800299:	83 eb 01             	sub    $0x1,%ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f e8                	jg     800288 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	56                   	push   %esi
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b3:	e8 68 1f 00 00       	call   802220 <__umoddi3>
  8002b8:	83 c4 14             	add    $0x14,%esp
  8002bb:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  8002c2:	50                   	push   %eax
  8002c3:	ff d7                	call   *%edi
}
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d3:	83 fa 01             	cmp    $0x1,%edx
  8002d6:	7e 0e                	jle    8002e6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	8b 52 04             	mov    0x4(%edx),%edx
  8002e4:	eb 22                	jmp    800308 <getuint+0x38>
	else if (lflag)
  8002e6:	85 d2                	test   %edx,%edx
  8002e8:	74 10                	je     8002fa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	eb 0e                	jmp    800308 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800310:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800314:	8b 10                	mov    (%eax),%edx
  800316:	3b 50 04             	cmp    0x4(%eax),%edx
  800319:	73 0a                	jae    800325 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	88 02                	mov    %al,(%edx)
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800330:	50                   	push   %eax
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	ff 75 0c             	pushl  0xc(%ebp)
  800337:	ff 75 08             	pushl  0x8(%ebp)
  80033a:	e8 05 00 00 00       	call   800344 <vprintfmt>
	va_end(ap);
}
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 2c             	sub    $0x2c,%esp
  80034d:	8b 75 08             	mov    0x8(%ebp),%esi
  800350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800353:	8b 7d 10             	mov    0x10(%ebp),%edi
  800356:	eb 12                	jmp    80036a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 89 03 00 00    	je     8006e9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	53                   	push   %ebx
  800364:	50                   	push   %eax
  800365:	ff d6                	call   *%esi
  800367:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036a:	83 c7 01             	add    $0x1,%edi
  80036d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800371:	83 f8 25             	cmp    $0x25,%eax
  800374:	75 e2                	jne    800358 <vprintfmt+0x14>
  800376:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800381:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800388:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038f:	ba 00 00 00 00       	mov    $0x0,%edx
  800394:	eb 07                	jmp    80039d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800399:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8d 47 01             	lea    0x1(%edi),%eax
  8003a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a3:	0f b6 07             	movzbl (%edi),%eax
  8003a6:	0f b6 c8             	movzbl %al,%ecx
  8003a9:	83 e8 23             	sub    $0x23,%eax
  8003ac:	3c 55                	cmp    $0x55,%al
  8003ae:	0f 87 1a 03 00 00    	ja     8006ce <vprintfmt+0x38a>
  8003b4:	0f b6 c0             	movzbl %al,%eax
  8003b7:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c5:	eb d6                	jmp    80039d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003dc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003df:	83 fa 09             	cmp    $0x9,%edx
  8003e2:	77 39                	ja     80041d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e7:	eb e9                	jmp    8003d2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fa:	eb 27                	jmp    800423 <vprintfmt+0xdf>
  8003fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ff:	85 c0                	test   %eax,%eax
  800401:	b9 00 00 00 00       	mov    $0x0,%ecx
  800406:	0f 49 c8             	cmovns %eax,%ecx
  800409:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	eb 8c                	jmp    80039d <vprintfmt+0x59>
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800414:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041b:	eb 80                	jmp    80039d <vprintfmt+0x59>
  80041d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800427:	0f 89 70 ff ff ff    	jns    80039d <vprintfmt+0x59>
				width = precision, precision = -1;
  80042d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043a:	e9 5e ff ff ff       	jmp    80039d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800445:	e9 53 ff ff ff       	jmp    80039d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	53                   	push   %ebx
  800457:	ff 30                	pushl  (%eax)
  800459:	ff d6                	call   *%esi
			break;
  80045b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800461:	e9 04 ff ff ff       	jmp    80036a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	99                   	cltd   
  800472:	31 d0                	xor    %edx,%eax
  800474:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800476:	83 f8 0f             	cmp    $0xf,%eax
  800479:	7f 0b                	jg     800486 <vprintfmt+0x142>
  80047b:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	75 18                	jne    80049e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800486:	50                   	push   %eax
  800487:	68 33 24 80 00       	push   $0x802433
  80048c:	53                   	push   %ebx
  80048d:	56                   	push   %esi
  80048e:	e8 94 fe ff ff       	call   800327 <printfmt>
  800493:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800499:	e9 cc fe ff ff       	jmp    80036a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80049e:	52                   	push   %edx
  80049f:	68 41 28 80 00       	push   $0x802841
  8004a4:	53                   	push   %ebx
  8004a5:	56                   	push   %esi
  8004a6:	e8 7c fe ff ff       	call   800327 <printfmt>
  8004ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b1:	e9 b4 fe ff ff       	jmp    80036a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c1:	85 ff                	test   %edi,%edi
  8004c3:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  8004c8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cf:	0f 8e 94 00 00 00    	jle    800569 <vprintfmt+0x225>
  8004d5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d9:	0f 84 98 00 00 00    	je     800577 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e5:	57                   	push   %edi
  8004e6:	e8 86 02 00 00       	call   800771 <strnlen>
  8004eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800500:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	eb 0f                	jmp    800513 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 75 e0             	pushl  -0x20(%ebp)
  80050b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ef 01             	sub    $0x1,%edi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 ff                	test   %edi,%edi
  800515:	7f ed                	jg     800504 <vprintfmt+0x1c0>
  800517:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	b8 00 00 00 00       	mov    $0x0,%eax
  800524:	0f 49 c1             	cmovns %ecx,%eax
  800527:	29 c1                	sub    %eax,%ecx
  800529:	89 75 08             	mov    %esi,0x8(%ebp)
  80052c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800532:	89 cb                	mov    %ecx,%ebx
  800534:	eb 4d                	jmp    800583 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800536:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053a:	74 1b                	je     800557 <vprintfmt+0x213>
  80053c:	0f be c0             	movsbl %al,%eax
  80053f:	83 e8 20             	sub    $0x20,%eax
  800542:	83 f8 5e             	cmp    $0x5e,%eax
  800545:	76 10                	jbe    800557 <vprintfmt+0x213>
					putch('?', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	ff 75 0c             	pushl  0xc(%ebp)
  80054d:	6a 3f                	push   $0x3f
  80054f:	ff 55 08             	call   *0x8(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	eb 0d                	jmp    800564 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 0c             	pushl  0xc(%ebp)
  80055d:	52                   	push   %edx
  80055e:	ff 55 08             	call   *0x8(%ebp)
  800561:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	eb 1a                	jmp    800583 <vprintfmt+0x23f>
  800569:	89 75 08             	mov    %esi,0x8(%ebp)
  80056c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800572:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800575:	eb 0c                	jmp    800583 <vprintfmt+0x23f>
  800577:	89 75 08             	mov    %esi,0x8(%ebp)
  80057a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800580:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800583:	83 c7 01             	add    $0x1,%edi
  800586:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058a:	0f be d0             	movsbl %al,%edx
  80058d:	85 d2                	test   %edx,%edx
  80058f:	74 23                	je     8005b4 <vprintfmt+0x270>
  800591:	85 f6                	test   %esi,%esi
  800593:	78 a1                	js     800536 <vprintfmt+0x1f2>
  800595:	83 ee 01             	sub    $0x1,%esi
  800598:	79 9c                	jns    800536 <vprintfmt+0x1f2>
  80059a:	89 df                	mov    %ebx,%edi
  80059c:	8b 75 08             	mov    0x8(%ebp),%esi
  80059f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a2:	eb 18                	jmp    8005bc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	6a 20                	push   $0x20
  8005aa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ac:	83 ef 01             	sub    $0x1,%edi
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	eb 08                	jmp    8005bc <vprintfmt+0x278>
  8005b4:	89 df                	mov    %ebx,%edi
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	7f e4                	jg     8005a4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c3:	e9 a2 fd ff ff       	jmp    80036a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 fa 01             	cmp    $0x1,%edx
  8005cb:	7e 16                	jle    8005e3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 08             	lea    0x8(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 50 04             	mov    0x4(%eax),%edx
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e1:	eb 32                	jmp    800615 <vprintfmt+0x2d1>
	else if (lflag)
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	74 18                	je     8005ff <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 04             	lea    0x4(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 c1                	mov    %eax,%ecx
  8005f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fd:	eb 16                	jmp    800615 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 00                	mov    (%eax),%eax
  80060a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060d:	89 c1                	mov    %eax,%ecx
  80060f:	c1 f9 1f             	sar    $0x1f,%ecx
  800612:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800615:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800618:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800620:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800624:	79 74                	jns    80069a <vprintfmt+0x356>
				putch('-', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 2d                	push   $0x2d
  80062c:	ff d6                	call   *%esi
				num = -(long long) num;
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800634:	f7 d8                	neg    %eax
  800636:	83 d2 00             	adc    $0x0,%edx
  800639:	f7 da                	neg    %edx
  80063b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800643:	eb 55                	jmp    80069a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 83 fc ff ff       	call   8002d0 <getuint>
			base = 10;
  80064d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800652:	eb 46                	jmp    80069a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 74 fc ff ff       	call   8002d0 <getuint>
		        base = 8;
  80065c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800661:	eb 37                	jmp    80069a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 30                	push   $0x30
  800669:	ff d6                	call   *%esi
			putch('x', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 78                	push   $0x78
  800671:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 04             	lea    0x4(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800683:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800686:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
  800690:	e8 3b fc ff ff       	call   8002d0 <getuint>
			base = 16;
  800695:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a1:	57                   	push   %edi
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	51                   	push   %ecx
  8006a6:	52                   	push   %edx
  8006a7:	50                   	push   %eax
  8006a8:	89 da                	mov    %ebx,%edx
  8006aa:	89 f0                	mov    %esi,%eax
  8006ac:	e8 70 fb ff ff       	call   800221 <printnum>
			break;
  8006b1:	83 c4 20             	add    $0x20,%esp
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b7:	e9 ae fc ff ff       	jmp    80036a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	51                   	push   %ecx
  8006c1:	ff d6                	call   *%esi
			break;
  8006c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c9:	e9 9c fc ff ff       	jmp    80036a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 25                	push   $0x25
  8006d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 03                	jmp    8006de <vprintfmt+0x39a>
  8006db:	83 ef 01             	sub    $0x1,%edi
  8006de:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e2:	75 f7                	jne    8006db <vprintfmt+0x397>
  8006e4:	e9 81 fc ff ff       	jmp    80036a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 18             	sub    $0x18,%esp
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800700:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800704:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800707:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 26                	je     800738 <vsnprintf+0x47>
  800712:	85 d2                	test   %edx,%edx
  800714:	7e 22                	jle    800738 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800716:	ff 75 14             	pushl  0x14(%ebp)
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	68 0a 03 80 00       	push   $0x80030a
  800725:	e8 1a fc ff ff       	call   800344 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	eb 05                	jmp    80073d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800738:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800748:	50                   	push   %eax
  800749:	ff 75 10             	pushl  0x10(%ebp)
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	ff 75 08             	pushl  0x8(%ebp)
  800752:	e8 9a ff ff ff       	call   8006f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	eb 03                	jmp    800769 <strlen+0x10>
		n++;
  800766:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800769:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076d:	75 f7                	jne    800766 <strlen+0xd>
		n++;
	return n;
}
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800777:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	eb 03                	jmp    800784 <strnlen+0x13>
		n++;
  800781:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	39 c2                	cmp    %eax,%edx
  800786:	74 08                	je     800790 <strnlen+0x1f>
  800788:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078c:	75 f3                	jne    800781 <strnlen+0x10>
  80078e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	83 c2 01             	add    $0x1,%edx
  8007a1:	83 c1 01             	add    $0x1,%ecx
  8007a4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ab:	84 db                	test   %bl,%bl
  8007ad:	75 ef                	jne    80079e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007af:	5b                   	pop    %ebx
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b9:	53                   	push   %ebx
  8007ba:	e8 9a ff ff ff       	call   800759 <strlen>
  8007bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	01 d8                	add    %ebx,%eax
  8007c7:	50                   	push   %eax
  8007c8:	e8 c5 ff ff ff       	call   800792 <strcpy>
	return dst;
}
  8007cd:	89 d8                	mov    %ebx,%eax
  8007cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	89 f3                	mov    %esi,%ebx
  8007e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	eb 0f                	jmp    8007f7 <strncpy+0x23>
		*dst++ = *src;
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	0f b6 01             	movzbl (%ecx),%eax
  8007ee:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f7:	39 da                	cmp    %ebx,%edx
  8007f9:	75 ed                	jne    8007e8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fb:	89 f0                	mov    %esi,%eax
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	8b 75 08             	mov    0x8(%ebp),%esi
  800809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080c:	8b 55 10             	mov    0x10(%ebp),%edx
  80080f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800811:	85 d2                	test   %edx,%edx
  800813:	74 21                	je     800836 <strlcpy+0x35>
  800815:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800819:	89 f2                	mov    %esi,%edx
  80081b:	eb 09                	jmp    800826 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800826:	39 c2                	cmp    %eax,%edx
  800828:	74 09                	je     800833 <strlcpy+0x32>
  80082a:	0f b6 19             	movzbl (%ecx),%ebx
  80082d:	84 db                	test   %bl,%bl
  80082f:	75 ec                	jne    80081d <strlcpy+0x1c>
  800831:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800833:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800836:	29 f0                	sub    %esi,%eax
}
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800845:	eb 06                	jmp    80084d <strcmp+0x11>
		p++, q++;
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084d:	0f b6 01             	movzbl (%ecx),%eax
  800850:	84 c0                	test   %al,%al
  800852:	74 04                	je     800858 <strcmp+0x1c>
  800854:	3a 02                	cmp    (%edx),%al
  800856:	74 ef                	je     800847 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800858:	0f b6 c0             	movzbl %al,%eax
  80085b:	0f b6 12             	movzbl (%edx),%edx
  80085e:	29 d0                	sub    %edx,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	89 c3                	mov    %eax,%ebx
  80086e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800871:	eb 06                	jmp    800879 <strncmp+0x17>
		n--, p++, q++;
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800879:	39 d8                	cmp    %ebx,%eax
  80087b:	74 15                	je     800892 <strncmp+0x30>
  80087d:	0f b6 08             	movzbl (%eax),%ecx
  800880:	84 c9                	test   %cl,%cl
  800882:	74 04                	je     800888 <strncmp+0x26>
  800884:	3a 0a                	cmp    (%edx),%cl
  800886:	74 eb                	je     800873 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 00             	movzbl (%eax),%eax
  80088b:	0f b6 12             	movzbl (%edx),%edx
  80088e:	29 d0                	sub    %edx,%eax
  800890:	eb 05                	jmp    800897 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a4:	eb 07                	jmp    8008ad <strchr+0x13>
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 0f                	je     8008b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	75 f2                	jne    8008a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	eb 03                	jmp    8008ca <strfind+0xf>
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 04                	je     8008d5 <strfind+0x1a>
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f2                	jne    8008c7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 36                	je     80091d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ed:	75 28                	jne    800917 <memset+0x40>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 23                	jne    800917 <memset+0x40>
		c &= 0xFF;
  8008f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 08             	shl    $0x8,%ebx
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 18             	shl    $0x18,%esi
  800902:	89 d0                	mov    %edx,%eax
  800904:	c1 e0 10             	shl    $0x10,%eax
  800907:	09 f0                	or     %esi,%eax
  800909:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090b:	89 d8                	mov    %ebx,%eax
  80090d:	09 d0                	or     %edx,%eax
  80090f:	c1 e9 02             	shr    $0x2,%ecx
  800912:	fc                   	cld    
  800913:	f3 ab                	rep stos %eax,%es:(%edi)
  800915:	eb 06                	jmp    80091d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	57                   	push   %edi
  800928:	56                   	push   %esi
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800932:	39 c6                	cmp    %eax,%esi
  800934:	73 35                	jae    80096b <memmove+0x47>
  800936:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	73 2e                	jae    80096b <memmove+0x47>
		s += n;
		d += n;
  80093d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800940:	89 d6                	mov    %edx,%esi
  800942:	09 fe                	or     %edi,%esi
  800944:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094a:	75 13                	jne    80095f <memmove+0x3b>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 0e                	jne    80095f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800951:	83 ef 04             	sub    $0x4,%edi
  800954:	8d 72 fc             	lea    -0x4(%edx),%esi
  800957:	c1 e9 02             	shr    $0x2,%ecx
  80095a:	fd                   	std    
  80095b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095d:	eb 09                	jmp    800968 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095f:	83 ef 01             	sub    $0x1,%edi
  800962:	8d 72 ff             	lea    -0x1(%edx),%esi
  800965:	fd                   	std    
  800966:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800968:	fc                   	cld    
  800969:	eb 1d                	jmp    800988 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	89 f2                	mov    %esi,%edx
  80096d:	09 c2                	or     %eax,%edx
  80096f:	f6 c2 03             	test   $0x3,%dl
  800972:	75 0f                	jne    800983 <memmove+0x5f>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0a                	jne    800983 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800979:	c1 e9 02             	shr    $0x2,%ecx
  80097c:	89 c7                	mov    %eax,%edi
  80097e:	fc                   	cld    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 05                	jmp    800988 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098f:	ff 75 10             	pushl  0x10(%ebp)
  800992:	ff 75 0c             	pushl  0xc(%ebp)
  800995:	ff 75 08             	pushl  0x8(%ebp)
  800998:	e8 87 ff ff ff       	call   800924 <memmove>
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	89 c6                	mov    %eax,%esi
  8009ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	eb 1a                	jmp    8009cb <memcmp+0x2c>
		if (*s1 != *s2)
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	0f b6 1a             	movzbl (%edx),%ebx
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	74 0a                	je     8009c5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bb:	0f b6 c1             	movzbl %cl,%eax
  8009be:	0f b6 db             	movzbl %bl,%ebx
  8009c1:	29 d8                	sub    %ebx,%eax
  8009c3:	eb 0f                	jmp    8009d4 <memcmp+0x35>
		s1++, s2++;
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cb:	39 f0                	cmp    %esi,%eax
  8009cd:	75 e2                	jne    8009b1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5e                   	pop    %esi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	53                   	push   %ebx
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009df:	89 c1                	mov    %eax,%ecx
  8009e1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e8:	eb 0a                	jmp    8009f4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	0f b6 10             	movzbl (%eax),%edx
  8009ed:	39 da                	cmp    %ebx,%edx
  8009ef:	74 07                	je     8009f8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	39 c8                	cmp    %ecx,%eax
  8009f6:	72 f2                	jb     8009ea <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a07:	eb 03                	jmp    800a0c <strtol+0x11>
		s++;
  800a09:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	0f b6 01             	movzbl (%ecx),%eax
  800a0f:	3c 20                	cmp    $0x20,%al
  800a11:	74 f6                	je     800a09 <strtol+0xe>
  800a13:	3c 09                	cmp    $0x9,%al
  800a15:	74 f2                	je     800a09 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a17:	3c 2b                	cmp    $0x2b,%al
  800a19:	75 0a                	jne    800a25 <strtol+0x2a>
		s++;
  800a1b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb 11                	jmp    800a36 <strtol+0x3b>
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2a:	3c 2d                	cmp    $0x2d,%al
  800a2c:	75 08                	jne    800a36 <strtol+0x3b>
		s++, neg = 1;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3c:	75 15                	jne    800a53 <strtol+0x58>
  800a3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a41:	75 10                	jne    800a53 <strtol+0x58>
  800a43:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a47:	75 7c                	jne    800ac5 <strtol+0xca>
		s += 2, base = 16;
  800a49:	83 c1 02             	add    $0x2,%ecx
  800a4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a51:	eb 16                	jmp    800a69 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a53:	85 db                	test   %ebx,%ebx
  800a55:	75 12                	jne    800a69 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a57:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5f:	75 08                	jne    800a69 <strtol+0x6e>
		s++, base = 8;
  800a61:	83 c1 01             	add    $0x1,%ecx
  800a64:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a71:	0f b6 11             	movzbl (%ecx),%edx
  800a74:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 09             	cmp    $0x9,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x8b>
			dig = *s - '0';
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 30             	sub    $0x30,%edx
  800a84:	eb 22                	jmp    800aa8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a86:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 57             	sub    $0x57,%edx
  800a96:	eb 10                	jmp    800aa8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a98:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 19             	cmp    $0x19,%bl
  800aa0:	77 16                	ja     800ab8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aab:	7d 0b                	jge    800ab8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab6:	eb b9                	jmp    800a71 <strtol+0x76>

	if (endptr)
  800ab8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abc:	74 0d                	je     800acb <strtol+0xd0>
		*endptr = (char *) s;
  800abe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac1:	89 0e                	mov    %ecx,(%esi)
  800ac3:	eb 06                	jmp    800acb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	74 98                	je     800a61 <strtol+0x66>
  800ac9:	eb 9e                	jmp    800a69 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	f7 da                	neg    %edx
  800acf:	85 ff                	test   %edi,%edi
  800ad1:	0f 45 c2             	cmovne %edx,%eax
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aea:	89 c3                	mov    %eax,%ebx
  800aec:	89 c7                	mov    %eax,%edi
  800aee:	89 c6                	mov    %eax,%esi
  800af0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afd:	ba 00 00 00 00       	mov    $0x0,%edx
  800b02:	b8 01 00 00 00       	mov    $0x1,%eax
  800b07:	89 d1                	mov    %edx,%ecx
  800b09:	89 d3                	mov    %edx,%ebx
  800b0b:	89 d7                	mov    %edx,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b24:	b8 03 00 00 00       	mov    $0x3,%eax
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	89 cb                	mov    %ecx,%ebx
  800b2e:	89 cf                	mov    %ecx,%edi
  800b30:	89 ce                	mov    %ecx,%esi
  800b32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b34:	85 c0                	test   %eax,%eax
  800b36:	7e 17                	jle    800b4f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 03                	push   $0x3
  800b3e:	68 1f 27 80 00       	push   $0x80271f
  800b43:	6a 23                	push   $0x23
  800b45:	68 3c 27 80 00       	push   $0x80273c
  800b4a:	e8 e5 f5 ff ff       	call   800134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 02 00 00 00       	mov    $0x2,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_yield>:

void
sys_yield(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ba3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb1:	89 f7                	mov    %esi,%edi
  800bb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7e 17                	jle    800bd0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 04                	push   $0x4
  800bbf:	68 1f 27 80 00       	push   $0x80271f
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 3c 27 80 00       	push   $0x80273c
  800bcb:	e8 64 f5 ff ff       	call   800134 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b8 05 00 00 00       	mov    $0x5,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bef:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf2:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 05                	push   $0x5
  800c01:	68 1f 27 80 00       	push   $0x80271f
  800c06:	6a 23                	push   $0x23
  800c08:	68 3c 27 80 00       	push   $0x80273c
  800c0d:	e8 22 f5 ff ff       	call   800134 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	89 de                	mov    %ebx,%esi
  800c37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 06                	push   $0x6
  800c43:	68 1f 27 80 00       	push   $0x80271f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 3c 27 80 00       	push   $0x80273c
  800c4f:	e8 e0 f4 ff ff       	call   800134 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 08                	push   $0x8
  800c85:	68 1f 27 80 00       	push   $0x80271f
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 3c 27 80 00       	push   $0x80273c
  800c91:	e8 9e f4 ff ff       	call   800134 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cac:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 df                	mov    %ebx,%edi
  800cb9:	89 de                	mov    %ebx,%esi
  800cbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 09                	push   $0x9
  800cc7:	68 1f 27 80 00       	push   $0x80271f
  800ccc:	6a 23                	push   $0x23
  800cce:	68 3c 27 80 00       	push   $0x80273c
  800cd3:	e8 5c f4 ff ff       	call   800134 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 0a                	push   $0xa
  800d09:	68 1f 27 80 00       	push   $0x80271f
  800d0e:	6a 23                	push   $0x23
  800d10:	68 3c 27 80 00       	push   $0x80273c
  800d15:	e8 1a f4 ff ff       	call   800134 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	be 00 00 00 00       	mov    $0x0,%esi
  800d2d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d53:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 cb                	mov    %ecx,%ebx
  800d5d:	89 cf                	mov    %ecx,%edi
  800d5f:	89 ce                	mov    %ecx,%esi
  800d61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 17                	jle    800d7e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 0d                	push   $0xd
  800d6d:	68 1f 27 80 00       	push   $0x80271f
  800d72:	6a 23                	push   $0x23
  800d74:	68 3c 27 80 00       	push   $0x80273c
  800d79:	e8 b6 f3 ff ff       	call   800134 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d91:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d96:	89 d1                	mov    %edx,%ecx
  800d98:	89 d3                	mov    %edx,%ebx
  800d9a:	89 d7                	mov    %edx,%edi
  800d9c:	89 d6                	mov    %edx,%esi
  800d9e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dcc:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800dd3:	75 2c                	jne    800e01 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	6a 07                	push   $0x7
  800dda:	68 00 f0 bf ee       	push   $0xeebff000
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 af fd ff ff       	call   800b95 <sys_page_alloc>
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	79 14                	jns    800e01 <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	68 4a 27 80 00       	push   $0x80274a
  800df5:	6a 22                	push   $0x22
  800df7:	68 61 27 80 00       	push   $0x802761
  800dfc:	e8 33 f3 ff ff       	call   800134 <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	a3 0c 40 80 00       	mov    %eax,0x80400c
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800e09:	83 ec 08             	sub    $0x8,%esp
  800e0c:	68 35 0e 80 00       	push   $0x800e35
  800e11:	6a 00                	push   $0x0
  800e13:	e8 c8 fe ff ff       	call   800ce0 <sys_env_set_pgfault_upcall>
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	79 14                	jns    800e33 <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 70 27 80 00       	push   $0x802770
  800e27:	6a 27                	push   $0x27
  800e29:	68 61 27 80 00       	push   $0x802761
  800e2e:	e8 01 f3 ff ff       	call   800134 <_panic>
    
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e35:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e36:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e3b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e3d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  800e40:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  800e44:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  800e49:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  800e4d:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800e4f:	83 c4 08             	add    $0x8,%esp
	popal
  800e52:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  800e53:	83 c4 04             	add    $0x4,%esp
	popfl
  800e56:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e57:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e58:	c3                   	ret    

00800e59 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e64:	c1 e8 0c             	shr    $0xc,%eax
}
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e79:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e86:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	c1 ea 16             	shr    $0x16,%edx
  800e90:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e97:	f6 c2 01             	test   $0x1,%dl
  800e9a:	74 11                	je     800ead <fd_alloc+0x2d>
  800e9c:	89 c2                	mov    %eax,%edx
  800e9e:	c1 ea 0c             	shr    $0xc,%edx
  800ea1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea8:	f6 c2 01             	test   $0x1,%dl
  800eab:	75 09                	jne    800eb6 <fd_alloc+0x36>
			*fd_store = fd;
  800ead:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	eb 17                	jmp    800ecd <fd_alloc+0x4d>
  800eb6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ebb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ec0:	75 c9                	jne    800e8b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ec2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed5:	83 f8 1f             	cmp    $0x1f,%eax
  800ed8:	77 36                	ja     800f10 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eda:	c1 e0 0c             	shl    $0xc,%eax
  800edd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ee2:	89 c2                	mov    %eax,%edx
  800ee4:	c1 ea 16             	shr    $0x16,%edx
  800ee7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eee:	f6 c2 01             	test   $0x1,%dl
  800ef1:	74 24                	je     800f17 <fd_lookup+0x48>
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	c1 ea 0c             	shr    $0xc,%edx
  800ef8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eff:	f6 c2 01             	test   $0x1,%dl
  800f02:	74 1a                	je     800f1e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f07:	89 02                	mov    %eax,(%edx)
	return 0;
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	eb 13                	jmp    800f23 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f15:	eb 0c                	jmp    800f23 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1c:	eb 05                	jmp    800f23 <fd_lookup+0x54>
  800f1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 08             	sub    $0x8,%esp
  800f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2e:	ba 14 28 80 00       	mov    $0x802814,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f33:	eb 13                	jmp    800f48 <dev_lookup+0x23>
  800f35:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f38:	39 08                	cmp    %ecx,(%eax)
  800f3a:	75 0c                	jne    800f48 <dev_lookup+0x23>
			*dev = devtab[i];
  800f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	eb 2e                	jmp    800f76 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f48:	8b 02                	mov    (%edx),%eax
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	75 e7                	jne    800f35 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f4e:	a1 08 40 80 00       	mov    0x804008,%eax
  800f53:	8b 40 48             	mov    0x48(%eax),%eax
  800f56:	83 ec 04             	sub    $0x4,%esp
  800f59:	51                   	push   %ecx
  800f5a:	50                   	push   %eax
  800f5b:	68 94 27 80 00       	push   $0x802794
  800f60:	e8 a8 f2 ff ff       	call   80020d <cprintf>
	*dev = 0;
  800f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 10             	sub    $0x10,%esp
  800f80:	8b 75 08             	mov    0x8(%ebp),%esi
  800f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f90:	c1 e8 0c             	shr    $0xc,%eax
  800f93:	50                   	push   %eax
  800f94:	e8 36 ff ff ff       	call   800ecf <fd_lookup>
  800f99:	83 c4 08             	add    $0x8,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 05                	js     800fa5 <fd_close+0x2d>
	    || fd != fd2)
  800fa0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fa3:	74 0c                	je     800fb1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fa5:	84 db                	test   %bl,%bl
  800fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fac:	0f 44 c2             	cmove  %edx,%eax
  800faf:	eb 41                	jmp    800ff2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 36                	pushl  (%esi)
  800fba:	e8 66 ff ff ff       	call   800f25 <dev_lookup>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 1a                	js     800fe2 <fd_close+0x6a>
		if (dev->dev_close)
  800fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	74 0b                	je     800fe2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	56                   	push   %esi
  800fdb:	ff d0                	call   *%eax
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	e8 2d fc ff ff       	call   800c1a <sys_page_unmap>
	return r;
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	89 d8                	mov    %ebx,%eax
}
  800ff2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 c4 fe ff ff       	call   800ecf <fd_lookup>
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 10                	js     801022 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	6a 01                	push   $0x1
  801017:	ff 75 f4             	pushl  -0xc(%ebp)
  80101a:	e8 59 ff ff ff       	call   800f78 <fd_close>
  80101f:	83 c4 10             	add    $0x10,%esp
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <close_all>:

void
close_all(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	53                   	push   %ebx
  801028:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	53                   	push   %ebx
  801034:	e8 c0 ff ff ff       	call   800ff9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801039:	83 c3 01             	add    $0x1,%ebx
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	83 fb 20             	cmp    $0x20,%ebx
  801042:	75 ec                	jne    801030 <close_all+0xc>
		close(i);
}
  801044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 2c             	sub    $0x2c,%esp
  801052:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801055:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 6e fe ff ff       	call   800ecf <fd_lookup>
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	0f 88 c1 00 00 00    	js     80112d <dup+0xe4>
		return r;
	close(newfdnum);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	56                   	push   %esi
  801070:	e8 84 ff ff ff       	call   800ff9 <close>

	newfd = INDEX2FD(newfdnum);
  801075:	89 f3                	mov    %esi,%ebx
  801077:	c1 e3 0c             	shl    $0xc,%ebx
  80107a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801080:	83 c4 04             	add    $0x4,%esp
  801083:	ff 75 e4             	pushl  -0x1c(%ebp)
  801086:	e8 de fd ff ff       	call   800e69 <fd2data>
  80108b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80108d:	89 1c 24             	mov    %ebx,(%esp)
  801090:	e8 d4 fd ff ff       	call   800e69 <fd2data>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80109b:	89 f8                	mov    %edi,%eax
  80109d:	c1 e8 16             	shr    $0x16,%eax
  8010a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a7:	a8 01                	test   $0x1,%al
  8010a9:	74 37                	je     8010e2 <dup+0x99>
  8010ab:	89 f8                	mov    %edi,%eax
  8010ad:	c1 e8 0c             	shr    $0xc,%eax
  8010b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 26                	je     8010e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cb:	50                   	push   %eax
  8010cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cf:	6a 00                	push   $0x0
  8010d1:	57                   	push   %edi
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 ff fa ff ff       	call   800bd8 <sys_page_map>
  8010d9:	89 c7                	mov    %eax,%edi
  8010db:	83 c4 20             	add    $0x20,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 2e                	js     801110 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010e5:	89 d0                	mov    %edx,%eax
  8010e7:	c1 e8 0c             	shr    $0xc,%eax
  8010ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f9:	50                   	push   %eax
  8010fa:	53                   	push   %ebx
  8010fb:	6a 00                	push   $0x0
  8010fd:	52                   	push   %edx
  8010fe:	6a 00                	push   $0x0
  801100:	e8 d3 fa ff ff       	call   800bd8 <sys_page_map>
  801105:	89 c7                	mov    %eax,%edi
  801107:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80110a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80110c:	85 ff                	test   %edi,%edi
  80110e:	79 1d                	jns    80112d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801110:	83 ec 08             	sub    $0x8,%esp
  801113:	53                   	push   %ebx
  801114:	6a 00                	push   $0x0
  801116:	e8 ff fa ff ff       	call   800c1a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801121:	6a 00                	push   $0x0
  801123:	e8 f2 fa ff ff       	call   800c1a <sys_page_unmap>
	return r;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	89 f8                	mov    %edi,%eax
}
  80112d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	53                   	push   %ebx
  801139:	83 ec 14             	sub    $0x14,%esp
  80113c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	53                   	push   %ebx
  801144:	e8 86 fd ff ff       	call   800ecf <fd_lookup>
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	89 c2                	mov    %eax,%edx
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 6d                	js     8011bf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801158:	50                   	push   %eax
  801159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115c:	ff 30                	pushl  (%eax)
  80115e:	e8 c2 fd ff ff       	call   800f25 <dev_lookup>
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	78 4c                	js     8011b6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80116a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80116d:	8b 42 08             	mov    0x8(%edx),%eax
  801170:	83 e0 03             	and    $0x3,%eax
  801173:	83 f8 01             	cmp    $0x1,%eax
  801176:	75 21                	jne    801199 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801178:	a1 08 40 80 00       	mov    0x804008,%eax
  80117d:	8b 40 48             	mov    0x48(%eax),%eax
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	53                   	push   %ebx
  801184:	50                   	push   %eax
  801185:	68 d8 27 80 00       	push   $0x8027d8
  80118a:	e8 7e f0 ff ff       	call   80020d <cprintf>
		return -E_INVAL;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801197:	eb 26                	jmp    8011bf <read+0x8a>
	}
	if (!dev->dev_read)
  801199:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119c:	8b 40 08             	mov    0x8(%eax),%eax
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	74 17                	je     8011ba <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	ff 75 10             	pushl  0x10(%ebp)
  8011a9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ac:	52                   	push   %edx
  8011ad:	ff d0                	call   *%eax
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	eb 09                	jmp    8011bf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	eb 05                	jmp    8011bf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011bf:	89 d0                	mov    %edx,%eax
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011da:	eb 21                	jmp    8011fd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011dc:	83 ec 04             	sub    $0x4,%esp
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	29 d8                	sub    %ebx,%eax
  8011e3:	50                   	push   %eax
  8011e4:	89 d8                	mov    %ebx,%eax
  8011e6:	03 45 0c             	add    0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	57                   	push   %edi
  8011eb:	e8 45 ff ff ff       	call   801135 <read>
		if (m < 0)
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 10                	js     801207 <readn+0x41>
			return m;
		if (m == 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 0a                	je     801205 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fb:	01 c3                	add    %eax,%ebx
  8011fd:	39 f3                	cmp    %esi,%ebx
  8011ff:	72 db                	jb     8011dc <readn+0x16>
  801201:	89 d8                	mov    %ebx,%eax
  801203:	eb 02                	jmp    801207 <readn+0x41>
  801205:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120a:	5b                   	pop    %ebx
  80120b:	5e                   	pop    %esi
  80120c:	5f                   	pop    %edi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	53                   	push   %ebx
  801213:	83 ec 14             	sub    $0x14,%esp
  801216:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801219:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	53                   	push   %ebx
  80121e:	e8 ac fc ff ff       	call   800ecf <fd_lookup>
  801223:	83 c4 08             	add    $0x8,%esp
  801226:	89 c2                	mov    %eax,%edx
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 68                	js     801294 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801232:	50                   	push   %eax
  801233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801236:	ff 30                	pushl  (%eax)
  801238:	e8 e8 fc ff ff       	call   800f25 <dev_lookup>
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	78 47                	js     80128b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801244:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801247:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124b:	75 21                	jne    80126e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80124d:	a1 08 40 80 00       	mov    0x804008,%eax
  801252:	8b 40 48             	mov    0x48(%eax),%eax
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	53                   	push   %ebx
  801259:	50                   	push   %eax
  80125a:	68 f4 27 80 00       	push   $0x8027f4
  80125f:	e8 a9 ef ff ff       	call   80020d <cprintf>
		return -E_INVAL;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80126c:	eb 26                	jmp    801294 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80126e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801271:	8b 52 0c             	mov    0xc(%edx),%edx
  801274:	85 d2                	test   %edx,%edx
  801276:	74 17                	je     80128f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	ff 75 10             	pushl  0x10(%ebp)
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	50                   	push   %eax
  801282:	ff d2                	call   *%edx
  801284:	89 c2                	mov    %eax,%edx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	eb 09                	jmp    801294 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	eb 05                	jmp    801294 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801294:	89 d0                	mov    %edx,%eax
  801296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <seek>:

int
seek(int fdnum, off_t offset)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	ff 75 08             	pushl  0x8(%ebp)
  8012a8:	e8 22 fc ff ff       	call   800ecf <fd_lookup>
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 0e                	js     8012c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 14             	sub    $0x14,%esp
  8012cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	53                   	push   %ebx
  8012d3:	e8 f7 fb ff ff       	call   800ecf <fd_lookup>
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 65                	js     801346 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012eb:	ff 30                	pushl  (%eax)
  8012ed:	e8 33 fc ff ff       	call   800f25 <dev_lookup>
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 44                	js     80133d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801300:	75 21                	jne    801323 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801302:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801307:	8b 40 48             	mov    0x48(%eax),%eax
  80130a:	83 ec 04             	sub    $0x4,%esp
  80130d:	53                   	push   %ebx
  80130e:	50                   	push   %eax
  80130f:	68 b4 27 80 00       	push   $0x8027b4
  801314:	e8 f4 ee ff ff       	call   80020d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801321:	eb 23                	jmp    801346 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801323:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801326:	8b 52 18             	mov    0x18(%edx),%edx
  801329:	85 d2                	test   %edx,%edx
  80132b:	74 14                	je     801341 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	ff 75 0c             	pushl  0xc(%ebp)
  801333:	50                   	push   %eax
  801334:	ff d2                	call   *%edx
  801336:	89 c2                	mov    %eax,%edx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	eb 09                	jmp    801346 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	eb 05                	jmp    801346 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801341:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801346:	89 d0                	mov    %edx,%eax
  801348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    

0080134d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80134d:	55                   	push   %ebp
  80134e:	89 e5                	mov    %esp,%ebp
  801350:	53                   	push   %ebx
  801351:	83 ec 14             	sub    $0x14,%esp
  801354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801357:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	ff 75 08             	pushl  0x8(%ebp)
  80135e:	e8 6c fb ff ff       	call   800ecf <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	89 c2                	mov    %eax,%edx
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 58                	js     8013c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801376:	ff 30                	pushl  (%eax)
  801378:	e8 a8 fb ff ff       	call   800f25 <dev_lookup>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 37                	js     8013bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801387:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80138b:	74 32                	je     8013bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80138d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801390:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801397:	00 00 00 
	stat->st_isdir = 0;
  80139a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a1:	00 00 00 
	stat->st_dev = dev;
  8013a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b1:	ff 50 14             	call   *0x14(%eax)
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	eb 09                	jmp    8013c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	eb 05                	jmp    8013c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c4:	89 d0                	mov    %edx,%eax
  8013c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	6a 00                	push   $0x0
  8013d5:	ff 75 08             	pushl  0x8(%ebp)
  8013d8:	e8 e7 01 00 00       	call   8015c4 <open>
  8013dd:	89 c3                	mov    %eax,%ebx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 1b                	js     801401 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	50                   	push   %eax
  8013ed:	e8 5b ff ff ff       	call   80134d <fstat>
  8013f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 fd fb ff ff       	call   800ff9 <close>
	return r;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	89 f0                	mov    %esi,%eax
}
  801401:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801404:	5b                   	pop    %ebx
  801405:	5e                   	pop    %esi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	89 c6                	mov    %eax,%esi
  80140f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801411:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801418:	75 12                	jne    80142c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	6a 01                	push   $0x1
  80141f:	e8 4b 0c 00 00       	call   80206f <ipc_find_env>
  801424:	a3 00 40 80 00       	mov    %eax,0x804000
  801429:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142c:	6a 07                	push   $0x7
  80142e:	68 00 50 80 00       	push   $0x805000
  801433:	56                   	push   %esi
  801434:	ff 35 00 40 80 00    	pushl  0x804000
  80143a:	e8 dc 0b 00 00       	call   80201b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143f:	83 c4 0c             	add    $0xc,%esp
  801442:	6a 00                	push   $0x0
  801444:	53                   	push   %ebx
  801445:	6a 00                	push   $0x0
  801447:	e8 62 0b 00 00       	call   801fae <ipc_recv>
}
  80144c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
  801467:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 02 00 00 00       	mov    $0x2,%eax
  801476:	e8 8d ff ff ff       	call   801408 <fsipc>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	8b 40 0c             	mov    0xc(%eax),%eax
  801489:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148e:	ba 00 00 00 00       	mov    $0x0,%edx
  801493:	b8 06 00 00 00       	mov    $0x6,%eax
  801498:	e8 6b ff ff ff       	call   801408 <fsipc>
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8014af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014be:	e8 45 ff ff ff       	call   801408 <fsipc>
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 2c                	js     8014f3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	68 00 50 80 00       	push   $0x805000
  8014cf:	53                   	push   %ebx
  8014d0:	e8 bd f2 ff ff       	call   800792 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  801502:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801507:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80150c:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  80150f:	53                   	push   %ebx
  801510:	ff 75 0c             	pushl  0xc(%ebp)
  801513:	68 08 50 80 00       	push   $0x805008
  801518:	e8 07 f4 ff ff       	call   800924 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151d:	8b 45 08             	mov    0x8(%ebp),%eax
  801520:	8b 40 0c             	mov    0xc(%eax),%eax
  801523:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801528:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	b8 04 00 00 00       	mov    $0x4,%eax
  801538:	e8 cb fe ff ff       	call   801408 <fsipc>
	//panic("devfile_write not implemented");
}
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154a:	8b 45 08             	mov    0x8(%ebp),%eax
  80154d:	8b 40 0c             	mov    0xc(%eax),%eax
  801550:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801555:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155b:	ba 00 00 00 00       	mov    $0x0,%edx
  801560:	b8 03 00 00 00       	mov    $0x3,%eax
  801565:	e8 9e fe ff ff       	call   801408 <fsipc>
  80156a:	89 c3                	mov    %eax,%ebx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 4b                	js     8015bb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801570:	39 c6                	cmp    %eax,%esi
  801572:	73 16                	jae    80158a <devfile_read+0x48>
  801574:	68 28 28 80 00       	push   $0x802828
  801579:	68 2f 28 80 00       	push   $0x80282f
  80157e:	6a 7c                	push   $0x7c
  801580:	68 44 28 80 00       	push   $0x802844
  801585:	e8 aa eb ff ff       	call   800134 <_panic>
	assert(r <= PGSIZE);
  80158a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158f:	7e 16                	jle    8015a7 <devfile_read+0x65>
  801591:	68 4f 28 80 00       	push   $0x80284f
  801596:	68 2f 28 80 00       	push   $0x80282f
  80159b:	6a 7d                	push   $0x7d
  80159d:	68 44 28 80 00       	push   $0x802844
  8015a2:	e8 8d eb ff ff       	call   800134 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	50                   	push   %eax
  8015ab:	68 00 50 80 00       	push   $0x805000
  8015b0:	ff 75 0c             	pushl  0xc(%ebp)
  8015b3:	e8 6c f3 ff ff       	call   800924 <memmove>
	return r;
  8015b8:	83 c4 10             	add    $0x10,%esp
}
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 20             	sub    $0x20,%esp
  8015cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ce:	53                   	push   %ebx
  8015cf:	e8 85 f1 ff ff       	call   800759 <strlen>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015dc:	7f 67                	jg     801645 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	e8 96 f8 ff ff       	call   800e80 <fd_alloc>
  8015ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ed:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 57                	js     80164a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	68 00 50 80 00       	push   $0x805000
  8015fc:	e8 91 f1 ff ff       	call   800792 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801601:	8b 45 0c             	mov    0xc(%ebp),%eax
  801604:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801609:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160c:	b8 01 00 00 00       	mov    $0x1,%eax
  801611:	e8 f2 fd ff ff       	call   801408 <fsipc>
  801616:	89 c3                	mov    %eax,%ebx
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	79 14                	jns    801633 <open+0x6f>
		fd_close(fd, 0);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	6a 00                	push   $0x0
  801624:	ff 75 f4             	pushl  -0xc(%ebp)
  801627:	e8 4c f9 ff ff       	call   800f78 <fd_close>
		return r;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	89 da                	mov    %ebx,%edx
  801631:	eb 17                	jmp    80164a <open+0x86>
	}

	return fd2num(fd);
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	ff 75 f4             	pushl  -0xc(%ebp)
  801639:	e8 1b f8 ff ff       	call   800e59 <fd2num>
  80163e:	89 c2                	mov    %eax,%edx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	eb 05                	jmp    80164a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801645:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164a:	89 d0                	mov    %edx,%eax
  80164c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 08 00 00 00       	mov    $0x8,%eax
  801661:	e8 a2 fd ff ff       	call   801408 <fsipc>
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80166e:	68 5b 28 80 00       	push   $0x80285b
  801673:	ff 75 0c             	pushl  0xc(%ebp)
  801676:	e8 17 f1 ff ff       	call   800792 <strcpy>
	return 0;
}
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 10             	sub    $0x10,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80168c:	53                   	push   %ebx
  80168d:	e8 16 0a 00 00       	call   8020a8 <pageref>
  801692:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801695:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80169a:	83 f8 01             	cmp    $0x1,%eax
  80169d:	75 10                	jne    8016af <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80169f:	83 ec 0c             	sub    $0xc,%esp
  8016a2:	ff 73 0c             	pushl  0xc(%ebx)
  8016a5:	e8 c0 02 00 00       	call   80196a <nsipc_close>
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8016af:	89 d0                	mov    %edx,%eax
  8016b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016bc:	6a 00                	push   $0x0
  8016be:	ff 75 10             	pushl  0x10(%ebp)
  8016c1:	ff 75 0c             	pushl  0xc(%ebp)
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	ff 70 0c             	pushl  0xc(%eax)
  8016ca:	e8 78 03 00 00       	call   801a47 <nsipc_send>
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016d7:	6a 00                	push   $0x0
  8016d9:	ff 75 10             	pushl  0x10(%ebp)
  8016dc:	ff 75 0c             	pushl  0xc(%ebp)
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	ff 70 0c             	pushl  0xc(%eax)
  8016e5:	e8 f1 02 00 00       	call   8019db <nsipc_recv>
}
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016f2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016f5:	52                   	push   %edx
  8016f6:	50                   	push   %eax
  8016f7:	e8 d3 f7 ff ff       	call   800ecf <fd_lookup>
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 17                	js     80171a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801703:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801706:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80170c:	39 08                	cmp    %ecx,(%eax)
  80170e:	75 05                	jne    801715 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801710:	8b 40 0c             	mov    0xc(%eax),%eax
  801713:	eb 05                	jmp    80171a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801715:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	83 ec 1c             	sub    $0x1c,%esp
  801724:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	e8 51 f7 ff ff       	call   800e80 <fd_alloc>
  80172f:	89 c3                	mov    %eax,%ebx
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 c0                	test   %eax,%eax
  801736:	78 1b                	js     801753 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	68 07 04 00 00       	push   $0x407
  801740:	ff 75 f4             	pushl  -0xc(%ebp)
  801743:	6a 00                	push   $0x0
  801745:	e8 4b f4 ff ff       	call   800b95 <sys_page_alloc>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	79 10                	jns    801763 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	56                   	push   %esi
  801757:	e8 0e 02 00 00       	call   80196a <nsipc_close>
		return r;
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	89 d8                	mov    %ebx,%eax
  801761:	eb 24                	jmp    801787 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801763:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80176e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801771:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801778:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80177b:	83 ec 0c             	sub    $0xc,%esp
  80177e:	50                   	push   %eax
  80177f:	e8 d5 f6 ff ff       	call   800e59 <fd2num>
  801784:	83 c4 10             	add    $0x10,%esp
}
  801787:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801794:	8b 45 08             	mov    0x8(%ebp),%eax
  801797:	e8 50 ff ff ff       	call   8016ec <fd2sockid>
		return r;
  80179c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 1f                	js     8017c1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017a2:	83 ec 04             	sub    $0x4,%esp
  8017a5:	ff 75 10             	pushl  0x10(%ebp)
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	50                   	push   %eax
  8017ac:	e8 12 01 00 00       	call   8018c3 <nsipc_accept>
  8017b1:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 07                	js     8017c1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017ba:	e8 5d ff ff ff       	call   80171c <alloc_sockfd>
  8017bf:	89 c1                	mov    %eax,%ecx
}
  8017c1:	89 c8                	mov    %ecx,%eax
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	e8 19 ff ff ff       	call   8016ec <fd2sockid>
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 12                	js     8017e9 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	ff 75 10             	pushl  0x10(%ebp)
  8017dd:	ff 75 0c             	pushl  0xc(%ebp)
  8017e0:	50                   	push   %eax
  8017e1:	e8 2d 01 00 00       	call   801913 <nsipc_bind>
  8017e6:	83 c4 10             	add    $0x10,%esp
}
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <shutdown>:

int
shutdown(int s, int how)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	e8 f3 fe ff ff       	call   8016ec <fd2sockid>
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 0f                	js     80180c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	ff 75 0c             	pushl  0xc(%ebp)
  801803:	50                   	push   %eax
  801804:	e8 3f 01 00 00       	call   801948 <nsipc_shutdown>
  801809:	83 c4 10             	add    $0x10,%esp
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	e8 d0 fe ff ff       	call   8016ec <fd2sockid>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 12                	js     801832 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801820:	83 ec 04             	sub    $0x4,%esp
  801823:	ff 75 10             	pushl  0x10(%ebp)
  801826:	ff 75 0c             	pushl  0xc(%ebp)
  801829:	50                   	push   %eax
  80182a:	e8 55 01 00 00       	call   801984 <nsipc_connect>
  80182f:	83 c4 10             	add    $0x10,%esp
}
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <listen>:

int
listen(int s, int backlog)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	e8 aa fe ff ff       	call   8016ec <fd2sockid>
  801842:	85 c0                	test   %eax,%eax
  801844:	78 0f                	js     801855 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	e8 67 01 00 00       	call   8019b9 <nsipc_listen>
  801852:	83 c4 10             	add    $0x10,%esp
}
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80185d:	ff 75 10             	pushl  0x10(%ebp)
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	ff 75 08             	pushl  0x8(%ebp)
  801866:	e8 3a 02 00 00       	call   801aa5 <nsipc_socket>
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 05                	js     801877 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801872:	e8 a5 fe ff ff       	call   80171c <alloc_sockfd>
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 04             	sub    $0x4,%esp
  801880:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801882:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801889:	75 12                	jne    80189d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	6a 02                	push   $0x2
  801890:	e8 da 07 00 00       	call   80206f <ipc_find_env>
  801895:	a3 04 40 80 00       	mov    %eax,0x804004
  80189a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80189d:	6a 07                	push   $0x7
  80189f:	68 00 60 80 00       	push   $0x806000
  8018a4:	53                   	push   %ebx
  8018a5:	ff 35 04 40 80 00    	pushl  0x804004
  8018ab:	e8 6b 07 00 00       	call   80201b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018b0:	83 c4 0c             	add    $0xc,%esp
  8018b3:	6a 00                	push   $0x0
  8018b5:	6a 00                	push   $0x0
  8018b7:	6a 00                	push   $0x0
  8018b9:	e8 f0 06 00 00       	call   801fae <ipc_recv>
}
  8018be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018d3:	8b 06                	mov    (%esi),%eax
  8018d5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018da:	b8 01 00 00 00       	mov    $0x1,%eax
  8018df:	e8 95 ff ff ff       	call   801879 <nsipc>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 20                	js     80190a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018ea:	83 ec 04             	sub    $0x4,%esp
  8018ed:	ff 35 10 60 80 00    	pushl  0x806010
  8018f3:	68 00 60 80 00       	push   $0x806000
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	e8 24 f0 ff ff       	call   800924 <memmove>
		*addrlen = ret->ret_addrlen;
  801900:	a1 10 60 80 00       	mov    0x806010,%eax
  801905:	89 06                	mov    %eax,(%esi)
  801907:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80190a:	89 d8                	mov    %ebx,%eax
  80190c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	53                   	push   %ebx
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801925:	53                   	push   %ebx
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	68 04 60 80 00       	push   $0x806004
  80192e:	e8 f1 ef ff ff       	call   800924 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801933:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801939:	b8 02 00 00 00       	mov    $0x2,%eax
  80193e:	e8 36 ff ff ff       	call   801879 <nsipc>
}
  801943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801956:	8b 45 0c             	mov    0xc(%ebp),%eax
  801959:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80195e:	b8 03 00 00 00       	mov    $0x3,%eax
  801963:	e8 11 ff ff ff       	call   801879 <nsipc>
}
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <nsipc_close>:

int
nsipc_close(int s)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801978:	b8 04 00 00 00       	mov    $0x4,%eax
  80197d:	e8 f7 fe ff ff       	call   801879 <nsipc>
}
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	53                   	push   %ebx
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80198e:	8b 45 08             	mov    0x8(%ebp),%eax
  801991:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801996:	53                   	push   %ebx
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	68 04 60 80 00       	push   $0x806004
  80199f:	e8 80 ef ff ff       	call   800924 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019a4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8019af:	e8 c5 fe ff ff       	call   801879 <nsipc>
}
  8019b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d4:	e8 a0 fe ff ff       	call   801879 <nsipc>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019eb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8019fe:	e8 76 fe ff ff       	call   801879 <nsipc>
  801a03:	89 c3                	mov    %eax,%ebx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 35                	js     801a3e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a09:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a0e:	7f 04                	jg     801a14 <nsipc_recv+0x39>
  801a10:	39 c6                	cmp    %eax,%esi
  801a12:	7d 16                	jge    801a2a <nsipc_recv+0x4f>
  801a14:	68 67 28 80 00       	push   $0x802867
  801a19:	68 2f 28 80 00       	push   $0x80282f
  801a1e:	6a 62                	push   $0x62
  801a20:	68 7c 28 80 00       	push   $0x80287c
  801a25:	e8 0a e7 ff ff       	call   800134 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	50                   	push   %eax
  801a2e:	68 00 60 80 00       	push   $0x806000
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	e8 e9 ee ff ff       	call   800924 <memmove>
  801a3b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a3e:	89 d8                	mov    %ebx,%eax
  801a40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a43:	5b                   	pop    %ebx
  801a44:	5e                   	pop    %esi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a51:	8b 45 08             	mov    0x8(%ebp),%eax
  801a54:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a59:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a5f:	7e 16                	jle    801a77 <nsipc_send+0x30>
  801a61:	68 88 28 80 00       	push   $0x802888
  801a66:	68 2f 28 80 00       	push   $0x80282f
  801a6b:	6a 6d                	push   $0x6d
  801a6d:	68 7c 28 80 00       	push   $0x80287c
  801a72:	e8 bd e6 ff ff       	call   800134 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	53                   	push   %ebx
  801a7b:	ff 75 0c             	pushl  0xc(%ebp)
  801a7e:	68 0c 60 80 00       	push   $0x80600c
  801a83:	e8 9c ee ff ff       	call   800924 <memmove>
	nsipcbuf.send.req_size = size;
  801a88:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a91:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a96:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9b:	e8 d9 fd ff ff       	call   801879 <nsipc>
}
  801aa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801abb:	8b 45 10             	mov    0x10(%ebp),%eax
  801abe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ac3:	b8 09 00 00 00       	mov    $0x9,%eax
  801ac8:	e8 ac fd ff ff       	call   801879 <nsipc>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	ff 75 08             	pushl  0x8(%ebp)
  801add:	e8 87 f3 ff ff       	call   800e69 <fd2data>
  801ae2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ae4:	83 c4 08             	add    $0x8,%esp
  801ae7:	68 94 28 80 00       	push   $0x802894
  801aec:	53                   	push   %ebx
  801aed:	e8 a0 ec ff ff       	call   800792 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801af2:	8b 46 04             	mov    0x4(%esi),%eax
  801af5:	2b 06                	sub    (%esi),%eax
  801af7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801afd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b04:	00 00 00 
	stat->st_dev = &devpipe;
  801b07:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b0e:	30 80 00 
	return 0;
}
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	53                   	push   %ebx
  801b21:	83 ec 0c             	sub    $0xc,%esp
  801b24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b27:	53                   	push   %ebx
  801b28:	6a 00                	push   $0x0
  801b2a:	e8 eb f0 ff ff       	call   800c1a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b2f:	89 1c 24             	mov    %ebx,(%esp)
  801b32:	e8 32 f3 ff ff       	call   800e69 <fd2data>
  801b37:	83 c4 08             	add    $0x8,%esp
  801b3a:	50                   	push   %eax
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 d8 f0 ff ff       	call   800c1a <sys_page_unmap>
}
  801b42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	57                   	push   %edi
  801b4b:	56                   	push   %esi
  801b4c:	53                   	push   %ebx
  801b4d:	83 ec 1c             	sub    $0x1c,%esp
  801b50:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b53:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b55:	a1 08 40 80 00       	mov    0x804008,%eax
  801b5a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	ff 75 e0             	pushl  -0x20(%ebp)
  801b63:	e8 40 05 00 00       	call   8020a8 <pageref>
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	89 3c 24             	mov    %edi,(%esp)
  801b6d:	e8 36 05 00 00       	call   8020a8 <pageref>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	39 c3                	cmp    %eax,%ebx
  801b77:	0f 94 c1             	sete   %cl
  801b7a:	0f b6 c9             	movzbl %cl,%ecx
  801b7d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b80:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b86:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b89:	39 ce                	cmp    %ecx,%esi
  801b8b:	74 1b                	je     801ba8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b8d:	39 c3                	cmp    %eax,%ebx
  801b8f:	75 c4                	jne    801b55 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b91:	8b 42 58             	mov    0x58(%edx),%eax
  801b94:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b97:	50                   	push   %eax
  801b98:	56                   	push   %esi
  801b99:	68 9b 28 80 00       	push   $0x80289b
  801b9e:	e8 6a e6 ff ff       	call   80020d <cprintf>
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	eb ad                	jmp    801b55 <_pipeisclosed+0xe>
	}
}
  801ba8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5f                   	pop    %edi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	57                   	push   %edi
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 28             	sub    $0x28,%esp
  801bbc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bbf:	56                   	push   %esi
  801bc0:	e8 a4 f2 ff ff       	call   800e69 <fd2data>
  801bc5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	bf 00 00 00 00       	mov    $0x0,%edi
  801bcf:	eb 4b                	jmp    801c1c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bd1:	89 da                	mov    %ebx,%edx
  801bd3:	89 f0                	mov    %esi,%eax
  801bd5:	e8 6d ff ff ff       	call   801b47 <_pipeisclosed>
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	75 48                	jne    801c26 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bde:	e8 93 ef ff ff       	call   800b76 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801be3:	8b 43 04             	mov    0x4(%ebx),%eax
  801be6:	8b 0b                	mov    (%ebx),%ecx
  801be8:	8d 51 20             	lea    0x20(%ecx),%edx
  801beb:	39 d0                	cmp    %edx,%eax
  801bed:	73 e2                	jae    801bd1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bf6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bf9:	89 c2                	mov    %eax,%edx
  801bfb:	c1 fa 1f             	sar    $0x1f,%edx
  801bfe:	89 d1                	mov    %edx,%ecx
  801c00:	c1 e9 1b             	shr    $0x1b,%ecx
  801c03:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c06:	83 e2 1f             	and    $0x1f,%edx
  801c09:	29 ca                	sub    %ecx,%edx
  801c0b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c0f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c13:	83 c0 01             	add    $0x1,%eax
  801c16:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c19:	83 c7 01             	add    $0x1,%edi
  801c1c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c1f:	75 c2                	jne    801be3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c21:	8b 45 10             	mov    0x10(%ebp),%eax
  801c24:	eb 05                	jmp    801c2b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5f                   	pop    %edi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	57                   	push   %edi
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	83 ec 18             	sub    $0x18,%esp
  801c3c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c3f:	57                   	push   %edi
  801c40:	e8 24 f2 ff ff       	call   800e69 <fd2data>
  801c45:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c4f:	eb 3d                	jmp    801c8e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c51:	85 db                	test   %ebx,%ebx
  801c53:	74 04                	je     801c59 <devpipe_read+0x26>
				return i;
  801c55:	89 d8                	mov    %ebx,%eax
  801c57:	eb 44                	jmp    801c9d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c59:	89 f2                	mov    %esi,%edx
  801c5b:	89 f8                	mov    %edi,%eax
  801c5d:	e8 e5 fe ff ff       	call   801b47 <_pipeisclosed>
  801c62:	85 c0                	test   %eax,%eax
  801c64:	75 32                	jne    801c98 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c66:	e8 0b ef ff ff       	call   800b76 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c6b:	8b 06                	mov    (%esi),%eax
  801c6d:	3b 46 04             	cmp    0x4(%esi),%eax
  801c70:	74 df                	je     801c51 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c72:	99                   	cltd   
  801c73:	c1 ea 1b             	shr    $0x1b,%edx
  801c76:	01 d0                	add    %edx,%eax
  801c78:	83 e0 1f             	and    $0x1f,%eax
  801c7b:	29 d0                	sub    %edx,%eax
  801c7d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c85:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c88:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c8b:	83 c3 01             	add    $0x1,%ebx
  801c8e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c91:	75 d8                	jne    801c6b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c93:	8b 45 10             	mov    0x10(%ebp),%eax
  801c96:	eb 05                	jmp    801c9d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb0:	50                   	push   %eax
  801cb1:	e8 ca f1 ff ff       	call   800e80 <fd_alloc>
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	0f 88 2c 01 00 00    	js     801def <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 ec 04             	sub    $0x4,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 c0 ee ff ff       	call   800b95 <sys_page_alloc>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 0d 01 00 00    	js     801def <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	e8 92 f1 ff ff       	call   800e80 <fd_alloc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 e2 00 00 00    	js     801ddd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	83 ec 04             	sub    $0x4,%esp
  801cfe:	68 07 04 00 00       	push   $0x407
  801d03:	ff 75 f0             	pushl  -0x10(%ebp)
  801d06:	6a 00                	push   $0x0
  801d08:	e8 88 ee ff ff       	call   800b95 <sys_page_alloc>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	85 c0                	test   %eax,%eax
  801d14:	0f 88 c3 00 00 00    	js     801ddd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d20:	e8 44 f1 ff ff       	call   800e69 <fd2data>
  801d25:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 c4 0c             	add    $0xc,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	50                   	push   %eax
  801d30:	6a 00                	push   $0x0
  801d32:	e8 5e ee ff ff       	call   800b95 <sys_page_alloc>
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	0f 88 89 00 00 00    	js     801dcd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4a:	e8 1a f1 ff ff       	call   800e69 <fd2data>
  801d4f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d56:	50                   	push   %eax
  801d57:	6a 00                	push   $0x0
  801d59:	56                   	push   %esi
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 77 ee ff ff       	call   800bd8 <sys_page_map>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	83 c4 20             	add    $0x20,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	78 55                	js     801dbf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d73:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d7f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d88:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d8d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d94:	83 ec 0c             	sub    $0xc,%esp
  801d97:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9a:	e8 ba f0 ff ff       	call   800e59 <fd2num>
  801d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801da4:	83 c4 04             	add    $0x4,%esp
  801da7:	ff 75 f0             	pushl  -0x10(%ebp)
  801daa:	e8 aa f0 ff ff       	call   800e59 <fd2num>
  801daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbd:	eb 30                	jmp    801def <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	56                   	push   %esi
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 50 ee ff ff       	call   800c1a <sys_page_unmap>
  801dca:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 40 ee ff ff       	call   800c1a <sys_page_unmap>
  801dda:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ddd:	83 ec 08             	sub    $0x8,%esp
  801de0:	ff 75 f4             	pushl  -0xc(%ebp)
  801de3:	6a 00                	push   $0x0
  801de5:	e8 30 ee ff ff       	call   800c1a <sys_page_unmap>
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801def:	89 d0                	mov    %edx,%eax
  801df1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e01:	50                   	push   %eax
  801e02:	ff 75 08             	pushl  0x8(%ebp)
  801e05:	e8 c5 f0 ff ff       	call   800ecf <fd_lookup>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 18                	js     801e29 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e11:	83 ec 0c             	sub    $0xc,%esp
  801e14:	ff 75 f4             	pushl  -0xc(%ebp)
  801e17:	e8 4d f0 ff ff       	call   800e69 <fd2data>
	return _pipeisclosed(fd, p);
  801e1c:	89 c2                	mov    %eax,%edx
  801e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e21:	e8 21 fd ff ff       	call   801b47 <_pipeisclosed>
  801e26:	83 c4 10             	add    $0x10,%esp
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e3b:	68 b3 28 80 00       	push   $0x8028b3
  801e40:	ff 75 0c             	pushl  0xc(%ebp)
  801e43:	e8 4a e9 ff ff       	call   800792 <strcpy>
	return 0;
}
  801e48:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	57                   	push   %edi
  801e53:	56                   	push   %esi
  801e54:	53                   	push   %ebx
  801e55:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e60:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e66:	eb 2d                	jmp    801e95 <devcons_write+0x46>
		m = n - tot;
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e6b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e6d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e70:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e75:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	53                   	push   %ebx
  801e7c:	03 45 0c             	add    0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	57                   	push   %edi
  801e81:	e8 9e ea ff ff       	call   800924 <memmove>
		sys_cputs(buf, m);
  801e86:	83 c4 08             	add    $0x8,%esp
  801e89:	53                   	push   %ebx
  801e8a:	57                   	push   %edi
  801e8b:	e8 49 ec ff ff       	call   800ad9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e90:	01 de                	add    %ebx,%esi
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e9a:	72 cc                	jb     801e68 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 08             	sub    $0x8,%esp
  801eaa:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eaf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb3:	74 2a                	je     801edf <devcons_read+0x3b>
  801eb5:	eb 05                	jmp    801ebc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eb7:	e8 ba ec ff ff       	call   800b76 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ebc:	e8 36 ec ff ff       	call   800af7 <sys_cgetc>
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	74 f2                	je     801eb7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 16                	js     801edf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec9:	83 f8 04             	cmp    $0x4,%eax
  801ecc:	74 0c                	je     801eda <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed1:	88 02                	mov    %al,(%edx)
	return 1;
  801ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed8:	eb 05                	jmp    801edf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eed:	6a 01                	push   $0x1
  801eef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef2:	50                   	push   %eax
  801ef3:	e8 e1 eb ff ff       	call   800ad9 <sys_cputs>
}
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    

00801efd <getchar>:

int
getchar(void)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f03:	6a 01                	push   $0x1
  801f05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f08:	50                   	push   %eax
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 25 f2 ff ff       	call   801135 <read>
	if (r < 0)
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 0f                	js     801f26 <getchar+0x29>
		return r;
	if (r < 1)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	7e 06                	jle    801f21 <getchar+0x24>
		return -E_EOF;
	return c;
  801f1b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f1f:	eb 05                	jmp    801f26 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f21:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	ff 75 08             	pushl  0x8(%ebp)
  801f35:	e8 95 ef ff ff       	call   800ecf <fd_lookup>
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 11                	js     801f52 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f44:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f4a:	39 10                	cmp    %edx,(%eax)
  801f4c:	0f 94 c0             	sete   %al
  801f4f:	0f b6 c0             	movzbl %al,%eax
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <opencons>:

int
opencons(void)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	e8 1d ef ff ff       	call   800e80 <fd_alloc>
  801f63:	83 c4 10             	add    $0x10,%esp
		return r;
  801f66:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 3e                	js     801faa <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f6c:	83 ec 04             	sub    $0x4,%esp
  801f6f:	68 07 04 00 00       	push   $0x407
  801f74:	ff 75 f4             	pushl  -0xc(%ebp)
  801f77:	6a 00                	push   $0x0
  801f79:	e8 17 ec ff ff       	call   800b95 <sys_page_alloc>
  801f7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f81:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 23                	js     801faa <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f87:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f90:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	50                   	push   %eax
  801fa0:	e8 b4 ee ff ff       	call   800e59 <fd2num>
  801fa5:	89 c2                	mov    %eax,%edx
  801fa7:	83 c4 10             	add    $0x10,%esp
}
  801faa:	89 d0                	mov    %edx,%eax
  801fac:	c9                   	leave  
  801fad:	c3                   	ret    

00801fae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	56                   	push   %esi
  801fb2:	53                   	push   %ebx
  801fb3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	74 0e                	je     801fce <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 7c ed ff ff       	call   800d45 <sys_ipc_recv>
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	eb 10                	jmp    801fde <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	68 00 00 00 f0       	push   $0xf0000000
  801fd6:	e8 6a ed ff ff       	call   800d45 <sys_ipc_recv>
  801fdb:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	74 0e                	je     801ff0 <ipc_recv+0x42>
    	*from_env_store = 0;
  801fe2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801fe8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801fee:	eb 24                	jmp    802014 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801ff0:	85 f6                	test   %esi,%esi
  801ff2:	74 0a                	je     801ffe <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801ff4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff9:	8b 40 74             	mov    0x74(%eax),%eax
  801ffc:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801ffe:	85 db                	test   %ebx,%ebx
  802000:	74 0a                	je     80200c <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  802002:	a1 08 40 80 00       	mov    0x804008,%eax
  802007:	8b 40 78             	mov    0x78(%eax),%eax
  80200a:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  80200c:	a1 08 40 80 00       	mov    0x804008,%eax
  802011:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802014:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	57                   	push   %edi
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	8b 7d 08             	mov    0x8(%ebp),%edi
  802027:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  80202d:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  80202f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802034:	0f 44 d8             	cmove  %eax,%ebx
  802037:	eb 1c                	jmp    802055 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802039:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80203c:	74 12                	je     802050 <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  80203e:	50                   	push   %eax
  80203f:	68 bf 28 80 00       	push   $0x8028bf
  802044:	6a 4b                	push   $0x4b
  802046:	68 d7 28 80 00       	push   $0x8028d7
  80204b:	e8 e4 e0 ff ff       	call   800134 <_panic>
        }	
        sys_yield();
  802050:	e8 21 eb ff ff       	call   800b76 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802055:	ff 75 14             	pushl  0x14(%ebp)
  802058:	53                   	push   %ebx
  802059:	56                   	push   %esi
  80205a:	57                   	push   %edi
  80205b:	e8 c2 ec ff ff       	call   800d22 <sys_ipc_try_send>
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	75 d2                	jne    802039 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802067:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80207a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80207d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802083:	8b 52 50             	mov    0x50(%edx),%edx
  802086:	39 ca                	cmp    %ecx,%edx
  802088:	75 0d                	jne    802097 <ipc_find_env+0x28>
			return envs[i].env_id;
  80208a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80208d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802092:	8b 40 48             	mov    0x48(%eax),%eax
  802095:	eb 0f                	jmp    8020a6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802097:	83 c0 01             	add    $0x1,%eax
  80209a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209f:	75 d9                	jne    80207a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ae:	89 d0                	mov    %edx,%eax
  8020b0:	c1 e8 16             	shr    $0x16,%eax
  8020b3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ba:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bf:	f6 c1 01             	test   $0x1,%cl
  8020c2:	74 1d                	je     8020e1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c4:	c1 ea 0c             	shr    $0xc,%edx
  8020c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ce:	f6 c2 01             	test   $0x1,%dl
  8020d1:	74 0e                	je     8020e1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d3:	c1 ea 0c             	shr    $0xc,%edx
  8020d6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020dd:	ef 
  8020de:	0f b7 c0             	movzwl %ax,%eax
}
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    
  8020e3:	66 90                	xchg   %ax,%ax
  8020e5:	66 90                	xchg   %ax,%ax
  8020e7:	66 90                	xchg   %ax,%ax
  8020e9:	66 90                	xchg   %ax,%ax
  8020eb:	66 90                	xchg   %ax,%ax
  8020ed:	66 90                	xchg   %ax,%ax
  8020ef:	90                   	nop

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
