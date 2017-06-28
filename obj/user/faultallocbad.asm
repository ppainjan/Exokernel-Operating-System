
obj/user/faultallocbad.debug:     file format elf32-i386


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
  800040:	68 60 23 80 00       	push   $0x802360
  800045:	e8 ae 01 00 00       	call   8001f8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 22 0b 00 00       	call   800b80 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 23 80 00       	push   $0x802380
  80006f:	6a 0f                	push   $0xf
  800071:	68 6a 23 80 00       	push   $0x80236a
  800076:	e8 a4 00 00 00       	call   80011f <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 23 80 00       	push   $0x8023ac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 a1 06 00 00       	call   80072a <snprintf>
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
  80009c:	e8 10 0d 00 00       	call   800db1 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 14 0a 00 00       	call   800ac4 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000ca:	e8 73 0a 00 00       	call   800b42 <sys_getenvid>
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
  8000f1:	e8 9b ff ff ff       	call   800091 <umain>

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
  80010b:	e8 ff 0e 00 00       	call   80100f <close_all>
	sys_env_destroy(0);
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	6a 00                	push   $0x0
  800115:	e8 e7 09 00 00       	call   800b01 <sys_env_destroy>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	c9                   	leave  
  80011e:	c3                   	ret    

0080011f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800124:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800127:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80012d:	e8 10 0a 00 00       	call   800b42 <sys_getenvid>
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	ff 75 0c             	pushl  0xc(%ebp)
  800138:	ff 75 08             	pushl  0x8(%ebp)
  80013b:	56                   	push   %esi
  80013c:	50                   	push   %eax
  80013d:	68 d8 23 80 00       	push   $0x8023d8
  800142:	e8 b1 00 00 00       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800147:	83 c4 18             	add    $0x18,%esp
  80014a:	53                   	push   %ebx
  80014b:	ff 75 10             	pushl  0x10(%ebp)
  80014e:	e8 54 00 00 00       	call   8001a7 <vcprintf>
	cprintf("\n");
  800153:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  80015a:	e8 99 00 00 00       	call   8001f8 <cprintf>
  80015f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800162:	cc                   	int3   
  800163:	eb fd                	jmp    800162 <_panic+0x43>

00800165 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	75 1a                	jne    80019e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	68 ff 00 00 00       	push   $0xff
  80018c:	8d 43 08             	lea    0x8(%ebx),%eax
  80018f:	50                   	push   %eax
  800190:	e8 2f 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  800195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 65 01 80 00       	push   $0x800165
  8001d6:	e8 54 01 00 00       	call   80032f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 d4 08 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800225:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800230:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800233:	39 d3                	cmp    %edx,%ebx
  800235:	72 05                	jb     80023c <printnum+0x30>
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 45                	ja     800281 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 45 14             	mov    0x14(%ebp),%eax
  800245:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800252:	ff 75 e0             	pushl  -0x20(%ebp)
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	e8 70 1e 00 00       	call   8020d0 <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	89 f2                	mov    %esi,%edx
  800267:	89 f8                	mov    %edi,%eax
  800269:	e8 9e ff ff ff       	call   80020c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 18                	jmp    80028b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	56                   	push   %esi
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	ff d7                	call   *%edi
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	eb 03                	jmp    800284 <printnum+0x78>
  800281:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	85 db                	test   %ebx,%ebx
  800289:	7f e8                	jg     800273 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	56                   	push   %esi
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 5d 1f 00 00       	call   802200 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff d7                	call   *%edi
}
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002be:	83 fa 01             	cmp    $0x1,%edx
  8002c1:	7e 0e                	jle    8002d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	8b 52 04             	mov    0x4(%edx),%edx
  8002cf:	eb 22                	jmp    8002f3 <getuint+0x38>
	else if (lflag)
  8002d1:	85 d2                	test   %edx,%edx
  8002d3:	74 10                	je     8002e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	eb 0e                	jmp    8002f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	3b 50 04             	cmp    0x4(%eax),%edx
  800304:	73 0a                	jae    800310 <sprintputch+0x1b>
		*b->buf++ = ch;
  800306:	8d 4a 01             	lea    0x1(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	88 02                	mov    %al,(%edx)
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800318:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031b:	50                   	push   %eax
  80031c:	ff 75 10             	pushl  0x10(%ebp)
  80031f:	ff 75 0c             	pushl  0xc(%ebp)
  800322:	ff 75 08             	pushl  0x8(%ebp)
  800325:	e8 05 00 00 00       	call   80032f <vprintfmt>
	va_end(ap);
}
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 2c             	sub    $0x2c,%esp
  800338:	8b 75 08             	mov    0x8(%ebp),%esi
  80033b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800341:	eb 12                	jmp    800355 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800343:	85 c0                	test   %eax,%eax
  800345:	0f 84 89 03 00 00    	je     8006d4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	53                   	push   %ebx
  80034f:	50                   	push   %eax
  800350:	ff d6                	call   *%esi
  800352:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800355:	83 c7 01             	add    $0x1,%edi
  800358:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035c:	83 f8 25             	cmp    $0x25,%eax
  80035f:	75 e2                	jne    800343 <vprintfmt+0x14>
  800361:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800365:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800373:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	eb 07                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	0f b6 07             	movzbl (%edi),%eax
  800391:	0f b6 c8             	movzbl %al,%ecx
  800394:	83 e8 23             	sub    $0x23,%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 1a 03 00 00    	ja     8006b9 <vprintfmt+0x38a>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b0:	eb d6                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ca:	83 fa 09             	cmp    $0x9,%edx
  8003cd:	77 39                	ja     800408 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d2:	eb e9                	jmp    8003bd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e5:	eb 27                	jmp    80040e <vprintfmt+0xdf>
  8003e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f1:	0f 49 c8             	cmovns %eax,%ecx
  8003f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fa:	eb 8c                	jmp    800388 <vprintfmt+0x59>
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800406:	eb 80                	jmp    800388 <vprintfmt+0x59>
  800408:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800412:	0f 89 70 ff ff ff    	jns    800388 <vprintfmt+0x59>
				width = precision, precision = -1;
  800418:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800425:	e9 5e ff ff ff       	jmp    800388 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800430:	e9 53 ff ff ff       	jmp    800388 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	ff 30                	pushl  (%eax)
  800444:	ff d6                	call   *%esi
			break;
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044c:	e9 04 ff ff ff       	jmp    800355 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	99                   	cltd   
  80045d:	31 d0                	xor    %edx,%eax
  80045f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800461:	83 f8 0f             	cmp    $0xf,%eax
  800464:	7f 0b                	jg     800471 <vprintfmt+0x142>
  800466:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80046d:	85 d2                	test   %edx,%edx
  80046f:	75 18                	jne    800489 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 13 24 80 00       	push   $0x802413
  800477:	53                   	push   %ebx
  800478:	56                   	push   %esi
  800479:	e8 94 fe ff ff       	call   800312 <printfmt>
  80047e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800484:	e9 cc fe ff ff       	jmp    800355 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800489:	52                   	push   %edx
  80048a:	68 21 28 80 00       	push   $0x802821
  80048f:	53                   	push   %ebx
  800490:	56                   	push   %esi
  800491:	e8 7c fe ff ff       	call   800312 <printfmt>
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049c:	e9 b4 fe ff ff       	jmp    800355 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 0c 24 80 00       	mov    $0x80240c,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x225>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 86 02 00 00       	call   80075c <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1c0>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x213>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x213>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x23f>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x23f>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x270>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1f2>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1f2>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x278>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ae:	e9 a2 fd ff ff       	jmp    800355 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 fa 01             	cmp    $0x1,%edx
  8005b6:	7e 16                	jle    8005ce <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	eb 32                	jmp    800600 <vprintfmt+0x2d1>
	else if (lflag)
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 18                	je     8005ea <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 c1                	mov    %eax,%ecx
  8005e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e8:	eb 16                	jmp    800600 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 c1                	mov    %eax,%ecx
  8005fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800600:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800603:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060f:	79 74                	jns    800685 <vprintfmt+0x356>
				putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 2d                	push   $0x2d
  800617:	ff d6                	call   *%esi
				num = -(long long) num;
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061f:	f7 d8                	neg    %eax
  800621:	83 d2 00             	adc    $0x0,%edx
  800624:	f7 da                	neg    %edx
  800626:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062e:	eb 55                	jmp    800685 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 83 fc ff ff       	call   8002bb <getuint>
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063d:	eb 46                	jmp    800685 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 74 fc ff ff       	call   8002bb <getuint>
		        base = 8;
  800647:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80064c:	eb 37                	jmp    800685 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 30                	push   $0x30
  800654:	ff d6                	call   *%esi
			putch('x', putdat);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 78                	push   $0x78
  80065c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800671:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800676:	eb 0d                	jmp    800685 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 3b fc ff ff       	call   8002bb <getuint>
			base = 16;
  800680:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800685:	83 ec 0c             	sub    $0xc,%esp
  800688:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068c:	57                   	push   %edi
  80068d:	ff 75 e0             	pushl  -0x20(%ebp)
  800690:	51                   	push   %ecx
  800691:	52                   	push   %edx
  800692:	50                   	push   %eax
  800693:	89 da                	mov    %ebx,%edx
  800695:	89 f0                	mov    %esi,%eax
  800697:	e8 70 fb ff ff       	call   80020c <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 ae fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	51                   	push   %ecx
  8006ac:	ff d6                	call   *%esi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b4:	e9 9c fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 03                	jmp    8006c9 <vprintfmt+0x39a>
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cd:	75 f7                	jne    8006c6 <vprintfmt+0x397>
  8006cf:	e9 81 fc ff ff       	jmp    800355 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 18             	sub    $0x18,%esp
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 26                	je     800723 <vsnprintf+0x47>
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	7e 22                	jle    800723 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800701:	ff 75 14             	pushl  0x14(%ebp)
  800704:	ff 75 10             	pushl  0x10(%ebp)
  800707:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	68 f5 02 80 00       	push   $0x8002f5
  800710:	e8 1a fc ff ff       	call   80032f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800715:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800718:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 05                	jmp    800728 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800733:	50                   	push   %eax
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	ff 75 08             	pushl  0x8(%ebp)
  80073d:	e8 9a ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 03                	jmp    800754 <strlen+0x10>
		n++;
  800751:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800758:	75 f7                	jne    800751 <strlen+0xd>
		n++;
	return n;
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	eb 03                	jmp    80076f <strnlen+0x13>
		n++;
  80076c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	39 c2                	cmp    %eax,%edx
  800771:	74 08                	je     80077b <strnlen+0x1f>
  800773:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800777:	75 f3                	jne    80076c <strnlen+0x10>
  800779:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800787:	89 c2                	mov    %eax,%edx
  800789:	83 c2 01             	add    $0x1,%edx
  80078c:	83 c1 01             	add    $0x1,%ecx
  80078f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800793:	88 5a ff             	mov    %bl,-0x1(%edx)
  800796:	84 db                	test   %bl,%bl
  800798:	75 ef                	jne    800789 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079a:	5b                   	pop    %ebx
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a4:	53                   	push   %ebx
  8007a5:	e8 9a ff ff ff       	call   800744 <strlen>
  8007aa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	50                   	push   %eax
  8007b3:	e8 c5 ff ff ff       	call   80077d <strcpy>
	return dst;
}
  8007b8:	89 d8                	mov    %ebx,%eax
  8007ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ca:	89 f3                	mov    %esi,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cf:	89 f2                	mov    %esi,%edx
  8007d1:	eb 0f                	jmp    8007e2 <strncpy+0x23>
		*dst++ = *src;
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	0f b6 01             	movzbl (%ecx),%eax
  8007d9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007df:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e2:	39 da                	cmp    %ebx,%edx
  8007e4:	75 ed                	jne    8007d3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	74 21                	je     800821 <strlcpy+0x35>
  800800:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800804:	89 f2                	mov    %esi,%edx
  800806:	eb 09                	jmp    800811 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800811:	39 c2                	cmp    %eax,%edx
  800813:	74 09                	je     80081e <strlcpy+0x32>
  800815:	0f b6 19             	movzbl (%ecx),%ebx
  800818:	84 db                	test   %bl,%bl
  80081a:	75 ec                	jne    800808 <strlcpy+0x1c>
  80081c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800821:	29 f0                	sub    %esi,%eax
}
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	eb 06                	jmp    800838 <strcmp+0x11>
		p++, q++;
  800832:	83 c1 01             	add    $0x1,%ecx
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800838:	0f b6 01             	movzbl (%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 04                	je     800843 <strcmp+0x1c>
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	74 ef                	je     800832 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
  800857:	89 c3                	mov    %eax,%ebx
  800859:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strncmp+0x17>
		n--, p++, q++;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 15                	je     80087d <strncmp+0x30>
  800868:	0f b6 08             	movzbl (%eax),%ecx
  80086b:	84 c9                	test   %cl,%cl
  80086d:	74 04                	je     800873 <strncmp+0x26>
  80086f:	3a 0a                	cmp    (%edx),%cl
  800871:	74 eb                	je     80085e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	0f b6 12             	movzbl (%edx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb 05                	jmp    800882 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	eb 07                	jmp    800898 <strchr+0x13>
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 0f                	je     8008a4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	0f b6 10             	movzbl (%eax),%edx
  80089b:	84 d2                	test   %dl,%dl
  80089d:	75 f2                	jne    800891 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b0:	eb 03                	jmp    8008b5 <strfind+0xf>
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 04                	je     8008c0 <strfind+0x1a>
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f2                	jne    8008b2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ce:	85 c9                	test   %ecx,%ecx
  8008d0:	74 36                	je     800908 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d8:	75 28                	jne    800902 <memset+0x40>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 23                	jne    800902 <memset+0x40>
		c &= 0xFF;
  8008df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e3:	89 d3                	mov    %edx,%ebx
  8008e5:	c1 e3 08             	shl    $0x8,%ebx
  8008e8:	89 d6                	mov    %edx,%esi
  8008ea:	c1 e6 18             	shl    $0x18,%esi
  8008ed:	89 d0                	mov    %edx,%eax
  8008ef:	c1 e0 10             	shl    $0x10,%eax
  8008f2:	09 f0                	or     %esi,%eax
  8008f4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f6:	89 d8                	mov    %ebx,%eax
  8008f8:	09 d0                	or     %edx,%eax
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
  8008fd:	fc                   	cld    
  8008fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800900:	eb 06                	jmp    800908 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
  800905:	fc                   	cld    
  800906:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800908:	89 f8                	mov    %edi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091d:	39 c6                	cmp    %eax,%esi
  80091f:	73 35                	jae    800956 <memmove+0x47>
  800921:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800924:	39 d0                	cmp    %edx,%eax
  800926:	73 2e                	jae    800956 <memmove+0x47>
		s += n;
		d += n;
  800928:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	09 fe                	or     %edi,%esi
  80092f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800935:	75 13                	jne    80094a <memmove+0x3b>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0e                	jne    80094a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 1d                	jmp    800973 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 f2                	mov    %esi,%edx
  800958:	09 c2                	or     %eax,%edx
  80095a:	f6 c2 03             	test   $0x3,%dl
  80095d:	75 0f                	jne    80096e <memmove+0x5f>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 0a                	jne    80096e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800964:	c1 e9 02             	shr    $0x2,%ecx
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 05                	jmp    800973 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097a:	ff 75 10             	pushl  0x10(%ebp)
  80097d:	ff 75 0c             	pushl  0xc(%ebp)
  800980:	ff 75 08             	pushl  0x8(%ebp)
  800983:	e8 87 ff ff ff       	call   80090f <memmove>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c6                	mov    %eax,%esi
  800997:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	eb 1a                	jmp    8009b6 <memcmp+0x2c>
		if (*s1 != *s2)
  80099c:	0f b6 08             	movzbl (%eax),%ecx
  80099f:	0f b6 1a             	movzbl (%edx),%ebx
  8009a2:	38 d9                	cmp    %bl,%cl
  8009a4:	74 0a                	je     8009b0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a6:	0f b6 c1             	movzbl %cl,%eax
  8009a9:	0f b6 db             	movzbl %bl,%ebx
  8009ac:	29 d8                	sub    %ebx,%eax
  8009ae:	eb 0f                	jmp    8009bf <memcmp+0x35>
		s1++, s2++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	39 f0                	cmp    %esi,%eax
  8009b8:	75 e2                	jne    80099c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ca:	89 c1                	mov    %eax,%ecx
  8009cc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d3:	eb 0a                	jmp    8009df <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	39 da                	cmp    %ebx,%edx
  8009da:	74 07                	je     8009e3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	39 c8                	cmp    %ecx,%eax
  8009e1:	72 f2                	jb     8009d5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	eb 03                	jmp    8009f7 <strtol+0x11>
		s++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	0f b6 01             	movzbl (%ecx),%eax
  8009fa:	3c 20                	cmp    $0x20,%al
  8009fc:	74 f6                	je     8009f4 <strtol+0xe>
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f2                	je     8009f4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a02:	3c 2b                	cmp    $0x2b,%al
  800a04:	75 0a                	jne    800a10 <strtol+0x2a>
		s++;
  800a06:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0e:	eb 11                	jmp    800a21 <strtol+0x3b>
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a15:	3c 2d                	cmp    $0x2d,%al
  800a17:	75 08                	jne    800a21 <strtol+0x3b>
		s++, neg = 1;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a27:	75 15                	jne    800a3e <strtol+0x58>
  800a29:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2c:	75 10                	jne    800a3e <strtol+0x58>
  800a2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a32:	75 7c                	jne    800ab0 <strtol+0xca>
		s += 2, base = 16;
  800a34:	83 c1 02             	add    $0x2,%ecx
  800a37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3c:	eb 16                	jmp    800a54 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	75 12                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a47:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4a:	75 08                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5c:	0f b6 11             	movzbl (%ecx),%edx
  800a5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 09             	cmp    $0x9,%bl
  800a67:	77 08                	ja     800a71 <strtol+0x8b>
			dig = *s - '0';
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 30             	sub    $0x30,%edx
  800a6f:	eb 22                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a71:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 08                	ja     800a83 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 57             	sub    $0x57,%edx
  800a81:	eb 10                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a83:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 16                	ja     800aa3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a96:	7d 0b                	jge    800aa3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa1:	eb b9                	jmp    800a5c <strtol+0x76>

	if (endptr)
  800aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa7:	74 0d                	je     800ab6 <strtol+0xd0>
		*endptr = (char *) s;
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	89 0e                	mov    %ecx,(%esi)
  800aae:	eb 06                	jmp    800ab6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	74 98                	je     800a4c <strtol+0x66>
  800ab4:	eb 9e                	jmp    800a54 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	f7 da                	neg    %edx
  800aba:	85 ff                	test   %edi,%edi
  800abc:	0f 45 c2             	cmovne %edx,%eax
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 17                	jle    800b3a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 ff 26 80 00       	push   $0x8026ff
  800b2e:	6a 23                	push   $0x23
  800b30:	68 1c 27 80 00       	push   $0x80271c
  800b35:	e8 e5 f5 ff ff       	call   80011f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_yield>:

void
sys_yield(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	be 00 00 00 00       	mov    $0x0,%esi
  800b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	89 f7                	mov    %esi,%edi
  800b9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 ff 26 80 00       	push   $0x8026ff
  800baf:	6a 23                	push   $0x23
  800bb1:	68 1c 27 80 00       	push   $0x80271c
  800bb6:	e8 64 f5 ff ff       	call   80011f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 75 18             	mov    0x18(%ebp),%esi
  800be0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 ff 26 80 00       	push   $0x8026ff
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 1c 27 80 00       	push   $0x80271c
  800bf8:	e8 22 f5 ff ff       	call   80011f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	b8 06 00 00 00       	mov    $0x6,%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 ff 26 80 00       	push   $0x8026ff
  800c33:	6a 23                	push   $0x23
  800c35:	68 1c 27 80 00       	push   $0x80271c
  800c3a:	e8 e0 f4 ff ff       	call   80011f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 ff 26 80 00       	push   $0x8026ff
  800c75:	6a 23                	push   $0x23
  800c77:	68 1c 27 80 00       	push   $0x80271c
  800c7c:	e8 9e f4 ff ff       	call   80011f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 ff 26 80 00       	push   $0x8026ff
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 1c 27 80 00       	push   $0x80271c
  800cbe:	e8 5c f4 ff ff       	call   80011f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0a                	push   $0xa
  800cf4:	68 ff 26 80 00       	push   $0x8026ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 27 80 00       	push   $0x80271c
  800d00:	e8 1a f4 ff ff       	call   80011f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	be 00 00 00 00       	mov    $0x0,%esi
  800d18:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	89 ce                	mov    %ecx,%esi
  800d4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	7e 17                	jle    800d69 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0d                	push   $0xd
  800d58:	68 ff 26 80 00       	push   $0x8026ff
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 1c 27 80 00       	push   $0x80271c
  800d64:	e8 b6 f3 ff ff       	call   80011f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d81:	89 d1                	mov    %edx,%ecx
  800d83:	89 d3                	mov    %edx,%ebx
  800d85:	89 d7                	mov    %edx,%edi
  800d87:	89 d6                	mov    %edx,%esi
  800d89:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800db7:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800dbe:	75 2c                	jne    800dec <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
        
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800dc0:	83 ec 04             	sub    $0x4,%esp
  800dc3:	6a 07                	push   $0x7
  800dc5:	68 00 f0 bf ee       	push   $0xeebff000
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 af fd ff ff       	call   800b80 <sys_page_alloc>
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	79 14                	jns    800dec <set_pgfault_handler+0x3b>
            panic("sys_page_alloc failed\n");
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	68 2a 27 80 00       	push   $0x80272a
  800de0:	6a 22                	push   $0x22
  800de2:	68 41 27 80 00       	push   $0x802741
  800de7:	e8 33 f3 ff ff       	call   80011f <_panic>
    }        
    // Save handler pointer for assembly to call.
    _pgfault_handler = handler;
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	a3 0c 40 80 00       	mov    %eax,0x80400c
    if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	68 20 0e 80 00       	push   $0x800e20
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 c8 fe ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
  800e03:	83 c4 10             	add    $0x10,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	79 14                	jns    800e1e <set_pgfault_handler+0x6d>
    	panic("sys_env_set_pgfault_upcall failed\n");
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 50 27 80 00       	push   $0x802750
  800e12:	6a 27                	push   $0x27
  800e14:	68 41 27 80 00       	push   $0x802741
  800e19:	e8 01 f3 ff ff       	call   80011f <_panic>
    
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e21:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e28:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx // trap-time eip
  800e2b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) 
  800e2f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax // trap-time esp-4
  800e34:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  800e38:	89 10                	mov    %edx,(%eax)
   

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800e3a:	83 c4 08             	add    $0x8,%esp
	popal
  800e3d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp
  800e3e:	83 c4 04             	add    $0x4,%esp
	popfl
  800e41:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e42:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e43:	c3                   	ret    

00800e44 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e64:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e71:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	c1 ea 16             	shr    $0x16,%edx
  800e7b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e82:	f6 c2 01             	test   $0x1,%dl
  800e85:	74 11                	je     800e98 <fd_alloc+0x2d>
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	c1 ea 0c             	shr    $0xc,%edx
  800e8c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e93:	f6 c2 01             	test   $0x1,%dl
  800e96:	75 09                	jne    800ea1 <fd_alloc+0x36>
			*fd_store = fd;
  800e98:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9f:	eb 17                	jmp    800eb8 <fd_alloc+0x4d>
  800ea1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ea6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eab:	75 c9                	jne    800e76 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ead:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eb3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ec0:	83 f8 1f             	cmp    $0x1f,%eax
  800ec3:	77 36                	ja     800efb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec5:	c1 e0 0c             	shl    $0xc,%eax
  800ec8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	c1 ea 16             	shr    $0x16,%edx
  800ed2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed9:	f6 c2 01             	test   $0x1,%dl
  800edc:	74 24                	je     800f02 <fd_lookup+0x48>
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 0c             	shr    $0xc,%edx
  800ee3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	74 1a                	je     800f09 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef2:	89 02                	mov    %eax,(%edx)
	return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	eb 13                	jmp    800f0e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f00:	eb 0c                	jmp    800f0e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f07:	eb 05                	jmp    800f0e <fd_lookup+0x54>
  800f09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f19:	ba f4 27 80 00       	mov    $0x8027f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f1e:	eb 13                	jmp    800f33 <dev_lookup+0x23>
  800f20:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f23:	39 08                	cmp    %ecx,(%eax)
  800f25:	75 0c                	jne    800f33 <dev_lookup+0x23>
			*dev = devtab[i];
  800f27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f31:	eb 2e                	jmp    800f61 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f33:	8b 02                	mov    (%edx),%eax
  800f35:	85 c0                	test   %eax,%eax
  800f37:	75 e7                	jne    800f20 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f39:	a1 08 40 80 00       	mov    0x804008,%eax
  800f3e:	8b 40 48             	mov    0x48(%eax),%eax
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	51                   	push   %ecx
  800f45:	50                   	push   %eax
  800f46:	68 74 27 80 00       	push   $0x802774
  800f4b:	e8 a8 f2 ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  800f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 10             	sub    $0x10,%esp
  800f6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
  800f7e:	50                   	push   %eax
  800f7f:	e8 36 ff ff ff       	call   800eba <fd_lookup>
  800f84:	83 c4 08             	add    $0x8,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 05                	js     800f90 <fd_close+0x2d>
	    || fd != fd2)
  800f8b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f8e:	74 0c                	je     800f9c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f90:	84 db                	test   %bl,%bl
  800f92:	ba 00 00 00 00       	mov    $0x0,%edx
  800f97:	0f 44 c2             	cmove  %edx,%eax
  800f9a:	eb 41                	jmp    800fdd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	ff 36                	pushl  (%esi)
  800fa5:	e8 66 ff ff ff       	call   800f10 <dev_lookup>
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 1a                	js     800fcd <fd_close+0x6a>
		if (dev->dev_close)
  800fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	74 0b                	je     800fcd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	56                   	push   %esi
  800fc6:	ff d0                	call   *%eax
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	56                   	push   %esi
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 2d fc ff ff       	call   800c05 <sys_page_unmap>
	return r;
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	89 d8                	mov    %ebx,%eax
}
  800fdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	ff 75 08             	pushl  0x8(%ebp)
  800ff1:	e8 c4 fe ff ff       	call   800eba <fd_lookup>
  800ff6:	83 c4 08             	add    $0x8,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 10                	js     80100d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	6a 01                	push   $0x1
  801002:	ff 75 f4             	pushl  -0xc(%ebp)
  801005:	e8 59 ff ff ff       	call   800f63 <fd_close>
  80100a:	83 c4 10             	add    $0x10,%esp
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <close_all>:

void
close_all(void)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	53                   	push   %ebx
  801013:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801016:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	53                   	push   %ebx
  80101f:	e8 c0 ff ff ff       	call   800fe4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801024:	83 c3 01             	add    $0x1,%ebx
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	83 fb 20             	cmp    $0x20,%ebx
  80102d:	75 ec                	jne    80101b <close_all+0xc>
		close(i);
}
  80102f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 2c             	sub    $0x2c,%esp
  80103d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801040:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801043:	50                   	push   %eax
  801044:	ff 75 08             	pushl  0x8(%ebp)
  801047:	e8 6e fe ff ff       	call   800eba <fd_lookup>
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	0f 88 c1 00 00 00    	js     801118 <dup+0xe4>
		return r;
	close(newfdnum);
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	56                   	push   %esi
  80105b:	e8 84 ff ff ff       	call   800fe4 <close>

	newfd = INDEX2FD(newfdnum);
  801060:	89 f3                	mov    %esi,%ebx
  801062:	c1 e3 0c             	shl    $0xc,%ebx
  801065:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80106b:	83 c4 04             	add    $0x4,%esp
  80106e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801071:	e8 de fd ff ff       	call   800e54 <fd2data>
  801076:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801078:	89 1c 24             	mov    %ebx,(%esp)
  80107b:	e8 d4 fd ff ff       	call   800e54 <fd2data>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801086:	89 f8                	mov    %edi,%eax
  801088:	c1 e8 16             	shr    $0x16,%eax
  80108b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801092:	a8 01                	test   $0x1,%al
  801094:	74 37                	je     8010cd <dup+0x99>
  801096:	89 f8                	mov    %edi,%eax
  801098:	c1 e8 0c             	shr    $0xc,%eax
  80109b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a2:	f6 c2 01             	test   $0x1,%dl
  8010a5:	74 26                	je     8010cd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b6:	50                   	push   %eax
  8010b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ba:	6a 00                	push   $0x0
  8010bc:	57                   	push   %edi
  8010bd:	6a 00                	push   $0x0
  8010bf:	e8 ff fa ff ff       	call   800bc3 <sys_page_map>
  8010c4:	89 c7                	mov    %eax,%edi
  8010c6:	83 c4 20             	add    $0x20,%esp
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	78 2e                	js     8010fb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010d0:	89 d0                	mov    %edx,%eax
  8010d2:	c1 e8 0c             	shr    $0xc,%eax
  8010d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e4:	50                   	push   %eax
  8010e5:	53                   	push   %ebx
  8010e6:	6a 00                	push   $0x0
  8010e8:	52                   	push   %edx
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 d3 fa ff ff       	call   800bc3 <sys_page_map>
  8010f0:	89 c7                	mov    %eax,%edi
  8010f2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010f5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f7:	85 ff                	test   %edi,%edi
  8010f9:	79 1d                	jns    801118 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010fb:	83 ec 08             	sub    $0x8,%esp
  8010fe:	53                   	push   %ebx
  8010ff:	6a 00                	push   $0x0
  801101:	e8 ff fa ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801106:	83 c4 08             	add    $0x8,%esp
  801109:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110c:	6a 00                	push   $0x0
  80110e:	e8 f2 fa ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	89 f8                	mov    %edi,%eax
}
  801118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 14             	sub    $0x14,%esp
  801127:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	53                   	push   %ebx
  80112f:	e8 86 fd ff ff       	call   800eba <fd_lookup>
  801134:	83 c4 08             	add    $0x8,%esp
  801137:	89 c2                	mov    %eax,%edx
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 6d                	js     8011aa <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801147:	ff 30                	pushl  (%eax)
  801149:	e8 c2 fd ff ff       	call   800f10 <dev_lookup>
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 4c                	js     8011a1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801155:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801158:	8b 42 08             	mov    0x8(%edx),%eax
  80115b:	83 e0 03             	and    $0x3,%eax
  80115e:	83 f8 01             	cmp    $0x1,%eax
  801161:	75 21                	jne    801184 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801163:	a1 08 40 80 00       	mov    0x804008,%eax
  801168:	8b 40 48             	mov    0x48(%eax),%eax
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	53                   	push   %ebx
  80116f:	50                   	push   %eax
  801170:	68 b8 27 80 00       	push   $0x8027b8
  801175:	e8 7e f0 ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801182:	eb 26                	jmp    8011aa <read+0x8a>
	}
	if (!dev->dev_read)
  801184:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801187:	8b 40 08             	mov    0x8(%eax),%eax
  80118a:	85 c0                	test   %eax,%eax
  80118c:	74 17                	je     8011a5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	ff 75 10             	pushl  0x10(%ebp)
  801194:	ff 75 0c             	pushl  0xc(%ebp)
  801197:	52                   	push   %edx
  801198:	ff d0                	call   *%eax
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	eb 09                	jmp    8011aa <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	eb 05                	jmp    8011aa <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011aa:	89 d0                	mov    %edx,%eax
  8011ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	57                   	push   %edi
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c5:	eb 21                	jmp    8011e8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	89 f0                	mov    %esi,%eax
  8011cc:	29 d8                	sub    %ebx,%eax
  8011ce:	50                   	push   %eax
  8011cf:	89 d8                	mov    %ebx,%eax
  8011d1:	03 45 0c             	add    0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	57                   	push   %edi
  8011d6:	e8 45 ff ff ff       	call   801120 <read>
		if (m < 0)
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 10                	js     8011f2 <readn+0x41>
			return m;
		if (m == 0)
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	74 0a                	je     8011f0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e6:	01 c3                	add    %eax,%ebx
  8011e8:	39 f3                	cmp    %esi,%ebx
  8011ea:	72 db                	jb     8011c7 <readn+0x16>
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	eb 02                	jmp    8011f2 <readn+0x41>
  8011f0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 14             	sub    $0x14,%esp
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801204:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	53                   	push   %ebx
  801209:	e8 ac fc ff ff       	call   800eba <fd_lookup>
  80120e:	83 c4 08             	add    $0x8,%esp
  801211:	89 c2                	mov    %eax,%edx
  801213:	85 c0                	test   %eax,%eax
  801215:	78 68                	js     80127f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801221:	ff 30                	pushl  (%eax)
  801223:	e8 e8 fc ff ff       	call   800f10 <dev_lookup>
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 47                	js     801276 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801232:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801236:	75 21                	jne    801259 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801238:	a1 08 40 80 00       	mov    0x804008,%eax
  80123d:	8b 40 48             	mov    0x48(%eax),%eax
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	53                   	push   %ebx
  801244:	50                   	push   %eax
  801245:	68 d4 27 80 00       	push   $0x8027d4
  80124a:	e8 a9 ef ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801257:	eb 26                	jmp    80127f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801259:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125c:	8b 52 0c             	mov    0xc(%edx),%edx
  80125f:	85 d2                	test   %edx,%edx
  801261:	74 17                	je     80127a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801263:	83 ec 04             	sub    $0x4,%esp
  801266:	ff 75 10             	pushl  0x10(%ebp)
  801269:	ff 75 0c             	pushl  0xc(%ebp)
  80126c:	50                   	push   %eax
  80126d:	ff d2                	call   *%edx
  80126f:	89 c2                	mov    %eax,%edx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	eb 09                	jmp    80127f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801276:	89 c2                	mov    %eax,%edx
  801278:	eb 05                	jmp    80127f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80127a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80127f:	89 d0                	mov    %edx,%eax
  801281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801284:	c9                   	leave  
  801285:	c3                   	ret    

00801286 <seek>:

int
seek(int fdnum, off_t offset)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 22 fc ff ff       	call   800eba <fd_lookup>
  801298:	83 c4 08             	add    $0x8,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 0e                	js     8012ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80129f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 14             	sub    $0x14,%esp
  8012b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	53                   	push   %ebx
  8012be:	e8 f7 fb ff ff       	call   800eba <fd_lookup>
  8012c3:	83 c4 08             	add    $0x8,%esp
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 65                	js     801331 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d2:	50                   	push   %eax
  8012d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d6:	ff 30                	pushl  (%eax)
  8012d8:	e8 33 fc ff ff       	call   800f10 <dev_lookup>
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 44                	js     801328 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012eb:	75 21                	jne    80130e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ed:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f2:	8b 40 48             	mov    0x48(%eax),%eax
  8012f5:	83 ec 04             	sub    $0x4,%esp
  8012f8:	53                   	push   %ebx
  8012f9:	50                   	push   %eax
  8012fa:	68 94 27 80 00       	push   $0x802794
  8012ff:	e8 f4 ee ff ff       	call   8001f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80130c:	eb 23                	jmp    801331 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80130e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801311:	8b 52 18             	mov    0x18(%edx),%edx
  801314:	85 d2                	test   %edx,%edx
  801316:	74 14                	je     80132c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	ff 75 0c             	pushl  0xc(%ebp)
  80131e:	50                   	push   %eax
  80131f:	ff d2                	call   *%edx
  801321:	89 c2                	mov    %eax,%edx
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	eb 09                	jmp    801331 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801328:	89 c2                	mov    %eax,%edx
  80132a:	eb 05                	jmp    801331 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80132c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801331:	89 d0                	mov    %edx,%eax
  801333:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 14             	sub    $0x14,%esp
  80133f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	ff 75 08             	pushl  0x8(%ebp)
  801349:	e8 6c fb ff ff       	call   800eba <fd_lookup>
  80134e:	83 c4 08             	add    $0x8,%esp
  801351:	89 c2                	mov    %eax,%edx
  801353:	85 c0                	test   %eax,%eax
  801355:	78 58                	js     8013af <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801361:	ff 30                	pushl  (%eax)
  801363:	e8 a8 fb ff ff       	call   800f10 <dev_lookup>
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 37                	js     8013a6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801376:	74 32                	je     8013aa <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801378:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80137b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801382:	00 00 00 
	stat->st_isdir = 0;
  801385:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80138c:	00 00 00 
	stat->st_dev = dev;
  80138f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	53                   	push   %ebx
  801399:	ff 75 f0             	pushl  -0x10(%ebp)
  80139c:	ff 50 14             	call   *0x14(%eax)
  80139f:	89 c2                	mov    %eax,%edx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	eb 09                	jmp    8013af <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	eb 05                	jmp    8013af <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013af:	89 d0                	mov    %edx,%eax
  8013b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	6a 00                	push   $0x0
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	e8 e7 01 00 00       	call   8015af <open>
  8013c8:	89 c3                	mov    %eax,%ebx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 1b                	js     8013ec <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013d1:	83 ec 08             	sub    $0x8,%esp
  8013d4:	ff 75 0c             	pushl  0xc(%ebp)
  8013d7:	50                   	push   %eax
  8013d8:	e8 5b ff ff ff       	call   801338 <fstat>
  8013dd:	89 c6                	mov    %eax,%esi
	close(fd);
  8013df:	89 1c 24             	mov    %ebx,(%esp)
  8013e2:	e8 fd fb ff ff       	call   800fe4 <close>
	return r;
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	89 f0                	mov    %esi,%eax
}
  8013ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ef:	5b                   	pop    %ebx
  8013f0:	5e                   	pop    %esi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	89 c6                	mov    %eax,%esi
  8013fa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013fc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801403:	75 12                	jne    801417 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801405:	83 ec 0c             	sub    $0xc,%esp
  801408:	6a 01                	push   $0x1
  80140a:	e8 4b 0c 00 00       	call   80205a <ipc_find_env>
  80140f:	a3 00 40 80 00       	mov    %eax,0x804000
  801414:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801417:	6a 07                	push   $0x7
  801419:	68 00 50 80 00       	push   $0x805000
  80141e:	56                   	push   %esi
  80141f:	ff 35 00 40 80 00    	pushl  0x804000
  801425:	e8 dc 0b 00 00       	call   802006 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80142a:	83 c4 0c             	add    $0xc,%esp
  80142d:	6a 00                	push   $0x0
  80142f:	53                   	push   %ebx
  801430:	6a 00                	push   $0x0
  801432:	e8 62 0b 00 00       	call   801f99 <ipc_recv>
}
  801437:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	8b 40 0c             	mov    0xc(%eax),%eax
  80144a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80144f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801452:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 02 00 00 00       	mov    $0x2,%eax
  801461:	e8 8d ff ff ff       	call   8013f3 <fsipc>
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80146e:	8b 45 08             	mov    0x8(%ebp),%eax
  801471:	8b 40 0c             	mov    0xc(%eax),%eax
  801474:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	b8 06 00 00 00       	mov    $0x6,%eax
  801483:	e8 6b ff ff ff       	call   8013f3 <fsipc>
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	8b 40 0c             	mov    0xc(%eax),%eax
  80149a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80149f:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a9:	e8 45 ff ff ff       	call   8013f3 <fsipc>
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 2c                	js     8014de <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	68 00 50 80 00       	push   $0x805000
  8014ba:	53                   	push   %ebx
  8014bb:	e8 bd f2 ff ff       	call   80077d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014c0:	a1 80 50 80 00       	mov    0x805080,%eax
  8014c5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014cb:	a1 84 50 80 00       	mov    0x805084,%eax
  8014d0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  8014ed:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014f2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014f7:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014fa:	53                   	push   %ebx
  8014fb:	ff 75 0c             	pushl  0xc(%ebp)
  8014fe:	68 08 50 80 00       	push   $0x805008
  801503:	e8 07 f4 ff ff       	call   80090f <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	8b 40 0c             	mov    0xc(%eax),%eax
  80150e:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  801513:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	b8 04 00 00 00       	mov    $0x4,%eax
  801523:	e8 cb fe ff ff       	call   8013f3 <fsipc>
	//panic("devfile_write not implemented");
}
  801528:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	8b 40 0c             	mov    0xc(%eax),%eax
  80153b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801540:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 03 00 00 00       	mov    $0x3,%eax
  801550:	e8 9e fe ff ff       	call   8013f3 <fsipc>
  801555:	89 c3                	mov    %eax,%ebx
  801557:	85 c0                	test   %eax,%eax
  801559:	78 4b                	js     8015a6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80155b:	39 c6                	cmp    %eax,%esi
  80155d:	73 16                	jae    801575 <devfile_read+0x48>
  80155f:	68 08 28 80 00       	push   $0x802808
  801564:	68 0f 28 80 00       	push   $0x80280f
  801569:	6a 7c                	push   $0x7c
  80156b:	68 24 28 80 00       	push   $0x802824
  801570:	e8 aa eb ff ff       	call   80011f <_panic>
	assert(r <= PGSIZE);
  801575:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157a:	7e 16                	jle    801592 <devfile_read+0x65>
  80157c:	68 2f 28 80 00       	push   $0x80282f
  801581:	68 0f 28 80 00       	push   $0x80280f
  801586:	6a 7d                	push   $0x7d
  801588:	68 24 28 80 00       	push   $0x802824
  80158d:	e8 8d eb ff ff       	call   80011f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	50                   	push   %eax
  801596:	68 00 50 80 00       	push   $0x805000
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	e8 6c f3 ff ff       	call   80090f <memmove>
	return r;
  8015a3:	83 c4 10             	add    $0x10,%esp
}
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 20             	sub    $0x20,%esp
  8015b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015b9:	53                   	push   %ebx
  8015ba:	e8 85 f1 ff ff       	call   800744 <strlen>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015c7:	7f 67                	jg     801630 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	e8 96 f8 ff ff       	call   800e6b <fd_alloc>
  8015d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 57                	js     801635 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	68 00 50 80 00       	push   $0x805000
  8015e7:	e8 91 f1 ff ff       	call   80077d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015fc:	e8 f2 fd ff ff       	call   8013f3 <fsipc>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	79 14                	jns    80161e <open+0x6f>
		fd_close(fd, 0);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	6a 00                	push   $0x0
  80160f:	ff 75 f4             	pushl  -0xc(%ebp)
  801612:	e8 4c f9 ff ff       	call   800f63 <fd_close>
		return r;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	89 da                	mov    %ebx,%edx
  80161c:	eb 17                	jmp    801635 <open+0x86>
	}

	return fd2num(fd);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	ff 75 f4             	pushl  -0xc(%ebp)
  801624:	e8 1b f8 ff ff       	call   800e44 <fd2num>
  801629:	89 c2                	mov    %eax,%edx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 05                	jmp    801635 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801630:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 08 00 00 00       	mov    $0x8,%eax
  80164c:	e8 a2 fd ff ff       	call   8013f3 <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801659:	68 3b 28 80 00       	push   $0x80283b
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	e8 17 f1 ff ff       	call   80077d <strcpy>
	return 0;
}
  801666:	b8 00 00 00 00       	mov    $0x0,%eax
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	53                   	push   %ebx
  801671:	83 ec 10             	sub    $0x10,%esp
  801674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801677:	53                   	push   %ebx
  801678:	e8 16 0a 00 00       	call   802093 <pageref>
  80167d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801680:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801685:	83 f8 01             	cmp    $0x1,%eax
  801688:	75 10                	jne    80169a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	ff 73 0c             	pushl  0xc(%ebx)
  801690:	e8 c0 02 00 00       	call   801955 <nsipc_close>
  801695:	89 c2                	mov    %eax,%edx
  801697:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80169a:	89 d0                	mov    %edx,%eax
  80169c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016a7:	6a 00                	push   $0x0
  8016a9:	ff 75 10             	pushl  0x10(%ebp)
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	ff 70 0c             	pushl  0xc(%eax)
  8016b5:	e8 78 03 00 00       	call   801a32 <nsipc_send>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016c2:	6a 00                	push   $0x0
  8016c4:	ff 75 10             	pushl  0x10(%ebp)
  8016c7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	ff 70 0c             	pushl  0xc(%eax)
  8016d0:	e8 f1 02 00 00       	call   8019c6 <nsipc_recv>
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016dd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016e0:	52                   	push   %edx
  8016e1:	50                   	push   %eax
  8016e2:	e8 d3 f7 ff ff       	call   800eba <fd_lookup>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 17                	js     801705 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016f7:	39 08                	cmp    %ecx,(%eax)
  8016f9:	75 05                	jne    801700 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fe:	eb 05                	jmp    801705 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801700:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	83 ec 1c             	sub    $0x1c,%esp
  80170f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	e8 51 f7 ff ff       	call   800e6b <fd_alloc>
  80171a:	89 c3                	mov    %eax,%ebx
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 1b                	js     80173e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	68 07 04 00 00       	push   $0x407
  80172b:	ff 75 f4             	pushl  -0xc(%ebp)
  80172e:	6a 00                	push   $0x0
  801730:	e8 4b f4 ff ff       	call   800b80 <sys_page_alloc>
  801735:	89 c3                	mov    %eax,%ebx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	79 10                	jns    80174e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	56                   	push   %esi
  801742:	e8 0e 02 00 00       	call   801955 <nsipc_close>
		return r;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	89 d8                	mov    %ebx,%eax
  80174c:	eb 24                	jmp    801772 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80174e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801757:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801763:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	50                   	push   %eax
  80176a:	e8 d5 f6 ff ff       	call   800e44 <fd2num>
  80176f:	83 c4 10             	add    $0x10,%esp
}
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	e8 50 ff ff ff       	call   8016d7 <fd2sockid>
		return r;
  801787:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 1f                	js     8017ac <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80178d:	83 ec 04             	sub    $0x4,%esp
  801790:	ff 75 10             	pushl  0x10(%ebp)
  801793:	ff 75 0c             	pushl  0xc(%ebp)
  801796:	50                   	push   %eax
  801797:	e8 12 01 00 00       	call   8018ae <nsipc_accept>
  80179c:	83 c4 10             	add    $0x10,%esp
		return r;
  80179f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 07                	js     8017ac <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8017a5:	e8 5d ff ff ff       	call   801707 <alloc_sockfd>
  8017aa:	89 c1                	mov    %eax,%ecx
}
  8017ac:	89 c8                	mov    %ecx,%eax
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	e8 19 ff ff ff       	call   8016d7 <fd2sockid>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 12                	js     8017d4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	ff 75 10             	pushl  0x10(%ebp)
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 2d 01 00 00       	call   8018fe <nsipc_bind>
  8017d1:	83 c4 10             	add    $0x10,%esp
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <shutdown>:

int
shutdown(int s, int how)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	e8 f3 fe ff ff       	call   8016d7 <fd2sockid>
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 0f                	js     8017f7 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	50                   	push   %eax
  8017ef:	e8 3f 01 00 00       	call   801933 <nsipc_shutdown>
  8017f4:	83 c4 10             	add    $0x10,%esp
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	e8 d0 fe ff ff       	call   8016d7 <fd2sockid>
  801807:	85 c0                	test   %eax,%eax
  801809:	78 12                	js     80181d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	ff 75 10             	pushl  0x10(%ebp)
  801811:	ff 75 0c             	pushl  0xc(%ebp)
  801814:	50                   	push   %eax
  801815:	e8 55 01 00 00       	call   80196f <nsipc_connect>
  80181a:	83 c4 10             	add    $0x10,%esp
}
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <listen>:

int
listen(int s, int backlog)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	e8 aa fe ff ff       	call   8016d7 <fd2sockid>
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 0f                	js     801840 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	ff 75 0c             	pushl  0xc(%ebp)
  801837:	50                   	push   %eax
  801838:	e8 67 01 00 00       	call   8019a4 <nsipc_listen>
  80183d:	83 c4 10             	add    $0x10,%esp
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801848:	ff 75 10             	pushl  0x10(%ebp)
  80184b:	ff 75 0c             	pushl  0xc(%ebp)
  80184e:	ff 75 08             	pushl  0x8(%ebp)
  801851:	e8 3a 02 00 00       	call   801a90 <nsipc_socket>
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 05                	js     801862 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80185d:	e8 a5 fe ff ff       	call   801707 <alloc_sockfd>
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 04             	sub    $0x4,%esp
  80186b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80186d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801874:	75 12                	jne    801888 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	6a 02                	push   $0x2
  80187b:	e8 da 07 00 00       	call   80205a <ipc_find_env>
  801880:	a3 04 40 80 00       	mov    %eax,0x804004
  801885:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801888:	6a 07                	push   $0x7
  80188a:	68 00 60 80 00       	push   $0x806000
  80188f:	53                   	push   %ebx
  801890:	ff 35 04 40 80 00    	pushl  0x804004
  801896:	e8 6b 07 00 00       	call   802006 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80189b:	83 c4 0c             	add    $0xc,%esp
  80189e:	6a 00                	push   $0x0
  8018a0:	6a 00                	push   $0x0
  8018a2:	6a 00                	push   $0x0
  8018a4:	e8 f0 06 00 00       	call   801f99 <ipc_recv>
}
  8018a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018be:	8b 06                	mov    (%esi),%eax
  8018c0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ca:	e8 95 ff ff ff       	call   801864 <nsipc>
  8018cf:	89 c3                	mov    %eax,%ebx
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 20                	js     8018f5 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	ff 35 10 60 80 00    	pushl  0x806010
  8018de:	68 00 60 80 00       	push   $0x806000
  8018e3:	ff 75 0c             	pushl  0xc(%ebp)
  8018e6:	e8 24 f0 ff ff       	call   80090f <memmove>
		*addrlen = ret->ret_addrlen;
  8018eb:	a1 10 60 80 00       	mov    0x806010,%eax
  8018f0:	89 06                	mov    %eax,(%esi)
  8018f2:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018f5:	89 d8                	mov    %ebx,%eax
  8018f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	53                   	push   %ebx
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801910:	53                   	push   %ebx
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	68 04 60 80 00       	push   $0x806004
  801919:	e8 f1 ef ff ff       	call   80090f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80191e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801924:	b8 02 00 00 00       	mov    $0x2,%eax
  801929:	e8 36 ff ff ff       	call   801864 <nsipc>
}
  80192e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801949:	b8 03 00 00 00       	mov    $0x3,%eax
  80194e:	e8 11 ff ff ff       	call   801864 <nsipc>
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <nsipc_close>:

int
nsipc_close(int s)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801963:	b8 04 00 00 00       	mov    $0x4,%eax
  801968:	e8 f7 fe ff ff       	call   801864 <nsipc>
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	53                   	push   %ebx
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801981:	53                   	push   %ebx
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	68 04 60 80 00       	push   $0x806004
  80198a:	e8 80 ef ff ff       	call   80090f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80198f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801995:	b8 05 00 00 00       	mov    $0x5,%eax
  80199a:	e8 c5 fe ff ff       	call   801864 <nsipc>
}
  80199f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8019b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8019bf:	e8 a0 fe ff ff       	call   801864 <nsipc>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019d6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019e4:	b8 07 00 00 00       	mov    $0x7,%eax
  8019e9:	e8 76 fe ff ff       	call   801864 <nsipc>
  8019ee:	89 c3                	mov    %eax,%ebx
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 35                	js     801a29 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019f4:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019f9:	7f 04                	jg     8019ff <nsipc_recv+0x39>
  8019fb:	39 c6                	cmp    %eax,%esi
  8019fd:	7d 16                	jge    801a15 <nsipc_recv+0x4f>
  8019ff:	68 47 28 80 00       	push   $0x802847
  801a04:	68 0f 28 80 00       	push   $0x80280f
  801a09:	6a 62                	push   $0x62
  801a0b:	68 5c 28 80 00       	push   $0x80285c
  801a10:	e8 0a e7 ff ff       	call   80011f <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a15:	83 ec 04             	sub    $0x4,%esp
  801a18:	50                   	push   %eax
  801a19:	68 00 60 80 00       	push   $0x806000
  801a1e:	ff 75 0c             	pushl  0xc(%ebp)
  801a21:	e8 e9 ee ff ff       	call   80090f <memmove>
  801a26:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	53                   	push   %ebx
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a44:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a4a:	7e 16                	jle    801a62 <nsipc_send+0x30>
  801a4c:	68 68 28 80 00       	push   $0x802868
  801a51:	68 0f 28 80 00       	push   $0x80280f
  801a56:	6a 6d                	push   $0x6d
  801a58:	68 5c 28 80 00       	push   $0x80285c
  801a5d:	e8 bd e6 ff ff       	call   80011f <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a62:	83 ec 04             	sub    $0x4,%esp
  801a65:	53                   	push   %ebx
  801a66:	ff 75 0c             	pushl  0xc(%ebp)
  801a69:	68 0c 60 80 00       	push   $0x80600c
  801a6e:	e8 9c ee ff ff       	call   80090f <memmove>
	nsipcbuf.send.req_size = size;
  801a73:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a79:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a81:	b8 08 00 00 00       	mov    $0x8,%eax
  801a86:	e8 d9 fd ff ff       	call   801864 <nsipc>
}
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801aae:	b8 09 00 00 00       	mov    $0x9,%eax
  801ab3:	e8 ac fd ff ff       	call   801864 <nsipc>
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	ff 75 08             	pushl  0x8(%ebp)
  801ac8:	e8 87 f3 ff ff       	call   800e54 <fd2data>
  801acd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801acf:	83 c4 08             	add    $0x8,%esp
  801ad2:	68 74 28 80 00       	push   $0x802874
  801ad7:	53                   	push   %ebx
  801ad8:	e8 a0 ec ff ff       	call   80077d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801add:	8b 46 04             	mov    0x4(%esi),%eax
  801ae0:	2b 06                	sub    (%esi),%eax
  801ae2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ae8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aef:	00 00 00 
	stat->st_dev = &devpipe;
  801af2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801af9:	30 80 00 
	return 0;
}
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
  801b01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 0c             	sub    $0xc,%esp
  801b0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b12:	53                   	push   %ebx
  801b13:	6a 00                	push   $0x0
  801b15:	e8 eb f0 ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b1a:	89 1c 24             	mov    %ebx,(%esp)
  801b1d:	e8 32 f3 ff ff       	call   800e54 <fd2data>
  801b22:	83 c4 08             	add    $0x8,%esp
  801b25:	50                   	push   %eax
  801b26:	6a 00                	push   $0x0
  801b28:	e8 d8 f0 ff ff       	call   800c05 <sys_page_unmap>
}
  801b2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 1c             	sub    $0x1c,%esp
  801b3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b3e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b40:	a1 08 40 80 00       	mov    0x804008,%eax
  801b45:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	ff 75 e0             	pushl  -0x20(%ebp)
  801b4e:	e8 40 05 00 00       	call   802093 <pageref>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	89 3c 24             	mov    %edi,(%esp)
  801b58:	e8 36 05 00 00       	call   802093 <pageref>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	39 c3                	cmp    %eax,%ebx
  801b62:	0f 94 c1             	sete   %cl
  801b65:	0f b6 c9             	movzbl %cl,%ecx
  801b68:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b6b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b71:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b74:	39 ce                	cmp    %ecx,%esi
  801b76:	74 1b                	je     801b93 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b78:	39 c3                	cmp    %eax,%ebx
  801b7a:	75 c4                	jne    801b40 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b7c:	8b 42 58             	mov    0x58(%edx),%eax
  801b7f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b82:	50                   	push   %eax
  801b83:	56                   	push   %esi
  801b84:	68 7b 28 80 00       	push   $0x80287b
  801b89:	e8 6a e6 ff ff       	call   8001f8 <cprintf>
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	eb ad                	jmp    801b40 <_pipeisclosed+0xe>
	}
}
  801b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b99:	5b                   	pop    %ebx
  801b9a:	5e                   	pop    %esi
  801b9b:	5f                   	pop    %edi
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 28             	sub    $0x28,%esp
  801ba7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801baa:	56                   	push   %esi
  801bab:	e8 a4 f2 ff ff       	call   800e54 <fd2data>
  801bb0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	bf 00 00 00 00       	mov    $0x0,%edi
  801bba:	eb 4b                	jmp    801c07 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bbc:	89 da                	mov    %ebx,%edx
  801bbe:	89 f0                	mov    %esi,%eax
  801bc0:	e8 6d ff ff ff       	call   801b32 <_pipeisclosed>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	75 48                	jne    801c11 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bc9:	e8 93 ef ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bce:	8b 43 04             	mov    0x4(%ebx),%eax
  801bd1:	8b 0b                	mov    (%ebx),%ecx
  801bd3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bd6:	39 d0                	cmp    %edx,%eax
  801bd8:	73 e2                	jae    801bbc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bdd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801be1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801be4:	89 c2                	mov    %eax,%edx
  801be6:	c1 fa 1f             	sar    $0x1f,%edx
  801be9:	89 d1                	mov    %edx,%ecx
  801beb:	c1 e9 1b             	shr    $0x1b,%ecx
  801bee:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bf1:	83 e2 1f             	and    $0x1f,%edx
  801bf4:	29 ca                	sub    %ecx,%edx
  801bf6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bfa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bfe:	83 c0 01             	add    $0x1,%eax
  801c01:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c04:	83 c7 01             	add    $0x1,%edi
  801c07:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c0a:	75 c2                	jne    801bce <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0f:	eb 05                	jmp    801c16 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c19:	5b                   	pop    %ebx
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 18             	sub    $0x18,%esp
  801c27:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c2a:	57                   	push   %edi
  801c2b:	e8 24 f2 ff ff       	call   800e54 <fd2data>
  801c30:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3a:	eb 3d                	jmp    801c79 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c3c:	85 db                	test   %ebx,%ebx
  801c3e:	74 04                	je     801c44 <devpipe_read+0x26>
				return i;
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	eb 44                	jmp    801c88 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c44:	89 f2                	mov    %esi,%edx
  801c46:	89 f8                	mov    %edi,%eax
  801c48:	e8 e5 fe ff ff       	call   801b32 <_pipeisclosed>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	75 32                	jne    801c83 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c51:	e8 0b ef ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c56:	8b 06                	mov    (%esi),%eax
  801c58:	3b 46 04             	cmp    0x4(%esi),%eax
  801c5b:	74 df                	je     801c3c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c5d:	99                   	cltd   
  801c5e:	c1 ea 1b             	shr    $0x1b,%edx
  801c61:	01 d0                	add    %edx,%eax
  801c63:	83 e0 1f             	and    $0x1f,%eax
  801c66:	29 d0                	sub    %edx,%eax
  801c68:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c70:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c73:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c76:	83 c3 01             	add    $0x1,%ebx
  801c79:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c7c:	75 d8                	jne    801c56 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c81:	eb 05                	jmp    801c88 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5f                   	pop    %edi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9b:	50                   	push   %eax
  801c9c:	e8 ca f1 ff ff       	call   800e6b <fd_alloc>
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	89 c2                	mov    %eax,%edx
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	0f 88 2c 01 00 00    	js     801dda <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cae:	83 ec 04             	sub    $0x4,%esp
  801cb1:	68 07 04 00 00       	push   $0x407
  801cb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 c0 ee ff ff       	call   800b80 <sys_page_alloc>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	0f 88 0d 01 00 00    	js     801dda <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ccd:	83 ec 0c             	sub    $0xc,%esp
  801cd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cd3:	50                   	push   %eax
  801cd4:	e8 92 f1 ff ff       	call   800e6b <fd_alloc>
  801cd9:	89 c3                	mov    %eax,%ebx
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	0f 88 e2 00 00 00    	js     801dc8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce6:	83 ec 04             	sub    $0x4,%esp
  801ce9:	68 07 04 00 00       	push   $0x407
  801cee:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf1:	6a 00                	push   $0x0
  801cf3:	e8 88 ee ff ff       	call   800b80 <sys_page_alloc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	0f 88 c3 00 00 00    	js     801dc8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d05:	83 ec 0c             	sub    $0xc,%esp
  801d08:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0b:	e8 44 f1 ff ff       	call   800e54 <fd2data>
  801d10:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d12:	83 c4 0c             	add    $0xc,%esp
  801d15:	68 07 04 00 00       	push   $0x407
  801d1a:	50                   	push   %eax
  801d1b:	6a 00                	push   $0x0
  801d1d:	e8 5e ee ff ff       	call   800b80 <sys_page_alloc>
  801d22:	89 c3                	mov    %eax,%ebx
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	85 c0                	test   %eax,%eax
  801d29:	0f 88 89 00 00 00    	js     801db8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	ff 75 f0             	pushl  -0x10(%ebp)
  801d35:	e8 1a f1 ff ff       	call   800e54 <fd2data>
  801d3a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d41:	50                   	push   %eax
  801d42:	6a 00                	push   $0x0
  801d44:	56                   	push   %esi
  801d45:	6a 00                	push   $0x0
  801d47:	e8 77 ee ff ff       	call   800bc3 <sys_page_map>
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	83 c4 20             	add    $0x20,%esp
  801d51:	85 c0                	test   %eax,%eax
  801d53:	78 55                	js     801daa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d55:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d63:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d6a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d73:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d78:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	e8 ba f0 ff ff       	call   800e44 <fd2num>
  801d8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d8f:	83 c4 04             	add    $0x4,%esp
  801d92:	ff 75 f0             	pushl  -0x10(%ebp)
  801d95:	e8 aa f0 ff ff       	call   800e44 <fd2num>
  801d9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d9d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	ba 00 00 00 00       	mov    $0x0,%edx
  801da8:	eb 30                	jmp    801dda <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	56                   	push   %esi
  801dae:	6a 00                	push   $0x0
  801db0:	e8 50 ee ff ff       	call   800c05 <sys_page_unmap>
  801db5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801db8:	83 ec 08             	sub    $0x8,%esp
  801dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbe:	6a 00                	push   $0x0
  801dc0:	e8 40 ee ff ff       	call   800c05 <sys_page_unmap>
  801dc5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dc8:	83 ec 08             	sub    $0x8,%esp
  801dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 30 ee ff ff       	call   800c05 <sys_page_unmap>
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ddf:	5b                   	pop    %ebx
  801de0:	5e                   	pop    %esi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	ff 75 08             	pushl  0x8(%ebp)
  801df0:	e8 c5 f0 ff ff       	call   800eba <fd_lookup>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 18                	js     801e14 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	ff 75 f4             	pushl  -0xc(%ebp)
  801e02:	e8 4d f0 ff ff       	call   800e54 <fd2data>
	return _pipeisclosed(fd, p);
  801e07:	89 c2                	mov    %eax,%edx
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	e8 21 fd ff ff       	call   801b32 <_pipeisclosed>
  801e11:	83 c4 10             	add    $0x10,%esp
}
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e26:	68 93 28 80 00       	push   $0x802893
  801e2b:	ff 75 0c             	pushl  0xc(%ebp)
  801e2e:	e8 4a e9 ff ff       	call   80077d <strcpy>
	return 0;
}
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	57                   	push   %edi
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e46:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e4b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e51:	eb 2d                	jmp    801e80 <devcons_write+0x46>
		m = n - tot;
  801e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e56:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e58:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e5b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e60:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e63:	83 ec 04             	sub    $0x4,%esp
  801e66:	53                   	push   %ebx
  801e67:	03 45 0c             	add    0xc(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	57                   	push   %edi
  801e6c:	e8 9e ea ff ff       	call   80090f <memmove>
		sys_cputs(buf, m);
  801e71:	83 c4 08             	add    $0x8,%esp
  801e74:	53                   	push   %ebx
  801e75:	57                   	push   %edi
  801e76:	e8 49 ec ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7b:	01 de                	add    %ebx,%esi
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	89 f0                	mov    %esi,%eax
  801e82:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e85:	72 cc                	jb     801e53 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 08             	sub    $0x8,%esp
  801e95:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e9e:	74 2a                	je     801eca <devcons_read+0x3b>
  801ea0:	eb 05                	jmp    801ea7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ea2:	e8 ba ec ff ff       	call   800b61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ea7:	e8 36 ec ff ff       	call   800ae2 <sys_cgetc>
  801eac:	85 c0                	test   %eax,%eax
  801eae:	74 f2                	je     801ea2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 16                	js     801eca <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eb4:	83 f8 04             	cmp    $0x4,%eax
  801eb7:	74 0c                	je     801ec5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebc:	88 02                	mov    %al,(%edx)
	return 1;
  801ebe:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec3:	eb 05                	jmp    801eca <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed8:	6a 01                	push   $0x1
  801eda:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801edd:	50                   	push   %eax
  801ede:	e8 e1 eb ff ff       	call   800ac4 <sys_cputs>
}
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <getchar>:

int
getchar(void)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eee:	6a 01                	push   $0x1
  801ef0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	6a 00                	push   $0x0
  801ef6:	e8 25 f2 ff ff       	call   801120 <read>
	if (r < 0)
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	78 0f                	js     801f11 <getchar+0x29>
		return r;
	if (r < 1)
  801f02:	85 c0                	test   %eax,%eax
  801f04:	7e 06                	jle    801f0c <getchar+0x24>
		return -E_EOF;
	return c;
  801f06:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f0a:	eb 05                	jmp    801f11 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f0c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	ff 75 08             	pushl  0x8(%ebp)
  801f20:	e8 95 ef ff ff       	call   800eba <fd_lookup>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 11                	js     801f3d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f35:	39 10                	cmp    %edx,(%eax)
  801f37:	0f 94 c0             	sete   %al
  801f3a:	0f b6 c0             	movzbl %al,%eax
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <opencons>:

int
opencons(void)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f48:	50                   	push   %eax
  801f49:	e8 1d ef ff ff       	call   800e6b <fd_alloc>
  801f4e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f51:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 3e                	js     801f95 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f57:	83 ec 04             	sub    $0x4,%esp
  801f5a:	68 07 04 00 00       	push   $0x407
  801f5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f62:	6a 00                	push   $0x0
  801f64:	e8 17 ec ff ff       	call   800b80 <sys_page_alloc>
  801f69:	83 c4 10             	add    $0x10,%esp
		return r;
  801f6c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 23                	js     801f95 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f72:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f87:	83 ec 0c             	sub    $0xc,%esp
  801f8a:	50                   	push   %eax
  801f8b:	e8 b4 ee ff ff       	call   800e44 <fd2num>
  801f90:	89 c2                	mov    %eax,%edx
  801f92:	83 c4 10             	add    $0x10,%esp
}
  801f95:	89 d0                	mov    %edx,%eax
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	56                   	push   %esi
  801f9d:	53                   	push   %ebx
  801f9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	74 0e                	je     801fb9 <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	50                   	push   %eax
  801faf:	e8 7c ed ff ff       	call   800d30 <sys_ipc_recv>
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	eb 10                	jmp    801fc9 <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	68 00 00 00 f0       	push   $0xf0000000
  801fc1:	e8 6a ed ff ff       	call   800d30 <sys_ipc_recv>
  801fc6:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	74 0e                	je     801fdb <ipc_recv+0x42>
    	*from_env_store = 0;
  801fcd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801fd3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801fd9:	eb 24                	jmp    801fff <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801fdb:	85 f6                	test   %esi,%esi
  801fdd:	74 0a                	je     801fe9 <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801fdf:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe4:	8b 40 74             	mov    0x74(%eax),%eax
  801fe7:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801fe9:	85 db                	test   %ebx,%ebx
  801feb:	74 0a                	je     801ff7 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801fed:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff2:	8b 40 78             	mov    0x78(%eax),%eax
  801ff5:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801ff7:	a1 08 40 80 00       	mov    0x804008,%eax
  801ffc:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802002:	5b                   	pop    %ebx
  802003:	5e                   	pop    %esi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    

00802006 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802012:	8b 75 0c             	mov    0xc(%ebp),%esi
  802015:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  802018:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  80201a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80201f:	0f 44 d8             	cmove  %eax,%ebx
  802022:	eb 1c                	jmp    802040 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  802024:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802027:	74 12                	je     80203b <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  802029:	50                   	push   %eax
  80202a:	68 9f 28 80 00       	push   $0x80289f
  80202f:	6a 4b                	push   $0x4b
  802031:	68 b7 28 80 00       	push   $0x8028b7
  802036:	e8 e4 e0 ff ff       	call   80011f <_panic>
        }	
        sys_yield();
  80203b:	e8 21 eb ff ff       	call   800b61 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802040:	ff 75 14             	pushl  0x14(%ebp)
  802043:	53                   	push   %ebx
  802044:	56                   	push   %esi
  802045:	57                   	push   %edi
  802046:	e8 c2 ec ff ff       	call   800d0d <sys_ipc_try_send>
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	85 c0                	test   %eax,%eax
  802050:	75 d2                	jne    802024 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802052:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802065:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802068:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80206e:	8b 52 50             	mov    0x50(%edx),%edx
  802071:	39 ca                	cmp    %ecx,%edx
  802073:	75 0d                	jne    802082 <ipc_find_env+0x28>
			return envs[i].env_id;
  802075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80207d:	8b 40 48             	mov    0x48(%eax),%eax
  802080:	eb 0f                	jmp    802091 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802082:	83 c0 01             	add    $0x1,%eax
  802085:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208a:	75 d9                	jne    802065 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80208c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    

00802093 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802099:	89 d0                	mov    %edx,%eax
  80209b:	c1 e8 16             	shr    $0x16,%eax
  80209e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020aa:	f6 c1 01             	test   $0x1,%cl
  8020ad:	74 1d                	je     8020cc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020af:	c1 ea 0c             	shr    $0xc,%edx
  8020b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020b9:	f6 c2 01             	test   $0x1,%dl
  8020bc:	74 0e                	je     8020cc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020be:	c1 ea 0c             	shr    $0xc,%edx
  8020c1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020c8:	ef 
  8020c9:	0f b7 c0             	movzwl %ax,%eax
}
  8020cc:	5d                   	pop    %ebp
  8020cd:	c3                   	ret    
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
