
obj/user/testtime.debug:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003a:	e8 76 0d 00 00       	call   800db5 <sys_time_msec>
	unsigned end = now + sec * 1000;
  80003f:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  800046:	01 c3                	add    %eax,%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
  800048:	89 c2                	mov    %eax,%edx
  80004a:	c1 ea 1f             	shr    $0x1f,%edx
  80004d:	84 d2                	test   %dl,%dl
  80004f:	74 17                	je     800068 <sleep+0x35>
  800051:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800054:	7c 12                	jl     800068 <sleep+0x35>
		panic("sys_time_msec: %e", (int)now);
  800056:	50                   	push   %eax
  800057:	68 20 23 80 00       	push   $0x802320
  80005c:	6a 0b                	push   $0xb
  80005e:	68 32 23 80 00       	push   $0x802332
  800063:	e8 fb 00 00 00       	call   800163 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 42 23 80 00       	push   $0x802342
  800074:	6a 0d                	push   $0xd
  800076:	68 32 23 80 00       	push   $0x802332
  80007b:	e8 e3 00 00 00       	call   800163 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  800080:	e8 20 0b 00 00       	call   800ba5 <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  800085:	e8 2b 0d 00 00       	call   800db5 <sys_time_msec>
  80008a:	39 c3                	cmp    %eax,%ebx
  80008c:	77 f2                	ja     800080 <sleep+0x4d>
		sys_yield();
}
  80008e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <umain>:

void
umain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	53                   	push   %ebx
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  80009f:	e8 01 0b 00 00       	call   800ba5 <sys_yield>
umain(int argc, char **argv)
{
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000a4:	83 eb 01             	sub    $0x1,%ebx
  8000a7:	75 f6                	jne    80009f <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 4e 23 80 00       	push   $0x80234e
  8000b1:	e8 86 01 00 00       	call   80023c <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 64 23 80 00       	push   $0x802364
  8000c7:	e8 70 01 00 00       	call   80023c <cprintf>
		sleep(1);
  8000cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000d3:	e8 5b ff ff ff       	call   800033 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000d8:	83 eb 01             	sub    $0x1,%ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000e1:	75 db                	jne    8000be <umain+0x2b>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	68 e4 27 80 00       	push   $0x8027e4
  8000eb:	e8 4c 01 00 00       	call   80023c <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8000f0:	cc                   	int3   
	breakpoint();
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800104:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  80010b:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80010e:	e8 73 0a 00 00       	call   800b86 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x37>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 59 ff ff ff       	call   800093 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014f:	e8 6c 0e 00 00       	call   800fc0 <close_all>
	sys_env_destroy(0);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	6a 00                	push   $0x0
  800159:	e8 e7 09 00 00       	call   800b45 <sys_env_destroy>
}
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800168:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800171:	e8 10 0a 00 00       	call   800b86 <sys_getenvid>
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 75 0c             	pushl  0xc(%ebp)
  80017c:	ff 75 08             	pushl  0x8(%ebp)
  80017f:	56                   	push   %esi
  800180:	50                   	push   %eax
  800181:	68 74 23 80 00       	push   $0x802374
  800186:	e8 b1 00 00 00       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018b:	83 c4 18             	add    $0x18,%esp
  80018e:	53                   	push   %ebx
  80018f:	ff 75 10             	pushl  0x10(%ebp)
  800192:	e8 54 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 e4 27 80 00 	movl   $0x8027e4,(%esp)
  80019e:	e8 99 00 00 00       	call   80023c <cprintf>
  8001a3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a6:	cc                   	int3   
  8001a7:	eb fd                	jmp    8001a6 <_panic+0x43>

008001a9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 04             	sub    $0x4,%esp
  8001b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b3:	8b 13                	mov    (%ebx),%edx
  8001b5:	8d 42 01             	lea    0x1(%edx),%eax
  8001b8:	89 03                	mov    %eax,(%ebx)
  8001ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c6:	75 1a                	jne    8001e2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 ff 00 00 00       	push   $0xff
  8001d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d3:	50                   	push   %eax
  8001d4:	e8 2f 09 00 00       	call   800b08 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001df:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	ff 75 0c             	pushl  0xc(%ebp)
  80020b:	ff 75 08             	pushl  0x8(%ebp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	50                   	push   %eax
  800215:	68 a9 01 80 00       	push   $0x8001a9
  80021a:	e8 54 01 00 00       	call   800373 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021f:	83 c4 08             	add    $0x8,%esp
  800222:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800228:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 d4 08 00 00       	call   800b08 <sys_cputs>

	return b.cnt;
}
  800234:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800242:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800245:	50                   	push   %eax
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	e8 9d ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 1c             	sub    $0x1c,%esp
  800259:	89 c7                	mov    %eax,%edi
  80025b:	89 d6                	mov    %edx,%esi
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	8b 55 0c             	mov    0xc(%ebp),%edx
  800263:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800266:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800269:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800274:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800277:	39 d3                	cmp    %edx,%ebx
  800279:	72 05                	jb     800280 <printnum+0x30>
  80027b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027e:	77 45                	ja     8002c5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800280:	83 ec 0c             	sub    $0xc,%esp
  800283:	ff 75 18             	pushl  0x18(%ebp)
  800286:	8b 45 14             	mov    0x14(%ebp),%eax
  800289:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80028c:	53                   	push   %ebx
  80028d:	ff 75 10             	pushl  0x10(%ebp)
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 75 e4             	pushl  -0x1c(%ebp)
  800296:	ff 75 e0             	pushl  -0x20(%ebp)
  800299:	ff 75 dc             	pushl  -0x24(%ebp)
  80029c:	ff 75 d8             	pushl  -0x28(%ebp)
  80029f:	e8 dc 1d 00 00       	call   802080 <__udivdi3>
  8002a4:	83 c4 18             	add    $0x18,%esp
  8002a7:	52                   	push   %edx
  8002a8:	50                   	push   %eax
  8002a9:	89 f2                	mov    %esi,%edx
  8002ab:	89 f8                	mov    %edi,%eax
  8002ad:	e8 9e ff ff ff       	call   800250 <printnum>
  8002b2:	83 c4 20             	add    $0x20,%esp
  8002b5:	eb 18                	jmp    8002cf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	56                   	push   %esi
  8002bb:	ff 75 18             	pushl  0x18(%ebp)
  8002be:	ff d7                	call   *%edi
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	eb 03                	jmp    8002c8 <printnum+0x78>
  8002c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	85 db                	test   %ebx,%ebx
  8002cd:	7f e8                	jg     8002b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cf:	83 ec 08             	sub    $0x8,%esp
  8002d2:	56                   	push   %esi
  8002d3:	83 ec 04             	sub    $0x4,%esp
  8002d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002df:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e2:	e8 c9 1e 00 00       	call   8021b0 <__umoddi3>
  8002e7:	83 c4 14             	add    $0x14,%esp
  8002ea:	0f be 80 97 23 80 00 	movsbl 0x802397(%eax),%eax
  8002f1:	50                   	push   %eax
  8002f2:	ff d7                	call   *%edi
}
  8002f4:	83 c4 10             	add    $0x10,%esp
  8002f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800302:	83 fa 01             	cmp    $0x1,%edx
  800305:	7e 0e                	jle    800315 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	8b 52 04             	mov    0x4(%edx),%edx
  800313:	eb 22                	jmp    800337 <getuint+0x38>
	else if (lflag)
  800315:	85 d2                	test   %edx,%edx
  800317:	74 10                	je     800329 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 0e                	jmp    800337 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 02                	mov    (%edx),%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 0a                	jae    800354 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	88 02                	mov    %al,(%edx)
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	50                   	push   %eax
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	ff 75 0c             	pushl  0xc(%ebp)
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	e8 05 00 00 00       	call   800373 <vprintfmt>
	va_end(ap);
}
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 2c             	sub    $0x2c,%esp
  80037c:	8b 75 08             	mov    0x8(%ebp),%esi
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800382:	8b 7d 10             	mov    0x10(%ebp),%edi
  800385:	eb 12                	jmp    800399 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800387:	85 c0                	test   %eax,%eax
  800389:	0f 84 89 03 00 00    	je     800718 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	53                   	push   %ebx
  800393:	50                   	push   %eax
  800394:	ff d6                	call   *%esi
  800396:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	83 c7 01             	add    $0x1,%edi
  80039c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003a0:	83 f8 25             	cmp    $0x25,%eax
  8003a3:	75 e2                	jne    800387 <vprintfmt+0x14>
  8003a5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c3:	eb 07                	jmp    8003cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8d 47 01             	lea    0x1(%edi),%eax
  8003cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d2:	0f b6 07             	movzbl (%edi),%eax
  8003d5:	0f b6 c8             	movzbl %al,%ecx
  8003d8:	83 e8 23             	sub    $0x23,%eax
  8003db:	3c 55                	cmp    $0x55,%al
  8003dd:	0f 87 1a 03 00 00    	ja     8006fd <vprintfmt+0x38a>
  8003e3:	0f b6 c0             	movzbl %al,%eax
  8003e6:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f4:	eb d6                	jmp    8003cc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800401:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800404:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800408:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80040b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040e:	83 fa 09             	cmp    $0x9,%edx
  800411:	77 39                	ja     80044c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800413:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800416:	eb e9                	jmp    800401 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 48 04             	lea    0x4(%eax),%ecx
  80041e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800421:	8b 00                	mov    (%eax),%eax
  800423:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800429:	eb 27                	jmp    800452 <vprintfmt+0xdf>
  80042b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	b9 00 00 00 00       	mov    $0x0,%ecx
  800435:	0f 49 c8             	cmovns %eax,%ecx
  800438:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043e:	eb 8c                	jmp    8003cc <vprintfmt+0x59>
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800443:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80044a:	eb 80                	jmp    8003cc <vprintfmt+0x59>
  80044c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 89 70 ff ff ff    	jns    8003cc <vprintfmt+0x59>
				width = precision, precision = -1;
  80045c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800462:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800469:	e9 5e ff ff ff       	jmp    8003cc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800474:	e9 53 ff ff ff       	jmp    8003cc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	53                   	push   %ebx
  800486:	ff 30                	pushl  (%eax)
  800488:	ff d6                	call   *%esi
			break;
  80048a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800490:	e9 04 ff ff ff       	jmp    800399 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	99                   	cltd   
  8004a1:	31 d0                	xor    %edx,%eax
  8004a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a5:	83 f8 0f             	cmp    $0xf,%eax
  8004a8:	7f 0b                	jg     8004b5 <vprintfmt+0x142>
  8004aa:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8004b1:	85 d2                	test   %edx,%edx
  8004b3:	75 18                	jne    8004cd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b5:	50                   	push   %eax
  8004b6:	68 af 23 80 00       	push   $0x8023af
  8004bb:	53                   	push   %ebx
  8004bc:	56                   	push   %esi
  8004bd:	e8 94 fe ff ff       	call   800356 <printfmt>
  8004c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c8:	e9 cc fe ff ff       	jmp    800399 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004cd:	52                   	push   %edx
  8004ce:	68 79 27 80 00       	push   $0x802779
  8004d3:	53                   	push   %ebx
  8004d4:	56                   	push   %esi
  8004d5:	e8 7c fe ff ff       	call   800356 <printfmt>
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e0:	e9 b4 fe ff ff       	jmp    800399 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
  8004f7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fe:	0f 8e 94 00 00 00    	jle    800598 <vprintfmt+0x225>
  800504:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800508:	0f 84 98 00 00 00    	je     8005a6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 d0             	pushl  -0x30(%ebp)
  800514:	57                   	push   %edi
  800515:	e8 86 02 00 00       	call   8007a0 <strnlen>
  80051a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800525:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800529:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	eb 0f                	jmp    800542 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	ff 75 e0             	pushl  -0x20(%ebp)
  80053a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053c:	83 ef 01             	sub    $0x1,%edi
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	85 ff                	test   %edi,%edi
  800544:	7f ed                	jg     800533 <vprintfmt+0x1c0>
  800546:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800549:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054c:	85 c9                	test   %ecx,%ecx
  80054e:	b8 00 00 00 00       	mov    $0x0,%eax
  800553:	0f 49 c1             	cmovns %ecx,%eax
  800556:	29 c1                	sub    %eax,%ecx
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	89 cb                	mov    %ecx,%ebx
  800563:	eb 4d                	jmp    8005b2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800565:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800569:	74 1b                	je     800586 <vprintfmt+0x213>
  80056b:	0f be c0             	movsbl %al,%eax
  80056e:	83 e8 20             	sub    $0x20,%eax
  800571:	83 f8 5e             	cmp    $0x5e,%eax
  800574:	76 10                	jbe    800586 <vprintfmt+0x213>
					putch('?', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	ff 75 0c             	pushl  0xc(%ebp)
  80057c:	6a 3f                	push   $0x3f
  80057e:	ff 55 08             	call   *0x8(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	eb 0d                	jmp    800593 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	52                   	push   %edx
  80058d:	ff 55 08             	call   *0x8(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800593:	83 eb 01             	sub    $0x1,%ebx
  800596:	eb 1a                	jmp    8005b2 <vprintfmt+0x23f>
  800598:	89 75 08             	mov    %esi,0x8(%ebp)
  80059b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a4:	eb 0c                	jmp    8005b2 <vprintfmt+0x23f>
  8005a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b2:	83 c7 01             	add    $0x1,%edi
  8005b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b9:	0f be d0             	movsbl %al,%edx
  8005bc:	85 d2                	test   %edx,%edx
  8005be:	74 23                	je     8005e3 <vprintfmt+0x270>
  8005c0:	85 f6                	test   %esi,%esi
  8005c2:	78 a1                	js     800565 <vprintfmt+0x1f2>
  8005c4:	83 ee 01             	sub    $0x1,%esi
  8005c7:	79 9c                	jns    800565 <vprintfmt+0x1f2>
  8005c9:	89 df                	mov    %ebx,%edi
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d1:	eb 18                	jmp    8005eb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 20                	push   $0x20
  8005d9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005db:	83 ef 01             	sub    $0x1,%edi
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	eb 08                	jmp    8005eb <vprintfmt+0x278>
  8005e3:	89 df                	mov    %ebx,%edi
  8005e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005eb:	85 ff                	test   %edi,%edi
  8005ed:	7f e4                	jg     8005d3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f2:	e9 a2 fd ff ff       	jmp    800399 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f7:	83 fa 01             	cmp    $0x1,%edx
  8005fa:	7e 16                	jle    800612 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 08             	lea    0x8(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 50 04             	mov    0x4(%eax),%edx
  800608:	8b 00                	mov    (%eax),%eax
  80060a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800610:	eb 32                	jmp    800644 <vprintfmt+0x2d1>
	else if (lflag)
  800612:	85 d2                	test   %edx,%edx
  800614:	74 18                	je     80062e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800624:	89 c1                	mov    %eax,%ecx
  800626:	c1 f9 1f             	sar    $0x1f,%ecx
  800629:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062c:	eb 16                	jmp    800644 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063c:	89 c1                	mov    %eax,%ecx
  80063e:	c1 f9 1f             	sar    $0x1f,%ecx
  800641:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800644:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800647:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800653:	79 74                	jns    8006c9 <vprintfmt+0x356>
				putch('-', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 2d                	push   $0x2d
  80065b:	ff d6                	call   *%esi
				num = -(long long) num;
  80065d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800660:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800663:	f7 d8                	neg    %eax
  800665:	83 d2 00             	adc    $0x0,%edx
  800668:	f7 da                	neg    %edx
  80066a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800672:	eb 55                	jmp    8006c9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 83 fc ff ff       	call   8002ff <getuint>
			base = 10;
  80067c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800681:	eb 46                	jmp    8006c9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 74 fc ff ff       	call   8002ff <getuint>
		        base = 8;
  80068b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800690:	eb 37                	jmp    8006c9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 30                	push   $0x30
  800698:	ff d6                	call   *%esi
			putch('x', putdat);
  80069a:	83 c4 08             	add    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	6a 78                	push   $0x78
  8006a0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ba:	eb 0d                	jmp    8006c9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bf:	e8 3b fc ff ff       	call   8002ff <getuint>
			base = 16;
  8006c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006d0:	57                   	push   %edi
  8006d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	50                   	push   %eax
  8006d7:	89 da                	mov    %ebx,%edx
  8006d9:	89 f0                	mov    %esi,%eax
  8006db:	e8 70 fb ff ff       	call   800250 <printnum>
			break;
  8006e0:	83 c4 20             	add    $0x20,%esp
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e6:	e9 ae fc ff ff       	jmp    800399 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	51                   	push   %ecx
  8006f0:	ff d6                	call   *%esi
			break;
  8006f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f8:	e9 9c fc ff ff       	jmp    800399 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 03                	jmp    80070d <vprintfmt+0x39a>
  80070a:	83 ef 01             	sub    $0x1,%edi
  80070d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800711:	75 f7                	jne    80070a <vprintfmt+0x397>
  800713:	e9 81 fc ff ff       	jmp    800399 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 18             	sub    $0x18,%esp
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800733:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 26                	je     800767 <vsnprintf+0x47>
  800741:	85 d2                	test   %edx,%edx
  800743:	7e 22                	jle    800767 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800745:	ff 75 14             	pushl  0x14(%ebp)
  800748:	ff 75 10             	pushl  0x10(%ebp)
  80074b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074e:	50                   	push   %eax
  80074f:	68 39 03 80 00       	push   $0x800339
  800754:	e8 1a fc ff ff       	call   800373 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800759:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	eb 05                	jmp    80076c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800767:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800774:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800777:	50                   	push   %eax
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	ff 75 08             	pushl  0x8(%ebp)
  800781:	e8 9a ff ff ff       	call   800720 <vsnprintf>
	va_end(ap);

	return rc;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	eb 03                	jmp    800798 <strlen+0x10>
		n++;
  800795:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079c:	75 f7                	jne    800795 <strlen+0xd>
		n++;
	return n;
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ae:	eb 03                	jmp    8007b3 <strnlen+0x13>
		n++;
  8007b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	39 c2                	cmp    %eax,%edx
  8007b5:	74 08                	je     8007bf <strnlen+0x1f>
  8007b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007bb:	75 f3                	jne    8007b0 <strnlen+0x10>
  8007bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	83 c1 01             	add    $0x1,%ecx
  8007d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007da:	84 db                	test   %bl,%bl
  8007dc:	75 ef                	jne    8007cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e8:	53                   	push   %ebx
  8007e9:	e8 9a ff ff ff       	call   800788 <strlen>
  8007ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	01 d8                	add    %ebx,%eax
  8007f6:	50                   	push   %eax
  8007f7:	e8 c5 ff ff ff       	call   8007c1 <strcpy>
	return dst;
}
  8007fc:	89 d8                	mov    %ebx,%eax
  8007fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	89 f3                	mov    %esi,%ebx
  800810:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	89 f2                	mov    %esi,%edx
  800815:	eb 0f                	jmp    800826 <strncpy+0x23>
		*dst++ = *src;
  800817:	83 c2 01             	add    $0x1,%edx
  80081a:	0f b6 01             	movzbl (%ecx),%eax
  80081d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800820:	80 39 01             	cmpb   $0x1,(%ecx)
  800823:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	39 da                	cmp    %ebx,%edx
  800828:	75 ed                	jne    800817 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	56                   	push   %esi
  800834:	53                   	push   %ebx
  800835:	8b 75 08             	mov    0x8(%ebp),%esi
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083b:	8b 55 10             	mov    0x10(%ebp),%edx
  80083e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	85 d2                	test   %edx,%edx
  800842:	74 21                	je     800865 <strlcpy+0x35>
  800844:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800848:	89 f2                	mov    %esi,%edx
  80084a:	eb 09                	jmp    800855 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084c:	83 c2 01             	add    $0x1,%edx
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800855:	39 c2                	cmp    %eax,%edx
  800857:	74 09                	je     800862 <strlcpy+0x32>
  800859:	0f b6 19             	movzbl (%ecx),%ebx
  80085c:	84 db                	test   %bl,%bl
  80085e:	75 ec                	jne    80084c <strlcpy+0x1c>
  800860:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800862:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800865:	29 f0                	sub    %esi,%eax
}
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	eb 06                	jmp    80087c <strcmp+0x11>
		p++, q++;
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087c:	0f b6 01             	movzbl (%ecx),%eax
  80087f:	84 c0                	test   %al,%al
  800881:	74 04                	je     800887 <strcmp+0x1c>
  800883:	3a 02                	cmp    (%edx),%al
  800885:	74 ef                	je     800876 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 c0             	movzbl %al,%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	89 c3                	mov    %eax,%ebx
  80089d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a0:	eb 06                	jmp    8008a8 <strncmp+0x17>
		n--, p++, q++;
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a8:	39 d8                	cmp    %ebx,%eax
  8008aa:	74 15                	je     8008c1 <strncmp+0x30>
  8008ac:	0f b6 08             	movzbl (%eax),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	74 04                	je     8008b7 <strncmp+0x26>
  8008b3:	3a 0a                	cmp    (%edx),%cl
  8008b5:	74 eb                	je     8008a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 00             	movzbl (%eax),%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
  8008bf:	eb 05                	jmp    8008c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d3:	eb 07                	jmp    8008dc <strchr+0x13>
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 0f                	je     8008e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	0f b6 10             	movzbl (%eax),%edx
  8008df:	84 d2                	test   %dl,%dl
  8008e1:	75 f2                	jne    8008d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f4:	eb 03                	jmp    8008f9 <strfind+0xf>
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 04                	je     800904 <strfind+0x1a>
  800900:	84 d2                	test   %dl,%dl
  800902:	75 f2                	jne    8008f6 <strfind+0xc>
			break;
	return (char *) s;
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800912:	85 c9                	test   %ecx,%ecx
  800914:	74 36                	je     80094c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800916:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091c:	75 28                	jne    800946 <memset+0x40>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 23                	jne    800946 <memset+0x40>
		c &= 0xFF;
  800923:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800927:	89 d3                	mov    %edx,%ebx
  800929:	c1 e3 08             	shl    $0x8,%ebx
  80092c:	89 d6                	mov    %edx,%esi
  80092e:	c1 e6 18             	shl    $0x18,%esi
  800931:	89 d0                	mov    %edx,%eax
  800933:	c1 e0 10             	shl    $0x10,%eax
  800936:	09 f0                	or     %esi,%eax
  800938:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80093a:	89 d8                	mov    %ebx,%eax
  80093c:	09 d0                	or     %edx,%eax
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	fc                   	cld    
  800942:	f3 ab                	rep stos %eax,%es:(%edi)
  800944:	eb 06                	jmp    80094c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	fc                   	cld    
  80094a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094c:	89 f8                	mov    %edi,%eax
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800961:	39 c6                	cmp    %eax,%esi
  800963:	73 35                	jae    80099a <memmove+0x47>
  800965:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800968:	39 d0                	cmp    %edx,%eax
  80096a:	73 2e                	jae    80099a <memmove+0x47>
		s += n;
		d += n;
  80096c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	89 d6                	mov    %edx,%esi
  800971:	09 fe                	or     %edi,%esi
  800973:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800979:	75 13                	jne    80098e <memmove+0x3b>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0e                	jne    80098e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800980:	83 ef 04             	sub    $0x4,%edi
  800983:	8d 72 fc             	lea    -0x4(%edx),%esi
  800986:	c1 e9 02             	shr    $0x2,%ecx
  800989:	fd                   	std    
  80098a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098c:	eb 09                	jmp    800997 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098e:	83 ef 01             	sub    $0x1,%edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 1d                	jmp    8009b7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	09 c2                	or     %eax,%edx
  80099e:	f6 c2 03             	test   $0x3,%dl
  8009a1:	75 0f                	jne    8009b2 <memmove+0x5f>
  8009a3:	f6 c1 03             	test   $0x3,%cl
  8009a6:	75 0a                	jne    8009b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 05                	jmp    8009b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009be:	ff 75 10             	pushl  0x10(%ebp)
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	ff 75 08             	pushl  0x8(%ebp)
  8009c7:	e8 87 ff ff ff       	call   800953 <memmove>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 c6                	mov    %eax,%esi
  8009db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	eb 1a                	jmp    8009fa <memcmp+0x2c>
		if (*s1 != *s2)
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	0f b6 1a             	movzbl (%edx),%ebx
  8009e6:	38 d9                	cmp    %bl,%cl
  8009e8:	74 0a                	je     8009f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ea:	0f b6 c1             	movzbl %cl,%eax
  8009ed:	0f b6 db             	movzbl %bl,%ebx
  8009f0:	29 d8                	sub    %ebx,%eax
  8009f2:	eb 0f                	jmp    800a03 <memcmp+0x35>
		s1++, s2++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fa:	39 f0                	cmp    %esi,%eax
  8009fc:	75 e2                	jne    8009e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0e:	89 c1                	mov    %eax,%ecx
  800a10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	eb 0a                	jmp    800a23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a19:	0f b6 10             	movzbl (%eax),%edx
  800a1c:	39 da                	cmp    %ebx,%edx
  800a1e:	74 07                	je     800a27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	39 c8                	cmp    %ecx,%eax
  800a25:	72 f2                	jb     800a19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a36:	eb 03                	jmp    800a3b <strtol+0x11>
		s++;
  800a38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3b:	0f b6 01             	movzbl (%ecx),%eax
  800a3e:	3c 20                	cmp    $0x20,%al
  800a40:	74 f6                	je     800a38 <strtol+0xe>
  800a42:	3c 09                	cmp    $0x9,%al
  800a44:	74 f2                	je     800a38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a46:	3c 2b                	cmp    $0x2b,%al
  800a48:	75 0a                	jne    800a54 <strtol+0x2a>
		s++;
  800a4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a52:	eb 11                	jmp    800a65 <strtol+0x3b>
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	75 08                	jne    800a65 <strtol+0x3b>
		s++, neg = 1;
  800a5d:	83 c1 01             	add    $0x1,%ecx
  800a60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6b:	75 15                	jne    800a82 <strtol+0x58>
  800a6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a70:	75 10                	jne    800a82 <strtol+0x58>
  800a72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a76:	75 7c                	jne    800af4 <strtol+0xca>
		s += 2, base = 16;
  800a78:	83 c1 02             	add    $0x2,%ecx
  800a7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a80:	eb 16                	jmp    800a98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	75 12                	jne    800a98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8e:	75 08                	jne    800a98 <strtol+0x6e>
		s++, base = 8;
  800a90:	83 c1 01             	add    $0x1,%ecx
  800a93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa0:	0f b6 11             	movzbl (%ecx),%edx
  800aa3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 09             	cmp    $0x9,%bl
  800aab:	77 08                	ja     800ab5 <strtol+0x8b>
			dig = *s - '0';
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 30             	sub    $0x30,%edx
  800ab3:	eb 22                	jmp    800ad7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 19             	cmp    $0x19,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 57             	sub    $0x57,%edx
  800ac5:	eb 10                	jmp    800ad7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 16                	ja     800ae7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ada:	7d 0b                	jge    800ae7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae5:	eb b9                	jmp    800aa0 <strtol+0x76>

	if (endptr)
  800ae7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aeb:	74 0d                	je     800afa <strtol+0xd0>
		*endptr = (char *) s;
  800aed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af0:	89 0e                	mov    %ecx,(%esi)
  800af2:	eb 06                	jmp    800afa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	85 db                	test   %ebx,%ebx
  800af6:	74 98                	je     800a90 <strtol+0x66>
  800af8:	eb 9e                	jmp    800a98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800afa:	89 c2                	mov    %eax,%edx
  800afc:	f7 da                	neg    %edx
  800afe:	85 ff                	test   %edi,%edi
  800b00:	0f 45 c2             	cmovne %edx,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	89 c6                	mov    %eax,%esi
  800b1f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	89 d1                	mov    %edx,%ecx
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	89 d7                	mov    %edx,%edi
  800b3c:	89 d6                	mov    %edx,%esi
  800b3e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b53:	b8 03 00 00 00       	mov    $0x3,%eax
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	89 cb                	mov    %ecx,%ebx
  800b5d:	89 cf                	mov    %ecx,%edi
  800b5f:	89 ce                	mov    %ecx,%esi
  800b61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b63:	85 c0                	test   %eax,%eax
  800b65:	7e 17                	jle    800b7e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	50                   	push   %eax
  800b6b:	6a 03                	push   $0x3
  800b6d:	68 9f 26 80 00       	push   $0x80269f
  800b72:	6a 23                	push   $0x23
  800b74:	68 bc 26 80 00       	push   $0x8026bc
  800b79:	e8 e5 f5 ff ff       	call   800163 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b91:	b8 02 00 00 00       	mov    $0x2,%eax
  800b96:	89 d1                	mov    %edx,%ecx
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	89 d7                	mov    %edx,%edi
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_yield>:

void
sys_yield(void)
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
  800bb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bcd:	be 00 00 00 00       	mov    $0x0,%esi
  800bd2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	89 f7                	mov    %esi,%edi
  800be2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 04                	push   $0x4
  800bee:	68 9f 26 80 00       	push   $0x80269f
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 bc 26 80 00       	push   $0x8026bc
  800bfa:	e8 64 f5 ff ff       	call   800163 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	b8 05 00 00 00       	mov    $0x5,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c21:	8b 75 18             	mov    0x18(%ebp),%esi
  800c24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 17                	jle    800c41 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 05                	push   $0x5
  800c30:	68 9f 26 80 00       	push   $0x80269f
  800c35:	6a 23                	push   $0x23
  800c37:	68 bc 26 80 00       	push   $0x8026bc
  800c3c:	e8 22 f5 ff ff       	call   800163 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 17                	jle    800c83 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 06                	push   $0x6
  800c72:	68 9f 26 80 00       	push   $0x80269f
  800c77:	6a 23                	push   $0x23
  800c79:	68 bc 26 80 00       	push   $0x8026bc
  800c7e:	e8 e0 f4 ff ff       	call   800163 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 17                	jle    800cc5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 08                	push   $0x8
  800cb4:	68 9f 26 80 00       	push   $0x80269f
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 bc 26 80 00       	push   $0x8026bc
  800cc0:	e8 9e f4 ff ff       	call   800163 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 17                	jle    800d07 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	50                   	push   %eax
  800cf4:	6a 09                	push   $0x9
  800cf6:	68 9f 26 80 00       	push   $0x80269f
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 bc 26 80 00       	push   $0x8026bc
  800d02:	e8 5c f4 ff ff       	call   800163 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 df                	mov    %ebx,%edi
  800d2a:	89 de                	mov    %ebx,%esi
  800d2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 17                	jle    800d49 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 0a                	push   $0xa
  800d38:	68 9f 26 80 00       	push   $0x80269f
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 bc 26 80 00       	push   $0x8026bc
  800d44:	e8 1a f4 ff ff       	call   800163 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	be 00 00 00 00       	mov    $0x0,%esi
  800d5c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	89 cb                	mov    %ecx,%ebx
  800d8c:	89 cf                	mov    %ecx,%edi
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7e 17                	jle    800dad <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	50                   	push   %eax
  800d9a:	6a 0d                	push   $0xd
  800d9c:	68 9f 26 80 00       	push   $0x80269f
  800da1:	6a 23                	push   $0x23
  800da3:	68 bc 26 80 00       	push   $0x8026bc
  800da8:	e8 b6 f3 ff ff       	call   800163 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	89 d3                	mov    %edx,%ebx
  800dc9:	89 d7                	mov    %edx,%edi
  800dcb:	89 d6                	mov    %edx,%esi
  800dcd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_net_xmit>:

int sys_net_xmit(void * addr, size_t length)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	89 df                	mov    %ebx,%edi
  800dec:	89 de                	mov    %ebx,%esi
  800dee:	cd 30                	int    $0x30
}

int sys_net_xmit(void * addr, size_t length)
{
	return (int) syscall(SYS_net_xmit, 0, (uint32_t)addr, (uint32_t)length, 0, 0, 0);
}
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	05 00 00 00 30       	add    $0x30000000,%eax
  800e00:	c1 e8 0c             	shr    $0xc,%eax
}
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e15:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e22:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e27:	89 c2                	mov    %eax,%edx
  800e29:	c1 ea 16             	shr    $0x16,%edx
  800e2c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e33:	f6 c2 01             	test   $0x1,%dl
  800e36:	74 11                	je     800e49 <fd_alloc+0x2d>
  800e38:	89 c2                	mov    %eax,%edx
  800e3a:	c1 ea 0c             	shr    $0xc,%edx
  800e3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e44:	f6 c2 01             	test   $0x1,%dl
  800e47:	75 09                	jne    800e52 <fd_alloc+0x36>
			*fd_store = fd;
  800e49:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e50:	eb 17                	jmp    800e69 <fd_alloc+0x4d>
  800e52:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e57:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e5c:	75 c9                	jne    800e27 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e5e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e64:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e71:	83 f8 1f             	cmp    $0x1f,%eax
  800e74:	77 36                	ja     800eac <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e76:	c1 e0 0c             	shl    $0xc,%eax
  800e79:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e7e:	89 c2                	mov    %eax,%edx
  800e80:	c1 ea 16             	shr    $0x16,%edx
  800e83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8a:	f6 c2 01             	test   $0x1,%dl
  800e8d:	74 24                	je     800eb3 <fd_lookup+0x48>
  800e8f:	89 c2                	mov    %eax,%edx
  800e91:	c1 ea 0c             	shr    $0xc,%edx
  800e94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e9b:	f6 c2 01             	test   $0x1,%dl
  800e9e:	74 1a                	je     800eba <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea3:	89 02                	mov    %eax,(%edx)
	return 0;
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	eb 13                	jmp    800ebf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb1:	eb 0c                	jmp    800ebf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb8:	eb 05                	jmp    800ebf <fd_lookup+0x54>
  800eba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eca:	ba 4c 27 80 00       	mov    $0x80274c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ecf:	eb 13                	jmp    800ee4 <dev_lookup+0x23>
  800ed1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ed4:	39 08                	cmp    %ecx,(%eax)
  800ed6:	75 0c                	jne    800ee4 <dev_lookup+0x23>
			*dev = devtab[i];
  800ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	eb 2e                	jmp    800f12 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee4:	8b 02                	mov    (%edx),%eax
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	75 e7                	jne    800ed1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eea:	a1 08 40 80 00       	mov    0x804008,%eax
  800eef:	8b 40 48             	mov    0x48(%eax),%eax
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	51                   	push   %ecx
  800ef6:	50                   	push   %eax
  800ef7:	68 cc 26 80 00       	push   $0x8026cc
  800efc:	e8 3b f3 ff ff       	call   80023c <cprintf>
	*dev = 0;
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 10             	sub    $0x10,%esp
  800f1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f25:	50                   	push   %eax
  800f26:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f2c:	c1 e8 0c             	shr    $0xc,%eax
  800f2f:	50                   	push   %eax
  800f30:	e8 36 ff ff ff       	call   800e6b <fd_lookup>
  800f35:	83 c4 08             	add    $0x8,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	78 05                	js     800f41 <fd_close+0x2d>
	    || fd != fd2)
  800f3c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3f:	74 0c                	je     800f4d <fd_close+0x39>
		return (must_exist ? r : 0);
  800f41:	84 db                	test   %bl,%bl
  800f43:	ba 00 00 00 00       	mov    $0x0,%edx
  800f48:	0f 44 c2             	cmove  %edx,%eax
  800f4b:	eb 41                	jmp    800f8e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f4d:	83 ec 08             	sub    $0x8,%esp
  800f50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f53:	50                   	push   %eax
  800f54:	ff 36                	pushl  (%esi)
  800f56:	e8 66 ff ff ff       	call   800ec1 <dev_lookup>
  800f5b:	89 c3                	mov    %eax,%ebx
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 1a                	js     800f7e <fd_close+0x6a>
		if (dev->dev_close)
  800f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f67:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	74 0b                	je     800f7e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f73:	83 ec 0c             	sub    $0xc,%esp
  800f76:	56                   	push   %esi
  800f77:	ff d0                	call   *%eax
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f7e:	83 ec 08             	sub    $0x8,%esp
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 c0 fc ff ff       	call   800c49 <sys_page_unmap>
	return r;
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	89 d8                	mov    %ebx,%eax
}
  800f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	ff 75 08             	pushl  0x8(%ebp)
  800fa2:	e8 c4 fe ff ff       	call   800e6b <fd_lookup>
  800fa7:	83 c4 08             	add    $0x8,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 10                	js     800fbe <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	6a 01                	push   $0x1
  800fb3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb6:	e8 59 ff ff ff       	call   800f14 <fd_close>
  800fbb:	83 c4 10             	add    $0x10,%esp
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <close_all>:

void
close_all(void)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	53                   	push   %ebx
  800fd0:	e8 c0 ff ff ff       	call   800f95 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd5:	83 c3 01             	add    $0x1,%ebx
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	83 fb 20             	cmp    $0x20,%ebx
  800fde:	75 ec                	jne    800fcc <close_all+0xc>
		close(i);
}
  800fe0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	83 ec 2c             	sub    $0x2c,%esp
  800fee:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	ff 75 08             	pushl  0x8(%ebp)
  800ff8:	e8 6e fe ff ff       	call   800e6b <fd_lookup>
  800ffd:	83 c4 08             	add    $0x8,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	0f 88 c1 00 00 00    	js     8010c9 <dup+0xe4>
		return r;
	close(newfdnum);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	56                   	push   %esi
  80100c:	e8 84 ff ff ff       	call   800f95 <close>

	newfd = INDEX2FD(newfdnum);
  801011:	89 f3                	mov    %esi,%ebx
  801013:	c1 e3 0c             	shl    $0xc,%ebx
  801016:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80101c:	83 c4 04             	add    $0x4,%esp
  80101f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801022:	e8 de fd ff ff       	call   800e05 <fd2data>
  801027:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801029:	89 1c 24             	mov    %ebx,(%esp)
  80102c:	e8 d4 fd ff ff       	call   800e05 <fd2data>
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801037:	89 f8                	mov    %edi,%eax
  801039:	c1 e8 16             	shr    $0x16,%eax
  80103c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801043:	a8 01                	test   $0x1,%al
  801045:	74 37                	je     80107e <dup+0x99>
  801047:	89 f8                	mov    %edi,%eax
  801049:	c1 e8 0c             	shr    $0xc,%eax
  80104c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801053:	f6 c2 01             	test   $0x1,%dl
  801056:	74 26                	je     80107e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801058:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	25 07 0e 00 00       	and    $0xe07,%eax
  801067:	50                   	push   %eax
  801068:	ff 75 d4             	pushl  -0x2c(%ebp)
  80106b:	6a 00                	push   $0x0
  80106d:	57                   	push   %edi
  80106e:	6a 00                	push   $0x0
  801070:	e8 92 fb ff ff       	call   800c07 <sys_page_map>
  801075:	89 c7                	mov    %eax,%edi
  801077:	83 c4 20             	add    $0x20,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 2e                	js     8010ac <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801081:	89 d0                	mov    %edx,%eax
  801083:	c1 e8 0c             	shr    $0xc,%eax
  801086:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	25 07 0e 00 00       	and    $0xe07,%eax
  801095:	50                   	push   %eax
  801096:	53                   	push   %ebx
  801097:	6a 00                	push   $0x0
  801099:	52                   	push   %edx
  80109a:	6a 00                	push   $0x0
  80109c:	e8 66 fb ff ff       	call   800c07 <sys_page_map>
  8010a1:	89 c7                	mov    %eax,%edi
  8010a3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a8:	85 ff                	test   %edi,%edi
  8010aa:	79 1d                	jns    8010c9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ac:	83 ec 08             	sub    $0x8,%esp
  8010af:	53                   	push   %ebx
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 92 fb ff ff       	call   800c49 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b7:	83 c4 08             	add    $0x8,%esp
  8010ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010bd:	6a 00                	push   $0x0
  8010bf:	e8 85 fb ff ff       	call   800c49 <sys_page_unmap>
	return r;
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	89 f8                	mov    %edi,%eax
}
  8010c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 14             	sub    $0x14,%esp
  8010d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010de:	50                   	push   %eax
  8010df:	53                   	push   %ebx
  8010e0:	e8 86 fd ff ff       	call   800e6b <fd_lookup>
  8010e5:	83 c4 08             	add    $0x8,%esp
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 6d                	js     80115b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f8:	ff 30                	pushl  (%eax)
  8010fa:	e8 c2 fd ff ff       	call   800ec1 <dev_lookup>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	78 4c                	js     801152 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801106:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801109:	8b 42 08             	mov    0x8(%edx),%eax
  80110c:	83 e0 03             	and    $0x3,%eax
  80110f:	83 f8 01             	cmp    $0x1,%eax
  801112:	75 21                	jne    801135 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801114:	a1 08 40 80 00       	mov    0x804008,%eax
  801119:	8b 40 48             	mov    0x48(%eax),%eax
  80111c:	83 ec 04             	sub    $0x4,%esp
  80111f:	53                   	push   %ebx
  801120:	50                   	push   %eax
  801121:	68 10 27 80 00       	push   $0x802710
  801126:	e8 11 f1 ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801133:	eb 26                	jmp    80115b <read+0x8a>
	}
	if (!dev->dev_read)
  801135:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801138:	8b 40 08             	mov    0x8(%eax),%eax
  80113b:	85 c0                	test   %eax,%eax
  80113d:	74 17                	je     801156 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113f:	83 ec 04             	sub    $0x4,%esp
  801142:	ff 75 10             	pushl  0x10(%ebp)
  801145:	ff 75 0c             	pushl  0xc(%ebp)
  801148:	52                   	push   %edx
  801149:	ff d0                	call   *%eax
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	eb 09                	jmp    80115b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801152:	89 c2                	mov    %eax,%edx
  801154:	eb 05                	jmp    80115b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801156:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80115b:	89 d0                	mov    %edx,%eax
  80115d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	53                   	push   %ebx
  801168:	83 ec 0c             	sub    $0xc,%esp
  80116b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801171:	bb 00 00 00 00       	mov    $0x0,%ebx
  801176:	eb 21                	jmp    801199 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	89 f0                	mov    %esi,%eax
  80117d:	29 d8                	sub    %ebx,%eax
  80117f:	50                   	push   %eax
  801180:	89 d8                	mov    %ebx,%eax
  801182:	03 45 0c             	add    0xc(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	57                   	push   %edi
  801187:	e8 45 ff ff ff       	call   8010d1 <read>
		if (m < 0)
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 10                	js     8011a3 <readn+0x41>
			return m;
		if (m == 0)
  801193:	85 c0                	test   %eax,%eax
  801195:	74 0a                	je     8011a1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801197:	01 c3                	add    %eax,%ebx
  801199:	39 f3                	cmp    %esi,%ebx
  80119b:	72 db                	jb     801178 <readn+0x16>
  80119d:	89 d8                	mov    %ebx,%eax
  80119f:	eb 02                	jmp    8011a3 <readn+0x41>
  8011a1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 14             	sub    $0x14,%esp
  8011b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b8:	50                   	push   %eax
  8011b9:	53                   	push   %ebx
  8011ba:	e8 ac fc ff ff       	call   800e6b <fd_lookup>
  8011bf:	83 c4 08             	add    $0x8,%esp
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 68                	js     801230 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d2:	ff 30                	pushl  (%eax)
  8011d4:	e8 e8 fc ff ff       	call   800ec1 <dev_lookup>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 47                	js     801227 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e7:	75 21                	jne    80120a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	53                   	push   %ebx
  8011f5:	50                   	push   %eax
  8011f6:	68 2c 27 80 00       	push   $0x80272c
  8011fb:	e8 3c f0 ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801208:	eb 26                	jmp    801230 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120d:	8b 52 0c             	mov    0xc(%edx),%edx
  801210:	85 d2                	test   %edx,%edx
  801212:	74 17                	je     80122b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	ff 75 10             	pushl  0x10(%ebp)
  80121a:	ff 75 0c             	pushl  0xc(%ebp)
  80121d:	50                   	push   %eax
  80121e:	ff d2                	call   *%edx
  801220:	89 c2                	mov    %eax,%edx
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	eb 09                	jmp    801230 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801227:	89 c2                	mov    %eax,%edx
  801229:	eb 05                	jmp    801230 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80122b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801230:	89 d0                	mov    %edx,%eax
  801232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <seek>:

int
seek(int fdnum, off_t offset)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	ff 75 08             	pushl  0x8(%ebp)
  801244:	e8 22 fc ff ff       	call   800e6b <fd_lookup>
  801249:	83 c4 08             	add    $0x8,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 0e                	js     80125e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801250:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801253:	8b 55 0c             	mov    0xc(%ebp),%edx
  801256:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	53                   	push   %ebx
  801264:	83 ec 14             	sub    $0x14,%esp
  801267:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	53                   	push   %ebx
  80126f:	e8 f7 fb ff ff       	call   800e6b <fd_lookup>
  801274:	83 c4 08             	add    $0x8,%esp
  801277:	89 c2                	mov    %eax,%edx
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 65                	js     8012e2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801287:	ff 30                	pushl  (%eax)
  801289:	e8 33 fc ff ff       	call   800ec1 <dev_lookup>
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	78 44                	js     8012d9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801295:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801298:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129c:	75 21                	jne    8012bf <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80129e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a3:	8b 40 48             	mov    0x48(%eax),%eax
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	53                   	push   %ebx
  8012aa:	50                   	push   %eax
  8012ab:	68 ec 26 80 00       	push   $0x8026ec
  8012b0:	e8 87 ef ff ff       	call   80023c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012bd:	eb 23                	jmp    8012e2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c2:	8b 52 18             	mov    0x18(%edx),%edx
  8012c5:	85 d2                	test   %edx,%edx
  8012c7:	74 14                	je     8012dd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	ff 75 0c             	pushl  0xc(%ebp)
  8012cf:	50                   	push   %eax
  8012d0:	ff d2                	call   *%edx
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	eb 09                	jmp    8012e2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	eb 05                	jmp    8012e2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e2:	89 d0                	mov    %edx,%eax
  8012e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 14             	sub    $0x14,%esp
  8012f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 6c fb ff ff       	call   800e6b <fd_lookup>
  8012ff:	83 c4 08             	add    $0x8,%esp
  801302:	89 c2                	mov    %eax,%edx
  801304:	85 c0                	test   %eax,%eax
  801306:	78 58                	js     801360 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801312:	ff 30                	pushl  (%eax)
  801314:	e8 a8 fb ff ff       	call   800ec1 <dev_lookup>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 37                	js     801357 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801320:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801323:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801327:	74 32                	je     80135b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801329:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80132c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801333:	00 00 00 
	stat->st_isdir = 0;
  801336:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80133d:	00 00 00 
	stat->st_dev = dev;
  801340:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	53                   	push   %ebx
  80134a:	ff 75 f0             	pushl  -0x10(%ebp)
  80134d:	ff 50 14             	call   *0x14(%eax)
  801350:	89 c2                	mov    %eax,%edx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	eb 09                	jmp    801360 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801357:	89 c2                	mov    %eax,%edx
  801359:	eb 05                	jmp    801360 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80135b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801360:	89 d0                	mov    %edx,%eax
  801362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	6a 00                	push   $0x0
  801371:	ff 75 08             	pushl  0x8(%ebp)
  801374:	e8 e7 01 00 00       	call   801560 <open>
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 1b                	js     80139d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	ff 75 0c             	pushl  0xc(%ebp)
  801388:	50                   	push   %eax
  801389:	e8 5b ff ff ff       	call   8012e9 <fstat>
  80138e:	89 c6                	mov    %eax,%esi
	close(fd);
  801390:	89 1c 24             	mov    %ebx,(%esp)
  801393:	e8 fd fb ff ff       	call   800f95 <close>
	return r;
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	89 f0                	mov    %esi,%eax
}
  80139d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	89 c6                	mov    %eax,%esi
  8013ab:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013b4:	75 12                	jne    8013c8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	6a 01                	push   $0x1
  8013bb:	e8 4b 0c 00 00       	call   80200b <ipc_find_env>
  8013c0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013c5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c8:	6a 07                	push   $0x7
  8013ca:	68 00 50 80 00       	push   $0x805000
  8013cf:	56                   	push   %esi
  8013d0:	ff 35 00 40 80 00    	pushl  0x804000
  8013d6:	e8 dc 0b 00 00       	call   801fb7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013db:	83 c4 0c             	add    $0xc,%esp
  8013de:	6a 00                	push   $0x0
  8013e0:	53                   	push   %ebx
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 62 0b 00 00       	call   801f4a <ipc_recv>
}
  8013e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801400:	8b 45 0c             	mov    0xc(%ebp),%eax
  801403:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801408:	ba 00 00 00 00       	mov    $0x0,%edx
  80140d:	b8 02 00 00 00       	mov    $0x2,%eax
  801412:	e8 8d ff ff ff       	call   8013a4 <fsipc>
}
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	8b 40 0c             	mov    0xc(%eax),%eax
  801425:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80142a:	ba 00 00 00 00       	mov    $0x0,%edx
  80142f:	b8 06 00 00 00       	mov    $0x6,%eax
  801434:	e8 6b ff ff ff       	call   8013a4 <fsipc>
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	53                   	push   %ebx
  80143f:	83 ec 04             	sub    $0x4,%esp
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	8b 40 0c             	mov    0xc(%eax),%eax
  80144b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801450:	ba 00 00 00 00       	mov    $0x0,%edx
  801455:	b8 05 00 00 00       	mov    $0x5,%eax
  80145a:	e8 45 ff ff ff       	call   8013a4 <fsipc>
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 2c                	js     80148f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	68 00 50 80 00       	push   $0x805000
  80146b:	53                   	push   %ebx
  80146c:	e8 50 f3 ff ff       	call   8007c1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801471:	a1 80 50 80 00       	mov    0x805080,%eax
  801476:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80147c:	a1 84 50 80 00       	mov    0x805084,%eax
  801481:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	uint32_t max_size = PGSIZE - (sizeof(int) + sizeof(size_t));

	n = n > max_size ? max_size : n;
  80149e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014a3:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014a8:	0f 46 d8             	cmovbe %eax,%ebx
	
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014ab:	53                   	push   %ebx
  8014ac:	ff 75 0c             	pushl  0xc(%ebp)
  8014af:	68 08 50 80 00       	push   $0x805008
  8014b4:	e8 9a f4 ff ff       	call   800953 <memmove>
	
 	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bf:	a3 00 50 80 00       	mov    %eax,0x805000
 	fsipcbuf.write.req_n = n;
  8014c4:	89 1d 04 50 80 00    	mov    %ebx,0x805004

 	return fsipc(FSREQ_WRITE, NULL);
  8014ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d4:	e8 cb fe ff ff       	call   8013a4 <fsipc>
	//panic("devfile_write not implemented");
}
  8014d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014dc:	c9                   	leave  
  8014dd:	c3                   	ret    

008014de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801501:	e8 9e fe ff ff       	call   8013a4 <fsipc>
  801506:	89 c3                	mov    %eax,%ebx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 4b                	js     801557 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80150c:	39 c6                	cmp    %eax,%esi
  80150e:	73 16                	jae    801526 <devfile_read+0x48>
  801510:	68 60 27 80 00       	push   $0x802760
  801515:	68 67 27 80 00       	push   $0x802767
  80151a:	6a 7c                	push   $0x7c
  80151c:	68 7c 27 80 00       	push   $0x80277c
  801521:	e8 3d ec ff ff       	call   800163 <_panic>
	assert(r <= PGSIZE);
  801526:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80152b:	7e 16                	jle    801543 <devfile_read+0x65>
  80152d:	68 87 27 80 00       	push   $0x802787
  801532:	68 67 27 80 00       	push   $0x802767
  801537:	6a 7d                	push   $0x7d
  801539:	68 7c 27 80 00       	push   $0x80277c
  80153e:	e8 20 ec ff ff       	call   800163 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	50                   	push   %eax
  801547:	68 00 50 80 00       	push   $0x805000
  80154c:	ff 75 0c             	pushl  0xc(%ebp)
  80154f:	e8 ff f3 ff ff       	call   800953 <memmove>
	return r;
  801554:	83 c4 10             	add    $0x10,%esp
}
  801557:	89 d8                	mov    %ebx,%eax
  801559:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    

00801560 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	53                   	push   %ebx
  801564:	83 ec 20             	sub    $0x20,%esp
  801567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80156a:	53                   	push   %ebx
  80156b:	e8 18 f2 ff ff       	call   800788 <strlen>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801578:	7f 67                	jg     8015e1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	e8 96 f8 ff ff       	call   800e1c <fd_alloc>
  801586:	83 c4 10             	add    $0x10,%esp
		return r;
  801589:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 57                	js     8015e6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	53                   	push   %ebx
  801593:	68 00 50 80 00       	push   $0x805000
  801598:	e8 24 f2 ff ff       	call   8007c1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80159d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ad:	e8 f2 fd ff ff       	call   8013a4 <fsipc>
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	79 14                	jns    8015cf <open+0x6f>
		fd_close(fd, 0);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	6a 00                	push   $0x0
  8015c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c3:	e8 4c f9 ff ff       	call   800f14 <fd_close>
		return r;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	89 da                	mov    %ebx,%edx
  8015cd:	eb 17                	jmp    8015e6 <open+0x86>
	}

	return fd2num(fd);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d5:	e8 1b f8 ff ff       	call   800df5 <fd2num>
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	eb 05                	jmp    8015e6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015e1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015e6:	89 d0                	mov    %edx,%eax
  8015e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015fd:	e8 a2 fd ff ff       	call   8013a4 <fsipc>
}
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80160a:	68 93 27 80 00       	push   $0x802793
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	e8 aa f1 ff ff       	call   8007c1 <strcpy>
	return 0;
}
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	53                   	push   %ebx
  801622:	83 ec 10             	sub    $0x10,%esp
  801625:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801628:	53                   	push   %ebx
  801629:	e8 16 0a 00 00       	call   802044 <pageref>
  80162e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801631:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801636:	83 f8 01             	cmp    $0x1,%eax
  801639:	75 10                	jne    80164b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 73 0c             	pushl  0xc(%ebx)
  801641:	e8 c0 02 00 00       	call   801906 <nsipc_close>
  801646:	89 c2                	mov    %eax,%edx
  801648:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80164b:	89 d0                	mov    %edx,%eax
  80164d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801658:	6a 00                	push   $0x0
  80165a:	ff 75 10             	pushl  0x10(%ebp)
  80165d:	ff 75 0c             	pushl  0xc(%ebp)
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	ff 70 0c             	pushl  0xc(%eax)
  801666:	e8 78 03 00 00       	call   8019e3 <nsipc_send>
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801673:	6a 00                	push   $0x0
  801675:	ff 75 10             	pushl  0x10(%ebp)
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	ff 70 0c             	pushl  0xc(%eax)
  801681:	e8 f1 02 00 00       	call   801977 <nsipc_recv>
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80168e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801691:	52                   	push   %edx
  801692:	50                   	push   %eax
  801693:	e8 d3 f7 ff ff       	call   800e6b <fd_lookup>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 17                	js     8016b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80169f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a2:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016a8:	39 08                	cmp    %ecx,(%eax)
  8016aa:	75 05                	jne    8016b1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8016af:	eb 05                	jmp    8016b6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	83 ec 1c             	sub    $0x1c,%esp
  8016c0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c5:	50                   	push   %eax
  8016c6:	e8 51 f7 ff ff       	call   800e1c <fd_alloc>
  8016cb:	89 c3                	mov    %eax,%ebx
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 1b                	js     8016ef <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	68 07 04 00 00       	push   $0x407
  8016dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016df:	6a 00                	push   $0x0
  8016e1:	e8 de f4 ff ff       	call   800bc4 <sys_page_alloc>
  8016e6:	89 c3                	mov    %eax,%ebx
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	79 10                	jns    8016ff <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	56                   	push   %esi
  8016f3:	e8 0e 02 00 00       	call   801906 <nsipc_close>
		return r;
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	eb 24                	jmp    801723 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80170a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801714:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801717:	83 ec 0c             	sub    $0xc,%esp
  80171a:	50                   	push   %eax
  80171b:	e8 d5 f6 ff ff       	call   800df5 <fd2num>
  801720:	83 c4 10             	add    $0x10,%esp
}
  801723:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	e8 50 ff ff ff       	call   801688 <fd2sockid>
		return r;
  801738:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 1f                	js     80175d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	ff 75 10             	pushl  0x10(%ebp)
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	50                   	push   %eax
  801748:	e8 12 01 00 00       	call   80185f <nsipc_accept>
  80174d:	83 c4 10             	add    $0x10,%esp
		return r;
  801750:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801752:	85 c0                	test   %eax,%eax
  801754:	78 07                	js     80175d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801756:	e8 5d ff ff ff       	call   8016b8 <alloc_sockfd>
  80175b:	89 c1                	mov    %eax,%ecx
}
  80175d:	89 c8                	mov    %ecx,%eax
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	e8 19 ff ff ff       	call   801688 <fd2sockid>
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 12                	js     801785 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801773:	83 ec 04             	sub    $0x4,%esp
  801776:	ff 75 10             	pushl  0x10(%ebp)
  801779:	ff 75 0c             	pushl  0xc(%ebp)
  80177c:	50                   	push   %eax
  80177d:	e8 2d 01 00 00       	call   8018af <nsipc_bind>
  801782:	83 c4 10             	add    $0x10,%esp
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <shutdown>:

int
shutdown(int s, int how)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	e8 f3 fe ff ff       	call   801688 <fd2sockid>
  801795:	85 c0                	test   %eax,%eax
  801797:	78 0f                	js     8017a8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	50                   	push   %eax
  8017a0:	e8 3f 01 00 00       	call   8018e4 <nsipc_shutdown>
  8017a5:	83 c4 10             	add    $0x10,%esp
}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	e8 d0 fe ff ff       	call   801688 <fd2sockid>
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 12                	js     8017ce <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017bc:	83 ec 04             	sub    $0x4,%esp
  8017bf:	ff 75 10             	pushl  0x10(%ebp)
  8017c2:	ff 75 0c             	pushl  0xc(%ebp)
  8017c5:	50                   	push   %eax
  8017c6:	e8 55 01 00 00       	call   801920 <nsipc_connect>
  8017cb:	83 c4 10             	add    $0x10,%esp
}
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <listen>:

int
listen(int s, int backlog)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	e8 aa fe ff ff       	call   801688 <fd2sockid>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 0f                	js     8017f1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	50                   	push   %eax
  8017e9:	e8 67 01 00 00       	call   801955 <nsipc_listen>
  8017ee:	83 c4 10             	add    $0x10,%esp
}
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017f9:	ff 75 10             	pushl  0x10(%ebp)
  8017fc:	ff 75 0c             	pushl  0xc(%ebp)
  8017ff:	ff 75 08             	pushl  0x8(%ebp)
  801802:	e8 3a 02 00 00       	call   801a41 <nsipc_socket>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 05                	js     801813 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80180e:	e8 a5 fe ff ff       	call   8016b8 <alloc_sockfd>
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	53                   	push   %ebx
  801819:	83 ec 04             	sub    $0x4,%esp
  80181c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80181e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801825:	75 12                	jne    801839 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	6a 02                	push   $0x2
  80182c:	e8 da 07 00 00       	call   80200b <ipc_find_env>
  801831:	a3 04 40 80 00       	mov    %eax,0x804004
  801836:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801839:	6a 07                	push   $0x7
  80183b:	68 00 60 80 00       	push   $0x806000
  801840:	53                   	push   %ebx
  801841:	ff 35 04 40 80 00    	pushl  0x804004
  801847:	e8 6b 07 00 00       	call   801fb7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80184c:	83 c4 0c             	add    $0xc,%esp
  80184f:	6a 00                	push   $0x0
  801851:	6a 00                	push   $0x0
  801853:	6a 00                	push   $0x0
  801855:	e8 f0 06 00 00       	call   801f4a <ipc_recv>
}
  80185a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80186f:	8b 06                	mov    (%esi),%eax
  801871:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801876:	b8 01 00 00 00       	mov    $0x1,%eax
  80187b:	e8 95 ff ff ff       	call   801815 <nsipc>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	85 c0                	test   %eax,%eax
  801884:	78 20                	js     8018a6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	ff 35 10 60 80 00    	pushl  0x806010
  80188f:	68 00 60 80 00       	push   $0x806000
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	e8 b7 f0 ff ff       	call   800953 <memmove>
		*addrlen = ret->ret_addrlen;
  80189c:	a1 10 60 80 00       	mov    0x806010,%eax
  8018a1:	89 06                	mov    %eax,(%esi)
  8018a3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018a6:	89 d8                	mov    %ebx,%eax
  8018a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5e                   	pop    %esi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018c1:	53                   	push   %ebx
  8018c2:	ff 75 0c             	pushl  0xc(%ebp)
  8018c5:	68 04 60 80 00       	push   $0x806004
  8018ca:	e8 84 f0 ff ff       	call   800953 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018cf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018da:	e8 36 ff ff ff       	call   801815 <nsipc>
}
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ff:	e8 11 ff ff ff       	call   801815 <nsipc>
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <nsipc_close>:

int
nsipc_close(int s)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801914:	b8 04 00 00 00       	mov    $0x4,%eax
  801919:	e8 f7 fe ff ff       	call   801815 <nsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801932:	53                   	push   %ebx
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	68 04 60 80 00       	push   $0x806004
  80193b:	e8 13 f0 ff ff       	call   800953 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801940:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801946:	b8 05 00 00 00       	mov    $0x5,%eax
  80194b:	e8 c5 fe ff ff       	call   801815 <nsipc>
}
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801963:	8b 45 0c             	mov    0xc(%ebp),%eax
  801966:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80196b:	b8 06 00 00 00       	mov    $0x6,%eax
  801970:	e8 a0 fe ff ff       	call   801815 <nsipc>
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	56                   	push   %esi
  80197b:	53                   	push   %ebx
  80197c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801987:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801995:	b8 07 00 00 00       	mov    $0x7,%eax
  80199a:	e8 76 fe ff ff       	call   801815 <nsipc>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 35                	js     8019da <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019a5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019aa:	7f 04                	jg     8019b0 <nsipc_recv+0x39>
  8019ac:	39 c6                	cmp    %eax,%esi
  8019ae:	7d 16                	jge    8019c6 <nsipc_recv+0x4f>
  8019b0:	68 9f 27 80 00       	push   $0x80279f
  8019b5:	68 67 27 80 00       	push   $0x802767
  8019ba:	6a 62                	push   $0x62
  8019bc:	68 b4 27 80 00       	push   $0x8027b4
  8019c1:	e8 9d e7 ff ff       	call   800163 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019c6:	83 ec 04             	sub    $0x4,%esp
  8019c9:	50                   	push   %eax
  8019ca:	68 00 60 80 00       	push   $0x806000
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	e8 7c ef ff ff       	call   800953 <memmove>
  8019d7:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019da:	89 d8                	mov    %ebx,%eax
  8019dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5d                   	pop    %ebp
  8019e2:	c3                   	ret    

008019e3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019f5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019fb:	7e 16                	jle    801a13 <nsipc_send+0x30>
  8019fd:	68 c0 27 80 00       	push   $0x8027c0
  801a02:	68 67 27 80 00       	push   $0x802767
  801a07:	6a 6d                	push   $0x6d
  801a09:	68 b4 27 80 00       	push   $0x8027b4
  801a0e:	e8 50 e7 ff ff       	call   800163 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a13:	83 ec 04             	sub    $0x4,%esp
  801a16:	53                   	push   %ebx
  801a17:	ff 75 0c             	pushl  0xc(%ebp)
  801a1a:	68 0c 60 80 00       	push   $0x80600c
  801a1f:	e8 2f ef ff ff       	call   800953 <memmove>
	nsipcbuf.send.req_size = size;
  801a24:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a32:	b8 08 00 00 00       	mov    $0x8,%eax
  801a37:	e8 d9 fd ff ff       	call   801815 <nsipc>
}
  801a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a52:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a57:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a5f:	b8 09 00 00 00       	mov    $0x9,%eax
  801a64:	e8 ac fd ff ff       	call   801815 <nsipc>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	ff 75 08             	pushl  0x8(%ebp)
  801a79:	e8 87 f3 ff ff       	call   800e05 <fd2data>
  801a7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a80:	83 c4 08             	add    $0x8,%esp
  801a83:	68 cc 27 80 00       	push   $0x8027cc
  801a88:	53                   	push   %ebx
  801a89:	e8 33 ed ff ff       	call   8007c1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a8e:	8b 46 04             	mov    0x4(%esi),%eax
  801a91:	2b 06                	sub    (%esi),%eax
  801a93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a99:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa0:	00 00 00 
	stat->st_dev = &devpipe;
  801aa3:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801aaa:	30 80 00 
	return 0;
}
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac3:	53                   	push   %ebx
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 7e f1 ff ff       	call   800c49 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801acb:	89 1c 24             	mov    %ebx,(%esp)
  801ace:	e8 32 f3 ff ff       	call   800e05 <fd2data>
  801ad3:	83 c4 08             	add    $0x8,%esp
  801ad6:	50                   	push   %eax
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 6b f1 ff ff       	call   800c49 <sys_page_unmap>
}
  801ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 1c             	sub    $0x1c,%esp
  801aec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aef:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af1:	a1 08 40 80 00       	mov    0x804008,%eax
  801af6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	ff 75 e0             	pushl  -0x20(%ebp)
  801aff:	e8 40 05 00 00       	call   802044 <pageref>
  801b04:	89 c3                	mov    %eax,%ebx
  801b06:	89 3c 24             	mov    %edi,(%esp)
  801b09:	e8 36 05 00 00       	call   802044 <pageref>
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	39 c3                	cmp    %eax,%ebx
  801b13:	0f 94 c1             	sete   %cl
  801b16:	0f b6 c9             	movzbl %cl,%ecx
  801b19:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b1c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b22:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b25:	39 ce                	cmp    %ecx,%esi
  801b27:	74 1b                	je     801b44 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b29:	39 c3                	cmp    %eax,%ebx
  801b2b:	75 c4                	jne    801af1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b2d:	8b 42 58             	mov    0x58(%edx),%eax
  801b30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b33:	50                   	push   %eax
  801b34:	56                   	push   %esi
  801b35:	68 d3 27 80 00       	push   $0x8027d3
  801b3a:	e8 fd e6 ff ff       	call   80023c <cprintf>
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	eb ad                	jmp    801af1 <_pipeisclosed+0xe>
	}
}
  801b44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4a:	5b                   	pop    %ebx
  801b4b:	5e                   	pop    %esi
  801b4c:	5f                   	pop    %edi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	57                   	push   %edi
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	83 ec 28             	sub    $0x28,%esp
  801b58:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b5b:	56                   	push   %esi
  801b5c:	e8 a4 f2 ff ff       	call   800e05 <fd2data>
  801b61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	bf 00 00 00 00       	mov    $0x0,%edi
  801b6b:	eb 4b                	jmp    801bb8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b6d:	89 da                	mov    %ebx,%edx
  801b6f:	89 f0                	mov    %esi,%eax
  801b71:	e8 6d ff ff ff       	call   801ae3 <_pipeisclosed>
  801b76:	85 c0                	test   %eax,%eax
  801b78:	75 48                	jne    801bc2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b7a:	e8 26 f0 ff ff       	call   800ba5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b82:	8b 0b                	mov    (%ebx),%ecx
  801b84:	8d 51 20             	lea    0x20(%ecx),%edx
  801b87:	39 d0                	cmp    %edx,%eax
  801b89:	73 e2                	jae    801b6d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b95:	89 c2                	mov    %eax,%edx
  801b97:	c1 fa 1f             	sar    $0x1f,%edx
  801b9a:	89 d1                	mov    %edx,%ecx
  801b9c:	c1 e9 1b             	shr    $0x1b,%ecx
  801b9f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba2:	83 e2 1f             	and    $0x1f,%edx
  801ba5:	29 ca                	sub    %ecx,%edx
  801ba7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801baf:	83 c0 01             	add    $0x1,%eax
  801bb2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb5:	83 c7 01             	add    $0x1,%edi
  801bb8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bbb:	75 c2                	jne    801b7f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc0:	eb 05                	jmp    801bc7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	57                   	push   %edi
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 18             	sub    $0x18,%esp
  801bd8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bdb:	57                   	push   %edi
  801bdc:	e8 24 f2 ff ff       	call   800e05 <fd2data>
  801be1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801beb:	eb 3d                	jmp    801c2a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bed:	85 db                	test   %ebx,%ebx
  801bef:	74 04                	je     801bf5 <devpipe_read+0x26>
				return i;
  801bf1:	89 d8                	mov    %ebx,%eax
  801bf3:	eb 44                	jmp    801c39 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf5:	89 f2                	mov    %esi,%edx
  801bf7:	89 f8                	mov    %edi,%eax
  801bf9:	e8 e5 fe ff ff       	call   801ae3 <_pipeisclosed>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	75 32                	jne    801c34 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c02:	e8 9e ef ff ff       	call   800ba5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c07:	8b 06                	mov    (%esi),%eax
  801c09:	3b 46 04             	cmp    0x4(%esi),%eax
  801c0c:	74 df                	je     801bed <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0e:	99                   	cltd   
  801c0f:	c1 ea 1b             	shr    $0x1b,%edx
  801c12:	01 d0                	add    %edx,%eax
  801c14:	83 e0 1f             	and    $0x1f,%eax
  801c17:	29 d0                	sub    %edx,%eax
  801c19:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c21:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c24:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c27:	83 c3 01             	add    $0x1,%ebx
  801c2a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c2d:	75 d8                	jne    801c07 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c2f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c32:	eb 05                	jmp    801c39 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3c:	5b                   	pop    %ebx
  801c3d:	5e                   	pop    %esi
  801c3e:	5f                   	pop    %edi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4c:	50                   	push   %eax
  801c4d:	e8 ca f1 ff ff       	call   800e1c <fd_alloc>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	89 c2                	mov    %eax,%edx
  801c57:	85 c0                	test   %eax,%eax
  801c59:	0f 88 2c 01 00 00    	js     801d8b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	68 07 04 00 00       	push   $0x407
  801c67:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 53 ef ff ff       	call   800bc4 <sys_page_alloc>
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	89 c2                	mov    %eax,%edx
  801c76:	85 c0                	test   %eax,%eax
  801c78:	0f 88 0d 01 00 00    	js     801d8b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c84:	50                   	push   %eax
  801c85:	e8 92 f1 ff ff       	call   800e1c <fd_alloc>
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	0f 88 e2 00 00 00    	js     801d79 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c97:	83 ec 04             	sub    $0x4,%esp
  801c9a:	68 07 04 00 00       	push   $0x407
  801c9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 1b ef ff ff       	call   800bc4 <sys_page_alloc>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	0f 88 c3 00 00 00    	js     801d79 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbc:	e8 44 f1 ff ff       	call   800e05 <fd2data>
  801cc1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 c4 0c             	add    $0xc,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	50                   	push   %eax
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 f1 ee ff ff       	call   800bc4 <sys_page_alloc>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	0f 88 89 00 00 00    	js     801d69 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce0:	83 ec 0c             	sub    $0xc,%esp
  801ce3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce6:	e8 1a f1 ff ff       	call   800e05 <fd2data>
  801ceb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf2:	50                   	push   %eax
  801cf3:	6a 00                	push   $0x0
  801cf5:	56                   	push   %esi
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 0a ef ff ff       	call   800c07 <sys_page_map>
  801cfd:	89 c3                	mov    %eax,%ebx
  801cff:	83 c4 20             	add    $0x20,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 55                	js     801d5b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d06:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d24:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d29:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	ff 75 f4             	pushl  -0xc(%ebp)
  801d36:	e8 ba f0 ff ff       	call   800df5 <fd2num>
  801d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d40:	83 c4 04             	add    $0x4,%esp
  801d43:	ff 75 f0             	pushl  -0x10(%ebp)
  801d46:	e8 aa f0 ff ff       	call   800df5 <fd2num>
  801d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	ba 00 00 00 00       	mov    $0x0,%edx
  801d59:	eb 30                	jmp    801d8b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d5b:	83 ec 08             	sub    $0x8,%esp
  801d5e:	56                   	push   %esi
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 e3 ee ff ff       	call   800c49 <sys_page_unmap>
  801d66:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d69:	83 ec 08             	sub    $0x8,%esp
  801d6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 d3 ee ff ff       	call   800c49 <sys_page_unmap>
  801d76:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d79:	83 ec 08             	sub    $0x8,%esp
  801d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 c3 ee ff ff       	call   800c49 <sys_page_unmap>
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9d:	50                   	push   %eax
  801d9e:	ff 75 08             	pushl  0x8(%ebp)
  801da1:	e8 c5 f0 ff ff       	call   800e6b <fd_lookup>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 18                	js     801dc5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	ff 75 f4             	pushl  -0xc(%ebp)
  801db3:	e8 4d f0 ff ff       	call   800e05 <fd2data>
	return _pipeisclosed(fd, p);
  801db8:	89 c2                	mov    %eax,%edx
  801dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbd:	e8 21 fd ff ff       	call   801ae3 <_pipeisclosed>
  801dc2:	83 c4 10             	add    $0x10,%esp
}
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd7:	68 eb 27 80 00       	push   $0x8027eb
  801ddc:	ff 75 0c             	pushl  0xc(%ebp)
  801ddf:	e8 dd e9 ff ff       	call   8007c1 <strcpy>
	return 0;
}
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dfc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e02:	eb 2d                	jmp    801e31 <devcons_write+0x46>
		m = n - tot;
  801e04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e07:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e09:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e0c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e11:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	53                   	push   %ebx
  801e18:	03 45 0c             	add    0xc(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	57                   	push   %edi
  801e1d:	e8 31 eb ff ff       	call   800953 <memmove>
		sys_cputs(buf, m);
  801e22:	83 c4 08             	add    $0x8,%esp
  801e25:	53                   	push   %ebx
  801e26:	57                   	push   %edi
  801e27:	e8 dc ec ff ff       	call   800b08 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2c:	01 de                	add    %ebx,%esi
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	89 f0                	mov    %esi,%eax
  801e33:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e36:	72 cc                	jb     801e04 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5e                   	pop    %esi
  801e3d:	5f                   	pop    %edi
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 08             	sub    $0x8,%esp
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e4f:	74 2a                	je     801e7b <devcons_read+0x3b>
  801e51:	eb 05                	jmp    801e58 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e53:	e8 4d ed ff ff       	call   800ba5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e58:	e8 c9 ec ff ff       	call   800b26 <sys_cgetc>
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	74 f2                	je     801e53 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 16                	js     801e7b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e65:	83 f8 04             	cmp    $0x4,%eax
  801e68:	74 0c                	je     801e76 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6d:	88 02                	mov    %al,(%edx)
	return 1;
  801e6f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e74:	eb 05                	jmp    801e7b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e76:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e83:	8b 45 08             	mov    0x8(%ebp),%eax
  801e86:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e89:	6a 01                	push   $0x1
  801e8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8e:	50                   	push   %eax
  801e8f:	e8 74 ec ff ff       	call   800b08 <sys_cputs>
}
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	c9                   	leave  
  801e98:	c3                   	ret    

00801e99 <getchar>:

int
getchar(void)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e9f:	6a 01                	push   $0x1
  801ea1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea4:	50                   	push   %eax
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 25 f2 ff ff       	call   8010d1 <read>
	if (r < 0)
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	78 0f                	js     801ec2 <getchar+0x29>
		return r;
	if (r < 1)
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	7e 06                	jle    801ebd <getchar+0x24>
		return -E_EOF;
	return c;
  801eb7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ebb:	eb 05                	jmp    801ec2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ebd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecd:	50                   	push   %eax
  801ece:	ff 75 08             	pushl  0x8(%ebp)
  801ed1:	e8 95 ef ff ff       	call   800e6b <fd_lookup>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 11                	js     801eee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ee6:	39 10                	cmp    %edx,(%eax)
  801ee8:	0f 94 c0             	sete   %al
  801eeb:	0f b6 c0             	movzbl %al,%eax
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <opencons>:

int
opencons(void)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef9:	50                   	push   %eax
  801efa:	e8 1d ef ff ff       	call   800e1c <fd_alloc>
  801eff:	83 c4 10             	add    $0x10,%esp
		return r;
  801f02:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 3e                	js     801f46 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f08:	83 ec 04             	sub    $0x4,%esp
  801f0b:	68 07 04 00 00       	push   $0x407
  801f10:	ff 75 f4             	pushl  -0xc(%ebp)
  801f13:	6a 00                	push   $0x0
  801f15:	e8 aa ec ff ff       	call   800bc4 <sys_page_alloc>
  801f1a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f1d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 23                	js     801f46 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f23:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f38:	83 ec 0c             	sub    $0xc,%esp
  801f3b:	50                   	push   %eax
  801f3c:	e8 b4 ee ff ff       	call   800df5 <fd2num>
  801f41:	89 c2                	mov    %eax,%edx
  801f43:	83 c4 10             	add    $0x10,%esp
}
  801f46:	89 d0                	mov    %edx,%eax
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	56                   	push   %esi
  801f4e:	53                   	push   %ebx
  801f4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int ret;
	// LAB 4: Your code here.
    //if (!pg) {
    //	pg = (void*) -1;
    //}	
    if(pg != NULL)
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	74 0e                	je     801f6a <ipc_recv+0x20>
	{
	 	ret = sys_ipc_recv(pg);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	50                   	push   %eax
  801f60:	e8 0f ee ff ff       	call   800d74 <sys_ipc_recv>
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	eb 10                	jmp    801f7a <ipc_recv+0x30>
		//cprintf("back from the rev wait\n");
	}
	else
	{
		ret = sys_ipc_recv((void * )0xF0000000);
  801f6a:	83 ec 0c             	sub    $0xc,%esp
  801f6d:	68 00 00 00 f0       	push   $0xf0000000
  801f72:	e8 fd ed ff ff       	call   800d74 <sys_ipc_recv>
  801f77:	83 c4 10             	add    $0x10,%esp
	}
    //int ret = sys_ipc_recv(pg);
    if (ret) {
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	74 0e                	je     801f8c <ipc_recv+0x42>
    	*from_env_store = 0;
  801f7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    	*perm_store = 0;
  801f84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    	return ret;
  801f8a:	eb 24                	jmp    801fb0 <ipc_recv+0x66>
    }	
    if (from_env_store) {
  801f8c:	85 f6                	test   %esi,%esi
  801f8e:	74 0a                	je     801f9a <ipc_recv+0x50>
        *from_env_store = thisenv->env_ipc_from;
  801f90:	a1 08 40 80 00       	mov    0x804008,%eax
  801f95:	8b 40 74             	mov    0x74(%eax),%eax
  801f98:	89 06                	mov    %eax,(%esi)
    }    
    if (perm_store) {
  801f9a:	85 db                	test   %ebx,%ebx
  801f9c:	74 0a                	je     801fa8 <ipc_recv+0x5e>
        *perm_store = thisenv->env_ipc_perm;
  801f9e:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa3:	8b 40 78             	mov    0x78(%eax),%eax
  801fa6:	89 03                	mov    %eax,(%ebx)
    }
    return thisenv->env_ipc_value;
  801fa8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fad:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	57                   	push   %edi
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	83 ec 0c             	sub    $0xc,%esp
  801fc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) {
  801fc9:	85 db                	test   %ebx,%ebx
		pg = (void*)-1;
  801fcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fd0:	0f 44 d8             	cmove  %eax,%ebx
  801fd3:	eb 1c                	jmp    801ff1 <ipc_send+0x3a>
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
        //if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) {
  801fd5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd8:	74 12                	je     801fec <ipc_send+0x35>
        	panic("not E_IPC_NOT_RECV, %e\n", ret);
  801fda:	50                   	push   %eax
  801fdb:	68 f7 27 80 00       	push   $0x8027f7
  801fe0:	6a 4b                	push   $0x4b
  801fe2:	68 0f 28 80 00       	push   $0x80280f
  801fe7:	e8 77 e1 ff ff       	call   800163 <_panic>
        }	
        sys_yield();
  801fec:	e8 b4 eb ff ff       	call   800ba5 <sys_yield>
	// LAB 4: Your code here.
	if (!pg) {
		pg = (void*)-1;
	}	
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ff1:	ff 75 14             	pushl  0x14(%ebp)
  801ff4:	53                   	push   %ebx
  801ff5:	56                   	push   %esi
  801ff6:	57                   	push   %edi
  801ff7:	e8 55 ed ff ff       	call   800d51 <sys_ipc_try_send>
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	85 c0                	test   %eax,%eax
  802001:	75 d2                	jne    801fd5 <ipc_send+0x1e>
        }	
        sys_yield();
    }
   //return;
	//panic("ipc_send not implemented");
}
  802003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802016:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802019:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201f:	8b 52 50             	mov    0x50(%edx),%edx
  802022:	39 ca                	cmp    %ecx,%edx
  802024:	75 0d                	jne    802033 <ipc_find_env+0x28>
			return envs[i].env_id;
  802026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202e:	8b 40 48             	mov    0x48(%eax),%eax
  802031:	eb 0f                	jmp    802042 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802033:	83 c0 01             	add    $0x1,%eax
  802036:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203b:	75 d9                	jne    802016 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	c1 e8 16             	shr    $0x16,%eax
  80204f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205b:	f6 c1 01             	test   $0x1,%cl
  80205e:	74 1d                	je     80207d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802060:	c1 ea 0c             	shr    $0xc,%edx
  802063:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206a:	f6 c2 01             	test   $0x1,%dl
  80206d:	74 0e                	je     80207d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206f:	c1 ea 0c             	shr    $0xc,%edx
  802072:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802079:	ef 
  80207a:	0f b7 c0             	movzwl %ax,%eax
}
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
